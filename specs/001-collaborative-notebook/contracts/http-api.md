# HTTP Endpoints & Contracts: Collaborative Notebook Workspace

**Feature Branch**: `001-collaborative-notebook`  
**Date**: 2026-10-15  
**Spec**: [spec.md](../spec.md)

---

## 1. Authentication & Magic Links

### 1.1 Request Magic Link
- **Method**: `POST`
- **Path**: `/magic_links`
- **Headers**: `Content-Type: application/x-www-form-urlencoded`
- **Payload**:
  ```json
  {
    "email_address": "user@example.com"
  }
  ```
- **Responses**:
  - `302 Found`: Redirects to `/magic_links/sent` with flash message: `"Link mágico enviado! Verifique sua caixa de entrada."`
  - `422 Unprocessable Content`: If email is malformed.

### 1.2 Verify Magic Link
- **Method**: `GET`
- **Path**: `/magic_links/verify?token=:token`
- **Responses**:
  - `302 Found`: Sets `session_id` signed cookie, redirects to `/dashboard` or intended destination.
  - `302 Found` (Invalid/Expired): Redirects to `/login` with flash alert: `"O link expirou ou é inválido. Solicite um novo link."`

### 1.3 Google OAuth Authentication
- **Initiate**: `GET /auth/google` (Redirects to Google OAuth consent screen with secure `state` and `openid email profile` scopes).
- **Callback**: `GET /auth/google/callback?code=:code&state=:state`
- **Responses**:
  - `302 Found`: Verifies token with Google API, extracts `email`, `name`, and `picture` (persisting the avatar URL into `user.profile_photo`), establishes session, and redirects to `/dashboard`.
  - `302 Found` (Failure): Redirects to `/login` with alert message.

### 1.4 Sign Out
- **Method**: `DELETE`
- **Path**: `/session`
- **Responses**:
  - `302 Found`: Clears signed session cookie, destroys `Session` record, redirects to `/login`.

---

## 2. Notes & Debounced Auto-Save

### 2.1 Create Note
- **Method**: `POST`
- **Path**: `/notes`
- **Payload**:
  ```json
  {
    "note": {
      "title": "Nova Nota",
      "folder_id": 12,
      "parent_note_id": null
    }
  }
  ```
- **Responses**:
  - `302 Found`: Redirects to `/notes/:id/edit`.
  - `200 OK` (Turbo Stream): Prepends new note item to sidebar tree and opens editor.

### 2.2 Auto-Save Note (Debounced Background Persistence)
- **Method**: `PATCH`
- **Path**: `/notes/:id`
- **Headers**:
  - `Accept: text/vnd.turbo-stream.html, application/json`
  - `X-CSRF-Token: <token>`
- **Payload**:
  ```json
  {
    "note": {
      "title": "Planejamento Estratégico",
      "content": "<p>Conteúdo formatado gerado pelo editor Lexxy...</p>"
    }
  }
  ```
- **Responses**:
  - `200 OK` (Turbo Stream):
    ```html
    <turbo-stream action="replace" target="auto_save_status">
      <template>
        <span id="auto_save_status" class="text-xs text-emerald-600 font-medium flex items-center gap-1">
          ✓ Salvo às 14:32:05
        </span>
      </template>
    </turbo-stream>
    ```
  - `200 OK` (JSON):
    ```json
    {
      "status": "saved",
      "updated_at": "2026-10-15T14:32:05Z",
      "title": "Planejamento Estratégico"
    }
    ```
  - `422 Unprocessable Content`: If validation fails (e.g. title is blank).

### 2.3 Create Nested Sub-Page
- **Method**: `POST`
- **Path**: `/notes/:id/sub_pages`
- **Payload**:
  ```json
  {
    "note": {
      "title": "Subpágina Filha"
    }
  }
  ```
- **Responses**:
  - `302 Found`: Redirects to `/notes/:child_id/edit`.
  - `200 OK` (Turbo Stream): Appends child node under parent node in the sidebar tree.

---

## 3. Folders Management

### 3.1 Create Folder
- **Method**: `POST`
- **Path**: `/folders`
- **Payload**:
  ```json
  {
    "folder": {
      "name": "Projetos 2026",
      "parent_folder_id": null
    }
  }
  ```
- **Responses**:
  - `302 Found` or `200 OK` (Turbo Stream): Appends folder to navigation sidebar.

### 3.2 Delete Folder
- **Method**: `DELETE`
- **Path**: `/folders/:id`
- **Responses**:
  - `302 Found` or `200 OK` (Turbo Stream): Removes folder element from sidebar, disassociates notes safely (`dependent: :nullify`).

---

## 4. Real-Time Collaborators

### 4.1 Invite Collaborator
- **Method**: `POST`
- **Path**: `/notes/:id/collaborators`
- **Payload**:
  ```json
  {
    "collaborator": {
      "email_address": "colaborador@example.com",
      "role": "editor"
    }
  }
  ```
- **Responses**:
  - `200 OK` (Turbo Stream): Appends collaborator avatar and details to the collaborator drawer.
  - `422 Unprocessable Content`: If user email does not exist or user is already a collaborator.

### 4.2 Revoke Collaborator
- **Method**: `DELETE`
- **Path**: `/notes/:id/collaborators/:user_id`
- **Responses**:
  - `200 OK` (Turbo Stream): Removes collaborator row; broadcasts kick event via Action Cable to disconnect that user.

---

## 5. Public Sharing

### 5.1 Toggle Public Share
- **Method**: `PATCH`
- **Path**: `/notes/:id/public_share`
- **Payload**:
  ```json
  {
    "public_share_enabled": true
  }
  ```
- **Responses**:
  - `200 OK` (JSON or Turbo Stream):
    ```json
    {
      "public_share_enabled": true,
      "public_url": "https://notekami.app/p/abc123secureTokenxyz"
    }
    ```

### 5.2 Read-Only Public Note View
- **Method**: `GET`
- **Path**: `/p/:token`
- **Authentication**: None required.
- **Responses**:
  - `200 OK`: Renders clean, read-only HTML layout presenting the note title and formatted Action Text / Lexxy content.
  - `404 Not Found`: If token does not exist or `public_share_enabled` is false.
