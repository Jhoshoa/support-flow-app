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
