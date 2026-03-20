const XSS_PATTERN = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
const SQL_INJECTION_PATTERN = /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER|CREATE|EXEC|EXECUTE)\b)/gi;
const HTML_TAG_PATTERN = /<[^>]*>/g;

export function sanitizeString(input: string): string {
  if (!input) return '';
  return input
    .replace(HTML_TAG_PATTERN, '')
    .replace(XSS_PATTERN, '')
    .trim();
}

export function sanitizeNumeric(input: string | number): number {
  const num = typeof input === 'string' ? parseFloat(input.replace(/[^\d.-]/g, '')) : input;
  if (isNaN(num) || !isFinite(num)) return 0;
  return Math.round(num * 100) / 100;
}

export function containsSqlInjection(input: string): boolean {
  return SQL_INJECTION_PATTERN.test(input);
}

export function containsXss(input: string): boolean {
  return XSS_PATTERN.test(input) || HTML_TAG_PATTERN.test(input);
}

export function sanitizeObject<T extends Record<string, unknown>>(obj: T): T {
  const sanitized = { ...obj };
  for (const key of Object.keys(sanitized)) {
    const value = sanitized[key];
    if (typeof value === 'string') {
      (sanitized as Record<string, unknown>)[key] = sanitizeString(value);
    }
  }
  return sanitized;
}
