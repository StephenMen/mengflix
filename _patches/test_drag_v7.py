import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path=r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", headless=True, args=["--disable-gpu"])
        ctx = await browser.new_context(viewport={"width":1280,"height":800}, device_scale_factor=1)
        page = await ctx.new_page()
        page.on("console", lambda msg: print(f"[{msg.type}] {msg.text}"))
        await page.goto("http://127.0.0.1:8911/index.html", wait_until="domcontentloaded", timeout=15000)
        await page.wait_for_timeout(1500)
        await page.evaluate("window.scrollTo(0, 700)")
        await page.wait_for_timeout(500)
        # Use page-level mouse events
        track = page.locator(".slider-track").first
        box = await track.bounding_box()
        print(f"box: {box}")
        cx, cy = box["x"] + 500, box["y"] + 150
        # First move, then click+drag
        await page.mouse.move(cx, cy)
        await page.wait_for_timeout(50)
        # Check element at that point
        info = await page.evaluate(f"""() => {{
            const el = document.elementFromPoint({cx}, {cy});
            return {{ tag: el && el.tagName, cls: el && el.className, id: el && el.id }};
        }}""")
        print(f"element at ({cx},{cy}): {info}")
        # Try the mouse.down
        await page.mouse.down()
        await page.wait_for_timeout(50)
        # Check if scroll handler is active
        active = await page.evaluate("typeof window.__mfApplyTheme")
        print(f"__mfApplyTheme exists: {active}")
        # Manually trigger scroll
        await page.evaluate("document.querySelector('.slider-track').scrollBy({left: 100, behavior: 'auto'})")
        sl = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"after manual scrollBy: {sl}")
        await page.mouse.up()
        await ctx.close()
        await browser.close()

asyncio.run(main())
