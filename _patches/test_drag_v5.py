import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path=r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", headless=True, args=["--disable-gpu"])
        ctx = await browser.new_context(viewport={"width":1280,"height":800}, device_scale_factor=1)
        page = await ctx.new_page()
        page.on("pageerror", lambda exc: print(f"PAGE ERR: {exc}"))
        await page.goto("http://127.0.0.1:8911/index.html", wait_until="domcontentloaded", timeout=15000)
        await page.wait_for_timeout(1500)
        await page.evaluate("window.scrollTo(0, 700)")
        await page.wait_for_timeout(500)
        # Use the actual page.mouse to confirm events arrive
        result = await page.evaluate("""() => {
            const track = document.querySelector('.slider-track');
            // Get all listeners by trying to add an instrumented listener
            let mouseDownEv = null, mouseMoveEv = null;
            track.addEventListener('mousedown', (e) => { mouseDownEv = { button: e.button, x: e.clientX, y: e.clientY }; }, false);
            track.addEventListener('mousemove', (e) => { mouseMoveEv = { x: e.clientX, y: e.clientY, buttons: e.buttons }; }, false);
            window.__getEv = () => ({ mouseDownEv, mouseMoveEv });
        }""")
        track = page.locator(".slider-track").first
        await track.hover(position={"x": 500, "y": 150})
        await page.wait_for_timeout(50)
        box = await track.bounding_box()
        cx = box["x"] + 500
        cy = box["y"] + 150
        await page.mouse.down()
        await page.wait_for_timeout(50)
        for i in range(5):
            await page.mouse.move(cx - i*30, cy)
            await page.wait_for_timeout(20)
        events = await page.evaluate("window.__getEv()")
        print(f"events captured: {events}")
        sl = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"scrollLeft: {sl}")
        await page.mouse.up()
        await ctx.close()
        await browser.close()

asyncio.run(main())
