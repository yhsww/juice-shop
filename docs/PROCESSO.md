# Mapa do processo: instalação e execução local

## Fluxo

```text
Iniciar setup.ps1
      |
      v
Verificar Windows, docker-compose.yml e winget
      |
      v
Docker CLI existe? ---- não ----> Instalar Docker Desktop via winget
      |                                  |
     sim                                 v
      |                          Reiniciar/abrir Docker Desktop
      v                                  |
Docker Engine responde? <----------------+
      |
      +---- não ----> Iniciar Docker Desktop / configurar WSL 2 / repetir
      |
     sim
      |
      v
Verificar Docker Compose v2
      |
      v
Baixar bkimminich/juice-shop:v20.3.0
      |
      v
docker compose up -d
      |
      v
Testar http://127.0.0.1:3000
      |
      +---- OK ----> Abrir http://localhost:3000
      |
      +---- Falha --> docker compose logs -f
```

## Etapas e validação

1. **Pré-validação:** o script verifica a existência de `docker-compose.yml` e do comando `winget` quando precisa instalar Docker Desktop.
2. **Instalação:** o Docker Desktop é instalado pelo identificador `Docker.DockerDesktop`. A instalação pode exigir privilégios administrativos e reinicialização.
3. **Engine:** `docker info` deve terminar com código zero. Se não estiver pronto, o script tenta iniciar Docker Desktop e aguarda.
4. **Compose:** `docker compose version` confirma a disponibilidade do Compose v2.
5. **Imagem:** `docker compose pull` baixa a tag definida em `docker-compose.yml`.
6. **Container:** `docker compose up -d` cria e inicia o serviço.
7. **Smoke check:** o script faz requisições HTTP a `127.0.0.1:3000` por até 90 segundos.
8. **Acesso:** quando a aplicação responder, abra `http://localhost:3000`.

## Comandos de diagnóstico

```powershell
docker version
docker info
docker compose version
docker compose ps
docker compose logs --tail 100
docker compose logs -f
```

## Problemas comuns

- **`winget` não encontrado:** instale/atualize o aplicativo *App Installer* da Microsoft Store ou instale Docker Desktop manualmente e execute ` .\setup.ps1 -SkipDockerInstall `.
- **Docker Engine indisponível:** abra Docker Desktop e aguarde o status de execução. Se solicitado, habilite WSL 2 e reinicie o Windows.
- **Virtualização/WSL 2:** siga o guia oficial do Docker Desktop para Windows; em computadores gerenciados por empresa, as políticas de TI podem impedir a ativação.
- **Porta 3000 ocupada:** pare o processo que usa a porta ou altere o mapeamento no Compose. Mantenha o endereço host em `127.0.0.1`.
- **Imagem/tag não encontrada:** confira a página oficial de releases e a disponibilidade da tag no registry; ajuste `docker-compose.yml` para uma versão publicada.
- **Container inicia, mas a página não abre:** execute `docker compose logs -f` e verifique se o Docker Desktop está usando Linux containers.

## Segurança operacional

A aplicação é deliberadamente vulnerável. Mantenha a publicação em `127.0.0.1`, não faça port-forward para a internet e use apenas em laboratório local ou ambiente explicitamente autorizado.
