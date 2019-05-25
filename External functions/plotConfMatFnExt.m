function plotConfMatFnExt(varargin)
%PLOTCONFMAT plots the confusion matrix with colorscale, absolute numbers
%   and precision normalized percentages
%
%   usage: 
%   PLOTCONFMAT(confmat) plots the confmat with integers 1 to n as class labels
%   PLOTCONFMAT(confmat, labels) plots the confmat with the specified labels
%
%   Vahe Tshitoyan
%   20/08/2017
%
%   Arguments
%   confmat:            a square confusion matrix
%   labels (optional):  vector of class labels

% number of arguments
switch (nargin)
    case 0
       confmat = 1;
       labels = {'1'};
    case 1
       confmat = varargin{1};
       labels = 1:size(confmat, 1);
    case 3
       confmat = varargin{1};
       labels = varargin{2};
       mode = varargin{3};
    case 4
       confmat = varargin{1};
       labels = varargin{2};
       mode = varargin{3};
       filepath = varargin{4};
end

confmat(isnan(confmat))=0; % in case there are NaN elements
numlabels = size(confmat, 1); % number of labels

% calculate the percentage accuracies
confpercent = 100*confmat./repmat(sum(confmat, 1),numlabels,1);

% plotting the colors
screenPixels = get(0,'screensize');
switch mode
    case 'view'
        visibility = 'on';
    case 'export'
        visibility = 'off';
end
fig1 = figure('Units','normalized','MenuBar','none','ToolBar','none',...
    'Visible',visibility,'Resize',...
    'off','position',[0 0 0.5 * (screenPixels(4) / screenPixels(3)) 0.5]);
movegui(fig1,'center');
imagesc(confpercent);
title(sprintf('Accuracy: %.2f%%', 100*trace(confmat)/sum(confmat(:))));
%ylabel('Output Class'); xlabel('Target Class');

% set the colormap
colorMap = linspecerFnExt(100);
colormap(colorMap);

% Create strings from the matrix values and remove spaces
textStrings = num2str([confpercent(:), confmat(:)], '%.1f%%\n%d\n');
textStrings = strtrim(cellstr(textStrings));

% Create x and y coordinates for the strings and plot them
[x,y] = meshgrid(1:numlabels);
hStrings = text(x(:),y(:),textStrings(:), ...
    'HorizontalAlignment','center');

% Get the middle value of the color range
midValue = mean(get(gca,'CLim'));

% Choose white or black for the text color of the strings so
% they can be easily seen over the background color
textColors = repmat(confpercent(:) < midValue,1,3);
set(hStrings,{'Color'},num2cell(textColors,2));

% Setting the axis labels
set(gca,'XTick',1:numlabels,...
    'XTickLabel',labels,...
    'YTick',1:numlabels,...
    'YTickLabel',labels,...
    'TickLength',[0 0],...
    'LineWidth',1.2,...
    'FontSize',11,...
    'XColor',[0.25 0.25 0.25],...
    'YColor',[0.25 0.25 0.25],...
    'Units','normalized',...
    'FontUnits','normalized');
axis equal
axis square

% saving .png if mode is export
if strcmp(mode,'export')
    print(fig1, [filepath '.png'], '-dpng', '-opengl', '-r300');
    %print(fig1, [filepath '.pdf'], '-dpdf', '-painters');
    print(fig1, [filepath '.svg'], '-dsvg', '-painters');
end
end

