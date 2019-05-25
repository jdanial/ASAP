function rawDataWriterAuxFn(dataArray,exportPath,exportMode)
% rawDataWriterAuxFn- (Auxillary function)
% saves ASAP data to .txt file.
%
% Syntax -
% rawDataWriterAuxFn(dataArray,exportPath,exportMode)
%
% Parameters -
% - dataArray: data structure.
% - exportPath: path to export file.
% - exportMode: export mode.

%% identifying text file name and path
switch exportMode
    case {'Plot','Montage'}
        textFileName = 'Plots.txt';
    otherwise
        textFileName = [dataArray.name '.txt'];
end
textFilePath = exportPath;
textFullFile = fullfile(textFilePath,textFileName);
textFileHandle = fopen(textFullFile,'w');

%% initialization
switch exportMode
    case {'Plot','Montage'}
    otherwise
        numStructures = numel(dataArray.identifiedStructures);
end

%% checkinhg export mode
switch exportMode
    case 'Identify'
        
        %% initial statements
        fprintf(textFileHandle,'%s\t%d\n','Number of particles indentified',numStructures);
        
        for structureId = 1 : numStructures
            %% line skipper
            fprintf(textFileHandle,'\n');
            
            %% particle id
            fprintf(textFileHandle,'%s%d\n','Particle ',structureId);
            fprintf(textFileHandle,'%s\n','-------');
            fprintf(textFileHandle,'%s\t%s\n','x','y');
            
            %% pixel list
            numPixels = size(dataArray.identifiedStructures(structureId).PixelList,1);
            for pixelId = 1 : numPixels
                fprintf(textFileHandle,'%d\t%d\n',...
                    dataArray.identifiedStructures(structureId).PixelList(pixelId,1),...
                    dataArray.identifiedStructures(structureId).PixelList(pixelId,2));
            end
        end
        
    case 'Analyze'
        
        %% initial statements
        fprintf(textFileHandle,'%s\t%d\n','Number of particles analyzed',numStructures);
        
        %% line skipper
        fprintf(textFileHandle,'\n');
        
        %% adding descriptors
        fprintf(textFileHandle,'%s\t','Particle #');
        numDescriptors = numel(dataArray.descriptors);
        for descriptorId = 1 : numDescriptors
            fprintf(textFileHandle,'%s\t',dataArray.descriptors{descriptorId});
        end
        
        %% line skipper
        fprintf(textFileHandle,'\n');
        
        %% dimensions
        for structureId = 1 : numStructures
            fprintf(textFileHandle,'%d\t',structureId);
            for descriptorId = 1 : numDescriptors
                descriptor = dataArray.descriptors{descriptorId};
                values = dataArray.dimensions{structureId}.(descriptor(~isspace(descriptor)));
                for valueId = 1 : numel(values)
                    fprintf(textFileHandle,'%f\t',values(valueId));
                end
            end
            
            %% line skipper
            fprintf(textFileHandle,'\n');
        end
        
    case 'Classify'
        
        %% initial statements
        fprintf(textFileHandle,'%s\t%d\n','Number of particles analyzed',numStructures);
        
        %% line skipper
        fprintf(textFileHandle,'\n');
        
        %% adding descriptors
        fprintf(textFileHandle,'%s\t%s\t','Particle #','Shape');
        numDescriptors = numel(dataArray.descriptors);
        for descriptorId = 1 : numDescriptors
            fprintf(textFileHandle,'%s\t',dataArray.descriptors{descriptorId});
        end
        
        %% line skipper
        fprintf(textFileHandle,'\n');
        
        %% shape and dimensions
        for structureId = 1 : numStructures
            shape = dataArray.shapes{structureId};
            fprintf(textFileHandle,'%d\t%s\t',structureId,shape);
            for descriptorId = 1 : numDescriptors
                descriptor = dataArray.descriptors{descriptorId};
                values = dataArray.dimensions{structureId}.(descriptor(~isspace(descriptor)));
                for valueId = 1 : numel(values)
                    fprintf(textFileHandle,'%f\t',values(valueId));
                end
            end
            
            %% line skipper
            fprintf(textFileHandle,'\n');
        end
        
    case 'Cluster'
        
        %% clustering shapes
        fprintf(textFileHandle,'%s\t','Clustered shape(s)');
        numShapes = numel(dataArray.clusteringData.shapes);
        for shapeId = 1 : numShapes
            fprintf(textFileHandle,'%s\t',dataArray.clusteringData.shapes{shapeId});
        end
        
        %% line skipper
        fprintf(textFileHandle,'\n');
        
        %% clustering mode
        fprintf(textFileHandle,'%s\t%s\n','Clustered mode',dataArray.clusteringData.mode);
        
        %% actual num of clusters
        fprintf(textFileHandle,'%s\t%d\n','# Actual clusters',dataArray.clusteringData.numActualClusters);
        
        %% optimal num of clusters
        fprintf(textFileHandle,'%s\t%d\n','# Optimal clusters',dataArray.clusteringData.numOptimalClusters);
        
        %% silhouette coefficient
        fprintf(textFileHandle,'%s\t%s\n','Silhouette coefficient',dataArray.clusteringData.siluoetteCoefficient);
        
        %% line skipper
        fprintf(textFileHandle,'\n');
        
        %% particle number, first and / or second descriptors and group
        numDescriptors = numel(dataArray.clusteringData.descriptors);
        fprintf(textFileHandle,'%s\t','Particle #');
        for descriptorId = 1 : numDescriptors
            fprintf(textFileHandle,'%s\t',...
                dataArray.clusteringData.descriptors{descriptorId});
        end
        fprintf(textFileHandle,'%s\n','Group');
        
        %% clustering data
        numStructures = length(dataArray.clusteringData.structuresIndices);
        for structureId = 1 : numStructures
            fprintf(textFileHandle,'%d\t',...
                dataArray.clusteringData.structuresIndices(structureId));
            for descriptorId = 1 : numDescriptors
                fprintf(textFileHandle,'%f\t',...
                    dataArray.clusteringData.descriptorData(structureId,descriptorId));
            end
            fprintf(textFileHandle,'%d\n',...
                dataArray.clusteringData.descriptorDataGrouping(structureId,1));
        end
        
    case 'Plot'
        
        %% extracting # of rows and cols
        numRows = size(dataArray.figureData,1);
        numCols = size(dataArray.figureData,2);
        
        %% looping through rows and cols
        for rowId = 1 : numRows
            for colId = 1 : numCols
                
                %% extracting results
                results = dataArray.figureData(rowId,colId).results;
                
                if ~isempty(results)
                    %% innitializing visited plots
                    visited = [];
                    
                    %% extracting numGraphs
                    numGraphs = numel(dataArray.graph);
                    
                    %% converting row # / col # to plot Id
                    for graphId = 1 : numGraphs
                        if dataArray.graph(graphId).rowNum == rowId && ...
                                dataArray.graph(graphId).colNum == colId && ...
                                ~ismember(graphId,visited)
                            visited = [visited graphId];
                            plotId = length(visited);
                            
                            %% printing row # / col #
                            fprintf(textFileHandle,'%s\n',['Plot (' num2str(rowId) ',' num2str(colId) ') / ' 'Graph ' num2str(plotId)]);
                            
                            %% file IDs
                            fprintf(textFileHandle,'%s\t','File IDs');
                            for fileId = 1 : length(dataArray.graph(graphId).files)
                                fprintf(textFileHandle,'%d\t',dataArray.graph(graphId).files(fileId));
                            end
                            
                            %% line skipper
                            fprintf(textFileHandle,'\n');
                            
                            %% descriptors
                            fprintf(textFileHandle,'%s\t%s\n','X descriptor',dataArray.graph(graphId).xDescriptor);
                            fprintf(textFileHandle,'%s\t%s\n','Y descriptor',dataArray.graph(graphId).yDescriptor);
                            
                            %% shape
                            try
                                fprintf(textFileHandle,'%s\t%s\n','Shapes',dataArray.graph(graphId).shapes);
                            catch
                                fprintf(textFileHandle,'%s\t%s\n','Shapes',dataArray.graph(graphId).shapes{1});
                            end
                            
                            %% fitting model
                            fprintf(textFileHandle,'%s\t','Fitting model');
                            if isfield(results,'stat_glm')
                                equation = results.stat_glm(plotId).model.Formula.ModelFun;
                            elseif isfield(results,'stat_fit')
                                equation = formula(results.stat_fit(plotId).model);
                            elseif isfield(results,'stat_density')
                                equation = 'PDF';
                            else
                                equation = 'None';
                            end
                            fprintf(textFileHandle,'%s\n',equation);
                            
                            %% fitting goodness
                            if isfield(results,'stat_glm')
                                fprintf(textFileHandle,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
                                    'Fitting goodness',...
                                    'SSE',...
                                    'SST',...
                                    'SSR',...
                                    'Ordinary R-Squared',...
                                    'Adjusted R-Squared',...
                                    'AIC');
                                fprintf(textFileHandle,'%s\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                                    'Value',...
                                    results.stat_glm(plotId).model.SSE,...
                                    results.stat_glm(plotId).model.SST,...
                                    results.stat_glm(plotId).model.SSR,...
                                    results.stat_glm(plotId).model.Rsquared.Ordinary,...
                                    results.stat_glm(plotId).model.Rsquared.Adjusted,...
                                    results.stat_glm(plotId).model.ModelCriterion.AIC);
                            elseif isfield(results,'stat_fit')
                                fprintf(textFileHandle,'%s\t%s\t%s\t%s\n',...
                                    'Fitting goodness',...
                                    'SSE',...
                                    'Ordinary R-Squared',...
                                    'Adjusted R-Squared');
                                fprintf(textFileHandle,'%s\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                                    'Value',...
                                    results.stat_fit(plotId).gof.sse,...
                                    results.stat_fit(plotId).gof.rsquare,...
                                    results.stat_fit(plotId).gof.adjrsquare);
                            end
                            
                            %% fitting coefficients
                            if isfield(results,'stat_glm')
                                fprintf(textFileHandle,'%s\t%s\t%s\t%s\t%s\t',...
                                    'Fitting coefficients',...
                                    'Estimate',...
                                    'SE',...
                                    'tStat',...
                                    'pValue');
                                numCoeff = results.stat_glm(plotId).model.NumCoefficients;
                                for coeffId = 1 : numCoeff
                                    fprintf(textFileHandle,'%s\t',...
                                        results.stat_glm(plotId).model.CoefficientNames{coeffId});
                                    for coeffParam = 1 : 4
                                        fprintf(textFileHandle,'%f\t',...
                                            results.stat_glm(plotId).model.Coefficients{coeffId,coeffParam});
                                    end
                                    
                                    %% line skipper
                                    fprintf(textFileHandle,'\n');
                                end
                            elseif isfield(results,'stat_fit')
                                fprintf(textFileHandle,'%s\t%s\t%s\t%s\n',...
                                    'Fitting coefficients',...
                                    'Estimate',...
                                    'Lower bound',...
                                    'Upper bound');
                                numCoeff = numcoeffs(results.stat_fit(plotId).model);
                                for coeffId = 1 : numCoeff
                                    temp = coeffnames(results.stat_fit(plotId).model);
                                    fprintf(textFileHandle,'%s\t',temp{coeffId});
                                    temp = coeffvalues(results.stat_fit(plotId).model);
                                    fprintf(textFileHandle,'%f\t',temp(coeffId));
                                    temp = confint(results.stat_fit(plotId).model);
                                    fprintf(textFileHandle,'%f\t%f\n',temp(1,coeffId),temp(2,coeffId));
                                end
                            end
                            
                            %% raw data
                            fprintf(textFileHandle,'%s\t%s\n','X (raw)','Y (raw)');
                            if ~strcmp(dataArray.graph(graphId).xDescriptor,'Distance')
                                if isfield(results,'stat_bin')
                                    numPoints = length(results.stat_bin(plotId).centers);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_bin(plotId).centers(pointId),...
                                            results.stat_bin(plotId).counts(pointId));
                                    end
                                elseif isfield(results,'stat_smooth')
                                    numPoints = length(results.stat_smooth(plotId).x);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_smooth(plotId).x(pointId),...
                                            results.stat_smooth(plotId).y(pointId));
                                    end
                                elseif isfield(results,'stat_summary')
                                    numPoints = length(results.stat_summary(plotId).x);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_summary(plotId).x(pointId),...
                                            results.stat_summary(plotId).y(pointId));
                                    end
                                elseif isfield(results,'stat_glm')
                                    numPoints = length(results.stat_glm(plotId).x);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_glm(plotId).x(pointId),...
                                            results.stat_glm(plotId).y(pointId));
                                    end
                                elseif isfield(results,'stat_boxplot')
                                    numPoints = length(results.stat_boxplot(plotId).boxplot_data);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            plotId,...
                                            results.stat_boxplot(plotId).boxplot_data(pointId));
                                    end
                                elseif isfield(results,'stat_violin')
                                    numPoints = length(results.stat_violin(plotId).densities{1});
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_violin(plotId).densities{1}(pointId),...
                                            results.stat_violin(plotId).densities_y{1}(pointId));
                                    end
                                elseif isfield(results,'geom_point_handle')
                                    numPoints = length(results.geom_point_handle(plotId).XData);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.geom_point_handle(plotId).XData(pointId),...
                                            results.geom_point_handle(plotId).YData(pointId));
                                    end
                                elseif isfield(results,'geom_bar_handle')
                                    fprintf(textFileHandle,'%f\t%f\n',...
                                        (min(results.geom_bar_handle(plotId).XData) + max(results.geom_bar_handle(plotId).XData)) / 2,...
                                        max(results.geom_bar_handle(plotId).YData));
                                end
                            else
                                if isfield(results,'geom_point_handle')
                                    numPoints = length(results.geom_point_handle(plotId).XData);
                                    step = length(unique(results.geom_point_handle(plotId).XData));
                                    for pointId = 1 : step
                                        fprintf(textFileHandle,'%f\t',...
                                            results.geom_point_handle(plotId).XData(pointId));
                                    end
                                    
                                    %% line skipper
                                    fprintf(textFileHandle,'\n');
                                    
                                    for pointId = 1 : step : numPoints
                                        fprintf(textFileHandle,'%f\t',...
                                            results.geom_point_handle(plotId).YData(pointId : pointId + step - 1));
                                        
                                        %% line skipper
                                        fprintf(textFileHandle,'\n');
                                    end
                                    
                                elseif isfield(results,'stat_smooth')
                                    numPoints = length(results.stat_smooth(plotId).x);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_smooth(plotId).x(pointId),...
                                            results.stat_smooth(plotId).y(pointId));
                                    end
                                elseif isfield(results,'stat_summary')
                                    numPoints = length(results.stat_summary(plotId).x);
                                    step = length(unique(results.stat_summary(plotId).x));
                                    for pointId = 1 : step
                                        fprintf(textFileHandle,'%f\t',...
                                            results.stat_summary(plotId).x(pointId));
                                    end
                                    
                                    %% line skipper
                                    fprintf(textFileHandle,'\n');
                                    
                                    for pointId = 1 : step : numPoints
                                        fprintf(textFileHandle,'%f\t',...
                                            results.stat_summary(plotId).y(pointId : pointId + step - 1));
                                        
                                        %% line skipper
                                        fprintf(textFileHandle,'\n');
                                    end
                                elseif isfield(results,'stat_glm')
                                    numPoints = length(results.stat_glm(plotId).x);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_glm(plotId).x(pointId),...
                                            results.stat_glm(plotId).y(pointId));
                                    end
                                end
                            end
                            
                            %% fitting data
                            if sum(isfield(results,{'stat_glm','stat_fit','stat_density'})) > 0
                                fprintf(textFileHandle,'%s\t%s\n','X (fitted)','Y (fitted)');
                                if isfield(results,'stat_glm')
                                    numPoints = length(results.stat_glm(plotId).x);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_glm(plotId).x(pointId),...
                                            results.stat_glm(plotId).y(pointId));
                                    end
                                elseif isfield(results,'stat_fit')
                                    numPoints = length(results.stat_fit(plotId).x);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_fit(plotId).x(pointId),...
                                            results.stat_fit(plotId).y(pointId));
                                    end
                                elseif isfield(results,'stat_density')
                                    numPoints = length(results.stat_density(plotId).x);
                                    for pointId = 1 : numPoints
                                        fprintf(textFileHandle,'%f\t%f\n',...
                                            results.stat_density(plotId).x(pointId),...
                                            results.stat_density(plotId).y(pointId));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
end

%% closing file
fclose(textFileHandle);
end



