# SupportFlow — Technical Decisions

> This document records significant technical decisions made during the project. Each entry follows the ADR (Architecture Decision Record) format: Decision, Alternatives, Rationale, and Trade-offs.

---

## Decision 1: SQLite for Development, PostgreSQL-Ready for Production

**Decision:** Use SQLite as the development and test database, while keeping the application ready for PostgreSQL deployment.

**Alternatives Considered:**
1. PostgreSQL from the start (requires local PostgreSQL installation)
2. MySQL (similar setup complexity to PostgreSQL)
3. SQLite for everything including production (not viable for concurrent access)

**Rationale:**
- SQLite requires zero setup — no daemon, no configuration, no credentials
- Rails abstracts database differences through ActiveRecord; migrations work across both
- The team can focus on business logic instead of database administration during the 3-day challenge
- `database.yml` is pre-configured with PostgreSQL settings (commented) for future deployment

**Trade-offs:**
- SQLite lacks advanced PostgreSQL features (arrays, JSONB, full-text search, concurrent writes)
- Some SQL syntax differences may surface during migration to PostgreSQL
- Foreign key constraints behave slightly differently
- No native `ILIKE` in SQLite (Rails handles this via Arel adapters)

**Migration Path:**
```yaml
# config/database.yml (production section, ready to uncomment)
production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch(\"RAILS_MAX_THREADS\") { 5 } %>
  url: <%= ENV['DATABASE_URL'] %>
```

---

## Decision 2: RSpec + FactoryBot over Minitest + Fixtures

**Decision:** Use RSpec with FactoryBot for the test suite instead of Rails' default Minitest with fixtures.

**Alternatives Considered:**
1. Minitest with fixtures (Rails default, no additional gems)
2. Minitest with FactoryBot (middle ground)
3. RSpec with fixtures (less common combination)

**Rationale:**
- RSpec's `describe`/`it` syntax is more readable for request specs and complex business rule testing
- FactoryBot allows dynamic, programmatic test data creation vs. static YAML fixtures
- Request specs in RSpec provide built-in helpers for JSON parsing and HTTP status assertions
- The team has familiarity with RSpec from previous projects

**Trade-offs:**
- Additional gem dependencies (`rspec-rails`, `factory_bot_rails`)
- Slightly slower test boot time compared to Minitest
- New team members may need to learn RSpec syntax if unfamiliar
- Fixtures are faster for simple cases; FactoryBot adds overhead for basic tests

**Configuration:**
```ruby
# Gemfile
group :development, :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.0'
  gem 'faker', '~> 3.0'  # For generating realistic seed/test data
end
```

---

## Decision 3: Monorepo with Separate Backend/Frontend Directories

**Decision:** Organize the project as a single Git repository with `backend/` and `frontend/` as sibling directories.

**Alternatives Considered:**
1. Two separate repositories (backend repo + frontend repo)
2. Rails serving Vue via Webpacker/Shakapacker (tight integration)
3. Monorepo with shared packages (Lerna, Nx, Turborepo)

**Rationale:**
- Single repository simplifies code reviews that span both layers (e.g., API contract changes)
- One place for documentation (README, DECISIONS, planning docs)
- Reviewers can clone once and run both applications
- No need for complex monorepo tooling; simple directory structure is sufficient for this scope

**Trade-offs:**
- Commit history is shared; harder to track frontend-only or backend-only changes
- CI/CD would need to handle both applications (not implemented in this challenge)
- Larger repository size over time
- Potential confusion in PRs if not clearly labeled (e.g., `[backend]` or `[frontend]` prefixes)

**Repository Structure:**
```
support-flow/
├── backend/     # Rails 7 API (independent)
├── frontend/    # Vue 3 + Vite (independent)
├── docs/        # Shared documentation
├── README.md
└── DECISIONS.md
```

---

## Decision 4: Vue 3 Composition API with Pinia for State Management

**Decision:** Use Vue 3 with the Composition API and Pinia for state management.

