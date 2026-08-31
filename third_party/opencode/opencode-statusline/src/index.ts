import { StatuslinePlugin } from "./plugin.js";

type V1PluginModule = {
  id: string;
  server: typeof StatuslinePlugin;
};

const pluginModule = {
  id: "opencode-statusline",
  server: StatuslinePlugin
} satisfies V1PluginModule;

export default pluginModule;
export { StatuslinePlugin } from "./plugin.js";
export type { StatuslineFieldID, StatuslineConfig } from "./lib/statusline-config.js";

