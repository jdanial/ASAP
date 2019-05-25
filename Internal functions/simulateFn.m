function returnFlag = simulateFn(app)
% simulateFn() -
% simulates super resolved images for analysis using ASAP.
%
% Syntax -
% simulateFn(app,entryPoint,exportPath,fileList)
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
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 12: no path is selected.')];
    return;
end
if isempty(app.pr_fileList)
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 13: no image files available.')];
    return;
end
switch app.pr_entryPoint
    case 'UI'
        inputFiles = readListBoxAuxFn(app.ListBox1_1,app.pr_fileList);
        if isempty(inputFiles)
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 14: no image files selected.')];
            return;
        end
    otherwise
        inputFiles = app.pr_fileList;
        if isempty(inputFiles)
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 13: no image files available.')];
            return;
        end
end

%% reading number of files
numFiles = numel(inputFiles);

%% setting margin
margin = 5;

%% displaying simulation re-run message
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: simulation started.')];
drawnow;

%% looping through files
for fileId = 1 : numFiles
    
    %% reading blinking particles parameters
    switch app.pr_entryPoint
        case 'UI'
            selectedTab = app.SimulateTypeTab.SelectedTab;
            simulationMode = selectedTab.Title;
            switch selectedTab.Title
                case 'Random'
                    numFluorophore = app.FluorophoreEditField1_1.Value * 1000;
                    numCycle = app.BlinkingCycleEditField1_1.Value;
                    photonCount = app.PhotonCountEditField1_1.Value;
                    labelLength = app.LabelLengthEditField1_1.Value;
                    lateralPrecision = app.LateralPrecisionEditField1_1.Value;
                    pixelSize = app.PixelSizeField1_1.Value;
                    segment = app.SegmentCheckBox1_1.Value;
                    segmentationLevel = round(app.LevelEditField1_1.Value);
                case 'Structured'
                    numEpitope = app.EpitopesEditField1_1.Value;
                    numCycle = app.BlinkingCycleEditField1_2.Value;
                    photonCount = app.PhotonCountEditField1_2.Value;
                    numStructure = app.StructuresEditField1_1.Value;
                    structureSize = app.StructureSizeEditField1_1.Value;
                    labelLength = app.LabelLengthEditField1_2.Value;
                    labelingEfficiency = app.LabelingEfficiencyEditField1_1.Value;
                    lateralPrecision = app.LateralPrecisionEditField1_2.Value;
                    pixelSize = app.PixelSizeEditField1_2.Value;
                    rotationEnabled = app.RotationEnabledCheckBox1_1.Value;
                    segment = app.segmentCellCheckBox1_2.Value;
                    segmentationLevel = round(app.LevelEditField1_2.Value);
            end
        otherwise
            simulationMode = app.pr_simulationParam.file(fileId).simulationMode;
            switch simulationMode
                case 'Random'
                    numFluorophore = app.pr_simulationParam.file(fileId).numFluorophore * 1000;
                    numCycle = app.pr_simulationParam.file(fileId).numCycle;
                    photonCount = app.pr_simulationParam.file(fileId).photonCount;
                    labelLength = app.pr_simulationParam.file(fileId).labelLength;
                    lateralPrecision = pr_app.simulationParam.file(fileId).lateralPrecision;
                    pixelSize = app.pr_simulationParam.file(fileId).pixelSize;
                    segment = app.pr_simulationParam.file(fileId).segment;
                    segmentationLevel =app.pr_simulationParam.file(fileId).segmentationLevel;
                case 'Structured'
                    numEpitope = app.pr_simulationParam.file(fileId).numEpitope;
                    numCycle = app.pr_simulationParam.file(fileId).numCycle;
                    photonCount = app.pr_simulationParam.file(fileId).photonCount;
                    numStructure = app.pr_simulationParam.file(fileId).numStructure;
                    structureSize = app.pr_simulationParam.file(fileId).structureSize;
                    labelLength = app.pr_simulationParam.file(fileId).labelLength;
                    labelingEfficiency = app.pr_simulationParam.file(fileId).labelingEfficiency;
                    lateralPrecision = app.pr_simulationParam.file(fileId).lateralPrecision;
                    pixelSize = app.pr_simulationParam.file(fileId).pixelSize;
                    rotationEnabled = app.pr_simulationParam.file(fileId).rotationEnabled;
                    segment = strcmp(app.pr_simulationParam.file(fileId).segment,'true');
                    segmentationLevel = app.pr_simulationParam.file(fileId).segmentationLevel;
            end
    end
    
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
    
    %% sample segmentation
    if segment
        segmentedImage = imageSegmentorAuxFn(image,segmentationLevel);
    else
        segmentedImage = ones(size(image));
    end
    
    %% setting up ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: simulating file ' num2str(fileId) ' out of ' num2str(numFiles) '. Generating positions.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% calling PositionGenerator
    switch simulationMode
        case 'Random'
            [returnFlag,frameCoor_x,frameCoor_y] = PositionGenerator(simulationMode,segmentedImage,pixelSize,margin,numFluorophore);
        case 'Structured'
            [returnFlag,frameCoor_x,frameCoor_y] = PositionGenerator(simulationMode,segmentedImage,pixelSize,margin,numEpitope,numStructure,structureSize,rotationEnabled);
    end
    
    %% displaying ASAP error if position generator fails to generate coordinates
    if returnFlag
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s',['ASAP error 15: no position coordinates were generated for file (' fileName ').'])];
        return;
    end
    
    %% displaying ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: simulating file ' num2str(fileId) ' out of ' num2str(numFiles) '. Generating image.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% calling ImageGenerator
    switch simulationMode
        case 'Random'
            [returnFlag,simulatedImage] = ImageGenerator(simulationMode,segmentedImage,margin,pixelSize,frameCoor_x,frameCoor_y,labelLength,lateralPrecision,photonCount,numCycle);
        case 'Structured'
            [returnFlag,simulatedImage] = ImageGenerator(simulationMode,segmentedImage,margin,pixelSize,frameCoor_x,frameCoor_y,labelLength,lateralPrecision,photonCount,numCycle,labelingEfficiency);
    end
    
    %% displaying ASAP error if image generator fails to generate an image
    if returnFlag
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s',['ASAP error 16: cannot simulate image file (' fileName ').'])];
        return;
    end
    
    %% saving image
    exportFileName = ['Simulated_image_' erase(fileName,{'.png','.jpg','.tif'}) '.tif'];
    try
        imwrite(uint16(simulatedImage),exportFileName,'WriteMode','overwrite');
    catch
        returnFlag = true;
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s','ASAP error 17: cannot write simulated image to disk.')];
        return;
    end
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: simulation complete.')];
drawnow;
end

