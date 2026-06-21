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
        result = await page.evaluate("""() => {
            const t = document.querySelector('.slider-track');
            const before = t.scrollLeft;
            t.scrollBy({ left: 100, behavior: 'instant' });
            const afterBy = t.scrollLeft;
            t.scrollTo({ left: 200 });
            const afterTo = t.scrollLeft;
            t.scrollLeft = 300;
            const afterSet = t.scrollLeft;
            return { before, afterBy, afterTo, afterSet, max: t.scrollWidth - t.clientWidth };
        }""")
        print(f"scroll methods test: {result}")
        # Check computed overflow
        ov = await page.evaluate("getComputedStyle(document.querySelector('.slider-track')).overflowX")
        print(f"overflowX: {ov}")
        await ctx.close()
        await browser.close()

asyncio.run(main())
