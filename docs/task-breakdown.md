# SupportFlow — Task Breakdown by Engineer

> This document contains individual checklists for each team member. Each engineer should track their own tasks without needing to scroll through the full planning document.

---

## 🔧 Engineer 1 — Models, Migrations, Validations, Team Members API

### Day 0 — Foundation
- [ ] Initialize Rails API (`rails new backend --api --database=sqlite3`)
- [ ] Configure `database.yml` with SQLite dev/test, PostgreSQL prod (commented)
- [ ] Add `rack-cors` gem and configure CORS for `localhost:5173`
- [ ] Set up RSpec + FactoryBot (`rails g rspec:install`)
- [ ] Create `.env.example` for backend
- [ ] Review PR #1 (Initial project setup)

### Day 1 — Rails Core
- [ ] Generate migration `CreateTeamMembers` (name, email, role, active)
- [ ] Define `TeamMember` model with validations (name, email format/unique, enum role)
- [ ] Define associations (`has_many :support_requests`)
- [ ] Create factory `spec/factories/team_members.rb`
- [ ] Write model specs: validations, enum, associations
- [ ] Create PR #2: "Add TeamMember model, migration, validations"
- [ ] Review PR #3 (SupportRequest model)
- [ ] Review PR #4 (Comment model)

### Day 2 — API & Business Rules
- [ ] Implement `TeamMembersController` with `index`, `create`, `update`
- [ ] Configure routes for team members in `config/routes.rb`
- [ ] Implement strong params `team_member_params`
- [ ] Add consistent error handling in `ApplicationController` (`render_error`)
- [ ] Write request specs: index (200), create valid (201), create invalid (422), update deactivate
- [ ] Create PR #5: "Implement TeamMembers API with tests"
- [ ] Review PR #6 (SupportRequests API)
- [ ] Review PR #7 (Comments & Dashboard API)

### Day 3 — Vue & Polish
- [ ] Implement `TeamMemberList.vue` component
- [ ] Implement `TeamMemberForm.vue` component
- [ ] Implement toggle active/inactive in Team Member list
- [ ] Add loading and error states to Team Members views
- [ ] Create PR #11: "Vue Team Members view and integration polish"
- [ ] Review PR #9 (Vue Dashboard)
- [ ] Review PR #10 (Vue Support Request views)

### Documentation
- [ ] Update README with setup instructions
- [ ] Document individual contribution in README team table
- [ ] Prepare individual defense: endpoint, tests, decisions, blockers, reviewed PRs

---

## 🔧 Engineer 2 — Support Requests API, Filters, Business Rules

### Day 0 — Foundation
- [ ] Review PR #1 (Initial project setup)
- [ ] Verify Rails API runs correctly (`rails s`)

### Day 1 — Rails Core
- [ ] Generate migration `CreateSupportRequests` (title, description, status, priority, due_date, completed_at, team_member_id)
- [ ] Define `SupportRequest` model with validations (title, description)
- [ ] Define enums: `status` (open, in_progress, resolved, closed), `priority` (low, medium, high, critical)
- [ ] Define associations (`belongs_to :team_member, optional: true`, `has_many :comments`)
- [ ] Implement business rules in model:
  - [ ] Rule 2: Cannot assign to inactive team member
  - [ ] Rule 3: Auto-set `completed_at` when status → resolved
  - [ ] Rule 4: Clear `completed_at` when status leaves resolved
  - [ ] Rule 5: Closed cannot return to open
  - [ ] Rule 6: Closed cannot be edited (except comments)
  - [ ] Rule 7: Overdue scope/method
- [ ] Create factory `spec/factories/support_requests.rb`
- [ ] Write model specs: validations, business rules, overdue logic, state transitions
- [ ] Create PR #3: "Add SupportRequest model, business rules, and seeds"
- [ ] Review PR #2 (TeamMember model)
- [ ] Review PR #4 (Comment model)

### Day 2 — API & Business Rules
- [ ] Implement `SupportRequestsController` with `index`, `show`, `create`, `update`
- [ ] Implement filters in `index`: status, priority, team_member_id, overdue, unassigned, text search
- [ ] Configure routes for support requests
- [ ] Write request specs:
  - [ ] Index with filters (test at least 2 filters individually + combined)
  - [ ] Show (200 with comments, 404)
  - [ ] Create valid (201), invalid (422)
  - [ ] Update status, assignment, invalid assignment, closed edit restriction
- [ ] Create PR #6: "Implement SupportRequests API, filters, and business rules"
- [ ] Review PR #5 (TeamMembers API)
- [ ] Review PR #7 (Comments & Dashboard API)

### Day 3 — Vue & Polish
- [ ] Implement `SupportRequestList.vue` with filters UI
- [ ] Implement `SupportRequestDetail.vue` with comments
- [ ] Implement `SupportRequestForm.vue` for create/edit
- [ ] Implement `CommentList.vue` and `CommentForm.vue`
- [ ] Add overdue badge/visual indicator in list
- [ ] Add loading and error states
- [ ] Create PR #10: "Vue Support Request views — list, detail, form, comments"
- [ ] Review PR #9 (Vue Dashboard)
- [ ] Review PR #11 (Vue Team Members)

