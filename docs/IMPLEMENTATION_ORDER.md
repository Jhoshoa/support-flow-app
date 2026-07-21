# SupportFlow — Implementation Order Guide

> Step-by-step guide for implementing the project. Each phase depends on the previous one. Follow this order to avoid errors.

---

## How to Read This Document

- **Prerequisites**: What must be done BEFORE starting this step
- **What to do**: Exact files to create/modify
- **Verify**: How to confirm the step works
- **Commit**: When to commit

---

## Phase 0: Foundation ✅ COMPLETE

All dependencies installed, CORS configured, Vite proxy ready.

| Component | Status | File |
|-----------|--------|------|
| Rails 8.1.3 API | ✅ | `backend/` |
| Vue 3 + Vite | ✅ | `frontend/` |
| rack-cors | ✅ | `backend/Gemfile:46` |
| rspec-rails | ✅ | `backend/Gemfile:48` |
| factory_bot_rails | ✅ | `backend/Gemfile:50` |
| faker | ✅ | `backend/Gemfile:52` |
| axios | ✅ | `frontend/package.json` |
| vue-router | ✅ | `frontend/package.json` |
| pinia | ✅ | `frontend/package.json` |
| CORS config | ✅ | `backend/config/initializers/cors.rb` |
| Vite proxy | ✅ | `frontend/vite.config.js` |
| RSpec setup | ✅ | `backend/spec/rails_helper.rb` |

---

## Phase 1: Rails Core (Day 1)

### Step 1.1: Configure RSpec for FactoryBot

**Prerequisites**: Phase 0 complete

**Files to modify**:
- `backend/spec/rails_helper.rb` — Add FactoryBot configuration

**What to add** (inside `RSpec.configure do |config|` block):

```ruby
config.include FactoryBot::Syntax::Methods
```

**Verify**: `bundle exec rspec` runs without errors (0 examples, 0 failures)

**Commit**: `test(rspec): configure FactoryBot integration`

---

### Step 1.2: Create TeamMember Migration + Model

**Prerequisites**: Step 1.1 complete

**Files to create**:
- `backend/db/migrate/YYYYMMDDHHMMSS_create_team_members.rb`
- `backend/app/models/team_member.rb`
- `backend/spec/models/team_member_spec.rb`
- `backend/spec/factories/team_members.rb`

**Migration columns**:
```
name:string
email:string
role:integer
active:boolean (default: true)
```

**Model rules**:
- `enum role: { developer: 0, qa: 1, support: 2 }`
- `validates :name, presence: true`
- `validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }`
- `has_many :support_requests, dependent: :nullify`

**Verify**: `rails db:migrate` succeeds, `rails c` → `TeamMember.create!(name: "Test", email: "test@test.com", role: :developer)` works

**Commit**: `feat(models): add TeamMember with validations and enum`

---

### Step 1.3: Create SupportRequest Migration + Model

**Prerequisites**: Step 1.2 complete (needs TeamMember for FK)

**Files to create**:
- `backend/db/migrate/YYYYMMDDHHMMSS_create_support_requests.rb`
- `backend/app/models/support_request.rb`
- `backend/spec/models/support_request_spec.rb`
- `backend/spec/factories/support_requests.rb`

**Migration columns**:
```
title:string
description:text
status:integer
priority:integer
due_date:date
completed_at:datetime
team_member:references (optional)
```

**Model rules**:
- `enum status: { open: 0, in_progress: 1, resolved: 2, closed: 3 }`
- `enum priority: { low: 0, medium: 1, high: 2, critical: 3 }`
- `belongs_to :team_member, optional: true`
- `has_many :comments, dependent: :destroy`
- 7 business rules (see `docs/BUSINESS_RULES.md`)

**Verify**: `rails db:migrate` succeeds, model tests pass

**Commit**: `feat(models): add SupportRequest with enums and business rules`

---

### Step 1.4: Create Comment Migration + Model

**Prerequisites**: Step 1.3 complete (needs SupportRequest for FK)

**Files to create**:
- `backend/db/migrate/YYYYMMDDHHMMSS_create_comments.rb`
- `backend/app/models/comment.rb`
- `backend/spec/models/comment_spec.rb`
- `backend/spec/factories/comments.rb`

