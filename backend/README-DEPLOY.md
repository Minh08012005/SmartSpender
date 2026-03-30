# Deploy Backend (Render / General)

This file contains step-by-step actions to make the backend reachable from the public frontend and to ensure CORS / env configuration is correct.

1. Verify code changes are committed
   - Ensure `backend/app.js` and `backend/server.js` changes are pushed to the repo.

2. Set environment variables on your host (Render / Railway / Heroku / DO)
   - Required:
     - `MONGO_URI` — production MongoDB connection string
     - `JWT_SECRET` — secure secret for JWT
   - Recommended for CORS:
     - `CORS_ALLOWED_ORIGINS` — comma-separated list of allowed frontend origins (example: `https://smartspender-x1fl.onrender.com,https://<username>.github.io`)
     - Or for quick debugging only: `CORS_ALLOW_ALL=true` then redeploy, test, and set it back to `false`

3. Redeploy backend on your host
   - On Render: open your service → Manual Deploy → Deploy Latest Commit (or enable automatic deploy from main branch)
   - On Railway/Heroku: push commit or trigger deploy in UI

4. Health check
   - After deployment, run:

     ```bash
       curl -v https://smartspender-x1fl.onrender.com/health
     ```

     Expected: HTTP 200 JSON with `success: true`.

   - Note for uptime monitors: configure them to check the `/health` path (e.g. `https://smartspender-x1fl.onrender.com/health`) instead of root `/` to avoid 404 if root is not intended to be monitored.

5. Update frontend build config
   - If using GitHub Actions workflow (`.github/workflows/pages-deploy.yml`), set `Settings → Secrets → Actions → API_BASE_URL` to your backend URL (e.g. `https://smartspender-x1fl.onrender.com`). The workflow includes a fallback to the Render URL for convenience.

6. Redeploy frontend
   - Trigger the build (push to `main`) or re-run the GitHub Actions job.

7. Verify end-to-end
   - Open frontend and open DevTools → Network tab. Reload and observe API requests. If you still see CORS errors, repeat step 2 to add the frontend origin to `CORS_ALLOWED_ORIGINS`.

Notes:

- Do NOT leave `CORS_ALLOW_ALL=true` in production long-term. Use it only for temporary debugging.
- Keep secrets out of commit history.