### Documentation
- [ ] Document business rules in code comments
- [ ] Document filter implementation approach
- [ ] Prepare individual defense: endpoint, tests, decisions, blockers, reviewed PRs

---

## 🔧 Engineer 3 — Vue Setup, Comments API, Dashboard API

### Day 0 — Foundation
- [ ] Initialize Vue 3 with Vite (`npm create vite@latest frontend -- --template vue`)
- [ ] Install dependencies: `axios`, `vue-router@4`, `pinia`
- [ ] Configure Vue Router with routes: `/`, `/requests`, `/requests/:id`, `/members`
- [ ] Create `.env.example` for frontend (`VITE_API_BASE_URL`)
- [ ] Create `src/api/client.js` — Axios instance with baseURL
- [ ] Review PR #1 (Initial project setup)

### Day 1 — Rails Core
- [ ] Generate migration `CreateComments` (body, author_name, support_request_id)
- [ ] Define `Comment` model with validations (body min 10 chars, author_name required)
- [ ] Define associations (`belongs_to :support_request`)
- [ ] Create factory `spec/factories/comments.rb`
- [ ] Write model specs: validations, minimum length, associations
- [ ] Create PR #4: "Add Comment model and nested routing"
- [ ] Review PR #2 (TeamMember model)
- [ ] Review PR #3 (SupportRequest model)

### Day 2 — API & Business Rules
- [ ] Implement `CommentsController` with `create` (nested under support_requests)
- [ ] Configure nested routes: `resources :support_requests do resources :comments, only: [:create] end`
- [ ] Write request specs: create valid (201), body too short (422), request not found (404)
- [ ] Implement `DashboardController` with `index`
- [ ] Implement dashboard aggregations: total, overdue, unassigned, by_status, by_priority
- [ ] Write request spec: dashboard structure and values
- [ ] Create PR #7: "Implement Comments and Dashboard API with tests"
- [ ] Review PR #5 (TeamMembers API)
- [ ] Review PR #6 (SupportRequests API)

### Day 3 — Vue & Polish
- [ ] Implement `Dashboard.vue` with metric cards
- [ ] Create Pinia stores: `supportRequestStore`, `teamMemberStore`, `dashboardStore`
- [ ] Implement shared components: `LoadingSpinner.vue`, `ErrorMessage.vue`
- [ ] Implement `FilterBar.vue` with all filter controls
- [ ] Wire up all Vue views to consume real API
- [ ] Ensure auto-refresh after create/update/comment
- [ ] Handle API errors gracefully in all views
- [ ] Create PR #9: "Vue setup, routing, and Dashboard view"
- [ ] Review PR #10 (Vue Support Request views)
- [ ] Review PR #11 (Vue Team Members)

### Documentation
- [ ] Document Vue component architecture
- [ ] Document API client configuration
- [ ] Prepare individual defense: endpoint, tests, decisions, blockers, reviewed PRs

---

## 📋 Shared Responsibilities (All Engineers)

### Day 0
- [ ] Create repository and protect `main` branch
- [ ] Set up branch protection rules (1 review minimum)
- [ ] Agree on commit message convention
- [ ] Create `docs/` directory structure

### Day 1
- [ ] Verify all migrations run cleanly: `rails db:migrate`
- [ ] Verify seeds work: `rails db:seed`
- [ ] Verify models in console: `rails c`
- [ ] Each engineer reviews at least 1 PR from another engineer

### Day 2
- [ ] Run full test suite: `bundle exec rspec` — all green
- [ ] Verify API endpoints with curl/Postman
- [ ] Each engineer reviews at least 1 PR from another engineer
- [ ] Update `docs/daily-checkpoints.md` with Day 2 notes

### Day 3
- [ ] Clean clone test: clone in new folder, follow README, verify it works
- [ ] Final `bundle exec rspec` — all green
- [ ] Verify no secrets in repository
- [ ] Complete `DECISIONS.md` with ≥3 technical decisions
- [ ] Complete `docs/daily-checkpoints.md`
- [ ] Complete `docs/pr-reviews.md` with review evidence
- [ ] Final PR merge to `main`
- [ ] Practice demo script as a team
- [ ] Prepare individual defense talking points

---

## 🚦 Dependency Map

```
PR #1 (Project Setup)
  │
  ├──► PR #2 (TeamMember Model) ──┐
  │                                │
  ├──► PR #3 (SupportRequest) ◄────┘ (depends on TeamMember for FK)
  │       │
  │       └──► PR #4 (Comment Model) (depends on SupportRequest for FK)
  │
  ├──► PR #5 (TeamMembers API)
  ├──► PR #6 (SupportRequests API) ──┐
  │                                    │
  └──► PR #7 (Comments + Dashboard) ◄─┘ (depends on SupportRequest scopes)
       │
       └──► PR #8 (Backend Tests) (depends on all APIs)
            │
            ├──► PR #9 (Vue Dashboard)
            ├──► PR #10 (Vue Requests)
            └──► PR #11 (Vue Members)
```

> **Critical Path:** PR #2 → PR #3 → PR #4 → PR #7 → PR #8 → PR #9/10/11
> Engineer 1 should prioritize PR #2 early to unblock Engineer 2.