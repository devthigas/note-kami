<!--
Sync Impact Report:
- Version change: initial template -> 1.0.0
- List of modified principles:
  - Princípio 1 (Original) -> I. The Rails Way, Convenção sobre Configuração & Fat Model, Thin Controller
  - Princípio 2 (Original) -> II. Zero Gem Bloat & Vanilla Rails (Aproveitamento Máximo do Rails 8)
  - Princípio 3 (Original) -> III. Elegância do Ruby, Simplicidade & Código Limpo (Omakase)
  - Princípio 4 (Original) -> IV. Test-Driven Development (TDD) & Qualidade Não-Negociável
  - Princípio 5 (Original) -> V. UI e UX Design Moderno, Reativo e Acessível (Hotwire & Tailwind)
  - (Adicionado) -> VI. Escalabilidade Nativa, Desempenho & Eficiência de Banco (Solid Suite)
  - (Adicionado) -> VII. Tarefas Especificadas para Execução Humana & Critérios de Aceite Claros
- Added sections:
  - Restrições Tecnológicas e Arquiteturais (Rails 8 Modern Stack)
  - Fluxo de Desenvolvimento, Qualidade e Critérios de Aceite
- Removed sections:
  - None
- Follow-up TODOs:
  - None
-->

# NoteKami Constitution

## Core Principles

### I. The Rails Way, Convenção sobre Configuração & Fat Model, Thin Controller
- **Convenção sobre Configuração**: O código DEVE (MUST) respeitar estritamente as convenções,
  nomenclaturas e padrões idiomáticos do Rails. Desenvolvedores NÃO DEVEM (MUST NOT) reinventar
  roteamentos proprietários, hierarquias exóticas de diretórios ou padrões arquiteturais alheios
  quando o Rails já fornecer uma solução opinativa consolidada.
- **Thin Controllers**: Controllers DEVEM (MUST) ser mantidos extremamente magros e focados.
  Sua única responsabilidade é receber parâmetros HTTP, invocar autenticação/autorização,
  chamar métodos de negócio no modelo e responder (render/redirect). Controllers NÃO DEVEM (MUST NOT)
  executar consultas SQL complexas, transformações de dados ou regras de negócio de múltiplos passos.
- **Fat Models & Domínio Coeso**: A regra de negócio, validações, cálculos de domínio e escopos
  DEVEM (MUST) residir primariamente nos models. Quando a complexidade do modelo justificar divisão,
  a modularização DEVE (MUST) utilizar `ActiveSupport::Concern` ou objetos Ruby simples (POROs)
  altamente coesos, preservando a interface natural do ActiveRecord.
- **Roteamento RESTful**: Rotas DEVEM (MUST) priorizar recursos CRUD (`resources`), mapeando ações
  de usuário para verbos e entidades REST padrão, evitando rotas RPC ou arbitrárias.
- **Rationale**: Adotar as convenções consagradas do Rails reduz expressivamente o custo cognitivo,
  elimina discussões de boilerplate e acelera a manutenibilidade e leitura por humanos.

### II. Zero Gem Bloat & Vanilla Rails (Aproveitamento Máximo do Rails 8)
- **Prioridade Nativa**: O projeto DEVE (MUST) esgotar todos os recursos nativos do Rails 8 e da
  biblioteca padrão do Ruby antes de considerar a adição de qualquer biblioteca ou gem externa.
- **Justificativa Rigorosa para Dependências**: A introdução de qualquer nova gem no `Gemfile`
  DEVE (MUST) ser justificada com comprovação de que não existe alternativa viável no Rails 8 e
  que o custo de manutenção da dependência externa é comprovadamente inferior à solução nativa.
