<template>
  <AppLayout title="Dashboard">
    <template #topbar>
      <RouterLink to="/requests/new" class="btn btn-primary">New Request</RouterLink>
    </template>

    <LoadingSpinner v-if="dashboardStore.loading" message="Loading metrics..." />
    <ErrorMessage v-else-if="dashboardStore.error" :message="dashboardStore.error" />

    <template v-else-if="dashboardStore.metrics">
      <div class="metrics-grid">
        <div class="metric-card">
          <div class="metric-value">{{ dashboardStore.metrics.total_requests }}</div>
          <div class="metric-label">Total Requests</div>
        </div>
        <div class="metric-card">
          <div class="metric-value">{{ dashboardStore.metrics.requests_by_status?.open || 0 }}</div>
          <div class="metric-label">Open</div>
        </div>
        <div class="metric-card">
          <div class="metric-value">{{ dashboardStore.metrics.requests_by_status?.in_progress || 0 }}</div>
          <div class="metric-label">In Progress</div>
        </div>
        <div class="metric-card">
          <div class="metric-value">{{ dashboardStore.metrics.requests_by_status?.resolved || 0 }}</div>
          <div class="metric-label">Resolved</div>
        </div>
      </div>

      <div class="dashboard-columns">
        <div class="dashboard-section">
          <h3 class="section-title">Requests by Priority</h3>
          <div class="stats-list">
            <div v-for="(count, priority) in dashboardStore.metrics.requests_by_priority" :key="priority" class="stat-row">
              <PriorityBadge :priority="priority" />
              <span class="stat-count">{{ count }}</span>
            </div>
          </div>
        </div>

        <div class="dashboard-section">
          <h3 class="section-title">Requests by Team</h3>
          <div v-if="!dashboardStore.metrics.requests_by_team?.length" class="empty-state">
            No data
          </div>
          <div v-else class="stats-list">
            <div v-for="member in dashboardStore.metrics.requests_by_team" :key="member.id" class="stat-row">
              <span class="stat-name">{{ member.name }}</span>
              <span class="stat-count">{{ member.count }}</span>
            </div>
          </div>
        </div>
      </div>

      <RouterLink to="/requests" class="view-all-link">View all requests &rarr;</RouterLink>
    </template>
  </AppLayout>
</template>

<script setup>
import { onMounted } from 'vue'
import { useDashboardStore } from '@/stores/dashboardStore'
import AppLayout from '@/components/layout/AppLayout.vue'
import PriorityBadge from '@/components/shared/PriorityBadge.vue'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'

const dashboardStore = useDashboardStore()

onMounted(() => {
  dashboardStore.fetchMetrics()
})
</script>

<style scoped>
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 32px;
}

.metric-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.metric-value {
  font-size: 32px;
  font-weight: 700;
  color: #111827;
  margin-bottom: 4px;
}

.metric-label {
  font-size: 14px;
  color: #6B7280;
}

.dashboard-columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.dashboard-section {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.section-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 600;
  color: #111827;
}

.empty-state {
  padding: 24px;
  text-align: center;
  color: #9CA3AF;
  font-size: 14px;
}

.stats-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.stat-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #F3F4F6;
}

.stat-row:last-child {
  border-bottom: none;
}

.stat-name {
  font-size: 14px;
  color: #374151;
}

.stat-count {
  font-size: 16px;
  font-weight: 700;
  color: #111827;
}

.view-all-link {
  display: inline-block;
  margin-top: 24px;
  color: #2563EB;
  font-size: 14px;
  font-weight: 500;
  text-decoration: none;
}

.view-all-link:hover {
  text-decoration: underline;
}
</style>
