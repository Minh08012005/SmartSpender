// k6 script
import http from 'k6/http';
import { check, sleep } from 'k6';

const TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OThkNDYyMTRjN2Y5YTI1ZjI4YjU5Y2MiLCJpYXQiOjE3NzA5ODEzOTIsImV4cCI6MTc3MTA2Nzc5Mn0.QiXALhXcUe2RERjPPkuD2sUKg-pIUjIsFI0o3V4H0j4";
export let options = {
  stages: [
    { duration: '30s', target: 50 }, // Ramp up lên 50 user
    { duration: '1m', target: 50 },  // Duy trì
    { duration: '10s', target: 0 },  // Ramp down
  ],
};

export default function () {
  const url = 'http://localhost:3000/api/transactions?month=2&year=2026';
  const params = {
    headers: {
      'Authorization': `Bearer ${TOKEN}`,
    },
  };

  let res = http.get(url, params);
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });
  sleep(1);
}