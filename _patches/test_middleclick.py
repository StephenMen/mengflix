import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path=r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", headless=True, args=["--disable-gpu"])
        ctx = await browser.new_context(viewport={"width":1280,"height":800}, device_scale_factor=1)
        page = await ctx.new_page()
        page.on("pageerror", lambda exc: print(f"err: {exc}"))
        await page.goto("http://127.0.0.1:8911/index.html", wait_until="domcontentloaded", timeout=15000)
        await page.wait_for_timeout(1500)
        await page.evaluate("window.scrollTo(0, 700)")
        await page.wait_for_timeout(500)

        # Inject counters
        await page.evaluate("""() => {
            window.__events = [];
            const t = document.querySelector(".slider-track");
            t.addEventListener("mousedown", (e) => window.__events.push("mousedown " + e.button), true);
            t.addEventListener("auxclick", (e) => window.__events.push("auxclick " + e.button), true);
            t.addEventListener("contextmenu", (e) => window.__events.push("contextmenu"), true);
        }""")

        # Simulate middle-click on a card
        track = page.locator(".slider-track").first
        box = await track.bounding_box()
        cx = box["x"] + 500
        cy = box["y"] + 150
        # Middle click = button 1
        await page.mouse.click(cx, cy, button="middle")
        await page.wait_for_timeout(500)
        events = await page.evaluate("window.__events")
        scrollL = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"events after middle click: {events}")
        print(f"slider scrollLeft (should still be 0): {scrollL}")
        # Also try middle-down + middle-up separately
        await page.evaluate("window.__events = []")
        await page.mouse.move(cx + 200, cy)
        await page.mouse.down(button="middle")
        await page.wait_for_timeout(50)
        await page.mouse.up(button="middle")
        await page.wait_for_timeout(300)
        events = await page.evaluate("window.__events")
        scrollL = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"events after middle down/up: {events}")
        print(f"slider scrollLeft (should be 0): {scrollL}")
        await ctx.close()
        await browser.close()

asyncio.run(main())
