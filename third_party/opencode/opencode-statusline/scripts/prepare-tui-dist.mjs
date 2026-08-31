import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import babel from "@babel/core";
import typescriptPreset from "@babel/preset-typescript";
import solidPreset from "babel-preset-solid";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const sourcePath = path.join(root, "src", "tui.tsx");
const distJsPath = path.join(root, "dist", "tui.js");

const source = await fs.readFile(sourcePath, "utf8");
const transformed = await babel.transformAsync(source, {
  filename: sourcePath,
  configFile: false,
  babelrc: false,
  presets: [
    [solidPreset, { moduleName: "@opentui/solid", generate: "universal" }],
    [typescriptPreset]
  ]
});

if (!transformed?.code) {
  throw new Error("Babel transform returned empty output");
}

await fs.writeFile(distJsPath, `${transformed.code}\n`);
await fs.rm(path.join(root, "dist", "tui.tsx"), { force: true });
await fs.rm(path.join(root, "dist", "tui.jsx"), { force: true });
await fs.rm(path.join(root, "dist", "tui.jsx.map"), { force: true });
