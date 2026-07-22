<template>
  <AppLayout title="Team Members">
    <template #topbar>
      <button class="btn btn-primary" @click="showForm = true">Add Member</button>
    </template>

    <LoadingSpinner v-if="teamMemberStore.loading && !teamMemberStore.members.length" message="Loading members..." />
    <ErrorMessage v-else-if="teamMemberStore.error" :message="teamMemberStore.error" />

    <template v-else>
      <div v-if="showForm" class="form-card">
        <h3 class="form-card-title">New Team Member</h3>
        <form @submit.prevent="handleCreate">
          <div class="form-row">
            <FormInput v-model="newMember.name" label="Name" :error="formErrors.name" />
            <FormInput v-model="newMember.email" label="Email" type="email" :error="formErrors.email" />
          </div>
          <FormSelect v-model="newMember.role" label="Role" :options="roleOptions" :error="formErrors.role" />
          <div class="form-actions">
            <button type="button" class="btn btn-ghost" @click="showForm = false">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="creating">Add Member</button>
          </div>
        </form>
      </div>

      <div class="members-grid">
        <div v-if="!teamMemberStore.members.length" class="empty-state">
          No team members yet. Add one!
        </div>
        <div v-for="member in teamMemberStore.members" :key="member.id" class="member-card" :class="{ 'member-card--inactive': !member.active }">
          <div class="member-avatar">{{ member.name[0] }}</div>
          <div class="member-info">
            <div class="member-name">{{ member.name }}</div>
            <div class="member-email">{{ member.email }}</div>
            <span class="role-badge">{{ member.role }}</span>
          </div>
          <div class="member-actions">
            <label class="toggle">
              <input
                type="checkbox"
                :checked="member.active"
                @change="handleToggle(member.id, $event.target.checked)"
              />
              <span class="toggle-slider"></span>
            </label>
          </div>
        </div>
      </div>
    </template>
  </AppLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'
import AppLayout from '@/components/layout/AppLayout.vue'
import FormInput from '@/components/shared/FormInput.vue'
import FormSelect from '@/components/shared/FormSelect.vue'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'

const teamMemberStore = useTeamMemberStore()
const toastStore = useToastStore()

const showForm = ref(false)
const creating = ref(false)

const newMember = ref({ name: '', email: '', role: 'developer' })
const formErrors = ref({})

const roleOptions = [
  { value: 'developer', label: 'Developer' },
  { value: 'qa', label: 'QA' },
  { value: 'support', label: 'Support' }
]

async function handleCreate() {
  formErrors.value = {}
  let hasError = false

  if (!newMember.value.name) { formErrors.value.name = 'Required'; hasError = true }
  if (!newMember.value.email || !newMember.value.email.includes('@')) { formErrors.value.email = 'Valid email required'; hasError = true }
  if (hasError) return

  creating.value = true
  try {
    await teamMemberStore.createMember(newMember.value)
    toastStore.success('Member added successfully')
    showForm.value = false
    newMember.value = { name: '', email: '', role: 'developer' }
  } catch {
    toastStore.error('Failed to add member')
  } finally {
    creating.value = false
  }
}

async function handleToggle(id, active) {
  try {
    await teamMemberStore.toggleActive(id, active)
    toastStore.success(`Member ${active ? 'activated' : 'deactivated'}`)
  } catch {
    toastStore.error('Failed to update member')
  }
}

onMounted(() => {
  teamMemberStore.fetchMembers()
})
</script>

<style scoped>
.form-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  margin-bottom: 24px;
}

.form-card-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 600;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 8px;
}

.members-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
}

.member-card {
  display: flex;
  align-items: center;
  gap: 12px;
  background: white;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.member-card--inactive {
  opacity: 0.5;
}

.member-avatar {
  width: 48px;
  height: 48px;
  background: #2563EB;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
  flex-shrink: 0;
}

.member-info {
  flex: 1;
  min-width: 0;
}

.member-name {
  font-size: 14px;
  font-weight: 600;
  color: #111827;
}

.member-email {
  font-size: 13px;
  color: #6B7280;
  margin-bottom: 4px;
}

.role-badge {
  display: inline-block;
  padding: 2px 8px;
  background: #F3F4F6;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  color: #374151;
  text-transform: capitalize;
}

.toggle {
  position: relative;
  display: inline-block;
  width: 44px;
  height: 24px;
  cursor: pointer;
}

.toggle input {
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-slider {
  position: absolute;
  inset: 0;
  background: #E5E7EB;
  border-radius: 24px;
  transition: background 200ms;
}

.toggle-slider::before {
  content: '';
  position: absolute;
  height: 18px;
  width: 18px;
  left: 3px;
  bottom: 3px;
  background: white;
  border-radius: 50%;
  transition: transform 200ms;
}

.toggle input:checked + .toggle-slider {
  background: #10B981;
}

.toggle input:checked + .toggle-slider::before {
  transform: translateX(20px);
}

.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 32px;
  color: #9CA3AF;
}

.btn {
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  border: none;
  cursor: pointer;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
}

.btn-primary {
  background: #2563EB;
  color: white;
}

.btn-primary:hover {
  background: #1D4ED8;
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-ghost {
  background: transparent;
  color: #6B7280;
  border: 1px solid #E5E7EB;
}

.btn-ghost:hover {
  background: #F3F4F6;
}
</style>
