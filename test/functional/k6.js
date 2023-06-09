import http from 'k6/http';
import { check, group } from 'k6';

export let options = {
  vus: 1,
  thresholds: {
    // the rate of successful checks should be 100%
    checks: ['rate>=1'],
  },
};

export default function() {
  group('GET /keys', () => {
    const response = http.get(`http://${__ENV.GOKV_URL}/keys`);
    check(response, {
      "status code should be 200": res => res.status === 200,
    });
  });

}
