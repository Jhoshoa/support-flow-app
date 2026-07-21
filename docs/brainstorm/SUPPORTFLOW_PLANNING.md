# SupportFlow — Planificación Arquitectónica & Sprints
## Aplicación de Gestión de Solicitudes de Soporte Interno

**Stack:** Ruby on Rails 7 (API Mode) + Vue 3 (Vite) + SQLite (dev) / PostgreSQL (prod-ready)
**Equipo:** 3 Ingenieros | **Duración:** 3 días hábiles | **Metodología:** Sprint-based Kanban

---

## Índice
1. [Visión Arquitectónica](#1-visión-arquitectónica)
2. [Estructura del Repositorio](#2-estructura-del-repositorio)
3. [Fases de Implementación](#3-fases-de-implementación)
   - [Fase 0: Foundation (Día 0)](#fase-0-foundation---día-0)
   - [Fase 1: Rails Core (Día 1)](#fase-1-rails-core---día-1)
   - [Fase 2: API & Business Rules (Día 2 AM)](#fase-2-api--business-rules---día-2-am)
   - [Fase 3: Testing & Vue Integration (Día 2 PM - Día 3 AM)](#fase-3-testing--vue-integration---día-2-pm---día-3-am)
   - [Fase 4: Polish & Defense Prep (Día 3 PM)](#fase-4-polish--defense-prep---día-3-pm)
4. [Modelo de Datos](#4-modelo-de-datos)
5. [API Contract](#5-api-contract)
6. [Business Rules Engine](#6-business-rules-engine)
7. [Vue Component Architecture](#7-vue-component-architecture)
8. [Testing Strategy](#8-testing-strategy)
9. [Git Workflow & Collaboration](#9-git-workflow--collaboration)
10. [Decisiones Técnicas (DECISIONS.md preview)](#10-decisiones-técnicas)

---

## 1. Visión Arquitectónica

```
┌─────────────────────────────────────────────────────────────┐
│                    VUE 3 FRONTEND (Vite)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Dashboard│  │  List    │  │  Detail  │  │  Forms   │   │
│  │  View    │  │  View    │  │  View    │  │  (CRUD)  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       └──────────────┴──────────────┴──────────────┘         │
│                         │                                   │
│                    Axios/Fetch                              │
│                         │                                   │
└─────────────────────────┼───────────────────────────────────┘
                          │ JSON API
┌─────────────────────────┼───────────────────────────────────┐
│              RUBY ON RAILS 7 (API Mode)                       │
│  ┌──────────────────────┴──────────────────────┐             │
│  │              Routes (config/routes.rb)        │             │
│  │         namespace :api, defaults: { format: :json }       │
│  └──────────────────────┬──────────────────────┘             │
│  ┌──────────────────────┴──────────────────────┐             │
│  │           Controllers (app/controllers/api/v1/)           │
│  │  TeamMembersController | SupportRequestsController        │
│  │  CommentsController      | DashboardController            │
│  └──────────────────────┬──────────────────────┘             │
│  ┌──────────────────────┴──────────────────────┐             │
│  │              Models (app/models/)             │             │
│  │  TeamMember | SupportRequest | Comment      │             │
│  └──────────────────────┬──────────────────────┘             │
│  ┌──────────────────────┴──────────────────────┐             │
│  │         ActiveRecord + SQLite/PostgreSQL     │             │
│  └─────────────────────────────────────────────┘             │
│  ┌─────────────────────────────────────────────┐             │
│  │  RSpec/Minitest (spec/ or test/)            │             │
│  │  Model Tests | Request Tests | Factories      │             │
│  └─────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

### Principios Arquitectónicos
1. **Convention over Configuration** — Usar al máximo las convenciones de Rails
2. **Fat Model, Skinny Controller** — Lógica de negocio en modelos, controllers solo orquestan
3. **API-First** — Rails en API mode, JSON consistente, HTTP semantics correctos
4. **Database Agnostic** — SQLite para dev, PostgreSQL para prod (mismas migrations)
5. **Test-Driven Where Possible** — Escribir tests ANTES o DURANTE la implementación

---

## 2. Estructura del Repositorio

```
support-flow/
├── .gitignore                          # Ignora: credentials, .env, tmp/, log/, node_modules/
├── README.md                           # Setup completo, comandos, arquitectura, contribuciones
├── DECISIONS.md                        # ≥3 decisiones técnicas documentadas
├── .env.example                        # Variables de entorno requeridas
│
├── backend/                            # Rails 7 API
│   ├── Gemfile
│   ├── Gemfile.lock
│   ├── Rakefile
│   ├── config.ru
│   ├── .ruby-version                   # 3.2.x
│   ├── config/
│   │   ├── application.rb              # config.api_only = true
│   │   ├── routes.rb                   # API v1 namespace
│   │   ├── database.yml                # SQLite dev/test, PostgreSQL prod (commented)
│   │   ├── environments/
│   │   └── initializers/
│   ├── app/
│   │   ├── controllers/
│   │   │   └── api/
│   │   │       └── v1/
│   │   │           ├── team_members_controller.rb
│   │   │           ├── support_requests_controller.rb
│   │   │           ├── comments_controller.rb
│   │   │           └── dashboard_controller.rb
│   │   ├── models/
│   │   │   ├── team_member.rb
│   │   │   ├── support_request.rb
│   │   │   └── comment.rb
│   │   └── serializers/               # Opcional: ActiveModel::Serializers o jbuilder
│   ├── db/
│   │   ├── migrate/
│   │   │   ├── 001_create_team_members.rb
│   │   │   ├── 002_create_support_requests.rb
│   │   │   └── 003_create_comments.rb
│   │   ├── schema.rb
│   │   └── seeds.rb                    # ≥5 members, ≥15 requests, ≥10 comments
│   ├── spec/                          # RSpec
│   │   ├── models/
│   │   │   ├── team_member_spec.rb
│   │   │   ├── support_request_spec.rb
│   │   │   └── comment_spec.rb
│   │   ├── requests/
│   │   │   ├── team_members_spec.rb
│   │   │   ├── support_requests_spec.rb
│   │   │   ├── comments_spec.rb
│   │   │   └── dashboard_spec.rb
│   │   ├── factories/                  # FactoryBot
│   │   │   ├── team_members.rb
│   │   │   ├── support_requests.rb
│   │   │   └── comments.rb
│   │   └── rails_helper.rb
│   └── bin/
│       ├── rails
│       ├── rspec
│       └── setup
│
├── frontend/                           # Vue 3 + Vite
│   ├── package.json
│   ├── vite.config.js
│   ├── index.html
│   ├── .env.example                    # VITE_API_BASE_URL=http://localhost:3000/api/v1
│   ├── src/
│   │   ├── main.js                     # App entry point
│   │   ├── App.vue                     # Root component + routing
│   │   ├── router/
│   │   │   └── index.js                # Vue Router: /, /requests, /requests/:id, /members
│   │   ├── api/
│   │   │   └── client.js               # Axios instance base configurada
│   │   ├── components/
│   │   │   ├── Dashboard.vue
│   │   │   ├── SupportRequestList.vue
│   │   │   ├── SupportRequestForm.vue
│   │   │   ├── SupportRequestDetail.vue
│   │   │   ├── TeamMemberList.vue
│   │   │   ├── TeamMemberForm.vue
│   │   │   ├── CommentList.vue
│   │   │   ├── CommentForm.vue
│   │   │   └── shared/
│   │   │       ├── LoadingSpinner.vue
│   │   │       ├── ErrorMessage.vue
│   │   │       └── FilterBar.vue
│   │   └── stores/                     # Pinia (opcional pero recomendado)
│   │       └── supportRequestStore.js
│   └── public/
│
└── docs/                              # Planificación, screenshots, evidencia
    ├── task-breakdown.md
    ├── daily-checkpoints.md
    ├── pr-reviews.md
    └── architecture-diagrams/
```

---

## 3. Fases de Implementación

### Fase 0: Foundation — Día 0 (Preparación, ~2 horas)

> **Objetivo:** Repositorio inicializado, estructura definida, planificación visible, primeros commits.

| Sprint | Tarea | Owner | Output | Tiempo Est. |
|--------|-------|-------|--------|-------------|
| **Sprint 0.1** | Crear repositorio GitHub, configurar `.gitignore`, estructura de carpetas | Todos (rotativo) | Repo limpio, sin secrets | 15 min |
| **Sprint 0.2** | Redactar `README.md` inicial (estructura, tech stack, planificación) | Todos | README v0.1 | 20 min |
| **Sprint 0.3** | Crear `task-breakdown.md` con asignación de ownership | Todos | Tabla de tareas visible | 30 min |
| **Sprint 0.4** | Crear rama `main`, protegerla, establecer reglas de PR (1 review mínimo) | Todos | Branch protection ON | 10 min |
| **Sprint 0.5** | Inicializar Rails API: `rails new backend --api --database=sqlite3` | Engineer 1 | Rails app funcional | 30 min |
| **Sprint 0.6** | Inicializar Vue: `npm create vite@latest frontend -- --template vue` | Engineer 3 | Vue app funcional | 15 min |
| **Sprint 0.7** | Primer PR: "Initial project setup" → merge a `main` | Todos | PR #1 merged | 15 min |

**Checkpoint Fase 0:** ✅ Repo clonable, Rails responde `rails s`, Vue responde `npm run dev`.

---

### Fase 1: Rails Core — Día 1

> **Objetivo:** Models, migrations, associations, validations, enums, seeds, y rutas base. Backend skeleton completo.

#### Sprint 1.1: Database Schema & Models (Mañana, ~3h)

| Tarea | Owner | Detalle | Tests |
|-------|-------|---------|-------|
| Generar migration `CreateTeamMembers` | Engineer 1 | `name:string`, `email:string:uniq`, `role:integer`, `active:boolean:default:true` | Model spec: validations, enum |
| Generar migration `CreateSupportRequests` | Engineer 2 | `title:string`, `description:text`, `status:integer`, `priority:integer`, `due_date:date`, `completed_at:datetime`, `team_member_id:references:optional` | Model spec: validations, associations, enums |
| Generar migration `CreateComments` | Engineer 3 | `body:text`, `author_name:string`, `support_request:references` | Model spec: validations, minimum length |
| Definir enums en models | Engineer 1 | `role: { developer: 0, qa: 1, support: 2 }` | — |
| Definir enums en SupportRequest | Engineer 2 | `status: { open: 0, in_progress: 1, resolved: 2, closed: 3 }`, `priority: { low: 0, medium: 1, high: 2, critical: 3 }` | — |
| Establecer associations | Todos | `TeamMember has_many :support_requests`, `SupportRequest belongs_to :team_member, optional: true`, `has_many :comments`, `Comment belongs_to :support_request` | Association specs |

#### Sprint 1.2: Business Rules en Models (Mediodía, ~2h)

| Tarea | Owner | Regla | Test |
|-------|-------|-------|------|
| Validación: inactive assignment | Engineer 2 | `validate :team_member_must_be_active` | Spec: asignar a inactive → error |
| Auto `completed_at` on resolve | Engineer 2 | `before_update :set_completed_at` si status cambia a resolved | Spec: cambiar a resolved → completed_at presente |
| Clear `completed_at` on un-resolve | Engineer 2 | `before_update :clear_completed_at` si status deja resolved | Spec: dejar resolved → completed_at nil |
| Closed → open restriction | Engineer 2 | `validate :closed_cannot_reopen` | Spec: closed → open → error |
| Closed edit restriction | Engineer 2 | `validate :closed_cannot_edit` (excepto comments) | Spec: update closed → error |
| Overdue scope/method | Engineer 1 | `scope :overdue, -> { where('due_date < ?', Date.today).where.not(status: [resolved, closed]) }` | Spec: overdue true/false |
| Unassigned scope | Engineer 1 | `scope :unassigned, -> { where(team_member_id: nil) }` | Spec: unassigned count |

#### Sprint 1.3: Routes & Controllers Skeleton (Tarde, ~2h)

| Tarea | Owner | Endpoint | Notas |
|-------|-------|----------|-------|
| Configurar `config/routes.rb` | Engineer 1 | `namespace :api do namespace :v1 do resources ... end end` | Base path `/api/v1` |
| `TeamMembersController` skeleton | Engineer 1 | `index`, `create`, `update` | Strong params, JSON responses |
| `SupportRequestsController` skeleton | Engineer 2 | `index`, `show`, `create`, `update` | Filters en index |
| `CommentsController` skeleton | Engineer 3 | `create` (nested under support_requests) | `POST /api/v1/support_requests/:id/comments` |
| `DashboardController` skeleton | Engineer 3 | `index` | Aggregations |

#### Sprint 1.4: Seed Data (Tarde, ~1h)

| Tarea | Owner | Requisito |
|-------|-------|-----------|
| Crear `db/seeds.rb` | Engineer 1 | ≥5 team members, mix de roles y active/inactive |
| Crear support requests | Engineer 2 | ≥15 requests, variados status/priority, assigned/unassigned, ≥3 overdue |
| Crear comments | Engineer 3 | ≥10 comments distribuidos en requests |
| Verificar seeds | Todos | `rails db:seed` ejecuta sin errores |

**Checkpoint Fase 1:** ✅ `rails db:migrate && rails db:seed` funciona. Models tienen tests verdes. `rails c` permite crear/validar records.

**PRs esperados:**
- PR #2: "Add TeamMember model, migration, validations, and seeds" (Engineer 1)
- PR #3: "Add SupportRequest model, business rules, and seeds" (Engineer 2)
- PR #4: "Add Comment model and nested routing" (Engineer 3)

---

### Fase 2: API & Business Rules — Día 2 (Mañana)

> **Objetivo:** Todos los endpoints funcionales con lógica completa, filtros, dashboard, error handling consistente.

#### Sprint 2.1: Team Members API (Completo, ~1.5h)

| Tarea | Owner | Endpoint | Comportamiento | Tests |
|-------|-------|----------|----------------|-------|
| List | Engineer 1 | `GET /api/v1/team_members` | JSON array, todos los campos | Request spec: 200, array not empty |
| Create | Engineer 1 | `POST /api/v1/team_members` | 201 si válido, 422 si inválido | Request spec: válido/inválido, email duplicado |
| Update | Engineer 1 | `PATCH /api/v1/team_members/:id` | 200 si válido, 404 si no existe, 422 si inválido | Request spec: update name, deactivate, invalid email |

#### Sprint 2.2: Support Requests API (Completo, ~2h)

| Tarea | Owner | Endpoint | Comportamiento | Tests |
|-------|-------|----------|----------------|-------|
| List + Filters | Engineer 2 | `GET /api/v1/support_requests` | Query params: `status`, `priority`, `team_member_id`, `overdue`, `unassigned`, `q` (text search) | Request spec: cada filtro individualmente, combinados |
| Show | Engineer 2 | `GET /api/v1/support_requests/:id` | 200 + comments anidados, 404 si no existe | Request spec: 200 con comments, 404 |
| Create | Engineer 2 | `POST /api/v1/support_requests` | 201, 422 con errores de validación | Request spec: válido, inválido, sin título |
| Update | Engineer 2 | `PATCH /api/v1/support_requests/:id` | 200, 422 (business rules), 404 | Request spec: update status, assign, invalid assignment, closed edit restriction |

**Filters implementation (ActiveRecord):**
```ruby
# En SupportRequest model o controller
scope = SupportRequest.all
scope = scope.where(status: params[:status]) if params[:status].present?
scope = scope.where(priority: params[:priority]) if params[:priority].present?
scope = scope.where(team_member_id: params[:team_member_id]) if params[:team_member_id].present?
scope = scope.overdue if params[:overdue] == 'true'
scope = scope.unassigned if params[:unassigned] == 'true'
scope = scope.where('title ILIKE ?', "%#{params[:q]}%") if params[:q].present?
```

#### Sprint 2.3: Comments API (Completo, ~1h)

| Tarea | Owner | Endpoint | Comportamiento | Tests |
|-------|-------|----------|----------------|-------|
| Create | Engineer 3 | `POST /api/v1/support_requests/:id/comments` | 201, 422 si body < 10 chars, 404 si request no existe | Request spec: válido, body corto, request inexistente |

#### Sprint 2.4: Dashboard API (Completo, ~1h)

| Tarea | Owner | Endpoint | Comportamiento | Tests |
|-------|-------|----------|----------------|-------|
| Summary | Engineer 3 | `GET /api/v1/dashboard` | JSON con: total, overdue, unassigned, by_status, by_priority | Request spec: estructura exacta, valores correctos |

**Dashboard implementation:**
```ruby
def index
  render json: {
    total_requests: SupportRequest.count,
    overdue_requests: SupportRequest.overdue.count,
    unassigned_requests: SupportRequest.unassigned.count,
    requests_by_status: SupportRequest.group(:status).count.transform_keys { |k| SupportRequest.statuses.key(k) },
    requests_by_priority: SupportRequest.group(:priority).count.transform_keys { |k| SupportRequest.priorities.key(k) }
  }
end
```

#### Sprint 2.5: Error Handling Consistente (~30min)

| Tarea | Owner | Implementación |
|-------|-------|----------------|
| Formato de error estandarizado | Engineer 1 | `ApplicationController` rescue_from ActiveRecord::RecordInvalid, RecordNotFound |
| Estructura JSON: `{ error: "...", details: [...] }` | Engineer 1 | Método `render_error` reusable |

**Checkpoint Fase 2:** ✅ `rspec` pasa. Postman/curl puede consumir TODOS los endpoints. Filtros funcionan. Dashboard devuelve JSON correcto.

**PRs esperados:**
- PR #5: "Implement TeamMembers API with tests" (Engineer 1)
- PR #6: "Implement SupportRequests API, filters, and business rules" (Engineer 2)
- PR #7: "Implement Comments and Dashboard API with tests" (Engineer 3)

---

### Fase 3: Testing & Vue Integration — Día 2 (Tarde) + Día 3 (Mañana)

> **Objetivo:** Suite de tests completa y verde. Vue consume API. Todas las vistas funcionales.

#### Sprint 3.1: Backend Test Suite Completa (Día 2 PM, ~2h)

| Test Category | Count Mínimo | Owner | Coverage |
|---------------|-------------|-------|----------|
| Model: TeamMember validations | 2 | Engineer 1 | name required, email format/unique, enum role |
| Model: SupportRequest validations | 3 | Engineer 2 | title/desc required, inactive assignment, closed restrictions |
| Model: SupportRequest business rules | 3 | Engineer 2 | completed_at auto, clear on unresolve, overdue logic |
| Model: Comment validations | 2 | Engineer 3 | body min 10 chars, author_name required |
| Request: TeamMembers | 3 | Engineer 1 | index, create valid/invalid, update deactivate |
| Request: SupportRequests | 4 | Engineer 2 | index+filters, show, create, update+rules |
| Request: Comments | 2 | Engineer 3 | create valid, create invalid |
| Request: Dashboard | 1 | Engineer 3 | structure and values |
| **Total mínimo** | **20** | **Todos** | — |

#### Sprint 3.2: Vue Setup & API Client (Día 2 PM, ~1h)

| Tarea | Owner | Detalle |
|-------|-------|---------|
| Instalar dependencias | Engineer 3 | `axios`, `vue-router@4`, `pinia` (opcional) |
| Configurar API client | Engineer 3 | `src/api/client.js` — Axios con baseURL `http://localhost:3000/api/v1` |
| Configurar Vue Router | Engineer 3 | Rutas: `/`, `/requests`, `/requests/:id`, `/members` |
| Crear stores Pinia (si se usa) | Engineer 3 | `supportRequestStore`, `teamMemberStore` |

#### Sprint 3.3: Vue Views Implementation (Día 3 AM, ~3h)

| View | Componentes | Owner | Funcionalidad |
|------|-------------|-------|---------------|
| **Dashboard** | `Dashboard.vue` | Engineer 3 | Cards con métricas, fetch a `/dashboard`, loading/error states |
| **Request List** | `SupportRequestList.vue`, `FilterBar.vue` | Engineer 2 | Tabla/lista, filtros UI, identificar overdue (badge rojo), navegar a detail |
| **Request Detail** | `SupportRequestDetail.vue`, `CommentList.vue`, `CommentForm.vue` | Engineer 2 | Info completa, historial de comments, form para nuevo comment |
| **Create/Edit Request** | `SupportRequestForm.vue` | Engineer 2 | Formulario con title, desc, status, priority, due_date, assignment dropdown |
| **Team Members** | `TeamMemberList.vue`, `TeamMemberForm.vue` | Engineer 1 | Lista, toggle active/inactive, formulario de creación |

#### Sprint 3.4: Vue Quality & Integration (Día 3 AM, ~1h)

| Tarea | Owner | Criterio |
|-------|-------|----------|
| Loading states | Todos | Spinner en todas las vistas durante fetch |
| Error states | Todos | Mensaje de error si API falla (500, 422, 404) |
| Auto-refresh | Todos | Después de create/update/comment, recargar datos |
| Validación UI | Todos | Mostrar errores de validación del backend en formularios |

**Checkpoint Fase 3:** ✅ Frontend consume API real. Flujo completo: crear request → asignar → comentar → resolver → ver dashboard. Tests verdes.

**PRs esperados:**
- PR #8: "Complete backend test suite — 20+ tests" (Todos, colaborativo)
- PR #9: "Vue setup, routing, and Dashboard view" (Engineer 3)
- PR #10: "Vue Support Request views — list, detail, form, comments" (Engineer 2)
- PR #11: "Vue Team Members view and integration polish" (Engineer 1)

---

### Fase 4: Polish & Defense Prep — Día 3 (Tarde)

> **Objetivo:** Documentación completa, setup validado desde clone limpio, presentación lista.

#### Sprint 4.1: Documentation (~1.5h)

| Documento | Owner | Contenido |
|-----------|-------|-----------|
| `README.md` final | Todos (rotativo) | Overview, tech versions, install steps, run commands, env vars, API summary, architecture, team table, limitations, future improvements |
| `DECISIONS.md` | Todos | ≥3 decisiones: SQLite vs PG, RSpec vs Minitest, Vue composition vs options, monorepo vs split, etc. |
| `.env.example` | Engineer 1 | Variables necesarias para backend y frontend |

#### Sprint 4.2: Validation & Cleanup (~1h)

| Tarea | Owner | Verificación |
|-------|-------|--------------|
| Clean clone test | Engineer 1 | Clonar en carpeta nueva, seguir README, verificar que funciona |
| `rails db:setup` | Engineer 1 | `db:create db:migrate db:seed` en una línea |
| `rspec` verde | Todos | Todos los tests pasan |
| `rubocop` (opcional) | Engineer 1 | Formato consistente |
| No secrets committed | Todos | Revisar `git log --name-only`, no `.env`, no `credentials.yml` |

#### Sprint 4.3: Git History & Collaboration Evidence (~30min)

| Tarea | Owner | Evidencia |
|-------|-------|-----------|
| Verificar PRs merged | Todos | ≥8 PRs con reviews |
| Verificar commits | Todos | Historia clara, mensajes descriptivos |
| Crear `docs/pr-reviews.md` | Todos | Screenshots o links de PRs con comments |
| Crear `docs/daily-checkpoints.md` | Todos | Notas de los 3 días: qué se hizo, blockers, ajustes |

#### Sprint 4.4: Defense Preparation (~1h)

| Actividad | Tiempo | Preparación |
|-----------|--------|-------------|
| Team overview | 5 min | Narrar problema, arquitectura, distribución |
| Live demo | 15 min | Script de flujos: crear member → crear request → asignar → comentar → filtrar → resolver → dashboard |
| Code walkthrough | 10 min | Mostrar models, controllers, tests, Vue components |
| Individual defense | 5-7 min c/u | Cada engineer prepara: su endpoint, sus tests, una decisión, un blocker, un PR reviewado |

**Checkpoint Fase 4:** ✅ Todo en `main`. README permite setup sin ayuda. Tests verdes. Demo script practicado.

---

## 4. Modelo de Datos

### Entity Relationship Diagram

```
┌─────────────────────┐         ┌─────────────────────────────┐         ┌─────────────────────┐
│    team_members     │         │      support_requests       │         │       comments        │
├─────────────────────┤         ├─────────────────────────────┤         ├─────────────────────┤
│ id: PK              │◄────────┤ id: PK                      │         │ id: PK              │
│ name: string        │    1    │ title: string               │    1    │ body: text          │
│ email: string (U)   │    ╲    │ description: text           │    ╲    │ author_name: string │
│ role: integer (E)   │     ╲   │ status: integer (E)         │     ╲   │ support_request_id: │
│ active: boolean     │      ╲  │ priority: integer (E)       │      ╲  │   FK (references)   │
│ created_at          │       ╲ │ due_date: date                │       ╲ │ created_at          │
│ updated_at          │        ╲│ completed_at: datetime        │        ╲│ updated_at            │
└─────────────────────┘         │ team_member_id: FK (opt)    │         └─────────────────────┘
                                │ created_at                  │
                                │ updated_at                  │
                                └─────────────────────────────┘

E = Enum
U = Unique
FK = Foreign Key
opt = Optional (nullable)
```

### Enum Definitions

```ruby
# TeamMember
enum role: { developer: 0, qa: 1, support: 2 }

# SupportRequest
enum status: { open: 0, in_progress: 1, resolved: 2, closed: 3 }
enum priority: { low: 0, medium: 1, high: 2, critical: 3 }
```

---

## 5. API Contract

### Base URL
```
http://localhost:3000/api/v1
```

### Endpoints

#### Team Members
```
GET    /api/v1/team_members          → 200 + [{ id, name, email, role, active }]
POST   /api/v1/team_members          → 201 + { ... } | 422 + { error, details }
PATCH  /api/v1/team_members/:id      → 200 + { ... } | 404 | 422
```

#### Support Requests
```
GET    /api/v1/support_requests      → 200 + [{ id, title, status, priority, due_date, overdue?, team_member, comment_count }]
         ?status=open
         ?priority=critical
         ?team_member_id=2
         ?overdue=true
         ?unassigned=true
         ?q=search+term

GET    /api/v1/support_requests/:id  → 200 + { id, title, description, status, priority, due_date, completed_at, team_member, comments: [...] } | 404
POST   /api/v1/support_requests      → 201 + { ... } | 422
PATCH  /api/v1/support_requests/:id  → 200 + { ... } | 404 | 422
```

#### Comments
```
POST   /api/v1/support_requests/:id/comments  → 201 + { id, body, author_name, created_at } | 404 | 422
```

#### Dashboard
```
GET    /api/v1/dashboard             → 200 + {
                                          total_requests: 24,
                                          overdue_requests: 3,
                                          unassigned_requests: 4,
                                          requests_by_status: { open: 8, in_progress: 7, resolved: 6, closed: 3 },
                                          requests_by_priority: { low: 4, medium: 10, high: 7, critical: 3 }
                                        }
```

### Error Response Format
```json
{
  "error": "Validation failed",
  "details": ["Title can't be blank", "Team member must be active"]
}
```

### HTTP Status Codes
| Código | Uso |
|--------|-----|
| 200 | GET exitoso, PATCH exitoso |
| 201 | POST exitoso (creación) |
| 204 | DELETE (no usado en este scope) |
| 404 | Resource no encontrado |
| 422 | Validación o business rule fallida |

---

## 6. Business Rules Engine

### Rule Matrix

| # | Regla | Implementación | Test |
|---|-------|----------------|------|
| 1 | Request puede crearse sin asignación | `belongs_to :team_member, optional: true` | Model spec: create without team_member_id |
| 2 | No asignar a miembro inactivo | `validate :team_member_must_be_active` | Model spec: assign inactive → error |
| 3 | `completed_at` auto al resolver | `before_update :set_completed_at_if_resolved` | Model spec: status resolved → completed_at presente |
| 4 | `completed_at` se limpia al salir de resolved | `before_update :clear_completed_at_if_not_resolved` | Model spec: status open → completed_at nil |
| 5 | Closed no puede volver a open | `validate :closed_cannot_transition_to_open` | Model spec: closed → open → error |
| 6 | Closed no editable (solo comments) | `validate :closed_cannot_be_edited` (excepto en comments controller) | Model spec: update closed title → error |
| 7 | Overdue = due_date < hoy && status ∉ {resolved, closed} | `scope :overdue` + method `overdue?` | Model spec: overdue true/false cases |

### State Machine (SupportRequest)

```
                    ┌─────────────┐
                    │    open     │
                    └──────┬──────┘
                           │ create / update
                           ▼
                    ┌─────────────┐
              ┌────►│ in_progress │◄────┐
              │     └──────┬──────┘     │
              │            │ update      │
              │            ▼             │
              │     ┌─────────────┐      │
              │     │  resolved   │──────┘ (can go back to in_progress)
              │     └──────┬──────┘
              │            │ update
              │            ▼
              │     ┌─────────────┐
              └────►│   closed    │ (terminal — cannot go back to open)
                    └─────────────┘
                            │
                            ▼
                      (solo comments permitidos)
```

---

## 7. Vue Component Architecture

### Component Tree

```
App.vue (Layout + RouterView)
│
├── Dashboard.vue
│   └── MetricCard.vue (×5: total, overdue, unassigned, by_status, by_priority)
│
├── SupportRequestList.vue
│   ├── FilterBar.vue
│   │   ├── StatusFilter.vue
│   │   ├── PriorityFilter.vue
│   │   ├── TeamMemberFilter.vue
│   │   ├── OverdueToggle.vue
│   │   └── SearchInput.vue
│   └── SupportRequestCard.vue (×N)
│
├── SupportRequestDetail.vue
│   ├── RequestInfo.vue
│   ├── StatusBadge.vue
│   ├── PriorityBadge.vue
│   ├── OverdueBadge.vue
│   ├── CommentList.vue
│   │   └── CommentItem.vue (×N)
│   └── CommentForm.vue
│
├── SupportRequestForm.vue
│   ├── FormInput.vue
│   ├── FormTextarea.vue
│   ├── FormSelect.vue (status, priority, team_member)
│   └── FormDatePicker.vue
│
└── TeamMemberList.vue
    ├── TeamMemberCard.vue (×N)
    └── TeamMemberForm.vue

Shared:
├── LoadingSpinner.vue
├── ErrorMessage.vue
└── EmptyState.vue
```

### State Management (Pinia Stores)

```javascript
// stores/supportRequestStore.js
export const useSupportRequestStore = defineStore('supportRequests', {
  state: () => ({
    requests: [],
    currentRequest: null,
    filters: { status: '', priority: '', team_member_id: '', overdue: false, unassigned: false, q: '' },
    loading: false,
    error: null
  }),
  actions: {
    async fetchRequests() { /* API call with filters */ },
    async fetchRequest(id) { /* API call */ },
    async createRequest(data) { /* API call + refresh list */ },
    async updateRequest(id, data) { /* API call + refresh */ },
    async addComment(requestId, data) { /* API call + refresh request */ }
  }
})

// stores/teamMemberStore.js
export const useTeamMemberStore = defineStore('teamMembers', {
  state: () => ({ members: [], loading: false, error: null }),
  actions: {
    async fetchMembers() { /* API call */ },
    async createMember(data) { /* API call */ },
    async toggleActive(id, active) { /* PATCH */ }
  }
})

// stores/dashboardStore.js
export const useDashboardStore = defineStore('dashboard', {
  state: () => ({ metrics: null, loading: false, error: null }),
  actions: {
    async fetchMetrics() { /* API call */ }
  }
})
```

---

## 8. Testing Strategy

### Test Pyramid

```
                    ▲
                   ╱ ╲
                  ╱ E2E ╲         (Opcional: Cypress/Playwright — no requerido)
                 ╱───────╲
                ╱ Request ╲       (8+ tests: API endpoints, filters, errors)
               ╱───────────╲
              ╱    Model    ╲     (8+ tests: validations, associations, business rules)
             ╱───────────────╲
            ╱   Unit/Helpers   ╲  (Opcional: scopes, custom methods)
           ╱─────────────────────╲
```

### Test Commands
```bash
# Backend
cd backend
bundle exec rspec              # Run full suite
bundle exec rspec spec/models  # Run model tests only
bundle exec rspec spec/requests # Run request tests only

# Frontend (opcional, no requerido)
cd frontend
npm run test                   # Si se configuran tests de Vue
```

### Coverage Targets
| Área | Mínimo | Ideal |
|------|--------|-------|
| Model validations | 100% | 100% |
| Business rules | 100% | 100% |
| API endpoints | Cada endpoint | 100% |
| Error cases | ≥5 casos | Todos los 422/404 |
| Filters | 4+ filtros | Todos los 6 |

---

## 9. Git Workflow & Collaboration

### Branching Strategy (GitHub Flow)

```
main (protegida, requiere 1 review)
  │
  ├── feature/team-member-model        → PR #2 → review → merge
  ├── feature/support-request-model    → PR #3 → review → merge
  ├── feature/comment-model            → PR #4 → review → merge
  ├── feature/team-members-api         → PR #5 → review → merge
  ├── feature/support-requests-api     → PR #6 → review → merge
  ├── feature/comments-dashboard-api  → PR #7 → review → merge
  ├── feature/backend-tests           → PR #8 → review → merge
  ├── feature/vue-dashboard           → PR #9 → review → merge
  ├── feature/vue-requests-views      → PR #10 → review → merge
  └── feature/vue-members-polish      → PR #11 → review → merge
```

### Commit Message Convention
```
type(scope): description

Types: feat, fix, test, docs, refactor, chore
Examples:
  feat(models): add TeamMember with validations and enum
  test(requests): add TeamMembersController request specs
  fix(support-requests): prevent assignment to inactive team member
  docs(readme): add setup instructions and API summary
```

### PR Review Checklist
- [ ] Código sigue convenciones Rails/Vue
- [ ] Tests incluidos y verdes
- [ ] No secrets o credenciales
- [ ] Seeds actualizados si hay cambios en schema
- [ ] README actualizado si hay cambios en setup
- [ ] RuboCop pasa (si se usa)

### Team Contribution Table (README)

| Engineer | Primary Ownership | Rails Endpoint | Tests | Vue Views | PRs Reviewed |
|----------|-------------------|----------------|-------|-----------|--------------|
| Engineer 1 | Models, migrations, validations, Team Members API | `GET/POST/PATCH /team_members` | Model + Request specs | Team Members view | PR #3, PR #6, PR #7 |
| Engineer 2 | Support Requests API, filters, business rules | `GET/POST/PATCH /support_requests` | Model + Request specs | Request List, Detail, Form | PR #2, PR #5, PR #8 |
| Engineer 3 | Vue setup, Comments API, Dashboard API | `POST /comments`, `GET /dashboard` | Model + Request specs | Dashboard, integration | PR #4, PR #5, PR #6 |

---

## 10. Decisiones Técnicas (Preview para DECISIONS.md)

### Decisión 1: SQLite para desarrollo, PostgreSQL-ready para producción
- **Decisión:** Usar SQLite en desarrollo y test, mantener `database.yml` preparado para PostgreSQL.
- **Alternativas:** PostgreSQL desde el inicio, MySQL.
- **Razón:** Setup instantáneo, sin dependencias de servicio externo. Rails abstrae las diferencias.
- **Trade-off:** Algunas features avanzadas de PG (arrays, JSONB) no disponibles en SQLite. Migrations deben ser compatibles con ambos.

### Decisión 2: RSpec + FactoryBot para testing
- **Decisión:** Usar RSpec con FactoryBot en lugar de Minitest.
- **Alternativas:** Minitest (default de Rails), Minitest + fixtures.
- **Razón:** RSpec es más expresivo para request specs y model specs. FactoryBot permite datos dinámicos.
- **Trade-off:** Setup adicional (gemas), curva de aprendizaje para quien no conozca RSpec.

### Decisión 3: Monorepo con backend/frontend separados
- **Decisión:** Un solo repo con carpetas `backend/` y `frontend/`.
- **Alternativas:** Dos repos separados, monorepo con integración más tight (Rails sirve Vue).
- **Razón:** Facilita reviews conjuntas, un solo lugar para documentación, setup más simple para reviewers.
- **Trade-off:** Historia de commits más grande, posible confusión en PRs si no se etiqueta bien.

### Decisión 4: Vue 3 Composition API + Pinia
- **Decisión:** Vue 3 con Composition API y Pinia para state management.
- **Alternativas:** Options API, Vuex, React.
- **Razón:** Composition API es el estándar moderno de Vue 3. Pinia es el reemplazo oficial de Vuex, más simple y type-safe.
- **Trade-off:** Requiere familiaridad con Composition API. Más boilerplate que Options API para componentes simples.

### Decisión 5: Sin autenticación ni autorización
- **Decisión:** No implementar auth (requisito del challenge).
- **Alternativas:** Devise, JWT, OAuth.
- **Razón:** Scope control explícito. Prioridad en backend funcional, tests, y Vue integration.
- **Trade-off:** Cualquier usuario puede hacer cualquier operación. No es production-ready sin auth.

---

## 11. Daily Checkpoints Template

### Día 1 — Rails Foundation
```markdown
## Día 1 Checklist
- [ ] Repo creado y estructura definida
- [ ] Rails API inicializado
- [ ] Vue inicializado
- [ ] Models y migrations creados
- [ ] Validations y enums implementados
- [ ] Associations establecidas
- [ ] Seeds funcionan
- [ ] PRs #2, #3, #4 merged
- [ ] Blockers: ___________
- [ ] Scope adjustments: ___________
```

### Día 2 — API & Integration
```markdown
## Día 2 Checklist
- [ ] Todos los endpoints implementados
- [ ] Filtros funcionan (4+ mínimo)
- [ ] Dashboard devuelve métricas correctas
- [ ] Business rules enforceadas en backend
- [ ] Error handling consistente
- [ ] Model tests verdes
- [ ] Request tests verdes (8+ mínimo)
- [ ] Vue consume API
- [ ] PRs #5, #6, #7, #8 merged
- [ ] Blockers: ___________
```

### Día 3 — Polish & Defense
```markdown
## Día 3 Checklist
- [ ] Frontend completo (todas las vistas)
- [ ] Loading y error states implementados
- [ ] README completo y validado
- [ ] DECISIONS.md con ≥3 decisiones
- [ ] Tests verdes: `bundle exec rspec`
- [ ] Clean clone test exitoso
- [ ] No secrets en repo
- [ ] PRs #9, #10, #11 merged
- [ ] Demo script practicado
- [ ] Individual defense preparado
```

---

## 12. Definition of Done (Checklist Final)

- [ ] **Repositorio:** Creado desde cero, commit history clara, PRs con reviews
- [ ] **Setup:** Reviewer puede clonar y ejecutar siguiendo README
- [ ] **Backend:** Endpoints requeridos implementados, business rules correctas
- [ ] **Individual Rails:** Cada engineer implementó ≥1 endpoint con tests
- [ ] **Frontend:** Vue consume API, flujos requeridos funcionan
- [ ] **Data:** Migrations y seeds incluidos
- [ ] **Tests:** `bundle exec rspec` pasa (≥8 model + ≥8 request)
- [ ] **Collaboration:** Planning, ownership, y peer review documentados
- [ ] **Documentation:** README.md y DECISIONS.md completos
- [ ] **Defense:** Equipo preparado para demo y defensa individual

---

*Documento creado como planificación arquitectónica para el challenge SupportFlow.*
*Stack: Ruby 3.x + Rails 7 API + Vue 3 (Vite) + SQLite (dev) / PostgreSQL (prod-ready)*
*Metodología: Sprint-based con GitHub Flow, convenciones Rails, y TDD donde sea posible.*
