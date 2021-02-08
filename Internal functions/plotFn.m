function returnFlag = plotFn(app)
% plotFn() -
% plots all data generated from ASAP in a publication-ready layout.
%
% Syntax -
% plotFn(app)
%
% Parameters -
% - app: ASAP UI class
%
% Copyright -
% John S. H. Danial (2018)
% danial@is.mpg.de

%% initializing returnFlag
returnFlag = false;

%% reading module parameters
switch app.pr_entryPoint
    case 'UI'
        plottingData = app.pr_plottingData;
    otherwise
        plottingData = app.pr_plottingParam;
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: plotting started.')];
drawnow;

%% initialization
clear g;
xData = cell(10);
yData = cell(10);
zData = cell(10);
splits = cell(10);
flips = cell(10);
addBoxes = cell(10);
addLegends = cell(10);
normalizations  = cell(10);
maps = {};
fills = {};
fits = {};
equations = {};
rowNums = [];
colNums = [];
binNums = [];
xLines = [];
yLines = [];
xDescriptors = {};
yDescriptors = {};

%% reading numGraphs
numGraphs = plottingData.numGraphs;

%% looping through graphs
for graphId = 1 : numGraphs
    switch app.pr_entryPoint
        case 'Script'
            plottingData.graph(graphId).include = true;
    end
    
    if plottingData.graph(graphId).include
        
        %% subinitalization
        xDataTemp = [];
        yDataTemp = [];
        zDataTemp = {};
        structureCount = 1;
        
        %% reading module parameters
        xDescriptor = plottingData.graph(graphId).xDescriptor;
        yDescriptor = plottingData.graph(graphId).yDescriptor;
        includeBinned = plottingData.graph(graphId).includeBinned;
        addLegend = plottingData.graph(graphId).addLegend;
        addBox = plottingData.graph(graphId).addBox;
        normalize = plottingData.graph(graphId).normalize;
        split = plottingData.graph(graphId).split;
        flip = plottingData.graph(graphId).flip;
        shapes = plottingData.graph(graphId).shapes;
        map = plottingData.graph(graphId).map;
        fill = plottingData.graph(graphId).fill;
        fit = plottingData.graph(graphId).fit;
        label = plottingData.graph(graphId).label;
        equation = plottingData.graph(graphId).equation;
        xLine = plottingData.graph(graphId).xLine;
        yLine = plottingData.graph(graphId).yLine;
        binNum = plottingData.graph(graphId).binNum;
        files = plottingData.graph(graphId).files;
        switch app.pr_entryPoint
            case 'UI'
                rowNum = plottingData.graph(graphId).rowNum;
                colNum = plottingData.graph(graphId).colNum;
        end
        
        %% reconfiguring module parameters
        xDescriptor = xDescriptor(~isspace(xDescriptor));
        yDescriptor = yDescriptor(~isspace(yDescriptor));
        label = {label};
        equation = {equation};
        if strcmp(app.pr_entryPoint,'UI')
            if isnan(xLine)
                xLine = 0;
            end
            if isnan(yLine)
                yLine = 0;
            end
            if isnan(binNum)
                binNum = 0;
            end
            if isnan(rowNum)
                returnFlag = true;
                app.MsgBox.Value = [app.MsgBox.Value ;...
                    sprintf('%s',['ASAP error 27: row number is empty in graph ' num2str(graphId) '.'])];
                return;
            end
            if isnan(colNum)
                returnFlag = true;
                app.MsgBox.Value = [app.MsgBox.Value ;...
                    sprintf('%s',['ASAP error 28: column number is empty in graph ' num2str(graphId) '.'])];
                return;
            end
        else
            includeBinned = strcmp(includeBinned,'true');
            addLegend = strcmp(addLegend,'true');
            addBox = strcmp(addBox,'true');
            normalize = strcmp(normalize,'true');
            split = strcmp(split,'true');
            flip = strcmp(flip,'true');
            if isempty(xLine)
                xLine = 0;
            end
            if isempty(yLine)
                yLine = 0;
            end
            if isempty(binNum)
                binNum = 0;
            end
            try
                rowNum = plottingData.graph(graphId).rowId;
                colNum = plottingData.graph(graphId).colId;
            catch
                if rowNum == 0
                    colNum = floor(graphId / sqrt(numGraphs)) + 1;
                    rowNum = mod(graphId,floor(numGraphs));
                else
                    colNum = floor((graphId - 1) / rowNum) + 1;
                    if mod(graphId,rowNum) ~= 0
                        rowNum = mod(graphId,rowNum);
                    end
                end
                plottingData.graph(graphId).rowNum = rowNum;
                plottingData.graph(graphId).colNum = colNum;
            end
        end
        
        %% extracting file id
        for fileId = 1 : numel(files)
            
            %% reading structuresData UI property for cooresponding file
            structuresData = app.pr_structuresData.file(files(fileId));
            
            %% reading number of structures
            numStructures = numel(structuresData.identifiedStructures);
            
            %% looping through structures
            for structureId  = 1 : numStructures
                
                %% checking if belongs to shapes
                if ismember(shapes,structuresData.shapes{structureId})
                    
                    %% checking state of includeBinned and if corresponding structure is binned
                    binned = structuresData.binned(structureId);
                    if (includeBinned && binned) || (includeBinned && ~binned) || (~includeBinned && ~binned)
                        
                        if strcmp(xDescriptor,'Distance')
                            %% assigning data to x, y and z DataTemp
                            newyDataTemp = structuresData.dimensions{structureId}.(yDescriptor);
                            yDataTemp = [yDataTemp newyDataTemp];
                            newxDataTemp = (structuresData.pixelSize - (structuresData.pixelSize / 2)):...
                                structuresData.pixelSize :...
                                (structuresData.pixelSize * length(newyDataTemp) -...
                                (structuresData.pixelSize / 2));
                            xDataTemp = [xDataTemp newxDataTemp];
                            newzDataTemp = repmat(strcat(label,', ',shapes),1,length(newxDataTemp));
                            zDataTemp = [zDataTemp newzDataTemp];
                            
                        elseif strcmp(yDescriptor,'Count')
                            xDataTemp = label;
                            yDataTemp = structureCount;
                            zDataTemp = strcat(label,', ',shapes);
                            structureCount = structureCount + 1;
                        else
                            if strcmp(xDescriptor,'Label') && ~strcmp(yDescriptor,'Events')
                                newXDataTemp = label;
                                newYDataTemp = structuresData.dimensions{structureId}.(yDescriptor);
                                choiceFlag = 1;
                            elseif ~strcmp(xDescriptor,'Label') && ~strcmp(yDescriptor,'Events')
                                newXDataTemp = structuresData.dimensions{structureId}.(xDescriptor);
                                newYDataTemp = structuresData.dimensions{structureId}.(yDescriptor);
                                choiceFlag = 2;
                            else
                                newXDataTemp = structuresData.dimensions{structureId}.(xDescriptor);
                                newYDataTemp = [];
                                choiceFlag = 3;
                            end
                            if ~isempty(newXDataTemp) && (~isempty(newYDataTemp) || choiceFlag == 3)
                                xDataTemp = [xDataTemp newXDataTemp];
                                yDataTemp = [yDataTemp newYDataTemp];
                                zDataTemp = [zDataTemp strcat(label,', ',shapes)];
                            end
                        end
                    end
                end
            end
            if ~strcmp(yDescriptor,'Count')
                %% concatenating x, y and zDataTemp with other data for same plot
                xData{rowNum,colNum} = [xData{rowNum,colNum} xDataTemp];
                yData{rowNum,colNum} = [yData{rowNum,colNum} yDataTemp];
                zData{rowNum,colNum} = [zData{rowNum,colNum} zDataTemp];
            end
        end
        if strcmp(yDescriptor,'Count')
            %% concatenating x, y and zDataTemp with other data for same plot
            xData{rowNum,colNum} = xDataTemp;
            yData{rowNum,colNum} = yDataTemp;
            zData{rowNum,colNum} = zDataTemp;
        end
        
        %% assigning data to arrays for input to GRAMM
        types{rowNum,colNum} = plottingData.graph(graphId).subType;
        addBoxes{rowNum,colNum} = [addBoxes{rowNum,colNum} addBox];
        addLegends{rowNum,colNum} = [addLegends{rowNum,colNum} addLegend];
        splits{rowNum,colNum} = [splits{rowNum,colNum} split];
        flips{rowNum,colNum} = [flips{rowNum,colNum} flip];
        normalizations{rowNum,colNum} = [normalizations{rowNum,colNum} normalize];
        maps = [maps map];
        fills = [fills fill];
        fits = [fits fit];
        equations = [equations equation];
        xLines = [xLines xLine];
        yLines = [yLines yLine];
        binNums = [binNums binNum];
        rowNums = [rowNums rowNum];
        colNums = [colNums colNum];
        xDescriptors = [xDescriptors xDescriptor];
        yDescriptors = [yDescriptors yDescriptor];
    end
