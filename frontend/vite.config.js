import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,  // Vue dev server port
    proxy: {
      // Forward all requests starting with /api to the Rails backend.
      //
      // How it works:
      // 1. Vue makes a request to http://localhost:5173/api/v1/team_members
      // 2. Vite intercepts it (because it starts with /api)
      // 3. Vite forwards it to http://localhost:3000/api/v1/team_members
      // 4. Rails processes the request and responds
      // 5. Vite passes the response back to Vue
      //
      // This way, the frontend code doesn't need to know the backend URL.
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true  // Changes the Origin header to match the target
      }
    }
  }
})
