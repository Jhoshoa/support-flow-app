<template>
  <header class="topbar">
    <div class="topbar-left">
      <h2 class="topbar-title">{{ title }}</h2>
    </div>
    <div class="topbar-right">
      <slot />
    </div>
  </header>
</template>

<script setup>
defineProps({
  title: { type: String, default: '' }
})
</script>

<style scoped>
.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  height: 64px;
  background: white;
  border-bottom: 1px solid #E5E7EB;
}

.topbar-title {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: #111827;
}
</style>
