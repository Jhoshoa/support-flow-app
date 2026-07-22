import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useToastStore = defineStore('toast', () => {
  const toasts = ref([])
  let nextId = 0

  function add(message, type = 'info', duration = 4000) {
    const id = nextId++
    toasts.value.push({ id, message, type, duration })
    setTimeout(() => remove(id), duration)
  }

  function remove(id) {
    const index = toasts.value.findIndex(t => t.id === id)
    if (index > -1) toasts.value.splice(index, 1)
  }

  function success(message) { add(message, 'success') }
  function error(message) { add(message, 'error', 6000) }
  function warning(message) { add(message, 'warning') }
  function info(message) { add(message, 'info') }

  return { toasts, add, remove, success, error, warning, info }
})
