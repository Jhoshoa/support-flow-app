<template>
  <div class="spinner-container">
    <div class="spinner"></div>
    <span v-if="message" class="spinner-message">{{ message }}</span>
  </div>
</template>

<script setup>
defineProps({
  message: { type: String, default: '' }
})
</script>

<style scoped>
.spinner-container {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 24px;
}

.spinner {
  width: 24px;
  height: 24px;
  border: 3px solid #E5E7EB;
  border-top-color: #2563EB;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.spinner-message {
  font-size: 14px;
  color: #6B7280;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
