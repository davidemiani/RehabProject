function fileList = requiredFiles2cell(file)
    fileList = matlab.codetools.requiredFilesAndProducts(file)';
end