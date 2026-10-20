# Research & Technical Decisions: Collaborative Notebook Workspace

**Feature Branch**: `001-collaborative-notebook`  
**Date**: 2026-10-15  
**Spec**: [spec.md](./spec.md)

---

## Decision 1: Rich Text Editor — Lexxy vs. Trix (Action Text)

### Context & User Criterion
The user explicitly directed: *"editor de texto rico lexxy ou trixxy não decidade o que tem mais features e sim a possibilidade de modificação desse editor"* (do not decide based on who has more features, but rather on the **extensibility and modifiability** of the editor).

### Comparison Matrix: Modifiability & Extensibility

| Dimension | Trix | Lexxy (built on Lexical) |
| :--- | :--- | :--- |
| **Document Data Model** | Flat list of chunk blocks with inline attributes. No AST / tree-like DOM hierarchy. | Hierarchical Abstract Syntax Tree (AST) node graph (`LexicalNode`, `ElementNode`, `TextNode`). |
| **Custom Block Nodes** | Extremely difficult. Custom tags (e.g. nested callouts, math, custom cards, sub-page links) require monkey-patching Trix's internal piece-cache and line-formatter. | Native and modular. Developers create custom subclasses of `ElementNode` or `DecoratorNode` to render arbitrary interactive UI/components. |
| **Internal Event & Command System** | Monolithic event listeners on `<trix-editor>` custom element; hard to intercept or extend keystrokes cleanly without breaking internal selection logic. | Expressive command dispatching pipeline (`registerCommand`, `COMMAND_PRIORITY_LOW/HIGH`). Clean interception of paste, drop, keyboard shortcuts, and transform hooks. |
| **HTML Semantic Output** | Proprietary block wrappers (`<div>` tags with non-standard markup), requiring post-processing for clean semantic HTML. | Native semantic HTML (`<p>`, `<h1>`-`<h6>`, `<blockquote>`, `<pre><code>`) with bi-directional DOM-to-AST serialization. |
| **Modifiability for Collaboration & Custom Widgets** | Virtually closed. Modifying selection, inline mentions, or collaborative presence indicators requires intrusive DOM hacks. | Purpose-built for extensibility: native support for node transforms, selection listeners, custom mentions/slash-commands (`/`), and headless editor instances. |
| **Rails 8 & Action Text Integration** | Supported natively in Action Text (legacy default). | Created by 37signals specifically as the modern, extensible successor to Trix for Action Text in Rails 8 (`gem "lexxy"`). Hooks seamlessly into `rich_text_area`. |

