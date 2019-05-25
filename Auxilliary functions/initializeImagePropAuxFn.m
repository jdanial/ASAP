function initializeImagePropAuxFn(app,mode,varargin)
% initializeGraphPropAuxFn - (Auxillary function)
% updates image properties panel and UI property
%
% Syntax -
% initializeGraphPropAuxFn(app)
%
% Parameters -
% - app: ASAP UI class

%% defining handles
listBoxHandle = {app.ListBox8_1,app.ListBox8_2};
checkBoxHandle = {app.CheckBox8_1,app.CheckBox8_2};
dropDownHandle = {app.DropDown8_1,app.DropDown8_2};
editFieldHandle = {app.EditField8_1,app.EditField8_2,app.EditField8_3,app.EditField8_4};
axesHandle = app.UIAxes8_1;
spinnerHandle = app.Spinner8_1;

switch mode
    case 'add'
        
        %% updating image number
        app.pr_montagingData.numImages = app.pr_montagingData.numImages + 1;
        
        %% updating listboxes
        listBoxHandle{2}.Items = string(1 : app.pr_montagingData.numImages);
        listBoxHandle{2}.Value = listBoxHandle{2}.Items{end};
        
        %% updating checkboxes
        checkBoxHandle{1}.Value = true;
        checkBoxHandle{2}.Value = true;
        
        %% updating dropdown menu - files
        dropDownHandle{1}.Items = listBoxHandle{1}.Value;
        dropDownHandle{1}.Value = dropDownHandle{1}.Items{1};
        
        %% updating dropdown menu - shapes
        dropDownHandle{2}.Items = unique(app.pr_structuresData.file(1).shapes);
        dropDownHandle{2}.Value = dropDownHandle{2}.Items{1};
        
        %% updating edit fields
        for handleId = 1 : numel(editFieldHandle)
            if handleId == 2
                editFieldHandle{handleId}.Value = 0;
            else
                editFieldHandle{handleId}.Value = '';
            end
        end
        
        %% updating spinner
        fileId = 1;
        if checkBoxHandle{2}.Value
            structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes));
        else
            structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes) &...
                ~app.pr_structuresData.file(fileId).binned);
        end
        spinnerHandle.Limits = [1 length(structureIds) + 0.0001];
        spinnerHandle.Value = 1;
        
        %% updating axis
        displayStructureAuxFn(app,axesHandle,fileId,structureIds(1));
        
        %% reading graphId
        imageId = str2double(listBoxHandle{2}.Value);
        
        %% writing structureIds
        app.pr_montagingData.image(imageId).structureIds = structureIds;
                
        %% writing updates
        initializeImagePropAuxFn(app,'write');
        
    case 'clear'
        
        %% initialing montaging data UI property
        app.pr_montagingData = struct();
        app.pr_montagingData.numImages = 0;
        
        %% updating listboxes
        listBoxHandle{2}.Items = {};
        
        %% updating checkboxes
        checkBoxHandle{1}.Value = false;
        checkBoxHandle{2}.Value = false;
        
        %% updating dropdown menus
        dropDownHandle{1}.Items = {};
        dropDownHandle{2}.Items = {};
        
        %% updating editfields
        for handleId = 1 : numel(editFieldHandle)
            if handleId == 2
                editFieldHandle{handleId}.Value = 0;
            else
                editFieldHandle{handleId}.Value = '';
            end
        end
        
    case 'update'
        
        %% reading subMode
        subMode = varargin{1};
        
        %% reading graphId
        imageId = str2double(listBoxHandle{2}.Value);
        
        switch subMode
            case 'listBoxChanged'
                
                %% updating montaging data UI property
                app.IEditField8_1.Value = app.pr_montagingData.imageSize;
                app.FEditField8_1.Value = app.pr_montagingData.fontSize;
                checkBoxHandle{1}.Value = app.pr_montagingData.image(imageId).include;
                checkBoxHandle{2}.Value = app.pr_montagingData.image(imageId).includeBinned;
                editFieldHandle{1}.Value = app.pr_montagingData.image(imageId).label;
                editFieldHandle{2}.Value = app.pr_montagingData.image(imageId).scale;
                editFieldHandle{3}.Value = app.pr_montagingData.image(imageId).rowNum;
                editFieldHandle{4}.Value = app.pr_montagingData.image(imageId).colNum;
                dropDownHandle{1}.Value = dropDownHandle{1}.Items{app.pr_montagingData.image(imageId).file};
                dropDownHandle{2}.Value = app.pr_montagingData.image(imageId).shapes;
                
                %% retrieving fileId and structureId
                fileId = find(strcmp(dropDownHandle{1}.Value,dropDownHandle{1}.Items));
                if checkBoxHandle{2}.Value
                    structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes));
                else
                    structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes) &...
                        ~app.pr_structuresData.file(fileId).binned);
                end
                spinnerHandle.Limits = [1 length(structureIds) + 0.0001];
                spinnerHandle.Value = app.pr_montagingData.image(imageId).structureId;
                structureId = spinnerHandle.Value;
                
                %% updating axis
                displayStructureAuxFn(app,axesHandle,fileId,structureIds(structureId));
                
            case 'dropDownChanged'
                
                %% updating spinner
                fileId = find(strcmp(dropDownHandle{1}.Value,dropDownHandle{1}.Items));
                if checkBoxHandle{2}.Value
                    structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes));
                else
                    structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes) &...
                        ~app.pr_structuresData.file(fileId).binned);
                end
                spinnerHandle.Limits = [1 length(structureIds) + 0.0001];
                spinnerHandle.Value = 1;
                
                %% updating axis
                displayStructureAuxFn(app,axesHandle,fileId,structureIds(1));
                
            case 'spinnerChanged'
                
                %% reading fileId and structureId
                fileId = find(strcmp(dropDownHandle{1}.Value,dropDownHandle{1}.Items));
                if checkBoxHandle{2}.Value
                    structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes));
                else
                    structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes) &...
                        ~app.pr_structuresData.file(fileId).binned);
                end
                structureId = spinnerHandle.Value;
                
                %% updating axis
                displayStructureAuxFn(app,axesHandle,fileId,structureIds(structureId));
        
            case 'checkBoxChanged'
                
                %% reading fileId
                fileId = find(strcmp(dropDownHandle{1}.Value,dropDownHandle{1}.Items));
                
                %% reading structureIds
                if checkBoxHandle{2}.Value
                    structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes));
                else
                    structureIds = find(strcmp(dropDownHandle{2}.Value,app.pr_structuresData.file(fileId).shapes) &...
                        ~app.pr_structuresData.file(fileId).binned);
                end
                spinnerHandle.Limits = [1 length(structureIds) + 0.0001];
                spinnerHandle.Value = 1;
                
                %% updating axis
                displayStructureAuxFn(app,axesHandle,fileId,structureIds(1));
                   
        end
        
        %% writing structureIds
        app.pr_montagingData.image(imageId).structureIds = structureIds;
        
        %% writing updates
        initializeImagePropAuxFn(app,'write');
        
    case 'write'
        
        %% reading graphId
        imageId = str2double(listBoxHandle{2}.Value);
        
        %% updating montaging data UI property
        app.pr_montagingData.imageSize = app.IEditField8_1.Value;
        app.pr_montagingData.fontSize = app.FEditField8_1.Value;
        app.pr_montagingData.image(imageId).include = checkBoxHandle{1}.Value;
        app.pr_montagingData.image(imageId).includeBinned = checkBoxHandle{2}.Value;
        app.pr_montagingData.image(imageId).label = editFieldHandle{1}.Value;
        app.pr_montagingData.image(imageId).scale = editFieldHandle{2}.Value;
        app.pr_montagingData.image(imageId).rowNum = editFieldHandle{3}.Value;
        app.pr_montagingData.image(imageId).colNum = editFieldHandle{4}.Value;
        app.pr_montagingData.image(imageId).file = find(strcmp(dropDownHandle{1}.Value,dropDownHandle{1}.Items));
        app.pr_montagingData.image(imageId).shapes = dropDownHandle{2}.Value;
        app.pr_montagingData.image(imageId).structureId = spinnerHandle.Value;
end
