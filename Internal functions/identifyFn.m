function returnFlag = identifyFn(app)
% identifyFn() -
% identifies structures in a super resolution microscopy
% based on their connectivity or spatial promixity (density).
%
% Syntax -
% identifyFn(app).
%
% Parameters -
% - app: ASAP UI class
%
% Copyright -
% John S. H. Danial (2018).
% danial@is.mpg.de

%% initializing returnFlag
returnFlag = false;

%% issuing initial error statements
if isempty(app.pr_exportPath)
    returnFlag = true;
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 12: no path is selected.')];
    return;
end
if isempty(app.pr_fileList)
    returnFlag = true;
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 13: no image files available.')];
    return;
end
switch app.pr_entryPoint
    case 'UI'
        inputFiles = readListBoxAuxFn(app.ListBox2_1,app.pr_fileList);
        if isempty(inputFiles)
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 14: no image files selected.')];
            return;
        end
    otherwise
        inputFiles = app.pr_fileList;
        if isempty(inputFiles)
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 13: no image files available.')];
            return;
        end
end

%% reading number of files
numFiles = numel(inputFiles);

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: identification started.')];
drawnow;

%% initializing structuresData property
app.pr_structuresData = struct();

%% initializing imageId
imageId = 1;

%% looping through files
for fileId = 1 : numFiles
    
    %% reading image file
    if numFiles == 1
        fileName = inputFiles.name;
        fileFolder = inputFiles.folder;
    else
        fileName = inputFiles(fileId).name;
        fileFolder = inputFiles(fileId).folder;
    end
    filePath = fullfile(fileFolder,fileName);
    try
        image = imread(filePath);
    catch
        returnFlag = true;
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s',['ASAP error 15: cannot read image file (' fileName ').'])];
        return;
    end
    
    %% reading identification parameters
    switch app.pr_entryPoint
        case 'UI'
            segment = app.SegmentCheckBox2_1.Value;
            segmentationLevel = round(app.LevelEditField2_1.Value);
            identificationMode = app.DropDown2_1.Value;
            thresholdMode = app.DropDown2_2.Value;
            thresholdMultiplier = app.MultiplierEditFieldSize2_1.Value;
            cleanParticleSize = app.ParticleSizeEditField2_1.Value;
            searchRadius = app.SearchRadiusEditField2_1.Value;
            clearBorder = app.ClearBorderCheckBox2_1.Value;
            maxStructureSize = app.MaxStructureSizeSpinner2_1.Value;
            sizeLowerBound = app.SizeLowEditField2_1.Value;
            sizeUpperBound = app.SizeUppEditField2_1.Value;
            displayImages = app.DisplayImagesMenu.Checked;
            exportImages = app.ExportImagesMenu.Checked;
            exportRawData = app.ExportRawDataMenu.Checked;
            
            %% setting export options
            if exportImages
                app.pr_options.file(fileId).exportImages = 'true';
            else
                app.pr_options.file(fileId).exportImages = 'false';
            end
            if exportRawData
                app.pr_options.file(fileId).exportRawData = 'true';
            else
                app.pr_options.file(fileId).exportRawData = 'false';
            end
        otherwise
            segment = strcmp(app.pr_identificationParam.file(fileId).segment,'true');
            segmentationLevel = app.pr_identificationParam.file(fileId).segmentationLevel;
            identificationMode = app.pr_identificationParam.file(fileId).identificationMode;
            thresholdMode = app.pr_identificationParam.file(fileId).thresholdMode;
            thresholdMultiplier = app.pr_identificationParam.file(fileId).thresholdMultiplier;
            cleanParticleSize = app.pr_identificationParam.file(fileId).maxClearParticleSize;
            searchRadius = app.pr_identificationParam.file(fileId).maxClearSearchRadius;
            clearBorder = strcmp(app.pr_identificationParam.file(fileId).clearBorder,'true');
            maxStructureSize = app.pr_identificationParam.file(fileId).maxStructureSize;
            sizeLowerBound = app.pr_identificationParam.file(fileId).minSize;
            sizeUpperBound = app.pr_identificationParam.file(fileId).maxSize;
            displayImages = strcmp(app.pr_options.file(fileId).displayImages,'true');
    end
    
    %% cell segmentation
    if segment
        segmentedImage = imageSegmentorAuxFn(image,segmentationLevel);
        outline = bwperim(segmentedImage);
        image = immultiply(image,segmentedImage);
    else
        outline = false(size(image));
    end
    
    % defining bounding box color and thickness
    boxThickness = round(max([1 round(max(size(image)) / 1000)]));
    
    % padding image and outline
    image = padarray(image,[2 * boxThickness + 1 2 * boxThickness + 1],'both');
    outline = padarray(outline,[2 * boxThickness + 1 2 * boxThickness + 1],'both');
    
    %% setting up ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: identifying structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '. Thresholding image.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% calling ImageThresholder
    thresholdImage = ImageThresholder(image,thresholdMode,thresholdMultiplier);
    
    %% displaying ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: identifying structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '. Clearing borders.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% calling ImageCleaner
    cleanedImage = ImageCleaner(image,thresholdImage,clearBorder,cleanParticleSize,searchRadius);
    
    %% displaying ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: identifying structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '. Identifying structures.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% calling StructureIdentifier
    [returnFlag,image,identifiedStructures] = ...
        StructureIdentifier(image,cleanedImage,identificationMode,sizeLowerBound,sizeUpperBound,maxStructureSize);
    
    if returnFlag
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s',['ASAP error 18: cannot identify any structures in (' fileName ').'])];
        return;
    end
    
    %% displaying ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: identifying structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '. Annotating image.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% calling ImageAnnotator
    [returnFlag,image,imageOutlined,identifiedStructures] = ImageAnnotator(image,thresholdImage,outline,identifiedStructures,identificationMode,boxThickness);
    
    %% transferring data to UI class property
    app.pr_structuresData.file(imageId).name = erase(fileName,{'.png','.tif','.jpg'});
    app.pr_structuresData.file(imageId).image = image;
    app.pr_structuresData.file(imageId).imageOutlined = imageOutlined;
    app.pr_structuresData.file(imageId).identificationMode = identificationMode;
    app.pr_structuresData.file(imageId).identifiedStructures = identifiedStructures;
    app.pr_structuresData.file(imageId).function = 'identified';
    
    %% displaying outlinedImage
    if displayImages
        displayImageAuxFn(imageOutlined);
    end
    
    %% incrementing imageId
    imageId = imageId + 1;
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: identification complete.')];
drawnow;
end

