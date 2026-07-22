# SupportFlow — User Stories for JIRA

> Comprehensive user stories for the SupportFlow project. Each story maps to a JIRA ticket.
> **Team:** Carlos (Backend Models & TeamMember API), Alejandro (SupportRequests API & Business Rules), Josoe (Vue Frontend & Dashboard/Comments API)

---

## Legend

| Field | Description |
|-------|-------------|
| **ID** | JIRA Ticket ID (SF-XXX) |
| **Phase** | Implementation phase |
| **Step** | Step within phase |
| **Assignee** | Primary owner (C=Carlos, A=Alejandro, J=Josoe) |
| **Priority** | High / Medium / Low |
| **Story Points** | Estimated complexity (Fibonacci) |
| **Dependencies** | Ticket(s) that must be completed first |
| **Type** | Backend / Frontend / Full-Stack / DevOps / Docs |

---

## Phase 0: Foundation

---

### SF-001 — Initialize Rails API Project with SQLite

| Field | Value |
|-------|-------|
| **Phase** | 0 |
| **Step** | 0.1a |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | None |
| **Status** | Done |

#### Description

As a backend developer, I want a Rails API project initialized with SQLite so that the team has a working backend foundation for building support request endpoints.

#### Acceptance Criteria

- [ ] Rails project created in `backend/` directory using `rails new . --api --database=sqlite3 --skip-test`
- [ ] `backend/Gemfile` includes: `rails ~> 8.1.3`, `sqlite3 ~> 2.0`, `puma ~> 6.0`
- [ ] `backend/config/database.yml` configured with SQLite for development and test, PostgreSQL placeholder for production
- [ ] `rails db:create` succeeds without errors
- [ ] `rails server` starts on port 3000
- [ ] `GET http://localhost:3000/up` returns 200 (health check)
- [ ] `.gitignore` excludes `db/*.sqlite3`, `log/*`, `tmp/*`, `config/master.key`

#### Implementation Notes

```bash
cd backend
rails new . --api --database=sqlite3 --skip-test --skip-action-mailer --skip-active-storage --skip-action-text --skip-javascript --skip-turbolinks --skip-spring
```

**Gemfile additions:**
```ruby
gem "rails", "~> 8.1.3"
gem "sqlite3", "~> 2.0"
gem "puma", "~> 6.0"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
```

**database.yml:**
```yaml
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3
```

#### How to Verify

```bash
cd backend
rails db:create
rails server &
sleep 2
curl http://localhost:3000/up
# Expected: 200 OK
kill %1
```

#### Commit Message

```
feat(backend): initialize Rails 8.1 API project with SQLite
```

---

### SF-002 — Initialize Vue 3 + Vite Frontend

| Field | Value |
|-------|-------|
| **Phase** | 0 |
| **Step** | 0.1b |
| **Type** | Frontend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | None |
| **Status** | Done |

#### Description

As a frontend developer, I want a Vue 3 project initialized with Vite so that the team has a working frontend foundation for building the support request UI.

#### Acceptance Criteria

- [ ] Vue 3 project created in `frontend/` directory using `npm create vite@latest . -- --template vue`
- [ ] `frontend/package.json` includes: `vue ^3.x`, `vite ^6.x`, `@vitejs/plugin-vue`
- [ ] `frontend/vite.config.js` exists with basic Vue plugin configuration
- [ ] `npm run dev` starts Vite dev server on port 5173
- [ ] `http://localhost:5173` shows Vue welcome page
- [ ] `npm run build` produces output in `frontend/dist/`
- [ ] `.gitignore` excludes `node_modules/`, `dist/`, `.env*`

#### Implementation Notes

```bash
cd frontend
npm create vite@latest . -- --template vue
npm install
```

**vite.config.js:**
```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173
  }
})
```

#### How to Verify

```bash
cd frontend
npm run dev &
sleep 3
curl http://localhost:5173
# Expected: HTML with Vue app
npm run build
# Expected: dist/ directory created
kill %1
```

#### Commit Message

```
feat(frontend): initialize Vue 3 + Vite project
```

---

### SF-003 — Configure CORS for Cross-Origin Requests

| Field | Value |
|-------|-------|
| **Phase** | 0 |
| **Step** | 0.2a |
| **Type** | Backend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-001 |
| **Status** | Done |

#### Description

As a full-stack developer, I want CORS configured in the Rails backend so that the Vue frontend on port 5173 can make API requests to the Rails server on port 3000 without browser security errors.

#### Acceptance Criteria

- [ ] `rack-cors` gem added to `backend/Gemfile`
- [ ] `bundle install` succeeds
- [ ] `backend/config/initializers/cors.rb` exists with CORS configuration
- [ ] Allowed origin: `http://localhost:5173` (configurable via `FRONTEND_URL` env var)
- [ ] Allowed methods: GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD
- [ ] Allowed headers: `:any`
- [ ] Preflight OPTIONS requests return correct CORS headers
- [ ] `curl -H "Origin: http://localhost:5173" -X OPTIONS http://localhost:3000/api/v1/team_members` returns CORS headers

#### Implementation Notes

**Gemfile:**
```ruby
gem "rack-cors"
```

**config/initializers/cors.rb:**
```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_URL") { "http://localhost:5173" }

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

#### How to Verify

```bash
cd backend
bundle install
rails server &
sleep 2

curl -v -H "Origin: http://localhost:5173" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: X-Requested-With" \
  -X OPTIONS \
  http://localhost:3000/api/v1/team_members 2>&1 | grep -i "access-control"

# Expected: Access-Control-Allow-Origin header present
kill %1
```

#### Commit Message

```
feat(backend): configure rack-cors for Vue frontend
```

---

### SF-004 — Install and Configure RSpec + FactoryBot

| Field | Value |
|-------|-------|
| **Phase** | 0 |
| **Step** | 0.2b |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-001 |
| **Status** | Done |

#### Description

As a backend developer, I want RSpec installed with FactoryBot and Faker so that the team has a complete testing framework ready for model and request specs.

#### Acceptance Criteria

- [ ] `rspec-rails ~> 7.0` added to Gemfile in development/test group
- [ ] `factory_bot_rails ~> 6.0` added to Gemfile in development/test group
- [ ] `faker ~> 3.0` added to Gemfile in development/test group
- [ ] `debug` gem added for debugging support
- [ ] `rails generate rspec:install` executed successfully
- [ ] `backend/spec/rails_helper.rb` exists with proper configuration
- [ ] `backend/spec/spec_helper.rb` exists
- [ ] `.rspec` file exists with `--require spec_helper` and `--format documentation`
- [ ] `bundle exec rspec` runs without errors (0 examples, 0 failures)

#### Implementation Notes

**Gemfile additions:**
```ruby
group :development, :test do
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails", "~> 6.0"
  gem "faker", "~> 3.0"
  gem "debug", platforms: %i[mri mingw x64_mingw]
end
```

**Commands:**
```bash
cd backend
bundle install
rails generate rspec:install
```

**.rspec:**
```
--require spec_helper
--format documentation
```

#### How to Verify

```bash
cd backend
bundle exec rspec
# Expected: 0 examples, 0 failures

cat .rspec
# Expected: --require spec_helper\n--format documentation

