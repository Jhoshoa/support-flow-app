# SupportFlow — Error Handling Standard

> This document defines the consistent error response format and implementation pattern for all API endpoints. Every controller must follow this standard.

---

## Error Response Format

All error responses MUST follow this JSON structure:

```json
{
  "error": "Error category",
  "details": ["Specific error message 1", "Specific error message 2"]
}
```

### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `error` | String | Yes | Human-readable error category (e.g., "Validation failed", "Not found") |
| `details` | Array[String] | Yes | Specific error messages. Always an array, even for single errors. |

---

## HTTP Status Codes

| Status | Meaning | When to Use |
|--------|---------|-------------|
| 200 OK | Success | GET, PATCH successful |
| 201 Created | Resource created | POST successful |
| 204 No Content | Empty response | DELETE successful (not used in this challenge) |
| 404 Not Found | Resource missing | Record not found by ID |
| 422 Unprocessable Entity | Validation/business rule failed | Invalid data, business rule violation |
| 500 Internal Server Error | Unexpected error | Unhandled exceptions (should be rare) |

---

## Implementation

### 1. Application Controller Base

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error

  private

  def render_not_found(exception)
    render json: {
      error: 'Not found',
      details: [exception.message]
    }, status: :not_found
  end

  def render_validation_error(exception)
    render json: {
      error: 'Validation failed',
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def render_error(message, details = [], status: :unprocessable_entity)
    render json: {
      error: message,
      details: Array(details)
    }, status: status
  end
end
```

### 2. Custom Business Rule Errors

For business rules that aren't standard ActiveRecord validations, use `render_error`:

```ruby
# app/controllers/api/v1/support_requests_controller.rb
module Api
  module V1
    class SupportRequestsController < ApplicationController
      def update
        support_request = SupportRequest.find(params[:id])

        if support_request.closed? && !comment_only_update?
          render_error('Business rule violation', ['A closed request cannot be edited'])
          return
        end

        if support_request.update(support_request_params)
          render json: serialize_request(support_request)
        else
          render_error('Validation failed', support_request.errors.full_messages)
        end
      end

      private

      def comment_only_update?
        # Check if only comments are being added (not implemented in update)
        # Comments are created via separate endpoint, so this is always false here
        false
      end
    end
  end
end
```

### 3. Model-Level Business Rules (Preferred)

Business rules should primarily live in the model:

```ruby
# app/models/support_request.rb
class SupportRequest < ApplicationRecord
  validate :closed_cannot_be_edited, on: :update

  private

  def closed_cannot_be_edited
    return unless closed? && changed?
    return if changes.keys == ['updated_at']

    errors.add(:base, 'A closed request cannot be edited')
  end
end
```

This automatically triggers the standard validation error response:
```json
{
  "error": "Validation failed",
  "details": ["A closed request cannot be edited"]
}
```

---

## Error Scenarios by Endpoint

### Team Members

| Scenario | Status | Response |
|----------|--------|----------|
| GET /team_members (empty) | 200 | `{ team_members: [] }` |
| POST valid | 201 | Member object |
| POST invalid (missing name) | 422 | `{ error: "Validation failed", details: ["Name can't be blank"] }` |
| POST duplicate email | 422 | `{ error: "Validation failed", details: ["Email has already been taken"] }` |
| PATCH valid | 200 | Updated member |
| PATCH non-existent ID | 404 | `{ error: "Not found", details: ["Couldn't find TeamMember with 'id'=999"] }` |
| PATCH invalid email | 422 | `{ error: "Validation failed", details: ["Email is invalid"] }` |

### Support Requests

| Scenario | Status | Response |
|----------|--------|----------|
| GET /support_requests | 200 | `{ support_requests: [...] }` |
| GET with filters (no matches) | 200 | `{ support_requests: [] }` |
| GET /support_requests/:id | 200 | Request object with comments |
| GET /support_requests/:id (not found) | 404 | `{ error: "Not found", details: [...] }` |
| POST valid | 201 | Request object |
| POST invalid (missing title) | 422 | `{ error: "Validation failed", details: ["Title can't be blank"] }` |
| POST with inactive member | 422 | `{ error: "Validation failed", details: ["Team member must be active"] }` |
| PATCH valid | 200 | Updated request |
| PATCH to resolved | 200 | Request with completed_at set |
| PATCH closed → open | 422 | `{ error: "Validation failed", details: ["A closed request cannot be reopened"] }` |
| PATCH edit closed request | 422 | `{ error: "Validation failed", details: ["A closed request cannot be edited"] }` |

### Comments

| Scenario | Status | Response |
|----------|--------|----------|
| POST valid | 201 | Comment object |
| POST body < 10 chars | 422 | `{ error: "Validation failed", details: ["Body is too short (minimum is 10 characters)"] }` |
| POST missing author_name | 422 | `{ error: "Validation failed", details: ["Author name can't be blank"] }` |
| POST to non-existent request | 404 | `{ error: "Not found", details: ["Couldn't find SupportRequest with 'id'=999"] }` |
| POST to closed request | 201 | Comment object (allowed!) |

### Dashboard

| Scenario | Status | Response |
|----------|--------|----------|
| GET /dashboard | 200 | Metrics object |
| Any error | 500 | `{ error: "Internal server error", details: [...] }` |

---

## Frontend Error Handling

The API client should normalize all errors:

```javascript
// src/api/client.js
apiClient.interceptors.response.use(
  response => response,
  error => {
    const status = error.response?.status || 500
    const data = error.response?.data || {}

    const normalizedError = {
      status,
      message: data.error || 'An unexpected error occurred',
      details: data.details || [],
      isValidationError: status === 422,
      isNotFound: status === 404
    }

    return Promise.reject(normalizedError)
  }
)
```

Vue components should handle errors:

```vue
<template>
  <div>
    <ErrorMessage
      v-if="error"
      :title="error.message"
      :details="error.details"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiClient from '@/api/client.js'

const error = ref(null)

async function createRequest(data) {
  error.value = null
  try {
    await apiClient.post('/support_requests', { support_request: data })
  } catch (err) {
    error.value = err
  }
}
</script>
```

---

## Testing Error Responses

### Request Spec Pattern

```ruby
# spec/requests/support_requests_spec.rb
RSpec.describe 'Support Requests API', type: :request do
  describe 'error handling' do
    it 'returns 404 for non-existent request' do
      get '/api/v1/support_requests/999'
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Not found')
      expect(json['details']).to be_an(Array)
    end

    it 'returns 422 with validation details for invalid creation' do
      post '/api/v1/support_requests', params: { support_request: { title: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
      expect(json['details']).to include("Title can't be blank")
    end

    it 'returns 422 for inactive team member assignment' do
      inactive = create(:team_member, active: false)
      post '/api/v1/support_requests', params: {
        support_request: {
          title: 'Test',
          description: 'Test desc',
          team_member_id: inactive.id
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['details']).to include('Team member must be active')
    end

    it 'returns 422 when trying to reopen closed request' do
      request = create(:support_request, status: :closed)
      patch "/api/v1/support_requests/#{request.id}", params: {
        support_request: { status: 'open' }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['details']).to include('A closed request cannot be reopened')
    end
  end
end
```

---

## Validation Checklist

Before marking an endpoint as complete, verify:

- [ ] Happy path returns correct 200/201 status
- [ ] Missing resource returns 404 with `error` and `details`
- [ ] Validation failure returns 422 with `error: "Validation failed"` and array of messages
- [ ] Business rule violation returns 422 with descriptive message
- [ ] Response always includes both `error` and `details` fields
- [ ] `details` is always an array (even for single errors)
- [ ] Frontend can parse and display all error types