function toggleButtonAuxFn(app,buttonHandle,fileId,structureId)
% toggleButtonAuxFn - (Auxillary function)
% toggles button with buttonHandle
%
% Syntax -
% toggleButtonAuxFn(app,buttonHandle,fileId,structureId)
%
% Parameters -
% - app: ASAP UI class
% - buttonHandle: handle to UI button
% - fileId: file Id
% - structureId: structure Id

if app.pr_structuresData.file(fileId).binned(round(structureId))
    buttonHandle.Value = 1;
    buttonHandle.Text = 'Unbin';
    buttonHandle.FontColor = [0 1 0];
else
    buttonHandle.Value = 0;
    buttonHandle.Text = 'Bin';
    buttonHandle.FontColor = [1 0 0];
end