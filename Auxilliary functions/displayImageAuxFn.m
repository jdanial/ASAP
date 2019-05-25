function displayImageAuxFn(image)
% displayImageAuxFn - (Auxillary function)
% displays a super resolved image in a new figure.
%
% Syntax -
% displayImageAuxFn(image)
%
% Parameters -
% - image: 2D matrix of a super resolved image.

% calculating screen size
screenPixels = get(0,'screensize');

% setting new figure properties
fHandle = figure('Units','normalized','MenuBar','none','ToolBar','none','Resize','off');

% displaying image
imshow(image);

% setting position of image in figure
set(fHandle,'position',[0 0 0.75 * ((screenPixels(4) / screenPixels(3)) * (size(image,2) / size(image,1)))  0.75]);

% displaying the magnify text
text(size(image,2)/2,size(image,1) + 30 ,...
    'Left click to magnify (+ zoom in / - zoom out)',...
    'clipping','off','FontSize',11,'Color','red',...
    'HorizontalAlignment','center');

% moving figure to center of screen
movegui(fHandle,'center');

% calling magnifyFnExt
magnifyFnExt(fHandle);