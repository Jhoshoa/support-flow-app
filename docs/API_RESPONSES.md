# SupportFlow — API Response Contract

> This document defines the exact JSON structure for every API endpoint. Backend and frontend engineers must agree on this contract before implementation begins.

## Base URL

```
http://localhost:3000/api/v1
```

## Headers

All requests should include:
```
Content-Type: application/json
Accept: application/json
```

---

## Team Members

### GET /api/v1/team_members

**Response 200 OK:**
```json
{
  "team_members": [
    {
      "id": 1,
      "name": "Alice Johnson",
      "email": "alice@company.com",
      "role": "developer",
      "active": true,
      "created_at": "2024-01-15T10:30:00.000Z",
      "updated_at": "2024-01-15T10:30:00.000Z"
    },
    {
      "id": 2,
      "name": "Bob Smith",
      "email": "bob@company.com",
      "role": "qa",
      "active": false,
      "created_at": "2024-01-15T10:30:00.000Z",
      "updated_at": "2024-01-20T14:00:00.000Z"
    }
  ]
}
```

### POST /api/v1/team_members

**Request Body:**
```json
{
  "team_member": {
    "name": "Charlie Brown",
    "email": "charlie@company.com",
    "role": "support"
  }
}
```

**Response 201 Created:**
```json
{
  "id": 3,
  "name": "Charlie Brown",
  "email": "charlie@company.com",
  "role": "support",
  "active": true,
  "created_at": "2024-01-21T09:00:00.000Z",
  "updated_at": "2024-01-21T09:00:00.000Z"
}
```

**Response 422 Unprocessable Entity:**
```json
{
  "error": "Validation failed",
  "details": ["Email has already been taken", "Name can't be blank"]
}
```

### PATCH /api/v1/team_members/:id

**Request Body (deactivate):**
```json
{
  "team_member": {
    "active": false
  }
}
```

**Response 200 OK:**
```json
{
  "id": 2,
  "name": "Bob Smith",
  "email": "bob@company.com",
  "role": "qa",
  "active": false,
  "created_at": "2024-01-15T10:30:00.000Z",
  "updated_at": "2024-01-21T09:15:00.000Z"
}
```

**Response 404 Not Found:**
```json
{
  "error": "Not found",
  "details": ["Team member not found"]
}
```

---

## Support Requests

### GET /api/v1/support_requests

**Query Parameters:**
- `status` — filter by status: `open`, `in_progress`, `resolved`, `closed`
- `priority` — filter by priority: `low`, `medium`, `high`, `critical`
- `team_member_id` — filter by assigned member
- `overdue` — `true` to show only overdue requests
- `unassigned` — `true` to show only unassigned requests
- `q` — text search by title (case-insensitive)

**Response 200 OK:**
```json
{
  "support_requests": [
    {
      "id": 1,
      "title": "Database connection timeout",
      "description": "Users reporting timeouts...",
      "status": "in_progress",
      "priority": "high",
      "due_date": "2024-01-25",
      "completed_at": null,
      "overdue": false,
      "team_member": {
        "id": 1,
        "name": "Alice Johnson"
      },
      "comments_count": 3,
      "created_at": "2024-01-20T08:00:00.000Z",
      "updated_at": "2024-01-20T14:00:00.000Z"
    },
    {
      "id": 2,
      "title": "Login page broken",
      "description": "Cannot access login...",
      "status": "open",
      "priority": "critical",
      "due_date": "2024-01-18",
      "completed_at": null,
      "overdue": true,
      "team_member": null,
      "comments_count": 0,
      "created_at": "2024-01-19T10:00:00.000Z",
      "updated_at": "2024-01-19T10:00:00.000Z"
    }
  ]
}
```

> **Note:** `team_member` is `null` when unassigned. `overdue` is a computed boolean.

### GET /api/v1/support_requests/:id

**Response 200 OK:**
```json
{
  "id": 1,
  "title": "Database connection timeout",
  "description": "Users reporting timeouts when accessing the dashboard...",
  "status": "in_progress",
  "priority": "high",
  "due_date": "2024-01-25",
  "completed_at": null,
  "overdue": false,
  "team_member": {
    "id": 1,
    "name": "Alice Johnson",
    "email": "alice@company.com",
    "role": "developer",
    "active": true
  },
  "comments": [
    {
      "id": 1,
      "body": "I checked the logs and found...",
      "author_name": "Alice Johnson",
      "created_at": "2024-01-20T09:00:00.000Z"
    },
    {
      "id": 2,
      "body": "The issue seems to be related to...",
      "author_name": "Bob Smith",
      "created_at": "2024-01-20T11:30:00.000Z"
    }
  ],
  "created_at": "2024-01-20T08:00:00.000Z",
  "updated_at": "2024-01-20T14:00:00.000Z"
}
```

**Response 404 Not Found:**
```json
{
  "error": "Not found",
  "details": ["Support request not found"]
}
```

