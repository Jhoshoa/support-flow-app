<template>
  <aside class="sidebar">
    <div class="sidebar-logo">
      <span class="sidebar-logo-icon">&#9881;</span>
      <span class="sidebar-logo-text">SupportFlow</span>
    </div>
    <nav class="sidebar-nav">
      <RouterLink to="/" class="sidebar-link" :class="{ 'sidebar-link--active': $route.path === '/' }">
        <span class="sidebar-link-icon">&#9632;</span>
        Dashboard
      </RouterLink>
      <RouterLink to="/requests" class="sidebar-link" :class="{ 'sidebar-link--active': $route.path.startsWith('/requests') }">
        <span class="sidebar-link-icon">&#9998;</span>
        Requests
      </RouterLink>
      <RouterLink to="/members" class="sidebar-link" :class="{ 'sidebar-link--active': $route.path === '/members' }">
        <span class="sidebar-link-icon">&#9787;</span>
        Team
      </RouterLink>
    </nav>
  </aside>
</template>

<style scoped>
.sidebar {
  width: 240px;
  background: #1E293B;
  color: white;
  min-height: 100vh;
  padding: 24px 0;
  flex-shrink: 0;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 20px 24px;
  border-bottom: 1px solid #334155;
  margin-bottom: 8px;
}

.sidebar-logo-icon {
  font-size: 24px;
}

.sidebar-logo-text {
  font-size: 18px;
  font-weight: 700;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  padding: 0 12px;
}

.sidebar-link {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 8px;
  text-decoration: none;
  color: #94A3B8;
  font-size: 14px;
  font-weight: 500;
  transition: background 150ms, color 150ms;
}

.sidebar-link:hover {
  background: rgba(255,255,255,0.1);
  color: white;
}

.sidebar-link--active {
  background: #2563EB;
  color: white;
}

.sidebar-link-icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
}
</style>
