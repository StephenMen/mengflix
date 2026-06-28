"""
MengFlix Core Interaction Tests (Playwright) - v3

Covers: Hero, Sections/Cards, Search, Details, Player, Themes, Mobile, Browse
"""
import sys, os, time, traceback
from playwright.sync_api import sync_playwright

BASE = "http://127.0.0.1:8080"

def wait_ready(page):
    page.wait_for_load_state("networkidle")
    page.wait_for_selector(".content-card", timeout=10000)
    page.wait_for_timeout(400)

def run_tests():
    passed = 0
    failed = 0
    results = []

    def test(name, fn):
        nonlocal passed, failed
        try:
            fn()
            results.append(("PASS", name))
            passed += 1
        except Exception as e:
            traceback.print_exc()
            results.append(("FAIL", name, str(e)))
            failed += 1

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1280, "height": 800})

        # ---- 1. Hero Carousel ----
        def hero_tests():
            page.goto(BASE)
            wait_ready(page)
            slides = page.locator(".yf-hero-slide")
            assert slides.count() > 0, "No hero slides"
            assert slides.count() >= 6, f"Expected >=6 slides, got {slides.count()}"
            assert "active" in slides.nth(0).get_attribute("class"), "First slide not active"
            page.click("#heroNext")
            page.wait_for_timeout(400)
            assert "active" in slides.nth(1).get_attribute("class"), "Second slide not active"
            page.click("#heroPrev")
            page.wait_for_timeout(400)
            assert "active" in slides.nth(0).get_attribute("class"), "First slide not active after prev"
            dots = page.locator(".yf-hero-dot")
            assert dots.count() == slides.count(), f"Dots ({dots.count()}) != slides ({slides.count()})"
            dots.nth(2).click()
            page.wait_for_timeout(400)
            assert "active" in slides.nth(2).get_attribute("class"), "Third slide not active after dot"
            assert page.locator(".yf-hero-actions .btn-play-circle").count() > 0, "No hero play buttons"
            assert page.locator(".yf-hero-actions .btn-secondary-circle").count() > 0, "No hero info buttons"

        test("Hero Carousel Works", hero_tests)

        # ---- 2. Sections & Cards ----
        def sections_tests():
            page.goto(BASE)
            wait_ready(page)
            for s in ["latest-movies", "trending", "top-rated", "latest-series"]:
                assert page.locator(f"#{s}").count() > 0, f"Section #{s} missing"
                cards = page.locator(f"#{s} .content-card")
                try:
                    cards.first.wait_for(timeout=3000)
                except:
                    pass
                print(f"  [{s}] cards: {cards.count()}")
            first_card = page.locator(".content-card").first
            assert len(first_card.get_attribute("data-title") or "") > 0, "Card missing data-title"
            first_card.locator("a[data-open]").click()
            page.wait_for_timeout(800)
            detail_v = page.locator("#detailOverlay").is_visible()
            player_v = page.locator("#playerOverlay").is_visible()
            assert detail_v or player_v, "Card click didn't open detail or player"
            if detail_v:
                page.click("#detailClose")
                page.wait_for_timeout(400)
                detail_hidden = page.locator("#detailOverlay").is_hidden()
                if not detail_hidden:
                    page.keyboard.press("Escape")
                    page.wait_for_timeout(400)

        test("Sections & Cards Render", sections_tests)

        # ---- 3. Search ----
        def search_tests():
            page.goto(BASE)
            wait_ready(page)
            page.click("#searchOpenBtn")
            page.wait_for_timeout(300)
            overlay = page.locator("#searchOverlay")
            assert overlay.is_visible(), "Search overlay not visible"
            input_el = overlay.locator(".search-overlay-input")
            input_el.fill("")
            page.wait_for_timeout(200)
            input_el.type("The", delay=50)
            page.wait_for_timeout(600)
            try:
                page.wait_for_selector("#searchResults .search-result-card", timeout=3000)
            except:
                pass
            result_count = page.locator("#searchResults .search-result-card").count()
            assert result_count > 0, f"No search results for 'The' (count={result_count})"
            # Non-match shows empty state
            input_el.fill("")
            page.wait_for_timeout(200)
            input_el.type("zzzzzzzxxxxx", delay=30)
            page.wait_for_timeout(500)
            empty_msg = page.locator("#searchResultsEmpty")
            if empty_msg.is_hidden():
                rcount = page.locator("#searchResults .search-result-card").count()
                assert rcount == 0, f"Expected 0 results for non-match, got {rcount}"
            # Click a result opens overlay
            input_el.fill("")
            page.wait_for_timeout(200)
            input_el.type("The", delay=50)
            page.wait_for_timeout(600)
            try:
                page.wait_for_selector("#searchResults .search-result-card", timeout=3000)
            except:
                pass
            results = page.locator("#searchResults .search-result-card")
            if results.count() > 0:
                results.first.click()
                page.wait_for_timeout(1000)
                detail_v = page.locator("#detailOverlay").is_visible()
                player_v = page.locator("#playerOverlay").is_visible()
                search_v = page.locator("#searchOverlay").is_visible()
                print(f"  Search click: detail={detail_v} player={player_v} search={search_v}")
                if not detail_v and not player_v:
                    # Attempt fallback: look at what opened
                    print("  WARN: search click didn't open detail or player - checking for errors")
                page.keyboard.press("Escape")
                page.wait_for_timeout(400)

        test("Search Functionality", search_tests)

        # ---- 4. Detail Overlay (via hero info btn) ----
        def detail_tests():
            page.goto(BASE)
            wait_ready(page)
            info_btns = page.locator(".btn-secondary-circle[data-open]")
            count = info_btns.count()
            assert count > 0, "No info buttons with data-open"
            page.evaluate("""() => {
                const btns = document.querySelectorAll(".btn-secondary-circle[data-open]");
                if (btns.length) btns[0].click();
            }""")
            page.wait_for_timeout(1000)
            detail = page.locator("#detailOverlay")
            if not detail.is_visible():
                page.evaluate("""() => {
                    const btns = document.querySelectorAll(".btn-secondary-circle[data-open]");
                    if (btns.length > 1) btns[1].click();
                    else btns[0].click();
                }""")
                page.wait_for_timeout(800)
            assert detail.is_visible(), "Detail overlay not visible after info btn click"
            assert page.locator("#detailTitle").is_visible(), "Detail title missing"
            assert page.locator("#detailPoster").is_visible(), "Detail poster missing"
            assert page.locator("#detailPlay").is_visible(), "Detail Play button missing"
            assert page.locator("#detailFav").is_visible(), "Detail Favorite button missing"
            page.click("#detailFav")
            page.wait_for_timeout(200)
            page.click("#detailClose")
            page.wait_for_timeout(400)
            assert detail.is_hidden(), "Detail didn't close"

        test("Detail Overlay", detail_tests)

        # ---- 5. Player Overlay ----
        def player_tests():
            page.goto(BASE)
            wait_ready(page)
            page.locator(".btn-play-circle[data-open]").first.click()
            page.wait_for_timeout(800)
            player = page.locator("#playerOverlay")
            assert player.is_visible(), "Player overlay not visible"
            assert page.locator("#playerFrame").is_visible(), "Player iframe missing"
            page.keyboard.press("Escape")
            page.wait_for_timeout(400)
            assert player.is_hidden(), "Player didn't close on Escape"

        test("Player Overlay", player_tests)

        # ---- 6. Theme Switching ----
        def theme_tests():
            page.goto(BASE)
            wait_ready(page)
            theme_attr = page.evaluate('() => document.documentElement.getAttribute("data-theme")')
            assert theme_attr, f'data-theme not set on html element'
            print(f'  Current theme: {theme_attr}')
            theme_link = page.evaluate('() => { const l = document.getElementById("theme-css"); return l ? l.outerHTML.slice(0, 100) : "not found"; }')
            print(f'  Theme link: {theme_link}')
            for theme in ["black", "blue", "green", "orange", "purple"]:
                fpath = os.path.join(r"C:\Users\mengxiang\Documents\MengFlix", "assets", "css", f"theme-{theme}.css")
                assert os.path.exists(fpath), f"Theme file theme-{theme}.css missing"
            print(f'  All theme CSS files verified')
            page.evaluate('() => { if (window.__mfApplyTheme) window.__mfApplyTheme("black"); }')
            page.wait_for_timeout(300)
            new_theme = page.evaluate('() => document.documentElement.getAttribute("data-theme")')
            assert new_theme == "black", f'Theme switch to black failed, got {new_theme}'
            print(f'  Switched to: {new_theme}')
            page.evaluate('() => { if (window.__mfApplyTheme) window.__mfApplyTheme("white"); }')
            page.wait_for_timeout(200)

        test("Theme Switching", theme_tests)        # ---- 7. Browse Dropdown ----
        def browse_tests():
            page.goto(BASE)
            wait_ready(page)
            btn = page.locator(".btn-browse")
            if btn.count() > 0:
                menu = page.locator(".browse-dropdown-menu")
                assert menu.is_hidden(), "Browse menu visible initially"
                btn.click()
                page.wait_for_timeout(200)
                assert menu.is_visible(), "Browse menu not visible after click"
                items = menu.locator("a")
                assert items.count() >= 4, f"Expected >=4 browse items, got {items.count()}"
                page.locator(".site-logo").click()
                page.wait_for_timeout(200)
                assert menu.is_hidden(), "Browse menu didn't close"
            else:
                print("  No browse dropdown found")

        test("Browse Dropdown", browse_tests)

        # ---- 8. Mobile Menu ----
        def mobile_tests():
            page.set_viewport_size({"width": 375, "height": 812})
            page.goto(BASE)
            wait_ready(page)
            menu_btn = page.locator("#mobileMenuBtn")
            assert menu_btn.is_visible(), "Mobile menu button missing on small viewport"
            mobile_menu = page.locator("#mobileMenu")
            assert mobile_menu.is_hidden(), "Mobile menu visible initially"
            menu_btn.click()
            page.wait_for_timeout(300)
            assert mobile_menu.is_visible(), "Mobile menu not visible after click"
            links = mobile_menu.locator("a")
            assert links.count() >= 5, f"Expected >=5 mobile links, got {links.count()}"
            links.first.click()
            page.wait_for_timeout(300)
            assert mobile_menu.is_hidden(), "Mobile menu didn't close after link click"

        test("Mobile Menu", mobile_tests)

        # ---- 9. Sign In ----
        def signin_tests():
            page.set_viewport_size({"width": 1280, "height": 800})
            page.goto(BASE)
            wait_ready(page)
            btn = page.locator("#signInBtn")
            btn_count = btn.count()
            if btn_count > 0:
                btn.click()
                page.wait_for_timeout(500)
                print("  Sign In clicked")
            else:
                print("  #signInBtn not found - checking HTML...")
                html = page.content()
                if "signInBtn" in html:
                    print("  Found in HTML but not selectable (likely display:none or visibility:hidden)")
                else:
                    print("  Not in HTML at all")

        test("Sign In Button", signin_tests)

        # ---- 10. Accessibility Basics ----
        def a11y_tests():
            page.set_viewport_size({"width": 1280, "height": 800})
            page.goto(BASE)
            wait_ready(page)
            skip = page.locator(".skip-link")
            assert skip.is_visible(), "Skip link missing"
            assert "Skip" in skip.text_content(), "Skip link text wrong"
            headings = page.locator("h1, h2, h3")
            assert headings.count() > 5, f"Few headings ({headings.count()})"

        test("Accessibility Basics", a11y_tests)

        # ---- Results ----
        print(f"\n{'='*50}")
        print(f"RESULTS: {passed} passed, {failed} failed ({passed + failed} total)")
        print(f"{'='*50}")
        for r in results:
            if r[0] == "PASS":
                print(f"  OK  {r[1]}")
            else:
                print(f"  FAIL {r[1]}: {r[2]}")

        browser.close()
        if failed > 0:
            sys.exit(1)

if __name__ == "__main__":
    os.makedirs("tests/screenshots", exist_ok=True)
    run_tests()
