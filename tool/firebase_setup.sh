#!/usr/bin/env bash
# Executa uma vez na sua máquina: login Google, gera lib/firebase_options.dart e publica regras.
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH:${PUB_CACHE:-$HOME/.pub-cache}/bin"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v firebase >/dev/null 2>&1; then
  echo "Instale: brew install firebase-cli"
  exit 1
fi
if ! command -v flutterfire >/dev/null 2>&1; then
  echo "Instale: dart pub global activate flutterfire_cli"
  exit 1
fi

echo "1) Autenticação (abre o navegador se necessário)"
firebase login

echo "2) Informe o ID do projeto Firebase (ex.: meu-app-12345)"
read -r PROJ
if [[ -z "${PROJ// }" ]]; then
  echo "ID vazio."
  exit 1
fi

echo "3) FlutterFire (web, android, ios)"
flutterfire configure \
  --platforms=web,android,ios \
  --yes \
  --project="$PROJ" \
  --overwrite-firebase-options

echo "4) Publicar regras do Firestore"
firebase deploy --only firestore:rules --project="$PROJ"

echo "Pronto. Rode: flutter run"
