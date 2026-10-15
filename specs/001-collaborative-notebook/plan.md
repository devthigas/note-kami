# Implementation Plan: Collaborative Notebook Workspace

**Branch**: `001-collaborative-notebook` | **Date**: 2026-10-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-collaborative-notebook/spec.md`

---

## Summary

Build an online collaborative notebook workspace for NoteKami using Rails 8.1 and SQLite3. The application features passwordless authentication via expiring Magic Links (powered by Rails 8 native token generation) and Google OAuth2, rich text editing via the extensible Lexxy editor (`gem "lexxy"`) with debounced auto-save (750ms threshold), hierarchical organization through folders and nested sub-pages (with circular nesting protection), real-time peer collaboration and presence indicators powered by Solid Cable over SQLite, and public read-only publishing via tokenized shareable links.

---

## Technical Context

- **Language/Version**: Ruby `~> 3.3.0`, Ruby on Rails `~> 8.1.4` (`config.load_defaults 8.1`).
- **Primary Dependencies**:
  - `lexxy`: Modern AST-based extensible rich text editor built on Lexical for Action Text.
  - `turbo-rails` & `stimulus-rails`: Hotwire reactivity, Turbo Streams, and client-side controllers.
  - `hotwire-spark`: Instant template morphing, CSS reloading, and Stimulus HMR in development.
  - `tailwindcss-rails`: Utility-first modern CSS framework with standalone CLI.
  - `solid_cable`, `solid_cache`, `solid_queue`: Rails 8 native database-backed infrastructure suite.
- **Storage**: SQLite3 with Write-Ahead Logging (WAL) mode, utilizing multi-database isolation for primary application data, Solid Cache, Solid Queue, and Solid Cable.
- **Testing**: Minitest (`rails test`), Request/Integration tests, System tests (`rails test:system`) with Headless Chrome/Cuprite, and RuboCop Omakase (`rubocop-rails-omakase`).
- **Target Platform**: Modern desktop and mobile evergreen web browsers.
- **Project Type**: Full-stack monolithic Rails 8 web application (Zero Node.js / NPM build pipeline).
- **Performance Goals**:
  - Debounced auto-save initiates persistence within 800ms of typing inactivity.
  - Real-time updates propagate across connected collaborators in under 1 second.
  - Publicly published notes load in under 1.5 seconds.
- **Constraints**:
  - Zero external service requirements (no Redis, no external message brokers).
  - Pure Vanilla JavaScript via Stimulus controllers using ESM Importmaps (`importmap-rails`).
  - Strict compliance with NoteKami Constitution (fat models, thin controllers, Rails Way).
- **Scale/Scope**: Multi-user notebook workspace supporting hierarchical trees, real-time presence, and secure public publishing.

---

## Constitution Check

*GATE: Verified before Phase 0 research and re-validated post-design. All 7 principles satisfied.*

| Principle | Status | Justification / Architectural Alignment |
| :--- | :--- | :--- |
| **I. The Rails Way & Fat Model, Thin Controller** | **PASS** | Controllers remain strictly thin (orchestration only). Domain validations, circular-nesting guards, and token logic are encapsulated in `Note`, `Folder`, and `User`. RESTful routes are standard. |
| **II. Zero Gem Bloat & Vanilla Rails (Rails 8 API)** | **PASS** | Replaced Devise with Rails 8 native authentication & `generates_token_for :magic_link`. Replaced Redis with Solid Cable, Solid Cache, and Solid Queue. No Node.js build pipeline. |
| **III. Ruby Elegance, Simplicity & Omakase** | **PASS** | Pure idiomatic Ruby adhering to `rubocop-rails-omakase`. Avoids premature micro-service abstractions, service object bloat, or complex nested-set gems in favor of straightforward ActiveRecord adjacency trees. |
| **IV. Test-Driven Development (TDD) & Quality** | **PASS** | Complete Minitest test matrix defined (unit models, controller requests, mailers, Action Cable channels, and browser system tests). |
| **V. Hotwire & Tailwind UI/UX** | **PASS** | Turbo Streams and Turbo Frames handle partial page updates; Stimulus manages debouncing and presence badges; Tailwind CSS provides responsive, accessible styling. |
| **VI. Native Scalability & Solid Suite** | **PASS** | Dedicated SQLite database for Solid Cable prevents locking primary database. Eager loading (`includes(:collaborators, :sub_pages)`) prevents N+1 queries. Background mailer delivery via Solid Queue. |
| **VII. Human-Executable Tasks & Clear Criteria** | **PASS** | All validation scenarios, endpoints, and channels are exhaustively documented with explicit inputs, outputs, and verification steps in `contracts/` and `quickstart.md`. |

---

## Project Structure

### Documentation (this feature)

```text
specs/001-collaborative-notebook/
├── plan.md              # This implementation plan
├── research.md          # Phase 0 research and architectural decisions
├── data-model.md        # Phase 1 entity schemas, validations, and state transitions
├── quickstart.md        # Phase 1 runnable end-to-end validation guide
├── contracts/           # Phase 1 interface specifications
│   ├── http-api.md      # RESTful endpoints, Turbo Stream contracts, and payloads
│   └── cable-channels.md# Action Cable / Solid Cable channels and real-time events
└── checklists/
    └── requirements.md  # Quality validation checklist
