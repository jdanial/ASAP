function returnFlag = analyzeFn(app)
% analyzeFn() -
% geometrical analysis of classified structures.
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

%% reading file list
switch app.pr_entryPoint
    case 'UI'
        listBoxHandle = app.ListBox3_1;
        inputFiles = readListBoxAuxFn(listBoxHandle,app.pr_fileList);
    otherwise
        inputFiles = app.pr_fileList;
end

%% extracting number of files
numFiles = numel(inputFiles);

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: analysis started.')];
drawnow;

%% initializing imageId
imageId = 1;

for fileId = 1 : numFiles
    
    %% reading module parameters
    switch app.pr_entryPoint
        case 'UI'
            pixelSize = app.PixelSizeEditField3_1.Value;
            analysisPlatform = app.DropDown3_1.Value;
            analysisMode = app.ListBox3_2.Value;
            maxRingSize = app.MaxRingSizeEditField3_1.Value;
            operations = app.ListBox3_3.Value;
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
            pixelSize = app.pr_analysisParam.file(fileId).pixelSize;
            analysisPlatform = app.pr_analysisParam.file(fileId).analysisPlatform;
            analysisMode = app.pr_analysisParam.file(fileId).analysisMode;
            maxRingSize = app.pr_analysisParam.file(fileId).maxRingSize;
            operations = app.pr_analysisParam.file(fileId).operations;
    end
    
    %% setting up ASAP progress
    message = app.MsgBox.Value;
    message{end} = ['ASAP progress: analyzing structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
    app.MsgBox.Value = message;
    drawnow;
    
    %% initializing pixel sizes
    pixelLength = pixelSize;
    pixelArea = pixelSize ^ 2;
    
    %% allocating structuresData to a GPU array
    if strcmp(analysisPlatform,'GPU')
        structuresData = gpuArray(app.pr_structuresData.file(fileId));
    else
        structuresData = app.pr_structuresData.file(fileId);
    end
    
    %% reading number of structures
    numStructures = numel(structuresData.identifiedStructures);
    
    %% initializing structureProps
    structureProps = cell(numStructures,1);
    
    %% extracting structureData
    identifiedStructures = structuresData.identifiedStructures;
    
    parfor structureId = 1 : numStructures

        %% selecting a structure in an image according to its ID
        xPosList = identifiedStructures(structureId).PixelList(:,1);
        yPosList = identifiedStructures(structureId).PixelList(:,2);
        binaryStructure = identifiedStructures(structureId).binaryStructure;
        rawStructure = identifiedStructures(structureId).rawStructure;
        
        %% calculating centroid
        [rowList,colList] = find(binaryStructure > 0);
        tot_mass = sum(double(rawStructure(:)));
        [rowGrid,colGrid] = ndgrid(1:size(rawStructure,1),1:size(rawStructure,2));
        rowCentroid = sum(double(rowGrid(:)) .* double(rawStructure(:))) ./ tot_mass;
        colCentroid = sum(double(colGrid(:)) .* double(rawStructure(:))) ./ tot_mass;
        
        %% applying operations
        for operationId = 1 : numel(operations)
            switch operations{operationId}
                case {'Fill';'Bridge';'Close';'Open';'Clean'}
                    
                    %% performing morphological operations
                    binaryStructure = bwmorph(binaryStructure,...
                        lower(operations{operationId}));
                    
                case 'Rotate'
                    
                    %% rotating structure to align major with x axis
                    orientations = atan2d(-(rowList - rowCentroid),(colList - colCentroid));
                    for orientationId = 1 : length(orientations)
                        if orientations(orientationId) < -5
                            orientations(orientationId) = 180 + orientations(orientationId);
                        end
                    end
                    orientation = median(orientations);
                    rawStructure = imrotate(rawStructure,-orientation);
                    binaryStructure = imrotate(binaryStructure,-orientation);
                    
                case 'Center'
                    
                    %% centering structure at centroid
                    colTranslation = (size(rawStructure,2) / 2) - colCentroid;
                    rowTranslation = (size(rawStructure,1) / 2) - rowCentroid;
                    rawStructure = imtranslate(rawStructure,[colTranslation , rowTranslation],'FillValues',0,'OutputView','full');
                    binaryStructure = imtranslate(binaryStructure,[colTranslation , rowTranslation],'FillValues',0,'OutputView','full');
                    
                case 'Resize'
                    
                    %% resizing structure to have the size of 30 x 30 px
                    rawStructure = imresize(rawStructure,[NaN 30]);
                    binaryStructure = imresize(binaryStructure,[NaN 30]);
            end
        end
        
        %% calling GetProperties to query for all shape descriptors
        structureProps{structureId} =...
            GetProperties(rawStructure,binaryStructure,xPosList,yPosList,...
            analysisMode,pixelLength,pixelArea,rowList,colList,rowCentroid,...
            colCentroid,maxRingSize);
    end
    %% tranferring 'structuresData' to a UI class array
    if strcmp(analysisPlatform,'GPU')
        app.pr_structuresData.file(imageId) = gather(structuresData);
    else
        app.pr_structuresData.file(imageId).dimensions = structureProps;
        app.pr_structuresData.file(imageId).binned = false(1,numStructures);
        app.pr_structuresData.file(imageId).analysisMode = analysisMode;
        app.pr_structuresData.file(imageId).descriptors = GetDescriptors(analysisMode);
        app.pr_structuresData.file(imageId).pixelSize = pixelLength;
        app.pr_structuresData.file(imageId).function = 'analyzed';
    end
    imageId = imageId + 1;
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: analysis complete.')];
drawnow;
end

%%====================GetProperties=====================%%
function retProps = GetProperties(rawStructure,binaryStructure,xPosList,yPosList,analysisMode,pixelLength,pixelArea,rowList,colList,rowCentroid,colCentroid,maxRingSize)
for analysisModeId = 1 : numel(analysisMode)
    if strcmp(analysisMode{analysisModeId},'Pixel counting')
        
        % calculating properties by pixel counting
        retPropTemp = regionprops(binaryStructure,'Area');
        retProps.Area = sum([retPropTemp.Area]) * (pixelArea);
        retPropTemp = regionprops(binaryStructure,'FilledArea');
        retProps.FilledArea = sum([retPropTemp.FilledArea]) * (pixelArea);
        retPropTemp = regionprops(binaryStructure,'ConvexArea');
        retProps.ConvexArea = sum([retPropTemp.ConvexArea]) * (pixelArea);
        retPropTemp = regionprops(binaryStructure,'Perimeter');
        retProps.Perimeter = sum([retPropTemp.Perimeter]) * (pixelLength);
        retPropTemp = regionprops(binaryStructure,'EulerNumber');
        retProps.EulerNumber = sum([retPropTemp.EulerNumber]);
        retPropTemp = regionprops(binaryStructure,'Eccentricity');
        retProps.Eccentricity = sum([retPropTemp.Eccentricity]);
        retPropTemp = regionprops(binaryStructure,'Solidity');
        retProps.Solidity = sum([retPropTemp.Solidity]);
        retPropTemp = regionprops(binaryStructure,'Orientation');
        retProps.Orientation = sum([retPropTemp.Orientation]);
        retPropTemp = regionprops(binaryStructure,'Extent');
        retProps.Extent = sum([retPropTemp.Extent]);
        retPropTemp = regionprops(binaryStructure,'MajorAxisLength');
        retProps.MajorAxisLength = sum([retPropTemp.MajorAxisLength]) * (pixelLength);
        retPropTemp = regionprops(binaryStructure,'MinorAxisLength');
        retProps.MinorAxisLength = sum([retPropTemp.MinorAxisLength]) * (pixelLength);
        retProps.FormFactor = 4 * retProps.Area / (retProps.Perimeter ^ 2);
        retProps.Roundness = 4 * retProps.Area / (retProps.MajorAxisLength ^ 2);
        retProps.Elongation = retProps.MajorAxisLength / retProps.MinorAxisLength;
        retProps.FillRatio = retProps.FilledArea / (pi * retProps.MajorAxisLength * retProps.MinorAxisLength / 4);
        rawStructurePositive = rawStructure(rawStructure > 0);
        retProps.MeanIntensity = mean(rawStructurePositive(:));
        regionalMinima = bwconncomp(imclearborder(imregionalmin(rawStructure,8)));
        retProps.MinimaNumber = regionalMinima.NumObjects;
        if regionalMinima.NumObjects > 0
            retPropTemp = int16(imregionalmin(rawStructure,8)) .* int16(rawStructure);
            retProps.MinimaIntensity = mean(retPropTemp(:)) / max(rawStructure(:));
            retPropTemp = regionprops(regionalMinima,'Eccentricity');
            retProps.MinimaEccentricity = mean([retPropTemp.Eccentricity]);
            retPropTemp = regionprops(regionalMinima,'Area');
            retProps.MinimaArea = sum([retPropTemp.Area]) * (pixelArea);
            retPropTemp = regionprops(regionalMinima,'ConvexArea');
            retProps.MinimaConvexArea = sum([retPropTemp.ConvexArea]) * (pixelArea);
        else
            retProps.MinimaIntensity = 0;
            retProps.MinimaEccentricity = 0;
            retProps.MinimaArea = 0;
            retProps.MinimaConvexArea = 0;
        end
        regionalMaxima = bwconncomp(imclearborder(imregionalmax(rawStructure,8)));
        retProps.MaximaNumber = regionalMaxima.NumObjects;
        if regionalMaxima.NumObjects > 0
            retPropTemp = int16(imregionalmax(rawStructure,8)) .* int16(rawStructure);
            retProps.MaximaIntensity = mean(retPropTemp(:));
            retPropTemp = regionprops(regionalMaxima,'Eccentricity');
            retProps.MaximaEccentricity = mean([retPropTemp.Eccentricity]);
            retPropTemp = regionprops(regionalMaxima,'Area');
            retProps.MaximaArea = sum([retPropTemp.Area]) * (pixelArea);
            retPropTemp = regionprops(regionalMaxima,'ConvexArea');
            retProps.MaximaConvexArea = sum([retPropTemp.ConvexArea]) * (pixelArea);
        else
            retProps.MaximaIntensity = 0;
            retProps.MaximaEccentricity = 0;
            retProps.MaximaArea = 0;
            retProps.MaximaConvexArea = 0;
        end
        binaryStructureSkeleton = bwskel(binaryStructure);
        retProps.SegmentTotalLength = sum(binaryStructureSkeleton(:)) * (pixelLength);
        retProps.SegmentNumberIntersections = size(segIntFnExt(binaryStructureSkeleton),1);
        retPropTemp = bwconncomp(binaryStructure);
        retProps.Objects = retPropTemp.NumObjects;
    elseif strcmp(analysisMode{analysisModeId},'Ellipse fitting')
        
        % calculating properties by ellipse fitting
        ellipse = ellifitFnExt(xPosList,yPosList);
        if ~isempty(ellipse.long_axis)
            retProps.MajorAxisLengthFit = ellipse.long_axis * pixelLength;
            retProps.MinorAxisLengthFit = ellipse.short_axis * pixelLength;
            retProps.ElongationFit = retProps.MajorAxisLengthFit / retProps.MinorAxisLengthFit;
            xCentroid = ellipse.X0_in;
            yCentroid = ellipse.Y0_in;
            xImageCenter = (max(xPosList) + min(xPosList)) / 2;
            yImageCenter = (max(yPosList) + min(yPosList)) / 2;
            retProps.RelativeCentroid = sqrt((xCentroid - xImageCenter) ^ 2 + (yCentroid - yImageCenter) ^ 2);
            retProps.OrientationFit = ellipse.phi * (180 / pi);
        else
            retProps.MajorAxisLengthFit = 0;
            retProps.MinorAxisLengthFit = 0;
            retProps.ElongationFit = 0;
            retProps.RelativeCentroid = 0;
            retProps.OrientationFit = 0;
        end
    else
        
        % calculating properties by radial profiling
        distList = sqrt((rowList - rowCentroid) .^ 2 + (colList - colCentroid) .^ 2);
        index = 1;
        step = 1;
        for maxRingSize = step : step : maxRingSize
            minRingSize = maxRingSize - step;
            radialProfile(index) = double(0);
            radialDensityProfile(index) = double(0);
            count = 0;
            for posId = 1 : length(rowList)
                if distList(posId) < maxRingSize && distList(posId) >= minRingSize
                    radialProfile(index) = double(radialProfile(index)) + ...
                        double(rawStructure(rowList(posId),colList(posId)));
                    count = count + 1;
                end
            end
            if count ~= 0
                radialDensityProfile(index) = radialProfile(index) / count;
            end
            index = index + 1;
        end
        retProps.RawRadialProfile = radialProfile;
        retProps.IntensityNormalizedRadialProfile = radialProfile / max(radialProfile);
        retProps.AreaNormalizedRadialProfile = radialProfile / sum(radialProfile);
        retProps.RawRadialDensityProfile = radialDensityProfile;
        retProps.IntensityNormalizedRadialDensityProfile = radialDensityProfile / max(radialDensityProfile);
        retProps.AreaNormalizedRadialDensityProfile = radialDensityProfile / sum(radialDensityProfile);
    end
end
end

%%====================GetDescriptors=====================%%
function retDescriptors = GetDescriptors(analysisMode)
for analysisModeId = 1 : numel(analysisMode)
    try
        retDescriptors = [retDescriptors; constantFetcherFn('shapeDescriptor',analysisMode{analysisModeId},'y')'];
    catch
        retDescriptors = constantFetcherFn('shapeDescriptor',analysisMode{analysisModeId},'y')';
    end
end
end
