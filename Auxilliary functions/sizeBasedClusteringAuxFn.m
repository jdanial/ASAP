function [clusterNum,clusteredStructures] = sizeBasedClusteringAuxFn(image,maxStructureSize)
% sizeBasedClusteringAuxFn - (Auxillary function)
% displays a super resolved image in a new figure.
%
% Syntax -
% sizeBasedClusteringAuxFn(image,maxStructureSize)
%
% Parameters -
% - image: 2D matrix of a super resolved image.
% - maxStructureSize: maximum size of the structures (in pixels)

%% initializing clusteredStructures
clusteredStructures = struct;

%% converting image to a 1 - 0 integer
for rowId = 1 : size(image,1)
    for colId = 1 : size(image,2)
        if image(rowId,colId) > 0
            image(rowId,colId) = 1;
        end
    end
end

%% finding non-zero pixels
[rowIds,colIds] = find(image);

%% initializing local- and global- cluster IDs
localClusterId = 3;
globalClusterId = 1;
for pixelId = 1 : length(rowIds)
    largestNumPixels = 0;
    if image(rowIds(pixelId),colIds(pixelId)) == 1
        for subRowId = max([1 rowIds(pixelId) - maxStructureSize]) : (maxStructureSize / 5) : rowIds(pixelId)
            for subColId = max([1 colIds(pixelId) - maxStructureSize]) : (maxStructureSize / 5) : colIds(pixelId)
                try
                    numPixels = length(find(image(subRowId : subRowId + maxStructureSize,subColId : subColId + maxStructureSize) == 1));
                    if numPixels > largestNumPixels
                        boxRowId = round(subRowId);
                        boxColId = round(subColId);
                        largestNumPixels = numPixels;
                    end
                catch
                end
            end
        end
        [pixelRowIds,pixelColIds] = find(image(boxRowId : boxRowId + maxStructureSize,...
            boxColId : boxColId + maxStructureSize) == 1);
        for subPixelId = 1 : length(pixelRowIds)
            image(pixelRowIds(subPixelId) + boxRowId - 1,pixelColIds(subPixelId) + boxColId - 1) = localClusterId;
        end
        clusteredStructures(globalClusterId).PixelList = [pixelRowIds + boxRowId - 1 pixelColIds + boxColId - 1];
        localClusterId = localClusterId + 1;
        globalClusterId = globalClusterId + 1;
    end
end

%% assigning number of clusters
clusterNum = globalClusterId - 1;
end
