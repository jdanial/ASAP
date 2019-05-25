function inputFiles = readListBoxAuxFn(listBoxHandle,fileList)
% readListBoxAuxFn() - 
% reads selected files from a listbox.
%
% Syntax - 
% readListBoxAuxFn(listBoxHandle,fileList).
%
% Parameters - 
% - listBoxHandle:handle to listbox.
% - fileList: list of files in listbox.
%
% Copyright -
% John S. H. Danial (2018). 
% danial@is.mpg.de

%% initializing inputFiles
inputFiles = struct();

%% reading selected files
selectedFiles = listBoxHandle.Value;
if isempty(selectedFiles)
    inputFiles = '';
    return;
else
    
    %% checking number of files
    if ~iscell(selectedFiles)
        selectedFiles = {selectedFiles};
    end
    if numel(selectedFiles) == 1
        inputFiles = fileList(strcmp(selectedFiles,listBoxHandle.Items));
    else
        for fileId = 1 : numel(selectedFiles)
            inputFiles(fileId).name = fileList(strcmp(selectedFiles{fileId},listBoxHandle.Items)).name;
            inputFiles(fileId).folder = fileList(strcmp(selectedFiles{fileId},listBoxHandle.Items)).folder;
        end
    end
end