```

### Source Code (repository root)

```text
app/
├── channels/
│   ├── application_cable/
│   │   ├── channel.rb
│   │   └── connection.rb
│   └── note_channel.rb            # Real-time presence & collaboration stream
├── controllers/
│   ├── application_controller.rb
│   ├── concerns/
│   │   └── authentication.rb      # Rails 8 session authentication concern
│   ├── dashboard_controller.rb    # Workspace home view
│   ├── folders_controller.rb      # Folder CRUD
│   ├── magic_links_controller.rb  # Passwordless request & verification
│   ├── notes_controller.rb        # Note CRUD, debounced auto-save & sub-pages
│   ├── oauth_controller.rb        # Google OAuth flow & callback
│   ├── public_notes_controller.rb # Read-only public note renderer
│   └── sessions_controller.rb     # Sign in / Sign out
├── javascript/
│   ├── controllers/
│   │   ├── application.js
│   │   ├── auto_save_controller.js # Debounced auto-save Stimulus controller
│   │   ├── presence_controller.js  # Action Cable presence avatar manager
│   │   └── tree_controller.js      # Expandable folder/sub-page sidebar tree
│   └── application.js
├── mailers/
│   └── magic_link_mailer.rb       # Delivers expiring sign-in tokens
├── models/
│   ├── application_record.rb
│   ├── current.rb                 # ActiveSupport::CurrentAttributes (user, session)
│   ├── folder.rb                  # Hierarchical folder with cycle protection
│   ├── note.rb                    # Rich text note with sub-page tree & public token
│   ├── note_collaborator.rb       # Collaboration membership join model
│   ├── oauth_identity.rb          # Google OAuth credentials join model
│   ├── session.rb                 # Device session model
│   └── user.rb                    # User model with magic_link token generator
└── views/
    ├── dashboard/
    ├── folders/
    ├── layouts/
    ├── magic_links/
    ├── magic_link_mailer/
    ├── notes/
    ├── public_notes/
    └── sessions/

config/
├── cable.yml                      # Solid Cable configuration
├── database.yml                   # Multi-database SQLite3 (primary, cache, queue, cable)
├── environments/
│   └── development.rb             # Hotwire Spark enablement & Solid configs
├── importmap.rb                   # Pins for Lexxy, Stimulus, Turbo
└── routes.rb                      # RESTful routes for workspace resources

db/
├── migrate/                       # Migrations for users, sessions, folders, notes
└── schema.rb

test/
├── channels/
│   └── note_channel_test.rb
├── controllers/
│   ├── folders_controller_test.rb
│   ├── magic_links_controller_test.rb
│   ├── notes_controller_test.rb
│   └── public_notes_controller_test.rb
├── mailers/
│   └── magic_link_mailer_test.rb
├── models/
│   ├── folder_test.rb
│   ├── note_test.rb
│   └── user_test.rb
└── system/
    ├── authentication_test.rb
    ├── collaborative_editing_test.rb
    └── note_organization_test.rb
```

**Structure Decision**: Standard monolithic Rails 8 layout complying with "The Rails Way". Domain models encapsulate business logic and integrity checks; thin controllers handle HTTP orchestration; Hotwire Stimulus controllers manage client debounce and real-time Action Cable DOM events without SPA bloat.

---

## Complexity Tracking

> *No Constitution violations identified. Architecture adheres strictly to all 7 principles.*

| Potential Complexity | Why Needed | Simpler Alternative Rejected Because |
| :--- | :--- | :--- |
| **Lexxy Gem** | Extensible AST rich text editor required by user prompt. | Trix rejected due to closed flat-list model making custom block modification and node interception brittle. |
| **Multi-Database SQLite3** | Solid Cable and Solid Queue require frequent database writes. | Single SQLite file rejected because concurrent Action Cable broadcasts could trigger database busy timeouts on the primary app database. |
| **Google OAuth Handler** | Requested by user prompt alongside magic links. | Heavy omniauth stacks rejected in favor of lightweight, targeted OAuth flow preserving zero-bloat philosophy. |
