<template>
  <AppLayout title="Support Requests">
    <template #topbar>
      <RouterLink to="/requests/new" class="btn btn-primary">New Request</RouterLink>
    </template>

    <div class="filters-bar">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Search requests..."
        class="filter-input"
        @input="debouncedFetch"
      />
      <select v-model="statusFilter" class="filter-select" @change="applyFilters">
        <option value="">All Statuses</option>
        <option value="open">Open</option>
        <option value="in_progress">In Progress</option>
        <option value="resolved">Resolved</option>
        <option value="closed">Closed</option>
      </select>
      <select v-model="priorityFilter" class="filter-select" @change="applyFilters">
        <option value="">All Priorities</option>
        <option value="low">Low</option>
        <option value="medium">Medium</option>
        <option value="high">High</option>
        <option value="critical">Critical</option>
      </select>
      <label class="filter-checkbox">
        <input v-model="overdueFilter" type="checkbox" @change="applyFilters" />
        Overdue only
      </label>
      <label class="filter-checkbox">
        <input v-model="unassignedFilter" type="checkbox" @change="applyFilters" />
        Unassigned only
      </label>
      <button v-if="hasActiveFilters" class="btn btn-ghost" @click="clearAll">Clear Filters</button>
    </div>

    <LoadingSpinner v-if="requestStore.loading" message="Loading requests..." />
    <ErrorMessage v-else-if="requestStore.error" :message="requestStore.error" />

    <template v-else>
      <div class="requests-table-wrapper">
        <table class="requests-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Status</th>
              <th>Priority</th>
              <th>Assignee</th>
              <th>Due Date</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="!requestStore.requests.length">
              <td colspan="7" class="empty-row">No requests found</td>
            </tr>
            <tr v-for="req in requestStore.requests" :key="req.id">
              <td class="cell-id">#{{ req.id }}</td>
              <td>
                <RouterLink :to="`/requests/${req.id}`" class="request-link">
                  {{ req.title }}
                </RouterLink>
              </td>
              <td><StatusBadge :status="req.status" /></td>
              <td><PriorityBadge :priority="req.priority" /></td>
              <td class="cell-assignee">{{ req.team_member?.name || 'Unassigned' }}</td>
              <td class="cell-due" :class="{ 'cell-due--overdue': req.overdue }">
                {{ req.due_date || '—' }}
              </td>
              <td>
                <RouterLink :to="`/requests/${req.id}/edit`" class="btn btn-ghost btn-sm">Edit</RouterLink>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </AppLayout>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import AppLayout from '@/components/layout/AppLayout.vue'
import StatusBadge from '@/components/shared/StatusBadge.vue'
import PriorityBadge from '@/components/shared/PriorityBadge.vue'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'

const requestStore = useSupportRequestStore()

const searchQuery = ref('')
const statusFilter = ref('')
const priorityFilter = ref('')
const overdueFilter = ref(false)
const unassignedFilter = ref(false)

let debounceTimer = null

const hasActiveFilters = computed(() => {
  return searchQuery.value || statusFilter.value || priorityFilter.value || overdueFilter.value || unassignedFilter.value
})

function debouncedFetch() {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => applyFilters(), 300)
}

function applyFilters() {
  requestStore.setFilter('q', searchQuery.value)
  requestStore.setFilter('status', statusFilter.value)
  requestStore.setFilter('priority', priorityFilter.value)
  requestStore.setFilter('overdue', overdueFilter.value)
  requestStore.setFilter('unassigned', unassignedFilter.value)
  requestStore.fetchRequests()
}

function clearAll() {
  searchQuery.value = ''
  statusFilter.value = ''
  priorityFilter.value = ''
  overdueFilter.value = false
  unassignedFilter.value = false
  requestStore.clearFilters()
  requestStore.fetchRequests()
}

onMounted(() => {
  requestStore.fetchRequests()
})
</script>

<style scoped>
.filters-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.filter-input,
.filter-select {
  padding: 8px 12px;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  font-size: 14px;
}

.filter-input {
  min-width: 250px;
}

.filter-select {
  background: white;
}

.filter-checkbox {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #374151;
  cursor: pointer;
}

.requests-table-wrapper {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  overflow: hidden;
}

.requests-table {
  width: 100%;
  border-collapse: collapse;
}

.requests-table th {
  text-align: left;
  padding: 12px 16px;
  font-size: 12px;
  font-weight: 600;
  color: #6B7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid #E5E7EB;
  background: #F9FAFB;
}

.requests-table td {
  padding: 12px 16px;
  font-size: 14px;
  border-bottom: 1px solid #F3F4F6;
  color: #374151;
}

.requests-table tr:hover {
  background: #F9FAFB;
}

.cell-id {
  color: #6B7280;
  font-size: 13px;
  font-weight: 600;
}

.request-link {
  color: #2563EB;
  text-decoration: none;
  font-weight: 500;
}

.request-link:hover {
  text-decoration: underline;
}

.cell-assignee {
  color: #6B7280;
}

.cell-due--overdue {
  color: #DC2626;
  font-weight: 600;
}

.empty-row {
  text-align: center;
  padding: 32px !important;
  color: #9CA3AF;
}

.btn {
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  border: none;
  cursor: pointer;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
}

.btn-primary {
  background: #2563EB;
  color: white;
}

.btn-primary:hover {
  background: #1D4ED8;
}

.btn-ghost {
  background: transparent;
  color: #6B7280;
  border: 1px solid #E5E7EB;
}

.btn-ghost:hover {
  background: #F3F4F6;
}

.btn-sm {
  padding: 4px 10px;
  font-size: 13px;
}
</style>
