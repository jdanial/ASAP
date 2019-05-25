function retProp = getPropFnAux(structureColor,structureBW,property)
% getPropFnAux - (Auxillary function)
% queries an input geometrical property for a structure
%
% Syntax - 
% getPropFnAux(structureColor,structureBW,property)
%
% Parameters -
% - 'structureColor': gray scale image of a structure.
% - 'structureBW': binary image of a structure.
% - 'property': property to be queried.  

switch property
    case {'Area','FilledArea','ConvexArea','Perimeter','EulerNumber', ...
            'Eccentricity','Solidity','Orientation','Extent', ...
            'MajorAxisLength','MinorAxisLength'}
        retPropTemp = regionprops(structureBW,property);
        retProp = retPropTemp.(property);
    case 'FormFactor'
        perimeterTemp = regionprops(structureBW,'Perimeter');
        perimeter = perimeterTemp.('Perimeter');
        areaTemp = regionprops(structureBW,'Area');
        area = areaTemp.('Area');
        retProp = 4 * area / (perimeter ^ 2);
    case 'Roundness'
        majorAxisLengthTemp = regionprops(structureBW,'MajorAxisLength');
        majorAxisLength = majorAxisLengthTemp.('MajorAxisLength');
        areaTemp = regionprops(structureBW,'Area');
        area = areaTemp.('Area');
        retProp = 4 * area / (majorAxisLength ^ 2);        
    case 'Elongation'
        majorAxisLengthTemp = regionprops(structureBW,'MajorAxisLength');
        majorAxisLength = majorAxisLengthTemp.('MajorAxisLength');
        minorAxisLengthTemp = regionprops(structureBW,'MinorAxisLength');
        minorAxisLength = minorAxisLengthTemp.('MinorAxisLength');
        retProp = majorAxisLength / minorAxisLength;
    case 'Rectangularity'
        boundingBoxTemp = regionprops(structureBW,'BoundingBox');
        boundingBox = boundingBoxTemp.('BoundingBox');
        xLength = boundingBox(3);
        yLength = boundingBox(4);
        areaTemp = regionprops(structureBW,'Area');
        area = areaTemp.('Area');
        retProp = area / (xLength * yLength);          
    case 'FillRatio'
        majorAxisLengthTemp = regionprops(structureBW,'MajorAxisLength');
        majorAxisLength = majorAxisLengthTemp.('MajorAxisLength');
        minorAxisLengthTemp = regionprops(structureBW,'MinorAxisLength');
        minorAxisLength = minorAxisLengthTemp.('MinorAxisLength');
        ellipseArea = pi * majorAxisLength * minorAxisLength / 4;
        filledAreaTemp = regionprops(structureBW,'FilledArea');
        filledArea = filledAreaTemp.('FilledArea');
        retProp = filledArea / ellipseArea;
    case 'MeanIntensity'
        structureColorPositive = structureColor(structureColor > 0);
        retProp = mean(structureColorPositive(:));
    case 'MinimaNumber'
        regionalMinima = bwconncomp(imclearborder(imregionalmin(structureColor,8)));
        retProp = regionalMinima.NumObjects;
    case 'MinimaIntensity'
        regionalMinima = bwconncomp(imclearborder(imregionalmin(structureColor,8)));
        if regionalMinima.NumObjects > 0
            retPropTemp = int16(imregionalmin(structureColor,8)) .* int16(structureColor);
            retProp = mean(retPropTemp(:));
        else
            retProp = 0;
        end        
    case 'MinimaEccentricity'
        regionalMinima = bwconncomp(imclearborder(imregionalmin(structureColor,8)));
        if regionalMinima.NumObjects > 0
            retPropTemp = regionprops(regionalMinima,'Eccentricity');
            retProp = mean([retPropTemp.Eccentricity]);
        else
            retProp = 0;
        end
    case 'MinimaArea'
        regionalMinima = bwconncomp(imclearborder(imregionalmin(structureColor,8)));
        if regionalMinima.NumObjects > 0
            retPropTemp = regionprops(regionalMinima,'Area');
            retProp = sum([retPropTemp.Area]);
        else
            retProp = 0;
        end
    case 'MinimaConvexArea'
        regionalMinima = bwconncomp(imclearborder(imregionalmin(structureColor,8)));
        if regionalMinima.NumObjects > 0
            retPropTemp = regionprops(regionalMinima,'ConvexArea');
            retProp = sum([retPropTemp.ConvexArea]);
        else
            retProp = 0;
        end
    case 'MaximaNumber'
        regionalMaxima = bwconncomp(imclearborder(imregionalmax(structureColor,8)));
        retProp = regionalMaxima.NumObjects;
    case 'MaximaIntensity'
        regionalMaxima = bwconncomp(imclearborder(imregionalmax(structureColor,8)));
        if regionalMaxima.NumObjects > 0
            retPropTemp = int16(imregionalmax(structureColor,8)) .* int16(structureColor);
            retProp = mean(retPropTemp(:));
        else
            retProp = 0;
        end          
    case 'MaximaEccentricity'
        regionalMaxima = bwconncomp(imclearborder(imregionalmax(structureColor,8)));
        if regionalMaxima.NumObjects > 0
            retPropTemp = regionprops(regionalMaxima,'Eccentricity');
            retProp = mean([retPropTemp.Eccentricity]);
        else
            retProp = 0;
        end
    case 'MaximaArea'
        regionalMaxima = bwconncomp(imclearborder(imregionalmax(structureColor,8)));
        if regionalMaxima.NumObjects > 0
            retPropTemp = regionprops(regionalMaxima,'Area');
            retProp = sum([retPropTemp.Area]);
        else
            retProp = 0;
        end
    case 'MaximaConvexArea'
        regionalMaxima = bwconncomp(imclearborder(imregionalmax(structureColor,8)));
        if regionalMaxima.NumObjects > 0
            retPropTemp = regionprops(regionalMaxima,'ConvexArea');
            retProp = sum([retPropTemp.ConvexArea]);
        else
            retProp = 0;
        end
    case {'SegmentTotalLength','SegmentNumberIntersections',...
            'SegmentLength','SegmentOrientation','SegmentRadius'}
        structureBWSkeleton = bwskel(structureBW);
        lines = pixLinFnExt(structureBWSkeleton,'0');
        lineLengths = zeros(1,numel(lines));
        lineOrientations = zeros(1,numel(lines));
        for lineIndex = 1 : numel(lines)
            lineLengths(1,lineIndex) = size(lines{lineIndex},1);
            lineOrientations(1,lineIndex) = atan2(lines{lineIndex}(1,1) - lines{lineIndex}(end,1),lines{lineIndex}(1,2) - lines{lineIndex}(end,2));
        end
        if strcmp(property,'SegmentTotalLength')
            retProp = sum(structureBWSkeleton(:));
        elseif strcmp(property,'SegmentNumberIntersections')
            retProp = size(segIntFnExt(structureBWSkeleton),1);
        elseif strcmp(property,'SegmentLength')
            retProp = mean(lineLengths);
        elseif strcmp(property,'SegmentOrientation')
            retProp = mean(lineOrientations);
        elseif strcmp(property,'SegmentRadius')
            retProp = mean(reshape(bwdist(~structureBW) .* structureBWSkeleton,1,[]));
        end
end
end