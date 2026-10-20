# Data Model Specification: Collaborative Notebook Workspace

**Feature Branch**: `001-collaborative-notebook`  
**Date**: 2026-10-15  
**Spec**: [spec.md](./spec.md)

---

## Entity Relationship Diagram (Conceptual)

```text
+------------------+         1:N         +--------------------+
|      User        |-------------------->|      Session       |
+------------------+                     +--------------------+
   | 1         1 |
   |           | | 1:N                   +--------------------+
   |           | +---------------------->|   OAuthIdentity    |
   |           |                         +--------------------+
   | 1:N       | 1:N
   v           v
+--------+   +------------------+  1:N   +--------------------+
| Folder |   |       Note       |------->|  NoteCollaborator  |
+--------+   +------------------+        +--------------------+
   | 1:N        | 1:N                       | N:1
   | (sub)      | (sub-pages)               v
   v            v                        +--------------------+
(Folder)     (Note)                      |    User (Collab)   |
                                         +--------------------+
```

---

## Entities & Schemas

### 1. `User`
Represents an individual with credentials, profile data, and ownership of workspace resources.

- **Table**: `users`
- **Fields**:
  - `id`: `bigint`, Primary Key, Auto-increment.
  - `name`: `string`, Not Null.
  - `profile_photo`: `string`, Nullable (stores the profile picture URL provided by external OAuth provider; direct file upload is deferred to future specs).
  - `email_address`: `string`, Not Null, Indexed (Unique).
  - `password_digest`: `string`, Nullable (enables passwordless magic link & OAuth-only accounts).
  - `last_sign_in_at`: `datetime`, Nullable (used as a salt/invalidation timestamp for magic link single-use).
  - `created_at`: `datetime`, Not Null.
  - `updated_at`: `datetime`, Not Null.
- **Relationships**:
  - `has_many :sessions, dependent: :destroy`
  - `has_many :oauth_identities, dependent: :destroy`
  - `has_many :folders, dependent: :destroy`
  - `has_many :notes, dependent: :destroy`
  - `has_many :note_collaborators, dependent: :destroy`
  - `has_many :collaborative_notes, through: :note_collaborators, source: :note`
- **Validations**:
  - `name`: `presence: true, length: { maximum: 100 }`
  - `email_address`: `presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }`
  - `profile_photo`: optional (`allow_nil: true`)
- **Tokens**:
  - `generates_token_for :magic_link, expires_in: 15.minutes { last_sign_in_at }`

---

### 2. `Session`
Represents an active authenticated device/browser session.

- **Table**: `sessions`
- **Fields**:
  - `id`: `bigint`, Primary Key, Auto-increment.
  - `user_id`: `bigint`, Foreign Key (`users.id`), Not Null, Indexed.
  - `ip_address`: `string`, Nullable.
  - `user_agent`: `string`, Nullable.
  - `created_at`: `datetime`, Not Null.
  - `updated_at`: `datetime`, Not Null.
- **Relationships**:
  - `belongs_to :user`

---

### 3. `OAuthIdentity`
Stores linked external identity providers (Google OAuth).

- **Table**: `oauth_identities`
- **Fields**:
  - `id`: `bigint`, Primary Key, Auto-increment.
  - `user_id`: `bigint`, Foreign Key (`users.id`), Not Null, Indexed.
  - `provider`: `string`, Not Null (e.g., `"google"`).
  - `uid`: `string`, Not Null.
  - `email`: `string`, Nullable.
  - `created_at`: `datetime`, Not Null.
  - `updated_at`: `datetime`, Not Null.
- **Indexes**:
  - Unique index on `[:provider, :uid]`
- **Relationships**:
  - `belongs_to :user`
- **Validations**:
  - `provider`: `presence: true`
  - `uid`: `presence: true, uniqueness: { scope: :provider }`

---

### 4. `Folder`
Hierarchical container for grouping notes.

