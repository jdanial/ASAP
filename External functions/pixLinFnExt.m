function lines = pixLinFnExt(skelIm, debugToggle)
%Takes an skeletonized image as an input and extracts lines

%Default debugToggle to false
if ~exist('debugToggle','var')
    debugToggle = '0';
end

%Convert string to number
debugToggle = str2num(debugToggle);

%Init
lines = cell(0,1);

%Group all connected pixels
CC = bwconncomp(skelIm);
S = regionprops(CC,'BoundingBox','Image');

for grpid = 1:numel(S)

    if debugToggle
        clc, grpid
    end
    
    %Get an image from the group
    grpim = S(grpid).Image;

    %Get the offsets to the full image
    offsets = floor(S(grpid).BoundingBox(2:-1:1));

    %while we still have pixels to extract
    while(sum(grpim(:)))

        if debugToggle
            sum(grpim(:))
        end
    
        %Find remanining critical points
        [ep, bp] = pixFinderFnExt(grpim);
        targets = cat(1, ep, bp);
        
        if debugToggle
            clf
            imagesc(grpim)
            hold on
            plot(bp(:,2),bp(:,1),'rx')
            plot(ep(:,2),ep(:,1),'go')
        end

        %Check if the image is a single circle
        if isempty(targets)
            [targets(1,1) targets(1,2)] = find(grpim,1);
        end
        
        %Trace from the first endpoint to another endpoint or branchpoint
        line = pixWalkerFnExt(grpim, targets(1,:), targets(2:end,:));
        
        if debugToggle
            plot(line(:,2),line(:,1),'k')
            pause(1)
        end
        
        %Remove the selected endpoint to the critical point
        grpim(sub2ind(size(grpim),line(1:end-1,1),line(1:end-1,2))) = 0;
        
        %Remove the last point unless it was a branch point
        if ~(ismember(line(end,:),bp,'rows'))
             grpim(line(end,1),line(end,2)) = 0;
        end
        
        %Save the line
        lines(end+1) = {line+repmat(offsets,size(line,1),1)};
        
        clear bp ep

    end  
end
