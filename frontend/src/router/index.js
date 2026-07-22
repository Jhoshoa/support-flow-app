import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '@/views/Dashboard.vue'
import SupportRequestList from '@/views/SupportRequestList.vue'
import SupportRequestDetail from '@/views/SupportRequestDetail.vue'
import SupportRequestForm from '@/views/SupportRequestForm.vue'
import TeamMemberList from '@/views/TeamMemberList.vue'

const routes = [
  { path: '/', name: 'Dashboard', component: Dashboard },
  { path: '/requests', name: 'RequestList', component: SupportRequestList },
  { path: '/requests/new', name: 'RequestNew', component: SupportRequestForm },
  { path: '/requests/:id', name: 'RequestDetail', component: SupportRequestDetail },
  { path: '/requests/:id/edit', name: 'RequestEdit', component: SupportRequestForm },
  { path: '/members', name: 'TeamMembers', component: TeamMemberList }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
