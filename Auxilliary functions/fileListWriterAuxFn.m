function fileListWriterAuxFn(app)
% assignmentFillerAuxFn - (Auxillary function)
% write a list of identified files with corresponding IDs on disk
%
% Syntax -
% fileListWriter(app)
%
% Parameters -
% - app: ASAP UI class

%% identifying text file name and path
textFileName = 'File_list.txt';
textFilePath = app.pr_exportPath;
textFullFile = fullfile(textFilePath,textFileName);

%% obtaining handle to text file
try
    textFileHandle = fopen(textFullFile,'w');
catch
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 0: cannot write file list to disk.')];
    return;
end

%% writing file ids and names to text file
for fileId = 1 : length(app.pr_fileList)
    fprintf(textFileHandle,'%d %s\n',fileId,app.pr_fileList(fileId).name);
end

%% closing file
fclose(textFileHandle);

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: file list generated. Check (File_list.txt) in project folder.')];