ls spec/
# Expected: rails_helper.rb spec_helper.rb
```

#### Commit Message

```
test(backend): install RSpec, FactoryBot, and Faker
```

---

### SF-005 — Configure Vite Proxy for API Requests

| Field | Value |
|-------|-------|
| **Phase** | 0 |
| **Step** | 0.3a |
| **Type** | Frontend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 1 |
| **Dependencies** | SF-002 |
| **Status** | Done |

#### Description

As a frontend developer, I want Vite configured with a proxy for `/api` requests so that the Vue dev server forwards API calls to the Rails backend without CORS issues during development.

#### Acceptance Criteria

- [ ] `frontend/vite.config.js` includes proxy configuration
- [ ] Proxy rule: `/api` requests forwarded to `http://localhost:3000`
- [ ] `changeOrigin: true` set on proxy
- [ ] Frontend can call `/api/v1/team_members` through Vite proxy
- [ ] No CORS errors in browser console when making API calls

#### Implementation Notes

**vite.config.js:**
```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    }
  }
})
```

#### How to Verify

```bash
cd frontend
# Ensure backend is running on port 3000
npm run dev &

# Test proxy (no CORS headers needed when using proxy):
curl http://localhost:5173/api/v1/team_members
# Expected: JSON response from Rails (or 404 if endpoint not yet created)

kill %1
```

#### Commit Message

```
feat(frontend): configure Vite proxy for API requests
```

---

### SF-006 — Install Frontend Dependencies (Axios, Vue Router, Pinia)

| Field | Value |
|-------|-------|
| **Phase** | 0 |
| **Step** | 0.3b |
| **Type** | Frontend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 1 |
| **Dependencies** | SF-002 |
| **Status** | Done |

#### Description

As a frontend developer, I want Axios, Vue Router, and Pinia installed so that the team has HTTP client, routing, and state management ready for building the application.

#### Acceptance Criteria

- [ ] `axios` installed and listed in `package.json`
- [ ] `vue-router@4` installed and listed in `package.json`
- [ ] `pinia` installed and listed in `package.json`
- [ ] `npm run dev` starts without errors after installation
- [ ] All packages importable in Vue components:
  ```javascript
  import axios from 'axios'
  import { createRouter } from 'vue-router'
  import { createPinia } from 'pinia'
  ```

#### Implementation Notes

```bash
cd frontend
npm install axios vue-router@4 pinia
```

**package.json dependencies should include:**
```json
{
  "dependencies": {
    "axios": "^1.x",
    "pinia": "^2.x",
    "vue": "^3.x",
    "vue-router": "^4.x"
  }
}
```

#### How to Verify

```bash
cd frontend
npm list axios vue-router pinia
# Expected: all three listed with versions

node -e "require('axios'); console.log('axios OK')"
# Expected: axios OK

npm run dev
# Expected: no errors
kill %1
```

#### Commit Message

```
feat(frontend): install axios, vue-router, and pinia
```

---

### SF-007 — Phase 0 Validation & Initial Commit

| Field | Value |
|-------|-------|
| **Phase** | 0 |
| **Step** | 0.4 |
| **Type** | Full-Stack |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 1 |
| **Dependencies** | SF-003, SF-004, SF-005, SF-006 |
| **Status** | Done |

#### Description

As a team, we want to validate that both backend and frontend projects are properly initialized and communicating so that we have a solid foundation before building features.

#### Acceptance Criteria

- [ ] `cd backend && rails server` starts on port 3000
- [ ] `cd frontend && npm run dev` starts on port 5173
- [ ] `curl http://localhost:3000/up` returns 200
- [ ] `curl http://localhost:5173` returns HTML
- [ ] `bundle exec rspec` runs (0 examples, 0 failures)
- [ ] CORS headers present on cross-origin requests
- [ ] Both `.env.example` files exist (backend + frontend)
- [ ] `.gitignore` at root covers both directories
- [ ] Initial commit includes all project structure

#### Implementation Notes

**Root .gitignore:**
```gitignore
# Backend
/backend/.env
/backend/log/*
!/backend/log/.keep
/backend/tmp/*
!/backend/tmp/.keep
/backend/db/*.sqlite3
/backend/db/*.sqlite3-*
/backend/config/master.key
/backend/config/credentials.yml.enc

# Frontend
/frontend/node_modules
/frontend/dist
/frontend/.env
/frontend/.env.local

# General
.DS_Store
*.log
```

**frontend/.env.example:**
```
VITE_API_BASE_URL=http://localhost:3000/api/v1
```

**backend/.env.example:**
```
FRONTEND_URL=http://localhost:5173
RAILS_ENV=development
```

#### How to Verify

```bash
# Full verification from root:
cd backend && rails db:create && bundle exec rspec && cd ..
cd frontend && npm run dev &
cd ../backend && rails server &
sleep 3

curl http://localhost:3000/up
curl http://localhost:5173

kill %1 %2
```

#### Commit Message

```
chore: complete Phase 0 foundation setup

- Rails 8.1 API with SQLite
- Vue 3 + Vite frontend
- CORS configured
- RSpec + FactoryBot ready
- Vite proxy configured
- Axios, Vue Router, Pinia installed
```

---

## Phase 0 Summary

| ID | Title | Assignee | Points | Status |
|----|-------|----------|--------|--------|
| SF-001 | Initialize Rails API Project | Carlos | 2 | Done |
| SF-002 | Initialize Vue 3 + Vite Frontend | Josoe | 2 | Done |
| SF-003 | Configure CORS | Alejandro | 2 | Done |
| SF-004 | Install RSpec + FactoryBot | Carlos | 2 | Done |
| SF-005 | Configure Vite Proxy | Josoe | 1 | Done |
| SF-006 | Install Frontend Dependencies | Alejandro | 1 | Done |
| SF-007 | Phase 0 Validation & Commit | Carlos | 1 | Done |
| **Total** | | | **11** | |

---

## Phase 1: Rails Core — Models, Migrations & Seeds

---

### SF-010 — Configure RSpec for FactoryBot Integration

| Field | Value |
|-------|-------|
| **Phase** | 1 |
| **Step** | 1.1 |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 1 |
| **Dependencies** | SF-004 |

#### Description

As a backend developer, I want RSpec configured with FactoryBot syntax methods so that I can use `create(:factory)` and `build(:factory)` shorthand in all test files without explicit module inclusion.

#### Acceptance Criteria

- [ ] `config.include FactoryBot::Syntax::Methods` is present inside `RSpec.configure do |config|` block in `backend/spec/rails_helper.rb`
- [ ] `bundle exec rspec` runs without errors (0 examples, 0 failures)
- [ ] FactoryBot syntax works: `build(:team_member)` resolves without `FactoryBot::Syntax::Methods` prefix

#### How to Verify

```bash
cd backend
bundle exec rspec
# Expected: 0 examples, 0 failures

rails runner "puts FactoryBot::Syntax::Methods.instance_methods"
# Should include :build, :create, etc.
```

#### Commit Message

```
test(rspec): configure FactoryBot integration
```

---

### SF-011 — Create TeamMember Migration & Model

| Field | Value |
|-------|-------|
| **Phase** | 1 |
| **Step** | 1.2 |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 3 |
| **Dependencies** | SF-010 |

#### Description

As a backend developer, I want a `TeamMember` model with migration, validations, enum role, and associations so that the system can track support team members and their roles.

#### Acceptance Criteria