%%====================PositionGenerator=====================%%
function [returnFlag,frameCoor_x,frameCoor_y] = PositionGenerator(simulationMode,segmentedImage,pixelSize,margin,varargin)

% initializing returnFlag
returnFlag = false;

% extracting number of rows and cols in segmentedImage
[numRows,numCols] = size(segmentedImage);

% checking simulation mode
switch simulationMode
    case 'Random'
        
        % reading arguments from varargin
        numFluorophore = varargin{1};
        
        % prelocating frameCoor_x and frameCoor_y
        frameCoor_x = zeros(numFluorophore,1);
        frameCoor_y = zeros(numFluorophore,1);
        
        % looping through structures
        for fluorophoreId = 1 : numFluorophore
            
            % generating random position across sample
            positionValid = false;
            while ~positionValid
                randCol = 1 + (numCols - 1) * rand;
                randRow = 1 + (numRows - 1) * rand;
                if segmentedImage(round(randRow),round(randCol)) && ...
                        randCol <= numCols - (2 * margin) && randCol >= 1 + (2 * margin) && ...
                        randRow <= numRows - (2 * margin) && randRow >= 1 + (2 * margin)
                    positionValid = true;
                end
            end
            
            % assigning coordinates
            frameCoor_x(fluorophoreId) = randCol * pixelSize;
            frameCoor_y(fluorophoreId) = randRow * pixelSize;
        end
        
    case 'Structured'
        
        % reading arguments from varargin
        numEpitope = varargin{1};
        numStructure = varargin{2};
        structureSize = varargin{3};
        rotationEnabled = varargin{4};
        
        % prelocating frameCoor_x and frameCoor_y
        frameCoor_x = zeros(numStructure * numEpitope,1);
        frameCoor_y = zeros(numStructure * numEpitope,1);
        
        % resetting locId
        locId = 1;
        
        % looping through structures
        for structureId = 1 : numStructure
            
            % calculating rotation offset
            if rotationEnabled
                rotationOffset = 360 * rand;
            else
                rotationOffset = 0;
            end
            
            % generating random position across sample
            positionValid = false;
            while ~positionValid
                randCol = 1 + (numCols - 1) * rand;
                randRow = 1 + (numRows - 1) * rand;
                if segmentedImage(round(randRow),round(randCol)) && ...
                        randCol <= numCols - (2 * margin) - (structureSize / pixelSize) && randCol >= 1 + (2 * margin) + (structureSize / pixelSize) && ...
                        randRow <= numRows - (2 * margin) - (structureSize / pixelSize) && randRow >= 1 + (2 * margin) + (structureSize / pixelSize)
                    positionValid = true;
                end
            end
            
            % calculating x and y coordinates of frames
            for angleId = 1 : numEpitope
                frameCoor_x(locId) = ((structureSize / 2) * cosd((angleId - 1) * (360 / numEpitope) + rotationOffset)) + (randCol * pixelSize);
                frameCoor_y(locId) = ((structureSize / 2) * sind((angleId - 1) * (360 / numEpitope) + rotationOffset)) + (randRow * pixelSize);
                locId = locId + 1;
            end
        end
