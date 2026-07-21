# SupportFlow — Business Rules Implementation Guide

> This document provides pseudocode and implementation guidance for all 7 mandatory business rules. These rules MUST be enforced in the Rails backend, not only in Vue.

---

## Rule 1: Support request may be created without an assigned team member

**Requirement:** `team_member_id` is optional on creation.

**Implementation:**
```ruby
# app/models/support_request.rb
belongs_to :team_member, optional: true
```

**Test:**
```ruby
# spec/models/support_request_spec.rb
it 'can be created without a team member' do
  request = build(:support_request, team_member: nil)
  expect(request).to be_valid
  expect(request.save).to be true
end
```

---

## Rule 2: Support request cannot be assigned to an inactive team member

**Requirement:** If `team_member_id` is present, the referenced team member must have `active: true`.

**Implementation:**
```ruby
# app/models/support_request.rb
validate :team_member_must_be_active, if: :team_member_id?

private

def team_member_must_be_active
  return unless team_member.present? && !team_member.active?

  errors.add(:team_member, 'must be active')
end
```

**Test:**
```ruby
# spec/models/support_request_spec.rb
it 'is invalid when assigned to an inactive team member' do
  inactive_member = create(:team_member, active: false)
  request = build(:support_request, team_member: inactive_member)
  expect(request).not_to be_valid
  expect(request.errors[:team_member]).to include('must be active')
end

it 'is valid when assigned to an active team member' do
  active_member = create(:team_member, active: true)
  request = build(:support_request, team_member: active_member)
  expect(request).to be_valid
end
```

---

## Rule 3: When a request changes to resolved, completed_at must be set automatically

**Requirement:** On update, if `status` changes TO `resolved`, set `completed_at` to current time.

**Implementation:**
```ruby
# app/models/support_request.rb
before_update :set_completed_at_if_resolved

private

def set_completed_at_if_resolved
  return unless status_changed? && status == 'resolved'

  self.completed_at = Time.current
end
```

**Alternative (using enum integer):**
```ruby
def set_completed_at_if_resolved
  return unless status_changed? && resolved?

  self.completed_at = Time.current
end
```

**Test:**
```ruby
# spec/models/support_request_spec.rb
it 'sets completed_at when status changes to resolved' do
  request = create(:support_request, status: :in_progress, completed_at: nil)
  request.update!(status: :resolved)
  expect(request.reload.completed_at).to be_present
end

it 'does not set completed_at when status changes to in_progress' do
  request = create(:support_request, status: :open, completed_at: nil)
  request.update!(status: :in_progress)
  expect(request.reload.completed_at).to be_nil
end
```

---

## Rule 4: When a request leaves the resolved state, completed_at must be cleared

**Requirement:** On update, if `status` changes FROM `resolved` TO anything else, clear `completed_at`.

**Implementation:**
```ruby
# app/models/support_request.rb
before_update :clear_completed_at_if_not_resolved

private

def clear_completed_at_if_not_resolved
  return unless status_changed? && status_was == 'resolved' && status != 'resolved'

  self.completed_at = nil
end
```

**Alternative:**
```ruby
def clear_completed_at_if_not_resolved
  return unless status_changed? && resolved? && !resolved?
  # Wait, this logic is tricky. Better approach:
  return unless status_changed? && status_was == 'resolved' && !resolved?

  self.completed_at = nil
end
```

**Test:**
```ruby
# spec/models/support_request_spec.rb
it 'clears completed_at when leaving resolved state' do
  request = create(:support_request, status: :resolved, completed_at: Time.current)
  request.update!(status: :in_progress)
  expect(request.reload.completed_at).to be_nil
end

it 'keeps completed_at when staying resolved' do
  request = create(:support_request, status: :resolved, completed_at: Time.current)
  request.update!(priority: :high)  # Change something else
  expect(request.reload.completed_at).to be_present
end
```

---

## Rule 5: A closed request cannot return to the open state

**Requirement:** If `status_was == 'closed'` and `status == 'open'`, reject the update.

**Implementation:**
```ruby
# app/models/support_request.rb
validate :closed_cannot_reopen, if: :status_changed?

private

def closed_cannot_reopen
  return unless status_was == 'closed' && status == 'open'

  errors.add(:status, 'A closed request cannot be reopened')
end
```

**Test:**
```ruby
# spec/models/support_request_spec.rb
it 'cannot transition from closed to open' do
  request = create(:support_request, status: :closed)
  request.status = :open
  expect(request).not_to be_valid
  expect(request.errors[:status]).to include('A closed request cannot be reopened')
end

it 'can transition from closed to resolved' do
  request = create(:support_request, status: :closed)
  request.status = :resolved
  expect(request).to be_valid
end
```

---

## Rule 6: A closed request cannot be edited, except that a new comment may still be added

