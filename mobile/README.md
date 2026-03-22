# Mobile App

## Quick Start

```bash
flutter pub get
flutter run
```

## Remote Integration Testing (Option B)

Use this mode when backend is hosted on a shared staging server (team is remote,
not testing on local backend).

### 1) Run with shared API URL

```bash
flutter run --dart-define=APP_ENV=staging --dart-define=API_BASE_URL=https://your-staging-domain
```

### 2) Device-specific examples

Android emulator with local backend:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

iOS simulator with local backend:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

Real device with backend on teammate machine:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000
```

## Notes

- `API_BASE_URL` always has highest priority.
- If `API_BASE_URL` is not provided, app falls back to auto platform config.
- Do not include trailing slash in `API_BASE_URL`.
