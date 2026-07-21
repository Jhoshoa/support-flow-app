# Be sure to restart your server when you modify this file.

# CORS (Cross-Origin Resource Sharing) Configuration
#
# Problem: The Vue frontend runs on http://localhost:5173 and the Rails backend
# runs on http://localhost:3000. Browsers block requests between different origins
# (ports count as different origins) by default.
#
# Solution: This middleware adds headers to Rails responses that tell the browser
# "it's okay to accept responses from this server when requested from localhost:5173".
#
# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from the Vue dev server.
    # In production, change this to your actual domain.
    origins ENV.fetch("FRONTEND_URL") { "http://localhost:5173" }

    resource "*",
      headers: :any,        # Allow any headers (Content-Type, Accept, etc.)
      methods: [:get, :post, :put, :patch, :delete, :options, :head]  # Allow these HTTP methods
  end
end
