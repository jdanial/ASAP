function displayStructureAuxFn(app,axesHandle,fileId,structureId)
% displaStructureAuxFn - (Auxillary function)
% displays structure in axes given by axesHandle
%
% Syntax -
% displaStructureAuxFn(app,axesHandle,fileId,structureId)
%
% Parameters -
% - app: ASAP UI class
% - axesHandle: handles to UI axes
% - fileId: file Id
% - structureId: structure Id

%% assigning raw and binary images
rawImage = app.pr_structuresData.file(fileId).identifiedStructures(round(structureId)).rawStructure;
if numel(axesHandle) > 1
    binaryImage = app.pr_structuresData.file(fileId).identifiedStructures(round(structureId)).binaryStructure;
end

%% setting color maps
try
    colormap(axesHandle{1},hot(255));
    colormap(axesHandle{2},gray(2));
catch
    colormap(axesHandle,hot(255));
end

%% displaying images
try
    imagesc(axesHandle{1},rawImage);
    image(axesHandle{2},binaryImage);
catch
    imagesc(axesHandle,rawImage);
end

%% setting axes to equal
try
    axis(axesHandle{1},'equal');
    axis(axesHandle{2},'equal');
catch
    axis(axesHandle,'equal');
end

%% intiating effects on UI
drawnow;