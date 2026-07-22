<template>
  <span class="badge" :class="`badge--${priority}`">
    {{ label }}
  </span>
</template>

<script setup>
const props = defineProps({ priority: String })

const labels = {
  low: 'Low',
  medium: 'Medium',
  high: 'High',
  critical: 'Critical'
}

const label = labels[props.priority] || props.priority
</script>

<style scoped>
.badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 9999px;
  font-size: 12px;
  font-weight: 600;
  text-transform: capitalize;
}

.badge--low { background: #F3F4F6; color: #6B7280; }
.badge--medium { background: #DBEAFE; color: #1E40AF; }
.badge--high { background: #FEF3C7; color: #92400E; }
.badge--critical { background: #FEE2E2; color: #991B1B; }
</style>