**Migration columns**:
```
body:text
author_name:string
support_request:references
```

**Model rules**:
- `belongs_to :support_request`
- `validates :body, presence: true, length: { minimum: 10 }`
- `validates :author_name, presence: true`

**Verify**: All model tests pass

**Commit**: `feat(models): add Comment with validations`

---

### Step 1.5: Create Seeds

**Prerequisites**: Steps 1.2, 1.3, 1.4 complete

**Files to modify**:
- `backend/db/seeds.rb`

**Requirements**:
- ≥5 TeamMembers (mix of roles, some active/inactive)
- ≥15 SupportRequests (varied status/priority, some overdue, some unassigned)
- ≥10 Comments distributed across requests

**Verify**: `rails db:seed` runs without errors

**Commit**: `feat(seeds): add sample data for development`

---

### Step 1.6: Commit Phase 1

**Verify**:
- `rails db:migrate && rails db:seed` works
- `bundle exec rspec` — all model tests pass
- `rails c` — can create and query records

**Commit**: `feat(phase1): complete Rails core with models, migrations, and seeds`

---

## Phase 2: API Endpoints (Day 2 Morning)

### Step 2.1: Configure Routes

**Prerequisites**: Phase 1 complete

**Files to modify**:
- `backend/config/routes.rb`

**What to add**:

```ruby
namespace :api do
  namespace :v1 do
    resources :team_members, only: [:index, :create, :update]
    resources :support_requests do
      resources :comments, only: [:create]
    end
    get 'dashboard', to: 'dashboard#index'
  end
end
```

**Verify**: `rails routes` shows all endpoints

**Commit**: `feat(routes): configure API v1 namespace`

---

### Step 2.2: Error Handling in ApplicationController

**Prerequisites**: Step 2.1 complete

**Files to modify**:
- `backend/app/controllers/application_controller.rb`

**What to add**:
- `rescue_from ActiveRecord::RecordNotFound` → 404
- `rescue_from ActiveRecord::RecordInvalid` → 422
- Helper method `render_error(message, details, status)`

**Verify**: `bundle exec rspec` still passes

**Commit**: `feat(api): add consistent error handling`

---

### Step 2.3: TeamMembersController

**Prerequisites**: Steps 2.1, 2.2 complete

**Files to create**:
- `backend/app/controllers/api/v1/team_members_controller.rb`
- `backend/spec/requests/api/v1/team_members_spec.rb`

**Actions**: `index`, `create`, `update`

**Verify**: `curl http://localhost:3000/api/v1/team_members` returns JSON

**Commit**: `feat(api): add TeamMembers endpoint`

---

### Step 2.4: SupportRequestsController

**Prerequisites**: Step 2.3 complete

**Files to create**:
- `backend/app/controllers/api/v1/support_requests_controller.rb`
- `backend/spec/requests/api/v1/support_requests_spec.rb`

**Actions**: `index` (with filters), `show`, `create`, `update`

**Verify**: `curl http://localhost:3000/api/v1/support_requests` returns JSON with filters working

**Commit**: `feat(api): add SupportRequests endpoint with filters`

---

### Step 2.5: CommentsController + DashboardController

**Prerequisites**: Step 2.4 complete

**Files to create**:
- `backend/app/controllers/api/v1/comments_controller.rb`
- `backend/app/controllers/api/v1/dashboard_controller.rb`
- `backend/spec/requests/api/v1/comments_spec.rb`
- `backend/spec/requests/api/v1/dashboard_spec.rb`

**Verify**: All endpoints return correct JSON (see `docs/API_RESPONSES.md`)

**Commit**: `feat(api): add Comments and Dashboard endpoints`

---

### Step 2.6: Commit Phase 2

**Verify**:
- `bundle exec rspec` — all tests pass (model + request)
- `curl` all endpoints — correct responses
- Filters work: `?status=open`, `?overdue=true`, etc.

**Commit**: `feat(phase2): complete all API endpoints with tests`

---

## Phase 3: Vue Integration (Day 2 PM - Day 3 AM)

### Step 3.1: Vue API Client

**Prerequisites**: Phase 2 complete

**Files to create**:
- `frontend/src/api/client.js`

