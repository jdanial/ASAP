function initializeGraphPropAuxFn(app,mode,varargin)
% initializeGraphPropAuxFn - (Auxillary function)
% updates graph properties panel and UI property
%
% Syntax -
% initializeGraphPropAuxFn(app)
%
% Parameters -
% - app: ASAP UI class

%% defining handles
listBoxHandle = {app.ListBox7_1,app.ListBox7_2,app.ListBox7_3};
checkBoxHandle = {app.CheckBox7_1,app.CheckBox7_2,app.CheckBox7_3,app.CheckBox7_4,...
    app.CheckBox7_5,app.CheckBox7_6,app.CheckBox7_7,app.CheckBox7_8};
dropDownHandle = {app.DropDown7_1,app.DropDown7_2,app.DropDown7_3,app.DropDown7_4,...
    app.DropDown7_5,app.DropDown7_6,app.DropDown7_7,app.DropDown7_8};
editFieldHandle = {app.EditField7_1,app.EditField7_2,app.EditField7_3,app.EditField7_4,...
    app.EditField7_5,app.EditField7_6,app.EditField7_7};

switch mode
    case 'add'
        %% updating graph number
        app.pr_plottingData.numGraphs = app.pr_plottingData.numGraphs + 1;
        
        %% updating listboxes
        listBoxHandle{2}.Items = string(1 : app.pr_plottingData.numGraphs);
        listBoxHandle{2}.Value = listBoxHandle{2}.Items{end};
        listBoxHandle{3}.Items = listBoxHandle{1}.Value;
        listBoxHandle{3}.Value = listBoxHandle{3}.Items{1};
        
        %% updating checkboxes
        checkBoxHandle{1}.Value = true;
        for handleId = 2 : numel(checkBoxHandle)
            checkBoxHandle{handleId}.Value = false;
        end
        
        %% updating dropdown menus - link graph
        dropDownHandle{1}.Items = string(1 : app.pr_plottingData.numGraphs);
        dropDownHandle{1}.Value = dropDownHandle{1}.Items{1};
        
        %% updating dropdown menus - shapes
        numFiles = length(app.pr_structuresData.file);
        tempShapes = (app.pr_structuresData.file(1).shapes);
        for fileId = 2 : numFiles
            try
                tempShapes = [tempShapes; (app.pr_structuresData.file(fileId).shapes)];
            catch
                tempShapes = [tempShapes; (app.pr_structuresData.file(fileId).shapes)'];
            end
        end
        dropDownHandle{2}.Items = unique(tempShapes);
        dropDownHandle{2}.Value = dropDownHandle{2}.Items{1};
        
        %% updating dropdown menus - y descriptor
        analysisModes = app.pr_structuresData.file(1).analysisMode;
        dropDownHandle{3}.Items = {};
        for analysisModeId = 1 : numel(analysisModes)
            try
                dropDownHandle{3}.Items = [dropDownHandle{3}.Items constantFetcherFn('shapeDescriptor',...
                    analysisModes{analysisModeId},'y')];
            catch
                dropDownHandle{3}.Items = constantFetcherFn('shapeDescriptor',...
                    analysisModes{analysisModeId},'y');
            end
        end
        dropDownHandle{3}.Items = [constantFetcherFn('shapeDescriptor',...
            'Reserved','y') dropDownHandle{3}.Items];
        dropDownHandle{3}.Value = dropDownHandle{3}.Items{1};
        
        %% updating dropdown menus - x descriptor
        yDescriptor = dropDownHandle{3}.Value;
        dropDownHandle{4}.Items = {};
        if ismember(yDescriptor,constantFetcherFn('shapeDescriptor',...
                'Radial profiling','y'))
            dropDownHandle{4}.Items = constantFetcherFn('shapeDescriptor',...
                'Radial profiling','x');
            dropDownHandle{4}.Value = dropDownHandle{4}.Items{1};
        else
            for analysisModeId = 1 : numel(analysisModes)
                if ~strcmp(analysisModes{analysisModeId},'Radial profiling')
                    try
                        dropDownHandle{4}.Items = [dropDownHandle{4}.Items constantFetcherFn('shapeDescriptor',...
                            analysisModes{analysisModeId},'x')];
                    catch
                        dropDownHandle{4}.Items = constantFetcherFn('shapeDescriptor',...
                            analysisModes{analysisModeId},'x');
                    end
                end
            end
            if strcmp(yDescriptor,'Events')
                try
                    dropDownHandle{4}.Value = dropDownHandle{4}.Items{1};
                catch
                end
            else
                strcmp(yDescriptor,'Count')
                dropDownHandle{4}.Items = [constantFetcherFn('shapeDescriptor',...
                    'Reserved','x') dropDownHandle{4}.Items];
                dropDownHandle{4}.Value = dropDownHandle{4}.Items{1};
            end
        end
        
        %% updating dropdown menus - map
        dropDownHandle{5}.Items = constantFetcherFn('map');
        dropDownHandle{5}.Value = dropDownHandle{5}.Items{1};
        
        %% updating dropdown menus - fill
        dropDownHandle{6}.Items = constantFetcherFn('fill');
        dropDownHandle{6}.Value = dropDownHandle{6}.Items{1};
        
        %% updating dropdown menus - subType
        type = constantFetcherFn('type',dropDownHandle{4}.Value,dropDownHandle{3}.Value);
        dropDownHandle{7}.Items = constantFetcherFn('subType',type);
        dropDownHandle{7}.Value = dropDownHandle{7}.Items{1};
        
        %% updating dropdown menus - fit
        dropDownHandle{8}.Items = constantFetcherFn('fit',type);
        dropDownHandle{8}.Value = dropDownHandle{8}.Items{1};
        
        %% updating edit fields
        for handleId = 1 : numel(editFieldHandle)
            editFieldHandle{handleId}.Value = '';
        end
        editFieldHandle{5}.Enable = false;
        
        %% writing updates
        initializeGraphPropAuxFn(app,'write');
        
    case 'clear'
        
        %% initialing plotting data UI property
        app.pr_plottingData = struct();
        app.pr_plottingData.numGraphs = 0;
        
        %% updating listboxes
        for handleId = 2 : numel(listBoxHandle)
            listBoxHandle{handleId}.Items = {};
        end
        
        %% updating checkboxes
        for handleId = 1 : numel(checkBoxHandle)
            checkBoxHandle{handleId}.Value = false;
        end
        
        %% updating dropdown menus
        for handleId = 1 : numel(dropDownHandle)
            dropDownHandle{handleId}.Items = {};
        end
        
        %% updating editfields
        for handleId = 1 : numel(editFieldHandle)
            editFieldHandle{handleId}.Value = '';
        end
        editFieldHandle{5}.Enable = false;
        
    case 'update'
        
        %% reading graphId
        graphId = str2double(listBoxHandle{2}.Value);
        
        %% reading subMode
        subMode = varargin{1};
        
        %% reading subMode
        switch subMode
            case 'linkChanged'
                
                %% reading link graphId
                linkGraphId = app.pr_plottingData.graph(graphId).linkGraph;
                
                %% updating widgets
                checkBoxHandle{3}.Value = app.pr_plottingData.graph(linkGraphId).normalize;
                checkBoxHandle{4}.Value = app.pr_plottingData.graph(linkGraphId).addLegend;
                checkBoxHandle{5}.Value = app.pr_plottingData.graph(linkGraphId).flip;
                checkBoxHandle{6}.Value = app.pr_plottingData.graph(linkGraphId).addBox;
                checkBoxHandle{7}.Value = app.pr_plottingData.graph(linkGraphId).split;
                dropDownHandle{3}.Items = app.pr_plottingData.graph(linkGraphId).yDescriptorList;
                dropDownHandle{3}.Value = app.pr_plottingData.graph(linkGraphId).yDescriptor;
                dropDownHandle{4}.Items = app.pr_plottingData.graph(linkGraphId).xDescriptorList;
                dropDownHandle{4}.Value = app.pr_plottingData.graph(linkGraphId).xDescriptor;
                dropDownHandle{5}.Value = app.pr_plottingData.graph(linkGraphId).map;
                dropDownHandle{6}.Value = app.pr_plottingData.graph(linkGraphId).fill;
                dropDownHandle{7}.Items = app.pr_plottingData.graph(linkGraphId).subTypeList;
                dropDownHandle{7}.Value = app.pr_plottingData.graph(linkGraphId).subType;
                dropDownHandle{8}.Items = app.pr_plottingData.graph(linkGraphId).fitList;
                dropDownHandle{8}.Value = app.pr_plottingData.graph(linkGraphId).fit;
                editFieldHandle{3}.Value = string(app.pr_plottingData.graph(linkGraphId).rowNum);
                editFieldHandle{4}.Value = string(app.pr_plottingData.graph(linkGraphId).colNum);
                editFieldHandle{5}.Value = string(app.pr_plottingData.graph(linkGraphId).equation);
                editFieldHandle{6}.Value = string(app.pr_plottingData.graph(linkGraphId).xLine);
                editFieldHandle{7}.Value = string(app.pr_plottingData.graph(linkGraphId).yLine);
                
            case 'yChanged'
                
                %% initializing x descriptor drop down menu
                dropDownHandle{4}.Items = {};
                
                %% reading yDescriptor and analysisModes
                yDescriptor = dropDownHandle{3}.Value;
                analysisModes = app.pr_structuresData.file(1).analysisMode;
                
                %% updating dropdown menus - descriptors
                if ismember(yDescriptor,constantFetcherFn('shapeDescriptor',...
                        'Radial profiling','y'))
                    dropDownHandle{4}.Items = constantFetcherFn('shapeDescriptor',...
                        'Radial profiling','x');
                    dropDownHandle{4}.Value = dropDownHandle{4}.Items{1};
                else
                    for analysisModeId = 1 : numel(analysisModes)
                        if ~strcmp(analysisModes{analysisModeId},'Radial profiling')
                            try
                                dropDownHandle{4}.Items = [dropDownHandle{4}.Items constantFetcherFn('shapeDescriptor',...
                                    analysisModes{analysisModeId},'x')];
                            catch
                                dropDownHandle{4}.Items = constantFetcherFn('shapeDescriptor',...
                                    analysisModes{analysisModeId},'x');
                            end
                        end
                    end
                    if strcmp(yDescriptor,'Events')
                        dropDownHandle{4}.Value = dropDownHandle{4}.Items{1};
                    else
                        dropDownHandle{4}.Items = [constantFetcherFn('shapeDescriptor',...
                            'Reserved','x') dropDownHandle{4}.Items];
                        dropDownHandle{4}.Value = dropDownHandle{4}.Items{1};
                    end
                end
                type = constantFetcherFn('type',dropDownHandle{4}.Value,dropDownHandle{3}.Value);
                dropDownHandle{7}.Items = constantFetcherFn('subType',type);
                dropDownHandle{7}.Value = dropDownHandle{7}.Items{1};
                dropDownHandle{8}.Items = constantFetcherFn('fit',type);
                dropDownHandle{8}.Value = dropDownHandle{8}.Items{1};
            
            case 'xChanged'
                type = constantFetcherFn('type',dropDownHandle{4}.Value,dropDownHandle{3}.Value);
                dropDownHandle{7}.Items = constantFetcherFn('subType',type);
                dropDownHandle{7}.Value = dropDownHandle{7}.Items{1};
                dropDownHandle{8}.Items = constantFetcherFn('fit',type);
                dropDownHandle{8}.Value = dropDownHandle{8}.Items{1};
        end
        
        %% writeing updates
        initializeGraphPropAuxFn(app,'write');
        
    case 'read'
        
        %% reading graphId
        graphId = str2double(listBoxHandle{2}.Value);
        
        %% updating plotting data UI property
        checkBoxHandle{1}.Value = app.pr_plottingData.graph(graphId).include;
        checkBoxHandle{2}.Value = app.pr_plottingData.graph(graphId).includeBinned;
        checkBoxHandle{3}.Value = app.pr_plottingData.graph(graphId).normalize;
        checkBoxHandle{4}.Value = app.pr_plottingData.graph(graphId).addLegend;
        checkBoxHandle{5}.Value = app.pr_plottingData.graph(graphId).flip;
        checkBoxHandle{6}.Value = app.pr_plottingData.graph(graphId).addBox;
        checkBoxHandle{7}.Value = app.pr_plottingData.graph(graphId).split;
        checkBoxHandle{8}.Value = app.pr_plottingData.graph(graphId).link;
        dropDownHandle{1}.Items = app.pr_plottingData.graph(graphId).linkGraphList;
        dropDownHandle{1}.Value = string(app.pr_plottingData.graph(graphId).linkGraph);
        dropDownHandle{2}.Value = app.pr_plottingData.graph(graphId).shapes;
        dropDownHandle{3}.Items = app.pr_plottingData.graph(graphId).yDescriptorList;
        dropDownHandle{3}.Value = app.pr_plottingData.graph(graphId).yDescriptor;
        dropDownHandle{4}.Items = app.pr_plottingData.graph(graphId).xDescriptorList;
        dropDownHandle{4}.Value = app.pr_plottingData.graph(graphId).xDescriptor;
        dropDownHandle{5}.Value = app.pr_plottingData.graph(graphId).map;
        dropDownHandle{6}.Value = app.pr_plottingData.graph(graphId).fill;
        dropDownHandle{7}.Items = app.pr_plottingData.graph(graphId).subTypeList;
        dropDownHandle{7}.Value = app.pr_plottingData.graph(graphId).subType;
        dropDownHandle{8}.Items = app.pr_plottingData.graph(graphId).fitList;
        dropDownHandle{8}.Value = app.pr_plottingData.graph(graphId).fit;
        editFieldHandle{1}.Value = app.pr_plottingData.graph(graphId).label;
        editFieldHandle{2}.Value = string(app.pr_plottingData.graph(graphId).binNum);
        editFieldHandle{3}.Value = string(app.pr_plottingData.graph(graphId).rowNum);
        editFieldHandle{4}.Value = string(app.pr_plottingData.graph(graphId).colNum);
        editFieldHandle{5}.Value = string(app.pr_plottingData.graph(graphId).equation);
        editFieldHandle{6}.Value = string(app.pr_plottingData.graph(graphId).xLine);
        editFieldHandle{7}.Value = string(app.pr_plottingData.graph(graphId).yLine);
        listBoxHandle{3}.Items = app.pr_plottingData.graph(graphId).filesList;
        listBoxHandle{3}.Value = listBoxHandle{3}.Items{app.pr_plottingData.graph(graphId).files};
        
    case 'write'
        
        %% reading graphId
        graphId = str2double(listBoxHandle{2}.Value);
        
        %% updating plotting data UI property
        app.pr_plottingData.length = str2double(app.LEditField7_1.Value);
        app.pr_plottingData.width = str2double(app.WEditField7_1.Value);
        app.pr_plottingData.fontSize = str2double(app.FEditField7_1.Value);
        app.pr_plottingData.graph(graphId).include = checkBoxHandle{1}.Value;
        app.pr_plottingData.graph(graphId).includeBinned = checkBoxHandle{2}.Value;
        app.pr_plottingData.graph(graphId).normalize = checkBoxHandle{3}.Value;
        app.pr_plottingData.graph(graphId).addLegend = checkBoxHandle{4}.Value;
        app.pr_plottingData.graph(graphId).flip = checkBoxHandle{5}.Value;
        app.pr_plottingData.graph(graphId).addBox = checkBoxHandle{6}.Value;
        app.pr_plottingData.graph(graphId).split = checkBoxHandle{7}.Value;
        app.pr_plottingData.graph(graphId).link = checkBoxHandle{8}.Value;
        app.pr_plottingData.graph(graphId).linkGraph = str2double(dropDownHandle{1}.Value);
        app.pr_plottingData.graph(graphId).linkGraphList = dropDownHandle{1}.Items;
        app.pr_plottingData.graph(graphId).shapes = dropDownHandle{2}.Value;
        app.pr_plottingData.graph(graphId).yDescriptor = dropDownHandle{3}.Value;
        app.pr_plottingData.graph(graphId).yDescriptorList = dropDownHandle{3}.Items;
        app.pr_plottingData.graph(graphId).xDescriptor = dropDownHandle{4}.Value;
        app.pr_plottingData.graph(graphId).xDescriptorList = dropDownHandle{4}.Items;
        app.pr_plottingData.graph(graphId).map = dropDownHandle{5}.Value;
        app.pr_plottingData.graph(graphId).fill = dropDownHandle{6}.Value;
        app.pr_plottingData.graph(graphId).subType = dropDownHandle{7}.Value;
        app.pr_plottingData.graph(graphId).subTypeList = dropDownHandle{7}.Items;
        app.pr_plottingData.graph(graphId).fit = dropDownHandle{8}.Value;
        app.pr_plottingData.graph(graphId).fitList = dropDownHandle{8}.Items;
        app.pr_plottingData.graph(graphId).label = editFieldHandle{1}.Value;
        app.pr_plottingData.graph(graphId).binNum = str2double(editFieldHandle{2}.Value);
        app.pr_plottingData.graph(graphId).rowNum = str2double(editFieldHandle{3}.Value);
        app.pr_plottingData.graph(graphId).colNum = str2double(editFieldHandle{4}.Value);
        app.pr_plottingData.graph(graphId).equation = editFieldHandle{5}.Value;
        app.pr_plottingData.graph(graphId).xLine = str2double(editFieldHandle{6}.Value);
        app.pr_plottingData.graph(graphId).yLine = str2double(editFieldHandle{7}.Value);
        app.pr_plottingData.graph(graphId).files = find(strcmp(listBoxHandle{3}.Value,listBoxHandle{3}.Items));
        app.pr_plottingData.graph(graphId).filesList = listBoxHandle{3}.Items;
        
        %% updating edit field 5 enable state
        if strcmp(dropDownHandle{8}.Value,'Custom')
            editFieldHandle{5}.Enable = true;
        else
            editFieldHandle{5}.Enable = false;
        end
end