- [ ] Migration creates `team_members` table with columns: `name:string`, `email:string`, `role:integer`, `active:boolean (default: true)`, `created_at`, `updated_at`
- [ ] Unique index on `email` column (case-insensitive)
- [ ] Model has `enum role: { developer: 0, qa: 1, support: 2 }`
- [ ] Model validates `name` presence
- [ ] Model validates `email` presence, uniqueness (case-insensitive), and format (`URI::MailTo::EMAIL_REGEXP`)
- [ ] Model validates `role` presence
- [ ] Association: `has_many :created_requests, class_name: "SupportRequest", foreign_key: :creator_id, dependent: :restrict_with_error`
- [ ] Association: `has_many :assigned_requests, class_name: "SupportRequest", foreign_key: :assignee_id, dependent: :nullify`
- [ ] Association: `has_many :comments, dependent: :restrict_with_error`
- [ ] Factory exists at `spec/factories/team_members.rb`
- [ ] Model spec covers: validations, enum, associations
- [ ] `rails db:migrate` succeeds
- [ ] `rails c` → `TeamMember.create!(name: "Test", email: "test@test.com", role: :developer)` works

#### Implementation Notes

**Migration columns:**
```ruby
create_table :team_members do |t|
  t.string :name, null: false
  t.string :email, null: false
  t.integer :role, null: false, default: 0
  t.boolean :active, null: false, default: true
  t.timestamps
end
add_index :team_members, :email, unique: true
```

**Model (`backend/app/models/team_member.rb`):**
```ruby
class TeamMember < ApplicationRecord
  enum :role, { developer: 0, qa: 1, support: 2 }
  has_many :created_requests, class_name: "SupportRequest", foreign_key: :creator_id, dependent: :restrict_with_error
  has_many :assigned_requests, class_name: "SupportRequest", foreign_key: :assignee_id, dependent: :nullify
  has_many :comments, dependent: :restrict_with_error
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
end
```

**Factory (`backend/spec/factories/team_members.rb`):**
```ruby
FactoryBot.define do
  factory :team_member do
    name { Faker::Name.name }
    sequence(:email) { |n| "member#{n}@supportflow.dev" }
    role { :developer }
    active { true }
  end
end
```

#### How to Verify

```bash
cd backend
rails db:migrate
bundle exec rspec spec/models/team_member_spec.rb
# Expected: all examples pass

rails c
TeamMember.create!(name: "Test User", email: "test@test.com", role: :developer)
TeamMember.create!(name: "Duplicate", email: "test@test.com", role: :qa)  # Should raise error
```

#### Commit Message

```
feat(models): add TeamMember with validations and enum
```

---

### SF-012 — Create SupportRequest Migration & Model

| Field | Value |
|-------|-------|
| **Phase** | 1 |
| **Step** | 1.3 |
| **Type** | Backend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 5 |
| **Dependencies** | SF-011 |

#### Description

As a backend developer, I want a `SupportRequest` model with migration, status/priority enums, and business rule validations so that the system enforces data integrity for support tickets.

#### Acceptance Criteria

- [ ] Migration creates `support_requests` table with columns: `title:string`, `description:text`, `status:integer`, `priority:integer`, `due_date:date`, `resolved_at:datetime`, `creator_id:references`, `assignee_id:references`, `team_id:references`, `created_at`, `updated_at`
- [ ] Foreign keys to `team_members` for `creator_id`, `assignee_id`, `team_id`
- [ ] Indexes on `status`, `priority`, `assignee_id`, `due_date`
- [ ] Model has `enum status: { open: 0, in_progress: 1, resolved: 2, closed: 3 }`
- [ ] Model has `enum priority: { low: 0, medium: 1, high: 2, critical: 3 }`
- [ ] Model validates `title` and `description` presence
- [ ] Model validates `status`, `priority`, `creator`, `team` presence
- [ ] Association: `belongs_to :creator, class_name: "TeamMember"`
- [ ] Association: `belongs_to :assignee, class_name: "TeamMember", optional: true`
- [ ] Association: `belongs_to :team, class_name: "TeamMember"`
- [ ] Association: `has_many :comments, dependent: :destroy`
- [ ] Business Rule 2: Cannot assign to inactive team member (validate via `team_member_must_be_active`)
- [ ] Business Rule 3: Auto-set `resolved_at` when status changes to `resolved`
- [ ] Business Rule 5: Closed request cannot return to `open` state
- [ ] Business Rule 6: Closed request cannot be edited
- [ ] Business Rule 7: `overdue?` method and `.overdue` scope
- [ ] Validation: Must have at least one comment to resolve
- [ ] Factory exists at `spec/factories/support_requests.rb`
- [ ] Model spec covers: validations, enums, business rules, overdue logic, state transitions
- [ ] `rails db:migrate` succeeds

#### Implementation Notes

**Migration columns:**
```ruby
create_table :support_requests do |t|
  t.string :title, null: false
  t.text :description, null: false
  t.integer :status, null: false, default: 0
  t.integer :priority, null: false, default: 1
  t.date :due_date
  t.datetime :resolved_at
  t.references :creator, null: false, foreign_key: { to_table: :team_members }
  t.references :assignee, foreign_key: { to_table: :team_members }
  t.references :team, null: false, foreign_key: { to_table: :team_members }
  t.timestamps
end
add_index :support_requests, :status
add_index :support_requests, :priority
add_index :support_requests, :assignee_id
add_index :support_requests, :due_date
```

**Key business rules to implement:**
```ruby
validate :must_have_comments_to_resolve, if: -> { status_changed?(to: :resolved) }
before_save :set_resolved_at, if: -> { status_changed?(to: :resolved) }
scope :overdue, -> { where('due_date < ?', Date.current).where.not(status: [:resolved, :closed]) }

def overdue?
  due_date.present? && due_date < Date.current && !resolved? && !closed?
end
```

#### How to Verify

```bash
cd backend
rails db:migrate
bundle exec rspec spec/models/support_request_spec.rb
# Expected: all examples pass including business rules

rails c
sr = SupportRequest.create!(title: "Test", description: "Test description", priority: :high, creator: TeamMember.first, team: TeamMember.first)
sr.update!(status: :resolved)
sr.resolved_at  # Should be present
```

#### Commit Message

```
feat(models): add SupportRequest with enums and business rules
```

---

### SF-013 — Create Comment Migration & Model

| Field | Value |
|-------|-------|
| **Phase** | 1 |
| **Step** | 1.4 |
| **Type** | Backend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-012 |

#### Description

As a backend developer, I want a `Comment` model with migration so that team members can add comments to support requests.

#### Acceptance Criteria

- [ ] Migration creates `comments` table with columns: `body:text`, `team_member_id:references`, `support_request_id:references`, `created_at`, `updated_at`
- [ ] Foreign keys to `team_members` and `support_requests`
- [ ] Index on `support_request_id` for query performance
- [ ] Model validates `body` presence and minimum length of 10 characters
- [ ] Model validates `team_member` presence (via `belongs_to`)
- [ ] Model validates `support_request` presence (via `belongs_to`)
- [ ] Association: `belongs_to :support_request`
- [ ] Association: `belongs_to :team_member`
- [ ] Factory exists at `spec/factories/comments.rb`
- [ ] Model spec covers: validations, minimum length, associations
- [ ] `rails db:migrate` succeeds

#### Implementation Notes

**Migration:**
```ruby
create_table :comments do |t|
  t.text :body, null: false
  t.references :team_member, null: false, foreign_key: true
  t.references :support_request, null: false, foreign_key: true
  t.timestamps
end
add_index :comments, :support_request_id
```

**Model:**
```ruby
class Comment < ApplicationRecord
  belongs_to :support_request
  belongs_to :team_member
  validates :body, presence: true, length: { minimum: 10 }
end
```

#### How to Verify

```bash
cd backend
rails db:migrate
bundle exec rspec spec/models/comment_spec.rb
# Expected: all examples pass
```

#### Commit Message

```
feat(models): add Comment with validations
```

