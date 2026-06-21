import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch(
            executable_path=r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
            headless=True,
            args=["--disable-gpu", "--no-sandbox"],
        )
        ctx = await b.new_context(viewport={"width": 1280, "height": 800})
        page = await ctx.new_page()
        logs = []
        page.on("console", lambda m: logs.append(f"[{m.type}] {m.text}"))
        await page.goto("http://localhost:8911/", wait_until="networkidle")
        # Inject diagnostic listeners
        await page.evaluate("""() => {
            const t = document.querySelectorAll('.slider-track')[0];
            window.__dbg = { events: [] };
            ['pointerdown','mousedown','pointermove','mousemove','pointerup','mouseup','pointerleave','mouseleave','click','wheel','scroll'].forEach(ev => {
                t.addEventListener(ev, (e) => {
                    window.__dbg.events.push({
                        ev, type: e.type, button: e.button,
                        clientX: e.clientX, clientY: e.clientY,
                        scrollLeft: t.scrollLeft,
                        target: (e.target && e.target.className) || ''
                    });
                }, true);
            });
        }""")
        track = page.locator(".slider-track").first
        box = await track.bounding_box()
        cx = box["x"] + box["width"] / 2
        cy = box["y"] + box["height"] / 2
        await page.mouse.move(cx, cy)
        await page.mouse.down()
        for i in range(1, 11):
            await page.mouse.move(cx - i * 40, cy)
            await page.wait_for_timeout(20)
        await page.mouse.up()
        await page.wait_for_timeout(200)
        ev = await page.evaluate("window.__dbg.events")
        for e in ev:
            print(e)
        sl = await track.evaluate("el => el.scrollLeft")
        print("FINAL scrollLeft:", sl)
        await b.close()

asyncio.run(main())
