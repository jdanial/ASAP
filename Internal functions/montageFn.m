function returnFlag = montageFn(app)
% montageFn() -
% dsiplays a gallery of the user-selected structures in a montage.
%
% Syntax -
% montageFn(app)
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
        montagingData = app.pr_montagingData;
        imageSize = str2double(montagingData.imageSize);
        fontSize = str2double(montagingData.fontSize);
    otherwise
        montagingData = app.pr_montagingParam;
        imageSize = montagingData.imageSize;
        fontSize = montagingData.fontSize;
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: montaging started.')];
drawnow;

%% initializing gallery
totalRows = 0;
totalCols = 0;
switch app.pr_entryPoint
    case 'UI'
        for imageId = 1 : length(montagingData.image)
            totalRows = max([totalRows str2double(montagingData.image(imageId).rowNum) * montagingData.image(imageId).include]);
            totalCols = max([totalCols str2double(montagingData.image(imageId).colNum) * montagingData.image(imageId).include]);
        end
    otherwise
        numImages = montagingData.numImages;
        rowNum = montagingData.rowNum;
        totalRows = rowNum;
        totalCols = ceil(numImages / montagingData.rowNum);
end

%% resizing image
borderSize = round(0.1 * imageSize);
pixels = get(0,'screensize');
height = totalRows * (imageSize + borderSize) + borderSize + 1;
width = totalCols * (imageSize + borderSize) + borderSize + 1;
if (1.5 * height > pixels(4)) || (1.5 * width > pixels(3))
    imageSize = round(imageSize /...
        (1.5 * max([height / pixels(4) width / pixels(3)])));
    borderSize = round(0.1 * imageSize);
end

%% recalculating image parameters
height = totalRows * (imageSize + borderSize) + borderSize + 1;
width = totalCols * (imageSize + borderSize) + borderSize + 1;
gallery = ones(height,width) .* 255;

