function [inputPath,exportPath,list] = setFolderPathAuxFn(app)
% setFolderPathAuxFn - (Auxillary function)
% sets input and output folder path.
%
% Syntax -
% setFolderPathAuxFn(app)
%
% Parameters -
% - app: ASAP UI class

%% reading exportPath
exportPath = uigetdir;
if exportPath == 0
    inputPath = '';
    exportPath = '';
    list = '';
    return;
end

%% setting input path to exportPath
inputPath = exportPath;

%% extracting folderName
[~,folderName] = fileparts(exportPath);

%% setting current directory to inputPath
cd(inputPath);

%% obtaining list of all files
list = dir ('**/*');

%% initializing numFiles (number of image files)
numFiles = 0;

%% looping through all files in the list 
for i = 1 : numel(list)
    [~,~,extension] = fileparts(list(i).name);
    switch lower(extension)
        
        %% checking for settings file
        case '.asse'
            settingsFile = list(i);
            settings = extractFn(settingsFile);
            app.BlinksEditField1_1.Value = settings.simulate_nBlinks;
            app.BlinksPerFrameEditField1_1.Value = settings.simulate_nBlinksFrame;
            app.NoiseEditField1_1.Value = settings.simulate_noise;
            app.DriftEditField1_1.Value = settings.simulate_drift;
            app.MeanUncertaintyEditField1_1.Value = settings.simulate_meanUncertainty;
            app.StdUncertaintyEditField1_1.Value = settings.simulate_stdUncertainty;
            app.MeanSigmaEditField1_1.Value = settings.simulate_meanSigma;
            app.StdSigmaEditField1_1.Value = settings.simulate_stdSigma;
            app.OnBlinksPerFrameEditField1_1.Value = settings.simulate_nOnBlinksFrame;
            app.OnTimeEditField1_1.Value = settings.simulate_onTime;
            app.OffTimeEditField1_1.Value = settings.simulate_offTime;
            app.PixelSizeField1_1.Value = settings.simulate_pixelSize;
            app.AstigmatismCheckBox1_1.Value = settings.simulate_astigmatism;
            app.segmentCellCheckBox1_1.Value = settings.simulate_segmentCell;
            app.LevelSlider1_1.Value = settings.simulate_segmentCellLevel;
            app.LevelSlider1_1.Enable = settings.simulate_segmentCellEnable;
            % Identification parameters
            app.segmentCellCheckBox2_1.Value = settings.identify_segmentCell;
            app.LevelSlider2_1.Value = settings.identify_segmentCellLevel;
            app.LevelSlider2_1.Enable = settings.identify_segmentCellLevelEnable;
            app.DropDown2_1.Value = settings.identify_method;
            app.SplitimageinequalpartsCheckBox.Value = settings.identify_splitImage;
            app.SplitimageinequalpartsCheckBox.Enable = settings.identify_splitImageEnable;
            app.DropDown2_2.Value = settings.identify_threshold;
            app.MultiplierEditFieldSize2_1.Value = settings.identify_thresholdMultiplier;
            app.ParticleSizeEditField1_1.Value = settings.identify_cleanerSize;
            app.SearchRadiusEditField1_1.Value = settings.identify_cleanerRadius;
            app.clearborderCheckBox1_1.Value = settings.identify_cleaner;
            app.DSpinner.Value = settings.identify_clusterD;
            app.DSpinner.Enable = settings.identify_clusterDEnable;
            app.SSpinner.Value = settings.identify_clusterS;
            app.SSpinner.Enable = settings.identify_clusterSEnable;
            app.EditFieldSizeLow.Value = settings.identify_sizeMin;
            app.EditFieldSizeUpp.Value = settings.identify_sizeMax;
            % Analysis parameters
            app.PixelsizeEditField.Value = settings.analyze_pixelSize;
            app.ListBox5_3.Value = settings.analyze_method;
            app.ListBox5_2.Value = settings.analyze_operations;
            app.MaxRingSizeEditField5_1.Value = settings.analyze_MaxRingSize;
            app.MaxRingSizeEditField5_1.Enable = settings.analyze_MaxRingSizeEnable;
            % Training parameters
            app.TextArea3_1.Value = settings.train_shapes;
            app.DropDown3_1.Value = settings.train_learner;
            app.ListBox3_2.Items = settings.train_featuresList;
            app.ListBox3_2.Value = settings.train_features;
            
            %% checking for image files
        case {'.png','.jpg','.tif'}
            numFiles = numFiles + 1;
    end
end

%% checking numFiles if empty
if numFiles == 0
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s','ASAP error 2: no image files in selected path.')];
    return;
else
    app.MsgBox.Value = [app.MsgBox.Value ;...
        sprintf('%s',['ASAP progress: selected folder (' folderName ') is succesfully loaded.'])];
end