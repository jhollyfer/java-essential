# zed-setup

Config do Zed portátil entre máquinas. **A fonte de verdade é `settings.jsonc.tpl`** —
não edite `~/.config/zed/settings.json` à mão; edite o template e rode o `install.sh`.

```
zed-setup/
├── install.sh           # aplica o kit nesta máquina
├── sync.sh              # traz ~/.config/zed de volta pro kit (re-templatiza o JDK)
├── settings.jsonc.tpl   # o settings.json, com os caminhos de JDK como marcadores
├── keymap.json
├── tasks.json
└── bin/{jdk-set,zed-java-run}
```

## Uso

```sh
sh zed-setup/install.sh --dry   # mostra o que faria
sh zed-setup/install.sh         # aplica
```

Depois **abra o Zed uma vez**: não existe `zed --install-extension`, quem instala as
extensões é o bloco `auto_install_extensions` do próprio `settings.json`, no primeiro launch.

## Por que template e não cópia direta

`lsp.jdtls` tem caminho absoluto de JDK — `/home/<user>/.sdkman/candidates/java/<versão>`.
Copiar o `settings.json` cru pra outra máquina quebra o jdtls: outro usuário, outros JDKs.
O `install.sh` varre `~/.sdkman/candidates/java/`, deriva o enum do JDT (`JavaSE-N`, com
major `1` → `1.8`, mesma regra do `jdk-set`), marca o mais novo como `default` e injeta
nos marcadores. Sem sdkman, ele omite `java_home`/`runtimes` e deixa o
`jdk_auto_download` cuidar, avisando.

## O que o install.sh faz

1. Gera `settings.json` do template com os JDKs desta máquina.
2. Instala `settings.json`, `keymap.json`, `tasks.json` em `~/.config/zed`, com backup
   datado do que já existia.
3. Instala `jdk-set` e `zed-java-run` em `~/.local/bin`.
4. Remove três extensões mortas (ver abaixo).
5. `corepack enable pnpm` se preciso.

Não instala extensão nem JDK — imprime o que falta.

## Decisões que não são óbvias

**Biome desligado em 10 linguagens.** A extensão registra o servidor para JavaScript, JSX,
TypeScript, TSX, Vue.js, Astro, Svelte, JSON, JSONC, CSS, GraphQL, HTML e XML. Como o padrão
global aqui é Prettier + ESLint, todas levam `!biome` — senão o biome sobe um processo por
sessão, até em projeto Java sem `package.json`. Em projeto que **usa** Biome, ligue por
projeto no `.zed/settings.json` (receita comentada dentro do template).

**`!graphql` em TS/TSX/JS/JSX.** A extensão do GraphQL registra o servidor dela em
JavaScript, JSX, TypeScript, TSX (além de Vue/Astro/Svelte) — pra ``gql`` `` embutido em template
literal — e não só em `.graphql`. Como o cliente de API aqui é openapi-fetch, seria só mais um
servidor em todo `.tsx`.

**`!emmet` em HTML/CSS.** A extensão do Edge registra um **segundo** emmet, sob o nome `emmet`,
em HTML e CSS — ao lado do `emmet-language-server` embutido no Zed. Mesma classe do jdtls duplicado.

**`file_types` para GitHub Actions.** A linguagem "GitHub Actions" da extensão homônima não
declara `path_suffixes` nenhum: ela nunca casa arquivo sozinha. Sem o mapeamento no `file_types`,
a extensão fica instalada e **inerte**.

**`tailwindcss-intellisense-css` no lugar do CSS padrão.** O Tailwind v4 se configura em CSS
(`@theme`, `@plugin`, `@source`, `@utility`, `@custom-variant`, `@apply`) e o
`vscode-css-language-server` marcaria o arquivo de tema inteiro como erro. O Zed traz builtin o
servidor de CSS da própria equipe do Tailwind, que entende essas at-rules **e** mantém o
IntelliSense de CSS padrão — melhor que só silenciar o diagnóstico, que também esconderia
`@improt` e afins. O `unknownAtRules: "ignore"` fica como rede de segurança para SCSS/LESS (que
esse servidor não cobre) e para projetos que reativem o servidor padrão.

Se o `tailwindcss-intellisense-css` der problema em algum projeto, remova as duas primeiras
entradas de `languages.CSS.language_servers` e o servidor padrão volta.

**`postgres-language-server` fora do auto-install.** Precisa de `postgrestools.jsonc` apontando
pro banco; global viraria ruído em todo repo. Instale pela paleta e ligue no `.zed/settings.json`
dos projetos Postgres:

```jsonc
{ "languages": { "SQL": { "language_servers": ["postgres-language-server", "..."] } } }
```

**`ruff` e `pyright` fora do auto-install.** São builtin do Zed. O `pylsp` também é builtin —
por isso a extensão homônima nunca era registrada e foi removida.

