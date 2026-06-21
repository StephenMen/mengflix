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
        await page.goto("http://localhost:8911/", wait_until="networkidle")
        await page.wait_for_timeout(500)
        # Find first slider track
        track = page.locator(".slider-track").first
        box = await track.bounding_box()
        print("track box:", box)
        # Where is scroll left before
        sl0 = await track.evaluate("el => el.scrollLeft")
        print("scrollLeft before:", sl0)
        # Drag from middle of the track to the left by 400px
        cx = box["x"] + box["width"] / 2
        cy = box["y"] + box["height"] / 2
        await page.mouse.move(cx, cy)
        await page.mouse.down()
        for i in range(1, 11):
            await page.mouse.move(cx - i * 40, cy)
            await page.wait_for_timeout(20)
        await page.mouse.up()
        await page.wait_for_timeout(200)
        sl1 = await track.evaluate("el => el.scrollLeft")
        print("scrollLeft after drag:", sl1)
        # Now try middle click
        sl2 = await track.evaluate("el => el.scrollLeft")
        await page.mouse.click(cx, cy, button="middle")
        await page.wait_for_timeout(200)
        sl3 = await track.evaluate("el => el.scrollLeft")
        print("scrollLeft after middle-click:", sl3)
        # Wheel
        await page.mouse.wheel(0, 300)
        await page.wait_for_timeout(200)
        sl4 = await track.evaluate("el => el.scrollLeft")
        print("scrollLeft after wheel:", sl4)
        await b.close()

asyncio.run(main())