- **Adoção do Ecossistema Nativo Rails 8**:
  - **Autenticação**: DEVE (MUST) utilizar o gerador nativo de autenticação do Rails 8
    (`has_secure_password`, sessões e cookies seguros), evitando bibliotecas pesadas de terceiros.
  - **Serviços de Background, Cache e Mensageria**: DEVE (MUST) utilizar a suíte Solid integrada
    (`Solid Queue`, `Solid Cache`, `Solid Cable`), mantendo a infraestrutura enxuta e sem
    dependência obrigatória de serviços externos adicionais (como Redis).
  - **Pipeline de Assets & JS**: DEVE (MUST) utilizar Propshaft e Importmaps (`importmap-rails`)
    com Vanilla JavaScript/ESM, dispensando Node.js, Webpack ou Vite no fluxo padrão.
- **Rationale**: Gems externas aumentam a superfície de vulnerabilidade, quebram em upgrades e
  aumentam o tempo de inicialização. O Rails 8 é completo e autossuficiente para criar produtos
  modernos com autonomia e mínimo atrito.

### III. Elegância do Ruby, Simplicidade & Código Limpo (Omakase)
- **Expressividade e Clareza**: O código DEVE (MUST) valorizar a elegância, fluidez e legibilidade
  naturais da linguagem Ruby. Código limpo e autodocumentado DEVE (MUST) prevalecer sobre
  construções "espertas", enigmáticas ou concisão artificial.
- **Simplicidade (YAGNI & KISS)**: É terminantemente proibido (MUST NOT) criar abstrações prematuras
  (ex: camadas desnecessárias de services, interactors, form objects, repositories fictícios)
  enquanto a complexidade do domínio não exigir formalmente. A simplicidade inicial é o padrão.
- **Estilo Omakase**: O estilo de código DEVE (MUST) seguir as diretrizes do `rubocop-rails-omakase`.
  Nomes de métodos e variáveis DEVEM ser semanticamente precisos em inglês, com métodos pequenos,
  responsabilidade única e ausência de efeitos colaterais ocultos.
- **Rationale**: Sistemas sustentáveis são fáceis de ler, alterar e depurar por qualquer desenvolvedor.
  A elegância do Ruby reside em dizer muito com clareza, sem complexidade acidental.

### IV. Test-Driven Development (TDD) & Qualidade Não-Negociável
- **Ciclo TDD Obrigatório**: O desenvolvimento de novas funcionalidades e correções de defeitos
  DEVE (MUST) seguir o ciclo rigoroso de Red-Green-Refactor:
  1. Escrever o teste automatizado que expressa o comportamento esperado e observar a falha (Red);
  2. Implementar a solução mais simples e elegante para fazer o teste passar (Green);
  3. Refatorar o código eliminando duplicações e melhorando a estrutura com testes verdes (Refactor).
- **Sem Código sem Teste**: Nenhuma alteração funcional DEVE (MUST NOT) ser integrada sem testes
  automatizados correspondentes.
- **Pirâmide e Ferramental de Testes**:
  - Testes DEVEM (MUST) utilizar a suíte padrão do Rails baseada em `Minitest` (`rails test`),
    organizados em testes de unidade (models), testes de integração (requests) e testes de sistema.
  - Testes de sistema (`system tests`) DEVEM (MUST) cobrir os fluxos críticos de ponta a ponta
    do usuário final no navegador.
  - Testes DEVEM (MUST) ser determinísticos, rápidos e independentes, sem dependência de ordem.
- **Rationale**: Testes automatizados escritos com antecedência garantem que o software cumpre
  seus critérios de aceite, asseguram regressão zero e conferem coragem para refatorações contínuas.

### V. UI e UX Design Moderno, Reativo e Acessível (Hotwire & Tailwind)
- **Reatividade com Hotwire**: A experiência de usuário (UX) DEVE (MUST) ser dinâmica, rápida e
  sem recarregamentos desnecessários de página, tirando proveito total de Turbo Drive, Turbo Frames,
  Turbo Streams e Turbo 8 Morphing.
- **Renderização no Servidor First**: Atualizações de interface DEVEM (MUST) priorizar renderização
  HTML no servidor via Turbo antes de recorrer a scripts customizados no navegador.