**`**/bin` NÃO entra em `file_scan_exclusions`.** O AdonisJS v6 põe `bin/server.ts`,
`bin/console.ts` e `bin/test.ts` ali. Diretório de saída de projeto Java se exclui por projeto.

**Extensões removidas:**

| Extensão | Motivo |
|---|---|
| `pylsp` | O Zed tem pylsp builtin; a extensão nunca chega a ser registrada |
| `java-eclipse-jdtls` | Expõe o servidor como `java`, desligado com `!java`. Quem serve o `jdtls` é a extensão `java` (que traz `gradle-language-server` junto) |
| `nextjs-react-snippets` | Pacote quebrado: `snippets/jsx.json` não existe, erro em todo boot |

## Geração de código Java (ctrl-.)

**Funciona:** `Generate Getters and Setters`, `Generate Getters`, `Generate Setters` — o jdtls
devolve o edit pronto para todos os campos da classe.

**Não funciona:** `Generate Constructors`, `toString()`, `hashCode()/equals()` e
`Override/Implement Methods`. **Não é configuração** — é limitação do cliente. O jdtls só oferece
essas quatro atrás de um comando client-side, `java.action.generateConstructorsPrompt`, que espera
o editor desenhar um seletor de campos. O Zed não implementa esse comando, e o servidor também
não: pedir para executá-lo devolve

```
-32601  No delegateCommandHandler for java.action.generateConstructorsPrompt
```

**Não tente destravar** ligando as capabilities de prompt em
`initialization_options.extendedClientCapabilities` (`generateConstructorsPromptSupport` & cia.).
Isso faz as ações aparecerem no menu, mas clicar não gera nada — e converte
`Generate Getters and Setters`, que hoje funciona, na mesma forma de prompt morta. A extensão do
Zed injeta só `classFileContentsSupport` e `resolveAdditionalTextEditsSupport`, e está certa.

**Alternativas reais para construtor:**

- `record Employee(String name, Role role) {}` — construtor canônico, acessores e `equals`/
  `hashCode`/`toString` de graça, sem dependência. Idiomático no Java 25.
- **Lombok** — `@AllArgsConstructor`, `@RequiredArgsConstructor`, `@Data`. **Já está pronto:**
  a extensão sobe o jdtls com o javaagent do Lombok (o autocomplete enxerga o que a anotação gera)
  e o `zed-java-run` deste kit compila com Lombok automaticamente. Basta anotar a classe.

  Como o `zed-java-run` resolve o Lombok:

  1. Detecta se algum `.java` do projeto importa `lombok.` ou usa uma das anotações. Se não usa,
     nada muda — projeto sem Lombok compila limpo, sem carregar processador.
  2. Procura o jar em `<projeto>/lib/lombok.jar` e depois no que a extensão de Java do Zed já
     baixou — o que garante a **mesma versão** que o jdtls usa, então o que compila é o que o
     autocomplete enxerga.
  3. Passa `-cp` **e** `-processorpath`. O `-processorpath` é obrigatório: só com `-cp`, o javac
     não roda o processador e as anotações viram no-op **silencioso** — compila sem erro e sem
     gerar nada.
  4. A partir do JDK 23 o Lombok dispara aviso de `sun.misc.Unsafe` a cada compilação. O script
     adiciona `-J--sun-misc-unsafe-memory-access=allow`, mas só depois de testar que o JDK aceita
     — em JDK 11 a flag não existe e seria erro.

  Lombok é compile-time: não entra no classpath de execução.

  Testado de ponta a ponta em JDK 25 e JDK 11, e verificado que projeto sem Lombok não regride.

O bloco `java.codeGeneration` no template afeta o que **é** gerado (os accessors): sempre com
chaves, sem javadoc stub, inserido no fim da classe.

## Fora do Zed

O `bash-language-server` é builtin e já roda nos `.sh` deste kit, mas ele **terceiriza** o
diagnóstico pro `shellcheck` e a formatação pro `shfmt`. Sem esses binários não há lint de shell
e o `format_on_save` é um no-op silencioso em `.sh`:

```sh
sudo apt install shellcheck shfmt
```

## Por projeto, não aqui

- **Biome** — receita comentada no template.
- **intelephense `phpVersion` + stubs** — a versão do container, não a da máquina. Receita
  comentada no template. Errado, gera diagnóstico falso (acusa `readonly`/enum de não existir).
- **JDK do projeto** — `jdk-set <versão>`, que escreve `.sdkmanrc` + `.zed/settings.json`.
  Ele se recusa a sobrescrever um `.zed/settings.json` que não foi gerado por ele; mas se
  foi, edições manuais nesse arquivo se perdem no próximo `jdk-set`.
- **Paraglide** — se as mensagens geradas poluírem a busca, adicione `**/src/paraglide` ao
  `file_scan_exclusions` do projeto.
