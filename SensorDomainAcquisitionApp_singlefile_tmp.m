app = localCreateApp();

function app = localCreateApp()
app = struct();
app.AxisIds = uint8([0 1 2]);
app.AxisModels = {'TSA200-B(F)', 'LA100-60'};
app.ShouldStop = false;
app.IsRunning = false;
app.dqIn = [];
app.dqOut = [];
app.vi = [];
app.TMC1 = [];
app.TMCHandle = [];
app.FrequencyData = [];
app.BackgroundS21 = [];
app.BackgroundS11 = [];
app.HasBackground = false;
app.StartPosition = [0 0 0];
app.PlotLines = struct();
app.ParamsLocked = false;
app.BackgroundMoveHeight = 0;
app.VNAConnected = false;

app.UIFigure = uifigure('Name', 'Sensor Domain Acquisition App', ...
    'Position', [80 80 1380 760], ...
    'CloseRequestFcn', @onClose);

app.MainGrid = uigridlayout(app.UIFigure, [1 2]);
app.MainGrid.ColumnWidth = {'2.2x', 620};
app.MainGrid.RowHeight = {'1x'};
app.MainGrid.Padding = [8 8 8 8];
app.MainGrid.ColumnSpacing = 8;

app.PlotPanel = uipanel(app.MainGrid, 'Title', 'Realtime Curves');
app.PlotPanel.Layout.Row = 1;
app.PlotPanel.Layout.Column = 1;

app.PlotGrid = uigridlayout(app.PlotPanel, [3 2]);
app.PlotGrid.RowHeight = {'1x', '1x', '1x'};
app.PlotGrid.ColumnWidth = {'1x', '1x'};
app.PlotGrid.RowSpacing = 6;
app.PlotGrid.ColumnSpacing = 6;
app.PlotGrid.Padding = [6 6 6 6];

app.Axes(1) = uiaxes(app.PlotGrid);
app.Axes(2) = uiaxes(app.PlotGrid);
app.Axes(3) = uiaxes(app.PlotGrid);
app.Axes(4) = uiaxes(app.PlotGrid);
app.Axes(5) = uiaxes(app.PlotGrid);
app.Axes(6) = uiaxes(app.PlotGrid);
for axisIdx = 1:6
    app.Axes(axisIdx).Layout.Row = ceil(axisIdx / 2);
    app.Axes(axisIdx).Layout.Column = mod(axisIdx - 1, 2) + 1;
    grid(app.Axes(axisIdx), 'on');
    hold(app.Axes(axisIdx), 'on');
end
setupAxes();

app.ControlPanel = uipanel(app.MainGrid, 'Title', 'Parameters');
app.ControlPanel.Layout.Row = 1;
app.ControlPanel.Layout.Column = 2;
app.ControlPanel.Scrollable = 'on';
app.ControlPanel.FontWeight = 'bold';

app.ControlRootGrid = uigridlayout(app.ControlPanel, [2 1]);
app.ControlRootGrid.RowHeight = {34, 'fit'};
app.ControlRootGrid.ColumnWidth = {'1x'};
app.ControlRootGrid.RowSpacing = 6;
app.ControlRootGrid.Padding = [4 4 4 4];

app.StateBarGrid = uigridlayout(app.ControlRootGrid, [1 4]);
app.StateBarGrid.RowHeight = {26};
app.StateBarGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
app.StateBarGrid.Padding = [6 4 6 4];
app.StateBarGrid.ColumnSpacing = 6;
app.StateBarGrid.BackgroundColor = [0.96 0.97 0.99];
app.StateBarGrid.Layout.Row = 1;
app.StateBarGrid.Layout.Column = 1;

app.LockStateLabel = uilabel(app.StateBarGrid, 'Text', 'Params: Unlocked');
app.LockStateLabel.Layout.Row = 1;
app.LockStateLabel.Layout.Column = 1;
app.LockStateLabel.HorizontalAlignment = 'center';
app.LockStateLabel.FontWeight = 'bold';

app.BackgroundStateLabel = uilabel(app.StateBarGrid, 'Text', 'Background: Not Loaded');
app.BackgroundStateLabel.Layout.Row = 1;
app.BackgroundStateLabel.Layout.Column = 2;
app.BackgroundStateLabel.HorizontalAlignment = 'center';
app.BackgroundStateLabel.FontWeight = 'bold';

app.VNAStateLabel = uilabel(app.StateBarGrid, 'Text', 'VNA: Disconnected');
app.VNAStateLabel.Layout.Row = 1;
app.VNAStateLabel.Layout.Column = 3;
app.VNAStateLabel.HorizontalAlignment = 'center';
app.VNAStateLabel.FontWeight = 'bold';

app.StageStateLabel = uilabel(app.StateBarGrid, 'Text', 'Stage: Ready');
app.StageStateLabel.Layout.Row = 1;
app.StageStateLabel.Layout.Column = 4;
app.StageStateLabel.HorizontalAlignment = 'center';
app.StageStateLabel.FontWeight = 'bold';

app.SectionGrid = uigridlayout(app.ControlRootGrid, [12 1]);
app.SectionGrid.RowHeight = {28, 'fit', 28, 'fit', 28, 'fit', 28, 'fit', 28, 'fit', 28, 'fit'};
app.SectionGrid.ColumnWidth = {'1x'};
app.SectionGrid.RowSpacing = 6;
app.SectionGrid.Padding = [6 6 6 6];
app.SectionGrid.Layout.Row = 2;
app.SectionGrid.Layout.Column = 1;

[fileGrid, app.FileToggle] = createSection(1, 'Output Preset', false);
[motionGrid, app.MotionToggle] = createSection(3, 'Motion', true);
[vnaGrid, app.VNAToggle] = createSection(5, 'VNA', true);
[niGrid, app.NIToggle] = createSection(7, 'NI DAQ', true);
[pythonGrid, app.PythonToggle] = createSection(9, 'Python && SDK', false);
[runGrid, app.RunToggle] = createSection(11, 'Run && Status', true);

fileRow = 1;
app.FileNoteLabel = uilabel(fileGrid, 'Text', 'Parameter-only area. Save path, background acquisition, and BG lift are in Run && Status.');
app.FileNoteLabel.Layout.Row = fileRow;
app.FileNoteLabel.Layout.Column = [1 4];
app.FileNoteLabel.WordWrap = 'on';
app.FileNoteLabel.FontSize = 10;

