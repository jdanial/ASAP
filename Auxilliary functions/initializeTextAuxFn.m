function initializeTextAuxFn(app,textHandle,fileId,structureId)
% initializeTextAuxFn - (Auxillary function)
% initialize text area with descriptor information
%
% Syntax -
% initializeTextAuxFn(app,textHandle,fileId,structureId)
%
% Parameters -
% - app: ASAP UI class
% - textHandle: handle to text area
% - fileId: file Id
% - structureId: structure Id

%% obtaining number of descriptors
numDescriptors = numel(app.pr_structuresData.file(fileId).descriptors);

%% otaining descriptor values
for descriptorId = 1 : numDescriptors
    descriptor = app.pr_structuresData.file(fileId).descriptors{descriptorId};
    cellArrayText{descriptorId} = ...
        sprintf('%s%s%s\n',descriptor,' = ', ...
        num2str(app.pr_structuresData.file(fileId).dimensions{round(structureId)}.(descriptor(~isspace(descriptor)))));
end

%% initializing text area with cellArrayText
textHandle.Value = cellArrayText;