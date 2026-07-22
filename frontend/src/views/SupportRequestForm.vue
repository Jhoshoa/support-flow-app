<template>
  <AppLayout :title="isEdit ? `Edit Request #${requestId}` : 'New Support Request'">
    <template #topbar>
      <RouterLink to="/requests" class="btn btn-ghost">Cancel</RouterLink>
    </template>

    <div class="form-container">
      <div class="form-card">
        <LoadingSpinner v-if="loadingData" message="Loading..." />
        <ErrorMessage v-else-if="loadError" :message="loadError" />

        <form v-else @submit.prevent="handleSubmit">
          <FormInput
            v-model="form.title"
            label="Title"
            placeholder="Brief description of the issue"
            :error="errors.title"
          />

          <FormTextarea
            v-model="form.description"
            label="Description"
            placeholder="Detailed description of the issue"
            :rows="6"
            :error="errors.description"
          />

          <div class="form-row">
            <FormSelect
              v-model="form.priority"
              label="Priority"
              :options="priorityOptions"
              :error="errors.priority"
            />
            <FormSelect
              v-model="form.status"
              label="Status"
              :options="statusOptions"
              :error="errors.status"
            />
          </div>

          <div class="form-row">
            <FormSelect
              v-model="form.team_id"
              label="Team"
              :options="teamOptions"
              :error="errors.team_id"
            />
            <FormSelect
              v-model="form.creator_id"
              label="Creator"
              :options="memberOptions"
              :error="errors.creator_id"
            />
          </div>

          <div class="form-row">
            <FormSelect
              v-model="form.assignee_id"
              label="Assignee (optional)"
              placeholder="Unassigned"
              :options="memberOptions"
            />
            <FormInput
              v-model="form.due_date"
              label="Due Date (optional)"
              type="date"
            />
          </div>

          <div class="form-actions">
            <RouterLink to="/requests" class="btn btn-ghost">Cancel</RouterLink>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              {{ submitting ? 'Saving...' : (isEdit ? 'Update Request' : 'Create Request') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'
import AppLayout from '@/components/layout/AppLayout.vue'
import FormInput from '@/components/shared/FormInput.vue'
import FormSelect from '@/components/shared/FormSelect.vue'
import FormTextarea from '@/components/shared/FormTextarea.vue'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'

const route = useRoute()
const router = useRouter()
const requestStore = useSupportRequestStore()
const teamMemberStore = useTeamMemberStore()
const toastStore = useToastStore()

const isEdit = computed(() => !!route.params.id)
const requestId = computed(() => route.params.id)

const form = ref({
  title: '',
  description: '',
  priority: 'medium',
  status: 'open',
  team_id: '',
  creator_id: '',
  assignee_id: '',
  due_date: ''
})

const errors = ref({})
const submitting = ref(false)
const loadingData = ref(false)
const loadError = ref(null)

const priorityOptions = [
  { value: 'low', label: 'Low' },
  { value: 'medium', label: 'Medium' },
  { value: 'high', label: 'High' },
  { value: 'critical', label: 'Critical' }
]

const statusOptions = [
  { value: 'open', label: 'Open' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'resolved', label: 'Resolved' },
  { value: 'closed', label: 'Closed' }
]

const teamOptions = computed(() =>
  [{ value: '', label: '—' }].concat(
    teamMemberStore.members
      .filter(m => m.role === 'support')
      .map(m => ({ value: m.id, label: m.name }))
  )
)

const memberOptions = computed(() =>
  teamMemberStore.members.map(m => ({ value: m.id, label: m.name }))
)

function validate() {
  const e = {}
  if (!form.value.title || form.value.title.length < 5) e.title = 'Title must be at least 5 characters'
  if (!form.value.description || form.value.description.length < 10) e.description = 'Description must be at least 10 characters'
  if (!form.value.priority) e.priority = 'Priority is required'
  if (!form.value.status) e.status = 'Status is required'
  errors.value = e
  return Object.keys(e).length === 0
}

async function handleSubmit() {
  if (!validate()) return

  submitting.value = true
  try {
    const data = { ...form.value }
    if (!data.assignee_id) delete data.assignee_id
    if (!data.due_date) delete data.due_date

    if (isEdit.value) {
      await requestStore.updateRequest(requestId.value, data)
      toastStore.success('Request updated successfully')
    } else {
      await requestStore.createRequest(data)
      toastStore.success('Request created successfully')
    }
    router.push('/requests')
  } catch {
    toastStore.error(isEdit.value ? 'Failed to update request' : 'Failed to create request')
  } finally {
    submitting.value = false
  }
}

async function loadRequest() {
  if (!isEdit.value) return
  loadingData.value = true
  loadError.value = null
  try {
    await requestStore.fetchRequest(requestId.value)
    const req = requestStore.currentRequest
    form.value = {
      title: req.title || '',
      description: req.description || '',
      priority: req.priority || 'medium',
      status: req.status || 'open',
      team_id: req.team_member?.id || '',
      creator_id: '',
      assignee_id: req.team_member?.id || '',
      due_date: req.due_date || ''
    }
  } catch {
    loadError.value = 'Failed to load request'
  } finally {
    loadingData.value = false
  }
}

onMounted(() => {
  teamMemberStore.fetchMembers()
  loadRequest()
})
</script>

<style scoped>
.form-container {
  max-width: 720px;
}

.form-card {
  background: white;
  border-radius: 12px;
  padding: 32px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
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
  padding-top: 24px;
  border-top: 1px solid #E5E7EB;
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