motionRow = 1;
app.XDistanceEditField = addNumericField(motionGrid, motionRow, 1, 'X Distance', 21);
app.XStepEditField = addNumericField(motionGrid, motionRow, 2, 'X Step', 1);
motionRow = motionRow + 1;
app.XDirectionDropDown = addDropDown(motionGrid, motionRow, 1, 'X Positive', {'+X', '-X'}, '+X');
app.XModelDropDown = addDropDown(motionGrid, motionRow, 2, 'X Model', app.AxisModels, 'TSA200-B(F)');
motionRow = motionRow + 1;
app.YDistanceEditField = addNumericField(motionGrid, motionRow, 1, 'Y Distance', 21);
app.YStepEditField = addNumericField(motionGrid, motionRow, 2, 'Y Step', 1);
motionRow = motionRow + 1;
app.YDirectionDropDown = addDropDown(motionGrid, motionRow, 1, 'Y Positive', {'+Y', '-Y'}, '-Y');
app.YModelDropDown = addDropDown(motionGrid, motionRow, 2, 'Y Model', app.AxisModels, 'TSA200-B(F)');
motionRow = motionRow + 1;
app.ZDistanceEditField = addNumericField(motionGrid, motionRow, 1, 'Z Distance', 30);
app.ZStepEditField = addNumericField(motionGrid, motionRow, 2, 'Z Step', 2);
motionRow = motionRow + 1;
app.ZDirectionDropDown = addDropDown(motionGrid, motionRow, 1, 'Z Positive', {'+Z', '-Z'}, '+Z');
app.ZModelDropDown = addDropDown(motionGrid, motionRow, 2, 'Z Model', app.AxisModels, 'TSA200-B(F)');
motionRow = motionRow + 1;
app.MotionPauseEditField = addNumericField(motionGrid, motionRow, 1, 'Motion Pause', 2);
app.MotionToleranceEditField = addNumericField(motionGrid, motionRow, 2, 'Move Tol', 0.02);
motionRow = motionRow + 1;
app.MotionPollPauseEditField = addNumericField(motionGrid, motionRow, 1, 'Move Poll (s)', 0.2);

vnaRow = 1;
app.InstrumentIPEditField = addEditField(vnaGrid, vnaRow, 1, 'Instrument IP', '169.254.206.69');
app.TimeoutEditField = addNumericField(vnaGrid, vnaRow, 2, 'Timeout (s)', 100);
vnaRow = vnaRow + 1;
app.StartFreqEditField = addNumericField(vnaGrid, vnaRow, 1, 'Start Freq', 65);
app.StopFreqEditField = addNumericField(vnaGrid, vnaRow, 2, 'Stop Freq', 95);
vnaRow = vnaRow + 1;
app.SweepPointsEditField = addNumericField(vnaGrid, vnaRow, 1, 'Sweep Points', 301);
app.IFBWEditField = addNumericField(vnaGrid, vnaRow, 2, 'IFBW (Hz)', 1000);
vnaRow = vnaRow + 1;
app.PowerEditField = addNumericField(vnaGrid, vnaRow, 1, 'Power (dBm)', 18);
app.SweepCommandEditField = addEditField(vnaGrid, vnaRow, 2, 'Sweep Cmd', 'CALCulate:DATA:MSD? "1,2"');
vnaRow = vnaRow + 1;
app.TraceOrderDropDown = addDropDown(vnaGrid, vnaRow, 1, 'Trace Order', {'S21 then S11', 'S11 then S21'}, 'S21 then S11');
app.BackgroundIFBWEditField = addNumericField(vnaGrid, vnaRow, 2, 'BG IFBW (Hz)', 100);
vnaRow = vnaRow + 1;
app.BackgroundPowerEditField = addNumericField(vnaGrid, vnaRow, 1, 'BG Power (dBm)', 18);

niRow = 1;
app.AIDeviceEditField = addEditField(niGrid, niRow, 1, 'AI Device', 'Dev1');
app.AIChannelEditField = addEditField(niGrid, niRow, 2, 'AI Channel', 'ai0');
niRow = niRow + 1;
app.AIRangeMinEditField = addNumericField(niGrid, niRow, 1, 'AI Min (V)', 0);
app.AIRangeMaxEditField = addNumericField(niGrid, niRow, 2, 'AI Max (V)', 1);
niRow = niRow + 1;
app.AIRateEditField = addNumericField(niGrid, niRow, 1, 'AI Rate (Hz)', 100);
app.AODeviceEditField = addEditField(niGrid, niRow, 2, 'AO Device', 'Dev1');
niRow = niRow + 1;
app.AOChannelEditField = addEditField(niGrid, niRow, 1, 'AO Channel', 'ao0');
app.AOStartEditField = addNumericField(niGrid, niRow, 2, 'AO Start (V)', 0);
niRow = niRow + 1;
app.AOStopEditField = addNumericField(niGrid, niRow, 1, 'AO Stop (V)', 0.3);
app.AOStepEditField = addNumericField(niGrid, niRow, 2, 'AO Step (V)', 0.05);
niRow = niRow + 1;
app.AORangeMinEditField = addNumericField(niGrid, niRow, 1, 'AO Min (V)', 0);
app.AORangeMaxEditField = addNumericField(niGrid, niRow, 2, 'AO Max (V)', 1);
niRow = niRow + 1;
app.AOToleranceEditField = addNumericField(niGrid, niRow, 1, 'AO Tol (V)', 1e-3);
app.AOPollPauseEditField = addNumericField(niGrid, niRow, 2, 'AO Pause (s)', 0.1);

pythonRow = 1;
app.PythonExeEditField = addEditField(pythonGrid, pythonRow, 1, 'Python Exe', 'D:\python\python.exe');
app.SDKPathEditField = addEditField(pythonGrid, pythonRow, 2, 'SDK Path', 'C:\Users\zhaoj\Desktop\TMC-USB SDK-32&64bit\Demo\Python');

