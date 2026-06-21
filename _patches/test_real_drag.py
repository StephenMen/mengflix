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
        # Use page-level mouse events with explicit coordinates
        track_box = await page.locator(".slider-track").first.bounding_box()
        # Drag from x=600 (right side of track) to x=200 (left)
        await page.mouse.move(track_box["x"] + 800, track_box["y"] + 50)
        await page.wait_for_timeout(50)
        await page.mouse.down()
        await page.wait_for_timeout(80)
        for i in range(30):
            await page.mouse.move(track_box["x"] + 800 - i*20, track_box["y"] + 50, steps=2)
            await page.wait_for_timeout(15)
        await page.mouse.up()
        await page.wait_for_timeout(500)
        sl = await page.evaluate("document.querySelector('.slider-track').scrollLeft")
        print(f"drag scrollLeft: {sl}")
        # Take screenshot
        await page.screenshot(path="C:\\Users\\mengxiang\\Documents\\MengFlix\\_patches\\d_after_real_drag.png", clip={"x":0, "y":0, "width":1280, "height":600})
        await ctx.close()
        await browser.close()

asyncio.run(main())
