# SupportFlow — Frontend UI/UX Specification

> This document defines the visual design system, interaction patterns, loading states, notifications, modals, side panels, and layout architecture for the Vue frontend. It serves as the single source of truth for all UI decisions.

---

## 1. Design System

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `--color-primary` | `#2563EB` | Primary buttons, active states, links |
| `--color-primary-dark` | `#1D4ED8` | Primary hover |
| `--color-success` | `#10B981` | Resolved status, success toasts |
| `--color-warning` | `#F59E0B` | High priority, warning toasts |
| `--color-danger` | `#EF4444` | Critical priority, errors, overdue |
| `--color-info` | `#3B82F6` | Info toasts, in-progress status |
| `--color-gray-50` | `#F9FAFB` | Page background |
| `--color-gray-100` | `#F3F4F6` | Card backgrounds, skeleton base |
| `--color-gray-200` | `#E5E7EB` | Borders, dividers |
| `--color-gray-300` | `#D1D5DB` | Disabled states |
| `--color-gray-500` | `#6B7280` | Secondary text |
| `--color-gray-700` | `#374151` | Primary text |
| `--color-gray-900` | `#111827` | Headings |
| `--color-white` | `#FFFFFF` | Card surfaces |

### Typography

| Element | Font | Size | Weight | Color |
|---------|------|------|--------|-------|
| Page Title | System UI / Inter | 24px | 700 | `--color-gray-900` |
| Section Title | System UI / Inter | 18px | 600 | `--color-gray-700` |
| Card Title | System UI / Inter | 16px | 600 | `--color-gray-700` |
| Body | System UI / Inter | 14px | 400 | `--color-gray-700` |
| Caption | System UI / Inter | 12px | 400 | `--color-gray-500` |
| Status Badge | System UI / Inter | 12px | 600 | varies |

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight gaps |
| `--space-2` | 8px | Inline spacing |
| `--space-3` | 12px | Component padding |
| `--space-4` | 16px | Card padding |
| `--space-5` | 20px | Section gaps |
| `--space-6` | 24px | Page padding |
| `--space-8` | 32px | Large sections |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `--radius-sm` | 4px | Buttons, badges |
| `--radius-md` | 8px | Cards, inputs |
| `--radius-lg` | 12px | Modals, panels |
| `--radius-full` | 9999px | Pills, avatars |

### Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Cards |
| `--shadow-md` | `0 4px 6px rgba(0,0,0,0.07)` | Hover cards |
| `--shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Modals, panels |

---

## 2. Layout Architecture

### App Shell

```
┌─────────────────────────────────────────────────────────────┐
│  Sidebar (200px)  │  Main Content Area (flex: 1)            │
│                   │                                          │
│  [Logo]           │  ┌─────────────────────────────────────┐ │
│                   │  │  Top Bar (56px)                     │ │
│  Dashboard        │  │  [Breadcrumbs]    [Page Title]        │ │
│  Requests       │  └─────────────────────────────────────┘ │
│  Team Members   │                                          │
│                   │  ┌─────────────────────────────────────┐ │
│  ─────────────  │  │                                     │ │
│                   │  │  Page Content                       │ │
│  [User Avatar]  │  │                                     │ │
│  Engineer Name    │  │                                     │ │
│                   │  │                                     │ │
└───────────────────┘  └─────────────────────────────────────┘
```

### Sidebar Navigation

```vue
<!-- components/layout/AppSidebar.vue -->
<template>
  <aside class="sidebar">
    <div class="sidebar-logo">
      <span class="logo-icon">🔧</span>
      <span class="logo-text">SupportFlow</span>
    </div>

    <nav class="sidebar-nav">
      <RouterLink to="/" class="nav-item" exact-active-class="active">
        <span class="nav-icon">📊</span>
        <span class="nav-label">Dashboard</span>
      </RouterLink>
      <RouterLink to="/requests" class="nav-item" active-class="active">
        <span class="nav-icon">🎫</span>
        <span class="nav-label">Requests</span>
        <span v-if="overdueCount > 0" class="nav-badge">{{ overdueCount }}</span>
      </RouterLink>
      <RouterLink to="/members" class="nav-item" active-class="active">
        <span class="nav-icon">👥</span>
        <span class="nav-label">Team Members</span>
      </RouterLink>
    </nav>

    <div class="sidebar-footer">
      <div class="user-avatar">E1</div>
      <div class="user-info">
        <div class="user-name">Engineer 1</div>
        <div class="user-role">Developer</div>
      </div>
    </div>
  </aside>
