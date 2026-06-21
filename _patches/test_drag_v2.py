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
        track = page.locator(".slider-track").first
        # Get the track's middle
        box = await track.bounding_box()
        cx = box["x"] + box["width"] - 100
        cy = box["y"] + 50
        # Drag from right to left
        await page.mouse.move(cx, cy)
        await page.mouse.down()
        await page.wait_for_timeout(50)
        for i in range(20):
            await page.mouse.move(cx - i*15, cy)
            await page.wait_for_timeout(15)
        await page.mouse.up()
        await page.wait_for_timeout(300)
        sl = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"drag scrollLeft: {sl}")
        await ctx.close()
        await browser.close()

asyncio.run(main())
