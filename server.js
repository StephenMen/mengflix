const http = require('http');
const fs = require('fs');
const path = require('path');

const mime = {
  'js': 'text/javascript',
  'css': 'text/css',
  'json': 'application/json',
  'svg': 'image/svg+xml',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'webp': 'image/webp',
  'ico': 'image/x-icon',
  'html': 'text/html',
};

http.createServer((req, res) => {
  let filePath = req.url === '/' ? 'index.html' : req.url.slice(1);
  filePath = path.join(__dirname, filePath);
  const ext = path.extname(filePath).slice(1);
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('404 Not Found');
      return;
    }
    res.writeHead(200, {
      'Permissions-Policy': 'popups=(),fullscreen=(),clipboard-write=(),window-management=()',
      'Content-Type': mime[ext] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    res.end(data);
  });
}).listen(8080, () => {
  console.log('MengFlix server running at http://localhost:8080');
});