</template>
```

**Sidebar Styles:**
- Width: 200px, fixed position
- Background: `--color-white`
- Border-right: 1px solid `--color-gray-200`
- Nav item height: 40px, padding: `--space-3` `--space-4`
- Active state: background `--color-primary` at 10% opacity, text `--color-primary`
- Hover: background `--color-gray-100`
- Transition: all 150ms ease

### Top Bar

```vue
<!-- components/layout/AppTopBar.vue -->
<template>
  <header class="top-bar">
    <div class="breadcrumbs">
      <span class="breadcrumb-item">SupportFlow</span>
      <span class="breadcrumb-separator">/</span>
      <span class="breadcrumb-item active">{{ pageTitle }}</span>
    </div>
    <div class="top-bar-actions">
      <button v-if="showCreateButton" class="btn btn-primary" @click="openCreatePanel">
        <span class="btn-icon">+</span>
        <span>New Request</span>
      </button>
    </div>
  </header>
</template>
```

---

## 3. Loading States — Skeleton Screens

### Principle

**Never show a blank page or a generic spinner.** Use skeleton screens that mimic the final layout to reduce perceived loading time.

### Skeleton Components

#### Dashboard Skeleton

```
┌─────────────────────────────────────────────────────────────┐
│  [Skeleton: Page Title]                                     │
│                                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ ████████ │ │ ████████ │ │ ████████ │ │ ████████ │      │
│  │ ████████ │ │ ████████ │ │ ████████ │ │ ████████ │      │
│  │ ████████ │ │ ████████ │ │ ████████ │ │ ████████ │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│                                                              │
│  ┌────────────────────────┐ ┌────────────────────────┐      │
│  │ ████████████████████   │ │ ████████████████████   │      │
│  │ ████████████████████   │ │ ████████████████████   │      │
│  │ ████████████████████   │ │ ████████████████████   │      │
│  │ ████████████████████   │ │ ████████████████████   │      │
│  │ ████████████████████   │ │ ████████████████████   │      │
│  └────────────────────────┘ └────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

#### Request List Skeleton

```
┌─────────────────────────────────────────────────────────────┐
│  [Skeleton: Filter Bar]                                       │
│  [Skeleton: Filter Bar]                                       │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ████████████  ████████████  ████████████  ████████  │   │
│  │ ████████████  ████████████  ████████████  ████████  │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ████████████  ████████████  ████████████  ████████  │   │
│  │ ████████████  ████████████  ████████████  ████████  │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ████████████  ████████████  ████████████  ████████  │   │
│  │ ████████████  ████████████  ████████████  ████████  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Skeleton Implementation

```vue
<!-- components/shared/SkeletonCard.vue -->
<template>
  <div class="skeleton-card">
    <div class="skeleton-header">
      <div class="skeleton-line skeleton-line--short"></div>
    </div>
    <div class="skeleton-body">
      <div class="skeleton-line"></div>
      <div class="skeleton-line skeleton-line--medium"></div>
    </div>
  </div>
</template>

<style scoped>
.skeleton-card {
  background: var(--color-white);
  border-radius: var(--radius-md);
  padding: var(--space-4);
  border: 1px solid var(--color-gray-200);
}

