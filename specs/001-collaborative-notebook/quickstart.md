# Quickstart Validation Guide: Collaborative Notebook Workspace

**Feature Branch**: `001-collaborative-notebook`  
**Date**: 2026-10-15  
**Spec**: [spec.md](./spec.md)  
**Data Model**: [data-model.md](./data-model.md)  
**Contracts**: [http-api.md](./contracts/http-api.md) | [cable-channels.md](./contracts/cable-channels.md)

---

## 1. Prerequisites & Environment Setup

- **Ruby**: Version `3.3.0` or higher (verified in `.ruby-version`).
- **Bundler**: `bundle install` executed.
- **SQLite3**: Installed locally with support for WAL mode.
- **Node.js**: **Not required** (the application relies on Propshaft, Importmaps, and Tailwind standalone CLI).

```bash
# 1. Install dependencies
bundle install

# 2. Setup SQLite databases (Primary, Cache, Queue, Cable)
bin/rails db:prepare

# 3. Start the unified development server (Web + Tailwind + Solid Queue + Solid Cable + Hotwire Spark)
bin/dev
```

The application will be available at `http://localhost:3000`.

---

## 2. End-to-End Validation Scenarios

### Scenario A: Passwordless Authentication via Magic Link & Google OAuth Profile Photo
1. Navigate to `http://localhost:3000/magic_links/new`.
2. Enter email `autor@notekami.test` and click **"Enviar Link Mágico"**.
3. In the terminal output or development email inbox (`/rails/mailers`), retrieve the generated sign-in URL containing the 15-minute token.
4. Open the link in the browser.
5. **Expected Outcome**:
   - The user is authenticated automatically and redirected to `/dashboard` with session established.
   - When signing in via Google OAuth (`/auth/google`), the user's OAuth profile picture URL is saved in `user.profile_photo` and displayed in the navigation bar (falling back to user initials when `profile_photo` is absent).
   - Re-clicking the same magic link or waiting > 15 minutes fails with an expiration message.

### Scenario B: Rich Text Editing & Debounced Auto-Save
1. Click **"Nova Nota"** on the dashboard.
2. In the title field, type `"Minha Primeira Anotação"`.
3. In the Lexxy rich text editor canvas, type styled content:
   - Apply a Heading 2 (`## Introdução`).
   - Add bold text, bullet points, and a fenced code block.
4. Stop typing and observe the auto-save indicator in the top right.
5. **Expected Outcome**:
   - Status changes to `"Salvando..."` within 750ms of the last keystroke.
   - Status changes to `"✓ Salvo"` with the current timestamp.
   - Pressing `F5` (refresh) reloads the page with 100% of the formatted content and title preserved.

### Scenario C: Hierarchical Organization (Folders & Nested Sub-pages)
1. In the sidebar, click **"+ Nova Pasta"** and name it `"Projetos"`.
2. Drag or move the existing note into the `"Projetos"` folder.
3. Open the note and click **"Adicionar Subpágina"**. Name it `"Arquitetura"`.
4. **Expected Outcome**:
   - The sidebar navigation tree displays `"Projetos"` > `"Minha Primeira Anotação"` > `"Arquitetura"`.
   - Clicking tree nodes navigates between parent and child pages.
   - Attempting to set `"Projetos"` inside its own subfolder is blocked by cycle validation.

### Scenario D: Real-Time Presence & Collaboration
1. In the note editor, click **"Compartilhar"** > **"Adicionar Colaborador"** and enter `colega@notekami.test`.
2. Open a separate Incognito window and log in as `colega@notekami.test`.
3. Open the shared note in both windows side-by-side.
4. **Expected Outcome**:
   - Both browser tabs display active presence avatar badges for each user (showing their OAuth `profile_photo` if present, or initials fallback).
   - When User A types in the note, the changes propagate to User B's screen in real time over Solid Cable.

### Scenario E: Public Sharing via Tokenized Link
1. In the note settings, toggle **"Link Público Ativado"**.
2. Copy the generated URL (format: `http://localhost:3000/p/:token`).
3. Open an unauthenticated browser window and paste the URL.
4. **Expected Outcome**:
   - The formatted note renders in read-only mode without login prompts.
   - No private editor controls or workspace navigation are exposed.
   - Turning off the toggle in the author's window causes the public link to immediately return a 404 page.

---

## 3. Automated Test Execution

Run the complete test suite:

```bash
# Run unit and integration tests (Models, Controllers, Requests, Mailers)
bin/rails test

# Run system tests (Full browser flow with Hotwire and Lexxy editor)
bin/rails test:system

# Check code style and formatting standards (Omakase style)
bin/rubocop
```
