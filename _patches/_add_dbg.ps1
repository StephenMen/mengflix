$path = "C:\Users\mengxiang\Documents\MengFlix\assets\js\main.js"
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$lf = "`n"
$old = [string]::Join($lf, @(
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
  '    }'
))
$new = [string]::Join($lf, @(
  '    function onDown(e){',
  '      if (e.button !== undefined && e.button !== 0) return;',
  '      isDown = true; dragged = false;',
  '      startX = e.clientX; startScroll = track.scrollLeft;',
  '      activePointerId = (e.pointerId !== undefined ? e.pointerId : null);',
  '      try { if (activePointerId !== null && track.setPointerCapture) track.setPointerCapture(activePointerId); } catch (err) {}',
  '      try { console.log(''[dbg] down btn='', e.button, ''id='', e.pointerId, ''isDown='', isDown); } catch (err) {}',
  '    }',
  '    function onMove(e){',
  '      try { console.log(''[dbg] move id='', e.pointerId, ''isDown='', isDown, ''active='', activePointerId); } catch (err) {}',
  '      if (!isDown) return;',
  '      const dx = e.clientX - startX;',
  '      if (Math.abs(dx) > 4) dragged = true;',
  '      track.scrollLeft = startScroll - dx;',
  '    }',
  '    function onUp(e){',
  '      try { console.log(''[dbg] up id='', e && e.pointerId, ''isDown was'', isDown); } catch (err) {}',
  '      if (!isDown) return;',
  '      if (activePointerId !== null && e && e.pointerId !== undefined && e.pointerId !== activePointerId) return;',
  '      isDown = false; activePointerId = null;',
  '    }'
))
$contains = $text.Contains($old)
Write-Output ("contains: {0}" -f $contains)
if (-not $contains) { exit 1 }
$text = $text.Replace($old, $new)
[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::UTF8)
Write-Output 'patched main.js with dbg'