.skeleton-line {
  height: 16px;
  background: linear-gradient(
    90deg,
    var(--color-gray-100) 25%,
    var(--color-gray-200) 50%,
    var(--color-gray-100) 75%
  );
  background-size: 200% 100%;
  border-radius: var(--radius-sm);
  margin-bottom: var(--space-2);
  animation: shimmer 1.5s infinite;
}

.skeleton-line--short { width: 40%; }
.skeleton-line--medium { width: 70%; }
.skeleton-line--long { width: 100%; }

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
</style>
```

### Skeleton Usage Pattern

```vue
<!-- In any view -->
<template>
  <div>
    <!-- Show skeleton while loading -->
    <div v-if="loading" class="skeleton-grid">
      <SkeletonCard v-for="n in 5" :key="n" />
    </div>

    <!-- Show content when loaded -->
    <div v-else-if="data" class="content-grid">
      <RequestCard v-for="request in data" :key="request.id" :request="request" />
    </div>

    <!-- Show error if failed -->
    <ErrorMessage v-else-if="error" :message="error" />
  </div>
</template>
```

---

## 4. Toast Notifications

### Toast System

Use a lightweight toast system for user feedback. No heavy library needed — a simple Vue component + Pinia store is sufficient.

### Toast Store

```javascript
// stores/toastStore.js
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
```

### Toast Component

```vue
<!-- components/shared/ToastContainer.vue -->
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
          <button class="toast-close" @click="toastStore.remove(toast.id)">×</button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<script setup>
import { useToastStore } from '@/stores/toastStore'

const toastStore = useToastStore()

function iconFor(type) {
  const icons = { success: '✓', error: '✕', warning: '⚠', info: 'ℹ' }
  return icons[type] || 'ℹ'
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
  gap: var(--space-2);
}

.toast {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-md);
  background: var(--color-white);
  box-shadow: var(--shadow-lg);
  min-width: 300px;
  max-width: 400px;
}

.toast--success { border-left: 4px solid var(--color-success); }
.toast--error { border-left: 4px solid var(--color-danger); }
.toast--warning { border-left: 4px solid var(--color-warning); }
.toast--info { border-left: 4px solid var(--color-info); }

.toast-icon { font-size: 16px; }
.toast-message { flex: 1; font-size: 14px; }
.toast-close {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 18px;
  color: var(--color-gray-500);
}

/* Transitions */
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
```

### Toast Usage

```javascript
// In any component or store action
import { useToastStore } from '@/stores/toastStore'

const toast = useToastStore()

// After successful creation
toast.success('Support request created successfully')

// After error
toast.error('Failed to create request: Title is required')

// Warning
toast.warning('Request is overdue')
```

### Toast Scenarios

| Action | Toast Type | Message |
|--------|-----------|---------|
| Create request | success | "Support request created" |
| Update request | success | "Request updated" |
| Resolve request | success | "Request marked as resolved" |
| Add comment | success | "Comment added" |
| Create member | success | "Team member added" |
| Toggle member active | success | "Member activated/deactivated" |
| Validation error | error | "Failed to save: [field] is required" |
| API error (500) | error | "Something went wrong. Please try again." |
| Not found (404) | error | "Request not found" |
| Filter with no results | info | "No requests match your filters" |

---

## 5. Side Panel (Create / Edit)

### Pattern

Use a **slide-in side panel** (not a centered modal) for create/edit operations. This preserves context and feels more modern.

### Side Panel Component

```vue
<!-- components/shared/SidePanel.vue -->
<template>
  <Teleport to="body">
    <Transition name="panel">
      <div v-if="isOpen" class="panel-overlay" @click="closeOnOverlay && close()">
        <div class="panel" @click.stop>
          <div class="panel-header">
            <h3 class="panel-title">{{ title }}</h3>
            <button class="panel-close" @click="close">×</button>
          </div>
          <div class="panel-body">
            <slot />
          </div>
          <div class="panel-footer">
            <slot name="footer">
              <button class="btn btn-secondary" @click="close">Cancel</button>
              <button class="btn btn-primary" @click="$emit('confirm')" :disabled="isSubmitting">
                {{ confirmText }}
              </button>
            </slot>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
