<template>
  <div class="error-container">
    <div class="error-icon">!</div>
    <div class="error-content">
      <h4 class="error-title">{{ title }}</h4>
      <p v-if="message" class="error-message">{{ message }}</p>
      <ul v-if="details && details.length" class="error-details">
        <li v-for="(detail, index) in details" :key="index">{{ detail }}</li>
      </ul>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: { type: String, default: 'Something went wrong' },
  message: { type: String, default: '' },
  details: { type: Array, default: () => [] }
})
</script>

<style scoped>
.error-container {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px;
  background: #FEF2F2;
  border: 1px solid #FECACA;
  border-radius: 8px;
}

.error-icon {
  width: 32px;
  height: 32px;
  background: #EF4444;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  flex-shrink: 0;
}

.error-title {
  margin: 0 0 4px;
  font-size: 14px;
  font-weight: 600;
  color: #991B1B;
}

.error-message {
  margin: 0;
  font-size: 13px;
  color: #7F1D1D;
}

.error-details {
  margin: 8px 0 0;
  padding-left: 16px;
  font-size: 13px;
  color: #7F1D1D;
}

.error-details li {
  margin-bottom: 2px;
}
</style>
