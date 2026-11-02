# Processo de instalação e execução multiplataforma

## Fluxo geral

```text
Escolher o sistema operacional
   |
   +-- Windows --> setup.ps1 --> verificar/instalar Docker Desktop via winget
   |
   +-- Linux ----> instalar Docker Engine + Compose v2 pela documentação oficial
   |                 |
   |                 +--> ./setup.sh
   |
   +-- macOS ----> instalar/abrir Docker Desktop
                     |
                     +--> ./setup.sh

Todos os caminhos:
verificar Docker Engine -> verificar Compose v2 -> baixar imagem
-> iniciar container -> testar http://127.0.0.1:3000
```

## Windows

1. Executar `setup.ps1` em PowerShell.
2. Se o Docker CLI não estiver instalado, o script tenta instalar Docker Desktop por `winget`.
3. Abrir Docker Desktop e aguardar o Engine responder.
4. O script verifica Compose v2, baixa a imagem fixada e executa `docker compose up -d`.
5. O script tenta verificar a resposta HTTP em `127.0.0.1:3000`.

## Linux

1. Instalar Docker Engine e o plugin Docker Compose v2 para a distribuição, seguindo https://docs.docker.com/engine/install/.
2. Confirmar que o serviço Docker está ativo e que o usuário tem permissão para acessar o daemon.
3. Executar `chmod +x setup.sh && ./setup.sh`.
4. Se o Engine estiver parado, consultar `sudo systemctl status docker`; em distribuições com systemd, iniciar com `sudo systemctl start docker`, se apropriado.

O script não instala pacotes do sistema nem executa comandos privilegiados automaticamente.

## macOS

1. Instalar e abrir Docker Desktop: https://docs.docker.com/desktop/setup/install/mac-install/.
2. Executar `chmod +x setup.sh && ./setup.sh`.
3. Se o Engine não responder, o script tenta abrir `/Applications/Docker.app` e aguarda. Conclua manualmente qualquer diálogo de primeira execução.

## Validação e diagnóstico

```bash
docker version
docker info
docker compose version
docker compose ps
docker compose logs --tail 100
docker compose logs -f
```

A aplicação pode levar algum tempo para iniciar. O script aguarda até 90 segundos por uma resposta HTTP.

## Problemas comuns

- **Docker CLI ausente:** instale Docker Desktop (Windows/macOS) ou Docker Engine e Compose v2 (Linux) pela documentação oficial.
- **Engine indisponível:** abra Docker Desktop no Windows/macOS. No Linux, verifique o serviço e as permissões do daemon.
- **Permissão negada no Linux:** confirme a configuração do daemon. O grupo `docker` pode conceder privilégios equivalentes a root; entenda o risco antes de adicioná-lo.
- **Porta 3000 ocupada:** identifique o serviço que a utiliza ou escolha outra porta host, mantendo o endereço host em `127.0.0.1`.
- **Imagem não baixa:** verifique conectividade, acesso ao registry e se a tag configurada ainda existe.
- **Container ativo, página indisponível:** consulte `docker compose logs -f` e `docker compose ps`.

## Segurança operacional

O Juice Shop é deliberadamente vulnerável. Mantenha a publicação vinculada a `127.0.0.1`, não configure encaminhamento de porta para a internet e use apenas em ambientes locais ou explicitamente autorizados.
