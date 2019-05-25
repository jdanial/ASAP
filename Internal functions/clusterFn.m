function returnFlag = clusterFn(app)
% clusterFn() -
% clusters classified structures according to their size parameters
% and the input clustering parameters.
%
% Syntax -
% clusterFn(app)
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
switch app.pr_entryPoint
    case 'UI'
        listBoxHandle = app.ListBox6_1;
        inputFiles = readListBoxAuxFn(listBoxHandle,app.pr_fileList);
    otherwise
        inputFiles = app.pr_fileList;
end

%% extracting number of files
numFiles = numel(inputFiles);

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: clustering started.')];
drawnow;

%% initializing structureIndices and fileIndices
structuresIndices = [];
fileIndices = [];
structureCount = 1;

%% looping through files
for fileId = 1 : numFiles
    
    %% reading module parameters
    switch app.pr_entryPoint
        case 'UI'
            shapes = app.ListBox6_2.Value;
            descriptors = app.ListBox6_3.Value;
            mode = app.DropDown6_1.Value;
            clusterAll = app.CheckBox6_1.Value;
            numClustersKnown = strcmp(app.Switch6_1.Value,'Y');
            numClusters = app.EditField6_1.Value;
            displayImages = app.DisplayImagesMenu.Checked;
            displayPlots = app.DisplayPlotsMenu.Checked;
            exportImages = app.ExportImagesMenu.Checked;
            exportPlots = app.ExportPlotsMenu.Checked;
            exportRawData = app.ExportRawDataMenu.Checked;
            
            %% setting export options
            if exportImages
                app.pr_options.file(fileId).exportImages = 'true';
            else
                app.pr_options.file(fileId).exportImages = 'false';
            end
            if exportPlots
                app.pr_options.file(fileId).exportPlots = 'true';
            else
                app.pr_options.file(fileId).exportPlots = 'false';
            end
            if exportRawData
                app.pr_options.file(fileId).exportRawData = 'true';
            else
                app.pr_options.file(fileId).exportRawData = 'false';
            end
        otherwise
            shapes = app.pr_clusteringParam.file(fileId).shape;
            descriptors = app.pr_clusteringParam.file(fileId).descriptor;
            mode = app.pr_clusteringParam.file(fileId).clusteringMode;
            clusterAll = strcmp(app.pr_clusteringParam.file(fileId).clusterAll,'true');
            numClustersKnown = strcmp(app.pr_clusteringParam.file(fileId).numClustersKnown,'true');
            numClusters = app.pr_clusteringParam.file(fileId).numClusters;
            displayImages = strcmp(app.pr_options.file(fileId).displayImages,'true');
            displayPlots = strcmp(app.pr_options.file(fileId).displayPlots,'true');
    end
    
    %% reading number of structures
    numStructures = numel(app.pr_structuresData.file(fileId).identifiedStructures);
    
    %% looping through structures
    for structureId = 1 : numStructures
        switch app.pr_structuresData.file(fileId).shapes{structureId}
            case shapes
                structuresIndices(structureCount,1) = structureId;
                fileIndices(structureCount,1) = fileId;
                structureCount = structureCount + 1;
        end
    end
    
    %% extracting shape descriptors
    structureCount = 1;
    descriptorData = [];
    for index = 1 : size(structuresIndices,1)
        for descriptorId = 1 : numel(descriptors)
            descriptor = descriptors{descriptorId};
            descriptorData(structureCount,descriptorId) = ...
                app.pr_structuresData.file(fileIndices(index,1)).dimensions{structuresIndices(index,1)}.(descriptor(~isspace(descriptor)));
        end
        structureCount = structureCount + 1;
    end
end

