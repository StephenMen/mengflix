/* MengFlix Donghua Episode Player */
(function() {
'use strict';

var donghuaCache = null;
var currentTitle = null;
var currentEpisode = null;
var epContainer = document.getElementById('playerEpisodes');
var epGrid = document.getElementById('episodeGrid');
var epCount = document.getElementById('episodeCount');

async function loadDonghua() {
  if (donghuaCache) return donghuaCache;
  try {
    var res = await fetch('assets/donghua.json');
    donghuaCache = await res.json();
    return donghuaCache;
  } catch(e) {
    console.warn('[ep] donghua.json load failed:', e);
    return {};
  }
}

function escAttr(s) {
  return String(s == null ? '' : s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function openPlayerOverlay(title, type, poster) {
  var overlay = document.getElementById('playerOverlay');
  var panel = document.getElementById('playerPanel');
  var pTitle = document.getElementById('playerTitle');
  var pCrumb = document.getElementById('playerCrumbTitle');
  var pCrumbType = document.getElementById('playerCrumbType');
  var pFrame = document.getElementById('playerFrame');
  var pPlaceholder = document.getElementById('playerPlaceholder');
  var pServers = document.getElementById('playerServers');
  var pWatchLink = document.getElementById('playerWatchLink');

  if (pTitle) pTitle.textContent = title;
  if (pCrumb) pCrumb.textContent = title;
  if (pCrumbType) pCrumbType.textContent = 'Donghua';
  if (pServers) pServers.innerHTML = '<p class="player-servers-empty">Select an episode first, then choose a server</p>';
  if (pFrame) pFrame.removeAttribute('src');
  if (pPlaceholder) pPlaceholder.classList.remove('is-hidden');
  if (pWatchLink) { pWatchLink.href = '#'; pWatchLink.style.display = 'none'; }

  if (overlay) {
    overlay.hidden = false;
    overlay.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
    if (panel) panel.focus();
  }
}

function buildEpisodeGrid(matchTitle, episodes) {
  if (!epGrid) return;
  if (!episodes || episodes.length === 0) {
    epGrid.innerHTML = '<p class="player-episodes-empty">No episodes available yet. Coming soon!</p>';
    if (epCount) epCount.textContent = '';
    return;
  }
  if (epCount) epCount.textContent = episodes.length + ' episodes';

  var html = '';
  for (var i = 0; i < episodes.length; i++) {
    var ep = episodes[i];
    var active = (currentEpisode && currentEpisode.number === ep.number) ? ' is-active' : '';
    html += '<button type="button" class="episode-btn' + active + '" data-ep="' + ep.number + '" data-title="' + escAttr(matchTitle) + '" data-index="' + i + '">' +
      '<span class="episode-num">' + ep.number + '</span>' +
      '<span class="episode-title-text">' + escAttr(ep.title || 'EP ' + ep.number) + '</span>' +
      '</button>';
  }
  epGrid.innerHTML = html;

  epGrid.querySelectorAll('.episode-btn').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
      var epNum = parseInt(this.dataset.ep);
      var epTitle = this.dataset.title || currentTitle;
      playEpisode(epTitle, epNum);
    });
  });
}

async function openDonghuaPicker(card) {
  var title = card.dataset.title || '';
  var type = card.dataset.type || '';
  if (type !== 'Donghua') return;

  var data = await loadDonghua();
  var match = data[title];
  if (!match) {
    for (var key in data) {
      var norm = key.toLowerCase().replace(/[^a-z0-9]+/g, '-');
      var ct = title.toLowerCase().replace(/[^a-z0-9]+/g, '-');
      if (norm === ct) { match = data[key]; break; }
    }
  }
  if (!match) return;

  currentTitle = title;
  var episodes = match.episodes || [];

  openPlayerOverlay(title, type, card.dataset.poster || '');
  if (epContainer) epContainer.hidden = false;
  buildEpisodeGrid(title, episodes);
}

function playEpisode(title, episodeNum) {
  if (!donghuaCache) return;
  var match = donghuaCache[title];
  if (!match || !match.episodes) return;

  var ep = null;
  for (var i = 0; i < match.episodes.length; i++) {
    if (match.episodes[i].number === episodeNum) {
      ep = match.episodes[i];
      break;
    }
  }
  if (!ep) return;

  currentEpisode = ep;

  // Update active state on episode buttons
  var epBtns = document.querySelectorAll('.episode-btn');
  epBtns.forEach(function(b) {
    b.classList.toggle('is-active', parseInt(b.dataset.ep) === episodeNum);
  });

  // Get sources from episode or fallback to match-level sources
  var sources = (ep.sources || match.sources || []).filter(function(s){var t=(s.name||'')+(s.provider||'')+(s.url||'');t=t.toLowerCase();return t.indexOf('ramoflix')<0&&t.indexOf('vidsrc')<0});if(sources.length===0&&watchUrl)sources.push({name:'AnimeCube',url:watchUrl,provider:'animecube'});
  var watchUrl = match.watch_url || 'https://animecube.live/anime/' + (match.slug || '') + '/' + episodeNum;

  // Populate servers
  var pServers = document.getElementById('playerServers');
  if (pServers) {
    pServers.innerHTML = '';
    if (sources.length === 0) {
      pServers.innerHTML = '<p class="player-servers-empty">No playable servers for this episode. Try the external link below.</p>';
    } else {
      sources.forEach(function(s, i) {
        var b = document.createElement('button');
        b.type = 'button';
        b.className = 'player-server-btn';
        b.setAttribute('role', 'tab');
        b.setAttribute('aria-selected', i === 0 ? 'true' : 'false');
        b.dataset.index = String(i);
        var provider = s.provider || '';
        try { if (!provider) provider = new URL(s.url).host.replace(/^www\./, ''); } catch(e) {}
        b.innerHTML = '<span class="server-dot"></span><span class="server-meta"><span class="server-name">' + escAttr(s.name) + '</span><span class="player-server-host">' + escAttr(provider) + '</span></span>';
        b.addEventListener('click', function() { selectServer(i, sources); });
        pServers.appendChild(b);
      });
    }
  }

  // Set watch link
  var pWatchLink = document.getElementById('playerWatchLink');
  if (pWatchLink) {
    pWatchLink.href = watchUrl || '#';
    pWatchLink.style.display = watchUrl ? '' : 'none';
  }

  // Auto-select first server
  if (sources.length > 0) {
    selectServer(0, sources);
  }
}

function selectServer(idx, sources) {
  if (!sources || !sources[idx]) return;
  var frame = document.getElementById('playerFrame');
  var placeholder = document.getElementById('playerPlaceholder');
  if (frame) frame.src = sources[idx].url;
  if (placeholder) placeholder.classList.add('is-hidden');

  var btns = document.querySelectorAll('#playerServers .player-server-btn');
  btns.forEach(function(b, i) {
    b.setAttribute('aria-selected', i === idx ? 'true' : 'false');
  });
}

function init() {
  document.addEventListener('click', function(e) {
    var card = e.target.closest && e.target.closest('.content-card');
    if (!card) return;
    if (card.dataset.type !== 'Donghua') return;
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();
    openDonghuaPicker(card);
  }, true);

  // Also handle hero slide buttons
  document.addEventListener('click', function(e) {
    var btn = e.target.closest && e.target.closest('.yf-hero-slide [data-open]');
    if (!btn) return;
    var card = btn.closest('.content-card');
    if (card && card.dataset.type === 'Donghua') {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      openDonghuaPicker(card);
    }
  }, true);
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}

window.__mfShowEpisodes = openDonghuaPicker;
window.__mfPlayEpisode = playEpisode;

})();