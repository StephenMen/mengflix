import re

with open("assets/js/main.js", "r", encoding="utf-8") as f:
    js = f.read()

# Step 1: Add search filter state + recent searches
si = "var searchIndex = [];"
nsi = "var searchIndex = [];var searchActiveFilter=\"all\";var RECENT_KEY=\"mf_recent_searches\";function getRecentSearches(){try{var d=localStorage.getItem(RECENT_KEY);return d?JSON.parse(d):[]}catch(e){return[]}}function saveRecentSearch(q){if(!q||q.trim().length<2)return;var r=getRecentSearches();r=r.filter(function(s){return s.toLowerCase()!==q.toLowerCase()});r.unshift(q);if(r.length>5)r=r.slice(0,5);try{localStorage.setItem(RECENT_KEY,JSON.stringify(r))}catch(e){}}function renderRecentSearches(){var list=document.getElementById(\"searchRecentList\");var recent=document.getElementById(\"searchRecent\");if(!list||!recent)return;var r=getRecentSearches();if(!r.length){recent.hidden=true;return}recent.hidden=false;list.innerHTML=r.map(function(s){return'<bitton type=\"button\" class=\"search-recent-chip\" data-q=\""+escAttr(s)+'\">'+escAttr(s)+'</button>'}).join(\"\");}"
js = js.replace(si, nsi, 1)
print("step 1 ok")

# Step 2: Modify renderSearchResults
r = "function renderSearchResults(query){if (!searchResults) return; const q = (query || \"\").trim().toLowerCase(); searchLastQuery = q; searchSelectedIdx = 0; if (!q){searchResults.innerHTML = \"\"; if (searchEmpty) searchEmpty.hidden = true; return;}"
nr= "function renderSearchResults(query){if(!searchResults)return;var q=(query||\"\").trim().toLowerCase();searchLastQuery=q;searchSelectedIdx=0;var clearBtn=document.getElementById(\"searchClearBtn\");if(clearBtn)clearBtn.hidden=!q;var meta=document.getElementById(\"searchMeta\");var count=document.getElementById(\"searchCount\");if(!q){searchResults.innerHTML=\"\";if(searchEmpty)searchEmpty.hidden=true;if(meta)meta.hidden=true;var hint=document.getElementById(\"searchHint\");if(hint)hint.hidden=false;return}"
js = js.replace(r, nr, 1)
print("step 2 ok")

# Step 3: Add type filter to loop
loop = "for (let i = 0; i < cards.length; i++){const hay = cardSearchHay(cards[i]); const s = scoreCard(hay, q); if (s >= 0) matched.push({card: cards[i], hay: hay, score: s, index: i});}"
nloop = "for (let i=0;i<cards.length;i++){var hay=cardSearchHay(cards[i]);var s=scoreCard(hay,q);if(s>=0&&searchActiveFilter!==\"all\"&&hay.type.toLowerCase()!==searchActiveFilter)continue;if(s>=0)matched.push({card:cards[i],hay:hay,score:s,index:i});}"
js = js.replace(loop, nloop, 1)
print("step 3 ok")

with open("assets/js/main.js", "w", encoding="utf-8") as f:
    f.write(js)
print("done")
