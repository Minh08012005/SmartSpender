/**
 * Lightweight logger wrapper.
 * - In production: only `error` is logged; `debug`/`info` are no-ops.
 * - In non-production: forwards to console.
 */
const isProd = process.env.NODE_ENV === 'production';

const logger = {
  debug: (...args) => {
    if (!isProd) console.debug(...args);
  },
  info: (...args) => {
    if (!isProd) console.info(...args);
  },
  error: (...args) => {
    console.error(...args);
  },
};

module.exports = logger;
