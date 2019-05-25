function line = pixWalkerFnExt(inputIm, startPos, targets)

%PixelWalker is similar to bwtraceboundary but it will always step N,W,S,E
%if available.  Line is the ordered points until a target or start position
%is reached

line(1,:) = startPos;   %Start the line

while(1)
    
    %First try to find a 4 connected
    trace = bwtraceboundary(inputIm,line(end,:),'E',4);
    if (size(trace,1) > 2)
        nextPoint = trace(2,:);
    else
        trace = bwtraceboundary(inputIm,line(end,:),'E',8);
        if (size(trace,1) > 2)
            nextPoint = trace(2,:);
        else
            return
        end
    end
    
%     %Check for loops
%     if ismember(nextPoint,line,'rows')
%         return
%     end
    
    %Erase the previous point
    inputIm(line(end,1),line(end,2)) = 0;
    
    %Add the new point to the end
    line(end+1,:) = nextPoint;

    %Check for targets
    if ismember(nextPoint,targets,'rows')
        return
    end

end
