import { defineStore } from 'pinia'
import apiClient from '@/api/client.js'

export const useTeamMemberStore = defineStore('teamMembers', {
  state: () => ({
    members: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetchMembers() {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.get('/team_members')
        this.members = response.data.team_members
      } catch (err) {
        this.error = err.message
      } finally {
        this.loading = false
      }
    },

    async createMember(data) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.post('/team_members', { team_member: data })
        this.members.push(response.data)
        return response.data
      } catch (err) {
        this.error = err.message
        throw err
      } finally {
        this.loading = false
      }
    },

    async toggleActive(id, active) {
      this.loading = true
      this.error = null
      try {
        const response = await apiClient.patch(`/team_members/${id}`, {
          team_member: { active }
        })
        const index = this.members.findIndex(m => m.id === id)
        if (index !== -1) this.members[index] = response.data
        return response.data
      } catch (err) {
        this.error = err.message
        throw err
      } finally {
        this.loading = false
      }
    }
  }
})
