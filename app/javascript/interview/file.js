const LangExts = {
    "js": "javascript",
    "rb": "ruby",
    "py": "python"
}

function CodeFile(path, content = "", version = 0) {
    [this.name, this.ext] = path.split(".");
    this.path = path;
    this.lang = LangExts[this.ext];
    this.content = content;
    this.version = version;
}

const FileRegex = /.+\.\w+/

function CodeFileManagement(session) { // TODO: interview should has uniqueId
    this.session = session;
    this.filePaths = [];
}

CodeFileManagement.prototype.createCodeFile = function(filePath) {
    if (!FileRegex.test(filePath)) throw "Invalid file name";

    const newFile = new CodeFile(filePath);
    this.filePaths.push(filePath);
    this.currentFile = filePath;
    this.saveCodeFile(newFile);
    this.saveSession();
    return newFile;
}

CodeFileManagement.prototype.saveCodeFile = function(codeFile) {
    sessionStorage.setItem(codeFile.path, JSON.stringify({
        content: codeFile.content,
        version: codeFile.version
    }));
}

CodeFileManagement.prototype.loadCodeFile = function(filePath) {
    let cachedFile = JSON.parse(sessionStorage.getItem(filePath));
    if (cachedFile !== null) {
        this.currentFile = filePath;
        this.saveSession();
        return new CodeFile(filePath, cachedFile.content, cachedFile.version);
    }
}

CodeFileManagement.prototype.searchCodeFile = function(searchKey, limit = undefined) {
    try {
        let searchRegex = new RegExp(searchKey);
        return this.filePaths.filter(path => searchRegex.test(path)).slice(0, limit);
    } catch(error) {
        return [];
    }
}

CodeFileManagement.prototype.saveSession = function() {
    sessionStorage.setItem(this.session, JSON.stringify({
        paths: this.filePaths, 
        current: this.currentFile
    }));
}

CodeFileManagement.prototype.loadSession = function() {
    let session = JSON.parse(sessionStorage.getItem(this.session));
    if (!session) return;

    this.filePaths = session.paths;
    this.currentFile = session.current;
    return this.loadCodeFile(this.currentFile);
}

export {
    CodeFileManagement,
    CodeFile
}
