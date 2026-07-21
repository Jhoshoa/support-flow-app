# SupportFlow — Dependencies Documentation

> Technical documentation for all external libraries and gems used in the project. Explains what each dependency does, why it was chosen, and how it fits into the architecture.

---

## Table of Contents

1. [Backend Dependencies (Ruby Gems)](#backend-dependencies)
2. [Frontend Dependencies (NPM Packages)](#frontend-dependencies)
3. [Dependency Comparison Table](#dependency-comparison-table)

---

## Backend Dependencies

### rack-cors

| Property | Value |
|----------|-------|
| **Name** | `rack-cors` |
| **Type** | Ruby Gem (Middleware) |
| **Purpose** | Handle Cross-Origin Resource Sharing (CORS) |
| **Group** | Production |

#### What it does

`rack-cors` is a Rack middleware that adds CORS headers to HTTP responses. When the Vue frontend (running on `http://localhost:5173`) makes API requests to the Rails backend (running on `http://localhost:3000`), browsers block these requests due to the **Same-Origin Policy**. CORS headers tell the browser that cross-origin requests are allowed.

#### Why it's necessary

Without CORS configuration:
- Vue app on port 5173 **cannot** fetch data from Rails on port 3000
- All API calls will fail with CORS errors in the browser console
- The application will not function

#### Configuration

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_URL") { "http://localhost:5173" }
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

#### How it works

1. Vue sends `GET /api/v1/team_members` from `localhost:5173`
2. Browser detects cross-origin request and sends `OPTIONS` preflight
3. `rack-cors` responds with `Access-Control-Allow-Origin: http://localhost:5173`
4. Browser allows the actual `GET` request to proceed
5. Rails processes the request and returns JSON with CORS headers

---

### rspec-rails

| Property | Value |
|----------|-------|
| **Name** | `rspec-rails` |
| **Type** | Ruby Gem (Testing Framework) |
| **Purpose** | Write and run automated tests for Rails |
| **Group** | development, test |

#### What it does

`rspec-rails` is a testing framework that provides a DSL (Domain Specific Language) for writing tests in Rails applications. It integrates with Rails' test infrastructure while providing more expressive syntax than Minitest (Rails default).

#### Why it's necessary

- **Readable tests**: `describe`, `context`, `it` blocks make tests self-documenting
- **Request specs**: Test API endpoints with clean HTTP semantics
- **Model specs**: Test validations, associations, and business rules
- **Matchers**: Powerful assertions like `have_http_status(:ok)`, `include()`, `be_present`
- **Industry standard**: Most Rails teams use RSpec; skills transfer to other projects

#### Usage Examples

```ruby
# spec/models/team_member_spec.rb
RSpec.describe TeamMember, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:email) }
  end
end

# spec/requests/team_members_spec.rb
RSpec.describe 'Team Members API', type: :request do
  describe 'GET /api/v1/team_members' do
    it 'returns all team members' do
      create(:team_member)
      get '/api/v1/team_members'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(1)
    end
  end
end
```

#### Commands

```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/models       # Run model tests only
bundle exec rspec spec/requests     # Run request tests only
bundle exec rspec spec/models/team_member_spec.rb  # Run specific file
```

---

### factory_bot_rails

| Property | Value |
|----------|-------|
| **Name** | `factory_bot_rails` |
| **Type** | Ruby Gem (Test Data) |
| **Purpose** | Create test data programmatically |
| **Group** | development, test |

#### What it does

`factory_bot_rails` provides a framework for defining and creating test data (factories). Instead of manually creating objects in each test, you define factories once and use them everywhere.

#### Why it's necessary

- **DRY test data**: Define a factory once, use it in all tests
- **Dynamic data**: Easily override attributes for specific test cases
- **Associations**: Automatically create related objects
- **Realistic data**: Combine with Faker for realistic test data

#### Usage Examples

```ruby
# spec/factories/team_members.rb
FactoryBot.define do
  factory :team_member do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    role { :developer }
    active { true }
  end
end

# In tests
member = create(:team_member)                    # Create and save
member = create(:team_member, role: :qa)         # Override attribute
member = build(:team_member)                     # Build without saving
inactive = create(:team_member, active: false)   # Inactive member
```

#### Why not use fixtures?

| Feature | FactoryBot | Fixtures |
|---------|-----------|----------|
| Syntax | Ruby DSL | YAML files |
| Dynamic data | Yes (Faker) | No (static) |
| Readability | High | Low |
| Flexibility | High | Low |
| Speed | Slightly slower | Faster |

For a 3-day challenge, FactoryBot's readability and flexibility outweigh the minor speed difference.

---

### faker

| Property | Value |
|----------|-------|
| **Name** | `faker` |
| **Type** | Ruby Gem (Data Generation) |
| **Purpose** | Generate realistic fake data |
| **Group** | development, test |

#### What it does

`faker` generates realistic fake data: names, emails, phone numbers, addresses, sentences, dates, and more. It's used in factories and seed data to create realistic test data.

#### Why it's necessary

- **Realistic seeds**: Database looks like real production data
- **Better tests**: Tests run against realistic data, not "test1", "test2"
- **Variety**: Each test gets unique data, avoiding collisions
- **No manual creation**: Don't waste time making up fake names and emails

#### Usage Examples

```ruby
Faker::Name.name           # => "John Smith"
Faker::Internet.email      # => "john@example.com"
Faker::Lorem.sentence      # => "Dolores et distinctio."
Faker::Date.backward(days: 30)  # => 2 weeks ago
Faker::Number.between(from: 1, to: 100)  # => 42
```

#### In seed data

```ruby
# db/seeds.rb
10.times do
  TeamMember.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    role: [:developer, :qa, :support].sample
  )
end
```

---

## Frontend Dependencies

### axios

| Property | Value |
|----------|-------|
| **Name** | `axios` |
| **Type** | NPM Package (HTTP Client) |
| **Purpose** | Make API requests to the Rails backend |
| **Group** | dependencies |

#### What it does

`axios` is a Promise-based HTTP client for the browser and Node.js. It provides a clean API for making HTTP requests (GET, POST, PATCH, DELETE) and handling responses.

#### Why it's necessary

- **Promise-based**: Clean `async/await` syntax
- **Request interceptors**: Add auth tokens, log requests, handle errors globally
- **Response interceptors**: Normalize errors, handle 401/403/500 responses
- **Automatic JSON parsing**: Response data is automatically parsed
- **Error handling**: Built-in support for HTTP error codes

#### Why not use native `fetch`?

| Feature | Axios | Fetch API |
|---------|-------|-----------|
| JSON parsing | Automatic | Manual (`response.json()`) |
| Error handling | Rejects on 4xx/5xx | Only rejects on network error |
| Interceptors | Built-in | Manual |
| Request timeout | Built-in | Manual |
| Browser support | All browsers | Modern browsers |

#### Usage Examples

```javascript
// src/api/client.js
import axios from 'axios'

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api/v1',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

// Request interceptor
apiClient.interceptors.request.use(config => {
  return config
})

// Response interceptor
apiClient.interceptors.response.use(
  response => response,
  error => {
    const message = error.response?.data?.error || 'An unexpected error occurred'
    return Promise.reject({ message, status: error.response?.status })
  }
)

export default apiClient
```

```javascript
// In a component
import apiClient from '@/api/client.js'

// GET request
const response = await apiClient.get('/team_members')
const members = response.data.team_members

// POST request
const response = await apiClient.post('/support_requests', {
  support_request: { title: 'New bug', priority: 'high' }
})
```

---

### vue-router@4

| Property | Value |
|----------|-------|
| **Name** | `vue-router` |
| **Type** | NPM Package (Routing) |
| **Purpose** | Client-side URL routing for Vue |
| **Group** | dependencies |

#### What it does

`vue-router` is the official router for Vue.js. It maps URLs to Vue components, enabling navigation between different views without full page reloads.

#### Why it's necessary

- **SPA navigation**: Navigate between Dashboard, Requests, Detail, Members without page reloads
- **URL mapping**: Each view has a clean URL (`/`, `/requests`, `/requests/:id`, `/members`)
- **History mode**: Clean URLs without `#` in the path
- **Route params**: Extract IDs from URLs (`/requests/5` → `id = 5`)
- **Nested routes**: Support for nested views

#### Routes for SupportFlow

```javascript
// src/router/index.js
const routes = [
  { path: '/', name: 'Dashboard', component: Dashboard },
  { path: '/requests', name: 'RequestList', component: SupportRequestList },
  { path: '/requests/new', name: 'RequestNew', component: SupportRequestForm },
  { path: '/requests/:id', name: 'RequestDetail', component: SupportRequestDetail },
  { path: '/requests/:id/edit', name: 'RequestEdit', component: SupportRequestForm },
  { path: '/members', name: 'TeamMembers', component: TeamMemberList }
]
```

#### Usage Examples

```vue
<template>
  <nav>
    <RouterLink to="/">Dashboard</RouterLink>
    <RouterLink to="/requests">Requests</RouterLink>
    <RouterLink to="/members">Team Members</RouterLink>
  </nav>
  <RouterView />
</template>

<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>
```

```javascript
// Get route params
import { useRoute } from 'vue-router'
const route = useRoute()
const requestId = route.params.id  // From /requests/:id
```

---

### pinia

| Property | Value |
|----------|-------|
| **Name** | `pinia` |
| **Type** | NPM Package (State Management) |
| **Purpose** | Centralized state management for Vue |
| **Group** | dependencies |

#### What it does

`Pinia` is the official state management library for Vue 3 (replaces Vuex). It provides a centralized store for managing shared state across components.

#### Why it's necessary

- **Shared state**: Multiple components need the same data (e.g., support requests list)
- **API caching**: Store fetched data so components don't re-fetch
- **Filter state**: Keep filter selections persistent across navigation
- **Loading/error states**: Centralized loading indicators and error messages
- **DevTools integration**: Debug state changes with Vue DevTools

#### Why Pinia over Vuex?

| Feature | Pinia | Vuex |
|---------|-------|------|
| API | Simple, direct | Verbose, nested |
| TypeScript | Excellent | Good |
| Mutations | None (direct state modification) | Required |
| Modules | Native (multiple stores) | Manual splitting |
| Bundle size | ~1KB | ~6KB |
| Official support | Vue 3 official | Maintenance mode |

#### Store Structure for SupportFlow

```javascript
// stores/supportRequestStore.js
import { defineStore } from 'pinia'
import apiClient from '@/api/client.js'

export const useSupportRequestStore = defineStore('supportRequests', {
  state: () => ({
    requests: [],
    currentRequest: null,
    filters: { status: '', priority: '', team_member_id: '' },
    loading: false,
    error: null
  }),

  actions: {
    async fetchRequests() {
      this.loading = true
      try {
        const response = await apiClient.get('/support_requests', {
          params: this.filters
        })
        this.requests = response.data.support_requests
      } catch (err) {
        this.error = err.message
      } finally {
        this.loading = false
      }
    },

    async createRequest(data) {
      const response = await apiClient.post('/support_requests', {
        support_request: data
      })
      this.requests.unshift(response.data)
      return response.data
    }
  }
})
```

#### Usage in Components

```vue
<template>
  <div v-if="store.loading">Loading...</div>
  <div v-else>
    <div v-for="request in store.requests" :key="request.id">
      {{ request.title }}
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useSupportRequestStore } from '@/stores/supportRequestStore'

const store = useSupportRequestStore()

onMounted(() => {
  store.fetchRequests()
})
</script>
```

---

## Dependency Comparison Table

### Backend

| Gem | Purpose | Replaces | Group |
|-----|---------|----------|-------|
| `rack-cors` | CORS handling | Manual headers | production |
| `rspec-rails` | Testing framework | Minitest | development, test |
| `factory_bot_rails` | Test data creation | Fixtures | development, test |
| `faker` | Fake data generation | Manual strings | development, test |

### Frontend

| Package | Purpose | Replaces | Group |
|---------|---------|----------|-------|
| `axios` | HTTP client | `fetch` API | dependencies |
| `vue-router` | Client-side routing | Manual URL handling | dependencies |
| `pinia` | State management | Vuex, prop drilling | dependencies |

---

## Architecture Decision Records (ADR)

### ADR-001: Use RSpec over Minitest

**Decision**: Use RSpec for testing instead of Rails default Minitest.

**Context**: Need a testing framework that supports expressive syntax for model validations and API request testing.

**Consequences**:
- ✅ More readable tests with `describe`/`it` blocks
- ✅ Better matchers for Rails-specific assertions
- ✅ Industry standard, skills transfer to other projects
- ❌ Additional gem dependency
- ❌ Slightly slower than Minitest

---

### ADR-002: Use Axios over Fetch API

**Decision**: Use Axios for HTTP requests instead of native Fetch.

**Context**: Need to make API calls from Vue to Rails, handle errors, and potentially add auth tokens.

**Consequences**:
- ✅ Automatic JSON parsing
- ✅ Built-in error handling for 4xx/5xx
- ✅ Interceptors for global logic
- ✅ Cleaner async/await syntax
- ❌ Additional package dependency
- ❌ Slightly larger bundle size

---

### ADR-003: Use Pinia over Vuex

**Decision**: Use Pinia for state management instead of Vuex.

**Context**: Need centralized state for support requests, filters, and loading states.

**Consequences**:
- ✅ Simpler API (no mutations, direct state changes)
- ✅ Better TypeScript support
- ✅ Official Vue 3 recommendation
- ✅ Smaller bundle size
- ❌ Different API from Vuex (team may need to learn)

---

### ADR-004: Use FactoryBot over Fixtures

**Decision**: Use FactoryBot for test data instead of YAML fixtures.

**Context**: Need realistic, dynamic test data for model and request specs.

**Consequences**:
- ✅ Dynamic, realistic data with Faker
- ✅ More readable test setup
- ✅ Easy to override attributes per test
- ❌ Slightly slower than fixtures
- ❌ More verbose than fixtures for simple cases

---

## Installation Commands Summary

### Backend

```bash
cd backend

# Add gems
bundle add rack-cors
bundle add rspec-rails --group="development, test"
bundle add factory_bot_rails --group="development, test"
bundle add faker --group="development, test"

# Install
bundle install

# Generate RSpec config
rails generate rspec:install
```

### Frontend

```bash
cd frontend

# Install packages
npm install axios vue-router@4 pinia
```

---

*This document should be updated when adding new dependencies to the project.*
