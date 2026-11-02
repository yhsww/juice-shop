#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE="bkimminich/juice-shop:v20.3.0"
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
SKIP_START=0

usage() {
  cat <<'EOF'
Uso: ./setup.sh [opções]

Opções:
  --skip-start   Verifica os pré-requisitos, sem baixar/iniciar o container
  -h, --help     Mostra esta ajuda

O script configura/inicia o Juice Shop; ele não instala Docker automaticamente.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --skip-start) SKIP_START=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opção desconhecida: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

step() { printf '\n==> %s\n' "$1"; }
fail() { printf 'ERRO: %s\n' "$1" >&2; exit 1; }

[[ -f "$COMPOSE_FILE" ]] || fail "Não encontrei docker-compose.yml em $PROJECT_DIR."
OS="$(uname -s)"
case "$OS" in
  Linux|Darwin) ;;
  *) fail "Sistema não suportado por este script: $OS. Use setup.ps1 no Windows." ;;
esac

step "Verificando Docker"
if ! command -v docker >/dev/null 2>&1; then
  case "$OS" in
    Darwin)
      cat >&2 <<'EOF'
Docker CLI não encontrado. Instale e abra o Docker Desktop para macOS:
https://docs.docker.com/desktop/setup/install/mac-install/
Depois, feche e reabra o terminal e execute ./setup.sh novamente.
EOF
      ;;
    Linux)
      cat >&2 <<'EOF'
Docker CLI não encontrado. Instale Docker Engine e o plugin Docker Compose
seguindo as instruções oficiais para sua distribuição:
https://docs.docker.com/engine/install/
Depois, execute ./setup.sh novamente.
EOF
      ;;
  esac
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  if [[ "$OS" == "Darwin" ]]; then
    step "Tentando abrir Docker Desktop"
    if [[ -d "/Applications/Docker.app" ]]; then
      open -a Docker || true
    else
      echo "Abra Docker Desktop manualmente e aguarde o Engine iniciar." >&2
    fi
    for _ in $(seq 1 30); do
      if docker info >/dev/null 2>&1; then break; fi
      sleep 2
    done
  elif command -v systemctl >/dev/null 2>&1; then
    echo "Docker Engine não responde. Se você tiver permissão, tente: sudo systemctl start docker" >&2
  fi
fi
docker info >/dev/null 2>&1 || fail "Docker Engine não está disponível. Inicie o Docker daemon/Desktop e tente novamente."

step "Verificando Docker Compose v2"
docker compose version >/dev/null 2>&1 || fail "Docker Compose v2 não está disponível. Atualize Docker Desktop ou instale o plugin Compose."

if [[ "$SKIP_START" -eq 1 ]]; then
  echo "Pré-requisitos OK. --skip-start solicitado; não foi iniciado nenhum container."
  exit 0
fi

step "Baixando imagem: $IMAGE"
docker compose -f "$COMPOSE_FILE" pull

step "Iniciando o container"
docker compose -f "$COMPOSE_FILE" up -d

step "Aguardando a aplicação responder"
ready=0
for _ in $(seq 1 45); do
  if command -v curl >/dev/null 2>&1 && curl --silent --show-error --fail --max-time 3 http://127.0.0.1:3000 >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [[ "$ready" -eq 1 ]]; then
  printf '\nJuice Shop está disponível em: http://localhost:3000\n'
else
  echo "O container iniciou, mas a aplicação ainda não respondeu." >&2
  echo "Diagnóstico: docker compose -f \"$COMPOSE_FILE\" logs -f" >&2
  exit 1
fi

cat <<'EOF'

Comandos úteis:
  docker compose ps
  docker compose logs -f
  docker compose down
  docker compose pull && docker compose up -d

Aviso: o Juice Shop é intencionalmente vulnerável. Mantenha a porta
vinculada a 127.0.0.1 e use somente em ambiente local/autorizado.
EOF