%%====================ImageThresholder=====================%%
function thresholdImage = ImageThresholder(image,thresholdMode,thresholdMultiplier)

% thresholding image
switch thresholdMode
    case 'Relative'
        thresholdValue = adaptthresh(image) .* thresholdMultiplier;
        thresholdImage = imbinarize(image,thresholdValue);
    case 'Fixed'
        thresholdValue = graythresh(image) .* thresholdMultiplier;
        thresholdImage = imbinarize(image,thresholdValue);
end
end

%%====================ImageCleaner=====================%%
function cleanedImage = ImageCleaner(image,thresholdImage,clearBorder,cleanParticleSize,searchRadius)

% finding rows and cols of high intensity regions
[rowPos,colPos] = find(thresholdImage > 0);

% getting number of rows and columns in the thresholdImage
rowNum = size(thresholdImage,1);
colNum = size(thresholdImage,2);

% calculating border margin
margin = 0.05 * min([rowNum colNum]);

for index = 1 : length(rowPos)
    
    % calculating clusterSize
    clusterSize = 0;
    for rowId = rowPos(index) - searchRadius : rowPos(index) + searchRadius
        for colId = colPos(index) - searchRadius : colPos(index) + searchRadius
            if thresholdImage(min(max(rowId,1),rowNum),min(max(colId,1),colNum))
                clusterSize = clusterSize + 1 ;
            end
        end
    end
    if clusterSize <= cleanParticleSize
        thresholdImage(rowPos(index),colPos(index)) = 0;
    end
    
    % clearing image borders
    if clearBorder
        if clusterSize > cleanParticleSize && ...
                (rowPos(index) < 1 + margin) || ...
                (rowPos(index) > size(image,1) - margin) || ...
                (colPos(index) < 1 + margin) || ...
                (colPos(index) > size(image,2) - margin)
            thresholdImage(rowPos(index),colPos(index)) = 0;
        end
    end
end

% returning cleaned image
cleanedImage = immultiply(image,thresholdImage);
end

%%====================StructureIdentifier=====================%%
function [returnFlag,image,identifiedStructures] = ...
    StructureIdentifier(image,cleanedImage,identificationMode,sizeLowerBound,sizeUpperBound,varargin)

% initializing returnFlag
returnFlag = false;

% initializing returnFlag
noStructures = true;

% initializing identifiedStructures
identifiedStructures = struct;