runRow = 1;
app.SaveFolderEditField = addEditField(runGrid, runRow, 1, 'Save Folder', fullfile('C:\Users\zhaoj\Desktop', ['lzy' char([27979 37327 25968 25454])], ['Matlab' char([25511 21046])], 'E5080A'));
app.BrowseOutputButton = addWideButton(runGrid, runRow, 2, 'Browse Save', @onBrowseOutput);
runRow = runRow + 1;
app.PrefixEditField = addEditField(runGrid, runRow, 1, 'File Prefix', 'sensor_scan');
app.BackgroundMoveHeightEditField = addNumericField(runGrid, runRow, 2, 'BG Z Lift', 0);
runRow = runRow + 1;
app.LockParamsButton = addStateButton(runGrid, runRow, 1, 'Lock Params', @onToggleParamsLock);
app.AcquireBackgroundButton = addWideButton(runGrid, runRow, 2, 'Acquire BG', @onAcquireBackground);
runRow = runRow + 1;
app.StartButton = addActionButton(runGrid, runRow, 1, 'Start', [0.14 0.50 0.28], @onStart);
app.StopButton = addActionButton(runGrid, runRow, 2, 'Stop', [0.75 0.33 0.22], @onStop);
runRow = runRow + 1;
app.PositionValueLabel = addValueLabel(runGrid, runRow, 'Position', '(0.00, 0.00, 0.00) mm');
runRow = runRow + 1;
app.VoltageValueLabel = addValueLabel(runGrid, runRow, 'Voltage', '0.0000 V');
runRow = runRow + 1;
app.StatusValueLabel = addValueLabel(runGrid, runRow, 'Status', 'Idle');
updateStateBar();

    function setupAxes()
        titles = {'Mag', 'Phase', 'submag', 'S21 0.3v-0v', 'S11 mag', 'S11 submag'};
        ylabels = {'dBmag', 'Phase(deg)', 'submag', 'S21 high-low', 'S11 mag', 'S11 submag'};
        for i = 1:6
            title(app.Axes(i), titles{i});
            xlabel(app.Axes(i), 'Freq (MHz)');
            ylabel(app.Axes(i), ylabels{i});
            app.Axes(i).FontName = 'Segoe UI';
            app.Axes(i).FontSize = 10;
            app.Axes(i).Toolbar.Visible = 'off';
            app.Axes(i).Box = 'on';
        end
        app.PlotLines.MagLow = plot(app.Axes(1), nan, nan, 'b');
        app.PlotLines.MagHigh = plot(app.Axes(1), nan, nan, 'r');
        app.PlotLines.PhaseLow = plot(app.Axes(2), nan, nan, 'b');
        app.PlotLines.PhaseHigh = plot(app.Axes(2), nan, nan, 'r');
        app.PlotLines.SubMagLow = plot(app.Axes(3), nan, nan, 'b');
        app.PlotLines.SubMagHigh = plot(app.Axes(3), nan, nan, 'r');
        app.PlotLines.DeltaS21 = plot(app.Axes(4), nan, nan, 'b');
        app.PlotLines.S11MagLow = plot(app.Axes(5), nan, nan, 'b');
        app.PlotLines.S11MagHigh = plot(app.Axes(5), nan, nan, 'r');
        app.PlotLines.S11SubLow = plot(app.Axes(6), nan, nan, 'b');
        app.PlotLines.S11SubHigh = plot(app.Axes(6), nan, nan, 'r');
    end

    function [contentGrid, toggleButton] = createSection(headerRow, titleText, isExpanded)
        toggleButton = uibutton(app.SectionGrid, 'state');
        toggleButton.Text = getToggleTitle(titleText, isExpanded);
        toggleButton.Value = isExpanded;
        toggleButton.FontWeight = 'bold';
        toggleButton.FontSize = 12;
        toggleButton.HorizontalAlignment = 'left';
        toggleButton.BackgroundColor = [0.95 0.96 0.98];
        toggleButton.Layout.Row = headerRow;
        toggleButton.Layout.Column = 1;

        panel = uipanel(app.SectionGrid);
        panel.Layout.Row = headerRow + 1;
        panel.Layout.Column = 1;
        panel.BorderType = 'none';
        panel.BackgroundColor = [0.99 0.99 1.00];

        contentGrid = uigridlayout(panel, [8 4]);
        contentGrid.ColumnWidth = {92, '1x', 92, '1x'};
        contentGrid.RowHeight = repmat({24}, 1, 8);
        contentGrid.RowSpacing = 5;
        contentGrid.ColumnSpacing = 8;
        contentGrid.Padding = [6 4 6 4];

        if ~isExpanded
            panel.Visible = 'off';
            app.SectionGrid.RowHeight{headerRow + 1} = 0;
        end

        toggleButton.ValueChangedFcn = @(btn, ~) toggleSection(btn, panel, headerRow + 1, titleText);
    end

    function toggleSection(button, panel, contentRow, titleText)
        isExpanded = logical(button.Value);
        button.Text = getToggleTitle(titleText, isExpanded);
        panel.Visible = matlab.lang.OnOffSwitchState(isExpanded);
        if isExpanded
            app.SectionGrid.RowHeight{contentRow} = 'fit';
        else
            app.SectionGrid.RowHeight{contentRow} = 0;
        end
    end

    function textValue = getToggleTitle(titleText, isExpanded)
        if isExpanded
            textValue = ['v  ' titleText];
        else
            textValue = ['>  ' titleText];
        end
    end

    function [labelCol, fieldCol] = getPairColumns(pairIndex)
        if pairIndex == 1
            labelCol = 1;
            fieldCol = 2;
        else
            labelCol = 3;
            fieldCol = 4;
        end
    end

    function field = addEditField(parentGrid, currentRow, pairIndex, labelText, defaultValue)
        [labelCol, fieldCol] = getPairColumns(pairIndex);
        label = uilabel(parentGrid, 'Text', labelText);
        label.Layout.Row = currentRow;
        label.Layout.Column = labelCol;
        label.FontSize = 10;
        field = uieditfield(parentGrid, 'text', 'Value', defaultValue);
        field.Layout.Row = currentRow;
        field.Layout.Column = fieldCol;
        field.FontSize = 10;
    end

    function field = addNumericField(parentGrid, currentRow, pairIndex, labelText, defaultValue)
        [labelCol, fieldCol] = getPairColumns(pairIndex);
        label = uilabel(parentGrid, 'Text', labelText);
        label.Layout.Row = currentRow;
        label.Layout.Column = labelCol;
        label.FontSize = 10;
        field = uieditfield(parentGrid, 'numeric', 'Value', defaultValue);
        field.Layout.Row = currentRow;
        field.Layout.Column = fieldCol;
        field.FontSize = 10;
    end

    function field = addDropDown(parentGrid, currentRow, pairIndex, labelText, items, defaultValue)
        [labelCol, fieldCol] = getPairColumns(pairIndex);
        label = uilabel(parentGrid, 'Text', labelText);
        label.Layout.Row = currentRow;
        label.Layout.Column = labelCol;
        label.FontSize = 10;
        field = uidropdown(parentGrid, 'Items', items, 'Value', defaultValue);
        field.Layout.Row = currentRow;
        field.Layout.Column = fieldCol;
        field.FontSize = 10;
    end

    function button = addButton(parentGrid, currentRow, pairIndex, buttonText, callbackFcn)
        [labelCol, fieldCol] = getPairColumns(pairIndex);
        label = uilabel(parentGrid, 'Text', '');
        label.Layout.Row = currentRow;
        label.Layout.Column = labelCol;
        button = uibutton(parentGrid, 'push', 'Text', buttonText, 'ButtonPushedFcn', callbackFcn);
        button.Layout.Row = currentRow;
        button.Layout.Column = fieldCol;
        button.FontSize = 10;
    end

    function button = addWideButton(parentGrid, currentRow, pairIndex, buttonText, callbackFcn)
        [labelCol, fieldCol] = getPairColumns(pairIndex);
        label = uilabel(parentGrid, 'Text', '');
        label.Layout.Row = currentRow;
        label.Layout.Column = labelCol;
        button = uibutton(parentGrid, 'push', 'Text', buttonText, 'ButtonPushedFcn', callbackFcn);
        button.Layout.Row = currentRow;
        button.Layout.Column = fieldCol;
        button.FontSize = 10;
    end

    function button = addActionButton(parentGrid, currentRow, pairIndex, buttonText, buttonColor, callbackFcn)
        [labelCol, fieldCol] = getPairColumns(pairIndex);
        label = uilabel(parentGrid, 'Text', '');
        label.Layout.Row = currentRow;
        label.Layout.Column = labelCol;
        button = uibutton(parentGrid, 'push', 'Text', buttonText, 'ButtonPushedFcn', callbackFcn);
        button.Layout.Row = currentRow;
        button.Layout.Column = fieldCol;
        button.FontWeight = 'bold';
        button.FontSize = 11;
        button.BackgroundColor = buttonColor;
        button.FontColor = [1 1 1];
    end

    function button = addStateButton(parentGrid, currentRow, pairIndex, buttonText, callbackFcn)
        [labelCol, fieldCol] = getPairColumns(pairIndex);
        label = uilabel(parentGrid, 'Text', '');
        label.Layout.Row = currentRow;
        label.Layout.Column = labelCol;
        button = uibutton(parentGrid, 'state', 'Text', buttonText, 'ValueChangedFcn', callbackFcn);
        button.Layout.Row = currentRow;
        button.Layout.Column = fieldCol;
        button.FontSize = 10;
        button.FontWeight = 'bold';
    end

    function label = addValueLabel(parentGrid, currentRow, nameText, valueText)
        left = uilabel(parentGrid, 'Text', nameText);
        left.Layout.Row = currentRow;
        left.Layout.Column = 1;
        left.FontWeight = 'bold';
        left.FontSize = 10;
        label = uilabel(parentGrid, 'Text', valueText);
        label.Layout.Row = currentRow;
        label.Layout.Column = [2 4];
        label.FontSize = 10;
        label.WordWrap = 'on';
    end

    function onBrowseOutput(~, ~)
        p = uigetdir(app.SaveFolderEditField.Value, 'Select output folder');
        if isequal(p, 0), return; end
        app.SaveFolderEditField.Value = p;
    end

    function onAcquireBackground(~, ~)
        if ~app.ParamsLocked
            uialert(app.UIFigure, 'Click Lock Params before acquiring background.', 'Lock Params First');
            return;
        end
        app.StageStateLabel.Text = 'Stage: Moving for BG';
        setStatus('Acquiring background traces...');
        try
            params = readParams();
            acquireBackground(params);
            app.HasBackground = true;
            updateStateBar();
            setStatus('Background acquired and loaded');
        catch ME
            app.StageStateLabel.Text = 'Stage: Error';
            setStatus(['BG Error: ' ME.message]);
            uialert(app.UIFigure, ME.message, 'Background Acquisition Error');
        end
    end

    function onToggleParamsLock(button, ~)
        if logical(button.Value)
            setStatus('Testing VNA connection...');
            app.StageStateLabel.Text = 'Stage: VNA Check';
            try
                params = readParams();
                idn = testVNAConnection(params);
                app.ParamsLocked = true;
                app.VNAConnected = true;
                button.Text = 'Params Locked';
                setStatus(['VNA connected: ' idn]);
                app.StageStateLabel.Text = 'Stage: Ready';
            catch ME
                app.ParamsLocked = false;
                app.VNAConnected = false;
                button.Value = false;
                button.Text = 'Lock Params';
                app.StageStateLabel.Text = 'Stage: VNA Error';
                setStatus(['VNA connect failed: ' ME.message]);
                updateStateBar();
                uialert(app.UIFigure, ME.message, 'VNA Connection Error');
                return;
            end
        else
            app.ParamsLocked = false;
            app.VNAConnected = false;
            button.Text = 'Lock Params';
            app.HasBackground = false;
            app.BackgroundS21 = [];
            app.BackgroundS11 = [];
            app.FrequencyData = [];
            app.StageStateLabel.Text = 'Stage: Ready';
            setStatus('Parameters unlocked');
        end
        setParameterControlsEnabled(~app.ParamsLocked);
        updateStateBar();
    end

    function onStart(~, ~)
        if app.IsRunning, return; end
        if ~app.ParamsLocked
            uialert(app.UIFigure, 'Click Lock Params before starting acquisition.', 'Lock Params First');
            return;
        end
        if ~app.HasBackground || isempty(app.BackgroundS21) || isempty(app.BackgroundS11)
            uialert(app.UIFigure, 'Acquire background with Acquire BG before starting the scan.', 'Acquire Background First');
            return;
        end
        app.IsRunning = true;
        app.ShouldStop = false;
        app.StartButton.Enable = 'off';
        app.StageStateLabel.Text = 'Stage: Scanning';
        setStatus('Preparing hardware...');
        try
            params = readParams();
            setupHardware(params);
            runAcquisition(params);
            if app.ShouldStop
                setStatus('Stopped and returned to start position');
            else
                setStatus('Completed');
            end
            app.StageStateLabel.Text = 'Stage: Ready';
        catch ME
            app.StageStateLabel.Text = 'Stage: Error';
            setStatus(['Error: ' ME.message]);
            uialert(app.UIFigure, ME.message, 'Acquisition Error');
        end
        cleanupHardware();
        app.StartButton.Enable = 'on';
        app.IsRunning = false;
    end

    function onStop(~, ~)
        app.ShouldStop = true;
        if app.IsRunning
            setStatus('Stopping after current step...');
        end
    end

    function onClose(~, ~)
        app.ShouldStop = true;
        if app.IsRunning
            setStatus('Closing after safe stop...');
            return;
        end
        cleanupHardware();
        delete(app.UIFigure);
    end

    function params = readParams()
        params.saveFolder = strtrim(app.SaveFolderEditField.Value);
        if ~isfolder(params.saveFolder), mkdir(params.saveFolder); end
        params.prefix = strtrim(app.PrefixEditField.Value);
        if isempty(params.prefix), params.prefix = 'sensor_scan'; end
        params.motionPause = app.MotionPauseEditField.Value;
        params.moveTol = app.MotionToleranceEditField.Value;
        params.movePollPause = app.MotionPollPauseEditField.Value;
        params.bgLift = app.BackgroundMoveHeightEditField.Value;
        params.vTol = app.AOToleranceEditField.Value;
        params.vPause = app.AOPollPauseEditField.Value;
        params.ip = strtrim(app.InstrumentIPEditField.Value);
        params.startFreq = app.StartFreqEditField.Value;
        params.stopFreq = app.StopFreqEditField.Value;
        params.points = round(app.SweepPointsEditField.Value);
        params.ifbw = app.IFBWEditField.Value;
        params.power = app.PowerEditField.Value;
        params.bgPower = app.BackgroundPowerEditField.Value;
        params.timeout = app.TimeoutEditField.Value;
        params.cmd = strtrim(app.SweepCommandEditField.Value);
        params.traceOrder = app.TraceOrderDropDown.Value;
        params.bgIfbw = app.BackgroundIFBWEditField.Value;
        params.aiDev = strtrim(app.AIDeviceEditField.Value);
        params.aiChan = strtrim(app.AIChannelEditField.Value);
        params.aiRange = [app.AIRangeMinEditField.Value app.AIRangeMaxEditField.Value];
        params.aiRate = app.AIRateEditField.Value;
        params.aoDev = strtrim(app.AODeviceEditField.Value);
        params.aoChan = strtrim(app.AOChannelEditField.Value);
        params.aoRange = [app.AORangeMinEditField.Value app.AORangeMaxEditField.Value];
        params.voltages = buildVector(app.AOStartEditField.Value, app.AOStopEditField.Value, app.AOStepEditField.Value, 1);
        params.py = strtrim(app.PythonExeEditField.Value);
        params.sdk = strtrim(app.SDKPathEditField.Value);
        params.axis(1) = buildAxisParam(app.XDistanceEditField.Value, app.XStepEditField.Value, app.XDirectionDropDown.Value, app.XModelDropDown.Value);
        params.axis(2) = buildAxisParam(app.YDistanceEditField.Value, app.YStepEditField.Value, app.YDirectionDropDown.Value, app.YModelDropDown.Value);
        params.axis(3) = buildAxisParam(app.ZDistanceEditField.Value, app.ZStepEditField.Value, app.ZDirectionDropDown.Value, app.ZModelDropDown.Value);
    end

    function axisParam = buildAxisParam(distance, step, dirValue, model)
        signValue = 1;
        if contains(dirValue, '-'), signValue = -1; end
        axisParam.distance = distance;
        axisParam.step = step;
        axisParam.model = model;
        axisParam.positions = buildVector(0, distance, step, signValue);
    end

    function vec = buildVector(startValue, stopValue, stepValue, signValue)
        if stepValue <= 0, error('Step must be positive.'); end
        if stopValue < startValue, error('Stop value must be >= start value.'); end
        vec = startValue:stepValue:stopValue;
        if isempty(vec) || abs(vec(end) - stopValue) > 1e-9
            vec = [vec stopValue];
        end
        vec = signValue .* vec;
    end

    function acquireBackground(params)
        obj = instrfind;
        if ~isempty(obj), fclose(obj); delete(obj); end
        localVi = [];
        cleanupObj = onCleanup(@() cleanupVisa(localVi)); %#ok<NASGU>
        localTMC = [];
        localHandle = [];
        homePosition = 0;
        cleanupStageObj = onCleanup(@() cleanupBackgroundStage(localTMC, localHandle, homePosition, params.moveTol, params.movePollPause)); %#ok<NASGU>

        pyenv('Version', params.py);
        pyPaths = cellfun(@char, cell(py.sys.path()), 'UniformOutput', false);
        if ~any(strcmp(pyPaths, params.sdk)), py.sys.path().append(params.sdk); end
        module = py.importlib.import_module('devices_TMC_USB');
        localTMC = module.TMC_USB();
        localHandle = initTMCWithDevice(localTMC, params);
        basePosition = double(localTMC.tmc_get_position(localHandle, app.AxisIds(3)));
        homePosition = basePosition;
        targetPosition = basePosition + params.bgLift * getDirectionSign(app.ZDirectionDropDown.Value);
        app.StageStateLabel.Text = sprintf('Stage: BG Lift %.2f mm', targetPosition);
        moveAxisAbsoluteChecked(localTMC, localHandle, 3, targetPosition, params.moveTol, params.movePollPause);

        address = sprintf('TCPIP0::%s::hislip0::INSTR', params.ip);
        localVi = visa('AGILENT', address);
        set(localVi, 'InputBufferSize', 200000);
        set(localVi, 'Timeout', params.timeout);
        fopen(localVi);
        bgParams = params;
        bgParams.ifbw = params.bgIfbw;
        bgParams.power = params.bgPower;
        configureVNAForVisa(localVi, bgParams);
        fprintf(localVi, ':INIT:CONT OFF');
        fprintf(localVi, ':INITiate1:IMMediate; *WAI');
        app.FrequencyData = linspace(params.startFreq, params.stopFreq, params.points);
        sData = collectSDataFromVisa(localVi, params.cmd);
        [app.BackgroundS21, app.BackgroundS11] = splitTracePair(sData, params.points, params.traceOrder);
        refreshBackgroundPlots();
        cleanupBackgroundStage(localTMC, localHandle, homePosition, params.moveTol, params.movePollPause);
        localHandle = [];
        app.StageStateLabel.Text = sprintf('Stage: BG Done, back to %.2f mm', homePosition);
    end

    function setupHardware(params)
        cleanupHardware();
        obj = instrfind;
        if ~isempty(obj), fclose(obj); delete(obj); end
        app.dqIn = daq("ni");
        aiChannel = addinput(app.dqIn, params.aiDev, params.aiChan, "Voltage");
        aiChannel.Range = params.aiRange;
        app.dqIn.Rate = params.aiRate;
        app.dqOut = daq("ni");
        aoChannel = addoutput(app.dqOut, params.aoDev, params.aoChan, "Voltage");
        aoChannel.Range = params.aoRange;
        pyenv('Version', params.py);
        pyPaths = cellfun(@char, cell(py.sys.path()), 'UniformOutput', false);
        if ~any(strcmp(pyPaths, params.sdk)), py.sys.path().append(params.sdk); end
        module = py.importlib.import_module('devices_TMC_USB');
        app.TMC1 = module.TMC_USB();
        app.TMCHandle = initTMC(params);
        address = sprintf('TCPIP0::%s::hislip0::INSTR', params.ip);
        app.vi = visa('AGILENT', address);
        set(app.vi, 'InputBufferSize', 200000);
        set(app.vi, 'Timeout', params.timeout);
        fopen(app.vi);
        app.FrequencyData = configureVNA(params);
        if numel(app.FrequencyData) ~= numel(app.BackgroundS21) || numel(app.FrequencyData) ~= numel(app.BackgroundS11)
            error('Background data length does not match VNA sweep points.');
        end
        app.StartPosition = readXYZ();
        write(app.dqOut, params.voltages(1));
        updateVoltage(params.voltages(1));
    end

    function handle = initTMC(params)
        deviceCount = double(app.TMC1.tmc_device_count());
        if deviceCount <= 0, error('No TMC device found.'); end
        handle = app.TMC1.tmc_open(int32(deviceCount - 1));
        for axisIdx = 1:3
            app.TMC1.tmc_init(handle, app.AxisIds(axisIdx), params.axis(axisIdx).model);
            app.TMC1.tmc_set_axis_enable(handle, app.AxisIds(axisIdx), true);
            app.TMC1.tmc_set_unit(handle, app.AxisIds(axisIdx), int32(2));
        end
        pause(4);
    end

    function handle = initTMCWithDevice(tmcDevice, params)
        deviceCount = double(tmcDevice.tmc_device_count());
        if deviceCount <= 0, error('No TMC device found.'); end
        handle = tmcDevice.tmc_open(int32(deviceCount - 1));
        for axisIdx = 1:3
            tmcDevice.tmc_init(handle, app.AxisIds(axisIdx), params.axis(axisIdx).model);
            tmcDevice.tmc_set_axis_enable(handle, app.AxisIds(axisIdx), true);
            tmcDevice.tmc_set_unit(handle, app.AxisIds(axisIdx), int32(2));
        end
        pause(4);
    end

    function frequency = configureVNA(params)
        fprintf(app.vi, 'SOUR:POWER %g', params.power);
        fprintf(app.vi, 'SENS:FREQ:START %gMHz', params.startFreq);
        fprintf(app.vi, 'SENS:FREQ:STOP %gMHz', params.stopFreq);
        fprintf(app.vi, 'SENS:SWEEP:POINTS %d', params.points);
        fprintf(app.vi, 'SENS:BAND %g', params.ifbw);
        fprintf(app.vi, 'CALC:PAR:MNUM 1');
        fprintf(app.vi, 'FORM:BORD SWAP');
        fprintf(app.vi, 'FORM REAL,64');
        frequency = linspace(params.startFreq, params.stopFreq, params.points);
    end

    function runAcquisition(params)
        xPos = params.axis(1).positions;
        yPos = params.axis(2).positions;
        zPos = params.axis(3).positions;
        numVoltages = numel(params.voltages);
        numPoints = numel(app.FrequencyData);
        numXY = numel(xPos) * numel(yPos);
        for iz = 1:numel(zPos)
            if app.ShouldStop, break; end
            moveAxisAbsolute(3, app.StartPosition(3) + zPos(iz), params.motionPause);
            allS21Data = complex(zeros(numPoints, numXY, numVoltages));
            allS11Data = complex(zeros(numPoints, numXY, numVoltages));
            scanLog = table('Size', [numXY 3], 'VariableTypes', {'double', 'double', 'double'}, 'VariableNames', {'Index', 'X_mm', 'Y_mm'});
            posnum = 1;
            for iy = 1:numel(yPos)
                if app.ShouldStop, break; end
                moveAxisAbsoluteChecked(app.TMC1, app.TMCHandle, 2, app.StartPosition(2) + yPos(iy), params.moveTol, params.movePollPause);
                for ix = 1:numel(xPos)
                    if app.ShouldStop, break; end
                    moveAxisAbsolute(1, app.StartPosition(1) + xPos(ix), params.motionPause);
                    for iv = 1:numVoltages
                        if app.ShouldStop, break; end
                        measuredV = setOutputVoltage(params.voltages(iv), params.vTol, params.vPause);
                        fprintf(app.vi, ':INITiate1:IMMediate; *WAI');
                        s = collectSData(params.cmd);
                        [s21Trace, s11Trace] = splitTracePair(s, numPoints, params.traceOrder);
                        allS21Data(:, posnum, iv) = s21Trace;
                        allS11Data(:, posnum, iv) = s11Trace;
                        updateVoltage(measuredV);
                    end
                    xyz = readXYZ();
                    scanLog.Index(posnum) = posnum;
                    scanLog.X_mm(posnum) = xyz(1);
                    scanLog.Y_mm(posnum) = xyz(2);
                    updatePosition(xyz);
                    updatePlots(allS21Data(:, posnum, :), allS11Data(:, posnum, :));
                    posnum = posnum + 1;
                end
            end
            moveAxisAbsolute(1, app.StartPosition(1), params.motionPause);
            moveAxisAbsolute(2, app.StartPosition(2), params.motionPause);
            zNow = getAxisPosition(3);
            updatePosition([app.StartPosition(1) app.StartPosition(2) zNow]);
            saveZFile(params, iz, zNow, xPos, yPos, allS21Data, allS11Data, scanLog);
        end
        returnToStart(params.motionPause, params.moveTol, params.movePollPause);
    end

    function value = setOutputVoltage(target, tolerance, pauseSec)
        write(app.dqOut, target);
        value = readInputVoltage();
        while abs(value - target) > tolerance
            if app.ShouldStop, return; end
            pause(pauseSec);
            value = readInputVoltage();
        end
    end

    function value = readInputVoltage()
        t = read(app.dqIn);
        fieldName = t.Properties.VariableNames{1};
        value = t.(fieldName);
    end

    function s = collectSData(cmd)
        fprintf(app.vi, cmd);
        [data, ~, ~] = binblockread(app.vi, 'double');
        fscanf(app.vi);
        s = data(1:2:end) + 1i * data(2:2:end);
    end

    function s = collectSDataFromVisa(viObj, cmd)
        fprintf(viObj, cmd);
        [data, ~, ~] = binblockread(viObj, 'double');
        fscanf(viObj);
        s = data(1:2:end) + 1i * data(2:2:end);
    end

    function [s21Trace, s11Trace] = splitTracePair(traceData, numPoints, traceOrder)
        if numel(traceData) < 2 * numPoints
            error('Trace data length is shorter than expected.');
        end
        firstTrace = traceData(1:numPoints);
        secondTrace = traceData(numPoints+1:2*numPoints);
        if strcmp(traceOrder, 'S11 then S21')
            s11Trace = firstTrace(:);
            s21Trace = secondTrace(:);
        else
            s21Trace = firstTrace(:);
            s11Trace = secondTrace(:);
        end
    end

    function configureVNAForVisa(viObj, params)
        fprintf(viObj, 'SOUR:POWER %g', params.power);
        fprintf(viObj, 'SENS:FREQ:START %gMHz', params.startFreq);
        fprintf(viObj, 'SENS:FREQ:STOP %gMHz', params.stopFreq);
        fprintf(viObj, 'SENS:SWEEP:POINTS %d', params.points);
        fprintf(viObj, 'SENS:BAND %g', params.ifbw);
        fprintf(viObj, 'CALC:PAR:MNUM 1');
        fprintf(viObj, 'FORM:BORD SWAP');
        fprintf(viObj, 'FORM REAL,64');
    end

    function refreshBackgroundPlots()
        if isempty(app.FrequencyData) || isempty(app.BackgroundS21) || isempty(app.BackgroundS11)
            return;
        end
        app.PlotLines.MagLow.XData = app.FrequencyData;
        app.PlotLines.MagLow.YData = 20 * log10(abs(app.BackgroundS21));
        app.PlotLines.MagHigh.XData = app.FrequencyData;
        app.PlotLines.MagHigh.YData = nan(size(app.BackgroundS21));
        app.PlotLines.S11MagLow.XData = app.FrequencyData;
        app.PlotLines.S11MagLow.YData = 20 * log10(abs(app.BackgroundS11));
        app.PlotLines.S11MagHigh.XData = app.FrequencyData;
        app.PlotLines.S11MagHigh.YData = nan(size(app.BackgroundS11));
        drawnow limitrate;
    end

    function signValue = getDirectionSign(directionValue)
        signValue = 1;
        if contains(directionValue, '-')
            signValue = -1;
        end
    end

    function cleanupBackgroundStage(tmcDevice, handle, homePosition, tolerance, pollPause)
        if isempty(tmcDevice) || isempty(handle)
            return;
        end
        try
            app.StageStateLabel.Text = 'Stage: Returning Home';
            moveAxisAbsoluteChecked(tmcDevice, handle, 3, homePosition, tolerance, pollPause);
        catch
        end
        try
            tmcDevice.tmc_close(handle);
        catch
        end
    end

    function updateStateBar()
        if app.ParamsLocked
            app.LockStateLabel.Text = 'Params: Locked';
            app.LockStateLabel.FontColor = [0.08 0.42 0.18];
        else
            app.LockStateLabel.Text = 'Params: Unlocked';
            app.LockStateLabel.FontColor = [0.65 0.32 0.12];
        end

        if app.HasBackground
            app.BackgroundStateLabel.Text = 'Background: Loaded';
            app.BackgroundStateLabel.FontColor = [0.08 0.42 0.18];
        else
            app.BackgroundStateLabel.Text = 'Background: Not Loaded';
            app.BackgroundStateLabel.FontColor = [0.65 0.32 0.12];
        end

        if app.VNAConnected
            app.VNAStateLabel.Text = 'VNA: Connected';
            app.VNAStateLabel.FontColor = [0.08 0.42 0.18];
        else
            app.VNAStateLabel.Text = 'VNA: Disconnected';
            app.VNAStateLabel.FontColor = [0.65 0.32 0.12];
        end

        if isempty(app.StageStateLabel.Text)
            app.StageStateLabel.Text = 'Stage: Ready';
        end
    end

    function updatePlots(s21Cube, s11Cube)
        s21Low = s21Cube(:, 1, 1);
        s21High = s21Cube(:, 1, end);
        s11Low = s11Cube(:, 1, 1);
        s11High = s11Cube(:, 1, end);
        app.PlotLines.MagLow.XData = app.FrequencyData;
        app.PlotLines.MagLow.YData = 20 * log10(abs(s21Low));
        app.PlotLines.MagHigh.XData = app.FrequencyData;
        app.PlotLines.MagHigh.YData = 20 * log10(abs(s21High));
        phaseLow = unwrap(angle(s21Low)) * (180 / pi);
        phaseLowBase = linspace(phaseLow(1), phaseLow(end), numel(phaseLow));
        app.PlotLines.PhaseLow.XData = app.FrequencyData;
        app.PlotLines.PhaseLow.YData = phaseLow(:) - phaseLowBase(:);
        phaseHigh = unwrap(angle(s21High)) * (180 / pi);
        phaseHighBase = linspace(phaseHigh(1), phaseHigh(end), numel(phaseHigh));
        app.PlotLines.PhaseHigh.XData = app.FrequencyData;
        app.PlotLines.PhaseHigh.YData = phaseHigh(:) - phaseHighBase(:);
        app.PlotLines.SubMagLow.XData = app.FrequencyData;
        app.PlotLines.SubMagLow.YData = 20 * log10(abs(s21Low - app.BackgroundS21));
        app.PlotLines.SubMagHigh.XData = app.FrequencyData;
        app.PlotLines.SubMagHigh.YData = 20 * log10(abs(s21High - app.BackgroundS21));
        app.PlotLines.DeltaS21.XData = app.FrequencyData;
        app.PlotLines.DeltaS21.YData = 20 * log10(abs(s21High - s21Low));
        app.PlotLines.S11MagLow.XData = app.FrequencyData;
        app.PlotLines.S11MagLow.YData = 20 * log10(abs(s11Low));
        app.PlotLines.S11MagHigh.XData = app.FrequencyData;
        app.PlotLines.S11MagHigh.YData = 20 * log10(abs(s11High));
        app.PlotLines.S11SubLow.XData = app.FrequencyData;
        app.PlotLines.S11SubLow.YData = 20 * log10(abs(s11Low - app.BackgroundS11));
        app.PlotLines.S11SubHigh.XData = app.FrequencyData;
        app.PlotLines.S11SubHigh.YData = 20 * log10(abs(s11High - app.BackgroundS11));
        drawnow limitrate;
    end

    function saveZFile(params, iz, zNow, xPos, yPos, allS21Data, allS11Data, scanLog)
        freqData = app.FrequencyData;
        metadata = struct('savedAt', char(datetime('now', 'Format', 'yyyy-MM-dd''T''HH:mm:ss')), ...
            'zIndex', iz - 1, 'zPositionMM', zNow, 'xPositions', xPos, 'yPositions', yPos, ...
            'outputVoltages', params.voltages, 'axisModels', {{params.axis.model}}, ...
            'vna', struct('startFreqMHz', params.startFreq, 'stopFreqMHz', params.stopFreq, 'points', params.points, 'ifbwHz', params.ifbw, 'powerdBm', params.power, 'command', params.cmd), ...
            'ni', struct('aiDevice', params.aiDev, 'aiChannel', params.aiChan, 'aiRange', params.aiRange, 'aoDevice', params.aoDev, 'aoChannel', params.aoChan, 'aoRange', params.aoRange));
        fileName = sprintf('%s_z%02d_%0.3fmm.mat', params.prefix, iz - 1, zNow);
        fileName = strrep(fileName, '-', 'm');
        save(fullfile(params.saveFolder, fileName), 'freqData', 'allS21Data', 'allS11Data', 'scanLog', 'metadata');
    end

    function moveAxisAbsolute(axisNumber, targetPosition, pauseSec)
        app.TMC1.tmc_absolute_move(app.TMCHandle, app.AxisIds(axisNumber), double(targetPosition));
        pause(pauseSec);
        app.TMC1.tmc_stop(app.TMCHandle, app.AxisIds(axisNumber));
    end

    function moveAxisAbsoluteChecked(tmcDevice, handle, axisNumber, targetPosition, tolerance, pollPause)
        tmcDevice.tmc_absolute_move(handle, app.AxisIds(axisNumber), double(targetPosition));
        while true
            currentPosition = double(tmcDevice.tmc_get_position(handle, app.AxisIds(axisNumber)));
            if abs(currentPosition - targetPosition) <= tolerance
                break;
            end
            if app.ShouldStop
                break;
            end
            pause(pollPause);
        end
        tmcDevice.tmc_stop(handle, app.AxisIds(axisNumber));
    end

    function xyz = readXYZ()
        xyz = [getAxisPosition(1) getAxisPosition(2) getAxisPosition(3)];
    end

    function value = getAxisPosition(axisNumber)
        value = double(app.TMC1.tmc_get_position(app.TMCHandle, app.AxisIds(axisNumber)));
    end

    function returnToStart(pauseSec, tolerance, pollPause)
        if isempty(app.TMC1) || isempty(app.TMCHandle), return; end
        for axisIdx = 1:3
            moveAxisAbsoluteChecked(app.TMC1, app.TMCHandle, axisIdx, app.StartPosition(axisIdx), tolerance, pollPause);
        end
        updatePosition(app.StartPosition);
    end

    function idn = testVNAConnection(params)
        testVi = [];
        cleanupObj = onCleanup(@() cleanupVisa(testVi)); %#ok<NASGU>
        obj = instrfind;
        if ~isempty(obj), fclose(obj); delete(obj); end
        address = sprintf('TCPIP0::%s::hislip0::INSTR', params.ip);
        testVi = visa('AGILENT', address);
        set(testVi, 'InputBufferSize', 200000);
        set(testVi, 'Timeout', params.timeout);
        fopen(testVi);
        fprintf(testVi, '*IDN?');
        idn = strtrim(fscanf(testVi));
        if isempty(idn)
            idn = params.ip;
        end
    end

    function cleanupHardware()
        if ~isempty(app.dqOut)
            try
                write(app.dqOut, 0);
            catch
            end
        end
        if ~isempty(app.TMC1) && ~isempty(app.TMCHandle)
            try
                app.TMC1.tmc_close(app.TMCHandle);
            catch
            end
        end
        if ~isempty(app.vi)
            try
                if strcmp(app.vi.Status, 'open')
                    fclose(app.vi);
                end
            catch
            end
            try
                delete(app.vi);
            catch
            end
        end
        app.dqIn = [];
        app.dqOut = [];
        app.vi = [];
        app.TMC1 = [];
        app.TMCHandle = [];
        app.VNAConnected = false;
        updateStateBar();
    end

    function cleanupVisa(viObj)
        if isempty(viObj)
            return;
        end
        try
            if strcmp(viObj.Status, 'open')
                fclose(viObj);
            end
        catch
        end
        try
            delete(viObj);
        catch
        end
    end

    function setParameterControlsEnabled(isEnabled)
        state = matlab.lang.OnOffSwitchState(isEnabled);
        controls = [
            app.PrefixEditField
            app.SaveFolderEditField
            app.BrowseOutputButton
            app.XDistanceEditField
            app.XStepEditField
            app.XDirectionDropDown
            app.XModelDropDown
            app.YDistanceEditField
            app.YStepEditField
            app.YDirectionDropDown
            app.YModelDropDown
            app.ZDistanceEditField
            app.ZStepEditField
            app.ZDirectionDropDown
            app.ZModelDropDown
            app.MotionPauseEditField
            app.MotionToleranceEditField
            app.MotionPollPauseEditField
            app.InstrumentIPEditField
            app.StartFreqEditField
            app.StopFreqEditField
            app.SweepPointsEditField
            app.IFBWEditField
            app.PowerEditField
            app.TimeoutEditField
            app.SweepCommandEditField
            app.TraceOrderDropDown
            app.BackgroundIFBWEditField
            app.BackgroundPowerEditField
            app.BackgroundMoveHeightEditField
            app.AIDeviceEditField
            app.AIChannelEditField
            app.AIRangeMinEditField
            app.AIRangeMaxEditField
            app.AIRateEditField
            app.AODeviceEditField
            app.AOChannelEditField
            app.AOStartEditField
            app.AOStopEditField
            app.AOStepEditField
            app.AORangeMinEditField
            app.AORangeMaxEditField
            app.AOToleranceEditField
            app.AOPollPauseEditField
            app.PythonExeEditField
            app.SDKPathEditField
        ];
        for controlIdx = 1:numel(controls)
            if isvalid(controls(controlIdx))
                controls(controlIdx).Enable = state;
            end
        end
        app.LockParamsButton.Enable = 'on';
        app.StartButton.Enable = 'on';
        app.StopButton.Enable = 'on';
    end

    function updatePosition(xyz)
        app.PositionValueLabel.Text = sprintf('(%.2f, %.2f, %.2f) mm', xyz(1), xyz(2), xyz(3));
    end

    function updateVoltage(value)
        app.VoltageValueLabel.Text = sprintf('%.4f V', value);
    end

    function setStatus(msg)
        app.StatusValueLabel.Text = msg;
        drawnow limitrate;
    end
end

