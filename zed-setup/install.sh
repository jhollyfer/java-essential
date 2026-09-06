#!/bin/sh
# install.sh — aplica a config do Zed deste kit na máquina atual.
#
#   sh zed-setup/install.sh          # aplica
#   sh zed-setup/install.sh --dry    # só mostra o que faria
#
# Idempotente: rodar duas vezes dá o mesmo resultado.
#
# O que ele NÃO faz (não dá pra fazer por CLI):
#   - instalar extensões. Não existe `zed --install-extension`. Quem instala é
#     o bloco "auto_install_extensions" do settings.json, no primeiro launch.
#   - instalar JDK. Use `sdk install java <versão>`.

set -eu

DRY=0
[ "${1:-}" = "--dry" ] && DRY=1

kit=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
zed_config="${XDG_CONFIG_HOME:-$HOME/.config}/zed"
zed_data="${XDG_DATA_HOME:-$HOME/.local/share}/zed"
bindir="$HOME/.local/bin"
candidates="$HOME/.sdkman/candidates/java"
stamp=$(date +%Y%m%d-%H%M%S)
tmp="${TMPDIR:-/tmp}/zed-setup.$$"
trap 'rm -rf "$tmp"' EXIT INT TERM
mkdir -p "$tmp"

say()  { printf '%s\n' "$*"; }
warn() { printf '!  %s\n' "$*" >&2; }
run()  { if [ "$DRY" -eq 1 ]; then printf '   [dry] %s\n' "$*"; else eval "$*"; fi; }

# ── 1. JDKs desta máquina ───────────────────────────────────────────────────
# Deriva o nome do enum do JDT (JavaSE-N) do nome do diretório do sdkman.
# Mesma regra do jdk-set: major "1" vira "1.8".
: > "$tmp/majors"
if [ -d "$candidates" ]; then
  for dir in "$candidates"/*; do
    [ -d "$dir" ] || continue
    v=$(basename "$dir")
    [ "$v" = "current" ] && continue
    major=${v%%.*}
    case "$major" in
      *[!0-9]*) continue ;;   # nome fora do padrão N.x — ignora
      "")       continue ;;
    esac
    [ "$major" = "1" ] && major="1.8"
    printf '%s\t%s\t%s\n' "$major" "$v" "$dir" >> "$tmp/majors"
  done
fi

# Um runtime por major. Ordena major desc (numérico) e, dentro do major,
# versão desc (ordenação de versão) — daí o awk fica com a PRIMEIRA de cada
# major, que é a mais nova. Major mais novo primeiro = default.
# LC_ALL=C é obrigatório: em locale com vírgula decimal (pt_BR, de_DE...) o
# `sort -n` do GNU lê "1.8" errado e o Java 8 sai fora de ordem.
tab=$(printf '\t')
LC_ALL=C sort -t"$tab" -k1,1nr -k2,2Vr "$tmp/majors" 2>/dev/null \
  | awk -F"$tab" '!seen[$1]++' > "$tmp/runtimes.src" || true

java_home=""
: > "$tmp/runtimes.json"
first=1
while IFS="$(printf '\t')" read -r major version path; do
  [ -n "${major:-}" ] || continue
  if [ "$first" -eq 1 ]; then
    java_home="$path"
    printf '                { "name": "JavaSE-%s", "path": "%s", "default": true },\n' \
      "$major" "$path" >> "$tmp/runtimes.json"
    first=0
  else
    printf '                { "name": "JavaSE-%s", "path": "%s" },\n' \
      "$major" "$path" >> "$tmp/runtimes.json"
  fi
done < "$tmp/runtimes.src"

if [ -n "$java_home" ]; then
  say "JDKs detectados ($(wc -l < "$tmp/runtimes.json" | tr -d ' ')):"
  sed 's/^ */   /' "$tmp/runtimes.json"
  say "   java_home (roda o jdtls) -> $java_home"
else
  warn "Nenhum JDK do sdkman encontrado em $candidates."
  warn "O settings.json sai sem java_home nem runtimes fixos — o jdtls vai"
  warn "depender de jdk_auto_download. Depois: sdk install java 25.0.4+1.58348-jbr"
