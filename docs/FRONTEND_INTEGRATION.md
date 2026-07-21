# SupportFlow — Frontend Integration Guide

> This document maps each Vue view to the API endpoints it consumes, including request/response expectations and state management approach.

---

## API Client Configuration

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

// Request interceptor (optional: add auth token here in future)
apiClient.interceptors.request.use(config => {
  return config
})

// Response interceptor for consistent error handling
apiClient.interceptors.response.use(
  response => response,
  error => {
    const message = error.response?.data?.error || 'An unexpected error occurred'
    const details = error.response?.data?.details || []
    return Promise.reject({ message, details, status: error.response?.status })
  }
)

export default apiClient
```

---

## Store: Dashboard

```javascript
// stores/dashboardStore.js
import { defineStore } from 'pinia'
import apiClient from '@/api/client.js'

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    metrics: null,
    loading: false,
    error: null
  }),

  actions: {
    async fetchMetrics() {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.get('/dashboard')
        this.metrics = response.data
      } catch (err) {
        this.error = err.message
      } finally {
        this.loading = false
      }
    }
  }
})
```

**Consumed by:** `Dashboard.vue`
**Endpoint:** `GET /api/v1/dashboard`
**Response shape:** `{ total_requests, overdue_requests, unassigned_requests, requests_by_status, requests_by_priority }`

---

## Store: Support Requests

```javascript
// stores/supportRequestStore.js
import { defineStore } from 'pinia'
import apiClient from '@/api/client.js'

export const useSupportRequestStore = defineStore('supportRequests', {
  state: () => ({
    requests: [],
    currentRequest: null,
    filters: {
      status: '',
      priority: '',
      team_member_id: '',
      overdue: false,
      unassigned: false,
      q: ''
    },
    loading: false,
    error: null
  }),

  getters: {
    activeFilters: (state) => {
      const filters = {}
      if (state.filters.status) filters.status = state.filters.status
      if (state.filters.priority) filters.priority = state.filters.priority
      if (state.filters.team_member_id) filters.team_member_id = state.filters.team_member_id
      if (state.filters.overdue) filters.overdue = true
      if (state.filters.unassigned) filters.unassigned = true
      if (state.filters.q) filters.q = state.filters.q
      return filters
    }
  },

  actions: {
    async fetchRequests() {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.get('/support_requests', {
          params: this.activeFilters
        })
        this.requests = response.data.support_requests
      } catch (err) {
        this.error = err.message
      } finally {
        this.loading = false
      }
    },

    async fetchRequest(id) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.get(`/support_requests/${id}`)
        this.currentRequest = response.data
      } catch (err) {
        this.error = err.message
      } finally {
        this.loading = false
      }
    },

    async createRequest(data) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/support_requests', { support_request: data })
        this.requests.unshift(response.data)
        return response.data
      } catch (err) {
        this.error = err.message
        throw err
      } finally {
        this.loading = false
      }
    },

    async updateRequest(id, data) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.patch(`/support_requests/${id}`, { support_request: data })
        const index = this.requests.findIndex(r => r.id === id)
        if (index !== -1) this.requests[index] = response.data
        if (this.currentRequest?.id === id) this.currentRequest = response.data
        return response.data
      } catch (err) {
        this.error = err.message
        throw err
      } finally {
        this.loading = false
      }
    },

    async addComment(requestId, data) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post(
          `/support_requests/${requestId}/comments`,
          { comment: data }
        )
        // Refresh the request to get updated comments
        await this.fetchRequest(requestId)
        return response.data
      } catch (err) {
        this.error = err.message
        throw err
      } finally {
        this.loading = false
      }
    },

    setFilter(key, value) {
      this.filters[key] = value
    },

    clearFilters() {
      this.filters = {
        status: '',
        priority: '',
        team_member_id: '',
        overdue: false,
        unassigned: false,
        q: ''
      }
    }
  }
})
```

**Consumed by:**
- `SupportRequestList.vue` — `fetchRequests()` + filters
- `SupportRequestDetail.vue` — `fetchRequest(id)`
- `SupportRequestForm.vue` — `createRequest(data)` / `updateRequest(id, data)`
- `CommentForm.vue` — `addComment(requestId, data)`

---

## Store: Team Members

```javascript
// stores/teamMemberStore.js
import { defineStore } from 'pinia'
import apiClient from '@/api/client.js'

