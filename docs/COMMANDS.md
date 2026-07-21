# SupportFlow — Comandos de Inicialización

> Guía paso a paso para crear el proyecto desde cero: Rails API + Vue 3 + dependencias + verificación.

---

## Requisitos Previos

Verifica que tengas instalado:

```bash
# Ruby (3.2.x)
ruby --version
# → ruby 3.2.x (o superior)

# Rails (7.x)
rails --version
# → Rails 7.x.x

# Node.js (18+)
node --version
# → v18.x.x (o superior)

# npm (9+)
npm --version
# → 9.x.x (o superior)

# SQLite3
sqlite3 --version
# → 3.x.x

# Git
git --version
# → 2.x.x
```

Si falta algo:
- **Ruby:** [rbenv](https://github.com/rbenv/rbenv) o [rvm](https://rvm.io/)
- **Rails:** `gem install rails`
- **Node.js:** [nvm](https://github.com/nvm-sh/nvm) o [nodejs.org](https://nodejs.org/)
- **SQLite3:** `brew install sqlite3` (Mac) o `sudo apt-get install sqlite3` (Linux)

---

## Paso 1: Crear Repositorio Git

```bash
# Crear carpeta del proyecto
mkdir support-flow
cd support-flow

# Inicializar Git
git init

# Crear estructura de carpetas
mkdir backend frontend docs

# Crear .gitignore raíz
cat > .gitignore << 'EOF'
# Backend
/backend/.env
/backend/log/*
!/backend/log/.keep
/backend/tmp/*
!/backend/tmp/.keep
/backend/db/*.sqlite3
/backend/db/*.sqlite3-*
/backend/config/master.key
/backend/config/credentials.yml.enc

# Frontend
/frontend/node_modules
/frontend/dist
/frontend/.env
/frontend/.env.local

# General
.DS_Store
*.log
EOF

# Primer commit
git add .
git commit -m "chore: initial project structure"
```

---

## Paso 2: Crear Rails API (Backend)

```bash
# Desde la raíz del proyecto (support-flow/)
cd backend

# Crear Rails en API mode con SQLite
rails new . --api --database=sqlite3 --skip-test --skip-action-mailer --skip-active-storage --skip-action-text --skip-javascript --skip-turbolinks --skip-spring

# Nota: --skip-test porque usaremos RSpec
```

### Configurar Gemfile

Edita `backend/Gemfile` y asegúrate de tener:

```ruby
source "https://ruby.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"  # Ajusta a tu versión

gem "rails", "~> 7.1.0"
gem "sqlite3", "~> 1.4"
gem "puma", "~> 5.0"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# CORS para Vue
gem "rack-cors"

# Serialización JSON (opcional, puedes usar jbuilder o manual)
# gem "active_model_serializers", "~> 0.10.0"

group :development, :test do
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails", "~> 6.0"
  gem "faker", "~> 3.0"
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "listen", "~> 3.3"
end
```

```bash
# Instalar gemas
bundle install
```

### Configurar CORS

```bash
# Crear/Editar config/initializers/cors.rb
cat > config/initializers/cors.rb << 'EOF'
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_URL") { "http://localhost:5173" }

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
EOF
```

### Configurar database.yml (SQLite + PostgreSQL ready)

```bash
cat > config/database.yml << 'EOF'
# SQLite. Versions 3.8.0 and up are supported.
# gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem "sqlite3"
#
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: db/test.sqlite3

# PostgreSQL ready for production (uncomment when deploying)
# production:
#   adapter: postgresql
#   encoding: unicode
#   pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
#   url: <%= ENV["DATABASE_URL"] %>
EOF
```

### Instalar RSpec

```bash
# Generar archivos de RSpec
rails generate rspec:install

# Verificar que funcione
bundle exec rspec
# → 0 examples, 0 failures (esperado, no hay tests aún)
```

### Verificar que Rails corre

```bash
# Crear base de datos
rails db:create

# Verificar que el servidor arranca
rails server
# → Listening on http://0.0.0.0:3000
# Presiona Ctrl+C para detener
```

Prueba en navegador o terminal:
```bash
curl http://localhost:3000
# → {"status":"ok","message":"Rails API running"} (o similar)
```

---

## Paso 3: Crear Vue 3 + Vite (Frontend)

```bash
# Desde la raíz del proyecto (support-flow/)
cd ../frontend

# Crear proyecto Vue 3 con Vite
npm create vite@latest . -- --template vue

# Instalar dependencias
npm install

# Instalar dependencias adicionales
npm install axios vue-router@4 pinia

# Instalar dependencias de desarrollo (opcional)
npm install -D @vitejs/plugin-vue
```

### Configurar Vite

```bash
# vite.config.js ya existe, verifica que tenga:
cat vite.config.js
```

Debería verse así:
```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    }
  }
})
```

### Crear .env.example

```bash
cat > .env.example << 'EOF'
VITE_API_BASE_URL=http://localhost:3000/api/v1
EOF

cp .env.example .env
```

### Verificar que Vue corre

```bash
npm run dev
# → Local: http://localhost:5173/
# Presiona Ctrl+C para detener
```

Abre http://localhost:5173 en tu navegador. Deberías ver la página de bienvenida de Vue.

---

## Paso 4: Commit Inicial del Proyecto

```bash
# Desde la raíz (support-flow/)
cd ..

# Verificar estructura
ls -la
ls backend/
ls frontend/

# Agregar todo
git add .

# Commit inicial del proyecto
git commit -m "feat: initialize Rails API and Vue 3 projects

- Rails 7 API mode with SQLite
- Vue 3 + Vite frontend
- CORS configured for cross-origin requests
- RSpec + FactoryBot + Faker for testing
- Axios + Vue Router + Pinia for frontend
- Proxy configured for API requests"
```

---

## Paso 5: Verificación Final (Ambos Corriendo)

### Terminal 1 — Backend

```bash
cd support-flow/backend
rails server
# → Booting Puma
# → Rails 7.x.x application starting in development
# → Run `bin/rails server --help` for more startup options
# → Listening on http://0.0.0.0:3000
```

### Terminal 2 — Frontend

```bash
cd support-flow/frontend
npm run dev
# → VITE v4.x.x  ready in xxx ms
# → Local: http://localhost:5173/
```

### Verificación con curl

```bash
# Test Rails API
curl http://localhost:3000

# Test Vue (dev server responde)
curl http://localhost:5173

# Test CORS (desde Vue a Rails)
curl -H "Origin: http://localhost:5173"      -H "Access-Control-Request-Method: GET"      -H "Access-Control-Request-Headers: X-Requested-With"      -X OPTIONS      http://localhost:3000/api/v1/team_members
# → Debería devolver headers CORS válidos
```

---

## Comandos Rápidos de Referencia

### Backend (Rails)

```bash
# Entrar al backend
cd backend

# Instalar dependencias
bundle install

# Crear base de datos
rails db:create

# Crear migración
rails generate migration CreateTeamMembers

# Ejecutar migraciones
rails db:migrate

# Seed datos
rails db:seed

# Reset completo (drop + create + migrate + seed)
rails db:reset

# Correr servidor
rails server
# o
rails s

# Correr tests
bundle exec rspec
bundle exec rspec spec/models
bundle exec rspec spec/requests

# Consola Rails
rails console
# o
rails c

# Generar scaffold (model + controller)
rails generate scaffold TeamMember name:string email:string role:integer active:boolean
```

### Frontend (Vue)

```bash
# Entrar al frontend
cd frontend

# Instalar dependencias
npm install

# Correr servidor de desarrollo
npm run dev

# Build para producción
npm run build

# Preview del build
npm run preview

# Lint (si configuraste ESLint)
npm run lint
```

### Git

```bash
# Ver estado
git status

# Crear rama
git checkout -b feature/team-member-model

# Agregar cambios
git add .
git add -p  # patch mode (recomendado)

# Commit con convención
git commit -m "feat(models): add TeamMember with validations and enum"

# Push rama
git push -u origin feature/team-member-model

# Ver log
git log --oneline --graph --all
```

---

## Troubleshooting

### Rails no encuentra la gem `rack-cors`

```bash
cd backend
bundle add rack-cors
bundle install
```

### Error de puerto ocupado (3000 o 5173)

```bash
# Encontrar proceso usando el puerto
lsof -i :3000
# o
lsof -i :5173

# Matar proceso
kill -9 <PID>

# O usar puerto alternativo
rails server -p 3001
npm run dev -- --port 5174
```

### Vue no puede conectar a Rails (CORS error)

1. Verifica que `rack-cors` esté en el Gemfile
2. Verifica que `config/initializers/cors.rb` exista
3. Reinicia el servidor Rails (los initializers se cargan al inicio)
4. Verifica que `FRONTEND_URL` o el origin en CORS sea `http://localhost:5173`

### SQLite "database is locked"

```bash
# En desarrollo, esto puede pasar con múltiples procesos
# Solución: reiniciar el servidor Rails
# O usar WAL mode (opcional):
sqlite3 db/development.sqlite3 "PRAGMA journal_mode=WAL;"
```

### Error "Cannot find module 'axios'"

```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

---

## Estructura Final Esperada

```
support-flow/
├── .git/
├── .gitignore
├── backend/
│   ├── app/
│   │   ├── controllers/
│   │   │   └── application_controller.rb
│   │   ├── models/
│   │   └── controllers/
│   ├── config/
│   │   ├── routes.rb
│   │   ├── database.yml
│   │   └── initializers/
│   │       └── cors.rb
│   ├── db/
│   │   └── development.sqlite3
│   ├── spec/
│   │   └── rails_helper.rb
│   ├── Gemfile
│   ├── Gemfile.lock
│   └── config.ru
├── frontend/
│   ├── src/
│   │   ├── main.js
│   │   ├── App.vue
│   │   ├── style.css
│   │   └── assets/
│   ├── public/
│   ├── index.html
│   ├── package.json
│   ├── package-lock.json
│   ├── vite.config.js
│   └── .env
├── docs/
└── README.md
```

---

## Próximos Pasos

1. ✅ Proyecto creado y corriendo
2. ⏭️ Crear modelos y migraciones (Día 1)
3. ⏭️ Implementar business rules (Día 1)
4. ⏭️ Crear API endpoints (Día 2)
5. ⏭️ Implementar Vue views (Día 2-3)
6. ⏭️ Escribir tests (Día 2-3)
7. ⏭️ Documentar y preparar defensa (Día 3)

---

*Ejecuta estos comandos en orden. Si algo falla, revisa el troubleshooting antes de continuar.*
