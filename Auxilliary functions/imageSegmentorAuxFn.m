function segmentedImage = imageSegmentorAuxFn(image,segmentationLevel)
% imageSegmentorAuxFn - (Auxillary function)
% segments an image according to provided segmentationLevel
%
% Syntax -
% imageSegmentorAuxFn(image,segmentationLevel)
%
% Parameters -
% - image: 2D array of image to be segmented.
% - segmentationLevel: level of segmentation.

%% finding edges in input image
[~,threshold] = edge(image,'sobel');
fudgeFactor = 0.5;
edgedImage = edge(image,'sobel',threshold * fudgeFactor);

%% dilating segmenting regions
dilatedImage = imdilate(edgedImage,strel('sphere',segmentationLevel));

%% filling segmented regions
filledImage = imfill(dilatedImage,'holes');

%% taking largest area of segmented regions
props = regionprops(filledImage,'area');
maxArea = max([props.Area]);
segmentedRegion = bwareaopen(filledImage,maxArea);

%% creating convex hull
segmentedImage = bwconvhull(segmentedRegion);