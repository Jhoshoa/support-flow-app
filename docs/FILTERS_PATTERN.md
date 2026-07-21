# SupportFlow — Filter Implementation Pattern

> This document defines the standard pattern for implementing query filters in the SupportRequestsController. All filters must follow this pattern to ensure consistency, testability, and extensibility.

---

## Design Principle

**Use scope chaining with conditional application.** Each filter is a scope or query method that can be chained. The controller builds the query dynamically based on present parameters.

---

## Implementation

### 1. Define Scopes in the Model

```ruby
# app/models/support_request.rb
class SupportRequest < ApplicationRecord
  belongs_to :team_member, optional: true
  has_many :comments, dependent: :destroy

  enum status: { open: 0, in_progress: 1, resolved: 2, closed: 3 }
  enum priority: { low: 0, medium: 1, high: 2, critical: 3 }

  # Core scopes for filtering
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_team_member, ->(id) { where(team_member_id: id) }
  scope :overdue, -> {
    where('due_date < ?', Date.current)
      .where.not(status: [:resolved, :closed])
  }
  scope :unassigned, -> { where(team_member_id: nil) }
  scope :search_by_title, ->(query) {
    where('title LIKE ?', "%#{query}%")  # SQLite
    # For PostgreSQL: where('title ILIKE ?', "%#{query}%")
  }
end
```

### 2. Build Query in Controller

```ruby
# app/controllers/api/v1/support_requests_controller.rb
module Api
  module V1
    class SupportRequestsController < ApplicationController
      def index
        support_requests = filter_support_requests
        render json: { support_requests: support_requests.map { |r| serialize_request(r) } }
      end

      private

      def filter_support_requests
        scope = SupportRequest.all
        scope = scope.by_status(params[:status]) if params[:status].present?
        scope = scope.by_priority(params[:priority]) if params[:priority].present?
        scope = scope.by_team_member(params[:team_member_id]) if params[:team_member_id].present?
        scope = scope.overdue if params[:overdue] == 'true'
        scope = scope.unassigned if params[:unassigned] == 'true'
        scope = scope.search_by_title(params[:q]) if params[:q].present?
        scope.order(created_at: :desc)
      end

      def serialize_request(request)
        {
          id: request.id,
          title: request.title,
          description: request.description,
          status: request.status,
          priority: request.priority,
          due_date: request.due_date,
          completed_at: request.completed_at,
          overdue: request.overdue?,
          team_member: request.team_member&.slice(:id, :name),
          comments_count: request.comments.count,
          created_at: request.created_at,
          updated_at: request.updated_at
        }
      end
    end
  end
end
```

### 3. Alternative: Query Object Pattern (for complex cases)

If filter logic grows beyond 6 parameters, extract to a query object:

```ruby
# app/queries/support_request_filter.rb
class SupportRequestFilter
  def initialize(params)
    @params = params
  end

  def apply(scope = SupportRequest.all)
    scope = scope.by_status(@params[:status]) if @params[:status].present?
    scope = scope.by_priority(@params[:priority]) if @params[:priority].present?
    scope = scope.by_team_member(@params[:team_member_id]) if @params[:team_member_id].present?
    scope = scope.overdue if @params[:overdue] == 'true'
    scope = scope.unassigned if @params[:unassigned] == 'true'
    scope = scope.search_by_title(@params[:q]) if @params[:q].present?
    scope.order(created_at: :desc)
  end
end
```

```ruby
# In controller
def index
  filter = SupportRequestFilter.new(params)
  support_requests = filter.apply
  render json: { support_requests: support_requests.map { |r| serialize_request(r) } }
end
```

> **For this challenge, the inline controller approach is sufficient.** Use the query object only if the team decides to add more filters.

---

## Filter Matrix

