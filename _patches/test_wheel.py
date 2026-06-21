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
        box = await track.bounding_box()
        # wheel test
        await page.mouse.move(box["x"] + 500, box["y"] + 150)
        await page.mouse.wheel(0, 200)
        await page.wait_for_timeout(400)
        sl = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"wheel scrollLeft: {sl}")
        # drag test
        await page.evaluate("document.querySelector('.slider-track').scrollLeft = 0")
        await page.wait_for_timeout(300)
        await track.hover(position={"x": 500, "y": 150})
        await page.mouse.down()
        await page.wait_for_timeout(50)
        for i in range(20):
            await page.mouse.move(box["x"] + 500 - i*20, box["y"] + 150, steps=2)
            await page.wait_for_timeout(15)
        await page.mouse.up()
        await page.wait_for_timeout(300)
        sl = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"drag scrollLeft: {sl}")
        await ctx.close()
        await browser.close()

asyncio.run(main())
