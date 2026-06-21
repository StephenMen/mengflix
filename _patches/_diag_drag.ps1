$path = "C:\Users\mengxiang\Documents\MengFlix\assets\js\main.js"
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$lf = "`n"
$old = [string]::Join($lf, @(
  '    // Drag-to-scroll (supports both pointer and mouse events for max compatibility)',
  '    let isDown = false, startX = 0, startScroll = 0, dragged = false;',
  '    function onDown(e){',
  '      if (e.button !== undefined && e.button !== 0) return;',
  '      isDown = true; dragged = false;',
  '      startX = e.clientX; startScroll = track.scrollLeft;',
  '      try { if (e.pointerId !== undefined && track.setPointerCapture) track.setPointerCapture(e.pointerId); } catch (err) {}',
  '    }',
  '    function onMove(e){',
  '      if (!isDown) return;',
  '      const dx = e.clientX - startX;',
  '      if (Math.abs(dx) > 4) dragged = true;',
  '      track.scrollLeft = startScroll - dx;',
  '    }',
  '    function onUp(){ if (!isDown) return; isDown = false; }',
  '    track.addEventListener(''pointerdown'', onDown);',
  '    track.addEventListener(''mousedown'', onDown);',
  '    track.addEventListener(''pointermove'', onMove);',
  '    track.addEventListener(''mousemove'', onMove);',
  '    track.addEventListener(''pointerup'', onUp);',
  '    track.addEventListener(''mouseup'', onUp);',
  '    track.addEventListener(''pointercancel'', onUp);',
  '    track.addEventListener(''pointerleave'', onUp);',
  '    track.addEventListener(''mouseleave'', onUp);',
  '    track.addEventListener(''click'', (e) => { if (dragged){ e.preventDefault(); e.stopPropagation(); dragged = false; } }, true);'
))
$new = [string]::Join($lf, @(
  '    // Drag-to-scroll (pointer + mouse fallback for headless).',
  '    // Only end the drag on pointerup/mouseup/cancel, never on leave — leaving the track',
  '    // mid-drag is normal and the old behavior was breaking long swipes.',
  '    let isDown = false, startX = 0, startScroll = 0, dragged = false, activePointerId = null;',
  '    function onDown(e){',
  '      if (e.button !== undefined && e.button !== 0) return;',
  '      isDown = true; dragged = false;',
  '      startX = e.clientX; startScroll = track.scrollLeft;',
  '      activePointerId = (e.pointerId !== undefined ? e.pointerId : null);',
  '      try { if (activePointerId !== null && track.setPointerCapture) track.setPointerCapture(activePointerId); } catch (err) {}',
  '    }',
  '    function onMove(e){',
  '      if (!isDown) return;',
  '      const dx = e.clientX - startX;',
  '      if (Math.abs(dx) > 4) dragged = true;',
  '      track.scrollLeft = startScroll - dx;',
  '    }',
  '    function onUp(e){',
  '      if (!isDown) return;',
  '      if (activePointerId !== null && e && e.pointerId !== undefined && e.pointerId !== activePointerId) return;',
  '      isDown = false; activePointerId = null;',
  '    }',
  '    track.addEventListener(''pointerdown'', onDown);',
  '    track.addEventListener(''mousedown'', onDown);',
  '    track.addEventListener(''pointermove'', onMove);',
  '    track.addEventListener(''mousemove'', onMove);',
  '    track.addEventListener(''pointerup'', onUp);',
  '    track.addEventListener(''mouseup'', onUp);',
  '    track.addEventListener(''pointercancel'', onUp);',
  '    // Suppress click after a real drag so cards do not open mid-swipe.',
  '    track.addEventListener(''click'', (e) => { if (dragged){ e.preventDefault(); e.stopPropagation(); dragged = false; } }, true);'
))
$contains = $text.Contains($old)
Write-Output ("contains: {0}" -f $contains)
if (-not $contains) { exit 1 }
$text = $text.Replace($old, $new)
[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::UTF8)
Write-Output 'patched main.js'