---

### SF-014 — Create Seed Data

| Field | Value |
|-------|-------|
| **Phase** | 1 |
| **Step** | 1.5 |
| **Type** | Backend |
| **Assignee** | Alejandro |
| **Priority** | Medium |
| **Story Points** | 2 |
| **Dependencies** | SF-011, SF-012, SF-013 |

#### Description

As a developer, I want realistic seed data so that the application has meaningful data for development and testing.

#### Acceptance Criteria

- [ ] At least 5 TeamMembers created (mix of developer/qa/support roles, some active/inactive)
- [ ] At least 15 SupportRequests created (varied status/priority, some overdue, some unassigned)
- [ ] At least 10 Comments distributed across requests
- [ ] Resolved requests have `resolved_at` set
- [ ] Closed requests exist
- [ ] `rails db:seed` runs without errors
- [ ] `rails db:seed` is idempotent (can run multiple times without duplicates)

#### How to Verify

```bash
cd backend
rails db:seed
# Check summary output

rails c
TeamMember.count           # >= 5
SupportRequest.count       # >= 15
Comment.count              # >= 10
SupportRequest.overdue.count  # >= 1
SupportRequest.where(assignee_id: nil).count  # >= 1
```

#### Commit Message

```
feat(seeds): add sample data for development
```

---

### SF-015 — Phase 1 Validation & Commit

| Field | Value |
|-------|-------|
| **Phase** | 1 |
| **Step** | 1.6 |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 1 |
| **Dependencies** | SF-010, SF-011, SF-012, SF-013, SF-014 |

#### Description

As a team, we want to validate that Phase 1 is complete and all models, migrations, and seeds work correctly before moving to API development.

#### Acceptance Criteria

- [ ] `rails db:migrate && rails db:seed` runs without errors
- [ ] `bundle exec rspec` — all model tests pass (0 failures)
- [ ] `rails c` — can create, read, update, and query all models
- [ ] All associations work: TeamMember → SupportRequests, SupportRequest → Comments
- [ ] All business rules enforced at model level
- [ ] Phase 1 commit merged to main

#### How to Verify

```bash
cd backend
rails db:migrate && rails db:seed
bundle exec rspec
# Expected: all green

rails c
# Test full lifecycle:
m = TeamMember.create!(name: "QA Test", email: "qa@test.com", role: :qa)
sr = SupportRequest.create!(title: "Test Request", description: "Test description for validation", priority: :high, creator: m, team: m)
c = Comment.create!(body: "This is a test comment for validation", team_member: m, support_request: sr)
sr.update!(status: :resolved)
sr.reload.resolved_at  # Should be present
```

#### Commit Message

```
feat(phase1): complete Rails core with models, migrations, and seeds
```

---

## Phase 2: API Endpoints

---

### SF-020 — Configure API Routes

| Field | Value |
|-------|-------|
| **Phase** | 2 |
| **Step** | 2.1 |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 1 |
| **Dependencies** | SF-015 |

#### Description

As a backend developer, I want API routes configured with proper namespace and nesting so that all endpoints are accessible via `/api/v1/`.

#### Acceptance Criteria

- [ ] Routes configured under `namespace :api { namespace :v1 { ... } }`
- [ ] `resources :team_members, only: [:index, :create, :update]` present
- [ ] `resources :support_requests` with nested `resources :comments, only: [:create]`
- [ ] `get 'dashboard', to: 'dashboard#index'` present
- [ ] `rails routes` shows all expected endpoints with correct HTTP verbs

#### How to Verify

```bash
cd backend
rails routes | grep api
# Expected output:
#   GET    /api/v1/team_members(.:format)          api/v1/team_members#index
#   POST   /api/v1/team_members(.:format)          api/v1/team_members#create
#   PATCH  /api/v1/team_members/:id(.:format)      api/v1/team_members#update
#   GET    /api/v1/support_requests(.:format)      api/v1/support_requests#index
#   GET    /api/v1/support_requests/:id(.:format)  api/v1/support_requests#show
#   POST   /api/v1/support_requests(.:format)      api/v1/support_requests#create
#   PATCH  /api/v1/support_requests/:id(.:format)  api/v1/support_requests#update
#   POST   /api/v1/support_requests/:support_request_id/comments(.:format)  api/v1/comments#create
#   GET    /api/v1/dashboard(.:format)              api/v1/dashboard#index
```

#### Commit Message

```
feat(routes): configure API v1 namespace
```

---

### SF-021 — Error Handling in ApplicationController

| Field | Value |
|-------|-------|
| **Phase** | 2 |
| **Step** | 2.2 |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-020 |

#### Description

As a backend developer, I want consistent error handling in `ApplicationController` so that all API responses follow the agreed error format (`{ error, details }`).

#### Acceptance Criteria

- [ ] `rescue_from ActiveRecord::RecordNotFound` renders 404 with `{ error: "Not found", details: [...] }`
- [ ] `rescue_from ActiveRecord::RecordInvalid` renders 422 with `{ error: "Validation failed", details: [...] }`
- [ ] Helper method `render_error(message, details, status)` available for custom errors
- [ ] All error responses include both `error` (string) and `details` (array) fields
- [ ] `bundle exec rspec` still passes after changes

#### Implementation Notes

**File: `backend/app/controllers/application_controller.rb`**
```ruby
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error

  private

  def render_not_found(exception)
    render json: { error: "Not found", details: [exception.message] }, status: :not_found
  end

  def render_validation_error(exception)
    render json: { error: "Validation failed", details: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_error(message, details = [], status: :unprocessable_entity)
    render json: { error: message, details: Array(details) }, status: status
  end
end
```

#### How to Verify

```bash
cd backend
bundle exec rspec
# Expected: all tests still pass

# Manual test:
curl http://localhost:3000/api/v1/support_requests/999999
# Expected: {"error":"Not found","details":["Couldn't find SupportRequest with 'id'=999999"]}
```

#### Commit Message

```
feat(api): add consistent error handling
```

---

### SF-022 — TeamMembers API Controller

| Field | Value |
|-------|-------|
| **Phase** | 2 |
| **Step** | 2.3 |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 3 |
| **Dependencies** | SF-020, SF-021 |

#### Description

As a frontend developer, I want a TeamMembers API endpoint (index, create, update) so that I can list team members, add new members, and toggle active/inactive status.

#### Acceptance Criteria

- [ ] `GET /api/v1/team_members` returns `{ team_members: [...] }` with all members sorted by name
- [ ] `POST /api/v1/team_members` with valid data returns 201 and member object
- [ ] `POST /api/v1/team_members` with invalid data returns 422 with `{ error, details }`
- [ ] `PATCH /api/v1/team_members/:id` returns updated member
- [ ] `PATCH /api/v1/team_members/:id` with non-existent ID returns 404
- [ ] Response shape matches API contract: `{ id, name, email, role, active, created_at, updated_at }`
- [ ] Request spec covers: index (200), create valid (201), create invalid (422), update (200), update not found (404)
- [ ] Strong params permit: `name`, `email`, `role`, `active`

#### Implementation Notes

**File: `backend/app/controllers/api/v1/team_members_controller.rb`**

#### How to Verify

```bash
cd backend
bundle exec rspec spec/requests/api/v1/team_members_spec.rb
# Expected: all examples pass

rails s  # In separate terminal
curl http://localhost:3000/api/v1/team_members
curl -X POST http://localhost:3000/api/v1/team_members -H "Content-Type: application/json" -d '{"team_member":{"name":"Test","email":"test@test.com","role":"developer"}}'
curl -X PATCH http://localhost:3000/api/v1/team_members/1 -H "Content-Type: application/json" -d '{"team_member":{"active":false}}'
```

