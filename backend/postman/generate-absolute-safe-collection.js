const fs = require('fs');
const path = require('path');

const BASE = 'http://localhost:3000';

const urlObj = (fullUrl) => {
  const u = new URL(fullUrl);
  return {
    raw: fullUrl,
    protocol: u.protocol.replace(':', ''),
    host: u.hostname.split('.'),
    ...(u.port ? { port: u.port } : {}),
    path: u.pathname.split('/').filter(Boolean),
    ...(u.search ? {
      query: Array.from(u.searchParams.entries()).map(([key, value]) => ({ key, value })),
    } : {}),
  };
};

const mkReq = (name, method, fullUrl, body, authVar) => ({
  name,
  request: {
    method,
    header: [
      ...(authVar ? [{ key: 'Authorization', value: `Bearer {{${authVar}}}` }] : []),
      ...(body !== undefined ? [{ key: 'Content-Type', value: 'application/json' }] : []),
    ],
    url: urlObj(fullUrl),
    ...(body !== undefined
      ? {
          body: {
            mode: 'raw',
            raw: JSON.stringify(body, null, 2),
          },
        }
      : {}),
  },
});

const c = {
  info: {
    name: 'SmartSpender CUD Auth Testing (Absolute Safe)',
    schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
  },
  item: [
    {
      name: '00 Setup',
      item: [
        mkReq('Register owner', 'POST', `${BASE}/api/auth/register`, { fullName: '{{ownerFullName}}', email: '{{ownerEmail}}', password: '{{ownerPassword}}' }),
        mkReq('Register other', 'POST', `${BASE}/api/auth/register`, { fullName: '{{otherFullName}}', email: '{{otherEmail}}', password: '{{otherPassword}}' }),
        mkReq('Login owner', 'POST', `${BASE}/api/auth/login`, { email: '{{ownerEmail}}', password: '{{ownerPassword}}' }),
        mkReq('Login other', 'POST', `${BASE}/api/auth/login`, { email: '{{otherEmail}}', password: '{{otherPassword}}' }),
      ],
    },
    {
      name: '01 Auth Tests',
      item: [
        mkReq('POST /api/auth/register', 'POST', `${BASE}/api/auth/register`, { fullName: 'Evidence Auth User', email: '{{authTestEmail}}', password: '{{authTestPassword}}' }),
        mkReq('POST /api/auth/login', 'POST', `${BASE}/api/auth/login`, { email: '{{authTestEmail}}', password: '{{authTestPassword}}' }),
      ],
    },
    {
      name: '02 POST transactions',
      item: [
        mkReq('Valid create', 'POST', `${BASE}/api/transactions`, { title: 'Evidence Create', amount: 90000, category: 'food', type: 'expense', note: 'created for update tests' }, 'ownerToken'),
        mkReq('Negative amount', 'POST', `${BASE}/api/transactions`, { title: 'Negative amount', amount: -1, category: 'food', type: 'expense' }, 'ownerToken'),
        mkReq('Missing required field', 'POST', `${BASE}/api/transactions`, { amount: 10, category: 'food', type: 'expense' }, 'ownerToken'),
        mkReq('Invalid category', 'POST', `${BASE}/api/transactions`, { title: 'Bad category', amount: 10, category: 'abcxyz', type: 'expense' }, 'ownerToken'),
        mkReq('Invalid date format', 'POST', `${BASE}/api/transactions`, { title: 'Bad date', amount: 10, category: 'food', type: 'expense', date: '03/19/2026' }, 'ownerToken'),
      ],
    },
    {
      name: '03 PUT transactions',
      item: [
        mkReq('Update success', 'PUT', `${BASE}/api/transactions/{{txUpdateId}}`, { title: 'Updated by owner', amount: 120000, category: 'food', type: 'expense' }, 'ownerToken'),
        mkReq('Partial update', 'PUT', `${BASE}/api/transactions/{{txUpdateId}}`, { title: 'Partial update title' }, 'ownerToken'),
        mkReq('Set amount 0', 'PUT', `${BASE}/api/transactions/{{txUpdateId}}`, { amount: 0 }, 'ownerToken'),
        mkReq('Empty payload', 'PUT', `${BASE}/api/transactions/{{txUpdateId}}`, {}, 'ownerToken'),
        mkReq('Invalid id format', 'PUT', `${BASE}/api/transactions/123`, { title: 'bad id' }, 'ownerToken'),
        mkReq('Non-owner update', 'PUT', `${BASE}/api/transactions/{{txUpdateId}}`, { amount: 777 }, 'otherToken'),
      ],
    },
    {
      name: '04 DELETE transactions',
      item: [
        mkReq('Delete success', 'DELETE', `${BASE}/api/transactions/{{txDeleteId}}`, undefined, 'ownerToken'),
        mkReq('Invalid id delete', 'DELETE', `${BASE}/api/transactions/not-valid-id`, undefined, 'ownerToken'),
        mkReq('Delete non-existent', 'DELETE', `${BASE}/api/transactions/{{nonExistentId}}`, undefined, 'ownerToken'),
        mkReq('Delete non-owner', 'DELETE', `${BASE}/api/transactions/{{txNonOwnerDeleteId}}`, undefined, 'otherToken'),
      ],
    },
    {
      name: '05 CRUD no token',
      item: [
        mkReq('POST no token', 'POST', `${BASE}/api/transactions`, { title: 'No token create', amount: 10, category: 'food', type: 'expense' }),
        mkReq('GET no token', 'GET', `${BASE}/api/transactions?month={{month}}&year={{year}}`),
        mkReq('PUT no token', 'PUT', `${BASE}/api/transactions/{{nonExistentId}}`, { title: 'No token update' }),
        mkReq('DELETE no token', 'DELETE', `${BASE}/api/transactions/{{nonExistentId}}`),
      ],
    },
    {
      name: '06 CRUD invalid token',
      item: [
        mkReq('POST invalid token', 'POST', `${BASE}/api/transactions`, { title: 'Invalid token create', amount: 10, category: 'food', type: 'expense' }, 'invalidToken'),
        mkReq('GET invalid token', 'GET', `${BASE}/api/transactions?month={{month}}&year={{year}}`, undefined, 'invalidToken'),
        mkReq('PUT invalid token', 'PUT', `${BASE}/api/transactions/{{nonExistentId}}`, { title: 'Invalid token update' }, 'invalidToken'),
        mkReq('DELETE invalid token', 'DELETE', `${BASE}/api/transactions/{{nonExistentId}}`, undefined, 'invalidToken'),
      ],
    },
    {
      name: '07 CRUD expired token',
      item: [
        mkReq('POST expired token', 'POST', `${BASE}/api/transactions`, { title: 'Expired token create', amount: 10, category: 'food', type: 'expense' }, 'expiredToken'),
        mkReq('GET expired token', 'GET', `${BASE}/api/transactions?month={{month}}&year={{year}}`, undefined, 'expiredToken'),
        mkReq('PUT expired token', 'PUT', `${BASE}/api/transactions/{{nonExistentId}}`, { title: 'Expired token update' }, 'expiredToken'),
        mkReq('DELETE expired token', 'DELETE', `${BASE}/api/transactions/{{nonExistentId}}`, undefined, 'expiredToken'),
      ],
    },
  ],
};

fs.writeFileSync(path.join(__dirname, 'cud-auth-testing.absolute-safe.postman_collection.json'), JSON.stringify(c, null, 2));
console.log('Absolute-safe collection generated');
