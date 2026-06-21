$path = "C:\Users\mengxiang\Documents\MengFlix\assets\js\main.js"
$content = Get-Content -Raw -LiteralPath $path

$nl = [char]10
$find = "    track.addEventListener('click', (e) => { if (dragged){ e.preventDefault(); e.stopPropagation(); dragged = false; } }, true);    track.addEventListener('pointermove', (e) => {" + $nl
$find += "      if (!isDown) return;" + $nl
$find += "      const dx = e.clientX - startX;" + $nl
$find += "      if (Math.abs(dx) > 4) dragged = true;" + $nl
$find += "      track.scrollLeft = startScroll - dx;" + $nl
$find += "    });" + $nl
$find += "    function endDrag(){ if (!isDown) return; isDown = false; }" + $nl
$find += "    track.addEventListener('pointerup', endDrag);" + $nl
$find += "    track.addEventListener('pointercancel', endDrag);" + $nl
$find += "    track.addEventListener('pointerleave', endDrag);" + $nl
$find += "    track.addEventListener('click', (e) => { if (dragged){ e.preventDefault(); e.stopPropagation(); dragged = false; } }, true);" + $nl
$find += "  }" + $nl
$find += "  document.querySelectorAll('.slider-wrap').forEach(setupSlider);"

$replace = "    track.addEventListener('click', (e) => { if (dragged){ e.preventDefault(); e.stopPropagation(); dragged = false; } }, true);" + $nl
$replace += "" + $nl
$replace += "    // Block the browser's middle-click auto-scroll on the track and on any card link inside it." + $nl
$replace += "    // Wheel-to-horizontal and left-click drag-to-scroll still work." + $nl
$replace += "    track.addEventListener('mousedown', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$replace += "    track.addEventListener('auxclick', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$replace += "    track.addEventListener('pointerdown', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$replace += "    track.addEventListener('contextmenu', (e) => e.preventDefault());" + $nl
$replace += "  }" + $nl
$replace += "  document.querySelectorAll('.slider-wrap').forEach(setupSlider);" + $nl
$replace += "  // Global guard: stop the browser's middle-click auto-scroll on any link inside a slider track" + $nl
$replace += "  // (the autoscroll cursor uses an up/down arrow icon, which is confusing on a horizontal slider)." + $nl
$replace += "  document.querySelectorAll('.slider-track a').forEach((a) => {" + $nl
$replace += "    a.addEventListener('auxclick', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$replace += "    a.addEventListener('mousedown', (e) => { if (e.button === 1) e.preventDefault(); });" + $nl
$replace += "  });" + $nl
$replace += "  // Also stop middle-click from opening links in a new tab from inside a slider." + $nl
$replace += "  document.addEventListener('auxclick', (e) => {" + $nl
$replace += "    if (e.button !== 1) return;" + $nl
$replace += "    const t = e.target;" + $nl
$replace += "    if (t.closest && t.closest('.slider-track')) e.preventDefault();" + $nl
$replace += "  });" + $nl

if (-not $content.Contains($find)) { Write-Error "find block not found"; exit 1 }
$content = $content.Replace($find, $replace)
Set-Content -LiteralPath $path -Value $content -Encoding UTF8 -NoNewline
Write-Output "patched slider JS: cleaned + middle-click blocked"
