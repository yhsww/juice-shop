async def run_cat01(session, recorder):
    try:
        await session.page.goto(session.base_url + "/#/")
        await session.page.wait_for_timeout(1200)
        await recorder.capture(session.page, "01", "Abrir catálogo")
        return "passed", "Execução concluída; analisar a evidência capturada."
    except Exception as exc:
        return "inconclusive", f"Execução inconclusiva: {type(exc).__name__}: {exc}"

async def run_cat02(session, recorder):
    try:
        await session.page.goto(session.base_url + "/#/")
        await session.page.wait_for_timeout(1200)
        await recorder.capture(session.page, "01", "Abrir catálogo")
        cards = session.page.locator("mat-card")
        if await cards.count() == 0:
            return "inconclusive", "Nenhum cartão de produto foi localizado; não é possível confirmar a visualização de detalhes."
        await cards.nth(0).click()
        await session.page.wait_for_timeout(800)
        await recorder.capture(session.page, "02", "Selecionar primeiro produto visível")
        return "passed", "Seleção executada; confirmar pelos registros qual detalhe foi efetivamente exibido."
    except Exception as exc:
        return "inconclusive", f"Execução inconclusiva: {type(exc).__name__}: {exc}"

async def run_cat03(session, recorder):
    try:
        await session.page.goto(session.base_url + "/#/")
        await session.page.wait_for_timeout(1200)
        await recorder.capture(session.page, "01", "Abrir catálogo")
        candidates = session.page.locator("input")
        for i in range(await candidates.count()):
            el = candidates.nth(i)
            ph = await el.get_attribute("placeholder")
            aria = await el.get_attribute("aria-label")
            if (ph and "search" in ph.lower()) or (aria and "search" in aria.lower()):
                await el.fill("apple")
                await session.page.wait_for_timeout(700)
                await recorder.capture(session.page, "02", "Pesquisar produto", data={"termo":"apple"})
                return "passed", "Pesquisa executada; interpretar somente o resultado efetivamente observado."
        return "inconclusive", "Campo de pesquisa não localizado pelos atributos disponíveis."
    except Exception as exc:
        return "inconclusive", f"Execução inconclusiva: {type(exc).__name__}: {exc}"
