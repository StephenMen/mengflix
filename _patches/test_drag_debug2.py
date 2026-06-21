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
        # Wait a bit
        await page.wait_for_timeout(1000)
        # List sliders
        info = await page.evaluate("""() => {
            const wraps = Array.from(document.querySelectorAll('.slider-wrap'));
            return wraps.slice(0, 3).map(w => {
                const t = w.querySelector('.slider-track');
                const r = t.getBoundingClientRect();
                return {
                    wrapClass: w.className,
                    trackClass: t.className,
                    rect: { x: r.x, y: r.y, w: r.width, h: r.height },
                    scrollWidth: t.scrollWidth,
                    clientWidth: t.clientWidth,
                    inViewport: r.y >= 0 && r.y < window.innerHeight
                };
            });
        }""")
        for s in info:
            print(s)
        # What element is at center of viewport?
        cx = 640; cy = 400
        elInfo = await page.evaluate(f"""() => {{
            const el = document.elementFromPoint({cx}, {cy});
            return el ? el.outerHTML.slice(0, 200) : 'none';
        }}""")
        print("Element at viewport center:", elInfo)
        await b.close()

asyncio.run(main())
