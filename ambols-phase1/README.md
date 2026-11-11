# AMBOLS — Juice Shop — Fase 1

Automação da investigação dinâmica do OWASP Juice Shop pela interface gráfica.

## Executar no Codespace

Na raiz do repositório:

    cd ambols-phase1
    python -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    python -m playwright install chromium

No Codespace Linux, use os comandos acima. Para Windows PowerShell, use:

    .\.venv\Scripts\Activate.ps1

Depois verifique:

    python run.py --check

E execute um cenário:

    python run.py --scenario CEN-CAT-01 --headed

Ou todos os cenários implementados:

    python run.py --all --headed

O Juice Shop precisa estar disponível em http://localhost:3000.

Os resultados ficam em executions/ e documentation/.

## Credenciais

Os cenários de login/logout não inventam credenciais. Defina as credenciais reais de teste no ambiente:

    export AMBOLS_TEST_EMAIL="seu-usuario-de-teste"
    export AMBOLS_TEST_PASSWORD="sua-senha-de-teste"

Sem elas, os cenários dependentes de sessão permanecem inconclusivos.

## Regra metodológica

A automação coleta evidências. Ela não transforma automaticamente observações em requisitos definitivos.

Não são executadas chamadas diretas à API, inspeção de endpoints, análise HTTP, análise de código-fonte ou testes de vulnerabilidade nesta fase.
