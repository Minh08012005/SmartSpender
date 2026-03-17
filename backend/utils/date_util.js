/**
 * Utility functions for date parsing and validation.
 * Supports both ISO 8601 and YYYY-MM-DD formats.
 */

/**
 * Parse YYYY-MM-DD format to UTC Date object
 * @param {string} dateString - Date string in YYYY-MM-DD format
 * @returns {Date|null} Parsed UTC Date or null if invalid
 */
function parseYYYYMMDD(dateString) {
  if (typeof dateString !== 'string') {
    return null;
  }

  // Validate format: YYYY-MM-DD
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
    return null;
  }

  const [yearStr, monthStr, dayStr] = dateString.split('-');
  const year = parseInt(yearStr, 10);
  const month = parseInt(monthStr, 10);
  const day = parseInt(dayStr, 10);

  // Create UTC date (avoid timezone issues)
  const date = new Date(Date.UTC(year, month - 1, day));

  // Validate: check if parsed values match input values
  // This prevents invalid dates like 2026-02-30
  if (
    date.getUTCFullYear() !== year ||
    date.getUTCMonth() !== month - 1 ||
    date.getUTCDate() !== day
  ) {
    return null;
  }

  return date;
}

/**
 * Parse date string in ISO 8601 or YYYY-MM-DD format
 * @param {string} dateString - Date string to parse
 * @returns {Date|null} Parsed Date or null if invalid
 */
function parseDate(dateString) {
  if (typeof dateString !== 'string') {
    return null;
  }

  // Try YYYY-MM-DD format first
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateString)) {
    return parseYYYYMMDD(dateString);
  }

  // Try ISO 8601 format
  const parsed = new Date(dateString);
  if (!isNaN(parsed.getTime())) {
    return parsed;
  }

  return null;
}

/**
 * Check if string is a valid YYYY-MM-DD format
 * @param {string} dateString - Date string to check
 * @returns {boolean}
 */
function isYYYYMMDDFormat(dateString) {
  if (typeof dateString !== 'string') {
    return false;
  }
  return /^\d{4}-\d{2}-\d{2}$/.test(dateString);
}

module.exports = {
  parseYYYYMMDD,
  parseDate,
  isYYYYMMDDFormat,
};
