<template>
  <AppLayout :title="`Request #${requestId}`">
    <template #topbar>
      <RouterLink :to="`/requests/${requestId}/edit`" class="btn btn-primary">Edit Request</RouterLink>
      <RouterLink to="/requests" class="btn btn-ghost">Back to List</RouterLink>
    </template>

    <LoadingSpinner v-if="requestStore.loading && !requestStore.currentRequest" message="Loading request..." />
    <ErrorMessage v-else-if="requestStore.error" :message="requestStore.error" />

    <template v-else-if="requestStore.currentRequest">
      <div class="detail-grid">
        <div class="detail-main">
          <div class="detail-card">
            <div class="detail-header">
              <span class="detail-id">#{{ requestStore.currentRequest.id }}</span>
              <StatusBadge :status="requestStore.currentRequest.status" />
              <PriorityBadge :priority="requestStore.currentRequest.priority" />
            </div>
            <h2 class="detail-title">{{ requestStore.currentRequest.title }}</h2>
            <p class="detail-description">{{ requestStore.currentRequest.description }}</p>
          </div>

          <div class="detail-card">
            <h3 class="detail-section-title">Comments ({{ requestStore.currentRequest.comments?.length || 0 }})</h3>

            <div v-if="!requestStore.currentRequest.comments?.length" class="empty-state">
              No comments yet. Be the first to respond!
            </div>

            <div v-else class="comments-list">
              <div v-for="comment in requestStore.currentRequest.comments" :key="comment.id" class="comment">
                <div class="comment-header">
                  <span class="comment-author">{{ comment.author_name }}</span>
                  <span class="comment-date">{{ comment.created_at }}</span>
                </div>
                <p class="comment-body">{{ comment.body }}</p>
              </div>
            </div>

            <div class="comment-form">
              <h4 class="comment-form-title">Add Comment</h4>
              <FormSelect
                v-model="commentForm.author_name"
                label="Your Name"
                placeholder="Select your name"
                :options="memberOptions"
                :error="commentErrors.author_name"
              />
              <FormTextarea
                v-model="commentForm.body"
                placeholder="Write your comment..."
                :error="commentErrors.body"
              />
              <button class="btn btn-primary" :disabled="submitting" @click="submitComment">
                {{ submitting ? 'Posting...' : 'Post Comment' }}
              </button>
            </div>
          </div>
        </div>

        <div class="detail-sidebar">
          <div class="detail-card">
            <h3 class="detail-section-title">Details</h3>
            <div class="detail-props">
              <div class="detail-prop">
                <span class="prop-label">Status</span>
                <StatusBadge :status="requestStore.currentRequest.status" />
              </div>
              <div class="detail-prop">
                <span class="prop-label">Priority</span>
                <PriorityBadge :priority="requestStore.currentRequest.priority" />
              </div>
              <div class="detail-prop">
                <span class="prop-label">Assignee</span>
                <span class="prop-value">{{ requestStore.currentRequest.team_member?.name || 'Unassigned' }}</span>
              </div>
              <div class="detail-prop">
                <span class="prop-label">Due Date</span>
                <span class="prop-value" :class="{ 'prop-value--overdue': requestStore.currentRequest.overdue }">
                  {{ requestStore.currentRequest.due_date || '—' }}
                </span>
              </div>
              <div class="detail-prop">
                <span class="prop-label">Created</span>
                <span class="prop-value">{{ requestStore.currentRequest.created_at }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'
import AppLayout from '@/components/layout/AppLayout.vue'
import StatusBadge from '@/components/shared/StatusBadge.vue'
import PriorityBadge from '@/components/shared/PriorityBadge.vue'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import FormSelect from '@/components/shared/FormSelect.vue'
import FormTextarea from '@/components/shared/FormTextarea.vue'

const route = useRoute()
const requestStore = useSupportRequestStore()
const teamMemberStore = useTeamMemberStore()
const toastStore = useToastStore()

const requestId = computed(() => route.params.id)

const commentForm = ref({ author_name: '', body: '' })
const commentErrors = ref({ author_name: '', body: '' })
const submitting = ref(false)

const memberOptions = computed(() =>
  teamMemberStore.members.map(m => ({ value: m.name, label: m.name }))
)

async function submitComment() {
  commentErrors.value = { author_name: '', body: '' }
  let hasError = false

  if (!commentForm.value.author_name) {
    commentErrors.value.author_name = 'Please select your name'
    hasError = true
  }
  if (!commentForm.value.body || commentForm.value.body.length < 10) {
    commentErrors.value.body = 'Comment must be at least 10 characters'
    hasError = true
  }
  if (hasError) return

  submitting.value = true
  try {
    await requestStore.addComment(requestId.value, commentForm.value)
    commentForm.value = { author_name: '', body: '' }
    toastStore.success('Comment posted successfully')
  } catch {
    toastStore.error('Failed to post comment')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  requestStore.fetchRequest(requestId.value)
  teamMemberStore.fetchMembers()
})

watch(() => route.params.id, (newId) => {
  if (newId) requestStore.fetchRequest(newId)
})
</script>

<style scoped>
.detail-grid {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 24px;
  align-items: start;
}

.detail-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.detail-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.detail-id {
  font-size: 13px;
  color: #6B7280;
  font-weight: 600;
}

.detail-title {
  margin: 0 0 12px;
  font-size: 20px;
  font-weight: 700;
  color: #111827;
}

.detail-description {
  margin: 0;
  font-size: 14px;
  color: #4B5563;
  line-height: 1.6;
  white-space: pre-wrap;
}

.detail-section-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 600;
  color: #111827;
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 24px;
}

.comment {
  padding: 12px;
  background: #F9FAFB;
  border-radius: 8px;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.comment-author {
  font-size: 13px;
  font-weight: 600;
  color: #111827;
}

.comment-date {
  font-size: 12px;
  color: #9CA3AF;
}

.comment-body {
  margin: 0;
  font-size: 14px;
  color: #374151;
  line-height: 1.5;
  white-space: pre-wrap;
}

.comment-form {
  border-top: 1px solid #E5E7EB;
  padding-top: 16px;
}

.comment-form-title {
  margin: 0 0 12px;
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}

.detail-props {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.detail-prop {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 12px;
  border-bottom: 1px solid #F3F4F6;
}

.detail-prop:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.prop-label {
  font-size: 13px;
  color: #6B7280;
}

.prop-value {
  font-size: 14px;
  font-weight: 500;
  color: #111827;
}

.prop-value--overdue {
  color: #DC2626;
  font-weight: 600;
}

.empty-state {
  padding: 16px;
  text-align: center;
  color: #9CA3AF;
  font-size: 14px;
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