- **Stimulus para Comportamentos Declarativos**: Qualquer comportamento dinâmico no cliente DEVE (MUST)
  ser implementado como um Stimulus Controller leve, focado, coeso e desacoplado, sem frameworks SPA.
- **Design Elegante e Acessível com Tailwind**: A interface (UI) DEVE (MUST) ser construída com
  Tailwind CSS, garantindo responsividade mobile-first, consistência tipográfica, contraste acessível
  (WCAG 2.1 AA) e feedback visual imediato para ações do usuário (loading, sucesso, erro).
- **Rationale**: Hotwire e Tailwind proporcionam a fluidez de uma Single Page Application com a
  velocidade de entrega, manutenibilidade e simplicidade operacional do Rails tradicional.

### VI. Escalabilidade Nativa, Desempenho & Eficiência de Banco (Solid Suite)
- **Consultas Otimizadas & Prevenção de N+1**: É expressamente proibido (MUST NOT) introduzir
  queries N+1 em telas e listagens. O carregamento antecipado (`includes`, `preload`, `strict_loading`)
  DEVE (MUST) ser validado em todas as ações de leitura de coleções.
- **Indexação Estruturada**: Toda chave estrangeira, coluna de busca frequente ou campo com
  restrição de unicidade DEVE (MUST) possuir índice explícito no banco de dados.
- **Processamento Assíncrono**: Tarefas demoradas (envio de emails, integrações, processamento de
  arquivos) DEVEM (MUST) ser executadas em background via Active Job com `Solid Queue`.
- **Estratégias de Cache Eficientes**: Endpoints e componentes de visualização com alto volume de
  acesso DEVEM (MUST) explorar fragment caching e russian-doll caching via `Solid Cache`.
- **Rationale**: A escalabilidade deve ser obtida com eficiência arquitetural e bom uso do banco,
  mantendo custos baixos e capacidade de atender alta demanda sem exigir microserviços prematuros.

### VII. Tarefas Especificadas para Execução Humana & Critérios de Aceite Claros
- **Foco no Desenvolvedor Humano**: Toda documentação, especificação de funcionalidade e lista de
  tarefas DEVE (MUST) ser escrita de maneira clara, pedagógica e autossuficiente para que qualquer
  desenvolvedor humano consiga executá-la de ponta a ponta sem recorrer a agentes de inteligência
  artificial ou depender de premissas não declaradas.
- **Critérios de Aceite Inequívocos (Definition of Done)**: Cada tarefa DEVE (MUST) declarar critérios
  de aceite objetivos e verificáveis (ex: no formato Given/When/Then ou checklist verificável).
- **Informações Obrigatórias por Tarefa**: Toda tarefa técnica DEVE (MUST) especificar:
  1. Objetivo conciso da mudança;
  2. Arquivos exatos que devem ser criados, alterados ou removidos;
  3. Passo a passo lógico de implementação;
  4. Comandos exatos para validação automatizada e passos de teste manual no navegador.
- **Atomicidade e Sequenciamento**: Tarefas DEVEM (MUST) ser atômicas, de escopo delimitado e
  ordenadas logicamente por dependência, facilitando commits limpos e revisões de código objetivas.
- **Rationale**: O julgamento e a maestria dos desenvolvedores humanos são a base da entrega de
  software de alto impacto. Tarefas bem estruturadas eliminam retrabalho e alinham expectativas.

## Restrições Tecnológicas e Arquiteturais (Rails 8 Modern Stack)

- **Linguagem & Framework**:
  - Ruby 3.3+ (conforme definido em `.ruby-version`).
  - Ruby on Rails 8.1+ (`~> 8.1.4` com `config.load_defaults 8.1`).
- **Camada de Apresentação e Assets**:
  - Propshaft como pipeline moderno de assets (sem Sprockets).
  - Importmaps (`importmap-rails`) gerenciando dependências JavaScript como módulos ESM sem Node.js.
  - Hotwire (`turbo-rails` + `stimulus-rails`) para toda dinâmica de interface.
  - Tailwind CSS (`tailwindcss-rails`) para estilização utilitária e responsiva.
