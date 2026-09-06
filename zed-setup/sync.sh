#!/bin/sh
# sync.sh — caminho inverso do install.sh: traz a config da máquina atual de
# volta pro kit, re-templatizando os caminhos de JDK (que são locais).
#
#   sh zed-setup/sync.sh          # atualiza o kit
#   sh zed-setup/sync.sh --dry    # só mostra o diff
#
# Use quando tiver mexido em ~/.config/zed direto (pela UI do Zed, por exemplo)
# e quiser que o kit não envelheça. O fluxo normal é o contrário: editar
# settings.jsonc.tpl e rodar install.sh.

set -eu

DRY=0
[ "${1:-}" = "--dry" ] && DRY=1

kit=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
zed_config="${XDG_CONFIG_HOME:-$HOME/.config}/zed"
bindir="$HOME/.local/bin"
tmp="${TMPDIR:-/tmp}/zed-sync.$$"
trap 'rm -rf "$tmp"' EXIT INT TERM
mkdir -p "$tmp"

[ -f "$zed_config/settings.json" ] || { echo "! $zed_config/settings.json não existe." >&2; exit 1; }

# Troca o valor de java_home pelo marcador e colapsa o array de runtimes.
awk '
  /"java_home"/ {
    sub(/"java_home"[[:space:]]*:[[:space:]]*"[^"]*"/, "\"java_home\": \"__JAVA_HOME__\"")
    print; next
  }
  /"runtimes"[[:space:]]*:[[:space:]]*\[/ { print; skip = 1; print "__JAVA_RUNTIMES__"; next }
  skip == 1 {
    if ($0 ~ /^[[:space:]]*\],?[[:space:]]*$/) { skip = 0; print }
    next
  }
  { print }
' "$zed_config/settings.json" > "$tmp/settings.jsonc.tpl"

if ! grep -q '__JAVA_HOME__' "$tmp/settings.jsonc.tpl" || ! grep -q '__JAVA_RUNTIMES__' "$tmp/settings.jsonc.tpl"; then
  echo "! Não achei java_home e/ou runtimes no settings.json — não vou gravar um" >&2
  echo "  template sem os marcadores (o install.sh aborta neles)." >&2
  exit 1
fi

changed=0
sync_file() { # <novo> <destino no kit>
  if [ -f "$2" ] && cmp -s "$1" "$2"; then return; fi
  changed=1
  printf '~  %s\n' "${2#$kit/}"
  if [ "$DRY" -eq 1 ]; then
    diff -u "$2" "$1" 2>/dev/null | sed 's/^/     /' || true
  else
    cp "$1" "$2"
  fi
}

sync_file "$tmp/settings.jsonc.tpl" "$kit/settings.jsonc.tpl"
sync_file "$zed_config/keymap.json" "$kit/keymap.json"
sync_file "$zed_config/tasks.json"  "$kit/tasks.json"
for s in jdk-set zed-java-run; do
  [ -f "$bindir/$s" ] && sync_file "$bindir/$s" "$kit/bin/$s"
done

if [ "$changed" -eq 0 ]; then
  echo "=  kit já em dia com ~/.config/zed"
elif [ "$DRY" -eq 0 ]; then
  echo ""
  echo "Kit atualizado. Confira o diff com git antes de commitar."
fi
