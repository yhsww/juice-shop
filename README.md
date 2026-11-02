# OWASP Juice Shop

Projeto para executar localmente o **OWASP Juice Shop**, uma aplicação web intencionalmente vulnerável para treinamento, demonstrações e testes de segurança.

> Imagem configurada: `bkimminich/juice-shop:v20.3.0`

## Sistemas compatíveis

- **Windows:** PowerShell e Docker Desktop.
- **Linux**: Docker Engine e Docker Compose v2.
- **macOS**: Docker Desktop.

O arquivo `docker-compose.yml` é compartilhado entre os sistemas. Os scripts ajudam na verificação e execução, mas **não instalam automaticamente Docker em Linux/macOS**: instale o mecanismo Docker conforme a documentação oficial do seu sistema.

## Arquivos

- `setup.ps1`: verificação e execução automatizada no Windows; pode instalar Docker Desktop via `winget` se necessário.
- `setup.sh`: verificação e execução no Linux/macOS; no macOS tenta abrir Docker Desktop se o Engine ainda não estiver ativo.
- `docker-compose.yml`: configuração do container, com a porta publicada somente em `127.0.0.1`.
- `docs/PROCESSO.md`: fluxo, comandos e solução de problemas.

Não é necessário instalar Node.js ou npm no computador host quando a aplicação é executada pela imagem Docker.

## 1. Obter o repositório

Se já clonou anteriormente:

```bash
git pull origin main
```

Para uma cópia nova:

```bash
git clone https://github.com/yhsww/juice-shop.git
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

1. Instale Docker Engine e o plugin Docker Compose v2 conforme a [documentação oficial de instalação](https://docs.docker.com/engine/install/).
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

O Juice Shop contém vulnerabilidades intencionais. Use somente em laboratório local e para testes autorizados. A porta do host está vinculada a `127.0.0.1`; não a altere para `0.0.0.0` nem exponha a aplicação na internet.

## Fontes

- [Repositório OWASP Juice Shop](https://github.com/juice-shop/juice-shop)
- [Releases](https://github.com/juice-shop/juice-shop/releases)
- [Guia de execução](https://pwning.owasp-juice.shop/companion-guide/latest/part1/running.html)
- [Docker Desktop para Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Docker Engine para Linux](https://docs.docker.com/engine/install/)
- [Docker Desktop para macOS](https://docs.docker.com/desktop/setup/install/mac-install/)