### POST /api/v1/support_requests

**Request Body:**
```json
{
  "support_request": {
    "title": "New bug in production",
    "description": "Users cannot submit forms...",
    "priority": "high",
    "due_date": "2024-01-30",
    "team_member_id": 1
  }
}
```

> `team_member_id` is optional. `status` defaults to `open`.

**Response 201 Created:**
```json
{
  "id": 5,
  "title": "New bug in production",
  "description": "Users cannot submit forms...",
  "status": "open",
  "priority": "high",
  "due_date": "2024-01-30",
  "completed_at": null,
  "overdue": false,
  "team_member": {
    "id": 1,
    "name": "Alice Johnson"
  },
  "comments": [],
  "comments_count": 0,
  "created_at": "2024-01-21T09:00:00.000Z",
  "updated_at": "2024-01-21T09:00:00.000Z"
}
```

**Response 422 Unprocessable Entity (validation):**
```json
{
  "error": "Validation failed",
  "details": ["Title can't be blank", "Description can't be blank"]
}
```

**Response 422 Unprocessable Entity (business rule — inactive member):**
```json
{
  "error": "Validation failed",
  "details": ["Team member must be active"]
}
```

### PATCH /api/v1/support_requests/:id

**Request Body (resolve):**
```json
{
  "support_request": {
    "status": "resolved"
  }
}
```

**Response 200 OK:**
```json
{
  "id": 1,
  "title": "Database connection timeout",
  "status": "resolved",
  "priority": "high",
  "due_date": "2024-01-25",
  "completed_at": "2024-01-21T09:15:00.000Z",
  "overdue": false,
  "team_member": {
    "id": 1,
    "name": "Alice Johnson"
  },
  "comments_count": 3,
  "created_at": "2024-01-20T08:00:00.000Z",
  "updated_at": "2024-01-21T09:15:00.000Z"
}
```

**Response 422 (closed → open attempt):**
```json
{
  "error": "Validation failed",
  "details": ["A closed request cannot be reopened"]
}
```

**Response 422 (edit closed request):**
```json
{
  "error": "Validation failed",
  "details": ["A closed request cannot be edited"]
}
```

---

## Comments

### POST /api/v1/support_requests/:id/comments

**Request Body:**
```json
{
  "comment": {
    "body": "I have investigated the issue and found the root cause...",
    "author_name": "Alice Johnson"
  }
}
```

**Response 201 Created:**
```json
{
  "id": 5,
  "body": "I have investigated the issue and found the root cause...",
  "author_name": "Alice Johnson",
  "support_request_id": 1,
  "created_at": "2024-01-21T09:20:00.000Z"
}
```

**Response 422 (body too short):**
```json
{
  "error": "Validation failed",
  "details": ["Body is too short (minimum is 10 characters)"]
}
```

**Response 404 (support request not found):**
```json
{
  "error": "Not found",
  "details": ["Support request not found"]
}
```

> **Note:** Comments CAN be added to closed support requests. This is the ONLY operation allowed on closed requests.

---

## Dashboard

### GET /api/v1/dashboard

**Response 200 OK:**
```json
{
  "total_requests": 24,
  "overdue_requests": 3,
  "unassigned_requests": 4,
  "requests_by_status": {
    "open": 8,
    "in_progress": 7,
    "resolved": 6,
    "closed": 3
  },
  "requests_by_priority": {
    "low": 4,
    "medium": 10,
    "high": 7,
    "critical": 3
  }
}
```

> **Note:** Keys in `requests_by_status` and `requests_by_priority` are string representations of the enum values.

---

## Error Response Standard

All error responses follow this structure:

```json
{
  "error": "Error category",
  "details": ["Specific error message 1", "Specific error message 2"]
}
```

### Error Categories

| HTTP Status | Error String | When Used |
|-------------|-------------|-----------|
| 404 | `"Not found"` | Resource does not exist |
| 422 | `"Validation failed"` | ActiveRecord validation fails |
| 422 | `"Business rule violation"` | Custom business rule fails |
| 500 | `"Internal server error"` | Unexpected server error |

---

## Frontend Integration Map

| Vue View | API Endpoint(s) Used |
|----------|---------------------|
| `Dashboard.vue` | `GET /api/v1/dashboard` |
| `SupportRequestList.vue` | `GET /api/v1/support_requests?filters...` |
| `SupportRequestDetail.vue` | `GET /api/v1/support_requests/:id` |
| `SupportRequestForm.vue` (create) | `POST /api/v1/support_requests` |
| `SupportRequestForm.vue` (edit) | `PATCH /api/v1/support_requests/:id` |
| `CommentForm.vue` | `POST /api/v1/support_requests/:id/comments` |
| `TeamMemberList.vue` | `GET /api/v1/team_members` |
| `TeamMemberForm.vue` | `POST /api/v1/team_members` |
| `TeamMemberList.vue` (toggle) | `PATCH /api/v1/team_members/:id` |