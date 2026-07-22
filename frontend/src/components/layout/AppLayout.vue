<template>
  <div class="layout">
    <AppSidebar />
    <div class="layout-main">
      <AppTopBar :title="title">
        <slot name="topbar" />
      </AppTopBar>
      <main class="layout-content">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup>
import AppSidebar from './AppSidebar.vue'
import AppTopBar from './AppTopBar.vue'

defineProps({
  title: { type: String, default: '' }
})
</script>

<style scoped>
.layout {
  display: flex;
  min-height: 100vh;
  background: #F8FAFC;
}

.layout-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.layout-content {
  flex: 1;
  padding: 24px 32px;
  overflow-y: auto;
}
</style>
