function returnFlag = classifyFn(app)
% classifyFn() -
% classifies structures according to trained classification model.
%
% Syntax -
% classifyFn(app)
%
% Parameters -
% - app: ASAP UI class
%
% Copyright -
% John S. H. Danial (2018).
% danial@is.mpg.de

%% initializing returnFlag
returnFlag = false;

%% reading file list
switch app.pr_entryPoint
    case 'UI'
        listBoxHandle = app.ListBox5_1;
        inputFiles = readListBoxAuxFn(listBoxHandle,app.pr_fileList);
    otherwise
        inputFiles = app.pr_fileList;
end

%% extracting number of files
numFiles = numel(inputFiles);

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: classification started.')];
drawnow;

%% extracting shape descriptors
shapeDescriptors = app.pr_trainingData.descriptors;
numShapeDescriptors = numel(shapeDescriptors);

%% extracting classification model
classificationModel = app.pr_trainingData.model;

%% initializing imageId
imageId = 1;

for fileId = 1 : numFiles
    structureProps = [];
    
    %% reading module parameters
    switch app.pr_entryPoint
        case 'UI'
            assignmentData = app.pr_assignmentData;
            exportRawData = app.ExportRawDataMenu.Checked;
            if exportRawData
                app.pr_options.file(fileId).exportRawData = 'true';
            else
                app.pr_options.file(fileId).exportRawData = 'false';
            end
        otherwise
            for assignmentId = 1 : app.pr_classificationParam.file(fileId).assignmentNum
                assignmentData(assignmentId).assign = true;
                assignmentData(assignmentId).shapeBefore = app.pr_classificationParam.file(fileId).assignment(assignmentId).shapeBefore;
                assignmentData(assignmentId).shapeAfter = app.pr_classificationParam.file(fileId).assignment(assignmentId).shapeAfter{1};
                assignmentData(assignmentId).descriptor = app.pr_classificationParam.file(fileId).assignment(assignmentId).descriptor{1};
                assignmentData(assignmentId).includeSecondBound = strcmp(app.pr_classificationParam.file(fileId).assignment(assignmentId).includeSecondBound{1},'true');
                assignmentData(assignmentId).firstBound = app.pr_classificationParam.file(fileId).assignment(assignmentId).firstBound;
                assignmentData(assignmentId).secondBound = app.pr_classificationParam.file(fileId).assignment(assignmentId).secondBound;
                assignmentData(assignmentId).firstEquality = app.pr_classificationParam.file(fileId).assignment(assignmentId).firstEquality{1};
                assignmentData(assignmentId).secondEquality = app.pr_classificationParam.file(fileId).assignment(assignmentId).secondEquality{1};
            end
    end
    
    %% setting up ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: classifying structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% extracting numStructures
    numStructures = numel(app.pr_structuresData.file(fileId).identifiedStructures);
    
    %% querying for selected shape descriptors
    if numStructures > 0
        for structureId = 1 : numStructures
            for shapeDescriptorId = 1 : numShapeDescriptors
                descriptor = shapeDescriptors{shapeDescriptorId};
                descriptorValue = app.pr_structuresData.file(fileId).dimensions{structureId}.(descriptor(~isspace(descriptor)));
                if shapeDescriptorId ~= 1
                    startIndex = endIndex + 1;
                    endIndex = startIndex + length(descriptorValue) - 1;
                else
                    startIndex = 1;
                    endIndex = startIndex + length(descriptorValue) - 1;
                end
                structureProps(structureId,startIndex : endIndex) = descriptorValue;
            end
        end
        
        %% classifying shapes according to classification model
        shapes = predict(classificationModel,structureProps);
        
        %% performing re-assignment
        shapes = StructureAssigner(app,assignmentData,shapes,fileId);
        
        %% assigning shapes to UI property
        app.pr_structuresData.file(imageId).shapes = shapes;
        app.pr_structuresData.file(imageId).clusteringData = struct();
        app.pr_structuresData.file(imageId).Function = 'Classified';

        imageId = imageId + 1;
    end
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: classification complete.')];
drawnow;
end

