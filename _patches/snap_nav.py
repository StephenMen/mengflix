import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path=r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", headless=True, args=["--disable-gpu"])
        for label, vp in [
            ("1280", {"width":1280,"height":200}),
            ("1180", {"width":1180,"height":200}),
            ("1040", {"width":1040,"height":200}),
            ("960", {"width":960,"height":200}),
            ("900", {"width":900,"height":200}),
            ("800", {"width":800,"height":200}),
        ]:
            ctx = await browser.new_context(viewport=vp, device_scale_factor=1)
            page = await ctx.new_page()
            page.on("pageerror", lambda exc: print(f"[{label}] err: {exc}"))
            await page.goto("http://127.0.0.1:8911/index.html", wait_until="domcontentloaded", timeout=15000)
            await page.wait_for_timeout(1000)
            await page.screenshot(path=f"C:\\Users\\mengxiang\\Documents\\MengFlix\\_patches\\nav_{label}.png", full_page=False)
            # Check for horizontal overflow
            scrollW = await page.evaluate("document.documentElement.scrollWidth")
            clientW = await page.evaluate("document.documentElement.clientWidth")
            print(f"[{label}] scrollW={scrollW} clientW={clientW} overflow={scrollW - clientW}")
            await ctx.close()
        await browser.close()
        print("done")

asyncio.run(main())