#### Commit Message

```
feat(api): add TeamMembers endpoint
```

---

### SF-023 — SupportRequests API Controller

| Field | Value |
|-------|-------|
| **Phase** | 2 |
| **Step** | 2.4 |
| **Type** | Backend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 5 |
| **Dependencies** | SF-020, SF-021, SF-022 |

#### Description

As a frontend developer, I want a SupportRequests API endpoint with filtering so that I can list, view, create, and update support requests with various filter combinations.

#### Acceptance Criteria

- [ ] `GET /api/v1/support_requests` returns all requests with `overdue` computed boolean
- [ ] `GET /api/v1/support_requests?status=open` filters by status
- [ ] `GET /api/v1/support_requests?priority=high` filters by priority
- [ ] `GET /api/v1/support_requests?team_member_id=1` filters by assignee
- [ ] `GET /api/v1/support_requests?overdue=true` returns only overdue requests
- [ ] `GET /api/v1/support_requests?unassigned=true` returns only unassigned requests
- [ ] `GET /api/v1/support_requests?q=search` filters by title (case-insensitive LIKE)
- [ ] Filters can be combined (AND logic)
- [ ] `GET /api/v1/support_requests/:id` returns request with nested comments and full assignee details
- [ ] `POST /api/v1/support_requests` creates request (201), enforces business rules
- [ ] `PATCH /api/v1/support_requests/:id` updates request, enforces closed restrictions
- [ ] Response shape matches API contract
- [ ] Request spec covers: index with filters, show (200, 404), create (201, 422), update (200, 422)

#### How to Verify

```bash
cd backend
bundle exec rspec spec/requests/api/v1/support_requests_spec.rb
# Expected: all examples pass

rails s
curl "http://localhost:3000/api/v1/support_requests?status=open&overdue=true"
curl http://localhost:3000/api/v1/support_requests/1
```

#### Commit Message

```
feat(api): add SupportRequests endpoint with filters
```

---

### SF-024 — Comments API Controller

| Field | Value |
|-------|-------|
| **Phase** | 2 |
| **Step** | 2.5a |
| **Type** | Backend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-013, SF-023 |

#### Description

As a frontend developer, I want a Comments API endpoint (nested under support_requests) so that users can add comments to support requests.

#### Acceptance Criteria

- [ ] `POST /api/v1/support_requests/:support_request_id/comments` creates comment (201)
- [ ] Response shape: `{ id, body, author_name, support_request_id, created_at }`
- [ ] 422 for body < 10 characters: `{ error: "Validation failed", details: ["Body is too short (minimum is 10 characters)"] }`
- [ ] 422 for missing team_member_id
- [ ] 404 for non-existent support request
- [ ] Comments CAN be added to closed support requests
- [ ] Request spec covers: create valid (201), body too short (422), request not found (404)

#### How to Verify

```bash
cd backend
bundle exec rspec spec/requests/api/v1/comments_spec.rb
# Expected: all examples pass

rails s
curl -X POST http://localhost:3000/api/v1/support_requests/1/comments -H "Content-Type: application/json" -d '{"comment":{"body":"This is a test comment","team_member_id":1}}'
```

#### Commit Message

```
feat(api): add Comments endpoint nested under support_requests
```

---

### SF-025 — Dashboard API Controller

| Field | Value |
|-------|-------|
| **Phase** | 2 |
| **Step** | 2.5b |
| **Type** | Backend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-023 |

#### Description

As a frontend developer, I want a Dashboard API endpoint that returns aggregated metrics so that the dashboard view can display summary statistics.

#### Acceptance Criteria

- [ ] `GET /api/v1/dashboard` returns 200 with aggregated metrics
- [ ] Response includes: `total_requests`, `requests_by_status`, `requests_by_priority`, `requests_by_team`
- [ ] `requests_by_status` counts: open, in_progress, resolved, closed
- [ ] `requests_by_priority` counts: low, medium, high, critical
- [ ] `requests_by_team` includes team member names and request counts
- [ ] Request spec covers: correct structure and values

#### How to Verify

```bash
cd backend
bundle exec rspec spec/requests/api/v1/dashboard_spec.rb
# Expected: all examples pass

rails s
curl http://localhost:3000/api/v1/dashboard
# Expected: {"total_requests":15,"requests_by_status":{"open":8,...},"requests_by_priority":{...},"requests_by_team":[...]}
```

#### Commit Message

```
feat(api): add Dashboard endpoint with aggregations
```

---

### SF-026 — Phase 2 Validation & Commit

| Field | Value |
|-------|-------|
| **Phase** | 2 |
| **Step** | 2.6 |
| **Type** | Backend |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 1 |
| **Dependencies** | SF-022, SF-023, SF-024, SF-025 |

#### Description

As a team, we want to validate that all API endpoints work correctly and all tests pass before starting frontend integration.

#### Acceptance Criteria

- [ ] `bundle exec rspec` — all tests pass (model + request specs)
- [ ] All endpoints return correct JSON (manual curl verification)
- [ ] Filters work: `?status=open`, `?overdue=true`, `?q=search`, etc.
- [ ] Error responses follow consistent format
- [ ] Phase 2 commit merged to main

#### How to Verify

```bash
cd backend
bundle exec rspec
# Expected: all green

# Manual verification of all endpoints:
curl http://localhost:3000/api/v1/team_members
curl http://localhost:3000/api/v1/support_requests
curl http://localhost:3000/api/v1/support_requests/1
curl http://localhost:3000/api/v1/dashboard
curl http://localhost:3000/api/v1/support_requests/1/comments -X POST -H "Content-Type: application/json" -d '{"comment":{"body":"Test comment","team_member_id":1}}'
```

#### Commit Message

```
feat(phase2): complete all API endpoints with tests
```

---

## Phase 3: Vue Integration

---

### SF-030 — Vue API Client (Axios)

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.1 |
| **Type** | Frontend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-026 |

#### Description

As a frontend developer, I want a configured Axios API client with base URL and error interceptors so that all API calls are centralized and errors are handled consistently.

#### Acceptance Criteria

- [ ] `frontend/src/api/client.js` exports an Axios instance
- [ ] Base URL configured from `VITE_API_BASE_URL` env var (default: `http://localhost:3000/api/v1`)
- [ ] Request headers: `Content-Type: application/json`, `Accept: application/json`
- [ ] Response interceptor normalizes errors: `{ status, message, details, isValidationError, isNotFound }`
- [ ] `import apiClient from '@/api/client.js'` works in any Vue component

#### Implementation Notes

**File: `frontend/src/api/client.js`**
```javascript
import axios from 'axios'

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api/v1',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

apiClient.interceptors.response.use(
  response => response,
  error => {
    const status = error.response?.status || 500
    const data = error.response?.data || {}
    const normalizedError = {
      status,
      message: data.error || 'An unexpected error occurred',
      details: data.details || [],
      isValidationError: status === 422,
      isNotFound: status === 404
    }
    return Promise.reject(normalizedError)
  }
)

export default apiClient
```

#### How to Verify

```bash
cd frontend
npm run dev
# Open browser console, test:
# import apiClient from '@/api/client.js'
# apiClient.get('/team_members').then(r => console.log(r.data))
```

#### Commit Message

```
feat(frontend): add Axios API client with error interceptor
```

---

### SF-031 — Vue Router Configuration

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.2 |
| **Type** | Frontend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-030 |

#### Description

