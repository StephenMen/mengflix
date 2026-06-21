from playwright.sync_api import sync_playwright
import os
out_dir = r'C:\Users\mengxiang\Documents\MengFlix'
out = os.path.join(out_dir, 'gladiator_ii.png')
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1440, "height": 900})
    page.goto("http://127.0.0.1:8765/?theme=white")
    page.wait_for_function("document.documentElement.getAttribute('data-theme') === 'white'", timeout=3000)
    page.wait_for_timeout(600)
    # Find the Gladiator II card
    card = page.locator('.content-card[data-title="Gladiator II"]').first
    card.scroll_into_view_if_needed()
    page.wait_for_timeout(400)
    # Take a tight crop around the card with a little padding
    box = card.bounding_box()
    print("card box:", box)
    pad = 24
    clip = {
        "x": max(0, box["x"] - pad),
        "y": max(0, box["y"] - pad),
        "width": min(1440, box["width"] + pad*2),
        "height": min(900, box["height"] + pad*2)
    }
    page.screenshot(path=out, clip=clip)
    print("saved", out)
    browser.close()
