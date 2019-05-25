function initializeSpinnerAuxFn(app,spinnerHandle,fileId)
% initializeSpinnerAuxFn - (Auxillary function)
% initializes spinner with spinnerHandle
%
% Syntax -
% initializeSpinnerAuxFn(app,spinnerHandle,fileId)
%
% Parameters -
% - app: ASAP UI class
% - spinnerHandle: handle to UI spinner
% - fileId: file Id

%% reading number of structures
numStructures = numel(app.pr_structuresData.file(fileId).identifiedStructures);

%% assigning value and limits to spinner
if numStructures > 0
    spinnerHandle.Limits = [1 numStructures + 0.0001];
    spinnerHandle.Value = 1;
else
    spinnerHandle.Limits = [0 0 + 0.0001];
    spinnerHandle.Value = 0;
end