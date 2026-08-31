export class DialogRequestLifecycle {
  private version = 0;
  private active = false;
  private replacing = false;

  begin(): number {
    this.active = true;
    return ++this.version;
  }

  isCurrent(version: number): boolean {
    return this.active && this.version === version;
  }

  isOpen(): boolean {
    return this.active;
  }

  install(version: number, replace: (onClose: () => void) => void): boolean {
    if (!this.isCurrent(version)) return false;
    this.replacing = true;
    try {
      replace(() => this.dismiss(version));
    } finally {
      this.replacing = false;
    }
    return this.isCurrent(version);
  }

  cancel(): boolean {
    if (!this.active) return false;
    this.active = false;
    this.version += 1;
    return true;
  }

  private dismiss(version: number): void {
    if (this.replacing || !this.isCurrent(version)) return;
    this.active = false;
    this.version += 1;
  }
}
