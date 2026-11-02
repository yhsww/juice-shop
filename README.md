# OWASP Juice Shop — Execução local com Docker

Este branch mantém os arquivos de execução local do repositório original e não inclui a geração de relatórios SAST.

> Imagem da aplicação: `bkimminich/juice-shop:v20.3.0`

## Sistemas compatíveis

- **Windows:** PowerShell e Docker Desktop.
- **Linux:** Docker Engine e Docker Compose v2.
- **macOS:** Docker Desktop.

O arquivo `docker-compose.yml` é compartilhado entre os sistemas. Os scripts ajudam na verificação e execução, mas **não instalam automaticamente Docker em Linux/macOS**: instale o Docker conforme a documentação oficial do seu sistema.

## Arquivos principais

- `setup.ps1`: verifica pré-requisitos e inicia a aplicação no Windows; pode instalar Docker Desktop via `winget` se necessário.
- `setup.sh`: verifica pré-requisitos e inicia a aplicação no Linux/macOS.
- `docker-compose.yml`: configura o container da aplicação, com a porta publicada somente em `127.0.0.1`.

## Fluxo rápido

Depois de clonar o repositório, execute os comandos conforme seu sistema.

| Objetivo | Windows PowerShell | Linux/macOS |
|---|---|---|
| Iniciar o Juice Shop localmente | `./setup.ps1` | `./setup.sh` |
| Parar o Juice Shop | `docker compose down` | `docker compose down` |

## 1. Obter o repositório

Se já clonou anteriormente, troque para esta branch:

```bash
git fetch origin
git switch docker-local
git pull
```

Para uma cópia nova:

```bash
git clone --branch docker-local https://github.com/yhsww/juice-shop.git
cd juice-shop
```

## 2. Windows

Instale/abra Docker Desktop e execute PowerShell na pasta do projeto:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
```

O script tenta instalar Docker Desktop com `winget` se não encontrar o Docker CLI. Se houver solicitação de reinicialização, reinicie o Windows, abra Docker Desktop, espere o Engine ficar pronto e rode o script novamente.

Opções:

```powershell
.\setup.ps1 -InstallGit          # instala Git for Windows se ausente
.\setup.ps1 -SkipDockerInstall   # não tenta instalar Docker Desktop
.\setup.ps1 -SkipStart           # verifica dependências sem iniciar a aplicação
```

## 3. Linux

1. Instale Docker Engine e o plugin Docker Compose v2 conforme a [documentação oficial](https://docs.docker.com/engine/install/).
2. Garanta que o serviço Docker esteja ativo e que seu usuário tenha permissão para executar comandos Docker.
3. Na pasta do projeto, execute:

```bash
chmod +x setup.sh
./setup.sh
```

Se o script informar que o Engine não está ativo, verifique o serviço com `sudo systemctl status docker`. Em sistemas com systemd, você pode iniciá-lo com `sudo systemctl start docker`. A configuração de permissões do grupo `docker` concede privilégios elevados; consulte a documentação oficial antes de alterá-la.

## 4. macOS

1. Instale e abra [Docker Desktop para Mac](https://docs.docker.com/desktop/setup/install/mac-install/).
2. Na pasta do projeto, execute:

```bash
chmod +x setup.sh
./setup.sh
```

O script tenta abrir Docker Desktop se ele estiver instalado em `/Applications/Docker.app`, mas o primeiro início e eventuais confirmações devem ser concluídos pelo usuário.

## 5. Acessar e administrar

Quando o script terminar, acesse **http://localhost:3000**.
Em seguida, execute:

```bash
docker compose pull
docker compose up -d
docker compose ps
docker compose logs -f
```

Parar e remover o container:

```bash
docker compose down
```

Verificar dependências sem iniciar a aplicação no Linux/macOS:

```bash
./setup.sh --skip-start
```

## Segurança

O Juice Shop é intencionalmente vulnerável. Use-o somente em ambiente local ou autorizado. A porta fica vinculada a `127.0.0.1`; não exponha a aplicação à rede pública.

## Fontes

- [Repositório OWASP Juice Shop](https://github.com/juice-shop/juice-shop)
- [Releases](https://github.com/juice-shop/juice-shop/releases)
- [Guia de execução](https://pwning.owasp-juice.shop/companion-guide/latest/part1/running.html)
- [Docker Desktop para Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Docker Engine para Linux](https://docs.docker.com/engine/install/)
- [Docker Desktop para macOS](https://docs.docker.com/desktop/setup/install/mac-install/)
- [PowerShell 7](https://learn.microsoft.com/powershell/)
- [Instalação do Docker](https://docs.docker.com/get-docker/)
