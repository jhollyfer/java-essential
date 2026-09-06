// Zed settings — https://zed.dev/docs/configuring-zed
// `zed: open default settings` na paleta mostra todos os padrões.
//
// ATENÇÃO: este arquivo é o TEMPLATE — a fonte de verdade fica em
// zed-setup/settings.jsonc.tpl no repo. Não edite ~/.config/zed/settings.json
// à mão; edite o template e rode `sh zed-setup/install.sh`.
//
// Os dois marcadores de JDK (em lsp.jdtls) são substituídos pelo install.sh a
// partir dos JDKs que o sdkman tem instalados NESTA máquina.
{
  // ─────────────────────────────────────────────────────────────────────────
  // Extensões que o Zed garante instaladas (não desinstala as demais)
  //
  // Não existe `zed --install-extension`. Este bloco é o único mecanismo de
  // instalação automática: o Zed lê e instala no primeiro launch.
  //
  // Fora daqui de propósito: "postgres-language-server" (precisa de
  // postgrestools.jsonc apontando pro banco — ligar global vira ruído; habilite
  // no .zed/settings.json dos projetos Postgres) e "ruff" (é builtin do Zed).
  // ─────────────────────────────────────────────────────────────────────────
  "auto_install_extensions": {
    "html": true,
    "java": true,
    "php": true,
    "prisma": true,
    "toml": true,
    "env": true,
    "xml": true,
    "biome": true,
    "git-firefly": true,
    "docker-compose": true,
    "dockerfile": true,
    "sql": true,
    "edge": true,
    "graphql": true,
    "mdx": true,
    "github-actions": true,
  },

  "agent_servers": {
    "claude-acp": {
      "type": "registry",
    },
  },

  // ─────────────────────────────────────────────────────────────────────────
  // Aparência
  // ─────────────────────────────────────────────────────────────────────────
  "theme": {
    "mode": "dark",
    "light": "Ayu Light",
    "dark": "Ayu Dark",
  },
  "icon_theme": "Zed (Default)",
  "ui_font_family": "JetBrains Mono",
  "ui_font_size": 16,
  "buffer_font_size": 16,
  "agent_buffer_font_family": "JetBrains Mono",

  // ─────────────────────────────────────────────────────────────────────────
  // Editor
  // ─────────────────────────────────────────────────────────────────────────
  "tab_size": 2,
  "format_on_save": "on",
  "ensure_final_newline_on_save": true,
  "remove_trailing_whitespace_on_save": true,
  "soft_wrap": "editor_width",

  // O toggle global só manda o editor DESENHAR as dicas. Cada LSP ainda
  // precisa ser mandado EMITI-LAS — veja os blocos vtsls/jdtls/pyright abaixo.
  "inlay_hints": {
    "enabled": true,
    "show_type_hints": true,
    "show_parameter_hints": true,
    "show_other_hints": true,
  },

  // Nunca mandados para agentes/IA e mascarados no editor.
  // Não há sintaxe de negação: "**/.env.*" também pega .env.example. Se
  // incomodar, troque pelos globs específicos (.env.local, .env.production...).
  "private_files": [
    "**/.env",
    "**/.env.*",
    "**/*.pem",
    "**/*.key",
    "**/*.p12",
    "**/*.crt",
    "**/id_rsa*",
    "**/secrets.*",
    "**/.npmrc",
    "**/.pgpass",
  ],

  "file_scan_exclusions": [
    "**/.git",
    "**/node_modules",
    "**/dist",
    "**/build",
    "**/out",
    "**/.next",
    "**/.turbo",
    "**/coverage",
    "**/target",
    "**/.gradle",
    // oculta da busca/painel do Zed; o intelephense indexa o vendor por
    // conta própria, então o autocomplete do Composer continua funcionando
    "**/vendor",
    "**/.venv",
    "**/__pycache__",
    "**/.pytest_cache",
    "**/.ruff_cache",
    "**/tmp",
    // TanStack Start + Nitro, Vite, Cloudflare, pnpm
    "**/.output",
    "**/.nitro",
    "**/.tanstack",
    "**/.vinxi",
    "**/.vite",
    "**/.wrangler",
    "**/.pnpm-store",
    // NÃO adicione "**/bin": o AdonisJS v6 põe bin/server.ts, bin/console.ts e
    // bin/test.ts ali. Diretório de saída de projeto Java se exclui por projeto.
  ],

  // A linguagem "GitHub Actions" (da extensão homônima) não declara nenhum
  // path_suffixes — ela nunca casa arquivo sozinha. Sem este mapeamento a
  // extensão fica instalada e inerte, e os workflows continuam como YAML puro,
  // sem schema nem autocomplete.
  "file_types": {
    "GitHub Actions": ["**/.github/workflows/*.yml", "**/.github/workflows/*.yaml"],
  },

  // ─────────────────────────────────────────────────────────────────────────
  // Linguagens
  //
  // Sobre `language_servers`: "..." = o resto dos padrões; "!nome" desliga.
  //
  // Biome: o padrão global aqui é Prettier + ESLint, então o biome é desligado
  // em TODAS as linguagens que a extensão dele registra — JavaScript, JSX,
  // TypeScript, TSX, JSON, JSONC, CSS, HTML, XML e GraphQL. Sem isso ele sobe
  // um processo por sessão até em projeto que não tem package.json.
  //
  // "!graphql": a extensão do GraphQL registra o servidor dela em JavaScript,
  // JSX, TypeScript e TSX (pra gql`` embutido em template literal), não só em
  // .graphql. Como aqui o cliente de API é openapi-fetch, é só um servidor a
  // mais em todo .tsx.
  //
  // "!emmet": a extensão do Edge registra um SEGUNDO emmet (nome "emmet") em
  // HTML e CSS, ao lado do "emmet-language-server" embutido no Zed. Mesmo
  // problema do jdtls duplicado.
  //
  // Num projeto que usa Biome, crie .zed/settings.json na raiz dele com:
  //
  //   {
  //     "languages": {
  //       "TypeScript": {
  //         "language_servers": ["biome", "vtsls", "!eslint", "..."],
  //         "formatter": { "language_server": { "name": "biome" } },
  //         "code_actions_on_format": {
  //           "source.fixAll.biome": true,
  //           "source.organizeImports.biome": true
  //         }
  //       },
  //       "TSX":        { ...igual ao TypeScript... },
  //       "JavaScript": { ...igual ao TypeScript... },
  //       "JSON":       { "language_servers": ["biome", "..."],
  //                       "formatter": { "language_server": { "name": "biome" } } }
  //     }
  //   }
  // ─────────────────────────────────────────────────────────────────────────
  "languages": {
    // ── TypeScript / JavaScript / React ──────────────────────────────────
    "TypeScript": {
      "language_servers": ["vtsls", "eslint", "tailwindcss-language-server", "!biome", "!graphql", "..."],
      "formatter": "prettier",
      "code_actions_on_format": { "source.fixAll.eslint": true },
    },
    "TSX": {
      "language_servers": [
        "vtsls",
        "eslint",
        "tailwindcss-language-server",
        "emmet-language-server",
        "!biome",
        "!graphql",
        "...",
      ],
      "formatter": "prettier",
      "code_actions_on_format": { "source.fixAll.eslint": true },
    },
    "JavaScript": {
      "language_servers": [
        "vtsls",
        "eslint",
        "tailwindcss-language-server",
        "emmet-language-server",
        "!biome",
        "!graphql",
        "...",
      ],
      "formatter": "prettier",
      "code_actions_on_format": { "source.fixAll.eslint": true },
    },
    // O Zed mapeia .jsx para JavaScript, mas a extensão do biome declara "JSX"
    // como linguagem própria. Bloco defensivo.
    "JSX": {
      "language_servers": ["!biome", "!graphql", "..."],
      "formatter": "prettier",
    },

    // ── Web ──────────────────────────────────────────────────────────────
    "HTML": {
      "language_servers": ["...", "tailwindcss-language-server", "emmet-language-server", "!biome", "!emmet"],
      "formatter": "prettier",
    },
    // "tailwindcss-intellisense-css" é builtin do Zed e é o servidor de CSS da
    // própria equipe do Tailwind: entende @theme, @apply, @layer, @plugin,
    // @source, e mantém o IntelliSense de CSS padrão. Substitui o
    // vscode-css-language-server, que marcaria essas at-rules como erro.
    // Se algum dia der problema, é só remover as duas primeiras entradas.
    "CSS": {
      "language_servers": [
        "tailwindcss-intellisense-css",
        "!vscode-css-language-server",
        "...",
        "tailwindcss-language-server",
        "!biome",
        "!emmet",
      ],
      "formatter": "prettier",
    },

    // ── Dados / config ───────────────────────────────────────────────────
    "JSON": { "language_servers": ["...", "!biome"], "formatter": "prettier" },
    "JSONC": { "language_servers": ["...", "!biome"], "formatter": "prettier" },
    "YAML": { "formatter": "prettier" },
    "GraphQL": { "language_servers": ["...", "!biome"], "formatter": "prettier" },
    // Sem language server e sem prettier (o prettier não formata XML sem plugin).
    // format_on_save off para o global "on" não mexer em pom.xml.
    "XML": {
      "language_servers": ["!biome", "..."],
      "prettier": { "allowed": false },
      "format_on_save": "off",
    },
    "Markdown": {
      "formatter": "prettier",
      "soft_wrap": "editor_width",
      // dois espaços no fim da linha são quebra de linha em Markdown
      "remove_trailing_whitespace_on_save": false,
    },
    "MDX": {
      "language_servers": ["...", "!biome"],
      "formatter": "prettier",
      "soft_wrap": "editor_width",
      "remove_trailing_whitespace_on_save": false,
    },

    // ── SQL ──────────────────────────────────────────────────────────────
    // A extensão "sql" só traz gramática (highlight), sem language server.
    // Para diagnóstico real contra o banco, habilite o postgres-language-server
    // no .zed/settings.json do projeto — ele precisa de postgrestools.jsonc:
    //
    //   { "languages": { "SQL": {
    //       "language_servers": ["postgres-language-server", "..."] } } }
    "SQL": { "tab_size": 2 },

    // ── Edge (templates do AdonisJS) ─────────────────────────────────────
    "Edge": {
      "language_servers": ["...", "tailwindcss-language-server", "emmet-language-server"],
      "tab_size": 2,
    },

    // ── Prisma ───────────────────────────────────────────────────────────
    "Prisma": {
      "formatter": "language_server",
      "tab_size": 2,
    },

    // ── PHP ──────────────────────────────────────────────────────────────
    "PHP": {
      "tab_size": 4,
      "language_servers": ["intelephense", "!phpactor", "!phptools", "..."],
      "formatter": "language_server",
      "prettier": { "allowed": false },
    },

    // ── Java ─────────────────────────────────────────────────────────────
    // "!java" desliga o servidor da extensão "Java with Eclipse JDTLS", que
    // subia um segundo jdtls em paralelo com o da extensão oficial. Mantido
    // mesmo com a extensão desinstalada, caso ela volte.
    "Java": {
      "tab_size": 4,
      "language_servers": ["jdtls", "!java", "..."],
      "formatter": "language_server",
      "prettier": { "allowed": false },
    },

    // ── Python ───────────────────────────────────────────────────────────
    // pyright = tipos/navegação; ruff = lint + format + organize imports.
    // Ambos são builtin do Zed — não precisam de extensão.
    // "!pylsp" desliga o python-lsp-server, que competia com o pyright.
    "Python": {
      "tab_size": 4,
      "language_servers": ["pyright", "ruff", "!pylsp", "..."],
      "formatter": [{ "language_server": { "name": "ruff" } }],
      "code_actions_on_format": { "source.organizeImports.ruff": true },
      "prettier": { "allowed": false },
    },

    // ── C / C++ ──────────────────────────────────────────────────────────
    // clangd é baixado pelo próprio Zed; respeita o .clang-format do projeto.
    "C": { "tab_size": 4, "formatter": "language_server", "prettier": { "allowed": false } },
    "C++": { "tab_size": 4, "formatter": "language_server", "prettier": { "allowed": false } },
  },

  // ─────────────────────────────────────────────────────────────────────────
  // Language servers
  // ─────────────────────────────────────────────────────────────────────────
  "lsp": {
    // ── TypeScript / JavaScript ──────────────────────────────────────────
    "vtsls": {
      "settings": {
        "typescript": {
          "tsserver": { "maxTsServerMemory": 8192 },
          "preferences": {
            // usa os aliases do tsconfig (@/lib/...) em vez de ../../..
            "importModuleSpecifier": "non-relative",
            "preferTypeOnlyAutoImports": true,
          },
          "updateImportsOnFileMove": { "enabled": "always" },
          "suggest": { "completeFunctionCalls": true },
          "inlayHints": {
            "parameterNames": { "enabled": "literals" },
            "parameterTypes": { "enabled": true },
            "variableTypes": { "enabled": true, "suppressWhenTypeMatchesName": true },
            "propertyDeclarationTypes": { "enabled": true },
            "functionLikeReturnTypes": { "enabled": true },
            "enumMemberValues": { "enabled": true },
          },
        },
        "javascript": {
          "preferences": {
            "importModuleSpecifier": "non-relative",
          },
          "updateImportsOnFileMove": { "enabled": "always" },
          "inlayHints": {
            "parameterNames": { "enabled": "literals" },
            "variableTypes": { "enabled": true, "suppressWhenTypeMatchesName": true },
            "functionLikeReturnTypes": { "enabled": true },
          },
        },
        "vtsls": {
          "experimental": {
            "completion": { "enableServerSideFuzzyMatch": true },
          },
        },
      },
    },

    // ── CSS ──────────────────────────────────────────────────────────────
    // Rede de segurança. Em CSS quem manda é o tailwindcss-intellisense-css
    // (ver o bloco "CSS" acima), então isto só entra em ação se algum projeto
    // reativar o servidor padrão — e vale para SCSS/LESS, que o servidor do
    // Tailwind não cobre. Sem isto, @theme/@apply viram erro.
    "vscode-css-language-server": {
      "settings": {
        "css": { "lint": { "unknownAtRules": "ignore" } },
        "scss": { "lint": { "unknownAtRules": "ignore" } },
        "less": { "lint": { "unknownAtRules": "ignore" } },
      },
    },

    // ── Tailwind ─────────────────────────────────────────────────────────
    // O LSP é embutido no Zed mas é opt-in: só sobe nas linguagens que o
    // listam em "language_servers" (acima).
    "tailwindcss-language-server": {
      "settings": {
        "classAttributes": ["class", "className", "ngClass", "classList", "styles"],
        "includeLanguages": { "php": "html", "edge": "html" },
        "experimental": {
          // reconhece classes dentro de cva()/cx()/tv()/clsx()/cn()
          "classRegex": [
            ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
            ["tv\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
            ["cx\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
            ["cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
            ["clsx\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
          ],
        },
      },
    },

    // ── ESLint ───────────────────────────────────────────────────────────
    "eslint": {
      "settings": {
        // detecta eslint.config.js (flat) e .eslintrc automaticamente
        "problems": { "shortenToSingleLine": false },
        "rulesCustomizations": [
          // regras de formatação viram dica, não erro — quem formata é o prettier
          { "rule": "prettier/prettier", "severity": "warn" },
        ],
      },
    },

    // ── PHP ──────────────────────────────────────────────────────────────
    // O intelephense roda em Node e analisa o código estaticamente — NÃO
    // precisa do binário do PHP na máquina. Rodar o PHP no docker compose
    // não muda nada aqui.
    //
    // O que É por projeto: `phpVersion` (a do container) e os stubs das
    // extensões que a imagem carrega. Errado, gera diagnóstico falso — tipo
    // acusar `readonly` ou enums de não existirem. Ponha no .zed/settings.json
    // da raiz do projeto:
    //
    //   {
    //     "lsp": {
    //       "intelephense": {
    //         "settings": {
    //           "intelephense": {
    //             "environment": { "phpVersion": "8.3.0" },
    //             "stubs": ["apache", "bcmath", "core", "ctype", "curl", "date",
    //                       "dom", "fileinfo", "filter", "hash", "iconv", "intl",
    //                       "json", "libxml", "mbstring", "mysqli", "openssl",
    //                       "pcre", "pdo", "pdo_mysql", "pdo_pgsql", "redis",
    //                       "session", "simplexml", "sockets", "sodium", "spl",
    //                       "standard", "tokenizer", "xml", "zip", "zlib"]
    //           }
    //         }
    //       }
    //     }
    //   }
    //
    // Confira a versão do container com:
    //   docker compose exec <serviço> php -v
    "intelephense": {
      "initialization_options": {
        "licenceKey": "",
      },
      "settings": {
        "intelephense": {
          "files": {
            "maxSize": 5000000,
            "exclude": [
              "**/.git/**",
              "**/node_modules/**",
              "**/storage/framework/**",
              "**/bootstrap/cache/**",
              "**/var/cache/**",
              "**/public/build/**",
            ],
          },
        },
      },
    },

    // ── Java ─────────────────────────────────────────────────────────────
    // `java_home` = a JVM que EXECUTA o jdtls. Precisa ser >= 21 e NÃO deve
    // mudar por projeto. A versão-alvo de cada projeto vai no
    // .zed/settings.json local, marcando outro runtime como "default"
    // (é o que o comando `jdk-set` escreve).
    //
    // Os nomes precisam ser do enum do JDT (JavaSE-N). Nomes livres como
    // "Java-25-JBR" são descartados silenciosamente pelo jdtls.
    // Este bloco é GERADO pelo install.sh a partir do sdkman desta máquina.
    "jdtls": {
      "settings": {
        "java_home": "__JAVA_HOME__",
        "jdk_auto_download": true,
      },
      "initialization_options": {
        "settings": {
          "java": {
            "configuration": {
              "runtimes": [
__JAVA_RUNTIMES__
              ],
            },
            "format": { "enabled": true },
            "completion": {
              "importOrder": ["java", "javax", "jakarta", "org", "com", ""],
              "guessMethodArguments": true,
            },

            // ── Geração de código (ctrl-. no editor) ─────────────────────
            //
            // O QUE FUNCIONA no Zed: "Generate Getters and Setters",
            // "Generate Getters", "Generate Setters" — o jdtls devolve o
            // WorkspaceEdit pronto, para todos os campos da classe.
            //
            // O QUE NÃO FUNCIONA: "Generate Constructors", toString(),
            // hashCode()/equals() e Override/Implement Methods. Não é config:
            // o jdtls só oferece essas quatro atrás de um comando CLIENT-SIDE
            // (java.action.generateConstructorsPrompt), que espera o editor
            // desenhar um seletor de campos. O Zed não implementa esse
            // comando, e o servidor também não — pedir para executá-lo devolve
            // -32601 "No delegateCommandHandler for
            // java.action.generateConstructorsPrompt".
            //
            // NÃO tente destravar ligando as capabilities de prompt em
            // initialization_options.extendedClientCapabilities
            // (generateConstructorsPromptSupport & cia.). Isso faz as ações
            // APARECEREM no menu, mas clicar nelas não gera nada — e, pior,
            // converte "Generate Getters and Setters" (que hoje funciona) na
            // mesma forma de prompt morta. A extensão do Zed deliberadamente
            // só injeta classFileContentsSupport e
            // resolveAdditionalTextEditsSupport; é o comportamento certo.
            //
            // Para construtor, use record (Java 16+) ou Lombok — a extensão já
            // sobe o jdtls com o javaagent do Lombok, basta o jar no classpath.
            //
            // Os valores abaixo afetam o que É gerado (ou seja, os accessors).
            // insertionLocation: "lastMember" | "afterCursor" | "beforeCursor"
            "codeGeneration": {
              "useBlocks": true,
              "generateComments": false,
              "insertionLocation": "lastMember",
              "addFinalForNewDeclaration": "none",
              "hashCodeEquals": { "useJava7Objects": true },
            },
            "inlayhints": { "parameterNames": { "enabled": "literals" } },
            "signatureHelp": { "enabled": true },
            "sources": {
              "organizeImports": {
                "starThreshold": 99,
                "staticStarThreshold": 99,
              },
            },
          },
        },
      },
    },

    // ── Python ───────────────────────────────────────────────────────────
    "pyright": {
      "settings": {
        "python": {
          "analysis": {
            "typeCheckingMode": "standard",
            "autoImportCompletions": true,
            "diagnosticMode": "openFilesOnly",
            "inlayHints": {
              "variableTypes": true,
              "functionReturnTypes": true,
              "callArgumentNames": true,
            },
          },
        },
      },
    },
    "ruff": {
      "initialization_options": {
        "settings": {
          "lineLength": 100,
          "lint": { "extendSelect": ["I"] },
        },
      },
    },

    // ── C / C++ ──────────────────────────────────────────────────────────
    "clangd": {
      "binary": {
        "arguments": [
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--all-scopes-completion",
          "--pch-storage=memory",
          "-j=4",
        ],
      },
    },
  },
}
