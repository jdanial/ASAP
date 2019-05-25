function displayMatrixFnExt(matrix,varargin)
%DISPLAY_MATRIX   Display contents of a matrix for easy viewing
%   DISPLAY_MATRIX(matrix) display an on-screen matrix of an input matrix
%   for easy viewing. Additional parameters are allowed to enable column
%   and title headers and matrix titles.
%
%   DISPLAY_MATRIX(matrix,'rowheader',rowheader,'colheader',colheader,...)
%   displays row and column headers.
%
%   DISPLAY_MATRIX(matrix,'title',titletext,...) additionally displays a
%   single row at the top with the title of the matrix.
%
%   Written by Marshall Crumiller
%   email: mcrumiller@gmail.com
%--------------------------------------------------------------------------
% define colors
indigo  =         [0.2471 0.3176 0.7098];
white =           [1        1       1  ];
dark_indigo =     [0.1882 0.2431 0.6314];
header_gray =     [0.9176 0.9176 0.9176];
line_gray =       [0.8118 0.8118 0.8118];
divider_gray =    [0.9020 0.9020 0.9020];
background_gray = [0.9804 0.9804 0.9804];
title_gray =      [0.1294 0.1294 0.1294];
text_gray =       [0.4588 0.4588 0.4588];
text_darkgray =   [0.3804 0.3804 0.3804];
diagonal_gray=    [0.1294 0.1294 0.1294];

M=size(matrix);

% grab input arguments
rowheader=[]; colheader=[]; title_text=[];
while(~isempty(varargin))
    if(length(varargin)<2)
        error('Argument <strong>%s</strong> has invalid value argument.',varargin{1});
    end
    switch varargin{1}
        case 'rowheader', rowheader=varargin{2};
        case 'colheader', colheader=varargin{2};
        case 'title', title_text=varargin{2};
        case 'visibility', visibility = varargin{2};
        case 'export', export = varargin{2};
        case 'outfold', outFold = varargin{2};
    end
    varargin(1:2)=[];
end

% determine orientation of output paper
rows=M(1); cols=M(2);

% generate figure
screenPixels = get(0,'screensize');
fig = figure('Units','normalized','MenuBar',...
    'none','ToolBar','none','Resize',...
    'off','outerposition',[0 0 (screenPixels(4) / screenPixels(3)) * 0.5 0.5],'Visible',visibility);
movegui(fig,'center');

if(isempty(rowheader)), rowheader=1:cols; end
if(~ischar(rowheader)), rowheader=strtrim(cellstr(int2str(rowheader(:)))); end
if(isempty(colheader)), colheader=1:rows; end
if(~ischar(colheader)), colheader=strtrim(cellstr(int2str(colheader(:)))); end
if(isempty(title_text)),title_text=sprintf('Matrix: %s',inputname(1)); end
rowheader_p=.05;
marg=.01;

status_p=0; % status bar height
title_p=.06;  % title bar height
max_colheader_len=max(cellfun(@length,colheader));
colheader_p=min(.02+.01*max_colheader_len,.1);
row_p=(1-status_p-title_p)/rows; % row height
col_p=1/cols; % column height


axes('position',[0 0 1 1],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1],'color',background_gray); hold all;

% display title bar
ytop=1-status_p; ybot=1-status_p-title_p;
patch('XData',[-.1 -.1 1.1 1.1],'YData',[ybot ytop ytop ybot],'FaceAlpha',0);

% draw lines
%plot([0 1],[1 1]*1-status_p-title_p-rowheader_p,'linewidth',1,'color',line_gray);

% X=repmat([colheader_p+marg 1 nan],1,M(1)-1);
% y=linspace(0,(1-status_p-title_p-rowheader_p),M(1)+1); y([1 end])=[];
% Y=reshape([y;y;nan(1,M(1)-1)],1,[]);
% plot(X,Y,'linewidth',1,'color',divider_gray);

% print date on the top right of page
text(0.5,1-status_p-title_p/2,title_text,'horizontalalignment','center',...
    'verticalalignment','middle','fontunits','normalized','fontsize',title_p*.5,'color',title_gray,'fontweight','bold');

% convert to text
M2=matrix(:);
mat_string=reshape(arrayfun(@(x) strtrim(cellstr(sprintf('%2.2f',x))),M2),M);

X=linspace(colheader_p+marg,1,M(2)+1); X(end)=[];
X=X+(X(2)-X(1))/2;
Y=linspace(1-status_p-title_p-rowheader_p,0,M(1)+1); Y(end)=[];
Y=Y+(Y(2)-Y(1))/2;
colheader_X=colheader_p/2; rowheader_y=(1-status_p-title_p-rowheader_p/2);
header_size=min([row_p col_p colheader_p rowheader_p .4])*1;
% rows
for i = 1:M(1)
    y=Y(i);
    
    % colheader first
    text(colheader_X,y,colheader{i},'horizontalalignment','center','verticalalignment','middle',...
        'fontunits','normalized','fontsize',header_size,'color',text_darkgray,'fontweight','bold');
    
    for j = 1:M(2)
        x=X(j);
        if(i==1)
            text(x,rowheader_y,rowheader{j},'horizontalalignment','center','verticalalignment','middle',...
                'fontunits','normalized','fontsize',header_size,'color',text_darkgray,'fontweight','bold');
        end
        text(x,y,mat_string{i,j},'horizontalalignment','center','verticalalignment','middle','fontunits','normalized','fontsize',min(row_p,col_p)*.4,'color',diagonal_gray);
    end
end

% export
if strcmp(export,'yes')
    print(fig,[outFold '\' title_text],'-dpdf');
    close(fig);
end