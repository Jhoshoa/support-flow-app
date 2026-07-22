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
