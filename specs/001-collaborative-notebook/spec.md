# Feature Specification: Collaborative Notebook Workspace

**Feature Branch**: `001-collaborative-notebook`

**Created**: 2026-10-15

**Status**: Draft

**Input**: User description: "crie um caderno online onde usuários possam se autenticar criar uma anotação utiliando um editor de texto rico, adicionar colaboradores em tempo real para auxiliar a anotação e criar um link publico para publicar as anotações para outras pessoas o save tem que ser automatico vamos usar um debounce para controlar quando o usuário para de digitar para salvar automaticamente capacidade de organizar anotações criando uma pagina dentro de outra e criando pastas para organizar suas anotações"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - User Authentication & Personal Notebook Setup (Priority: P1)

As a knowledge worker or student,
I want to register an account, securely log in, and access my personal notebook workspace,
So that my private notes and documents are protected and accessible across sessions.

**Why this priority**: Authentication and personal workspace isolation are the core security and data ownership foundation. Every note, folder, and collaborative permission relies on verified user identity.

**Independent Test**: Can be fully tested by registering a new account, signing in, verifying that a private dashboard loads, and confirming that session termination prevents unauthorized access.

**Acceptance Scenarios**:

1. **Given** an unauthenticated visitor, **When** they submit valid registration credentials (name, email, password), **Then** an account is created, they are signed in, and redirected to their personal workspace.
2. **Given** a registered user, **When** they submit valid login credentials, **Then** an authenticated session is established and their notebook contents are displayed.
3. **Given** a user authenticating via an external OAuth provider, **When** the provider supplies a profile picture, **Then** the system stores the profile photo on the user's account and displays it in their workspace profile and presence indicators (falling back to a default avatar/initials if none is provided).
4. **Given** an authenticated user, **When** they click "Sign Out", **Then** the session is terminated and private notes are no longer accessible without re-authenticating.
5. **Given** invalid or missing registration/login credentials, **When** the form is submitted, **Then** clear, actionable validation messages are displayed without clearing safe form fields.

---

### User Story 2 - Rich Text Note Creation with Debounced Auto-Save (Priority: P1)

As an author or note-taker,
I want to draft and format content using a rich text editor with automatic saving as I type,
So that my ideas are structured clearly and my work is continuously preserved without manual saving friction.

**Why this priority**: The primary value of an online notebook is writing and formatting content reliably. Unobtrusive auto-save eliminates data loss anxiety and streamlines the writing flow.

**Independent Test**: Can be fully tested by creating a note, typing styled content, pausing typing, observing the save status indicator transition from "Saving..." to "Saved", and reloading the page to confirm complete content fidelity.

**Acceptance Scenarios**:

1. **Given** an authenticated user in a notebook, **When** they choose to create a new note, **Then** a new blank document opens with a title input and a rich text editing canvas.
2. **Given** an author editing a note, **When** they apply formatting (headings, bold, italic, bullet lists, numbered lists, blockquotes, code blocks), **Then** the canvas reflects the formatting immediately.
3. **Given** an author actively typing in a note, **When** keystrokes pause for a defined debounce window (e.g., 750ms), **Then** the system automatically saves the title and body in the background and displays a "Saved" confirmation state.
4. **Given** a note with recent edits, **When** the page is refreshed or reopened, **Then** the latest saved content and formatting are completely restored.

---

### User Story 3 - Hierarchical Organization with Folders and Nested Sub-Pages (Priority: P2)

As a researcher or project manager,
I want to create folders and nest notes inside other notes as sub-pages,
So that I can build a structured knowledge base, project wiki, or multi-level notebook.

**Why this priority**: High-volume note-taking quickly becomes unmanageable without hierarchical grouping. Nested pages and folders transform a basic notepad into a cohesive knowledge management system.

**Independent Test**: Can be fully tested by creating folders, placing notes inside them, creating sub-pages under existing parent notes, and navigating the resulting multi-level tree in the sidebar.

**Acceptance Scenarios**:

1. **Given** an authenticated user in their notebook, **When** they create a new folder, **Then** the folder appears in the workspace navigation tree ready to hold notes.
2. **Given** an existing note, **When** the user clicks "Add Sub-page" within that note, **Then** a child note is created linked to the parent note, and both are visible hierarchically in the navigation sidebar.
3. **Given** a hierarchy of folders, parent notes, and sub-pages, **When** the user navigates the sidebar, **Then** nested items can be expanded or collapsed to facilitate navigation.
4. **Given** an item (note or folder), **When** the user moves it into another folder or nests it under another page, **Then** the hierarchy updates immediately without breaking internal relationships.

---

### User Story 4 - Real-Time Collaborative Editing & Presence (Priority: P2)