**What to configure**:
- Axios instance with baseURL
- Response interceptor for error handling

**Verify**: `import apiClient from '@/api/client.js'` works in Vue

**Commit**: `feat(frontend): add Axios API client`

---

### Step 3.2: Vue Router

**Prerequisites**: Step 3.1 complete

**Files to create**:
- `frontend/src/router/index.js`

**Routes**:
- `/` → Dashboard
- `/requests` → SupportRequestList
- `/requests/new` → SupportRequestForm
- `/requests/:id` → SupportRequestDetail
- `/requests/:id/edit` → SupportRequestForm
- `/members` → TeamMemberList

**Verify**: `npm run dev` → navigating between routes works

**Commit**: `feat(frontend): configure Vue Router`

---

### Step 3.3: Pinia Stores

**Prerequisites**: Step 3.2 complete

**Files to create**:
- `frontend/src/stores/dashboardStore.js`
- `frontend/src/stores/supportRequestStore.js`
- `frontend/src/stores/teamMemberStore.js`

**Verify**: Stores are accessible in components

**Commit**: `feat(frontend): add Pinia stores`

---

### Step 3.4: Vue Views

**Prerequisites**: Step 3.3 complete

**Files to create/modify**:
- `frontend/src/App.vue` — Layout with sidebar
- `frontend/src/views/Dashboard.vue`
- `frontend/src/views/SupportRequestList.vue`
- `frontend/src/views/SupportRequestDetail.vue`
- `frontend/src/views/SupportRequestForm.vue`
- `frontend/src/views/TeamMemberList.vue`

**Verify**: Full flow works: create request → assign → comment → resolve → dashboard

**Commit**: `feat(frontend): implement all views`

---

### Step 3.5: Commit Phase 3

**Verify**:
- Frontend loads without errors
- All views display data from API
- Create/edit forms work
- Loading and error states show correctly

**Commit**: `feat(phase3): complete Vue integration`

---

## Phase 4: Polish & Documentation (Day 3 PM)

### Step 4.1: Documentation

**Files to create/update**:
- `README.md` — Setup instructions, architecture, team
- `DECISIONS.md` — Technical decisions
- `.env.example` — Environment variables

**Commit**: `docs: complete project documentation`

---

### Step 4.2: Final Validation

**Verify**:
- `rails db:setup` works from clean state
- `bundle exec rspec` — all tests green
- No secrets in repo
- Clean clone test: new developer can set up in < 5 minutes

**Commit**: `chore: final cleanup and validation`

---

## Dependency Graph

```
Phase 0 ✅
    │
    ▼
Phase 1 (Models)
    │
    ├── Step 1.2: TeamMember ──────┐
    │                              ▼
    ├── Step 1.3: SupportRequest ◄─┘ (FK dependency)
    │                    │
    │                    ▼
    └── Step 1.4: Comment ◄──────── (FK dependency)
         │
         ▼
Phase 2 (API)
    │
    ├── Step 2.3: TeamMembers API ──┐
    ├── Step 2.4: SupportRequests API ──► Step 2.5: Comments + Dashboard
    │
    ▼
Phase 3 (Vue)
    │
    ├── Step 3.1: API Client ──► Step 3.2: Router ──► Step 3.3: Stores ──► Step 3.4: Views
    │
    ▼
Phase 4 (Polish)
```

---

## Quick Reference: What Depends on What

| Step | Depends On | Why |
|------|-----------|-----|
| 1.2 TeamMember | — | First model, no dependencies |
| 1.3 SupportRequest | 1.2 | `team_member_id` foreign key |
| 1.4 Comment | 1.3 | `support_request_id` foreign key |
| 1.5 Seeds | 1.2, 1.3, 1.4 | Needs all models to create records |
| 2.3 TeamMembers API | 1.2 | Needs TeamMember model |
| 2.4 SupportRequests API | 1.3, 2.3 | Needs SupportRequest model + TeamMember for assignment |
| 2.5 Comments API | 1.4, 2.4 | Needs Comment model + SupportRequest endpoint |
| 3.1 API Client | 2.x | Needs working API to connect to |
| 3.4 Views | 3.3, 2.x | Needs stores + working API |

---

*Follow this order. Each step builds on the previous one. If something breaks, check the step before it.*
