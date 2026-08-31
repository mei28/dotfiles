export declare class DialogRequestLifecycle {
    private version;
    private active;
    private replacing;
    begin(): number;
    isCurrent(version: number): boolean;
    isOpen(): boolean;
    install(version: number, replace: (onClose: () => void) => void): boolean;
    cancel(): boolean;
    private dismiss;
}
//# sourceMappingURL=dialog-lifecycle.d.ts.map