function CodeFile(path, content = "") {
    [this.name, this.ext] = path.split(".");
    this.path = path;
    this.content = content;
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
    localStorage.setItem(codeFile.path, codeFile.content);
}

CodeFileManagement.prototype.loadCodeFile = function(filePath) {
    let cachedFileContent = localStorage.getItem(filePath);
    console.log(cachedFileContent);
    if (cachedFileContent !== null) {
        this.currentFile = filePath;
        this.saveSession();
        return new CodeFile(filePath, cachedFileContent);
    }
}

CodeFileManagement.prototype.searchCodeFile = function(searchKey, limit) {
    try {
        let searchRegex = new RegExp(searchKey);
        return this.filePaths.filter(path => searchRegex.test(path)).slice(0, limit);
    } catch(error) {
        return [];
    }
}

CodeFileManagement.prototype.saveSession = function() {
    localStorage.setItem(this.session, JSON.stringify({
        paths: this.filePaths, 
        current: this.currentFile
    }));
}

CodeFileManagement.prototype.loadSession = function() {
    let session = JSON.parse(localStorage.getItem(this.session));
    console.log(session);
    if (!session) return;

    this.filePaths = session.paths;
    this.currentFile = session.current;
    return this.loadCodeFile(this.currentFile);
}

export {
    CodeFileManagement,
    CodeFile
}