%% organizing images in gallery
for imageId = 1 : length(montagingData.image)
    switch app.pr_entryPoint
        case 'Script'
            montagingData.image(imageId).include = true;
    end
    
    if montagingData.image(imageId).include
        
        %% extracting fileID and structureId
        fileId = montagingData.image(imageId).file;
        switch app.pr_entryPoint
            case 'UI'
                structureIds = montagingData.image(imageId).structureIds;
                structureId = montagingData.image(imageId).structureId;
            otherwise
                if montagingData.image(imageId).includeBinned
                    structureIds = find(strcmp(montagingData.image(imageId).shape,app.pr_structuresData.file(fileId).shapes));
                else
                    structureIds = find(strcmp(montagingData.image(imageId).shape,app.pr_structuresData.file(fileId).shapes) &...
                        ~app.pr_structuresData.file(fileId).binned);
                end
                if length(structureIds) < montagingData.numImages
                    returnFlag = true;
                    app.MsgBox.Value = [app.MsgBox.Value ;...
                        sprintf('%s','ASAP error 30: number of filtered structures is smaller than number of images.')];
                    return;
                end
                while true
                    structureId = round(1 + (length(structureIds) - 1) * rand(1,1));
                    structureId = max([1 structureId]);
                    structureId = min([length(structureIds) structureId]);
                    try
                        if ~ismember(structureId,visitedId{fileId})
                            visitedId{fileId} = [visitedId{fileId} structureId];
                            break;
                        end
                    catch
                        visitedId{fileId} = structureId;
                        break;
                    end
                end
                montagingData.image(imageId).structureIds = structureIds;
                montagingData.image(imageId).structureId = structureId;
        end
        
        %% extracting scale
        scale = montagingData.image(imageId).scale;
        
        %% extracting rowNum and colNum
        switch app.pr_entryPoint
            case 'UI'
                rowNum = str2double(montagingData.image(imageId).rowNum);
                colNum = str2double(montagingData.image(imageId).colNum);
            otherwise
                rowNum = montagingData.rowNum;
                if rowNum == 0
                    colNum = floor(imageId / sqrt(numImages)) + 1;
                    rowNum = mod(imageId,floor(numImages));
                else
                    colNum = floor((imageId - 1) / rowNum) + 1;
                    if mod(imageId,rowNum) ~= 0
                        rowNum = mod(imageId,rowNum);
                    end
                end
                montagingData.image(imageId).rowNum = rowNum;
                montagingData.image(imageId).colNum = colNum;
        end
        
        %% extracting and rescaling image
        image = app.pr_structuresData.file(fileId).identifiedStructures(structureIds(structureId)).rawStructure;
        particleImageTemp = imresize(image,[NaN imageSize],'nearest');
        if size(particleImageTemp,1) > imageSize
            particleImageTemp = imrotate(imresize(image,[imageSize NaN],'nearest'),90);
        end
        particleImage = zeros(imageSize);
        particleImage(round(imageSize / 2 - size(particleImageTemp,1) / 2 + 1) : ...
            round(imageSize / 2 + size(particleImageTemp,1) / 2), ...
            round(imageSize / 2 - size(particleImageTemp,2) / 2 + 1): ...
            round(imageSize / 2 + size(particleImageTemp,2) / 2)) = particleImageTemp;
        imageSize_0 = size(image,2);
        particleImage = particleImage .* (255 / max(particleImage(:)));
        
        %% adding scale bar
        if scale ~= 0
            try
                pixelSize = app.pr_structuresData.file(fileId).pixelSize;
                scaleBar = (scale / pixelSize) * (imageSize / imageSize_0);
                particleImage(imageSize - borderSize : imageSize - 0.5 * borderSize,...
                    imageSize - 0.5 * borderSize - scaleBar : imageSize - 0.5 * borderSize) = 255;
            catch
                returnFlag = true;
                app.MsgBox.Value = [app.MsgBox.Value ;...
                    sprintf('%s',['ASAP error 29: scale bar exceeds the size of image (' num2str(imageId) ').'])];
                return;
            end
        end
        
        %% inserting image into gallery
        startRow = borderSize + 1 + (rowNum - 1) * (imageSize + borderSize);
        endRow = (imageSize + borderSize) + (rowNum - 1) * (imageSize + borderSize);
        startCol = borderSize + 1 + (colNum - 1) * (imageSize + borderSize);
        endCol = (imageSize + borderSize) + (colNum - 1) * (imageSize + borderSize);
        gallery(startRow : endRow,startCol : endCol) = particleImage;
    end
end

%% creating new figure
fig = figure('units','pixels',...
    'MenuBar','none',...
    'ToolBar','none',...
    'Resize','off',...
    'InvertHardCopy','off',...
    'Name','Leave open for export');
movegui(fig,'center');

%% modifying color map and displaying image
colorMap = hot(255);
imshow(gallery,colorMap);

%% adding text
ax = gca;
for imageId = 1 : length(montagingData.image)
    switch app.pr_entryPoint
        case 'Script'
            montagingData.image(imageId).include = true;
    end
    if montagingData.image(imageId).include
        
        %% extracting rowNum and colNum
        rowNum = str2double(montagingData.image(imageId).rowNum);
        colNum = str2double(montagingData.image(imageId).colNum);
        
        %% extracting label
        label = montagingData.image(imageId).label;
        
        %% adding label
        if ~isempty(label)
            colPos = borderSize + 1 + (colNum - 1) * (imageSize + borderSize) + (0.5 * borderSize);
            rowPos = (imageSize + borderSize) + (totalRows - rowNum) * (imageSize + borderSize) - fontSize - (0.5 * borderSize);
            x = ruler2num(colPos,ax.XAxis);
            y = ruler2num(rowPos,ax.YAxis);
            text('units','pixels',...
                'position',[x y],...
                'fontsize',fontSize,...
                'string',label,...
                'Color','white',...
                'FontName','Arial',...
                'VerticalAlignment','baseline');
        end
    end
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: montaging complete.')];
drawnow;
