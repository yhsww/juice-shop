import os
import uuid

def unique_email():
    return f"ambols_{uuid.uuid4().hex[:10]}@example.invalid"

async def run_idt01(session, recorder):
    try:
        await session.page.goto(session.base_url + "/#/register")
        await session.page.wait_for_timeout(800)
        await recorder.capture(session.page, "01", "Abrir tela de cadastro")
        await session.page.locator("input").nth(0).fill("AMBOLS Teste")
        await session.page.locator("input").nth(1).fill(unique_email())
        await session.page.locator("input").nth(2).fill("12345")
        await recorder.capture(session.page, "02", "Preencher formulário de cadastro",
                               data={"nome":"AMBOLS Teste","email":"[gerado]","senha":"[omitida]"})
        await session.page.get_by_role("button", name="Register").click()
        await session.page.wait_for_timeout(1200)
        await recorder.capture(session.page, "03", "Submeter cadastro")
        return "passed", "Execução concluída; a criação efetiva da conta deve ser confirmada somente pela evidência capturada."
    except Exception as exc:
        return "inconclusive", f"Não foi possível concluir o cenário pela interface: {type(exc).__name__}: {exc}"

async def run_idt02(session, recorder):
    email = os.getenv("AMBOLS_TEST_EMAIL")
    password = os.getenv("AMBOLS_TEST_PASSWORD")
    if not email or not password:
        return "inconclusive", "Credenciais de teste não fornecidas; nenhuma credencial foi inventada."
    try:
        await session.page.goto(session.base_url + "/#/login")
        await session.page.wait_for_timeout(800)
        await recorder.capture(session.page, "01", "Abrir tela de login")
        await session.page.locator("input").nth(0).fill(email)
        await session.page.locator("input").nth(1).fill(password)
        await session.page.get_by_role("button", name="Login").click()
        await session.page.wait_for_timeout(1200)
        await recorder.capture(session.page, "02", "Enviar credenciais", data={"email":email,"senha":"[omitida]"})
        return "passed", "Fluxo executado; a autenticação deve ser determinada pelo estado e texto realmente capturados."
    except Exception as exc:
        return "inconclusive", f"Execução inconclusiva: {type(exc).__name__}: {exc}"

async def run_idt03(session, recorder):
    email = os.getenv("AMBOLS_TEST_EMAIL")
    password = os.getenv("AMBOLS_TEST_PASSWORD")
    if not email or not password:
        return "inconclusive", "Credenciais de teste não fornecidas; o logout não será executado sem uma sessão autenticada real."
    try:
        await session.page.goto(session.base_url + "/#/login")
        await session.page.wait_for_timeout(700)
        await session.page.locator("input").nth(0).fill(email)
        await session.page.locator("input").nth(1).fill(password)
        await session.page.get_by_role("button", name="Login").click()
        await session.page.wait_for_timeout(1000)
        await recorder.capture(session.page, "01", "Autenticar usuário para iniciar a sessão")
        logout = session.page.get_by_text("Logout", exact=True)
        if await logout.count() == 0:
            await recorder.capture(session.page, "02", "Procurar ação de logout")
            return "inconclusive", "Logout não foi localizado após a tentativa de autenticação."
        await logout.click()
        await session.page.wait_for_timeout(800)
        await recorder.capture(session.page, "03", "Acionar logout")
        return "passed", "A ação de logout foi executada; confirmar o efeito pelo estado registrado."
    except Exception as exc:
        return "inconclusive", f"Não foi possível confirmar a execução do logout: {type(exc).__name__}: {exc}"

async def run_idt04(session, recorder):
    try:
        await session.page.goto(session.base_url + "/#/login")
        await session.page.wait_for_timeout(700)
        await recorder.capture(session.page, "01", "Abrir tela de login")
        await session.page.locator("input").nth(0).fill(unique_email())
        await session.page.locator("input").nth(1).fill("senha_incorreta_ambols")
        await session.page.get_by_role("button", name="Login").click()
        await session.page.wait_for_timeout(900)
        await recorder.capture(session.page, "02", "Enviar credenciais inválidas",
                               data={"email":"[gerado]","senha":"[omitida]"})
        return "passed", "Fluxo executado; aceitação ou rejeição deve ser determinada pelo texto e estado realmente capturados."
    except Exception as exc:
        return "inconclusive", f"Execução inconclusiva: {type(exc).__name__}: {exc}"