- **Table**: `folders`
- **Fields**:
  - `id`: `bigint`, Primary Key, Auto-increment.
  - `user_id`: `bigint`, Foreign Key (`users.id`), Not Null, Indexed.
  - `parent_folder_id`: `bigint`, Foreign Key (`folders.id`), Nullable, Indexed.
  - `name`: `string`, Not Null.
  - `created_at`: `datetime`, Not Null.
  - `updated_at`: `datetime`, Not Null.
- **Relationships**:
  - `belongs_to :user`
  - `belongs_to :parent_folder, class_name: "Folder", optional: true`
  - `has_many :sub_folders, class_name: "Folder", foreign_key: :parent_folder_id, dependent: :destroy`
  - `has_many :notes, dependent: :nullify`
- **Validations**:
  - `name`: `presence: true, length: { maximum: 80 }`
  - `validate :prevent_circular_nesting`
- **Cycle Prevention Rule**:
  - A folder cannot set its `parent_folder_id` to itself or any of its descendant folders.

---

### 5. `Note`
Rich text document entity supporting auto-save, sub-page nesting, and public publishing.

- **Table**: `notes`
- **Fields**:
  - `id`: `bigint`, Primary Key, Auto-increment.
  - `user_id`: `bigint`, Foreign Key (`users.id`), Not Null, Indexed.
  - `folder_id`: `bigint`, Foreign Key (`folders.id`), Nullable, Indexed.
  - `parent_note_id`: `bigint`, Foreign Key (`notes.id`), Nullable, Indexed (for nested sub-pages).
  - `title`: `string`, Not Null, Default: `"Sem título"`.
  - `public_share_enabled`: `boolean`, Not Null, Default: `false`, Indexed.
  - `public_share_token`: `string`, Nullable, Indexed (Unique).
  - `created_at`: `datetime`, Not Null.
  - `updated_at`: `datetime`, Not Null.
- **Rich Text Integration**:
  - `has_rich_text :content` (backed by Action Text / Lexxy storage).
- **Relationships**:
  - `belongs_to :user`
  - `belongs_to :folder, optional: true`
  - `belongs_to :parent_note, class_name: "Note", optional: true`
  - `has_many :sub_pages, class_name: "Note", foreign_key: :parent_note_id, dependent: :destroy`
  - `has_many :note_collaborators, dependent: :destroy`
  - `has_many :collaborators, through: :note_collaborators, source: :user`
- **Validations**:
  - `title`: `presence: true, length: { maximum: 200 }`
  - `validate :prevent_circular_nesting`
- **State Transitions**:
  - **Publish Note**:
    - Trigger: Owner checks "Public Share Link".
    - Action: If `public_share_token` is blank, assign `SecureRandom.urlsafe_base64(24)`. Set `public_share_enabled = true`.
  - **Unpublish Note**:
    - Trigger: Owner unchecks "Public Share Link".
    - Action: Set `public_share_enabled = false`. (Token retained for idempotent re-enable or regenerated optionally).

---

### 6. `NoteCollaborator`
Join table defining real-time editing privileges for a collaborator on a note.

- **Table**: `note_collaborators`
- **Fields**:
  - `id`: `bigint`, Primary Key, Auto-increment.
  - `note_id`: `bigint`, Foreign Key (`notes.id`), Not Null, Indexed.
  - `user_id`: `bigint`, Foreign Key (`users.id`), Not Null, Indexed.
  - `role`: `string`, Not Null, Default: `"editor"` (options: `"editor"`, `"viewer"`).
  - `created_at`: `datetime`, Not Null.
  - `updated_at`: `datetime`, Not Null.
- **Indexes**:
  - Unique index on `[:note_id, :user_id]`.
- **Relationships**:
  - `belongs_to :note`
  - `belongs_to :user`
- **Validations**:
  - `user_id`: `uniqueness: { scope: :note_id }`
  - `role`: `inclusion: { in: %w[editor viewer] }`
  - `validate :owner_cannot_be_collaborator`
