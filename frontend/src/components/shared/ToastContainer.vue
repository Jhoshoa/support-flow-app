<template>
  <Teleport to="body">
    <div class="toast-container">
      <TransitionGroup name="toast">
        <div
          v-for="toast in toastStore.toasts"
          :key="toast.id"
          class="toast"
          :class="`toast--${toast.type}`"
        >
          <span class="toast-icon">{{ iconFor(toast.type) }}</span>
          <span class="toast-message">{{ toast.message }}</span>
          <button class="toast-close" @click="toastStore.remove(toast.id)">&times;</button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<script setup>
import { useToastStore } from '@/stores/toastStore'

const toastStore = useToastStore()

function iconFor(type) {
  const icons = { success: '\u2713', error: '\u2715', warning: '\u26A0', info: '\u2139' }
  return icons[type] || '\u2139'
}
</script>

<style scoped>
.toast-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.toast {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border-radius: 8px;
  background: #FFFFFF;
  box-shadow: 0 10px 15px rgba(0,0,0,0.1);
  min-width: 300px;
  max-width: 400px;
}

.toast--success { border-left: 4px solid #10B981; }
.toast--error { border-left: 4px solid #EF4444; }
.toast--warning { border-left: 4px solid #F59E0B; }
.toast--info { border-left: 4px solid #3B82F6; }

.toast-icon { font-size: 16px; }
.toast-message { flex: 1; font-size: 14px; }
.toast-close {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 18px;
  color: #6B7280;
}

.toast-enter-active,
.toast-leave-active { transition: all 300ms ease; }

.toast-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(100%);
}
</style>