As a frontend developer, I want Vue Router configured with all application routes so that users can navigate between views.

#### Acceptance Criteria

- [ ] Routes configured: `/` (Dashboard), `/requests` (List), `/requests/new` (Form), `/requests/:id` (Detail), `/requests/:id/edit` (Form), `/members` (TeamMembers)
- [ ] Router uses `createWebHistory` mode
- [ ] Navigation between routes works without full page reload
- [ ] Route names: Dashboard, RequestList, RequestNew, RequestDetail, RequestEdit, TeamMembers

#### How to Verify

```bash
cd frontend
npm run dev
# Navigate to http://localhost:5173/
# Click sidebar links, verify no full page reload
```

#### Commit Message

```
feat(frontend): configure Vue Router
```

---

### SF-032 — Pinia Stores

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.3 |
| **Type** | Frontend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 3 |
| **Dependencies** | SF-030 |

#### Description

As a frontend developer, I want Pinia stores for Dashboard, SupportRequests, and TeamMembers so that state management is centralized and components share data.

#### Acceptance Criteria

- [ ] `dashboardStore` with `fetchMetrics()` action, `metrics`, `loading`, `error` state
- [ ] `supportRequestStore` with `fetchRequests()`, `fetchRequest(id)`, `createRequest(data)`, `updateRequest(id, data)`, `addComment(requestId, data)` actions
- [ ] `supportRequestStore` has `filters` state and `setFilter(key, value)`, `clearFilters()` actions
- [ ] `supportRequestStore` has `activeFilters` getter that filters out empty values
- [ ] `teamMemberStore` with `fetchMembers()`, `createMember(data)`, `toggleActive(id, active)` actions
- [ ] `toastStore` with `success()`, `error()`, `warning()`, `info()` actions
- [ ] All stores handle loading and error states
- [ ] All stores are accessible in components

#### How to Verify

```bash
cd frontend
npm run dev
# In Vue DevTools, verify stores are registered and actions work
```

#### Commit Message

```
feat(frontend): add Pinia stores
```

---

### SF-033 — App Layout & Sidebar

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.4a |
| **Type** | Frontend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 3 |
| **Dependencies** | SF-031, SF-032 |

#### Description

As a user, I want a consistent app layout with sidebar navigation so that I can move between sections of the application.

#### Acceptance Criteria

- [ ] `AppLayout.vue` renders sidebar + top bar + main content area
- [ ] Sidebar shows: logo, Dashboard link, Requests link, Team Members link
- [ ] Active nav item is visually highlighted
- [ ] Top bar shows page title and slot for actions (e.g., "New Request" button)
- [ ] Sidebar width: 200px, fixed position
- [ ] Responsive: sidebar collapses on mobile (optional, time permitting)

#### How to Verify

```bash
cd frontend
npm run dev
# Verify sidebar navigation works
# Verify top bar shows page title
# Verify "New Request" button appears on Dashboard
```

#### Commit Message

```
feat(frontend): implement app layout with sidebar navigation
```

---

### SF-034 — Dashboard View

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.4b |
| **Type** | Frontend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 3 |
| **Dependencies** | SF-032, SF-033 |

#### Description

As a user, I want a dashboard view showing key metrics so that I can get an at-a-glance overview of support request status.

#### Acceptance Criteria

- [ ] Shows 4 metric cards: Total Requests, Open, In Progress, Resolved
- [ ] Shows "Requests by Priority" breakdown with PriorityBadge components
- [ ] Shows "Requests by Team" breakdown with member names and counts
- [ ] Loading state: skeleton cards or spinner while data loads
- [ ] Error state: error message if API call fails
- [ ] "View all requests" link navigates to request list
- [ ] Data is fetched from `GET /api/v1/dashboard` on mount
- [ ] Metrics update in real-time (refetch on mount)

#### How to Verify

```bash
cd frontend
npm run dev
# Navigate to http://localhost:5173/
# Verify metrics cards display correct counts
# Verify priority breakdown shows badges
# Verify team breakdown shows member names
```

#### Commit Message

```
feat(frontend): implement Dashboard view
```

---

### SF-035 — Support Request List View

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.4c |
| **Type** | Frontend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 5 |
| **Dependencies** | SF-032, SF-033 |

#### Description

As a user, I want a list view of all support requests with filtering so that I can find and manage tickets efficiently.

#### Acceptance Criteria

- [ ] Table displays: ID, Title, Status, Priority, Assignee, Due Date
- [ ] Filter bar with: Status dropdown, Priority dropdown, Overdue checkbox, Unassigned checkbox, Search input
- [ ] Filters are debounced (300ms for search) and applied via API query params
- [ ] "Clear Filters" button appears when any filter is active
- [ ] Status shown as StatusBadge, Priority as PriorityBadge
- [ ] Overdue due dates highlighted in red
- [ ] Clicking title navigates to detail view
- [ ] "Edit" button on each row navigates to edit form
- [ ] "New Request" button in top bar
- [ ] Loading state: table skeleton or spinner
- [ ] Empty state: "No requests found" message
- [ ] Data fetched from `GET /api/v1/support_requests` with filters on mount

#### How to Verify

```bash
cd frontend
npm run dev
# Navigate to http://localhost:5173/requests
# Verify table shows all requests
# Test status filter: select "Open" → only open requests shown
# Test search: type "login" → only matching requests shown
# Test overdue checkbox → only overdue requests shown
# Click title → navigates to detail view
```

#### Commit Message

```
feat(frontend): implement SupportRequestList view with filters
```

---

### SF-036 — Support Request Detail View

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.4d |
| **Type** | Frontend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 4 |
| **Dependencies** | SF-032, SF-033, SF-035 |

#### Description

As a user, I want a detail view for a support request showing full information and comments so that I can understand and work on the issue.

#### Acceptance Criteria

- [ ] Shows request ID, title, description, status badge, priority badge
- [ ] Shows metadata: assignee, due date, created date
- [ ] Shows comments list with author name, timestamp, and body
- [ ] Comment form with: author name select (from team members), body textarea (min 10 chars), submit button
- [ ] Comment form validates client-side before submission
- [ ] "Edit Request" button opens edit form
- [ ] "Back to List" button navigates to list
- [ ] Loading state while data loads
- [ ] Error state if request not found (404)
- [ ] Data fetched from `GET /api/v1/support_requests/:id` on mount
- [ ] After adding comment, list refreshes automatically
- [ ] Toast notification on successful comment post

#### How to Verify

```bash
cd frontend
npm run dev
# Navigate to http://localhost:5173/requests/1
# Verify request details displayed
# Verify comments listed
# Add a comment → verify it appears in the list
# Verify toast notification appears
```

#### Commit Message

```
feat(frontend): implement SupportRequestDetail view with comments
```

---

### SF-037 — Support Request Form (Create/Edit)

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.4e |
| **Type** | Frontend |
| **Assignee** | Alejandro |
| **Priority** | High |
| **Story Points** | 4 |
| **Dependencies** | SF-032, SF-033, SF-035 |

#### Description

As a user, I want a form to create and edit support requests so that I can manage tickets through their lifecycle.

#### Acceptance Criteria

- [ ] Form fields: Title (required), Description (required), Priority (select), Due Date (date input), Assignee (select from team members)
- [ ] Create mode: form empty, submits to `POST /api/v1/support_requests`
- [ ] Edit mode: form pre-populated with existing data, submits to `PATCH /api/v1/support_requests/:id`
- [ ] Form validates required fields client-side
- [ ] Backend validation errors displayed next to relevant fields
- [ ] Success: navigates to detail view, shows toast notification
- [ ] Cancel button returns to previous view
- [ ] Assignee select shows "Unassigned" option (empty value)
- [ ] Loading state while submitting