- **Infraestrutura de Dados & Serviços Rails 8 (Solid Suite)**:
  - Banco de Dados: SQLite3 em desenvolvimento/testes com suporte a concorrência WAL, ou banco
    relacional padrão (PostgreSQL/MySQL) conforme ambiente.
  - Filas e Jobs em Background: `Solid Queue`.
  - Caching de Aplicação: `Solid Cache`.
  - WebSockets e Real-Time: `Solid Cable`.
  - Autenticação de Usuários: Solução nativa do Rails com `has_secure_password` e gerenciamento de
    sessões via cookies assinados/criptografados.
- **Gestão de Dependências de Terceiros**:
  - Novas gems só podem ser introduzidas após verificação de ausência de solução equivalente
    no Ruby padrão ou no Rails 8, exigindo aprovação prévia no processo de code review.

## Fluxo de Desenvolvimento, Qualidade e Critérios de Aceite

- **Etapas do Ciclo de Vida da Feature**:
  1. **Especificação**: Definição da funcionalidade com critérios de aceite detalhados e casos
     de uso explícitos antes de qualquer código de produção.
  2. **Planejamento & Decomposição em Tarefas Humanas**: Decomposição em tarefas atômicas contendo
     arquivos envolvidos, passos de implementação e testes de validação.
  3. **Execução Orientada a TDD**: Escrita do teste com falha inicial (`Red`), implementação mínima
     necessária (`Green`) e limpeza de código (`Refactor`).
  4. **Auditoria de Estilo e Linter**: Execução de `bin/rubocop` para garantir conformidade total
     com as diretrizes do `rubocop-rails-omakase`.
  5. **Verificação dos Critérios de Aceite**: Validação de cada critério de aceite definido na tarefa
     através de testes unitários, testes de integração e testes de sistema no navegador.
- **Quality Gates para Aprovação (CI / PR Checklist)**:
  - Todo PR DEVE (MUST) passar com 100% de sucesso em `bin/rails test`.
  - Todo PR com alteração de interface DEVE (MUST) validar fluxos em `bin/rails test:system`.
  - Todo PR DEVE (MUST) ter zero ofensas no `bin/rubocop`.
  - Todo PR DEVE (MUST) demonstrar conformidade com os 7 princípios desta constituição.

## Governance

- **Supremacia da Constituição**: Esta Constituição representa o acordo técnico soberano do projeto
  NoteKami e se sobrepõe a quaisquer preferências informais de implementação. Nenhuma funcionalidade
  pode ser mergeada em desacordo com os princípios `MUST` aqui estabelecidos.
- **Processo de Emenda**: Qualquer alteração, inclusão ou revogação de princípios DEVE (MUST) ser
  submetida por meio de um Pull Request exclusivo de governança, contendo justificativa técnica,
  análise de impacto na base de código e plano de migração quando aplicável.
- **Política de Versionamento Semântico da Constituição**:
  - **MAJOR (ex: 2.0.0)**: Alterações, revogações ou redefinições que quebrem a compatibilidade
    com princípios `MUST` anteriores.
  - **MINOR (ex: 1.1.0)**: Adição de novos princípios, novas seções ou expansão substancial
    de diretrizes sem invalidar as regras anteriores.
  - **PATCH (ex: 1.0.1)**: Correções gramaticais, esclarecimentos textuais e refinamentos que não
    alterem o significado normativo dos princípios.
- **Revisão e Cumprimento Contínuo**: As revisões de código (Code Reviews) e inspeções do Spec Kit
  DEVEM (MUST) validar explicitamente a adesão a esta constituição antes da aprovação final de
  qualquer entrega.

**Version**: 1.0.0 | **Ratified**: 2026-10-15 | **Last Amended**: 2026-10-15