%% clustering and displaying data
if clusterAll
    try
        clusterDataOutput = clusterData(descriptorData,numClusters,numClustersKnown,mode);
    catch
        returnFlag = true;
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s','ASAP error 26: cannot cluster data.')];
        return;
    end
    if displayPlots
        displayClusteredPlots(descriptors,descriptorData, ...
            clusterDataOutput.descriptorDataGrouping,'');
    end
    for fileId = 1 : numFiles
        
        %% setting up ASAP progress
        message = app.MsgBox.Value;
        message{end} = ['ASAP progress: clustering structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
        app.MsgBox.Value = message;
        drawnow;
        
        [clusteredImage,clusteredImageReshaped] = displayClusteredImages(app,structuresIndices(fileIndices == fileId,:), ...
            clusterDataOutput.descriptorDataGrouping(fileIndices == fileId,:),inputFiles(fileId).name,fileId,displayImages);
        app.pr_structuresData.file(fileId).clusteringData.shapes = shapes;
        app.pr_structuresData.file(fileId).clusteringData.descriptors = descriptors;
        app.pr_structuresData.file(fileId).clusteringData.mode = mode;
        app.pr_structuresData.file(fileId).clusteringData.numActualClusters = numClusters;
        app.pr_structuresData.file(fileId).clusteringData.descriptorData = descriptorData;
        app.pr_structuresData.file(fileId).clusteringData.structuresIndices = structuresIndices(fileIndices == fileId,:);
        app.pr_structuresData.file(fileId).clusteringData.descriptorDataGrouping = clusterDataOutput.descriptorDataGrouping(fileIndices == fileId,:);
        app.pr_structuresData.file(fileId).clusteringData.numOptimalClusters = clusterDataOutput.numOptimalClusters;
        app.pr_structuresData.file(fileId).clusteringData.siluoetteCoefficient = clusterDataOutput.siluoetteCoefficient;
        app.pr_structuresData.file(fileId).clusteringData.clusteredImage = clusteredImage;
        app.pr_structuresData.file(fileId).clusteringData.clusteredImageReshaped = clusteredImageReshaped;
        app.pr_structuresData.file(fileId).Function = 'clustered';
    end
else
    for fileId = 1 : numFiles
        try
            clusterDataOutput = clusterData(descriptorData(fileIndices == fileId,:), ...
                numClusters,numClustersKnown,mode);
        catch
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 26: cannot cluster data.')];
            return;
        end
        if displayPlots
            displayClusteredPlots(descriptors,descriptorData(fileIndices == fileId,:), ...
                clusterDataOutput.descriptorDataGrouping,inputFiles(fileId).name);
        end
        
        %% setting up ASAP progress
        message = app.MsgBox.Value;
        message{end} = ['ASAP progress: clustering structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
        app.MsgBox.Value = message;
        drawnow;
        
        [clusteredImage,clusteredImageReshaped] = displayClusteredImages(app,structuresIndices(fileIndices == fileId,:), ...
            clusterDataOutput.descriptorDataGrouping,inputFiles(fileId).name,fileId,displayImages);
        app.pr_structuresData.file(fileId).clusteringData.shapes = shapes;
        app.pr_structuresData.file(fileId).clusteringData.descriptors = descriptors;
        app.pr_structuresData.file(fileId).clusteringData.mode = mode;
        app.pr_structuresData.file(fileId).clusteringData.numActualClusters = numClusters;
        app.pr_structuresData.file(fileId).clusteringData.descriptorData = descriptorData;
        app.pr_structuresData.file(fileId).clusteringData.structuresIndices = structuresIndices;
        app.pr_structuresData.file(fileId).clusteringData.descriptorDataGrouping = clusterDataOutput.descriptorDataGrouping;
        app.pr_structuresData.file(fileId).clusteringData.numOptimalClusters = clusterDataOutput.numOptimalClusters;
        app.pr_structuresData.file(fileId).clusteringData.siluoetteCoefficient = clusterDataOutput.siluoetteCoefficient;
        app.pr_structuresData.file(fileId).clusteringData.clusteredImage = clusteredImage;
        app.pr_structuresData.file(fileId).clusteringData.clusteredImageReshaped = clusteredImageReshaped;
        app.pr_structuresData.file(fileId).Function = 'clustered';
    end
end

%% calculating Jaccard indices
if numFiles > 1
    for fileId_1 = 1 : numFiles
        
        %% setting up ASAP progress
        message = app.MsgBox.Value;
        message{end} = ['ASAP progress: calculating Jaccard indices in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
        app.MsgBox.Value = message;
        drawnow;
        
        for fileId_2 = 1 : numFiles
            clusteredImageTemp_1 = app.pr_structuresData.file(fileId_1).clusteringData.clusteredImageReshaped;
            clusteredImageTemp_2 = app.pr_structuresData.file(fileId_2).clusteringData.clusteredImageReshaped;
            sizeImage_1 = size(clusteredImageTemp_1);
            sizeImage_2 = size(clusteredImageTemp_2);
            if fileId_2 ~= fileId_1 && isequal(sizeImage_1,sizeImage_2)
                [jaccardIndex,adjustedJaccardIndex] = calculateJaccardIndex(app,fileId_1,fileId_2);
                app.pr_structuresData.file(fileId_1).clusteringData.JaccardIndex{fileId_2} = jaccardIndex;
                app.pr_structuresData.file(fileId_1).clusteringData.AdjJaccardIndex{fileId_2} = adjustedJaccardIndex;
            end
        end
    end
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: clustering complete.')];
drawnow;
end

function clusterDataOutput = clusterData(descriptorData,numClusters,numClustersKnown,mode)
% clusterData - (Subfunction)
% clusters data according to supplied parameters.
%
% Syntax -
% clusterData(descriptorData,numClusters,...
% numClustersKnown,mode)
%
% Parameters -
% - 'descriptorData': parametic data of the selected shapes
% - 'numClustersKnown': boolean of clusters known (1) or not (0).
% - 'numClusters': number of clusters (if known).
% - 'mode': algorithm (Centroid) or (Gaussian Mixture).
%
% Copyright -
% John S. H. Danial (2018).
% danial@is.mpg.de

clusterDataOutput = [];
switch mode
    case 'Centroid'
        if numClustersKnown
            [clusterDataOutput.descriptorDataGrouping,~] = kmeans(descriptorData,numClusters);
            clusterDataOutput.evaluation = evalclusters(descriptorData,'kmeans','silhouette','KList',1 : 10);
            clusterDataOutput.numOptimalClusters = clusterDataOutput.evaluation.OptimalK;
            clusterDataOutput.siluoetteCoefficient = clusterDataOutput.evaluation.CriterionValues(numClusters);
        else
            clusterDataOutput.evaluation = evalclusters(descriptorData,'kmeans','silhouette','KList',1 : 10);
            clusterDataOutput.numOptimalClusters = clusterDataOutput.evaluation.OptimalK;
            clusterDataOutput.numClusters = clusterDataOutput.numOptimalClusters;
            clusterDataOutput.siluoetteCoefficient = max(clusterDataOutput.evaluation.CriterionValues);
            [clusterDataOutput.descriptorDataGrouping,~] = ...
                kmeans(descriptorData,clusterDataOutput.numOptimalClusters);
        end
    case 'Gaussian mixture'
        if numClustersKnown
            clusterDataOutput.gaussianMixtureFit = ...
                fitgmdist(descriptorData,numClusters, ...
                'CovarianceType','full','SharedCovariance',true,'Options',statset('MaxIter',1000));
            clusterDataOutput.descriptorDataGrouping = ...
                cluster(clusterDataOutput.gaussianMixtureFit,descriptorData);
            clusterDataOutput.evaluation = ...
                evalclusters(descriptorData,'gmdistribution','silhouette','KList',1 : 10);
            clusterDataOutput.numOptimalClusters = clusterDataOutput.evaluation.OptimalK;
            clusterDataOutput.siluoetteCoefficient = clusterDataOutput.evaluation.CriterionValues(numClusters);
        else
            clusterDataOutput.evaluation = ...
                evalclusters(descriptorData,'gmdistribution','silhouette','KList',1 : 10);
            clusterDataOutput.evaluation
            clusterDataOutput.numOptimalClusters = clusterDataOutput.evaluation.OptimalK;
            clusterDataOutput.numClusters = clusterDataOutput.numOptimalClusters;
            clusterDataOutput.siluoetteCoefficient = max(clusterDataOutput.evaluation.CriterionValues);
            clusterDataOutput.gaussianMixtureFit = ...
                fitgmdist(descriptorData,clusterDataOutput.numOptimalClusters, ...
                'CovarianceType','full','SharedCovariance',true,'Options',statset('MaxIter',1000));
            clusterDataOutput.descriptorDataGrouping = ...
                cluster(clusterDataOutput.gaussianMixtureFit,descriptorData);
        end
end
end

function [clusteredImage,clusteredImageReshaped] = displayClusteredImages(app,structuresIndices,descriptorDataGrouping,fileName,fileId,displayImages)
% displayClusteredImages - (Subfunction)
% displays the spatial distribution of clustered data.
%
% Syntax -
% displayClusteredImages(structuresData,structuresIndices,...
% descriptorDataGrouping,fileNames,fileId)
%
% Parameters -
% - 'structuresData': array of structures data.
% - 'structuresIndices': indices of structures selected for structuring.
% - 'descriptorDataGrouping': clustered data.
% - 'fileNames': names of the selected files for clustering.
% - 'fileId': index of the file being display.
%
% Copyright -
% John S. H. Danial (2018).
% danial@is.mpg.de

image = app.pr_structuresData.file(fileId).image;

%% setting color map
colorMap = linspecerFnExt(max(unique(descriptorDataGrouping)));

%% setting intensity values according to their group affiliation
clusteredImageTemp = zeros(1,size(image,1) * size(image,2));
for index = 1 : length(descriptorDataGrouping)
    xPosList = app.pr_structuresData.file(fileId).identifiedStructures(structuresIndices(index,1)).PixelList(:,1);
    yPosList = app.pr_structuresData.file(fileId).identifiedStructures(structuresIndices(index,1)).PixelList(:,2);
    pixelList = sub2ind(size(image),yPosList,xPosList);
    clusteredImageTemp(pixelList) = descriptorDataGrouping(index);
end

%% reshaping 'clusteredImageTemp' to 2D array
clusteredImageReshaped = reshape(clusteredImageTemp,size(image));

%% converting 'clusteredImageReshaped' from gray to rgb
clusteredImage = ind2rgb(clusteredImageReshaped,colorMap);
if displayImages
    %% setting figure properties
    screenPixels = get(0,'screensize');
    figureHandle = figure('Units','normalized','MenuBar','none','ToolBar','none','Resize','off');
    
    %% displaying clustered image
    imshow(clusteredImage);
    
    %% setting title and figure captions
    title(fileName);
    set(figureHandle,'position',[0 0 0.75 * ((screenPixels(4) / screenPixels(3)) * ...
        (size(image,2) / size(image,1)))  0.75]);
    text(size(image,2)/2,size(image,1) + 30 ,...
        'Left click to magnify (+ zoom in / - zoom out)',...
        'clipping','off','FontSize',11,'Color','red',...
        'HorizontalAlignment','center');
    
    %% moving figure to center
    movegui(figureHandle,'center');
    
    %% calling magnifyFnExt - refer to function for external calls
    magnifyFnExt(figureHandle);
end
end

function displayClusteredPlots(descriptors,descriptorData,descriptorDataGrouping,fileName)
% displayClusteredPlots - (Subfunction)
% displays a 2D plot of clustered data.
%
% Syntax -
% displayClusteredPlots(descriptors,descriptorData,...
% descriptorDataGrouping,fileNames,fileId)
%
% Parameters -
% - 'descriptors': names of the shape descriptors.
% - 'descriptorData': parametric data of selected shapes.
% - 'descriptorDataGrouping': clustered data.
% - 'fileNames': names of the selected files for clustering.
% - 'fileId': index of the file being display.
%
% Copyright -
% John S. H. Danial (2018).
% danial@is.mpg.de

%% setting figure properties
screenPixels = get(0,'screensize');
figureHandle = figure('Units','normalized','MenuBar','none','ToolBar','none','Resize','off');

%% setting color map
colorMap = linspecerFnExt(max(unique(descriptorDataGrouping)));

%% plotting clustered data
if size(descriptorData,2) == 1
    gscatter(descriptorData(:,1),descriptorData(:,1),descriptorDataGrouping,colorMap);
else
    gscatter(descriptorData(:,1),descriptorData(:,2),descriptorDataGrouping,colorMap);
end

%% setting figure properties
title(fileName);
set(figureHandle,'position',[0 0 0.5 * (screenPixels(4) / screenPixels(3)) 0.5]);

%% setting axis properties
if size(descriptors,2) == 1
    xlabel(descriptors);
    ylabel(descriptors);
else
    xlabel(descriptors{1});
    ylabel(descriptors{2});
end
ax = gca;
ax.LineWidth = 1.2;
ax.FontSize = 11;
ax.XColor = [0.25 0.25 0.25];
ax.YColor = [0.25 0.25 0.25];
ax.TickDir = 'out';
ax.Box = 'off';
axis square;
ax.Units = 'normalized';
ax.FontUnits = 'normalized';

%% setting legend properties
legendHandle = legend('Location','southeast');
legendHandle.FontSize = 11;
legendHandle.TextColor = [0.25 0.25 0.25];
title(legendHandle,'Groups');

%% moving figure to center
movegui(figureHandle,'center');
end

function [jaccardIndex,adjustedJaccardIndex] = calculateJaccardIndex(app,fileId_1,fileId_2)
% calculateJaccardIndex - (Subfunction)
% calculate the Jaccard Index between clusters across two different images.
%
% Syntax -
% calculateJaccardIndex(structuresData,fileId_1,fileId_2)
%
% Parameters -
% - 'structuresData': array of structures data.
% - 'fileId_1': index of first file.
% - 'fileId_2': index of second file.
%
% Copyright -
% John S. H. Danial (2018).
% danial@is.mpg.de

clusteredImageTemp_1 = app.pr_structuresData.file(fileId_1).clusteringData.clusteredImageReshaped;
clusteredImageTemp_2 = app.pr_structuresData.file(fileId_2).clusteringData.clusteredImageReshaped;
sizeImage_1 = size(clusteredImageTemp_1);
sizeImage_2 = size(clusteredImageTemp_2);
if isequal(sizeImage_1,sizeImage_2)
    groups_1 = unique(app.pr_structuresData.file(fileId_1).clusteringData.descriptorDataGrouping);
    groups_2 = unique(app.pr_structuresData.file(fileId_2).clusteringData.descriptorDataGrouping);
    jaccardIndex = zeros(length(groups_1),length(groups_2));
    adjustedJaccardIndex = zeros(length(groups_1),length(groups_2));
    
    for groupId_1 = 1 : length(groups_1)
        clusteredImage_1 = clusteredImageTemp_1;
        
        % silencing all structures not belonging to current group
        clusteredImage_1(clusteredImage_1 ~= groups_1(groupId_1)) = 0;
        
        % converting silenced image to logical
        clusteredImageBW_1 = clusteredImage_1 > 0;
        
        % finding centroid of silenced imaged
        [yPos_1,xPos_1] = ndgrid(1:size(clusteredImageBW_1,1),1:size(clusteredImageBW_1,2));
        centroidclusteredImageBW_1 = mean([xPos_1(logical(clusteredImageBW_1)),yPos_1(logical(clusteredImageBW_1))]);
        
        % calculating convex hull of silenced image
        convexHullClusteredImage_1 = bwconvhull(clusteredImage_1);
        
        % finding centroid of the convex hull
        [yPos_1,xPos_1] = ndgrid(1:size(convexHullClusteredImage_1,1),1:size(convexHullClusteredImage_1,2));
        centroidConvexHullClusteredImage_1 = mean([xPos_1(logical(convexHullClusteredImage_1)),yPos_1(logical(convexHullClusteredImage_1))]);
        
        % calculating distance between both centroids
        distance_1 = pdist([centroidclusteredImageBW_1;centroidConvexHullClusteredImage_1],'euclidean');
        
        for groupId_2 = 1 : length(groups_2)
            clusteredImage_2 = clusteredImageTemp_2;
            
            % silencing all structures not belonging to current group
            clusteredImage_2(clusteredImage_2 ~= groups_2(groupId_2)) = 0;
            
            % converting silenced image to logical
            clusteredImageBW_2 = clusteredImage_2 > 0;
            
            % finding centroid of silenced imaged
            [yPos_2,xPos_2] = ndgrid(1:size(clusteredImageBW_2,1),1:size(clusteredImageBW_2,2));
            centroidclusteredImageBW_2 = mean([xPos_2(logical(clusteredImageBW_2)),yPos_2(logical(clusteredImageBW_2))]);
            
            % calculating convex hull of silenced image
            convexHullClusteredImage_2 = bwconvhull(clusteredImage_2);
            
            % finding centroid of the convex hull
            [yPos_2,xPos_2] = ndgrid(1:size(convexHullClusteredImage_2,1),1:size(convexHullClusteredImage_2,2));
            centroidConvexHullClusteredImage_2 = mean([xPos_2(logical(convexHullClusteredImage_2)),yPos_2(logical(convexHullClusteredImage_2))]);
            
            % calculating distance between both centroids
            distance_2 = pdist([centroidclusteredImageBW_2;centroidConvexHullClusteredImage_2],'euclidean');
            
            % calculating Jaccard index
            jaccardIndex(groupId_1,groupId_2) = ...
                sum(sum(and(convexHullClusteredImage_1,convexHullClusteredImage_2)))/ ...
                sum(sum(or(convexHullClusteredImage_1,convexHullClusteredImage_2)));
            
            % calculating adjusted Jaccard index
            adjustedJaccardIndex(groupId_1,groupId_2) = ...
                jaccardIndex(groupId_1,groupId_2) * ...
                (min([distance_1 distance_2]) / max([distance_1 distance_2]));
        end
    end
end
end