end

if isempty(frameCoor_x)
    returnFlag = true;
end
end

%%====================ImageGenerator=====================%%
function [returnFlag,simulatedImage] = ImageGenerator(simulationMode,segmentedImage,margin,pixelSize,frameCoor_x,frameCoor_y,labelLength,lateralPrecision,photonCount,numCycle,varargin)

% initializing returnFlag
returnFlag = false;

% initializing image
try
    simulatedImage = zeros(size(segmentedImage));
catch
    returnFlag = true;
    return;
end

% extracting number of locations
numLocs = length(frameCoor_x);

% generating labels vector
switch simulationMode
    case 'Random'
        labelVec = ones(numLocs,1);
    case 'Structured'
        labelingEfficiency = varargin{1};
        labelVec = round(rand(numLocs,1) + (labelingEfficiency - 0.5));
end

% looping through emission cycles
for cycleId = 1 : numCycle
    
    % generating labeling angles vector
    labelAngles = 360 .* rand(numLocs,1);
    
    % adding antibody and label length to frameCoor
    currentFrameCoor_x = ((frameCoor_x + (labelLength .* cosd(labelAngles))) ./ pixelSize);
    currentFrameCoor_y = ((frameCoor_y + (labelLength .* sind(labelAngles))) ./ pixelSize);
    
    % generating gaussian profiles
    for posId = 1 : numLocs
        if labelVec(posId)
            for xVal = round(currentFrameCoor_x(posId)) - margin : round(currentFrameCoor_x(posId)) + margin
                for yVal = round(currentFrameCoor_y(posId)) - margin : round(currentFrameCoor_y(posId)) + margin
                    try
                        simulatedImage(yVal,xVal) = simulatedImage(yVal,xVal) + ...
                            double(abs(photonCount * randn)) * double(exp(-((xVal - currentFrameCoor_x(posId)) ^ 2 + (yVal - currentFrameCoor_y(posId)) ^ 2) / (2 * (abs(lateralPrecision * randn) / pixelSize) ^ 2)));
                    catch
                        simulatedImage(yVal,xVal) = ...
                            double(abs(photonCount * randn)) * double(exp(-((xVal - currentFrameCoor_x(posId)) ^ 2 + (yVal - currentFrameCoor_y(posId)) ^ 2) / (2 * (abs(lateralPrecision * randn) / pixelSize) ^ 2)));
                    end
                end
            end
        end
    end
end
end
