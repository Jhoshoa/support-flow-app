# SupportFlow

Internal Support Request Management Application

## Overview

SupportFlow is an internal application for registering, assigning, prioritizing, and tracking technical support requests. It replaces scattered communication channels with a centralized system where ownership, priority, due dates, and workload are always visible.

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Backend | Ruby on Rails | 7.x (API mode) |
| Ruby | Ruby | 3.2.x |
| Frontend | Vue | 3.x |
| Build Tool | Vite | Latest |
| Database (Dev) | SQLite | 3.x |
| Database (Prod) | PostgreSQL | 14+ |
| Testing | RSpec + FactoryBot | Latest |
| State Management | Pinia | Latest |

## Prerequisites

- Ruby 3.2.x
- Node.js 18+
- SQLite3 (development)
- Bundler gem
- npm or yarn

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd support-flow
```

### 2. Backend setup

```bash
cd backend
bundle install
rails db:create db:migrate db:seed
```

### 3. Frontend setup

```bash
cd ../frontend
npm install
```

## Running the application

### Start the Rails API

```bash
cd backend
rails server
# API available at http://localhost:3000/api/v1
```

### Start the Vue frontend

```bash
cd frontend
npm run dev
# Frontend available at http://localhost:5173
```

## Environment Variables

Copy `.env.example` to `.env` in both backend and frontend directories:

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

## Running Tests

```bash
cd backend
bundle exec rspec
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/team_members` | List team members |
| POST | `/api/v1/team_members` | Create team member |
| PATCH | `/api/v1/team_members/:id` | Update team member |
| GET | `/api/v1/support_requests` | List support requests (with filters) |
| GET | `/api/v1/support_requests/:id` | Show support request details |
| POST | `/api/v1/support_requests` | Create support request |
| PATCH | `/api/v1/support_requests/:id` | Update support request |
| POST | `/api/v1/support_requests/:id/comments` | Add comment |
| GET | `/api/v1/dashboard` | Dashboard metrics |

## Architecture

```
support-flow/
├── backend/     # Rails 7 API
│   ├── app/
│   ├── config/
│   ├── db/
│   └── spec/
├── frontend/    # Vue 3 + Vite
│   ├── src/
│   └── public/
├── docs/        # Planning & documentation
└── README.md
```

## Model Relationships

- `TeamMember` has_many `SupportRequest`
- `SupportRequest` belongs_to `TeamMember` (optional)
- `SupportRequest` has_many `Comment`
- `Comment` belongs_to `SupportRequest`

## Team Organization

| Engineer | Primary Ownership | Rails Endpoint | Tests | Vue Views |
|----------|-------------------|----------------|-------|-----------|
| Engineer 1 | Models, migrations, validations, Team Members API | `GET/POST/PATCH /team_members` | Model + Request specs | Team Members view |
| Engineer 2 | Support Requests API, filters, business rules | `GET/POST/PATCH /support_requests` | Model + Request specs | Request List, Detail, Form |
| Engineer 3 | Vue setup, Comments API, Dashboard API | `POST /comments`, `GET /dashboard` | Model + Request specs | Dashboard, integration |

## Known Limitations

- No authentication or authorization
- No real-time updates (WebSockets)
- No pagination on list endpoints
- No deployment configuration
- SQLite only (PostgreSQL migration path documented)

## Future Improvements

- Add JWT-based authentication
- Implement pagination and sorting
- Add WebSocket support for real-time comments
- Dockerize the application
- Add CI/CD pipeline (GitHub Actions)
- Generate OpenAPI/Swagger documentation

## License

Internal use only.