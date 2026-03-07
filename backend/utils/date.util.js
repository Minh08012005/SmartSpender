/**
 * Date utility functions
 */

/**
 * Parse YYYY-MM-DD string to Date object using UTC
 * @param {string} dateStr - Date string in YYYY-MM-DD format
 * @returns {Date|null} Parsed Date object or null if invalid
 */
function parseYYYYMMDD(dateStr) {
  const parts = dateStr.split("-").map(Number);
  if (parts.length !== 3) return null;
  const [y, m, d] = parts;
  const dt = new Date(Date.UTC(y, m - 1, d));
  if (
    dt.getUTCFullYear() !== y ||
    dt.getUTCMonth() !== m - 1 ||
    dt.getUTCDate() !== d
  )
    return null;
  return dt;
}

module.exports = { parseYYYYMMDD };