| Filter | Param | Type | Scope | Example URL |
|--------|-------|------|-------|-------------|
| Status | `status` | String (enum) | `by_status` | `?status=open` |
| Priority | `priority` | String (enum) | `by_priority` | `?priority=critical` |
| Team Member | `team_member_id` | Integer | `by_team_member` | `?team_member_id=2` |
| Overdue | `overdue` | Boolean string | `overdue` | `?overdue=true` |
| Unassigned | `unassigned` | Boolean string | `unassigned` | `?unassigned=true` |
| Text Search | `q` | String | `search_by_title` | `?q=database+timeout` |

---

## Combined Filters

Filters are AND-combined (all conditions must match):

```
GET /api/v1/support_requests?status=open&priority=high&overdue=true
```

This returns requests that are:
- Status = open
- AND priority = high
- AND overdue = true

---

## Testing Filters

### Request Spec Pattern

```ruby
# spec/requests/support_requests_spec.rb
RSpec.describe 'Support Requests API', type: :request do
  describe 'GET /api/v1/support_requests' do
    let!(:open_request) { create(:support_request, status: :open, priority: :high) }
    let!(:resolved_request) { create(:support_request, status: :resolved, priority: :low) }
    let!(:overdue_request) { create(:support_request, status: :open, due_date: 2.days.ago) }
    let!(:unassigned_request) { create(:support_request, team_member: nil) }

    it 'filters by status' do
      get '/api/v1/support_requests', params: { status: 'open' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].length).to eq(3)  # open, overdue, unassigned
      expect(json['support_requests'].map { |r| r['status'] }).to all(eq('open'))
    end

    it 'filters by priority' do
      get '/api/v1/support_requests', params: { priority: 'high' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].map { |r| r['priority'] }).to all(eq('high'))
    end

    it 'filters by overdue' do
      get '/api/v1/support_requests', params: { overdue: 'true' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].length).to eq(1)
      expect(json['support_requests'].first['id']).to eq(overdue_request.id)
    end

    it 'filters by unassigned' do
      get '/api/v1/support_requests', params: { unassigned: 'true' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].length).to eq(1)
      expect(json['support_requests'].first['team_member']).to be_nil
    end

    it 'filters by text search' do
      open_request.update!(title: 'Database timeout issue')
      get '/api/v1/support_requests', params: { q: 'timeout' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].length).to eq(1)
      expect(json['support_requests'].first['title']).to include('timeout')
    end

    it 'combines multiple filters' do
      get '/api/v1/support_requests', params: { status: 'open', overdue: 'true' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].length).to eq(1)
      expect(json['support_requests'].first['status']).to eq('open')
      expect(json['support_requests'].first['overdue']).to be true
    end

    it 'returns all requests when no filters applied' do
      get '/api/v1/support_requests'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].length).to eq(4)
    end
  end
end
```

---

## Performance Considerations

1. **Database indexes:** Ensure indexes exist on frequently filtered columns:
   ```ruby
   add_index :support_requests, :status
   add_index :support_requests, :priority
   add_index :support_requests, :team_member_id
   add_index :support_requests, :due_date
   ```

2. **N+1 queries:** Use `includes` when serializing associations:
   ```ruby
   scope = scope.includes(:team_member, :comments) if params[:include] == 'all'
   ```

3. **Pagination:** Not required for this challenge, but add if list grows:
   ```ruby
   scope = scope.page(params[:page]).per(params[:per] || 20)
   ```

---

## SQLite vs PostgreSQL Compatibility

| Feature | SQLite | PostgreSQL | Solution |
|---------|--------|-----------|----------|
| Case-insensitive search | `LIKE` (case-sensitive by default) | `ILIKE` | Use `LIKE` for SQLite, document `ILIKE` for PG |
| Date comparison | Works | Works | ActiveRecord handles both |
| Enum storage | Integer | Integer | Same migration works for both |

**Migration note:** For production PostgreSQL, change `search_by_title` scope:
```ruby
scope :search_by_title, ->(query) {
  if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
    where('title ILIKE ?', "%#{query}%")
  else
    where('title LIKE ?', "%#{query}%")
  end
}
```

> **For this challenge, use `LIKE` (SQLite default).** Document the `ILIKE` change for PostgreSQL migration.