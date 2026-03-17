// Ensure integration tests that sign/verify JWT use a stable secret in Jest.
if (!process.env.JWT_SECRET || !process.env.JWT_SECRET.trim()) {
  process.env.JWT_SECRET = 'test_secret_for_jest';
}