### Decision
**Select Lexxy** (`gem "lexxy"` by 37signals, powered by Meta's Lexical engine).

### Rationale
Lexxy's underlying AST engine (Lexical) separates state management from DOM rendering. This allows developers to:
1. Extend the schema with custom blocks (e.g., slash-commands, mention popups, callout cards, code syntax highlighting).
2. Intercept change events effortlessly to trigger our debounced auto-save Stimulus controller without polluting the editor's internal undo/redo history.
3. Support future collaborative extensions and presence cursors through modular node listeners.
4. Retain 100% native Rails Action Text compatibility via `rich_text_area` and Active Storage attachment handling.

### Alternatives Considered
- **Trix**: Rejected because its 10-year-old flat document model makes extending or modifying editor behavior notoriously brittle. Adding custom nested blocks or specialized node behavior requires hacking private APIs.
- **TipTap / ProseMirror**: Highly extensible, but lacks the zero-configuration official 37signals Rails Action Text bridge that Lexxy natively provides via Importmaps.

---

## Decision 2: Real-Time Collaboration & Presence with Solid Cable

### Context
User Stories 2 & 4 require active presence tracking (who is viewing/editing) and live collaboration updates between connected peers without external services like Redis.

### Architectural Approach
- **Channel Layer**: Action Cable powered by `Solid Cable` (`solid_cable` gem, Rails 8 native).
- **Database Segregation**: In development and production, Solid Cable operates against a dedicated SQLite database (`storage/development_cable.sqlite3`), configured in `config/database.yml` and `config/cable.yml`. This guarantees that high-frequency polling/websocket writes never lock the primary SQLite application database.
- **Presence Tracking (`NoteChannel`)**:
  - When a collaborator opens a note, the client connects to `NoteChannel.subscribe(note_id: id)`.
  - The channel broadcasts `presence_diff` / `presence_update` events (connected users: `id`, `name`, `profile_photo` URL from OAuth if present, `avatar_color` for initials fallback, and current timestamp).
  - Client sends periodic heartbeats or disconnects on `unsubscribed` to clean up presence list.
- **Content Synchronization**:
  - Turbo Streams over Action Cable broadcasts updated fragments, title updates, and collaborator join/leave states.
  - Granular note updates broadcast to `note_#{id}` stream, allowing remote participants to receive real-time diffs.

### Rationale
Solid Cable satisfies Constitution Principle II (Zero Gem Bloat) and Principle VI (Native Scalability) by removing Redis while offering high-performance pubsub directly over SQLite with WAL mode.

---

## Decision 3: Debounced Auto-Save Mechanism

### Context
FR-005 and FR-006 require automatic background persistence when a user pauses typing, using a debounce mechanism with real-time "Saving..." and "Saved" status feedback.

### Architectural Approach
- **Stimulus Controller (`auto_save_controller.js`)**:
  - Attached to the note editor form.
  - Listens to `input` events on the title input and Lexxy editor change events (`lexxy-change` / `input`).
  - Implements a debounce timer (default: `750ms`).
  - When typing occurs:
    1. Status badge immediately updates to indicate "Unsaved changes" or "Typing...".
    2. Any existing pending timer is cancelled (`clearTimeout`).
    3. A new timer is armed for 750ms.
  - When the timer fires:
    1. Status badge updates to "Saving...".
    2. Dispatches an asynchronous `fetch` request (`PATCH /notes/:id`) with `Accept: text/vnd.turbo-stream.html` or JSON payload containing the updated title and rich text body.
    3. On successful HTTP 200/204 response, status badge transitions to "Saved" with a subtle checkmark and the save timestamp.
    4. On network failure, status updates to "Offline - retry pending", retaining local unsaved state and retrying after a backoff interval.
- **Keyboard Shortcut (Ctrl+S / Cmd+S)**:
  - Intercepted by the controller to bypass the debounce delay and trigger immediate submission.

### Rationale
Client-side debounce in a lightweight Vanilla JS Stimulus controller avoids unnecessary HTTP roundtrips during rapid typing while guaranteeing predictable persistence within 750ms of a pause, aligning with Constitution Principle V (Hotwire/Stimulus) and Principle III (Code Simplicity).

---

## Decision 4: Authentication via Magic Links & Google OAuth2 (with OAuth Profile Photo)

### Context
The user requested:
1. Native Rails authentication foundation (`bin/rails generate authentication`).
2. Passwordless login via **Magic Links** sent by email with expiration.
3. Social login with **Google OAuth**, storing the user's OAuth profile photo (`profile_photo`) on the `User` record while deferring direct image file uploads to future specifications.

### Architectural Approach

#### 1. Native Foundation
- Generate Rails 8 standard authentication scaffold:
  - `User` model (`app/models/user.rb`) with nullable `profile_photo` string attribute.
  - `Session` model (`app/models/session.rb`).
  - `Current` attributes (`app/models/current.rb`).
  - `Authentication` controller concern (`app/controllers/concerns/authentication.rb`).

#### 2. Passwordless Magic Links
- In `User`:
  - Declare Rails 8 native token generation:
    ```ruby
    generates_token_for :magic_link, expires_in: 15.minutes do
      last_sign_in_at
    end
    ```
    *(Including `last_sign_in_at` in the token generator block guarantees that once a magic link is used to sign in, any previous magic links for that user are immediately invalidated and single-use).*
- **Flow**:
  1. User enters email at `/magic_link/new`.
  2. `MagicLinksController#create`:
     - Finds or registers user by normalized email address.
     - Generates token: `token = user.generate_token_for(:magic_link)`.
     - Dispatches background job via Solid Queue (`MagicLinkMailer.sign_in_link(user, token).deliver_later`).
     - Renders notification: "Check your inbox for your secure sign-in link."
  3. User clicks link: `GET /magic_link/verify?token=...`.
  4. `MagicLinksController#verify`:
     - Resolves: `user = User.find_by_token_for(:magic_link, params[:token])`.
     - If valid:
       - Updates `user.update!(last_sign_in_at: Time.current)`.
       - Creates new `Session` record (`start_new_session_for(user)`).
       - Redirects to workspace dashboard.
     - If nil (expired or reused):
       - Renders error flash: "This sign-in link is invalid or has expired. Please request a new one." and redirects to login.

#### 3. Google OAuth Integration & Profile Photo Sync
- To adhere to Constitution Principle II (Zero Gem Bloat) and avoid unnecessary omniauth gem bloat, we implement a clean, lightweight OAuth2 handler:
  - `GET /auth/google`: Generates secure state/nonce in session and redirects browser to Google's OAuth2 authorization endpoint (`https://accounts.google.com/o/oauth2/v2/auth`) requesting `openid email profile` scopes.
  - `GET /auth/google/callback`: Verifies state token, exchanges authorization code for identity tokens via Google's token endpoint (`https://oauth2.googleapis.com/token`), extracts verified `email`, `name`, and `picture` (avatar URL), matches/creates user and identity, updates `user.profile_photo` with the OAuth `picture` URL when present, and starts session (`start_new_session_for(user)`).
  - Stored in `OAuthIdentity` model (`belongs_to :user`, `provider: 'google'`, `uid`, `email`), while `users.profile_photo` stores the nullable string URL for fast rendering in headers and collaboration presence indicators without extra joins or Active Storage upload overhead (manual avatar upload is deferred to future specs).

### Rationale
Leveraging Rails 8's built-in `generates_token_for` provides cryptographic security, tamper-resistance, and time-based expiration out-of-the-box without requiring external gems like Devise or passwordless gems.

---

## Decision 5: Live Reloading with Hotwire Spark in Development

### Context
The user specified: *"hotwire spark em modo de desenvolvimento para atualização de alterações em tempo real"*.

### Architectural Approach
- Add to `Gemfile` under `:development` group:
  ```ruby
  group :development do
    gem "hotwire-spark"
  end
  ```
- Hotwire Spark connects directly to the development server. When ERB templates, CSS, or Stimulus controllers are edited:
  - Views are morphed seamlessly without losing form or scroll state.
  - Stimulus controllers are hot-reloaded and reconnected dynamically.
- In production, the gem is completely excluded from the bundle.

### Rationale
Drastically shortens the feedback loop during frontend development while respecting the Rails 8 no-build philosophy (Propshaft + Importmaps).

---

## Decision 6: Hierarchical Data Structure (Folders & Nested Sub-Pages)

### Context
FR-008 to FR-011 require folders, notes inside folders, and nested sub-pages (pages within pages).

### Architectural Approach
- **Adjacency List Pattern with Foreign Keys**:
  - `Folder`:
    - `belongs_to :user`
    - `belongs_to :parent_folder, class_name: "Folder", optional: true`
    - `has_many :sub_folders, class_name: "Folder", foreign_key: :parent_folder_id, dependent: :destroy`
    - `has_many :notes, dependent: :nullify`
  - `Note`:
    - `belongs_to :user` (owner)
    - `belongs_to :folder, optional: true`
    - `belongs_to :parent_note, class_name: "Note", optional: true`
    - `has_many :sub_pages, class_name: "Note", foreign_key: :parent_note_id, dependent: :destroy`
- **Integrity & Cycle Prevention**:
  - Custom validation in `Note` and `Folder`: `validate :prevent_circular_nesting` ensuring an entity cannot be its own ancestor.
- **Navigation Tree View**:
  - Rendered via a recursive Turbo Frame / partial in the sidebar (`app/views/sidebar/_tree.html.erb`).
  - Expand/collapse state managed client-side with a lightweight Stimulus tree controller.

### Rationale
Adjacency lists are simple, idiomatic ActiveRecord patterns that avoid complex nested set / closure table gems for modest tree depths, adhering directly to Constitution Principle I (The Rails Way) and Principle III (Code Simplicity).
