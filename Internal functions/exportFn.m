function returnFlag = exportFn(app,exportMode)
% exportFn() -
% exports data generated from ASAP.mlapp.
%
% Syntax -
% exportFn(app,exportMode).
%
% Parameters -
% - app: ASAP UI class
% - exportMode: ASAP module name.
%
% Copyright -
% John S. H. Danial (2018)
% danial@is.mpg.de

%% initializing returnFlag
returnFlag = false;

%% determing seperator
if strcmp(computer,'MACI64')
    separator = '/';
else
    separator = '\';
end

%% obtaining export folder path
exportFolderComplete = strcat(app.pr_exportPath,separator,exportMode);
mkdir(exportFolderComplete);

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: export started.')];
drawnow;

%% getting numFiles
numFiles = length(app.pr_structuresData.file);

switch exportMode       
    case 'Identify'
        try
            %% saving files produced during identification
            for fileId = 1 : numFiles
                
                %% setting up ASAP progress
                message = app.MsgBox.Value;
                message{end} = ['ASAP progress: exporting identified structures in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
                app.MsgBox.Value = message;
                drawnow;
                
                if strcmp(app.pr_options.file(fileId).exportImages,'true')
                    
                    %% saving .tif file of identified and annotated particles
                    imageArray = app.pr_structuresData.file(fileId).imageOutlined;
                    imwrite(imageArray,[exportFolderComplete separator 'Identified particles_' app.pr_structuresData.file(fileId).name '.tif']);
                    
                    %% saving .tif file of all identified particles each alone
                    mkdir([exportFolderComplete separator 'Individual particles_' app.pr_structuresData.file(fileId).name]);
                    for structureId = 1 : numel(app.pr_structuresData.file(fileId).identifiedStructures)
                        imageForSaving = app.pr_structuresData.file(fileId).identifiedStructures(structureId).rawStructure;
                        imwrite(imageForSaving,[exportFolderComplete ...
                            separator 'Individual particles_' app.pr_structuresData.file(fileId).name ...
                            separator 'Particle ' num2str(structureId) '.tif']);
                    end
                end
                
                if strcmp(app.pr_options.file(fileId).exportRawData,'true')
                    
                    %% saving .txt raw data file
                    dataArray = app.pr_structuresData.file(fileId);
                    rawDataWriterAuxFn(dataArray,exportFolderComplete,exportMode);
                end
                
                %% saving .asid file
                dataArray = app.pr_structuresData.file(fileId);
                save([exportFolderComplete separator app.pr_structuresData.file(fileId).name '.asid'],'dataArray');
            end
        catch
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 19: cannot write files to disk.')];
            return
        end
        
    case 'Analyze'
        
        try
            %% saving files produced during identification
            for fileId = 1 : numFiles
                
                %% setting up ASAP progress
                message = app.MsgBox.Value;
                message{end} = ['ASAP progress: exporting analyzed data in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
                app.MsgBox.Value = message;
                drawnow;
                
                if strcmp(app.pr_options.file(fileId).exportRawData,'true')
                    
                    %% saving .txt raw data file
                    dataArray = app.pr_structuresData.file(fileId);
                    rawDataWriterAuxFn(dataArray,exportFolderComplete,exportMode);
                end
                
                %% saving .asan file
                dataArray = app.pr_structuresData.file(fileId);
                save([exportFolderComplete separator app.pr_structuresData.file(fileId).name '.asan'],'dataArray');
            end
        catch
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 19: cannot write files to disk.')];
            return
        end
        
    case 'Train'
        
        try
            %% saving files produced during training
            if strcmp(app.pr_options.file(1).exportImages,'true')
                
                %% saving .png file of confusion matrix
                plotConfMatFnExt(app.pr_trainingData.confusionMatrix,...
                    app.pr_trainingData.shapeNamesOrder,'export',...
                    [exportFolderComplete separator 'Confusion matrix']);
            end
            
            %% saving .astr file of classification model
            dataArray = app.pr_trainingData;
            save([exportFolderComplete separator 'Classification model.astr'],'dataArray');
        catch
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 19: cannot write files to disk.')];
            return
        end
        
    case 'Classify'
        
        try
            %% saving files produced during classification
            for fileId = 1 : numFiles
                
                %% setting up ASAP progress
                message = app.MsgBox.Value;
                message{end} = ['ASAP progress: exporting classified data in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
                app.MsgBox.Value = message;
                drawnow;
                
                if strcmp(app.pr_options.file(fileId).exportRawData,'true')
                    
                    %% saving .txt raw data file
                    dataArray = app.pr_structuresData.file(fileId);
                    rawDataWriterAuxFn(dataArray,exportFolderComplete,exportMode);
                end
                
                %% saving .ascl file of raw data of the identified par ticles
                dataArray = app.pr_structuresData.file(fileId);
                save([exportFolderComplete separator app.pr_structuresData.file(fileId).name '.ascl'],'dataArray');
            end
        catch
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 19: cannot write files to disk.')];
            return
        end
        
    case 'Cluster'
        
        try
            %% saving files produced during clustering
            for fileId = 1 : numFiles
                
                %% setting up ASAP progress
                message = app.MsgBox.Value;
                message{end} = ['ASAP progress: exporting clustered data in file ' num2str(fileId) ' out of ' num2str(numFiles) '.'];
                app.MsgBox.Value = message;
                drawnow;
                
                if strcmp(app.pr_options.file(fileId).exportImages,'true')
                    
                    %% saving .tif clustered image files
                    imageArray = app.pr_structuresData.file(fileId).clusteringData.clusteredImage;
                    imwrite(imageArray,[exportFolderComplete separator 'Clustered particles_' app.pr_structuresData.file(fileId).name '.tif']);
                end
                
                if strcmp(app.pr_options.file(fileId).exportRawData,'true')
                    
                    %% saving .txt raw data file
                    dataArray = app.pr_structuresData.file(fileId);
                    rawDataWriterAuxFn(dataArray,exportFolderComplete,exportMode);
                end
                
                %% saving .ascu file of raw data of the analyzed particles
                dataArray = app.pr_structuresData.file(fileId);
                save([exportFolderComplete separator app.pr_structuresData.file(fileId).name '.ascu'],'dataArray');
            end
        catch
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 19: cannot write files to disk.')];
            return
        end
        
    case 'Plot'
        
        try
            
            %% setting up ASAP progress
            message = app.MsgBox.Value;
            message{end} = 'ASAP progress: exporting plot';
            app.MsgBox.Value = message;
            drawnow;

            %% saving .txt raw data file
            dataArray = app.pr_plottingData;
            rawDataWriterAuxFn(dataArray,exportFolderComplete,exportMode);
            
            %% saving plots in .png, .svg && .pdf formats
            extensions = {'svg','pdf','png'};
            for extensionId = 1 : numel(extensions)
                try
                app.pr_plottingData.figureData.export(...
                    'file_name','plots',...
                    'export_path',exportFolderComplete,...
                    'file_type',extensions{extensionId},...
                    'width',app.pr_plottingData.length,...
                    'height',app.pr_plottingData.width,...
                    'units','centimeters');
                catch
                end
            end
            
        catch
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 19: cannot write files to disk.')];
            return
        end
    
    case 'Montage'

        try
   
            %% setting up ASAP progress
            message = app.MsgBox.Value;
            message{end} = 'ASAP progress: exporting montage';
            app.MsgBox.Value = message;
            drawnow;
            
            %% saving gallery in .png and .pdf formats
            filePath = [exportFolderComplete separator 'Montage.png'];
            export_fig(filePath);
        
        catch
            returnFlag = true;
            app.MsgBox.Value = [app.MsgBox.Value ;...
                sprintf('%s','ASAP error 19: cannot write files to disk.')];
            return
        end
end

%% displaying ASAP progress
app.MsgBox.Value = [app.MsgBox.Value ;...
    sprintf('%s','ASAP progress: export complete.')];
drawnow;
end

