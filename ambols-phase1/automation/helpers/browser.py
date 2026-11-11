from playwright.async_api import async_playwright

class BrowserSession:
    def __init__(self, base_url, headed=False):
        self.base_url = base_url
        self.headed = headed

    async def __aenter__(self):
        self.playwright = await async_playwright().start()
        self.browser = await self.playwright.chromium.launch(headless=not self.headed)
        self.context = await self.browser.new_context(viewport={"width":1440,"height":900}, locale="pt-BR")
        self.page = await self.context.new_page()
        return self

    async def __aexit__(self, exc_type, exc, tb):
        await self.browser.close()
        await self.playwright.stop()

    async def open(self):
        await self.page.goto(self.base_url, wait_until="domcontentloaded")
        await self.page.wait_for_timeout(1000)
