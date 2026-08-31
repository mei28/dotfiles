import { resolveActiveModel } from "./opencode-client.js";
import { isRecord, toNonEmptyString } from "./format.js";
import { collectProviderUsage } from "./providers.js";
import { formatUsageReport } from "./usage-format.js";
export async function buildTuiUsageText(api, sessionID) {
    const config = isRecord(api.state.config) ? api.state.config : {};
    const client = {
        session: {
            get: async () => api.state.session.get(sessionID),
            messages: async () => api.state.session.messages(sessionID)
        }
    };
    const model = await resolveActiveModel({
        client,
        sessionID,
        config,
        providers: api.state.provider,
        stateDir: api.state.path?.state
    });
    if (!model)
        return formatUsageReport(undefined);
    const providerInfo = api.state.provider.find((provider) => provider.id === model.providerID);
    const report = await collectProviderUsage({
        providerID: model.providerID,
        providerName: toNonEmptyString(providerInfo?.name),
        modelID: model.modelID,
        config,
        providerInfo,
        force: true
    });
    return formatUsageReport(report);
}
//# sourceMappingURL=tui-usage.js.map