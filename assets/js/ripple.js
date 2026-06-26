(function() {
  "use strict";

  var lastTrigger = null;

  // Capture trigger position before any event handlers fire (capture phase)
  document.addEventListener("click", function(e) {
    var card = e.target.closest(".content-card, [data-open]");
    if (card) {
      var r = card.getBoundingClientRect();
      lastTrigger = {
        x: r.left + r.width / 2,
        y: r.top + r.height / 2
      };
    }
  }, true);

  document.addEventListener("click", function(e) {
    var btn = e.target.closest(".btn-play-circle, .btn-secondary-circle");
    if (btn) {
      var r = btn.getBoundingClientRect();
      lastTrigger = {
        x: r.left + r.width / 2,
        y: r.top + r.height / 2
      };
    }
  }, true);

  // Override close animation with iOS-like transform
  var origClose = window.__mfAnimateClose;
  window.__mfAnimateClose = function(overlay, panelEl, onDone) {
    if (!overlay) { if (typeof onDone === "function") onDone(); return; }
    if (overlay.dataset.closing === "1") return;

    var panel = panelEl || overlay.querySelector(".detail-panel, .player-panel");
    if (!panel) panel = overlay;

    if (lastTrigger && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      var pr = panel.getBoundingClientRect();
      var pcx = pr.left + pr.width / 2;
      var pcy = pr.top + pr.height / 2;
      var isPlayer = overlay.classList.contains("player-overlay");
      var s = isPlayer ? 0.82 : 0.68;
      var dx = (lastTrigger.x - pcx) * 0.6;
      var dy = ((lastTrigger.y - pcy) * 0.3) + 20;
      panel.style.setProperty("--close-tx", dx.toFixed(1) + "px");
      panel.style.setProperty("--close-ty", dy.toFixed(1) + "px");
      panel.style.setProperty("--close-s", String(s));
    } else {
      panel.style.setProperty("--close-tx", "0px");
      panel.style.setProperty("--close-ty", "30px");
      panel.style.setProperty("--close-s", "0.85");
    }

    overlay.dataset.closing = "1";
    overlay.classList.add("is-closing");

    var finished = false;
    function done() {
      if (finished) return;
      finished = true;
      overlay.classList.remove("is-closing");
      overlay.removeAttribute("data-closing");
      panel.style.removeProperty("--close-tx");
      panel.style.removeProperty("--close-ty");
      panel.style.removeProperty("--close-s");
      lastTrigger = null;
      if (typeof onDone === "function") onDone();
    }

    var onEnd = function(e) {
      if (e && e.target !== panel) return;
      panel.removeEventListener("animationend", onEnd);
      done();
    };
    panel.addEventListener("animationend", onEnd);
    setTimeout(done, 450);

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setTimeout(done, 0);
    }
  };

  // Search overlay close with animation
  var origSearchClose = window.closeSearch;
  if (typeof origSearchClose === "function") {
    window.closeSearch = function() {
      var search = document.getElementById("searchOverlay");
      if (!search || search.hidden) return;
      search.classList.add("is-closing");
      search.dataset.closing = "1";
      setTimeout(function() {
        search.hidden = true;
        search.classList.remove("is-closing");
        search.removeAttribute("data-closing");
        document.body.style.overflow = "";
      }, 220);
    };
  }

  // Press animation on interactive elements
  document.addEventListener("mousedown", function(e) {
    var el = e.target.closest(
      ".content-card, .btn-play-circle, .btn-secondary-circle, " +
      ".slider-btn, .badge, .detail-close, .player-close, " +
      ".player-server-btn, .nav-search-link, .mobile-menu-toggle, " +
      ".nav-theme-link, .btn-view-all, .btn-signin, .episode-btn, " +
      ".theme-option, .btn-browse"
    );
    if (el) {
      el.style.transition = "transform 0.12s cubic-bezier(0.34, 1.56, 0.64, 1)";
      el.style.transform = "scale(0.96)";
    }
  }, true);

  document.addEventListener("mouseup", function(e) {
    var el = e.target.closest(
      ".content-card, .btn-play-circle, .btn-secondary-circle, " +
      ".slider-btn, .badge, .detail-close, .player-close, " +
      ".player-server-btn, .nav-search-link, .mobile-menu-toggle, " +
      ".nav-theme-link, .btn-view-all, .btn-signin, .episode-btn, " +
      ".theme-option, .btn-browse"
    );
    if (el) {
      el.style.transform = "scale(1)";
    }
  }, true);

  document.addEventListener("mouseleave", function(e) {
    var el = e.target;
    if (el && el.style && el.style.transform === "scale(0.96)") {
      el.style.transform = "scale(1)";
    }
  }, true);

})();