#### How to Verify

```bash
cd frontend
npm run dev
# Navigate to http://localhost:5173/requests/new
# Fill form, submit → verify request created
# Navigate to detail → click Edit → verify form pre-populated
# Change fields, submit → verify changes saved
```

#### Commit Message

```
feat(frontend): implement SupportRequestForm view
```

---

### SF-038 — Team Members View

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.4f |
| **Type** | Frontend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 3 |
| **Dependencies** | SF-032, SF-033 |

#### Description

As a user, I want a team members view showing all members with ability to add new members and toggle active status so that I can manage the support team.

#### Acceptance Criteria

- [ ] Table displays: Name, Email, Role badge, Active status toggle
- [ ] "Add Member" button opens side panel or modal with form
- [ ] Add form: Name (required), Email (required, validated), Role (select: developer/qa/support)
- [ ] Active toggle: switch to activate/deactivate member
- [ ] Deactivation shows confirmation warning: "This member will no longer be assignable"
- [ ] Toast notification on successful create/toggle
- [ ] Loading state while data loads
- [ ] Data fetched from `GET /api/v1/team_members` on mount

#### How to Verify

```bash
cd frontend
npm run dev
# Navigate to http://localhost:5173/members
# Verify member list displays
# Click "Add Member" → fill form → submit → verify new member appears
# Toggle active status → verify confirmation → verify status changes
```

#### Commit Message

```
feat(frontend): implement TeamMemberList view
```

---

### SF-039 — Shared UI Components

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.4g |
| **Type** | Frontend |
| **Assignee** | Josoe |
| **Priority** | Medium |
| **Story Points** | 3 |
| **Dependencies** | SF-030 |

#### Description

As a frontend developer, I want reusable shared components (badges, forms, loading, errors) so that UI is consistent across all views.

#### Acceptance Criteria

- [ ] `StatusBadge.vue` — renders colored badge for open/in_progress/resolved/closed
- [ ] `PriorityBadge.vue` — renders colored badge for low/medium/high/critical
- [ ] `LoadingSpinner.vue` — shows spinner with optional message
- [ ] `ErrorMessage.vue` — shows error message with optional details
- [ ] `FormInput.vue` — reusable input with label and error display
- [ ] `FormTextarea.vue` — reusable textarea with label and error display
- [ ] `FormSelect.vue` — reusable select with label, options, and error display
- [ ] `ToastContainer.vue` — fixed position container for toast notifications
- [ ] All components follow design system tokens (colors, spacing, radius)

#### How to Verify

```bash
cd frontend
npm run dev
# Verify badges render correctly in list and detail views
# Verify form components work in create/edit forms
# Verify loading spinners appear during API calls
# Verify error messages display when API fails
```

#### Commit Message

```
feat(frontend): implement shared UI components
```

---

### SF-040 — Phase 3 Validation & Commit

| Field | Value |
|-------|-------|
| **Phase** | 3 |
| **Step** | 3.5 |
| **Type** | Frontend |
| **Assignee** | Josoe |
| **Priority** | High |
| **Story Points** | 1 |
| **Dependencies** | SF-034, SF-035, SF-036, SF-037, SF-038, SF-039 |

#### Description

As a team, we want to validate that the entire Vue integration works end-to-end before final polish.

#### Acceptance Criteria

- [ ] Frontend loads without console errors
- [ ] All views display data from API
- [ ] Create/edit forms work (submit and validation)
- [ ] Loading and error states show correctly
- [ ] Toast notifications work
- [ ] Navigation between all routes works
- [ ] Full flow: create request → assign → comment → resolve → dashboard updates
- [ ] Phase 3 commit merged to main

#### How to Verify

```bash
cd frontend
npm run dev

# Full flow test:
1. Go to Dashboard → verify metrics
2. Go to Members → add a new member
3. Go to Requests → click "New Request"
4. Fill form, assign to new member → submit
5. Click on request → verify detail view
6. Add a comment → verify it appears
7. Edit request → change status → verify update
8. Go back to Dashboard → verify metrics updated
```

#### Commit Message

```
feat(phase3): complete Vue integration
```

---

## Phase 4: Polish & Documentation

---

### SF-050 — Project Documentation

| Field | Value |
|-------|-------|
| **Phase** | 4 |
| **Step** | 4.1a |
| **Type** | Docs |
| **Assignee** | Carlos |
| **Priority** | Medium |
| **Story Points** | 2 |
| **Dependencies** | SF-040 |

#### Description

As a developer, I want comprehensive project documentation so that new team members can understand and set up the project.

#### Acceptance Criteria

- [ ] `README.md` includes: project overview, tech stack, setup instructions, architecture diagram, team members
- [ ] Setup instructions: clone, install, seed, run (backend + frontend)
- [ ] API documentation: all endpoints with request/response examples
- [ ] `.env.example` files for both backend and frontend
- [ ] New developer can set up project in < 5 minutes following README

#### How to Verify

```bash
# Clean clone test:
cd /tmp
git clone <repo-url> support-flow-test
cd support-flow-test
# Follow README instructions
# Verify both servers start and app works
```

#### Commit Message

```
docs: complete project documentation
```

---

### SF-051 — Technical Decisions Document

| Field | Value |
|-------|-------|
| **Phase** | 4 |
| **Step** | 4.1b |
| **Type** | Docs |
| **Assignee** | Alejandro |
| **Priority** | Medium |
| **Story Points** | 1 |
| **Dependencies** | SF-040 |

#### Description

As a team, I want documented technical decisions (ADRs) so that we can explain our choices during the defense.

#### Acceptance Criteria

- [ ] `DECISIONS.md` includes at least 3 technical decisions in ADR format
- [ ] Each decision includes: Decision, Alternatives, Rationale, Trade-offs
- [ ] Decisions cover: database choice, testing framework, state management, monorepo structure
- [ ] Decisions are consistent with actual implementation

#### Commit Message

```
docs: complete technical decisions document
```

---

### SF-052 — Final Validation & Cleanup

| Field | Value |
|-------|-------|
| **Phase** | 4 |
| **Step** | 4.2 |
| **Type** | Full-Stack |
| **Assignee** | Carlos |
| **Priority** | High |
| **Story Points** | 2 |
| **Dependencies** | SF-050, SF-051 |

#### Description

As a team, we want to perform final validation and cleanup so that the project is production-ready for defense.

#### Acceptance Criteria

- [ ] `rails db:setup` works from clean state
- [ ] `bundle exec rspec` — all tests green (0 failures)
- [ ] `npm run build` — frontend builds without errors
- [ ] No secrets or API keys in repository
- [ ] `.gitignore` covers all sensitive files
- [ ] No TODO comments left in code (or documented as known limitations)
- [ ] All PRs merged to main
- [ ] `docs/daily-checkpoints.md` completed
- [ ] `docs/pr-reviews.md` completed with evidence

#### How to Verify

```bash
cd backend
rails db:drop db:create db:migrate db:seed
bundle exec rspec
# Expected: all green

cd ../frontend
npm run build
# Expected: build succeeds

# Security check:
grep -r "password\|secret\|token\|key" --include="*.rb" --include="*.js" .
# Expected: no sensitive data found
```

#### Commit Message

```
chore: final cleanup and validation
```

---

## Summary: Ticket Distribution by Assignee

### Carlos (Backend Foundation, Models & TeamMember API)