As a team member or co-author,
I want to invite collaborators to a note so we can view and edit the document simultaneously in real time,
So that we can brainstorm, take meeting notes, and co-write content cooperatively without version conflicts.

**Why this priority**: Real-time collaboration unlocks teamwork, pair-writing, and live review, meeting modern expectations for collaborative workspaces.

**Independent Test**: Can be fully tested by opening the same note simultaneously in two distinct user sessions, inviting the second user as a collaborator, typing edits in one session, and verifying that the changes and active presence indicators appear in the other session in real time.

**Acceptance Scenarios**:

1. **Given** the owner of a note, **When** they invite another registered user by email as a collaborator, **Then** the collaborator is granted access and the note appears in their shared notebook view.
2. **Given** multiple collaborators viewing the same note simultaneously, **When** a collaborator opens or focuses on the note, **Then** an active presence avatar (displaying their OAuth profile photo if available, or initials fallback) or indicator is visible to all participants.
3. **Given** two collaborators editing a note concurrently, **When** one collaborator makes modifications, **Then** the updates are broadcast and rendered in the other collaborator's editor in real time.
4. **Given** the note owner, **When** they remove a collaborator's access, **Then** the removed user's active session is revoked and they can no longer view or edit the private note.

---

### User Story 5 - Public Note Sharing via Shareable Link (Priority: P3)

As a content creator or presenter,
I want to generate a unique public web link for a note,
So that external readers can view the formatted note without needing to create an account or sign in.

**Why this priority**: Enables publication and distribution of documentation, articles, and guides to external stakeholders or the general public.

**Independent Test**: Can be fully tested by enabling public sharing on a note, copying the generated public link, opening it in an unauthenticated incognito browser, verifying read-only presentation, and verifying that toggling public sharing off revokes access.

**Acceptance Scenarios**:

1. **Given** a note owner, **When** they enable "Public Share Link" in the note settings, **Then** a unique, obfuscated public URL is generated and presented with a quick copy action.
2. **Given** an unauthenticated visitor with a valid public link, **When** they access the URL, **Then** they see the formatted note in read-only mode with a clean, distraction-free reading layout.
3. **Given** an unauthenticated visitor viewing a public note, **When** they attempt to edit content or access private controls, **Then** no editing tools are available and no private metadata or other notes are exposed.
4. **Given** a note with public sharing active, **When** the owner disables public sharing, **Then** subsequent requests to the public link return a clear "Not Found / Access Revoked" page.

---

### Edge Cases

- **Network Disconnection During Active Typing**: If the client loses internet connectivity while auto-save is debouncing or in-flight, the system MUST show an "Offline / Unsaved Changes" warning indicator, preserve local unsaved text in memory, and automatically retry saving once connectivity is restored without discarding user input.
- **Concurrent Conflicting Edits**: When two collaborators edit identical paragraphs simultaneously during a network latency spike, the synchronization mechanism MUST reconcile edits gracefully without crashing the editor or silently overwriting either user's content.
- **Circular Nesting Prevention**: The system MUST prevent moving a folder or page into itself or into any of its own descendant sub-pages, displaying a clear error message.
- **Deletion of Parent Page with Sub-pages or Folders with Notes**: When a user attempts to delete a parent item that contains sub-pages or notes, the system MUST prompt with an explicit confirmation dialog detailing the number of child items affected, with safe options to cancel or confirm cascading deletion/archival.
- **Revoked Collaborator Mid-Session**: If an active collaborator has their access revoked while viewing or editing a note, the system MUST disconnect their real-time channel, disable the editor canvas, and inform the user that their access has been updated.
- **Empty or Whitespace-Only Notes**: Auto-save MUST handle untitled or newly created blank notes without generating invalid states or database errors.
- **Missing or Unavailable OAuth Profile Photo**: If an OAuth provider does not return a profile photo or the user registers without OAuth, the system MUST gracefully fall back to a default visual avatar (e.g., user initials) without errors or broken image icons.

## Requirements *(mandatory)*

### Functional Requirements

#### Authentication & Account Management
- **FR-001**: System MUST provide user registration with name, unique email, and secure password validation.
- **FR-002**: System MUST provide secure session authentication (login and logout) with encrypted session persistence, including support for external OAuth authentication.
- **FR-003**: System MUST isolate each user's private workspace, ensuring that unshared folders and notes are strictly invisible to other users.
- **FR-020**: System MUST support an optional profile photo attribute on the user account (`profile_photo`), automatically populated from the external OAuth provider when authenticating via OAuth, and displayed in user navigation and collaboration presence views with a fallback to user initials when absent.