**Requirement:** Once `status == 'closed'`, no fields can be updated EXCEPT through the comments controller.

**Implementation:**
```ruby
# app/models/support_request.rb
validate :closed_cannot_be_edited, on: :update

private

def closed_cannot_be_edited
  return unless closed? && changed?
  return if changes.keys == ['updated_at']  # Allow timestamp-only updates

  errors.add(:base, 'A closed request cannot be edited')
end
```

**IMPORTANT:** The comments controller must bypass this validation when creating comments:
```ruby
# app/controllers/api/v1/comments_controller.rb
# Comments are created independently — they don't modify the support request
# So this validation only applies to SupportRequest updates, not Comment creation
```

**Test:**
```ruby
# spec/models/support_request_spec.rb
it 'cannot be edited when closed' do
  request = create(:support_request, status: :closed)
  request.title = 'New title'
  expect(request).not_to be_valid
  expect(request.errors[:base]).to include('A closed request cannot be edited')
end

it 'allows comments to be added when closed' do
  request = create(:support_request, status: :closed)
  comment = build(:comment, support_request: request)
  expect(comment).to be_valid
  expect(comment.save).to be true
end
```

**Request spec for closed edit:**
```ruby
# spec/requests/support_requests_spec.rb
it 'returns 422 when trying to edit a closed request' do
  closed_request = create(:support_request, status: :closed)
  patch "/api/v1/support_requests/#{closed_request.id}",
        params: { support_request: { title: 'New title' } }
  expect(response).to have_http_status(:unprocessable_entity)
  expect(JSON.parse(response.body)['details']).to include('A closed request cannot be edited')
end
```

---

## Rule 7: A request is overdue when its due date is before today and its status is neither resolved nor closed

**Requirement:** Computed property + scope for filtering.

**Implementation:**
```ruby
# app/models/support_request.rb
scope :overdue, -> {
  where('due_date < ?', Date.current)
    .where.not(status: [:resolved, :closed])
}

def overdue?
  return false if due_date.nil?
  return false if resolved? || closed?

  due_date < Date.current
end
```

**Test:**
```ruby
# spec/models/support_request_spec.rb
describe '#overdue?' do
  it 'returns true when due_date is in the past and status is open' do
    request = build(:support_request, due_date: 1.day.ago, status: :open)
    expect(request.overdue?).to be true
  end

  it 'returns false when due_date is in the future' do
    request = build(:support_request, due_date: 1.day.from_now, status: :open)
    expect(request.overdue?).to be false
  end

  it 'returns false when status is resolved' do
    request = build(:support_request, due_date: 1.day.ago, status: :resolved)
    expect(request.overdue?).to be false
  end

  it 'returns false when status is closed' do
    request = build(:support_request, due_date: 1.day.ago, status: :closed)
    expect(request.overdue?).to be false
  end

  it 'returns false when due_date is nil' do
    request = build(:support_request, due_date: nil, status: :open)
    expect(request.overdue?).to be false
  end
end

describe '.overdue scope' do
  it 'returns only overdue requests' do
    overdue = create(:support_request, due_date: 2.days.ago, status: :open)
    create(:support_request, due_date: 2.days.ago, status: :resolved)
    create(:support_request, due_date: 2.days.from_now, status: :open)

    expect(SupportRequest.overdue).to eq([overdue])
  end
end
```

---

## Implementation Order Recommendation

```
1. Rule 1 (optional association) — First, no dependencies
2. Rule 7 (overdue scope) — Independent, needed for dashboard
3. Rule 2 (inactive assignment) — Needs TeamMember model ready
4. Rule 3 (auto completed_at) — Needs status enum ready
5. Rule 4 (clear completed_at) — Depends on Rule 3
6. Rule 5 (closed → open) — Depends on status enum
7. Rule 6 (closed edit restriction) — Last, most complex
```

> **Note:** Rules 3, 4, 5, and 6 all interact with status transitions. Consider extracting status transition logic into a service object if complexity grows, but for this challenge, model callbacks + validations are sufficient.

---

## Testing Checklist

- [ ] Rule 1: Create without team member
- [ ] Rule 2: Assign to inactive member → error
- [ ] Rule 3: Status → resolved → completed_at set
- [ ] Rule 3: Status → resolved from any state → completed_at set
- [ ] Rule 4: Status leaves resolved → completed_at cleared
- [ ] Rule 5: Closed → open → error
- [ ] Rule 5: Closed → in_progress → allowed
- [ ] Rule 5: Closed → resolved → allowed
- [ ] Rule 6: Edit closed request → error
- [ ] Rule 6: Add comment to closed request → allowed
- [ ] Rule 7: overdue? true when past due + open/in_progress
- [ ] Rule 7: overdue? false when resolved/closed
- [ ] Rule 7: overdue? false when no due_date
- [ ] Rule 7: overdue scope returns correct records