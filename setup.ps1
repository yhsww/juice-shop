[CmdletBinding()]
param(
    [switch]$SkipDockerInstall,
    [switch]$InstallGit,
    [switch]$SkipStart
)

$ErrorActionPreference = "Stop"
$Image = "bkimminich/juice-shop:v20.3.0"
$ComposeFile = Join-Path $PSScriptRoot "docker-compose.yml"

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Test-Command([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-WingetInstall([string]$PackageId) {
    if (-not (Test-Command "winget")) {
        throw "winget não foi encontrado. Atualize/instale o 'App Installer' da Microsoft Store ou instale manualmente: $PackageId"
    }
    & winget install --id $PackageId --exact --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "A instalação de $PackageId falhou (código $LASTEXITCODE). Instale manualmente e execute novamente."
    }
}

Write-Host "OWASP Juice Shop - configuração local com Docker" -ForegroundColor Green
Write-Host "Imagem fixada: $Image"
Write-Host "Diretório: $PSScriptRoot"

if (-not (Test-Path $ComposeFile)) {
    throw "Não encontrei docker-compose.yml em $PSScriptRoot. Execute o script a partir da pasta do projeto."
}

Write-Step "Verificando Windows e gerenciador de pacotes"
if (-not $IsWindows -and $env:OS -ne "Windows_NT") {
    throw "Este script foi criado para Windows PowerShell 5.1/PowerShell 7 no Windows."
}
if (-not (Test-Command "winget") -and -not $SkipDockerInstall) {
    throw "winget não está disponível. Instale/atualize 'App Installer' ou instale Docker Desktop manualmente; depois rode novamente com -SkipDockerInstall."
}

if ($InstallGit -and -not (Test-Command "git")) {
    Write-Step "Instalando Git (opcional, útil para clonar/publicar o projeto)"
    Invoke-WingetInstall "Git.Git"
    Write-Host "O Git pode precisar de um novo terminal para entrar no PATH." -ForegroundColor Yellow
}

if (-not (Test-Command "docker")) {
    if ($SkipDockerInstall) {
        throw "Docker CLI não encontrado. Instale Docker Desktop e rode novamente sem -SkipDockerInstall."
    }
    Write-Step "Instalando Docker Desktop"
    Invoke-WingetInstall "Docker.DockerDesktop"
    Write-Host "Se o instalador solicitar reinicialização, reinicie o Windows e execute setup.ps1 novamente." -ForegroundColor Yellow
}

if (-not (Test-Command "docker")) {
    throw "Docker CLI ainda não está disponível no PATH. Feche e reabra o terminal; se necessário, reinicie o Windows."
}

Write-Step "Aguardando o Docker Engine"
$engineReady = $false
for ($i = 0; $i -lt 30; $i++) {
    try {
        & docker info *> $null
        if ($LASTEXITCODE -eq 0) { $engineReady = $true; break }
    } catch {}
    Start-Sleep -Seconds 2
}
if (-not $engineReady) {
    Write-Host "O Docker Engine não respondeu. Tentando iniciar Docker Desktop..." -ForegroundColor Yellow
    $desktopCandidates = @(
        "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "$Env:LOCALAPPDATA\Programs\Docker\Docker\Docker Desktop.exe"
    )
    $desktop = $desktopCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($desktop) { Start-Process -FilePath $desktop }
    else { Write-Host "Abra o Docker Desktop pelo menu Iniciar." -ForegroundColor Yellow }
    for ($i = 0; $i -lt 60; $i++) {
        try {
            & docker info *> $null
            if ($LASTEXITCODE -eq 0) { $engineReady = $true; break }
        } catch {}
        Start-Sleep -Seconds 2
    }
}
if (-not $engineReady) {
    throw "Docker Engine não ficou pronto. Abra Docker Desktop, conclua a configuração do WSL 2 se solicitada, reinicie se necessário e execute novamente."
}

Write-Step "Verificando Docker Compose"
& docker compose version
if ($LASTEXITCODE -ne 0) { throw "Docker Compose v2 não está disponível. Atualize/reinstale Docker Desktop." }

if (-not $SkipStart) {
    Write-Step "Baixando a imagem do OWASP Juice Shop"
    & docker compose -f $ComposeFile pull
    if ($LASTEXITCODE -ne 0) { throw "Falha ao baixar $Image. Verifique a internet e a disponibilidade da tag." }

    Write-Step "Iniciando o container"
    & docker compose -f $ComposeFile up -d
    if ($LASTEXITCODE -ne 0) { throw "Falha ao iniciar o container. Confira 'docker compose logs'." }

    Write-Step "Aguardando a aplicação responder"
    $ready = $false
    for ($i = 0; $i -lt 45; $i++) {
        try {
            $response = Invoke-WebRequest -Uri "http://127.0.0.1:3000" -TimeoutSec 3 -UseBasicParsing
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) { $ready = $true; break }
        } catch {}
        Start-Sleep -Seconds 2
    }
    if ($ready) { Write-Host "`nJuice Shop está disponível em: http://localhost:3000" -ForegroundColor Green }
    else { Write-Host "O container iniciou, mas a página ainda não respondeu. Verifique: docker compose logs -f" -ForegroundColor Yellow }
} else {
    Write-Host "Dependências verificadas. A inicialização foi ignorada por -SkipStart." -ForegroundColor Green
}

Write-Host "`nComandos úteis:" -ForegroundColor Cyan
Write-Host "  docker compose ps"
Write-Host "  docker compose logs -f"
Write-Host "  docker compose down"
Write-Host "  docker compose pull; docker compose up -d"
Write-Host "`nAviso: Juice Shop é intencionalmente vulnerável. Mantenha a porta vinculada a 127.0.0.1 e use apenas em ambiente local/autorizado." -ForegroundColor Yellow
