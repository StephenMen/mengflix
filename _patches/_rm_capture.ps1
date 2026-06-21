$path = "C:\Users\mengxiang\Documents\MengFlix\assets\js\main.js"
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$lf = "`n"
$old = [string]::Join($lf, @(
  '      startX = e.clientX; startScroll = track.scrollLeft;',
  '      activePointerId = (e.pointerId !== undefined ? e.pointerId : null);',
  '      try { if (activePointerId !== null && track.setPointerCapture) track.setPointerCapture(activePointerId); } catch (err) {}',
  '      try { console.log(''[dbg] down btn='', e.button, ''id='', e.pointerId, ''isDown='', isDown); } catch (err) {}',
  '    }'
))
$new = [string]::Join($lf, @(
  '      startX = e.clientX; startScroll = track.scrollLeft;',
  '      activePointerId = (e.pointerId !== undefined ? e.pointerId : null);',
  '      // Pointer capture is intentionally not used: it can swallow move events in some headless setups',
  '      // and is not needed because we listen on both pointer* and mouse* events.',
  '      try { console.log(''[dbg] down btn='', e.button, ''id='', e.pointerId, ''isDown='', isDown); } catch (err) {}',
  '    }'
))
$contains = $text.Contains($old)
Write-Output ("contains: {0}" -f $contains)
if (-not $contains) { exit 1 }
$text = $text.Replace($old, $new)
[System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::UTF8)
Write-Output 'rm capture'