**Alternatives Considered:**
1. Vue 3 Options API (more familiar to Vue 2 developers, but less flexible)
2. Vue 3 Composition API with Vuex (Vuex is deprecated in favor of Pinia)
3. React with hooks (different framework, steeper learning curve for the team)
4. No state management (prop drilling, event bus)

**Rationale:**
- Composition API is the recommended approach for Vue 3; better TypeScript support and logic reuse
- Pinia is the official Vuex replacement, simpler API, better devtools integration
- The team wants to practice modern Vue patterns aligned with current ecosystem standards
- Composition API makes it easier to extract reusable logic (e.g., API fetching patterns)

**Trade-offs:**
- Composition API has a learning curve for developers coming from Vue 2 Options API
- More boilerplate for simple components compared to Options API
- Pinia is an additional dependency (though lightweight)
- Without TypeScript, some of Pinia's type-safety benefits are lost

**Store Structure:**
```javascript
// stores/supportRequestStore.js
import { defineStore } from 'pinia'

export const useSupportRequestStore = defineStore('supportRequests', {
  state: () => ({ requests: [], loading: false, error: null }),
  actions: {
    async fetchRequests(filters = {}) { /* ... */ },
    async createRequest(data) { /* ... */ },
    async updateRequest(id, data) { /* ... */ }
  }
})
```

---

## Decision 5: No Authentication or Authorization

**Decision:** Do not implement user authentication, session management, or role-based access control.

**Alternatives Considered:**
1. Devise + token-based auth (JWT or session cookies)
2. Simple password protection (HTTP Basic Auth)
3. OAuth integration (GitHub, Google)

**Rationale:**
- The challenge explicitly lists authentication as out of scope ("Scope control" section)
- Authentication would consume significant development time (setup, login flow, token management, password reset)
- The priority is a reliable backend, correct business behavior, automated tests, and Vue integration
- The application is internal; network-level security is assumed

**Trade-offs:**
- Any user can perform any operation (create, update, delete)
- No audit trail of who made changes
- Cannot restrict access by role (e.g., only support members can resolve requests)
- Not production-ready without authentication layer

**Future Path:**
- Add JWT-based authentication with `devise-jwt` or `knock`
- Implement role-based authorization with Pundit or CanCanCan
- Add audit logging for all state-changing operations

---

## Decision 6: Rack-CORS for Cross-Origin Requests

**Decision:** Use the `rack-cors` gem to enable CORS between the Rails API (port 3000) and Vue frontend (port 5173).

**Alternatives Considered:**
1. Proxy configuration in Vite (hides CORS issue but doesn't solve it for production)
2. JSONP (outdated, limited to GET requests)
3. Same-origin deployment (Rails serves Vue, no CORS needed)

**Rationale:**
- Development requires two separate servers; CORS is unavoidable
- `rack-cors` is the standard Rails solution, minimal configuration
- Configuring CORS correctly in the API is better than hiding it with proxies
- Production-ready: the same CORS config works when frontend and backend are on different domains

**Trade-offs:**
- Additional gem dependency
- Must configure allowed origins carefully to avoid security issues
- Preflight OPTIONS requests add slight latency

**Configuration:**
```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('FRONTEND_URL') { 'http://localhost:5173' }
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

---

## Summary Table

| # | Decision | Status | Impact |
|---|----------|--------|--------|
| 1 | SQLite dev / PostgreSQL prod | ✅ Accepted | Low setup friction, future migration needed |
| 2 | RSpec + FactoryBot | ✅ Accepted | Better testing ergonomics, additional dependencies |
| 3 | Monorepo structure | ✅ Accepted | Simpler collaboration, shared docs |
| 4 | Vue 3 Composition API + Pinia | ✅ Accepted | Modern patterns, learning curve |
| 5 | No authentication | ✅ Accepted (scope) | Faster delivery, not production-ready |
| 6 | Rack-CORS | ✅ Accepted | Required for dev, production-ready config |

---

*This document will be updated as new decisions are made during the challenge.*