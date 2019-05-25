function [ep, bp] = pixFinderFnExt(inputIm)

%vipPixelFinder is similar to bwmorph with 'endpoints' and 'branchpoints',
%but it is more accurate in its labeling in that it does not label pixels
%with 3 connectors as a branch point if unless the 3 connectors are also
%isolated from each other - also pixels with 7 on neighbors are not labeled
%as endpoints as in bwmorph

padIm = padarray(inputIm,[1 1]);

datacube = zeros(size(inputIm,1), size(inputIm,2), 8);

% 1 2 3
% 8 X 4
% 7 6 5

datacube(:,:,1) = padIm(1:end-2,1:end-2);
datacube(:,:,2) = padIm(1:end-2,2:end-1);
datacube(:,:,3) = padIm(1:end-2,3:end);
datacube(:,:,4) = padIm(2:end-1,3:end);
datacube(:,:,5) = padIm(3:end,3:end);
datacube(:,:,6) = padIm(3:end,2:end-1);
datacube(:,:,7) = padIm(3:end,1:end-2);
datacube(:,:,8) = padIm(2:end-1,1:end-2);

numNeighbors = inputIm.*sum(datacube,3);
numBranches =  inputIm.*sum(abs(datacube-circshift(datacube,1,3)),3)/2;

try
  [ep(:,1) ep(:,2)] = find(numNeighbors==1 | (numNeighbors==2 & numBranches==1));
catch
  ep = zeros(0,2);
end

try
  [bp(:,1) bp(:,2)] = find(numBranches==3 | numBranches==4 | numNeighbors==7);
catch
  bp = zeros(0,2);
end
