function returnFlag = trainFn(app)
% trainFn() -
% trains a user-chosen classifier to classify structures according to
% user-chosen parameters.
%
% Syntax -
% trainFn(app)
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
inputFiles = readListBoxAuxFn(app.ListBox4_1,app.pr_fileList);

%% extracting number of files
numFiles = numel(inputFiles);

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: training started.')];
drawnow;

%% reading module parameters
classificationAlgorithm = app.DropDown4_2.Value;
shapeDescriptors = app.ListBox4_3.Value;

%% checking no shapeDescriptors have been selected
if isempty(shapeDescriptors)
    returnFlag = true;
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 23: no shape descriptors selected.')];
    return;
end

%% initializing structureClass and structureProps
structureClass = {};
structureProps = [];

%% global structureId
globalStructureId = 1;

%% looping through files
for fileId = 1 : numFiles
    
    %% reading number of structures
    numStructures = numel(app.pr_structuresData.file(fileId).identifiedStructures);
    
    %% assigning export options
    exportImages = app.ExportImagesMenu.Checked;
    if exportImages
        app.pr_options.file(fileId).exportImages = 'true';
    else
        app.pr_options.file(fileId).exportImages = 'false';
    end
    
    %% looping through structures
    for structureId = 1 : numStructures
        try
            
            %% reading structure shape (if assigned)
            structureClass{globalStructureId} = app.pr_structuresData.file(fileId).shapes{structureId};
            
            %% querying for selected shape descriptors
            for shapeDescriptorId = 1 : numel(shapeDescriptors)
                descriptor = shapeDescriptors{shapeDescriptorId};
                descriptorValue = app.pr_structuresData.file(fileId).dimensions{structureId}.(descriptor(~isspace(descriptor)));
                if shapeDescriptorId ~= 1
                    startIndex = endIndex + 1;
                    endIndex = startIndex + length(descriptorValue) - 1;
                else
                    startIndex = 1;
                    endIndex = startIndex + length(descriptorValue) - 1;
                end
                structureProps(globalStructureId,startIndex : endIndex) = descriptorValue;
            end
            
            %% incrementing globalstructureId
            globalStructureId = globalStructureId + 1;
        catch
            
            %% empty
        end
    end
end

%% checking if no structures have been classified
if isempty(structureClass)
    returnFlag = true;
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 24: no structures classified.')];
    return;
end

%% training classifier
classificationModel = fitcecoc(structureProps,...
    structureClass,'Learners',classificationAlgorithm);
crossValidatedClassificationModel = crossval(classificationModel);
outShapeClassifications = kfoldPredict(crossValidatedClassificationModel);

%% producing confusion matrix
[confusionMatrix,shapeNamesOrder] = confusionmat(structureClass,outShapeClassifications);
plotConfMatFnExt(confusionMatrix,shapeNamesOrder,'view');

%% transferring classification data to UI class property
app.pr_trainingData.model = classificationModel;
app.pr_trainingData.descriptors = shapeDescriptors;
app.pr_trainingData.shapes = unique(structureClass);
app.pr_trainingData.confusionMatrix = confusionMatrix;
app.pr_trainingData.shapeNamesOrder = shapeNamesOrder;

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: training complete.')];
drawnow;
end