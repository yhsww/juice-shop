# OWASP Juice Shop — Execução local com Docker

Este branch contém apenas o necessário para executar localmente a aplicação **OWASP Juice Shop** usando Docker. A análise SAST e a geração de relatórios não fazem parte deste branch.

## Pré-requisitos

- Windows: Docker Desktop e PowerShell.
- Linux: Docker Engine e Docker Compose v2.
- macOS: Docker Desktop e Docker Compose v2.

Os scripts verificam as dependências, mas não instalam Docker automaticamente em Linux/macOS. No Windows, `setup.ps1` pode tentar instalar Docker Desktop via `winget`.

## Arquivos

- `docker-compose.yml`: executa a imagem `bkimminich/juice-shop:v20.3.0`.
- `setup.ps1`: configuração e inicialização no Windows.
- `setup.sh`: configuração e inicialização no Linux/macOS.

## Executar

### Windows (PowerShell)

Na pasta do repositório:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
```

Se o Docker Desktop já estiver instalado e você não quiser que o script tente instalá-lo:

```powershell
.\setup.ps1 -SkipDockerInstall
```

### Linux

Instale e inicie Docker Engine e o plugin Docker Compose v2 conforme a documentação oficial. Depois:

```bash
chmod +x setup.sh
./setup.sh
```

### macOS

Instale e abra Docker Desktop. Depois, na pasta do repositório:

```bash
chmod +x setup.sh
./setup.sh
```

## Acessar e parar

Quando a inicialização terminar, acesse:

**http://localhost:3000**

Comandos úteis:

```bash
docker compose ps
docker compose logs -f
docker compose down
```

## Segurança

O Juice Shop é intencionalmente vulnerável e deve ser usado apenas em laboratório ou ambiente autorizado. A porta é publicada em `127.0.0.1:3000` para restringir o acesso ao próprio computador. Não exponha essa aplicação à rede pública.
