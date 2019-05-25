function clusterId = dbscanAuxFn(row,col,minPoints,epsilon)
% dbscanAuxFn - (Auxillary function)
% clusters row and col according to:
% Ester, M, Kriegel, H, Sander, J et al.
% 'A density-based algorithm for discovering clusters in large spatial
% databases with noise'.
% Proceedings of the Second International Conference on
% Knowledge Discovery and Data Mining (1996).
%
% Syntax -
% dbscanAuxFn(row,col,minPoints,epsilon)
%
% Parameters -
% - 'row': list of x positions.
% - 'col': list of y positions.
% - 'minPoints': as described in paper.
% - 'epsilon': as described in paper.

count = 0;
numPoints = length(row);
clusterId = zeros(numPoints,1);
pairDistance = pdist2([row col],[row col]);
visited = false(numPoints,1);
for pointId = 1 : numPoints
    if ~visited(pointId)
        visited(pointId) = 1;
        neighbors = regionQueryAuxFn(pointId);
        if numel(neighbors) > minPoints
            count = count + 1;
            expandClusterAuxFn(pointId,neighbors,count);
        end
    end
end
    function expandClusterAuxFn(pointId,neighbors,count)
        clusterId(pointId) = count;
        neighborId = 1;
        while true
            neighbor = neighbors(neighborId);
            if ~visited(neighbor)
                visited(neighbor) = 1;
                neighborsTemp = regionQueryAuxFn(neighbor);
                if numel(neighborsTemp) >= minPoints
                    neighbors = [neighbors ; neighborsTemp];
                end
            end
            if clusterId(neighbor) == 0
                clusterId(neighbor) = count;
            end
            neighborId = neighborId + 1;
            if neighborId > numel(neighbors)
                break;
            end
        end
    end
    function neighbors = regionQueryAuxFn(pointId)
        neighbors = find(pairDistance(:,pointId) <= epsilon);
    end
end

