function assignmentUpdaterAuxFn(app,varargin)
% assignmentFillerAuxFn - (Auxillary function)
% fills assignment details
%
% Syntax -
% assignmentFillerAuxFn(app)
%
% Parameters -
% - app: ASAP UI class

%% defining handles
spinnerHandle = app.Spinner5_1;
listBoxHandle = app.ListBox5_2;
checkBoxHandle = {app.CheckBox5_1,app.CheckBox5_2};
dropDownHandle = {app.DropDown5_1,app.DropDown5_2,app.DropDown5_3,app.DropDown5_4};
editFieldHandle = {app.EditField5_1,app.EditField5_2};

%% obtaining assignmentId
assignmentId = spinnerHandle.Value;

%% detecting flipping of the spinner
if ~isempty(varargin)
    spinnerFlipped = true;
else
    spinnerFlipped = false;
end

%% updating assignmentData property
if ~spinnerFlipped
    try
        app.pr_assignmentData(assignmentId).shapeBeforeList = listBoxHandle.Items;
        app.pr_assignmentData(assignmentId).shapeBefore = listBoxHandle.Value;
        app.pr_assignmentData(assignmentId).assign = checkBoxHandle{1}.Value;
        app.pr_assignmentData(assignmentId).includeSecondBound = checkBoxHandle{2}.Value;
        app.pr_assignmentData(assignmentId).shapeAfter = dropDownHandle{1}.Value;
        app.pr_assignmentData(assignmentId).descriptor = dropDownHandle{2}.Value;
        app.pr_assignmentData(assignmentId).firstEquality = dropDownHandle{3}.Value;
        app.pr_assignmentData(assignmentId).secondEquality = dropDownHandle{4}.Value;
        app.pr_assignmentData(assignmentId).firstBound = editFieldHandle{1}.Value;
        app.pr_assignmentData(assignmentId).secondBound = editFieldHandle{2}.Value;
    catch
    end
else
    
    %% updating UI or assignment property
    try
        listBoxHandle.Value = app.pr_assignmentData(assignmentId).shapeBefore;
        checkBoxHandle{1}.Value = app.pr_assignmentData(assignmentId).assign;
        checkBoxHandle{2}.Value = app.pr_assignmentData(assignmentId).includeSecondBound;
        dropDownHandle{1}.Value = app.pr_assignmentData(assignmentId).shapeAfter;
        dropDownHandle{2}.Value = app.pr_assignmentData(assignmentId).descriptor;
        dropDownHandle{3}.Value = app.pr_assignmentData(assignmentId).firstEquality;
        dropDownHandle{4}.Value = app.pr_assignmentData(assignmentId).secondEquality;
        editFieldHandle{1}.Value = app.pr_assignmentData(assignmentId).firstBound;
        editFieldHandle{2}.Value = app.pr_assignmentData(assignmentId).secondBound;
    catch
        listBoxHandle.Items = app.pr_trainingData.shapes;
        listBoxHandle.Value = listBoxHandle.Items{1};
        checkBoxHandle{1}.Value = 0;
        checkBoxHandle{2}.Value = 0;
        editFieldHandle{1}.Value = 0;
        editFieldHandle{2}.Value = 0;
        dropDownHandle{1}.Items = ['Bin';app.pr_trainingData.shapes'];
        dropDownHandle{1}.Value = dropDownHandle{1}.Items{1};
        dropDownHandle{2}.Items = app.pr_trainingData.descriptors;
        dropDownHandle{2}.Value = dropDownHandle{2}.Items{1};
    end
end