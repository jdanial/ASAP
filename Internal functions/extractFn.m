function returnFlag = extractFn(app,varargin)
% extractFn() - 
% extracts data saved by ASAP.
%
% Syntax - 
% extractFn(app).
%
% Parameters -
% - app: ASAP UI class
%
% Copyright -
% John S. H. Danial (2018). 
% danial@is.mpg.de

%% initializing returnFlag
returnFlag = false;

%% issuing initial error statements
if isempty(app.pr_fileList)
    returnFlag = true;
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 20: no ASAP files available.')];
    return;
end
switch app.pr_entryPoint
    case 'UI'
        if ~isempty(varargin)
            listBoxHandle = varargin{1};
            inputFiles = readListBoxAuxFn(listBoxHandle,app.pr_fileList);
            if isempty(inputFiles)
                returnFlag = true;
                app.MsgBox.Value = [app.MsgBox.Value ;...
                    sprintf('%s','ASAP error 21: no ASAP files selected.')];
                return;
            end
            
            %% initializing structuresData property
            app.pr_structuresData = struct();
        else
            inputFiles = retrieveFilesAuxFn(app.pr_inputPath,'.astr');
            if numel(inputFiles) ~= 1
                returnFlag = true;
                app.MsgBox.Value = [app.MsgBox.Value ;...
                    sprintf('%s','ASAP error 25: no single classification model (.astr) file is found.')];
                return;
            end
        end
    otherwise
        inputFiles = app.pr_fileList;
        if isempty(inputFiles)
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 20: no ASAP files available.')];
            return;
        end
        
        %% initializing structuresData property
        app.pr_structuresData = struct();
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: extraction started.')];
drawnow;

%% extracting number of files
numFiles = numel(inputFiles);

%% looping through files
for fileId = 1 : numFiles
    
    %% reading file name and folder
    if numFiles == 1
        fileName = inputFiles.name;
        fileFolder = inputFiles.folder;
    else
        fileName = inputFiles(fileId).name;
        fileFolder = inputFiles(fileId).folder;
    end
    filePath = fullfile(fileFolder,fileName);
    
    %% reading file extension
    [~,~,extension] = fileparts(fileName);
    
    %% setting up ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: extracting data from file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% replacing extension with .mat
    newFilePath = strrep(filePath,extension,'.mat');
    
    %% copying file
    copyfile(filePath,newFilePath);
    
    %% loading data
    try
        dataTemp = load(newFilePath);
    catch
        returnFlag = true;
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s',['ASAP error 22: cannot load data from (' fileName ').'])];
        return;
    end
    
    %% deleting copied file
    delete(newFilePath);
    
    %% assigning data array to app UI class pr_structuresData property
    if ~strcmp(extension,'.astr')
        app.pr_structuresData.file(fileId) = dataTemp.dataArray;
    else
        app.pr_trainingData = dataTemp.dataArray;
    end
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: extraction complete.')];
drawnow;
end