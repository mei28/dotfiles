import stringWidth from "string-width";
const graphemeSegmenter = new Intl.Segmenter(undefined, { granularity: "grapheme" });
export function displayColumns(value) {
    return stringWidth(value);
}
export function takeColumns(value, maxColumns) {
    let used = 0;
    let output = "";
    for (const { segment } of graphemeSegmenter.segment(value)) {
        const width = stringWidth(segment);
        if (used + width > maxColumns)
            break;
        output += segment;
        used += width;
    }
    return output;
}
//# sourceMappingURL=display-width.js.map