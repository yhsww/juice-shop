# OWASP Juice Shop — Executor local e gerador de relatórios SAST

Este repositório oferece dois fluxos locais independentes:

1. **Executar o OWASP Juice Shop** em um container Docker para treinamento e testes de segurança.
2. **Analisar o código-fonte com Semgrep** e gerar um relatório SAST em JSON usando o script PowerShell `sast.ps1`.

O Juice Shop é uma aplicação web intencionalmente vulnerável. Use-a apenas em laboratório local e em testes autorizados.

> Imagem da aplicação: `bkimminich/juice-shop:v20.3.0`  
> Imagem do analisador: `semgrep/semgrep`

## Sistemas compatíveis

- **Windows:** PowerShell e Docker Desktop.
- **Linux**: Docker Engine e Docker Compose v2.
- **macOS**: Docker Desktop.

O arquivo `docker-compose.yml` é compartilhado entre os sistemas. Os scripts ajudam na verificação e execução, mas **não instalam automaticamente Docker em Linux/macOS**: instale o mecanismo Docker conforme a documentação oficial do seu sistema.

## Arquivos principais

- `setup.ps1`: verifica pré-requisitos e inicia a aplicação no Windows; pode instalar Docker Desktop via `winget` se necessário.
- `setup.sh`: verifica pré-requisitos e inicia a aplicação no Linux/macOS.
- `docker-compose.yml`: configura o container da aplicação, com a porta publicada somente em `127.0.0.1`.
- `sast.ps1`: executa a análise estática com Semgrep em um container Docker e grava o relatório JSON no repositório.

Não é necessário instalar Node.js/npm no host para executar a aplicação pela imagem Docker nem instalar Python/pip no host para gerar o relatório SAST.

## Fluxo rápido

Depois de clonar o repositório, execute os comandos abaixo conforme sua necessidade.

| Objetivo | Windows PowerShell | Linux/macOS |
|---|---|---|
| Iniciar o Juice Shop localmente | `./setup.ps1` | `./setup.sh` |
| Gerar relatório SAST | `./sast.ps1` | `pwsh ./sast.ps1` |
| Parar o Juice Shop | `docker compose down` | `docker compose down` |

Para gerar o relatório SAST no Linux/macOS, instale o PowerShell 7 (`pwsh`) e mantenha o Docker Engine ativo. A primeira execução do analisador pode baixar a imagem do Semgrep.

Os dois fluxos são independentes: você pode analisar os arquivos do repositório sem iniciar o Juice Shop, e pode executar o Juice Shop sem gerar um relatório SAST.

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

## 6. Relatório SAST

O script `sast.ps1` gera um relatório JSON do Semgrep a partir do código-fonte local.

### Pré-requisitos

- Docker Desktop no Windows/macOS ou Docker Engine com Docker Compose no Linux.
- PowerShell 7 ou superior (`pwsh`) em qualquer sistema operacional.
- Conexão com a internet na primeira execução, para baixar a imagem Docker do Semgrep.

O Docker já é utilizado para executar o Juice Shop; não é necessário instalar Node.js/npm no host para esta análise.

### Windows (PowerShell)

Abra o PowerShell na pasta do repositório:

```powershell
# Verificar as ferramentas
$PSVersionTable.PSVersion
docker --version
docker info

# Gerar o relatório
.\sast.ps1
```

Se o PowerShell bloquear a execução do script, permita a execução somente para o processo atual e tente novamente:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\sast.ps1
```

### Linux e macOS (PowerShell 7)

Instale o PowerShell 7 (`pwsh`) e Docker conforme as instruções oficiais para seu sistema. Com o Docker ativo, na pasta do repositório, execute:

```powershell
pwsh ./sast.ps1
```

### Personalizar a análise

Por padrão, o script aplica as regras `p/javascript` e cria `sast-report.json` na raiz do repositório. Você pode escolher outra configuração de regras e nome de saída:

```powershell
# Usar outra configuração Semgrep
./sast.ps1 -Config p/typescript

# Escolher o nome do relatório
./sast.ps1 -Output relatorio-sast.json

# Personalizar ambos
./sast.ps1 -Config p/javascript -Output sast-report.json
```

O arquivo JSON é salvo no diretório do repositório, mesmo que o Semgrep seja executado dentro do container Docker.

### Saída e interpretação

- `sast-report.json`: relatório estruturado produzido pelo Semgrep.
- `results`: achados encontrados pelas regras executadas.
- `errors`: avisos ou erros de análise. Eles devem ser avaliados separadamente e **não devem ser contabilizados automaticamente como vulnerabilidades**.
- A quantidade de achados depende da configuração das regras e dos arquivos que puderam ser analisados.

O JSON nativo do Semgrep tem um esquema próprio. Se outro pipeline ou experimento espera um formato diferente (por exemplo, um campo `issues`), adapte os dados explicitamente ao esquema esperado antes de usá-los.

### Observações

- O primeiro uso pode demorar porque o Docker precisa baixar a imagem `semgrep/semgrep`.
- O script não instala Docker nem inicia o Juice Shop; apenas executa a análise estática.
- Reexecute `sast.ps1` sempre que quiser gerar um relatório atualizado.
- A análise estática não garante ausência de vulnerabilidades. Revise e valide os achados no contexto do código.
- O Juice Shop é intencionalmente vulnerável. Use-o somente em ambiente local ou autorizado.

## Fontes

- [Repositório OWASP Juice Shop](https://github.com/juice-shop/juice-shop)
- [Releases](https://github.com/juice-shop/juice-shop/releases)
- [Guia de execução](https://pwning.owasp-juice.shop/companion-guide/latest/part1/running.html)
- [Docker Desktop para Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Docker Engine para Linux](https://docs.docker.com/engine/install/)
- [Docker Desktop para macOS](https://docs.docker.com/desktop/setup/install/mac-install/)
- [PowerShell 7](https://learn.microsoft.com/powershell/)
- [Instalação do Docker](https://docs.docker.com/get-docker/)
- [Semgrep](https://semgrep.dev/docs/)
