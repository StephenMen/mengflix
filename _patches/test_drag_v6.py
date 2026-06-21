import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path=r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", headless=True, args=["--disable-gpu"])
        ctx = await browser.new_context(viewport={"width":1280,"height":800}, device_scale_factor=1)
        page = await ctx.new_page()
        page.on("pageerror", lambda exc: print(f"PAGE ERR: {exc}"))
        page.on("console", lambda msg: print(f"[{msg.type}] {msg.text}") if msg.type != "log" else None)
        await page.goto("http://127.0.0.1:8911/index.html", wait_until="domcontentloaded", timeout=15000)
        await page.wait_for_timeout(1500)
        await page.evaluate("window.scrollTo(0, 700)")
        await page.wait_for_timeout(500)
        # Add logging in capture phase
        await page.evaluate("""() => {
            const t = document.querySelector('.slider-track');
            t.addEventListener('mousedown', (e) => { console.warn('CAP mousedown ' + e.button + ' target=' + e.target.tagName + '.' + e.target.className); }, true);
            t.addEventListener('mousedown', (e) => { console.warn('BUB mousedown ' + e.button + ' target=' + e.target.tagName + '.' + e.target.className); }, false);
        }""")
        track = page.locator(".slider-track").first
        await track.hover(position={"x": 500, "y": 150})
        await page.wait_for_timeout(50)
        box = await track.bounding_box()
        cx = box["x"] + 500
        cy = box["y"] + 150
        await page.mouse.down()
        await page.wait_for_timeout(100)
        await page.mouse.up()
        await page.wait_for_timeout(300)
        sl = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"scrollLeft: {sl}")
        await ctx.close()
        await browser.close()

asyncio.run(main())