| ID | Title | Phase | Points | Status |
|----|-------|-------|--------|--------|
| SF-001 | Initialize Rails API Project | 0 | 2 | Done |
| SF-004 | Install RSpec + FactoryBot | 0 | 2 | Done |
| SF-007 | Phase 0 Validation & Commit | 0 | 1 | Done |
| SF-010 | Configure RSpec for FactoryBot | 1 | 1 | |
| SF-011 | Create TeamMember Migration & Model | 1 | 3 | |
| SF-015 | Phase 1 Validation & Commit | 1 | 1 | |
| SF-020 | Configure API Routes | 2 | 1 | |
| SF-021 | Error Handling in ApplicationController | 2 | 2 | |
| SF-022 | TeamMembers API Controller | 2 | 3 | |
| SF-026 | Phase 2 Validation & Commit | 2 | 1 | |
| SF-050 | Project Documentation | 4 | 2 | |
| SF-052 | Final Validation & Cleanup | 4 | 2 | |
| **Total** | | | **21** | |

### Alejandro (Frontend Foundation, SupportRequests API & Business Rules)

| ID | Title | Phase | Points | Status |
|----|-------|-------|--------|--------|
| SF-003 | Configure CORS | 0 | 2 | Done |
| SF-006 | Install Frontend Dependencies | 0 | 1 | Done |
| SF-012 | Create SupportRequest Migration & Model | 1 | 5 | |
| SF-014 | Create Seed Data | 1 | 2 | |
| SF-023 | SupportRequests API Controller | 2 | 5 | |
| SF-032 | Pinia Stores | 3 | 3 | |
| SF-034 | Dashboard View | 3 | 3 | |
| SF-035 | Support Request List View | 3 | 5 | |
| SF-036 | Support Request Detail View | 3 | 4 | |
| SF-037 | Support Request Form (Create/Edit) | 3 | 4 | |
| SF-051 | Technical Decisions Document | 4 | 1 | |
| **Total** | | | **35** | |

### Josoe (Frontend Foundation, Vue Frontend & Dashboard/Comments API)

| ID | Title | Phase | Points | Status |
|----|-------|-------|--------|--------|
| SF-002 | Initialize Vue 3 + Vite Frontend | 0 | 2 | Done |
| SF-005 | Configure Vite Proxy | 0 | 1 | Done |
| SF-013 | Create Comment Migration & Model | 1 | 2 | |
| SF-024 | Comments API Controller | 2 | 2 | |
| SF-025 | Dashboard API Controller | 2 | 2 | |
| SF-030 | Vue API Client (Axios) | 3 | 2 | |
| SF-031 | Vue Router Configuration | 3 | 2 | |
| SF-033 | App Layout & Sidebar | 3 | 3 | |
| SF-038 | Team Members View | 3 | 3 | |
| SF-039 | Shared UI Components | 3 | 3 | |
| SF-040 | Phase 3 Validation & Commit | 3 | 1 | |
| **Total** | | | **23** | |

---

## Complete Ticket Inventory

| Phase | Tickets | Points | Status |
|-------|---------|--------|--------|
| Phase 0: Foundation | SF-001 → SF-007 (7 tickets) | 11 | Done |
| Phase 1: Rails Core | SF-010 → SF-015 (6 tickets) | 14 | |
| Phase 2: API Endpoints | SF-020 → SF-026 (7 tickets) | 16 | |
| Phase 3: Vue Integration | SF-030 → SF-040 (11 tickets) | 29 | |
| Phase 4: Polish & Docs | SF-050 → SF-052 (3 tickets) | 5 | |
| **Total** | **34 tickets** | **79** | |

---

## Dependency Graph (Critical Path)

```
Phase 0 (Foundation)
    │
    ├──► SF-001 (Rails API) ──► SF-003 (CORS) ──────────┐
    │                          SF-004 (RSpec) ──┐        │
    ├──► SF-002 (Vue 3) ──► SF-005 (Proxy)     │        │
    │                   ──► SF-006 (Deps)       │        │
    │                                           │        │
    └──► SF-007 (Phase 0 Validation) ◄──────────┘────────┘
              │
              ▼
Phase 1 (Rails Core)
    │
    SF-010 (RSpec Config) ──► SF-011 (TeamMember) ──► SF-012 (SupportRequest) ──► SF-013 (Comment)
        │                           │                          │                          │
        │                           ▼                          ▼                          ▼
        │                       SF-014 (Seeds) ◄───────────────┘──────────────────────────┘
        │                           │
        ▼                           ▼
    SF-015 (Phase 1 Validation)
              │
              ▼
Phase 2 (API Endpoints)
    │
    SF-020 (Routes) ──► SF-021 (Error Handling)
        │                    │
        ├──► SF-022 (TeamMembers API)
        ├──► SF-023 (SupportRequests API) ──► SF-024 (Comments API)
        │                                        SF-025 (Dashboard API)
        ▼
    SF-026 (Phase 2 Validation)
              │
              ▼
Phase 3 (Vue Integration)
    │
    SF-030 (API Client) ──► SF-031 (Router) ──► SF-032 (Stores)
        │                                           │
        ├──► SF-033 (Layout) ◄─────────────────────┘
        │        │
        ├──► SF-034 (Dashboard View)
        ├──► SF-035 (Request List) ──► SF-036 (Request Detail)
        │                              SF-037 (Request Form)
        ├──► SF-038 (Team Members View)
        └──► SF-039 (Shared Components)
                  │
                  ▼
             SF-040 (Phase 3 Validation)
                  │
                  ▼
Phase 4 (Polish & Docs)
    │
    ├──► SF-050 (Documentation)
    ├──► SF-051 (Technical Decisions)
    │
    └──► SF-052 (Final Validation)
```

**Critical Path:** SF-001 → SF-004 → SF-007 → SF-010 → SF-011 → SF-012 → SF-013 → SF-015 → SF-020 → SF-021 → SF-023 → SF-026 → SF-030 → SF-032 → SF-035 → SF-040 → SF-052

---

## Sprint Planning Recommendation

### Sprint 0 (Setup Day — Before Day 1)
- **Carlos:** SF-001 (Rails API), SF-004 (RSpec), SF-007 (Validation)
- **Alejandro:** SF-003 (CORS), SF-006 (Frontend Deps)
- **Josoe:** SF-002 (Vue 3), SF-005 (Vite Proxy)

### Sprint 1 (Day 1 Morning)
- **Carlos:** SF-010, SF-011
- **Alejandro:** SF-012 (start)
- **Josoe:** SF-013

### Sprint 2 (Day 1 Afternoon)
- **Carlos:** SF-015
- **Alejandro:** SF-012 (finish), SF-014
- **Josoe:** SF-030, SF-031

### Sprint 3 (Day 2 Morning)
- **Carlos:** SF-020, SF-021, SF-022
- **Alejandro:** SF-023
- **Josoe:** SF-024, SF-025

### Sprint 4 (Day 2 Afternoon)
- **Carlos:** SF-026
- **Alejandro:** SF-032, SF-034
- **Josoe:** SF-033, SF-039

### Sprint 5 (Day 3 Morning)
- **Carlos:** SF-050
- **Alejandro:** SF-035, SF-036, SF-037
- **Josoe:** SF-038, SF-040

### Sprint 6 (Day 3 Afternoon)
- **Carlos:** SF-052
- **Alejandro:** SF-051
- **Josoe:** Final testing & bug fixes

---

*Total Story Points: 79 | Total Tickets: 34 | Team Size: 3 | Duration: 3 days + setup*
