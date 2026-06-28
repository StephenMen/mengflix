const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

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

const USERS_FILE = path.join(__dirname, '_users.json');

function readUsers() {
  try { return JSON.parse(fs.readFileSync(USERS_FILE, 'utf-8')); }
  catch { return []; }
}
function writeUsers(u) {
  fs.writeFileSync(USERS_FILE, JSON.stringify(u, null, 2));
}

function sendJSON(res, status, data) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
  });
  res.end(JSON.stringify(data));
}
function parseBody(req) {
  return new Promise(resolve => {
    let body = '';
    req.on('data', c => body += c);
    req.on('end', () => {
      try { resolve(JSON.parse(body)); }
      catch { resolve({}); }
    });
  });
}

function handleAPI(req, res) {
  const url = new URL(req.url, 'http://localhost');
  const pathname = url.pathname;

  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
    });
    return res.end();
  }

  // POST /api/auth/register
  if (pathname === '/api/auth/register' && req.method === 'POST') {
    return parseBody(req).then(b => {
      const { name, email, password } = b;
      if (!email || !password || password.length < 6) {
        return sendJSON(res, 400, { ok: false, error: 'Invalid email or password (min 6 chars)' });
      }
      const users = readUsers();
      if (users.find(u => u.email === email)) {
        return sendJSON(res, 409, { ok: false, error: 'An account with this email already exists' });
      }
      const hashed = crypto.createHash('sha256').update(password).digest('hex');
      const user = {
        id: Date.now().toString(36) + Math.random().toString(36).slice(2, 8),
        name: (name || email.split('@')[0]).trim(),
        email,
        password: hashed,
        picture: '',
        joined: new Date().toISOString(),
      };
      users.push(user);
      writeUsers(users);
      const { password: _, ...safe } = user;
      safe.token = user.id;
      sendJSON(res, 200, { ok: true, user: safe });
    });
  }

  // POST /api/auth/login
  if (pathname === '/api/auth/login' && req.method === 'POST') {
    return parseBody(req).then(b => {
      const { email, password } = b;
      if (!email || !password) {
        return sendJSON(res, 400, { ok: false, error: 'Email and password required' });
      }
      const users = readUsers();
      const hashed = crypto.createHash('sha256').update(password).digest('hex');
      const user = users.find(u => u.email === email && u.password === hashed);
      if (!user) {
        return sendJSON(res, 401, { ok: false, error: 'Invalid email or password' });
      }
      const { password: _, ...safe } = user;
      safe.token = user.id;
      sendJSON(res, 200, { ok: true, user: safe });
    });
  }

  // POST /api/auth/google
  if (pathname === '/api/auth/google' && req.method === 'POST') {
    return parseBody(req).then(b => {
      const { name, email, picture, googleId } = b;
      if (!email || !googleId) {
        return sendJSON(res, 400, { ok: false, error: 'Missing Google account data' });
      }
      const users = readUsers();
      let user = users.find(u => u.email === email);
      if (!user) {
        user = {
          id: Date.now().toString(36) + Math.random().toString(36).slice(2, 8),
          name: (name || email.split('@')[0]).trim(),
          email,
          password: '',
          picture: picture || '',
          googleId,
          joined: new Date().toISOString(),
        };
        users.push(user);
        writeUsers(users);
      } else if (!user.googleId) {
        user.googleId = googleId;
        user.picture = user.picture || picture || '';
        writeUsers(users);
      }
      const { password: _, ...safe } = user;
      safe.token = user.id;
      sendJSON(res, 200, { ok: true, user: safe });
    });
  }

  // GET /api/auth/session?token=...
  if (pathname === '/api/auth/session' && req.method === 'GET') {
    const token = url.searchParams.get('token');
    if (!token) return sendJSON(res, 400, { ok: false, error: 'No token' });
    const users = readUsers();
    const user = users.find(u => u.id === token);
    if (!user) return sendJSON(res, 401, { ok: false, error: 'Invalid session' });
    const { password: _, ...safe } = user;
    sendJSON(res, 200, { ok: true, user: safe });
  }

  return null; // not an API route
}

http.createServer((req, res) => {
  const apiResult = handleAPI(req, res);
  if (apiResult !== null) return;

  const parsedUrl = new URL(req.url, 'http://localhost');
  let filePath = parsedUrl.pathname === '/' ? 'index.html' : parsedUrl.pathname.slice(1);
  filePath = path.join(__dirname, filePath);
  const ext = path.extname(filePath).slice(1);
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('404 Not Found');
      return;
    }
    res.writeHead(200, {
      'Permissions-Policy': 'popups=(),fullscreen=(self),clipboard-write=(),window-management=()',
      'Content-Type': mime[ext] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    res.end(data);
  });
}).listen(8080, () => {
  console.log('MengFlix server running at http://localhost:8080');
});