end

%% calculating effective number of graphs after deduction of graphs that are not included
numGraphsEff = numel(rowNums);

%% looping through graphs
for graphId = 1 : numGraphsEff
    
    %% transposing x, y and z Data to vector format
    xDataVec = xData{rowNums(graphId),colNums(graphId)};
    yDataVec = yData{rowNums(graphId),colNums(graphId)};
    zDataVec = zData{rowNums(graphId),colNums(graphId)};
    
    %% setting axes labels
    postLabel = constantFetcherFn('units',xDescriptors{graphId});
    labelX = [xDescriptors{graphId} ' ' postLabel];
    postLabel = constantFetcherFn('units',yDescriptors{graphId});
    labelY = [yDescriptors{graphId} ' ' postLabel];
    
    if ~isempty(yData{rowNums(graphId),colNums(graphId)})
        
        %% checking type of plot (some parameters are flipped to conform with convention)
        switch types{rowNums(graphId),colNums(graphId)}
            
            %% plotting a violin plot
            case 'Violin'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).stat_violin('fill',lower(fills{graphId}));
                g(rowNums(graphId),colNums(graphId)).set_names('y',labelY);
                plottingData.graph(graphId).xData = xDataVec;
                plottingData.graph(graphId).yData = yDataVec;
                
                %% plotting a box plot
            case 'Box plot'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).stat_boxplot('dodge',1.5,'width',1);
                g(rowNums(graphId),colNums(graphId)).set_names('y',labelY);
                plottingData.graph(graphId).xData = xDataVec;
                plottingData.graph(graphId).yData = yDataVec;
                
                %% plotting a jittered plot
            case 'Jittered'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).set_names('y',labelY);
                plottingData.graph(graphId).xData = xDataVec;
                plottingData.graph(graphId).yData = yDataVec;
                
                %% plotting a bars plot
            case 'Aligned bars'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).geom_bar('dodge',1.5,'width',1);
                g(rowNums(graphId),colNums(graphId)).set_names('y',labelY);
                plottingData.graph(graphId).xData = xDataVec;
                plottingData.graph(graphId).yData = yDataVec;
                
                %% plotting a bars plot
            case 'Stacked bars'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).geom_bar('dodge',1.5,'width',1,'stacked',1);
                g(rowNums(graphId),colNums(graphId)).set_names('y',labelY);
                plottingData.graph(graphId).xData = yDataVec;
                plottingData.graph(graphId).yData = xDataVec;
                
                %% plotting a scatter plot
            case 'Scatter'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).geom_point('dodge',0.5,'alpha',0.25);
                g(rowNums(graphId),colNums(graphId)).set_names('x',labelX,'y',labelY);
                g(rowNums(graphId),colNums(graphId)).set_point_options('base_size',1);
                plottingData.graph(graphId).xData = xDataVec;
                plottingData.graph(graphId).yData = yDataVec;
                
                %% plotting a line plot
            case 'Line'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).stat_glm();
                g(rowNums(graphId),colNums(graphId)).set_names('x',labelX,'y',labelY);
                plottingData.graph(graphId).xData = xDataVec;
                plottingData.graph(graphId).yData = yDataVec;
                
                %% plotting a smoothed plot
            case 'Smooth'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).stat_smooth();
                g(rowNums(graphId),colNums(graphId)).set_names('x',labelX,'y',labelY);
                plottingData.graph(graphId).xData = xDataVec;
                plottingData.graph(graphId).yData = yDataVec;
                
                %% plotting a summary plot
            case 'Summary'
                g(rowNums(graphId),colNums(graphId))...
                    = gramm('x',xDataVec,'y',yDataVec,'color',zDataVec);
                g(rowNums(graphId),colNums(graphId)).stat_summary();
                g(rowNums(graphId),colNums(graphId)).set_names('x',labelX,'y',labelY);
                plottingData.graph(graphId).xData = xDataVec;
                plottingData.graph(graphId).yData = yDataVec;
        end
        
    else
        
        %% plotting histogram
        g(rowNums(graphId),colNums(graphId))...
            = gramm('x',xDataVec,'color',zDataVec);
        plottingData.graph(graphId).xData = xDataVec;
        plottingData.graph(graphId).yData = [];
        
        %% normalizing histogram
        if (normalizations{rowNums(graphId),colNums(graphId)} == 1) | (strcmp(fits{graphId},'None') == 0)
            normType = 'probability';
        else
            normType = 'count';
        end
        
        %% fitting plot
        switch fits{graphId}
            
            %% plotting pdf
            case 'Density'
                g(rowNums(graphId),colNums(graphId)).stat_density('function','pdf');
                g(rowNums(graphId),colNums(graphId)).set_names('y','Probability');
                
            otherwise
                if binNums(graphId) == 0
                    
                    %% plotting all other plots (# bins automatically chosen)
                    switch types{rowNums(graphId),colNums(graphId)}
                        case 'Bar'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('fill',lower(fills{graphId}),'normalization',normType);
                        case 'Stacked bar'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('geom','stacked_bar','fill',lower(fills{graphId}),'normalization',normType);
                        case 'Point'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('geom','point','fill',lower(fills{graphId}),'normalization',normType);
                        case 'Line'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('geom','line','fill',lower(fills{graphId}),'normalization',normType);
                        case 'Stairs'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('geom','stairs','fill',lower(fills{graphId}),'normalization',normType);
                    end
                else
                    switch types{rowNums(graphId),colNums(graphId)}
                        
                        %% plotting all others plots (# bins input by user)
                        case 'Bar'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('fill',lower(fills{graphId}),'nbins',binNums(graphId),'normalization',normType);
                        case 'Stacked bar'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('geom','stacked_bar','fill',lower(fills{graphId}),'nbins',binNums(graphId),'normalization',normType);
                        case 'Point'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('geom','point','fill',lower(fills{graphId}),'nbins',binNums(graphId),'normalization',normType);
                        case 'Line'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('geom','line','fill',lower(fills{graphId}),'nbins',binNums(graphId),'normalization',normType);
                        case 'Stairs'
                            g(rowNums(graphId),colNums(graphId)).stat_bin('geom','stairs','fill',lower(fills{graphId}),'nbins',binNums(graphId),'normalization',normType);
                    end
                end
        end
        g(rowNums(graphId),colNums(graphId)).set_names('x',labelY);
    end
    
    %% fitting plots
    switch fits{graphId}
        
        %% fitting with normal distribution
        case 'Normal'
            fitFunc = '(1 ./ (sigma .* sqrt(2 .* pi))) .* exp( -0.5 .*((1 ./ sigma) .* (x - mu)) .^ 2)';
            if binNums(graphId) == 0
                g(rowNums(graphId),colNums(graphId)).stat_fit('fun',fitFunc,'geom','line','fullrange',false);
            else
                g(rowNums(graphId),colNums(graphId)).stat_fit('fun',fitFunc,'geom','line','fullrange',false,'nbins',binNums(graphId));
            end
            
            %% no fitting
        case {'Density','None'}
        otherwise
            switch fits{graphId}
                
                %% fitting with linear curve
                case 'Linear'
                    fitFunc = 'a .* x + b';
                    startPoint = [1 1];
                    
                    %% fitting with quadratic curve
                case 'Quadratic'
                    fitFunc = 'a .* (x .^ 2) + b';
                    startPoint = [1 1];
                    
                    %% fitting with exponential curve
                case 'Exponential'
                    fitFunc = 'a .* exp(-x) + b';
                    startPoint = [1 1];
                    
                    %% fitting with polynomial curve
                case 'Polynomial'
                    fitFunc = 'a .* (x .^ c) + b';
                    startPoint = [1 1];
                    
                    %% fitting a custom equation
                case 'Custom'
                    funcParts = strsplit(equations{graphId},{'[',',',']'});
                    fitFunc = funcParts{1};
                    startPoints = funcParts(2:end);
                    for startPointId = 1 : numel(startPoints) - 1
                        startPoint(startPointId) = str2double(startPoints{startPointId});
                    end
            end
            
            %% setting fitting parameters
            g(rowNums(graphId),colNums(graphId)).stat_fit('fun',fitFunc,'StartPoint',startPoint,'geom','line','fullrange',true);
    end
    
    %% splitting plot
    if sum(splits{rowNums(graphId),colNums(graphId)}) == 0
        xFacetVar = [];
    else
        xFacetVar = zDataVec;
    end
    
    %% flipping plot
    if ~sum(flips{rowNums(graphId),colNums(graphId)}) == 0
        g(rowNums(graphId),colNums(graphId)).coord_flip();
    end
    
    %% adding legend
    if sum(addLegends{rowNums(graphId),colNums(graphId)}) == 0
        g(rowNums(graphId),colNums(graphId)).facet_grid(xFacetVar,[],'row_labels',0);
        g(rowNums(graphId),colNums(graphId)).set_layout_options('legend',0);
    else
        g(rowNums(graphId),colNums(graphId)).facet_grid(xFacetVar,[]);
    end
    
    %% adding box
    if ~sum(addBoxes{rowNums(graphId),colNums(graphId)}) == 0
        g(rowNums(graphId),colNums(graphId)).axe_property('Box','on');
    end
    
    %% adding intercept
    if ~xLines(graphId) == 0
        g(rowNums(graphId),colNums(graphId)).geom_vline('xintercept',xLines(graphId));
    end
    if ~yLines(graphId) == 0
        g(rowNums(graphId),colNums(graphId)).geom_hline('yintercept',yLines(graphId));
    end
    
    %% setting map
    g(rowNums(graphId),colNums(graphId)).set_color_options('map',maps{graphId});
    
    %% setting extra limit
    g(rowNums(graphId),colNums(graphId)).set_limit_extra([0.05 0.05],[0.05 0.05]);
    
    %% setting order
    g(rowNums(graphId),colNums(graphId)).set_order_options('x',0);
    
    %% setting fontSize
    g(rowNums(graphId),colNums(graphId)).set_text_options('interpreter','tex','font','Helvetica','base_size',plottingData.fontSize);
end

%% drawing figure
fHandle = figure('Units','centimeters',...
    'MenuBar','none',...
    'ToolBar','none',...
    'Resize','off',...
    'NumberTitle','off',...
    'Name','Leave open for export');

%% setting figure length and width
set(fHandle,'position',[0 0 plottingData.length plottingData.width]);

%% moving figure to center of screen
movegui(fHandle,'center');

%% drawing plots
g.draw();

%% transferring g class to UI property
plottingData.figureData = g;
app.pr_plottingData = plottingData;

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: plotting complete.')];
drawnow;