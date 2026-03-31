export function decodeHtmlEntities(input: string): string {
  return input
    .replace(/&#39;|&#x27;/g, "'")
    .replace(/&#038;|&amp;/g, "&")
    .replace(/&nbsp;/g, " ")
    .replace(/&quot;/g, '"')
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">");
}

export function sanitizeText(input: string): string {
  return decodeHtmlEntities(input)
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

export function toSlug(input: string): string {
  return sanitizeText(input)
    .normalize("NFD")
    .replace(/\p{Diacritic}+/gu, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

export function matchSingle(input: string, pattern: RegExp): string | undefined {
  const match = input.match(pattern);
  return match?.[1] ?? undefined;
}

export function absoluteUrl(input: string, baseUrl: string): string {
  if (!input) {
    return "";
  }

  return input.startsWith("http") ? input : new URL(input, baseUrl).toString();
}

export function optionalAbsoluteUrl(
  input: string | null | undefined,
  baseUrl: string,
): string | undefined {
  if (!input) {
    return undefined;
  }

  return input.startsWith("http") ? input : new URL(input, baseUrl).toString();
}
