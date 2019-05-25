%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPML110
% Project Title: Implementation of DBSCAN Clustering in MATLAB
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

function [IDX, isnoise]=dbscanFnExt(X,epsilon,MinPts)

    C=0;
    
    n=size(X,1);
    IDX=zeros(n,1);
    
    D = pdist2(X,X);
    
    figure
    Dmod = zeros(n);
    for col = 1 : n
        Dmod(:,col) = sort(D(:,col));
        Dmodlol(1,col) = sum(Dmod(:,col) <= 10);
    end
    for row = 1 : 20
        Dmodmean(row) = mean(Dmod(row,:));
    end
    
    L = sort(Dmod(2,:));
    dd = diff(L);
    [~,index] = max(dd);
    opteps = L(index-1)
    figure
    hist(Dmodlol);
    bol = quantile(Dmodlol,0.10)
    figure
    plot(1:length(dd),dd);
    figure
    plot(1:n,L);
    
    visited=false(n,1);
    isnoise=false(n,1);
    
    for i=1:n
        if ~visited(i)
            visited(i)=true;
            
            Neighbors=RegionQuery(i);
            if numel(Neighbors)<MinPts
                % X(i,:) is NOISE
                isnoise(i)=true;
            else
                C=C+1;
                ExpandCluster(i,Neighbors,C);
            end
            
        end
    
    end
    
    function ExpandCluster(i,Neighbors,C)
        IDX(i)=C;
        
        k = 1;
        while true
            j = Neighbors(k);
            
            if ~visited(j)
                visited(j)=true;
                Neighbors2=RegionQuery(j);
                if numel(Neighbors2)>=MinPts
                    
                    Neighbors=[Neighbors;Neighbors2];   %#ok
                    
                end
            end
            if IDX(j)==0
                IDX(j)=C;
            end
            
            k = k + 1;
            if k > numel(Neighbors)
                break;
            end
        end
    end
    
    function Neighbors=RegionQuery(i)
        Neighbors=find(D(:,i)<=epsilon);
    end

end