fi
say ""

# ── 2. settings.json a partir do template ───────────────────────────────────
have_jdk=0
[ -n "$java_home" ] && have_jdk=1

awk -v home="$java_home" -v rtfile="$tmp/runtimes.json" -v have="$have_jdk" '
  /__JAVA_RUNTIMES__/ {
    if (have == 1) { while ((getline l < rtfile) > 0) print l }
    next
  }
  /"java_home"/ {
    if (have == 0) next
    gsub(/__JAVA_HOME__/, home)
  }
  { print }
' "$kit/settings.jsonc.tpl" > "$tmp/settings.json"

if grep -q '__JAVA_' "$tmp/settings.json"; then
  warn "Sobrou marcador não substituído no settings.json gerado. Abortando."
  grep -n '__JAVA_' "$tmp/settings.json" >&2
  exit 1
fi

# ── 3. Instala config, com backup do que já existia ─────────────────────────
run "mkdir -p '$zed_config'"
install_file() { # <origem> <destino>
  src=$1; dst=$2
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    say "=  $dst (já idêntico)"
    return
  fi
  if [ -f "$dst" ]; then
    run "cp -p '$dst' '$dst.bak-$stamp'"
    say "~  $dst  (backup em $(basename "$dst").bak-$stamp)"
  else
    say "+  $dst"
  fi
  run "cp '$src' '$dst'"
}
install_file "$tmp/settings.json" "$zed_config/settings.json"
install_file "$kit/keymap.json"   "$zed_config/keymap.json"
install_file "$kit/tasks.json"    "$zed_config/tasks.json"
say ""

# ── 4. Scripts auxiliares do Java ───────────────────────────────────────────
run "mkdir -p '$bindir'"
for s in jdk-set zed-java-run; do
  install_file "$kit/bin/$s" "$bindir/$s"
  run "chmod +x '$bindir/$s'"
done
case ":$PATH:" in
  *":$bindir:"*) ;;
  *) warn "$bindir não está no PATH — 'jdk-set' não vai funcionar no terminal."
     warn "A task 'Java: run' do Zed continua ok (chama por caminho absoluto)." ;;
esac
say ""

# ── 5. Extensões mortas ─────────────────────────────────────────────────────
# pylsp            -> o Zed tem pylsp builtin, a extensão nunca é registrada
# java-eclipse-jdtls -> expõe o servidor como "java", desligado com "!java"
# nextjs-react-snippets -> pacote quebrado (snippets/jsx.json não existe)
for ext in pylsp java-eclipse-jdtls nextjs-react-snippets; do
  for sub in installed work; do
    d="$zed_data/extensions/$sub/$ext"
    [ -d "$d" ] || continue
    say "-  removendo extensão morta: $d"
    run "rm -rf '$d'"
  done
done
say ""

# ── 6. pnpm ─────────────────────────────────────────────────────────────────
if command -v pnpm >/dev/null 2>&1; then
  say "=  pnpm já disponível ($(pnpm --version 2>/dev/null))"
elif command -v corepack >/dev/null 2>&1; then
  say "+  habilitando pnpm via corepack"
  run "corepack enable pnpm" || warn "corepack enable pnpm falhou — rode à mão"
else
  warn "Nem pnpm nem corepack encontrados. Instale o Node 24+ primeiro."
fi
say ""

# ── 7. O que sobra ──────────────────────────────────────────────────────────
say "Pronto. O que ainda depende de você:"
say "  1. Abrir o Zed uma vez — 'auto_install_extensions' instala sozinho:"
say "     html java php prisma toml env xml biome git-firefly docker-compose"
say "     dockerfile sql edge graphql mdx github-actions"
say "     (não existe 'zed --install-extension'; é esse bloco ou a paleta)"
say "  2. Projetos Postgres: instalar 'postgres-language-server' pela paleta e"
say "     ligar no .zed/settings.json do projeto (precisa de postgrestools.jsonc)."
[ -n "$java_home" ] || say "  3. sdk install java 25.0.4+1.58348-jbr  (e rodar este script de novo)"
