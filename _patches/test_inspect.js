// Inject a script via page.evaluate to monitor drag
(async () => {
  const t = document.querySelector(".slider-track");
  let md = 0, mm = 0;
  t.addEventListener("mousedown", (e) => { md++; console.warn("Mousedown " + md + " button=" + e.button + " target=" + e.target.tagName + "." + e.target.className); }, true);
  t.addEventListener("mousemove", (e) => { mm++; if (mm % 5 === 0) console.warn("Mousemove " + mm + " buttons=" + e.buttons + " target=" + e.target.tagName + "." + e.target.className); }, true);
  window.__m = () => ({ md, mm });
})();
