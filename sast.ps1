[CmdletBinding()]
param(
    [string]$Config = "p/javascript",
    [string]$Output = "sast-report.json"
)

$ErrorActionPreference = "Stop"

function Stop-WithMessage([string]$Message) {
    Write-Error $Message
    exit 1
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Stop-WithMessage "Docker CLI não encontrado. Instale Docker Desktop (Windows/macOS) ou Docker Engine (Linux)."
}

try {
    & docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        Stop-WithMessage "Docker Engine não está ativo. Inicie o Docker Desktop/Engine e tente novamente."
    }
} catch {
    Stop-WithMessage "Não foi possível acessar o Docker Engine. Inicie-o e tente novamente."
}

if ([System.IO.Path]::IsPathRooted($Output) -or $Output.Contains("..") -or $Output.Contains("/") -or $Output.Contains("\")) {
    Stop-WithMessage "O parâmetro -Output deve ser apenas um nome de arquivo, por exemplo sast-report.json."
}

$ProjectPath = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$ContainerOutput = "/src/$Output"

Write-Host "Projeto: $ProjectPath"
Write-Host "Regras:  $Config"
Write-Host "Saída:   $Output"
Write-Host "Executando Semgrep em container Docker..."

# A imagem contém o Semgrep e suas dependências; não é necessário instalar Python/pip no host.
$Volume = "{0}:/src" -f $ProjectPath
& docker run --rm --volume $Volume --workdir /src semgrep/semgrep semgrep scan --config $Config --json --output $ContainerOutput /src
$ScanExitCode = $LASTEXITCODE

if ($ScanExitCode -ne 0) {
    Write-Warning "O Semgrep terminou com código $ScanExitCode. Verifique as mensagens acima e o relatório, se ele foi criado."
    exit $ScanExitCode
}

$HostOutput = Join-Path $ProjectPath $Output
if (Test-Path -LiteralPath $HostOutput) {
    Write-Host "Relatório criado: $HostOutput" -ForegroundColor Green
} else {
    Write-Warning "A execução terminou, mas o arquivo de relatório não foi encontrado em $HostOutput."
    exit 1
}
