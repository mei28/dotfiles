export class DialogRequestLifecycle {
    version = 0;
    active = false;
    replacing = false;
    begin() {
        this.active = true;
        return ++this.version;
    }
    isCurrent(version) {
        return this.active && this.version === version;
    }
    isOpen() {
        return this.active;
    }
    install(version, replace) {
        if (!this.isCurrent(version))
            return false;
        this.replacing = true;
        try {
            replace(() => this.dismiss(version));
        }
        finally {
            this.replacing = false;
        }
        return this.isCurrent(version);
    }
    cancel() {
        if (!this.active)
            return false;
        this.active = false;
        this.version += 1;
        return true;
    }
    dismiss(version) {
        if (this.replacing || !this.isCurrent(version))
            return;
        this.active = false;
        this.version += 1;
    }
}
//# sourceMappingURL=dialog-lifecycle.js.map