import stringWidth from "string-width";

const graphemeSegmenter = new Intl.Segmenter(undefined, { granularity: "grapheme" });

export function displayColumns(value: string): number {
  return stringWidth(value);
}

export function takeColumns(value: string, maxColumns: number): string {
  let used = 0;
  let output = "";
  for (const { segment } of graphemeSegmenter.segment(value)) {
    const width = stringWidth(segment);
    if (used + width > maxColumns) break;
    output += segment;
    used += width;
  }
  return output;
}
