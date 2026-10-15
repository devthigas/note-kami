# Cable Channels & Real-Time Contracts: Collaborative Notebook Workspace

**Feature Branch**: `001-collaborative-notebook`  
**Date**: 2026-10-15  
**Spec**: [spec.md](../spec.md)

---

## 1. Overview
Real-time presence and concurrent collaboration are powered by **Solid Cable** (`solid_cable`) over Action Cable. The architecture guarantees zero external service dependencies (no Redis) by writing to the dedicated `cable` SQLite database (`storage/development_cable.sqlite3`).

---

## 2. Channel: `NoteChannel`

### 2.1 Subscription
- **Channel Identifier**:
  ```json
  {
    "channel": "NoteChannel",
    "note_id": 42
  }
  ```
- **Authorization**:
  - The server verifies: `current_user == note.user || note.collaborators.include?(current_user)`.
  - If unauthorized, subscription is rejected (`reject`).

### 2.2 Client-to-Server Actions

#### `appear`
Sent by the client upon connecting or refocusing the tab.
- **Payload**:
  ```json
  {
    "action": "appear"
  }
  ```
- **Server Behavior**:
  - Adds user to the active presence set for `note:42`.
  - Broadcasts `presence_update` to the stream.

#### `disappear`
Sent by the client upon closing tab, navigating away, or disconnecting.
- **Server Behavior**:
  - Removes user from the active presence set for `note:42`.
  - Broadcasts `presence_update` to the stream.

### 2.3 Server-to-Client Broadcasts

#### Stream: `note_42`

##### 1. `presence_update`
Broadcast whenever a collaborator connects, disconnects, or sends a heartbeat.
- **Message Payload**:
  ```json
  {
    "type": "presence_update",
    "active_users": [
      {
        "id": 1,
        "name": "Alice Silva",
        "avatar_color": "#4f46e5",
        "is_owner": true
      },
      {
        "id": 5,
        "name": "Bruno Souza",
        "avatar_color": "#059669",
        "is_owner": false
      }
    ]
  }
  ```
- **Client Handling**:
  - `presence_controller.js` updates the header avatar stack showing active collaborators.

##### 2. `content_updated`
Broadcast by the server when an auto-save or edit from another collaborator is successfully saved.
- **Message Payload**:
  ```json
  {
    "type": "content_updated",
    "sender_id": 5,
    "title": "Novo Título Atualizado",
    "updated_at": "2026-10-15T14:35:10Z"
  }
  ```
- **Client Handling**:
  - If `sender_id != current_user.id`, updates the document title and triggers non-disruptive sync.

##### 3. `access_revoked`
Broadcast when the note owner revokes a collaborator's access.
- **Message Payload**:
  ```json
  {
    "type": "access_revoked",
    "revoked_user_id": 5
  }
  ```
- **Client Handling**:
  - If `revoked_user_id == current_user.id`, disables the editor canvas and displays an alert indicating that access was revoked.