export const useTeamMemberStore = defineStore('teamMembers', {
  state: () => ({
    members: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetchMembers() {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.get('/team_members')
        this.members = response.data.team_members
      } catch (err) {
        this.error = err.message
      } finally {
        this.loading = false
      }
    },

    async createMember(data) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/team_members', { team_member: data })
        this.members.push(response.data)
        return response.data
      } catch (err) {
        this.error = err.message
        throw err
      } finally {
        this.loading = false
      }
    },

    async toggleActive(id, active) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.patch(`/team_members/${id}`, {
          team_member: { active }
        })
        const index = this.members.findIndex(m => m.id === id)
        if (index !== -1) this.members[index] = response.data
        return response.data
      } catch (err) {
        this.error = err.message
        throw err
      } finally {
        this.loading = false
      }
    }
  }
})
```

**Consumed by:**
- `TeamMemberList.vue` — `fetchMembers()`, `toggleActive(id, active)`
- `TeamMemberForm.vue` — `createMember(data)`
- `SupportRequestForm.vue` — `fetchMembers()` (for assignment dropdown)

---

## Vue Router Configuration

```javascript
// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '@/components/Dashboard.vue'
import SupportRequestList from '@/components/SupportRequestList.vue'
import SupportRequestDetail from '@/components/SupportRequestDetail.vue'
import SupportRequestForm from '@/components/SupportRequestForm.vue'
import TeamMemberList from '@/components/TeamMemberList.vue'

const routes = [
  { path: '/', name: 'Dashboard', component: Dashboard },
  { path: '/requests', name: 'RequestList', component: SupportRequestList },
  { path: '/requests/new', name: 'RequestNew', component: SupportRequestForm },
  { path: '/requests/:id', name: 'RequestDetail', component: SupportRequestDetail },
  { path: '/requests/:id/edit', name: 'RequestEdit', component: SupportRequestForm },
  { path: '/members', name: 'TeamMembers', component: TeamMemberList }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
```

---

## Component ↔ API Mapping

| Vue Component | API Endpoint(s) | Store Action | Trigger |
|---------------|----------------|--------------|---------|
| `Dashboard.vue` | `GET /dashboard` | `dashboardStore.fetchMetrics()` | On mount |
| `SupportRequestList.vue` | `GET /support_requests?filters` | `supportRequestStore.fetchRequests()` | On mount, filter change |
| `SupportRequestDetail.vue` | `GET /support_requests/:id` | `supportRequestStore.fetchRequest(id)` | On mount, route param |
| `SupportRequestForm.vue` (create) | `POST /support_requests` | `supportRequestStore.createRequest(data)` | Form submit |
| `SupportRequestForm.vue` (edit) | `PATCH /support_requests/:id` | `supportRequestStore.updateRequest(id, data)` | Form submit |
| `CommentForm.vue` | `POST /support_requests/:id/comments` | `supportRequestStore.addComment(id, data)` | Form submit |
| `TeamMemberList.vue` | `GET /team_members` | `teamMemberStore.fetchMembers()` | On mount |
| `TeamMemberForm.vue` | `POST /team_members` | `teamMemberStore.createMember(data)` | Form submit |
| `TeamMemberList.vue` (toggle) | `PATCH /team_members/:id` | `teamMemberStore.toggleActive(id, active)` | Toggle click |

---

## Error Handling Pattern

All components should follow this pattern:

```vue
<template>
  <div>
    <LoadingSpinner v-if="loading" />
    <ErrorMessage v-else-if="error" :message="error" />
    <div v-else>
      <!-- Content -->
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useDashboardStore } from '@/stores/dashboardStore'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'

const store = useDashboardStore()

onMounted(() => {
  store.fetchMetrics()
})
</script>
```

---

## Environment Variables

```bash
# frontend/.env
VITE_API_BASE_URL=http://localhost:3000/api/v1
```

```yaml
# backend/.env.example
FRONTEND_URL=http://localhost:5173
RAILS_ENV=development
```