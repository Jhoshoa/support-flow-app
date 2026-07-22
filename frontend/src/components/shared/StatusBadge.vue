<template>
  <span class="badge" :class="`badge--${status}`">
    {{ label }}
  </span>
</template>

<script setup>
const props = defineProps({ status: String })

const labels = {
  open: 'Open',
  in_progress: 'In Progress',
  resolved: 'Resolved',
  closed: 'Closed'
}

const label = labels[props.status] || props.status
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

.badge--open { background: #DBEAFE; color: #1E40AF; }
.badge--in_progress { background: #FEF3C7; color: #92400E; }
.badge--resolved { background: #D1FAE5; color: #065F46; }
.badge--closed { background: #F3F4F6; color: #374151; }
</style>