#### Rich Text Editing & Debounced Auto-Save
- **FR-004**: System MUST provide a rich text editor supporting core typography and structural blocks: Headings (H1, H2, H3), Bold, Italic, Strikethrough, Bullet Lists, Numbered Lists, Blockquotes, and Code Blocks.
- **FR-005**: System MUST automatically persist note modifications (title and rich text content) after a period of typing inactivity controlled by a debounce interval (defaulting to 750 milliseconds).
- **FR-006**: System MUST visually convey auto-save states in real time: "Saving..." while the background save is in progress, and "Saved" (with timestamp or icon) when successfully committed.
- **FR-007**: System MUST provide a manual "Save Now" fallback or keyboard shortcut (Ctrl+S / Cmd+S) to force immediate persistence without waiting for debounce expiration.

#### Organization Hierarchy (Folders & Nested Sub-Pages)
- **FR-008**: System MUST allow users to create, rename, and delete organizational Folders in their workspace.
- **FR-009**: System MUST allow notes to be placed inside Folders.
- **FR-010**: System MUST allow any note to have one or more child notes (nested sub-pages), supporting multi-level document hierarchy.
- **FR-011**: System MUST present a hierarchical navigation sidebar reflecting the tree structure of folders, notes, and sub-pages, with collapsible and expandable nodes.

#### Real-Time Collaboration
- **FR-012**: Note owners MUST be able to invite other registered users as Collaborators via their registered email address.
- **FR-013**: System MUST support concurrent real-time editing of the note canvas for all active collaborators connected to the same note.
- **FR-014**: System MUST display real-time presence indicators (e.g., active user avatars using their OAuth profile photo or name/initials badges) showing which collaborators are currently viewing or editing the note.
- **FR-015**: Note owners MUST be able to view the list of collaborators and revoke collaboration access at any time.

#### Public Sharing & Publishing
- **FR-016**: Note owners MUST be able to toggle public sharing on or off for individual notes.
- **FR-017**: When public sharing is enabled, the system MUST generate a secure, unique, unguessable public link (obfuscated token/slug).
- **FR-018**: Anyone with the public link MUST be able to read the formatted note content without authentication in a distraction-free, strictly read-only interface.
- **FR-019**: Disabling public sharing MUST immediately invalidate public access to that note.

### Key Entities *(include if feature involves data)*

- **User**: Represents a registered account with identity attributes (name, email, optional `profile_photo` reference populated via OAuth, password credentials, account timestamps).
- **Folder**: An organizational container belonging to a user, with attributes (name, user reference, optional parent folder reference for nested folders, timestamps).
- **Note / Page**: A rich text document entity with attributes:
  - Title (string)
  - Content (rich text document structure / HTML / structured blocks)
  - Owner reference (User)
  - Optional Folder reference (Folder)
  - Optional Parent Note reference (Note, for sub-page nesting)
  - Public sharing flag (boolean)
  - Public share token (unique string / slug)
  - Timestamps (created_at, updated_at)
- **Collaborator / Note Membership**: Represents an authorized collaboration relationship between a User and a Note, with attributes:
  - Note reference
  - User reference (collaborator)
  - Role / Permissions (Editor)
  - Created timestamp

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Debounced auto-save initiates persistence within 800ms of user typing cessation, and 100% of persisted edits are retained without loss upon immediate page reload.
- **SC-002**: Changes made by one collaborator in a shared note propagate and render in other active collaborators' sessions in under 1 second under standard broadband conditions.
- **SC-003**: Publicly shared notes render in under 1.5 seconds for unauthenticated visitors, presenting 100% of formatted rich text content accurately.
- **SC-004**: Users can create a nested sub-page within an existing note in 3 clicks or fewer from the note editor interface.
- **SC-005**: 95% of users in testing can create an account, compose a formatted note, and organize it into a folder or sub-page in under 3 minutes on their initial session without external training.
- **SC-006**: In simulated network disconnection scenarios, 0% of typed content is lost; unsaved state is flagged to the user and synced automatically upon reconnection.

## Assumptions

- Users access the application via modern desktop or mobile evergreen web browsers (Chrome, Firefox, Safari, Edge) with JavaScript enabled.
- Rich text editing supports essential document blocks (headings, lists, quotes, inline bold/italic/code) without requiring complex desktop publishing features like multi-column pagination or desktop page breaks.
- Public sharing is strictly read-only; anonymous visitors cannot edit or comment on published notes.
- Collaborators must have an existing registered account in the system to be granted editing access to private notes.
- The default debounce delay is 750 milliseconds, providing a balanced threshold between responsiveness and server request frequency.
- User profile photos (`profile_photo`) in this specification are optional and populated solely from OAuth identity providers during OAuth authentication; direct manual file upload and image management by the user are out of scope for this specification and deferred to future specifications.
