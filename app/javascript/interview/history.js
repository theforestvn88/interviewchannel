export default class History {
  constructor() {
    this.codeVersions = [];
    this.currentVersion = -1;
  }

  push(code) {
    if (this.currentVersion == this.codeVersions.length - 1) {
      console.log("push code");
      this.currentVersion += 1;
      this.codeVersions.push(code);
    } else {
      this.rewriteVersion(this.currentVersion + 1, code);
    }
  }

  applyVersion(version) {
    if (version < 0) {
      this.currentVersion = 0;
    } else if (version >= this.codeVersions.length) {
      this.currentVersion = this.codeVersions.length - 1;
    } else {
      this.currentVersion = version;
    }

    return this.codeVersions[this.currentVersion];
  }

  rewriteVersion(version, code) {
    if (version > 0 && version < this.codeVersions.length) {
      console.log("rewrite");
      this.codeVersions = this.codeVersions.slice(0, version);
      this.currentVersion = version;
      this.push(code);
    }
  }

  forward() {
    return this.applyVersion(this.currentVersion + 1);
  }

  backward() {
    console.log("backward");
    return this.applyVersion(this.currentVersion - 1);
  }
}