defineProps({
  isOpen: Boolean,
  title: String,
  confirmText: { type: String, default: 'Save' },
  closeOnOverlay: { type: Boolean, default: true },
  isSubmitting: { type: Boolean, default: false }
})

defineEmits(['close', 'confirm'])

function close() {
  emit('close')
}
</script>

<style scoped>
.panel-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1000;
  display: flex;
  justify-content: flex-end;
}

.panel {
  width: 480px;
  max-width: 90vw;
  height: 100vh;
  background: var(--color-white);
  box-shadow: var(--shadow-lg);
  display: flex;
  flex-direction: column;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--space-4) var(--space-5);
  border-bottom: 1px solid var(--color-gray-200);
}

.panel-title { font-size: 18px; font-weight: 600; }

.panel-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--color-gray-500);
}

.panel-body {
  flex: 1;
  padding: var(--space-5);
  overflow-y: auto;
}

.panel-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
  padding: var(--space-4) var(--space-5);
  border-top: 1px solid var(--color-gray-200);
}

/* Transitions */
.panel-enter-active,
.panel-leave-active { transition: all 300ms ease; }

.panel-enter-from,
.panel-leave-to {
  opacity: 0;
}

.panel-enter-from .panel,
.panel-leave-to .panel {
  transform: translateX(100%);
}
</style>
```

### Side Panel Usage — Create Request

```vue
<!-- SupportRequestList.vue -->
<template>
  <div>
    <button class="btn btn-primary" @click="showCreatePanel = true">
      + New Request
    </button>

    <SidePanel
      :is-open="showCreatePanel"
      title="New Support Request"
      confirm-text="Create Request"
      :is-submitting="isSubmitting"
      @close="showCreatePanel = false"
      @confirm="handleCreate"
    >
      <SupportRequestForm v-model="newRequest" :errors="formErrors" />
    </SidePanel>
  </div>
</template>
```

### Side Panel Usage — Edit Request

```vue
<!-- SupportRequestDetail.vue -->
<template>
  <div>
    <button class="btn btn-secondary" @click="showEditPanel = true">
      Edit
    </button>

    <SidePanel
      :is-open="showEditPanel"
      title="Edit Support Request"
      confirm-text="Update"
      :is-submitting="isSubmitting"
      @close="showEditPanel = false"
      @confirm="handleUpdate"
    >
      <SupportRequestForm v-model="editableRequest" :errors="formErrors" />
    </SidePanel>
  </div>
</template>
```

### Side Panel for Team Members

Same pattern, different form:
- **Create Member:** "New Team Member" panel with name, email, role fields
- **Edit Member:** "Edit Team Member" panel (mainly for activate/deactivate toggle)

---

## 6. Modals (Confirmation Only)

### When to Use Modals vs Side Panels

| Pattern | Use For | Example |
|---------|---------|---------|
| **Side Panel** | Create, Edit, Forms | New request, Edit request, New member |
| **Modal** | Confirmations, Alerts | Delete confirmation, Unsaved changes warning |

### Confirmation Modal

```vue
<!-- components/shared/ConfirmModal.vue -->
<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="isOpen" class="modal-overlay" @click="closeOnOverlay && close()">
        <div class="modal" @click.stop>
          <div class="modal-icon" :class="`modal-icon--${type}`">
            {{ icon }}
          </div>
          <h3 class="modal-title">{{ title }}</h3>
          <p class="modal-message">{{ message }}</p>
          <div class="modal-actions">
            <button class="btn btn-secondary" @click="close">{{ cancelText }}</button>
            <button class="btn" :class="`btn-${confirmButtonType}`" @click="confirm">
              {{ confirmText }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
const props = defineProps({
  isOpen: Boolean,
  title: String,
  message: String,
  type: { type: String, default: 'warning' }, // warning, danger, info
  confirmText: { type: String, default: 'Confirm' },
  cancelText: { type: String, default: 'Cancel' },
  closeOnOverlay: { type: Boolean, default: true }
})

const emit = defineEmits(['close', 'confirm'])

const icon = computed(() => {
  const icons = { warning: '⚠', danger: '✕', info: 'ℹ' }
  return icons[props.type]
})

const confirmButtonType = computed(() => {
  return props.type === 'danger' ? 'danger' : 'primary'
})

function close() { emit('close') }
function confirm() { emit('confirm'); close() }
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal {
  background: var(--color-white);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
  width: 400px;
  max-width: 90vw;
  text-align: center;
  box-shadow: var(--shadow-lg);
}

.modal-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto var(--space-4);
  font-size: 24px;
}

