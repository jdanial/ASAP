function populateListBoxAuxFn(app)
% populateListBoxAuxFn - (Auxillary function)
% populates listboxes with relevent files
%
% Syntax -
% populateListBoxAuxFn(app,inputPath)
%
% Parameters -
% - app: ASAP UI class
% - inputPath: path selected by user containing images files and / or a
% .astr classification model file

%% retreiving files with relevent extensions
selectedTab = app.TabGroup.SelectedTab;

%% initializing fileList
fileListExists = true;

switch selectedTab.Title
    case 'Project'
        fileListNames = '';
        fileListExists = false;
    case 'Simulate'
        fileList = retrieveFilesAuxFn(app.pr_inputPath,{'.png','.jpg','.tif'});
        listBoxHandle = app.ListBox1_1;
    case 'Identify'
        fileList = retrieveFilesAuxFn(app.pr_inputPath,{'.png','.jpg','.tif'});
        listBoxHandle = app.ListBox2_1;
    case 'Analyze'
        fileList = retrieveFilesAuxFn(app.pr_inputPath,'.asid');
        listBoxHandle = app.ListBox3_1;
    case 'Train'
        fileList = retrieveFilesAuxFn(app.pr_inputPath,'.asan');
        listBoxHandle = app.ListBox4_1;
    case 'Classify'
        fileList = retrieveFilesAuxFn(app.pr_inputPath,'.asan');
        listBoxHandle = app.ListBox5_1;
    case 'Cluster'
        fileList = retrieveFilesAuxFn(app.pr_inputPath,'.ascl');
        listBoxHandle = app.ListBox6_1;
    case 'Plot'
        fileList = retrieveFilesAuxFn(app.pr_inputPath,'.ascl');
        listBoxHandle = app.ListBox7_1;
    case 'Montage'
        fileList = retrieveFilesAuxFn(app.pr_inputPath,'.ascl');
        listBoxHandle = app.ListBox8_1;
end

if fileListExists
    
    %% adding file names to listBox
    for fileId = 1 : length(fileList)
        fileListNames{fileId} = fileList(fileId).name;
    end
    listBoxHandle.Items = fileListNames;
    
    %% displaying warning message
    if isempty(fileListNames)
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s','ASAP warning 1: no files to display in list box.')];
        return;
    end
    
    %% assigning list to UI class property
    app.pr_fileList = fileList;
end