%%====================StructureAssigner=====================%%
function shapes = StructureAssigner(app,assignmentData,shapes,fileId)
try
    for assignmentId = 1 : length(assignmentData)
        if assignmentData(assignmentId).assign
            numStructures = numel(app.pr_structuresData.file(fileId).identifiedStructures);
            for structureId = 1 : numStructures
                descriptor = assignmentData(assignmentId).descriptor;
                noSpaceDescriptor = descriptor(~isspace(descriptor));
                descriptorValue = app.pr_structuresData.file(fileId).dimensions{structureId}.(noSpaceDescriptor);
                if ismember(shapes{structureId},assignmentData(assignmentId).shapeBefore)
                    switch assignmentData(assignmentId).firstEquality
                        case '>'
                            if assignmentData(assignmentId).includeSecondBound
                                switch assignmentData(assignmentId).secondEquality
                                    case '<'
                                        if assignmentData(assignmentId).firstBound < assignmentData(assignmentId).secondBound
                                            if descriptorValue > assignmentData(assignmentId).firstBound && descriptorValue < assignmentData(assignmentId).secondBound
                                                if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                                    app.pr_structuresData.file(fileId).binned(structureId) = true;
                                                else
                                                    shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                                end
                                            end
                                        elseif assignmentData(assignmentId).firstBound > assignmentData(assignmentId).secondBound
                                            if descriptorValue > assignmentData(assignmentId).firstBound || descriptorValue < assignmentData(assignmentId).secondBound
                                                if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                                    app.pr_structuresData.file(fileId).binned(structureId) = true;
                                                else
                                                    shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                                end
                                            end
                                        end
                                    case '='
                                        if assignmentData(assignmentId).firstBound == assignmentData(assignmentId).secondBound
                                            if descriptorValue > assignmentData(assignmentId).firstBound || descriptorValue == assignmentData(assignmentId).secondBound
                                                if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                                    app.pr_structuresData.file(fileId).binned(structureId) = true;
                                                else
                                                    shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                                end
                                            end
                                        end
                                end
                            else
                                if descriptorValue > assignmentData(assignmentId).firstBound
                                    if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                        app.pr_structuresData.file(fileId).binned(structureId) = true;
                                    else
                                        shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                    end
                                end
                            end
                        case '<'
                            if assignmentData(assignmentId).includeSecondBound
                                switch assignmentData(assignmentId).secondEquality
                                    case '>'
                                        if assignmentData(assignmentId).firstBound > assignmentData(assignmentId).secondBound
                                            if descriptorValue < assignmentData(assignmentId).firstBound && descriptorValue > assignmentData(assignmentId).secondBound
                                                if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                                    app.pr_structuresData.file(fileId).binned(structureId) = true;
                                                else
                                                    shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                                end
                                            end
                                        elseif assignmentData(assignmentId).firstBound < assignmentData(assignmentId).secondBound
                                            if descriptorValue < assignmentData(assignmentId).firstBound || descriptorValue > assignmentData(assignmentId).secondBound
                                                if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                                    app.pr_structuresData.file(fileId).binned(structureId) = true;
                                                else
                                                    shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                                end
                                            end
                                        end
                                    case '='
                                        if assignmentData(assignmentId).firstBound == assignmentData(assignmentId).secondBound
                                            if descriptorValue < assignmentData(assignmentId).firstBound || descriptorValue == assignmentData(assignmentId).secondBound
                                                if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                                    app.pr_structuresData.file(fileId).binned(structureId) = true;
                                                else
                                                    shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                                end
                                            end
                                        end
                                end
                            else
                                if descriptorValue < assignmentData(assignmentId).firstBound
                                    if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                        app.pr_structuresData.file(fileId).binned(structureId) = true;
                                    else
                                        shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                    end
                                end
                            end
                        case '='
                            if assignmentData(assignmentId).includeSecondBound
                                switch assignmentData(assignmentId).secondEquality
                                    case '>'
                                        if assignmentData(assignmentId).firstBound == assignmentData(assignmentId).secondBound
                                            if descriptorValue > assignmentData(assignmentId).firstBound || descriptorValue == assignmentData(assignmentId).secondBound
                                                if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                                    app.pr_structuresData.file(fileId).binned(structureId) = true;
                                                else
                                                    shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                                end
                                            end
                                        end
                                    case '<'
                                        if assignmentData(assignmentId).firstBound == assignmentData(assignmentId).secondBound
                                            if descriptorValue < assignmentData(assignmentId).firstBound || descriptorValue == assignmentData(assignmentId).secondBound
                                                if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                                    app.pr_structuresData.file(fileId).binned(structureId) = true;
                                                else
                                                    shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                                end
                                            end
                                        end
                                end
                            else
                                if descriptorValue == assignmentData(assignmentId).firstBound
                                    if strcmp(assignmentData(assignmentId).shapeAfter,'Bin')
                                        app.pr_structuresData.file(fileId).binned(structureId) = true;
                                    else
                                        shapes{structureId} = assignmentData(assignmentId).shapeAfter;
                                    end
                                end
                            end
                    end
                end
            end
        end
    end
catch
end
end