.modal-icon--warning { background: #FEF3C7; color: var(--color-warning); }
.modal-icon--danger { background: #FEE2E2; color: var(--color-danger); }
.modal-icon--info { background: #DBEAFE; color: var(--color-info); }

.modal-title { font-size: 18px; font-weight: 600; margin-bottom: var(--space-2); }
.modal-message { color: var(--color-gray-500); margin-bottom: var(--space-5); }

.modal-actions {
  display: flex;
  gap: var(--space-3);
  justify-content: center;
}

/* Transitions */
.modal-enter-active, .modal-leave-active { transition: all 200ms ease; }
.modal-enter-from, .modal-leave-to { opacity: 0; transform: scale(0.95); }
</style>
```

### Modal Scenarios

| Scenario | Type | Title | Message |
|----------|------|-------|---------|
| Deactivate member | warning | "Deactivate Member?" | "This member will no longer be assignable to new requests." |
| Reopen closed request | danger | "Cannot Reopen" | "Closed requests cannot be returned to open status." |
| Delete (if implemented) | danger | "Delete Request?" | "This action cannot be undone." |
| Unsaved changes | warning | "Unsaved Changes" | "You have unsaved changes. Are you sure you want to leave?" |

---

## 7. Status Badges & Visual Indicators

### Status Badge

```vue
<!-- components/shared/StatusBadge.vue -->
<template>
  <span class="badge" :class="`badge--${status}`">
    {{ label }}
  </span>
</template>

<script setup>
const props = defineProps({ status: String })

const labels = {
  open: 'Open',
  in_progress: 'In Progress',
  resolved: 'Resolved',
  closed: 'Closed'
}

const label = computed(() => labels[props.status] || props.status)
</script>

<style scoped>
.badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: var(--radius-full);
  font-size: 12px;
  font-weight: 600;
  text-transform: capitalize;
}

.badge--open { background: #DBEAFE; color: #1E40AF; }
.badge--in_progress { background: #FEF3C7; color: #92400E; }
.badge--resolved { background: #D1FAE5; color: #065F46; }
.badge--closed { background: #F3F4F6; color: #374151; }
</style>
```

### Priority Badge

```vue
<!-- components/shared/PriorityBadge.vue -->
<template>
  <span class="badge" :class="`badge--${priority}`">
    {{ label }}
  </span>
</template>

<script setup>
const props = defineProps({ priority: String })

const labels = {
  low: 'Low',
  medium: 'Medium',
  high: 'High',
  critical: 'Critical'
}

const label = computed(() => labels[props.priority] || props.priority)
</script>

<style scoped>
.badge--low { background: #F3F4F6; color: #6B7280; }
.badge--medium { background: #DBEAFE; color: #1E40AF; }
.badge--high { background: #FEF3C7; color: #92400E; }
.badge--critical { background: #FEE2E2; color: #991B1B; }
</style>
```

### Overdue Indicator

```vue
<!-- components/shared/OverdueBadge.vue -->
<template>
  <span v-if="isOverdue" class="overdue-badge">
    ⚠ Overdue
  </span>
</template>

<style scoped>
.overdue-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 8px;
  background: #FEE2E2;
  color: #991B1B;
  border-radius: var(--radius-full);
  font-size: 11px;
  font-weight: 600;
}
</style>
```

---

## 8. Page Specifications

### Dashboard Page

```
┌─────────────────────────────────────────────────────────────┐
│  Dashboard                                    [New Request] │
│                                                              │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌──────────┐│
│  │  24        │ │  3         │ │  4         │ │  8       ││
│  │ Total      │ │ Overdue    │ │ Unassigned │ │ Open     ││
│  │ Requests   │ │ Requests   │ │ Requests   │ │          ││
│  └────────────┘ └────────────┘ └────────────┘ └──────────┘│
│                                                              │
│  ┌────────────────────────┐ ┌────────────────────────┐     │
│  │  Requests by Status    │ │  Requests by Priority  │     │
│  │                        │ │                        │     │
│  │  ████████████ Open 8   │ │  ████████████ Low 4    │     │
│  │  ██████████   In Prog 7│ │  ██████████████████ Med│     │
│  │  ████████     Resolved6│ │  ██████████████ High 7 │     │
│  │  ████         Closed 3 │ │  ██████       Critical3│     │
│  └────────────────────────┘ └────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

**Components:**
- `MetricCard` (×4): Total, Overdue, Unassigned, Open
- `StatusChart` (bar chart or simple bars)
- `PriorityChart` (bar chart or simple bars)

**Loading:** 4 skeleton cards + 2 skeleton chart areas

---

### Request List Page

```
┌─────────────────────────────────────────────────────────────┐
│  Support Requests                             [New Request] │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ [Status ▼] [Priority ▼] [Member ▼] [🔍 Search...] │   │
│  │ [☐ Overdue] [☐ Unassigned]        [Clear Filters] │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ⚠ Database timeout        High    In Progress  Alice │   │
│  │    Due: Jan 25                              [View →] │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Login page broken         Critical  Open       —     │   │
│  │ ⚠ Overdue — Due: Jan 18                     [View →] │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ API rate limiting         Medium  Resolved   Bob   │   │
│  │    Completed: Jan 20                        [View →] │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Components:**
- `FilterBar`: Status select, Priority select, Member select, Search input, Overdue checkbox, Unassigned checkbox, Clear button
- `RequestCard`: Title, priority badge, status badge, assignee name or "—", due date, overdue badge, view link

**Loading:** FilterBar skeleton + 5 request card skeletons

---

### Request Detail Page

```
┌─────────────────────────────────────────────────────────────┐
│  ← Back to Requests                           [Edit] [Resolve]│
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Database connection timeout              High  In Prog│   │
│  │                                                        │   │
│  │ Assigned to: Alice Johnson    Due: Jan 25, 2024      │   │
│  │ Created: Jan 20, 2024                               │   │
│  │                                                        │   │
│  │ Description:                                           │   │
│  │ Users reporting timeouts when accessing the dashboard    │   │
│  │ after the latest deployment. The issue appears to be   │   │
│  │ related to connection pool exhaustion.                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Comments (3)                                    [Add +]   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Alice Johnson — Jan 20, 09:00                        │   │
│  │ I checked the logs and found connection pool spikes   │   │
│  │ during peak hours.                                    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Bob Smith — Jan 20, 11:30                            │   │
│  │ The issue seems to be related to the new query in     │   │
│  │ the reports module.                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Components:**
- `RequestInfoCard`: Title, badges, metadata grid
- `CommentList`: Comment items with author, timestamp, body
- `CommentForm`: Textarea (min 10 chars), author name input, submit button
- Action buttons: Edit (opens side panel), Resolve (changes status), Close (if open/in_progress)

**Loading:** Skeleton info card + skeleton comments

---

### Team Members Page

```
┌─────────────────────────────────────────────────────────────┐
│  Team Members                                  [Add Member]│
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Name              Email              Role    Status  │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Alice Johnson     alice@co.com      Dev     ● Active │   │
│  │ Bob Smith         bob@co.com        QA      ○ Inact  │   │
│  │ Charlie Brown     charlie@co.com    Support ● Active │   │
│  │ Diana Prince      diana@co.com      Dev     ● Active │   │
│  │ Evan Wright       evan@co.com       QA      ● Active │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Components:**
- `TeamMemberTable`: Name, email, role badge, status toggle switch
- `TeamMemberForm` (in side panel): Name input, email input, role select

**Loading:** Table skeleton (5 rows)

---

## 9. Form Patterns

### Form Input

```vue
<!-- components/shared/FormInput.vue -->
<template>
  <div class="form-group">
    <label v-if="label" class="form-label">{{ label }}</label>
    <input
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :class="['form-input', { 'form-input--error': error }]"
      @input="$emit('update:modelValue', $event.target.value)"
    />
    <span v-if="error" class="form-error">{{ error }}</span>
  </div>
</template>

<style scoped>
.form-group { margin-bottom: var(--space-4); }
.form-label {
  display: block;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-700);
  margin-bottom: var(--space-1);
}
.form-input {
  width: 100%;
  padding: var(--space-2) var(--space-3);
  border: 1px solid var(--color-gray-200);
  border-radius: var(--radius-md);
  font-size: 14px;
  transition: border-color 150ms;
}
.form-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}
.form-input--error { border-color: var(--color-danger); }
.form-error {
  font-size: 12px;
  color: var(--color-danger);
  margin-top: var(--space-1);
}
</style>
```

### Form Select

```vue
<!-- components/shared/FormSelect.vue -->
<template>
  <div class="form-group">
    <label v-if="label" class="form-label">{{ label }}</label>
    <select
      :value="modelValue"
      :class="['form-input', { 'form-input--error': error }]"
      @change="$emit('update:modelValue', $event.target.value)"
    >
      <option value="">{{ placeholder }}</option>
      <option v-for="option in options" :key="option.value" :value="option.value">
        {{ option.label }}
      </option>
    </select>
    <span v-if="error" class="form-error">{{ error }}</span>
  </div>
</template>
```

### Form Validation Display

When backend returns 422, display errors next to fields:

```vue
<SupportRequestForm>
  <FormInput
    v-model="form.title"
    label="Title"
    :error="errors.title?.[0]"
  />
  <FormTextarea
    v-model="form.description"
    label="Description"
    :error="errors.description?.[0]"
  />
  <FormSelect
    v-model="form.priority"
    label="Priority"
    :options="priorityOptions"
    :error="errors.priority?.[0]"
  />
</SupportRequestForm>
```

---

## 10. Responsive Behavior

### Breakpoints

| Breakpoint | Width | Layout Change |
|------------|-------|---------------|
| Mobile | < 768px | Sidebar collapses to hamburger menu, cards stack vertically |
| Tablet | 768px - 1024px | Sidebar narrows to icons only, 2-column grids |
| Desktop | > 1024px | Full sidebar, 4-column metric cards, full tables |

### Mobile Sidebar

```
┌─────────────────────────────────┐
│ ≡  SupportFlow        [+ New] │  ← Hamburger + top actions
├─────────────────────────────────┤
│                                 │
│  [Content]                      │
│                                 │
└─────────────────────────────────┘

[Drawer opens from left when ≡ clicked]
┌────┬────────────────────────────┐
│ Nav│                            │
│    │                            │
│Dash│                            │
│Req │                            │
│Mem │                            │
└────┴────────────────────────────┘
```

> **Note:** Responsive design is optional for the challenge. Focus on desktop first, add mobile if time permits.

---

## 11. Animation & Micro-interactions

### Standard Transitions

| Element | Duration | Easing | Property |
|---------|----------|--------|----------|
| Button hover | 150ms | ease | background, transform |
| Card hover | 200ms | ease | box-shadow, transform |
| Side panel | 300ms | ease | transform |
| Modal | 200ms | ease | opacity, transform |
| Toast | 300ms | ease | opacity, transform |
| Skeleton shimmer | 1.5s | linear | background-position |
| Page fade | 200ms | ease | opacity |

### Button Hover

```css
.btn {
  transition: all 150ms ease;
}
.btn:hover {
  transform: translateY(-1px);
}
.btn:active {
  transform: translateY(0);
}
```

### Card Hover

```css
.card {
  transition: box-shadow 200ms ease, transform 200ms ease;
}
.card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}
```

---

## 12. Component Inventory

### Layout Components

| Component | File | Used By |
|-----------|------|---------|
| `AppLayout` | `layout/AppLayout.vue` | Root |
| `AppSidebar` | `layout/AppSidebar.vue` | AppLayout |
| `AppTopBar` | `layout/AppTopBar.vue` | AppLayout |

### Shared Components

| Component | File | Used By |
|-----------|------|---------|
| `SkeletonCard` | `shared/SkeletonCard.vue` | All pages |
| `SkeletonLine` | `shared/SkeletonLine.vue` | SkeletonCard |
| `ToastContainer` | `shared/ToastContainer.vue` | AppLayout |
| `SidePanel` | `shared/SidePanel.vue` | List, Detail pages |
| `ConfirmModal` | `shared/ConfirmModal.vue` | Members, Detail |
| `StatusBadge` | `shared/StatusBadge.vue` | List, Detail |
| `PriorityBadge` | `shared/PriorityBadge.vue` | List, Detail |
| `OverdueBadge` | `shared/OverdueBadge.vue` | List |
| `FormInput` | `shared/FormInput.vue` | All forms |
| `FormTextarea` | `shared/FormTextarea.vue` | Request form, Comment form |
| `FormSelect` | `shared/FormSelect.vue` | All forms |
| `LoadingSpinner` | `shared/LoadingSpinner.vue` | Buttons, small areas |
| `ErrorMessage` | `shared/ErrorMessage.vue` | All pages |
| `EmptyState` | `shared/EmptyState.vue` | List (no results) |

### Page Components

| Component | File | Route |
|-----------|------|-------|
| `Dashboard` | `Dashboard.vue` | `/` |
| `SupportRequestList` | `SupportRequestList.vue` | `/requests` |
| `SupportRequestDetail` | `SupportRequestDetail.vue` | `/requests/:id` |
| `SupportRequestForm` | `SupportRequestForm.vue` | `/requests/new`, `/requests/:id/edit` |
| `TeamMemberList` | `TeamMemberList.vue` | `/members` |
| `TeamMemberForm` | `TeamMemberForm.vue` | Side panel |
| `CommentList` | `CommentList.vue` | Detail page |
| `CommentForm` | `CommentForm.vue` | Detail page |
| `FilterBar` | `FilterBar.vue` | List page |

---

## 13. State Management Summary

| Store | State | Actions | Used By |
|-------|-------|---------|---------|
| `dashboardStore` | metrics, loading, error | fetchMetrics | Dashboard |
| `supportRequestStore` | requests[], currentRequest, filters, loading, error | fetchRequests, fetchRequest, createRequest, updateRequest, addComment, setFilter, clearFilters | List, Detail, Form |
| `teamMemberStore` | members[], loading, error | fetchMembers, createMember, toggleActive | Members, Form (dropdown) |
| `toastStore` | toasts[] | success, error, warning, info, add, remove | All (via API client or components) |
| `uiStore` (optional) | sidePanelOpen, modalOpen, activePanel | openPanel, closePanel, openModal, closeModal | Layout, pages |

---

*This document serves as the visual and interaction specification for the SupportFlow frontend. All frontend engineers should reference this when implementing components.*