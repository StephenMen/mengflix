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
        await page.wait_for_timeout(800)
        await page.evaluate("document.querySelectorAll('.slider-wrap')[0].scrollIntoView({block: 'center'})")
        await page.wait_for_timeout(500)
        track = page.locator(".slider-track").first
        box = await track.bounding_box()
        cx = box["x"] + box["width"] / 2
        cy = box["y"] + box["height"] / 2
        await page.mouse.move(cx, cy)
        await page.mouse.down()
        for i in range(1, 11):
            await page.mouse.move(cx - i * 40, cy)
            await page.wait_for_timeout(30)
        await page.mouse.up()
        await page.wait_for_timeout(300)
        sl = await track.evaluate("el => el.scrollLeft")
        print("FINAL scrollLeft:", sl)
        for line in logs:
            if '[dbg]' in line:
                print(line)
        await b.close()

asyncio.run(main())
