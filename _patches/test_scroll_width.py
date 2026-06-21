import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path=r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", headless=True, args=["--disable-gpu"])
        ctx = await browser.new_context(viewport={"width":1280,"height":800}, device_scale_factor=1)
        page = await ctx.new_page()
        await page.goto("http://127.0.0.1:8911/index.html", wait_until="domcontentloaded", timeout=15000)
        await page.wait_for_timeout(1500)
        await page.evaluate("window.scrollTo(0, 700)")
        await page.wait_for_timeout(500)
        info = await page.evaluate("""() => {
            const t = document.querySelector('.slider-track');
            return {
                scrollWidth: t.scrollWidth,
                clientWidth: t.clientWidth,
                offsetWidth: t.offsetWidth,
                childCount: t.children.length,
                gap: getComputedStyle(t).gap
            };
        }""")
        print(f"track: {info}")
        # Try setting scrollLeft directly
        result = await page.evaluate("""() => {
            const t = document.querySelector('.slider-track');
            t.scrollLeft = 200;
            return { after: t.scrollLeft, max: t.scrollWidth - t.clientWidth };
        }""")
        print(f"set scrollLeft=200: {result}")
        await ctx.close()
        await browser.close()

asyncio.run(main())
