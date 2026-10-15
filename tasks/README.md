# NoteKami - Detalhamento das Tarefas de Implementação

Este diretório reúne as especificações detalhadas de execução para cada uma das **48 tarefas técnicas** do workspace colaborativo do NoteKami, em conformidade estrita com o **Princípio VII da Constituição do Projeto** (*Tarefas Especificadas para Execução Humana & Critérios de Aceite Claros*).

Cada documento contém:
1. **Objetivo Técnico** contextualizado na arquitetura Rails 8 Vanilla (Solid Suite + Hotwire + Tailwind).
2. **Arquivos Impactados** com mapeamento exato de criação, modificação ou leitura.
3. **Passo a Passo de Implementação** com comandos, orientações de modelagem e padrões idiomáticos do Rails.
4. **Critérios de Aceite (Definition of Done)** mensuráveis no formato checklist.
5. **Comandos de Validação Automatizada e Roteiro de Teste Manual**.

---

## Matriz Geral de Tarefas

| Task ID | Issue GitHub | Prioridade | Título da Tarefa | Fase do Projeto |
| :--- | :--- | :--- | :--- | :--- |
| [T001](./T001.md) | [#5](https://github.com/devthigas/note-kami/issues/5) | P1 | Add gem "lexxy" and development dependency gem "hotwire-spark" to Gemfile and run bundle install | Phase 1: Setup (Shared Infrastructure) |
| [T002](./T002.md) | [#6](https://github.com/devthigas/note-kami/issues/6) | P1 | Configure multi-database SQLite3 and Solid Cable in config/database.yml and config/cable.yml | Phase 1: Setup (Shared Infrastructure) |
| [T003](./T003.md) | [#7](https://github.com/devthigas/note-kami/issues/7) | P1 | Configure Lexxy and Stimulus pins in config/importmap.rb and app/javascript/application.js | Phase 1: Setup (Shared Infrastructure) |
| [T004](./T004.md) | [#8](https://github.com/devthigas/note-kami/issues/8) | P1 | Create database migration for users, sessions, and oauth_identities in db/migrate/ | Phase 2: Foundational (Blocking Prerequisites) |
| [T005](./T005.md) | [#9](https://github.com/devthigas/note-kami/issues/9) | P1 | Implement base User, Session, and Current models in app/models/user.rb, app/models/session.rb, and app/models/current.rb | Phase 2: Foundational (Blocking Prerequisites) |
| [T006](./T006.md) | [#10](https://github.com/devthigas/note-kami/issues/10) | P1 | Implement authentication controller concern in app/controllers/concerns/authentication.rb | Phase 2: Foundational (Blocking Prerequisites) |
| [T007](./T007.md) | [#11](https://github.com/devthigas/note-kami/issues/11) | P1 | Configure development mailer delivery and base layout in config/environments/development.rb and app/views/layouts/application.html.erb | Phase 2: Foundational (Blocking Prerequisites) |
| [T008](./T008.md) | [#12](https://github.com/devthigas/note-kami/issues/12) | P1 | Unit and request tests for Magic Link generation and session verification in test/models/user_test.rb and test/controllers/magic_links_controller_test.rb | Phase 3: User Story 1 - User Authentication & Personal Notebook Setup |
| [T009](./T009.md) | [#13](https://github.com/devthigas/note-kami/issues/13) | P1 | System test for end-to-end Magic Link login flow in test/system/authentication_test.rb | Phase 3: User Story 1 - User Authentication & Personal Notebook Setup |
| [T010](./T010.md) | [#14](https://github.com/devthigas/note-kami/issues/14) | P1 | Implement generates_token_for magic_link in app/models/user.rb | Phase 3: User Story 1 - User Authentication & Personal Notebook Setup |
| [T011](./T011.md) | [#15](https://github.com/devthigas/note-kami/issues/15) | P1 | Implement MagicLinkMailer in app/mailers/magic_link_mailer.rb and app/views/magic_link_mailer/sign_in_link.html.erb | Phase 3: User Story 1 - User Authentication & Personal Notebook Setup |
| [T012](./T012.md) | [#16](https://github.com/devthigas/note-kami/issues/16) | P1 | Implement MagicLinksController in app/controllers/magic_links_controller.rb and app/views/magic_links/new.html.erb | Phase 3: User Story 1 - User Authentication & Personal Notebook Setup |
| [T013](./T013.md) | [#17](https://github.com/devthigas/note-kami/issues/17) | P1 | Implement Google OAuth flow in app/controllers/oauth_controller.rb and app/models/oauth_identity.rb | Phase 3: User Story 1 - User Authentication & Personal Notebook Setup |
| [T014](./T014.md) | [#18](https://github.com/devthigas/note-kami/issues/18) | P1 | Implement SessionsController in app/controllers/sessions_controller.rb and app/views/sessions/new.html.erb | Phase 3: User Story 1 - User Authentication & Personal Notebook Setup |
| [T015](./T015.md) | [#19](https://github.com/devthigas/note-kami/issues/19) | P1 | Implement DashboardController in app/controllers/dashboard_controller.rb and app/views/dashboard/index.html.erb | Phase 3: User Story 1 - User Authentication & Personal Notebook Setup |
| [T016](./T016.md) | [#20](https://github.com/devthigas/note-kami/issues/20) | P1 | Unit and request tests for Note CRUD and debounced auto-save in test/models/note_test.rb and test/controllers/notes_controller_test.rb | Phase 4: User Story 2 - Rich Text Note Creation & Auto-Save |
| [T017](./T017.md) | [#21](https://github.com/devthigas/note-kami/issues/21) | P1 | System test for Lexxy editor and auto-save persistence in test/system/notes_editing_test.rb | Phase 4: User Story 2 - Rich Text Note Creation & Auto-Save |
| [T018](./T018.md) | [#22](https://github.com/devthigas/note-kami/issues/22) | P1 | Create database migration for notes and Action Text in db/migrate/ | Phase 4: User Story 2 - Rich Text Note Creation & Auto-Save |
| [T019](./T019.md) | [#23](https://github.com/devthigas/note-kami/issues/23) | P1 | Implement Note model in app/models/note.rb | Phase 4: User Story 2 - Rich Text Note Creation & Auto-Save |
| [T020](./T020.md) | [#24](https://github.com/devthigas/note-kami/issues/24) | P1 | Implement NotesController in app/controllers/notes_controller.rb | Phase 4: User Story 2 - Rich Text Note Creation & Auto-Save |
| [T021](./T021.md) | [#25](https://github.com/devthigas/note-kami/issues/25) | P1 | Implement Stimulus auto-save controller in app/javascript/controllers/auto_save_controller.js | Phase 4: User Story 2 - Rich Text Note Creation & Auto-Save |
| [T022](./T022.md) | [#26](https://github.com/devthigas/note-kami/issues/26) | P1 | Build note editing views and Lexxy form in app/views/notes/edit.html.erb and app/views/notes/_form.html.erb | Phase 4: User Story 2 - Rich Text Note Creation & Auto-Save |
| [T023](./T023.md) | [#27](https://github.com/devthigas/note-kami/issues/27) | P2 | Unit and request tests for Folder hierarchy and cycle prevention in test/models/folder_test.rb and test/controllers/folders_controller_test.rb | Phase 5: User Story 3 - Hierarchical Organization with Folders & Sub-pages |
| [T024](./T024.md) | [#28](https://github.com/devthigas/note-kami/issues/28) | P2 | System test for folder creation and sub-page nesting in test/system/note_organization_test.rb | Phase 5: User Story 3 - Hierarchical Organization with Folders & Sub-pages |
| [T025](./T025.md) | [#29](https://github.com/devthigas/note-kami/issues/29) | P2 | Create database migration for folders and note hierarchy fields in db/migrate/ | Phase 5: User Story 3 - Hierarchical Organization with Folders & Sub-pages |
| [T026](./T026.md) | [#30](https://github.com/devthigas/note-kami/issues/30) | P2 | Implement Folder model with cycle validation in app/models/folder.rb | Phase 5: User Story 3 - Hierarchical Organization with Folders & Sub-pages |
| [T027](./T027.md) | [#31](https://github.com/devthigas/note-kami/issues/31) | P2 | Update Note model with sub-page associations and cycle validation in app/models/note.rb | Phase 5: User Story 3 - Hierarchical Organization with Folders & Sub-pages |
| [T028](./T028.md) | [#32](https://github.com/devthigas/note-kami/issues/32) | P2 | Implement FoldersController in app/controllers/folders_controller.rb | Phase 5: User Story 3 - Hierarchical Organization with Folders & Sub-pages |
| [T029](./T029.md) | [#33](https://github.com/devthigas/note-kami/issues/33) | P2 | Add sub-pages action to NotesController in app/controllers/notes_controller.rb | Phase 5: User Story 3 - Hierarchical Organization with Folders & Sub-pages |
| [T030](./T030.md) | [#34](https://github.com/devthigas/note-kami/issues/34) | P2 | Build sidebar tree partial and tree Stimulus controller in app/views/shared/_sidebar_tree.html.erb and app/javascript/controllers/tree_controller.js | Phase 5: User Story 3 - Hierarchical Organization with Folders & Sub-pages |
| [T031](./T031.md) | [#35](https://github.com/devthigas/note-kami/issues/35) | P2 | Unit and channel tests for NoteCollaborator and NoteChannel in test/models/note_collaborator_test.rb and test/channels/note_channel_test.rb | Phase 6: User Story 4 - Real-Time Collaboration & Peer Presence |
| [T032](./T032.md) | [#36](https://github.com/devthigas/note-kami/issues/36) | P2 | System test for multi-user collaboration and presence in test/system/collaborative_presence_test.rb | Phase 6: User Story 4 - Real-Time Collaboration & Peer Presence |
| [T033](./T033.md) | [#37](https://github.com/devthigas/note-kami/issues/37) | P2 | Create database migration for note_collaborators in db/migrate/ | Phase 6: User Story 4 - Real-Time Collaboration & Peer Presence |
| [T034](./T034.md) | [#38](https://github.com/devthigas/note-kami/issues/38) | P2 | Implement NoteCollaborator model in app/models/note_collaborator.rb | Phase 6: User Story 4 - Real-Time Collaboration & Peer Presence |
| [T035](./T035.md) | [#39](https://github.com/devthigas/note-kami/issues/39) | P2 | Implement NoteChannel with presence tracking in app/channels/note_channel.rb | Phase 6: User Story 4 - Real-Time Collaboration & Peer Presence |
| [T036](./T036.md) | [#40](https://github.com/devthigas/note-kami/issues/40) | P2 | Implement CollaboratorsController in app/controllers/collaborators_controller.rb | Phase 6: User Story 4 - Real-Time Collaboration & Peer Presence |
| [T037](./T037.md) | [#41](https://github.com/devthigas/note-kami/issues/41) | P2 | Implement Stimulus presence controller in app/javascript/controllers/presence_controller.js | Phase 6: User Story 4 - Real-Time Collaboration & Peer Presence |
| [T038](./T038.md) | [#42](https://github.com/devthigas/note-kami/issues/42) | P2 | Build collaborator drawer and presence avatar partials in app/views/notes/_collaborators_drawer.html.erb and app/views/notes/_presence_avatars.html.erb | Phase 6: User Story 4 - Real-Time Collaboration & Peer Presence |
| [T039](./T039.md) | [#43](https://github.com/devthigas/note-kami/issues/43) | P3 | Request and model tests for public note sharing in test/controllers/public_notes_controller_test.rb | Phase 7: User Story 5 - Public Note Sharing via Read-Only Tokenized Link |
| [T040](./T040.md) | [#44](https://github.com/devthigas/note-kami/issues/44) | P3 | System test for public note viewing in test/system/public_sharing_test.rb | Phase 7: User Story 5 - Public Note Sharing via Read-Only Tokenized Link |
| [T041](./T041.md) | [#45](https://github.com/devthigas/note-kami/issues/45) | P3 | Implement public_share toggle action in app/controllers/notes_controller.rb | Phase 7: User Story 5 - Public Note Sharing via Read-Only Tokenized Link |
| [T042](./T042.md) | [#46](https://github.com/devthigas/note-kami/issues/46) | P3 | Implement PublicNotesController in app/controllers/public_notes_controller.rb | Phase 7: User Story 5 - Public Note Sharing via Read-Only Tokenized Link |
| [T043](./T043.md) | [#47](https://github.com/devthigas/note-kami/issues/47) | P3 | Build distraction-free public note layout and view in app/views/layouts/public_note.html.erb and app/views/public_notes/show.html.erb | Phase 7: User Story 5 - Public Note Sharing via Read-Only Tokenized Link |
| [T044](./T044.md) | [#48](https://github.com/devthigas/note-kami/issues/48) | P3 | Build public share modal in app/views/notes/_share_modal.html.erb | Phase 7: User Story 5 - Public Note Sharing via Read-Only Tokenized Link |
| [T045](./T045.md) | [#49](https://github.com/devthigas/note-kami/issues/49) | P1 | Run RuboCop Omakase style audit and auto-correct across the codebase | Phase 8: Polish & Cross-Cutting Concerns |
| [T046](./T046.md) | [#50](https://github.com/devthigas/note-kami/issues/50) | P1 | Add strict_loading and eager loading to eliminate N+1 queries in app/controllers/dashboard_controller.rb and app/controllers/notes_controller.rb | Phase 8: Polish & Cross-Cutting Concerns |
| [T047](./T047.md) | [#51](https://github.com/devthigas/note-kami/issues/51) | P1 | Execute complete quickstart validation scenarios from specs/001-collaborative-notebook/quickstart.md | Phase 8: Polish & Cross-Cutting Concerns |
| [T048](./T048.md) | [#52](https://github.com/devthigas/note-kami/issues/52) | P1 | Run complete automated test suite | Phase 8: Polish & Cross-Cutting Concerns |

---

### Documentos de Referência
- **Especificação da Funcionalidade**: [`specs/001-collaborative-notebook/spec.md`](../specs/001-collaborative-notebook/spec.md)
- **Plano de Implementação**: [`specs/001-collaborative-notebook/plan.md`](../specs/001-collaborative-notebook/plan.md)
- **Modelo de Dados**: [`specs/001-collaborative-notebook/data-model.md`](../specs/001-collaborative-notebook/data-model.md)
- **Contratos HTTP**: [`specs/001-collaborative-notebook/contracts/http-api.md`](../specs/001-collaborative-notebook/contracts/http-api.md)
- **Contratos de Cable**: [`specs/001-collaborative-notebook/contracts/cable-channels.md`](../specs/001-collaborative-notebook/contracts/cable-channels.md)
- **Roteiro Quickstart**: [`specs/001-collaborative-notebook/quickstart.md`](../specs/001-collaborative-notebook/quickstart.md)
