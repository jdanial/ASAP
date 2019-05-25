function automationScriptRunnerFn(app)
% automationScriptRunnerFn() -
% runs ASAP (or modules thereof) using the parameters loaded from the 
% automation script.
%
% Syntax -
% automationScriptRunnerFn(app).
%
% Parameters -
% - app: ASAP UI class
%
% Copyright -
% John S. H. Danial (2018).
% danial@is.mpg.de

%% initializing returnFlag
returnFlag = false;

switch app.pr_entryPoint
    case 'Script'
        
        %% simulating data
        if strcmp(app.pr_simulationParam.simulate,'true')
            app.pr_fileList = retrieveFilesAuxFn(app.pr_inputPath,{'.png','.jpg','.tif'});
            returnFlag = simulateFn(app);
        end
        
        %% segmenting data
        if strcmp(app.pr_identificationParam.identify,'true')
            if ~returnFlag
                app.pr_fileList = retrieveFilesAuxFn(app.pr_inputPath,{'.png','.jpg','.tif'});
                returnFlag = identifyFn(app);
            end
            if ~returnFlag
                returnFlag = exportFn(app,'Identify');
            end
        end
        
        %% analysing data
        if strcmp(app.pr_analysisParam.analyze,'true')
            if ~returnFlag
                app.pr_fileList = retrieveFilesAuxFn(app.pr_inputPath,'.asid');
                returnFlag = extractFn(app);
            end
            if ~returnFlag
                returnFlag = analyzeFn(app);
            end
            if ~returnFlag
                returnFlag = exportFn(app,'Analyze');
            end
        end
        
        %% classifying data
        if strcmp(app.pr_classificationParam.classify,'true')
            if ~returnFlag
                app.pr_fileList = retrieveFilesAuxFn(app.pr_inputPath,'.asan');
                returnFlag = extractFn(app);
            end
            if ~returnFlag
                returnFlag = classifyFn(app);
            end
            if ~returnFlag
                returnFlag = exportFn(app,'Classify');
            end
        end
        
        %% clustering data
        if strcmp(app.pr_clusteringParam.cluster,'true')
            if ~returnFlag
                app.pr_fileList = retrieveFilesAuxFn(app.pr_inputPath,'.ascl');
                returnFlag = extractFn(app);
            end
            if ~returnFlag
                returnFlag = clusterFn(app);
            end
            if ~returnFlag
                returnFlag = exportFn(app,'Cluster');
            end
        end
        
        %% plotting data
        if strcmp(app.pr_plottingParam.plot,'true')
            if ~returnFlag
                app.pr_fileList = retrieveFilesAuxFn(app.pr_inputPath,'.ascl');
                returnFlag = extractFn(app);
            end
            if ~returnFlag
                returnFlag = plotFn(app);
            end
            if ~returnFlag
                returnFlag = exportFn(app,'Plot');
            end
        end
        
        %% montaging data
        if strcmp(app.pr_montagingParam.montage,'true')
            if ~returnFlag
                app.pr_fileList = retrieveFilesAuxFn(app.pr_inputPath,'.ascl');
                returnFlag = extractFn(app);
            end
            if ~returnFlag
                returnFlag = montageFn(app);
            end
            if ~returnFlag
                exportFn(app,'Montage');
            end
        end
        
    otherwise
        app.MsgBox.Value = [app.MsgBox.Value ;...
            sprintf('%s','ASAP error 11: cannot run - no script is loaded.')];
        return;
end