% segmenting structures by connectivity
switch identificationMode
    case 'Connectivity'
        
        % processing structures (excluding out of range)
        processedImage = xor(bwareaopen(cleanedImage,sizeLowerBound),bwareaopen(cleanedImage,sizeUpperBound));
        image = immultiply(image,processedImage);
        
        % retrieving identified structures in range
        identifiedStructures = regionprops(processedImage,'PixelList');
        noStructures = false;
        
    case 'Size'
        
        maxStructureSize = varargin{1};
        
        % calling sizeBasedClusteringAuxFn
        [clusterNum,clusteredStructures] = sizeBasedClusteringAuxFn(cleanedImage,maxStructureSize);
        
        % initializing structure Id
        structureId = 0;
        
        % processing structures (excluding out of range)
        for clusterId = 1 : clusterNum
            coorIds = clusteredStructures(clusterId).PixelList;
            Area  = length(coorIds(:,1));
            if (Area > sizeLowerBound) && (Area < sizeUpperBound)
                
                % including structures in range
                structureId = structureId + 1;
                identifiedStructures(structureId).PixelList = [coorIds(:,2) coorIds(:,1)];
                
                % flipping boolean
                noStructures = false;
            else
                
                % removing structures out of range
                for pixelId = 1 : size(coorIds,1)
                    image(coorIds(pixelId,1),coorIds(pixelId,2)) = 0;
                end
            end
        end
        
end

if noStructures
    returnFlag = true;
end
end

%%====================ImageAnnotator=====================%%
function [returnFlag,image,imageOutlined,identifiedStructures] = ...
    ImageAnnotator(image,thresholdImage,outline,identifiedStructures,identificationMode,boxThickness)

% initializing returnFlag
returnFlag = false;

% defiing box color
boxColor = max(image(:));

% looping through structures for capturing
for structureId = 1 : numel(identifiedStructures)
    
    rowIdDown = min(identifiedStructures(structureId).PixelList(:,2)) - boxThickness;
    rowIdUp = max(identifiedStructures(structureId).PixelList(:,2)) + boxThickness;
    colIdLeft = min(identifiedStructures(structureId).PixelList(:,1)) - boxThickness;
    colIdRight = max(identifiedStructures(structureId).PixelList(:,1)) + boxThickness;
    
    switch identificationMode
        case 'Connectivity'
            rawImage = zeros(rowIdUp - rowIdDown,colIdRight - colIdLeft);
            binaryImage = zeros(rowIdUp - rowIdDown,colIdRight - colIdLeft);
            centerRow = round((rowIdUp - rowIdDown) / 2) + 1;
            centerCol = round((colIdRight - colIdLeft) / 2) + 1;
            meanRow = round(mean(identifiedStructures(structureId).PixelList(:,2)));
            meanCol = round(mean(identifiedStructures(structureId).PixelList(:,1)));
            for pixelId = 1 : length(identifiedStructures(structureId).PixelList(:,2))
                absoluteRow = identifiedStructures(structureId).PixelList(pixelId,2);
                absoluteCol = identifiedStructures(structureId).PixelList(pixelId,1);
                relativeRow = absoluteRow - meanRow + centerRow + 1;
                relativeCol = absoluteCol - meanCol + centerCol + 1;
                if relativeRow < 1
                    relativeRow = 1;
                elseif relativeRow > size(rawImage,1)
                    relativeRow = size(rawImage,1);
                end
                if relativeCol < 1
                    relativeCol = 1;
                elseif relativeCol > size(rawImage,2)
                    relativeCol = size(rawImage,2);
                end
                rawImage(relativeRow,relativeCol) = image(absoluteRow,absoluteCol);
                binaryImage(relativeRow,relativeCol) = thresholdImage(absoluteRow,absoluteCol);
                identifiedStructures(structureId).rawStructure = rawImage;
                identifiedStructures(structureId).binaryStructure = binaryImage > 0;
            end
            
        case 'Size'
            
            identifiedStructures(structureId).rawStructure = image(rowIdDown - boxThickness : rowIdUp + boxThickness,...
                colIdLeft - boxThickness : colIdRight  + boxThickness);
            identifiedStructures(structureId).binaryStructure = thresholdImage(rowIdDown - boxThickness : rowIdUp + boxThickness,...
                colIdLeft - boxThickness : colIdRight  + boxThickness);
    end
end

% looping through structures for annotation
for structureId = 1 : numel(identifiedStructures)
    rowIdDown = min(identifiedStructures(structureId).PixelList(:,2)) - boxThickness;
    rowIdUp = max(identifiedStructures(structureId).PixelList(:,2)) + boxThickness;
    colIdLeft = min(identifiedStructures(structureId).PixelList(:,1)) - boxThickness;
    colIdRight = max(identifiedStructures(structureId).PixelList(:,1)) + boxThickness;
    for drawCycle = 1 : boxThickness
        image([rowIdDown - drawCycle , rowIdUp + drawCycle],...
            colIdLeft - drawCycle : colIdRight  + drawCycle) = boxColor;
        image(rowIdDown - drawCycle : rowIdUp + drawCycle,...
            [colIdLeft - drawCycle , colIdRight + drawCycle]) = boxColor;
    end
end

% producing an outlined image
tempImage = image;
tempImage(outline) = boxColor;
imageOutlined = tempImage;
end
