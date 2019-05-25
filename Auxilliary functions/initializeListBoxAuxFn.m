function initializeListBoxAuxFn(app,listBoxHandle,fileId,structureId)
% initializeListBoxAuxFn - (Auxillary function)
% initializes the shape selection list box
%
% Syntax -
% initializeListBoxAuxFn(app,listBoxHandle,fileId,structureId)
%
% Parameters -
% - app: ASAP UI class
% - listBoxHandle: handle to UI list box
% - fileId: file Id
% - structureId: structure Id

try
    listBoxHandle.Value = app.pr_structuresData.file(fileId).shapes{structureId};
catch
    app.pr_structuresData.file(fileId).shapes{structureId} = listBoxHandle.Value;
end