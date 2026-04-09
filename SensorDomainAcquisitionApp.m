classdef SensorDomainAcquisitionApp < matlab.apps.AppBase
    properties (Access = public)
        UIFigure matlab.ui.Figure
        MainGrid matlab.ui.container.GridLayout
        PlotPanel matlab.ui.container.Panel
        ControlPanel matlab.ui.container.Panel
        PlotGrid matlab.ui.container.GridLayout
        ControlGrid matlab.ui.container.GridLayout
        UIAxes1 matlab.ui.control.UIAxes
        UIAxes2 matlab.ui.control.UIAxes
        UIAxes3 matlab.ui.control.UIAxes
        UIAxes4 matlab.ui.control.UIAxes
        UIAxes5 matlab.ui.control.UIAxes
        UIAxes6 matlab.ui.control.UIAxes
        BackgroundFileEditField matlab.ui.control.EditField
        SaveFolderEditField matlab.ui.control.EditField
        PrefixEditField matlab.ui.control.EditField
        XDistanceEditField matlab.ui.control.NumericEditField
        XStepEditField matlab.ui.control.NumericEditField
        XDirectionDropDown matlab.ui.control.DropDown
        XModelDropDown matlab.ui.control.DropDown
        YDistanceEditField matlab.ui.control.NumericEditField
        YStepEditField matlab.ui.control.NumericEditField
        YDirectionDropDown matlab.ui.control.DropDown
        YModelDropDown matlab.ui.control.DropDown
        ZDistanceEditField matlab.ui.control.NumericEditField
        ZStepEditField matlab.ui.control.NumericEditField
        ZDirectionDropDown matlab.ui.control.DropDown
        ZModelDropDown matlab.ui.control.DropDown
        MotionPauseEditField matlab.ui.control.NumericEditField
        InstrumentIPEditField matlab.ui.control.EditField
        StartFreqEditField matlab.ui.control.NumericEditField
        StopFreqEditField matlab.ui.control.NumericEditField
        SweepPointsEditField matlab.ui.control.NumericEditField
        IFBWEditField matlab.ui.control.NumericEditField
        PowerEditField matlab.ui.control.NumericEditField
        TimeoutEditField matlab.ui.control.NumericEditField
        SweepCommandEditField matlab.ui.control.EditField
        AIDeviceEditField matlab.ui.control.EditField
        AIChannelEditField matlab.ui.control.EditField
        AIRangeMinEditField matlab.ui.control.NumericEditField
        AIRangeMaxEditField matlab.ui.control.NumericEditField
        AIRateEditField matlab.ui.control.NumericEditField
        AODeviceEditField matlab.ui.control.EditField
        AOChannelEditField matlab.ui.control.EditField
        AOStartEditField matlab.ui.control.NumericEditField
        AOStopEditField matlab.ui.control.NumericEditField
        AOStepEditField matlab.ui.control.NumericEditField
        AORangeMinEditField matlab.ui.control.NumericEditField
        AORangeMaxEditField matlab.ui.control.NumericEditField
        AOToleranceEditField matlab.ui.control.NumericEditField
        AOPollPauseEditField matlab.ui.control.NumericEditField
        PythonExeEditField matlab.ui.control.EditField
        SDKPathEditField matlab.ui.control.EditField
        BrowseBackgroundButton matlab.ui.control.Button
        BrowseOutputButton matlab.ui.control.Button
        StartButton matlab.ui.control.Button
        StopButton matlab.ui.control.Button
        PositionValueLabel matlab.ui.control.Label
        VoltageValueLabel matlab.ui.control.Label
        StatusValueLabel matlab.ui.control.Label
    end

    properties (Access = private)
        dqIn
        dqOut
        vi
        TMC1
        TMCHandle
        FrequencyData = []
        BackgroundS21 = []
        BackgroundS11 = []
        StartPosition = [0 0 0]
        ShouldStop = false
        IsRunning = false
        PlotLines struct = struct()
    end

    properties (Constant, Access = private)
        AxisIds = uint8([0 1 2])
        AxisModels = {'TSA200-B(F)', 'LA100-60'}
    end

    methods (Access = private)
        function startupFcn(app)
            app.StatusValueLabel.Text = 'Idle';
            app.PositionValueLabel.Text = '(0.00, 0.00, 0.00) mm';
            app.VoltageValueLabel.Text = '0.0000 V';
        end

        function BrowseBackgroundButtonPushed(app, ~)
            [f, p] = uigetfile({'*.txt;*.dat;*.csv', 'Data files'; '*.*', 'All files'});
            if isequal(f, 0)
                return;
            end
            app.BackgroundFileEditField.Value = fullfile(p, f);
        end

        function BrowseOutputButtonPushed(app, ~)
            p = uigetdir(app.SaveFolderEditField.Value, 'Select output folder');
            if isequal(p, 0)
                return;
            end
            app.SaveFolderEditField.Value = p;
        end

        function StartButtonPushed(app, ~)
            if app.IsRunning
                return;
            end
            app.IsRunning = true;
            app.ShouldStop = false;
            app.StartButton.Enable = 'off';
            app.setStatus('Preparing hardware...');

            try
                params = app.readParams();
                app.loadBackground(params.background);
                app.setupHardware(params);
                app.runAcquisition(params);
                if app.ShouldStop
                    app.setStatus('Stopped and returned to start position');
                else
                    app.setStatus('Completed');
                end
            catch ME
                app.setStatus(['Error: ' ME.message]);
                uialert(app.UIFigure, ME.message, 'Acquisition Error');
            end

            app.cleanupHardware();
            app.StartButton.Enable = 'on';
            app.IsRunning = false;
        end

        function StopButtonPushed(app, ~)
            app.ShouldStop = true;
            if app.IsRunning
                app.setStatus('Stopping after current step...');
            end
        end

        function UIFigureCloseRequest(app, ~)
            app.ShouldStop = true;
            if app.IsRunning
                app.setStatus('Closing after safe stop...');
                return;
            end
            delete(app);
        end

        function params = readParams(app)
            params.background = strtrim(app.BackgroundFileEditField.Value);
            params.saveFolder = strtrim(app.SaveFolderEditField.Value);
            if ~isfolder(params.saveFolder)
                mkdir(params.saveFolder);
            end
            params.prefix = strtrim(app.PrefixEditField.Value);
            if isempty(params.prefix)
                params.prefix = 'sensor_scan';
            end
            params.motionPause = app.MotionPauseEditField.Value;
            params.vTol = app.AOToleranceEditField.Value;
            params.vPause = app.AOPollPauseEditField.Value;
            params.ip = strtrim(app.InstrumentIPEditField.Value);
            params.startFreq = app.StartFreqEditField.Value;
            params.stopFreq = app.StopFreqEditField.Value;
            params.points = round(app.SweepPointsEditField.Value);
            params.ifbw = app.IFBWEditField.Value;
            params.power = app.PowerEditField.Value;
            params.timeout = app.TimeoutEditField.Value;
            params.cmd = strtrim(app.SweepCommandEditField.Value);
            params.aiDev = strtrim(app.AIDeviceEditField.Value);
            params.aiChan = strtrim(app.AIChannelEditField.Value);
            params.aiRange = [app.AIRangeMinEditField.Value app.AIRangeMaxEditField.Value];
            params.aiRate = app.AIRateEditField.Value;
            params.aoDev = strtrim(app.AODeviceEditField.Value);
            params.aoChan = strtrim(app.AOChannelEditField.Value);
            params.aoRange = [app.AORangeMinEditField.Value app.AORangeMaxEditField.Value];
            params.voltages = app.buildVector(app.AOStartEditField.Value, app.AOStopEditField.Value, app.AOStepEditField.Value, 1);
            params.py = strtrim(app.PythonExeEditField.Value);
            params.sdk = strtrim(app.SDKPathEditField.Value);
            params.axis(1) = app.buildAxisParam(app.XDistanceEditField.Value, app.XStepEditField.Value, app.XDirectionDropDown.Value, app.XModelDropDown.Value);
            params.axis(2) = app.buildAxisParam(app.YDistanceEditField.Value, app.YStepEditField.Value, app.YDirectionDropDown.Value, app.YModelDropDown.Value);
            params.axis(3) = app.buildAxisParam(app.ZDistanceEditField.Value, app.ZStepEditField.Value, app.ZDirectionDropDown.Value, app.ZModelDropDown.Value);
        end

        function axisParam = buildAxisParam(app, distance, step, dirValue, model)
            signValue = 1;
            if contains(dirValue, '-')
                signValue = -1;
            end
            axisParam.distance = distance;
            axisParam.step = step;
            axisParam.model = model;
            axisParam.positions = app.buildVector(0, distance, step, signValue);
        end

        function vec = buildVector(~, startValue, stopValue, stepValue, signValue)
            if stepValue <= 0
                error('Step must be positive.');
            end
            if stopValue < startValue
                error('Stop value must be >= start value.');
            end
            vec = startValue:stepValue:stopValue;
            if isempty(vec) || abs(vec(end) - stopValue) > 1e-9
                vec = [vec stopValue];
            end
            vec = signValue .* vec;
        end

        function loadBackground(app, file)
            if ~isfile(file)
                error('Background file not found: %s', file);
            end
            raw = table2array(readtable(file));
            raw = raw(:);
            if mod(numel(raw), 2) ~= 0
                error('Background file must contain an even number of values.');
            end
            n = numel(raw) / 2;
            app.BackgroundS21 = raw(1:n);
            app.BackgroundS11 = raw(n+1:end);
        end

        function setupHardware(app, params)
            app.cleanupHardware();
            obj = instrfind;
            if ~isempty(obj)
                fclose(obj);
                delete(obj);
            end

            app.dqIn = daq("ni");
            aiChannel = addinput(app.dqIn, params.aiDev, params.aiChan, "Voltage");
            aiChannel.Range = params.aiRange;
            app.dqIn.Rate = params.aiRate;

            app.dqOut = daq("ni");
            aoChannel = addoutput(app.dqOut, params.aoDev, params.aoChan, "Voltage");
            aoChannel.Range = params.aoRange;

            pyenv('Version', params.py);
            pyPaths = cellfun(@char, cell(py.sys.path()), 'UniformOutput', false);
            if ~any(strcmp(pyPaths, params.sdk))
                py.sys.path().append(params.sdk);
            end
            module = py.importlib.import_module('devices_TMC_USB');
            app.TMC1 = module.TMC_USB();
            app.TMCHandle = app.initTMC(params);

            address = sprintf('TCPIP0::%s::hislip0::INSTR', params.ip);
            app.vi = visa('AGILENT', address);
            set(app.vi, 'InputBufferSize', 200000);
            set(app.vi, 'Timeout', params.timeout);
            fopen(app.vi);

            app.FrequencyData = app.configureVNA(params);
            if numel(app.FrequencyData) ~= numel(app.BackgroundS21) || numel(app.FrequencyData) ~= numel(app.BackgroundS11)
                error('Background data length does not match VNA sweep points.');
            end

            app.StartPosition = app.readXYZ();
            write(app.dqOut, params.voltages(1));
            app.updateVoltage(params.voltages(1));
        end

        function handle = initTMC(app, params)
            deviceCount = double(app.TMC1.tmc_device_count());
            if deviceCount <= 0
                error('No TMC device found.');
            end
            handle = app.TMC1.tmc_open(int32(deviceCount - 1));
            for k = 1:3
                app.TMC1.tmc_init(handle, app.AxisIds(k), params.axis(k).model);
                app.TMC1.tmc_set_axis_enable(handle, app.AxisIds(k), true);
                app.TMC1.tmc_set_unit(handle, app.AxisIds(k), int32(2));
            end
            pause(4);
        end

        function frequency = configureVNA(app, params)
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

        function runAcquisition(app, params)
            xPos = params.axis(1).positions;
            yPos = params.axis(2).positions;
            zPos = params.axis(3).positions;
            numVoltages = numel(params.voltages);
            numPoints = numel(app.FrequencyData);
            numXY = numel(xPos) * numel(yPos);

            for iz = 1:numel(zPos)
                if app.ShouldStop
                    break;
                end

                app.moveAxisAbsolute(3, app.StartPosition(3) + zPos(iz), params.motionPause);
                allS21Data = complex(zeros(numPoints, numXY, numVoltages));
                allS11Data = complex(zeros(numPoints, numXY, numVoltages));
                scanLog = table('Size', [numXY 3], 'VariableTypes', {'double', 'double', 'double'}, ...
                    'VariableNames', {'Index', 'X_mm', 'Y_mm'});
                posnum = 1;

                for iy = 1:numel(yPos)
                    if app.ShouldStop
                        break;
                    end
                    app.moveAxisAbsolute(2, app.StartPosition(2) + yPos(iy), params.motionPause);

                    for ix = 1:numel(xPos)
                        if app.ShouldStop
                            break;
                        end
                        app.moveAxisAbsolute(1, app.StartPosition(1) + xPos(ix), params.motionPause);

                        for iv = 1:numVoltages
                            if app.ShouldStop
                                break;
                            end
                            measuredV = app.setOutputVoltage(params.voltages(iv), params.vTol, params.vPause);
                            fprintf(app.vi, ':INITiate1:IMMediate; *WAI');
                            s = app.collectSData(params.cmd);
                            n = numel(s) / 2;
                            allS21Data(:, posnum, iv) = s(1:n);
                            allS11Data(:, posnum, iv) = s(n+1:end);
                            app.updateVoltage(measuredV);
                        end

                        xyz = app.readXYZ();
                        scanLog.Index(posnum) = posnum;
                        scanLog.X_mm(posnum) = xyz(1);
                        scanLog.Y_mm(posnum) = xyz(2);
                        app.updatePosition(xyz);
                        app.updatePlots(allS21Data(:, posnum, :), allS11Data(:, posnum, :));
                        posnum = posnum + 1;
                    end
                end

                app.moveAxisAbsolute(1, app.StartPosition(1), params.motionPause);
                app.moveAxisAbsolute(2, app.StartPosition(2), params.motionPause);
                zNow = app.getAxisPosition(3);
                app.updatePosition([app.StartPosition(1) app.StartPosition(2) zNow]);
                app.saveZFile(params, iz, zNow, xPos, yPos, allS21Data, allS11Data, scanLog);
            end

            app.returnToStart(params.motionPause);
        end

        function value = setOutputVoltage(app, target, tolerance, pauseSec)
            write(app.dqOut, target);
            value = app.readInputVoltage();
            while abs(value - target) > tolerance
                if app.ShouldStop
                    return;
                end
                pause(pauseSec);
                value = app.readInputVoltage();
            end
        end

        function value = readInputVoltage(app)
            t = read(app.dqIn);
            fieldName = t.Properties.VariableNames{1};
            value = t.(fieldName);
        end

        function s = collectSData(app, cmd)
            fprintf(app.vi, cmd);
            [data, ~, ~] = binblockread(app.vi, 'double');
            fscanf(app.vi);
            s = data(1:2:end) + 1i * data(2:2:end);
        end

        function updatePlots(app, s21Cube, s11Cube)
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

        function saveZFile(app, params, iz, zNow, xPos, yPos, allS21Data, allS11Data, scanLog)
            freqData = app.FrequencyData;
            metadata = struct( ...
                'savedAt', char(datetime('now', 'Format', 'yyyy-MM-dd''T''HH:mm:ss')), ...
                'zIndex', iz - 1, ...
                'zPositionMM', zNow, ...
                'xPositions', xPos, ...
                'yPositions', yPos, ...
                'outputVoltages', params.voltages, ...
                'axisModels', {{params.axis.model}}, ...
                'vna', struct('startFreqMHz', params.startFreq, 'stopFreqMHz', params.stopFreq, 'points', params.points, 'ifbwHz', params.ifbw, 'powerdBm', params.power, 'command', params.cmd), ...
                'ni', struct('aiDevice', params.aiDev, 'aiChannel', params.aiChan, 'aiRange', params.aiRange, 'aoDevice', params.aoDev, 'aoChannel', params.aoChan, 'aoRange', params.aoRange) ...
            );

            fileName = sprintf('%s_z%02d_%0.3fmm.mat', params.prefix, iz - 1, zNow);
            fileName = strrep(fileName, '-', 'm');
            save(fullfile(params.saveFolder, fileName), 'freqData', 'allS21Data', 'allS11Data', 'scanLog', 'metadata');
        end

        function moveAxisAbsolute(app, axisNumber, targetPosition, pauseSec)
            app.TMC1.tmc_absolute_move(app.TMCHandle, app.AxisIds(axisNumber), double(targetPosition));
            pause(pauseSec);
            app.TMC1.tmc_stop(app.TMCHandle, app.AxisIds(axisNumber));
        end

        function xyz = readXYZ(app)
            xyz = [app.getAxisPosition(1) app.getAxisPosition(2) app.getAxisPosition(3)];
        end

        function value = getAxisPosition(app, axisNumber)
            value = double(app.TMC1.tmc_get_position(app.TMCHandle, app.AxisIds(axisNumber)));
        end

        function returnToStart(app, pauseSec)
            if isempty(app.TMC1) || isempty(app.TMCHandle)
                return;
            end
            for k = 1:3
                app.moveAxisAbsolute(k, app.StartPosition(k), pauseSec);
            end
            app.updatePosition(app.StartPosition);
        end

        function cleanupHardware(app)
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
        end

        function updatePosition(app, xyz)
            app.PositionValueLabel.Text = sprintf('(%.2f, %.2f, %.2f) mm', xyz(1), xyz(2), xyz(3));
        end

        function updateVoltage(app, value)
            app.VoltageValueLabel.Text = sprintf('%.4f V', value);
        end

        function setStatus(app, msg)
            app.StatusValueLabel.Text = msg;
            drawnow limitrate;
        end

        function createComponents(app)
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [60 60 1500 860];
            app.UIFigure.Name = 'Sensor Domain Acquisition App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            app.MainGrid = uigridlayout(app.UIFigure, [1 2]);
            app.MainGrid.ColumnWidth = {'2x', 420};
            app.MainGrid.RowHeight = {'1x'};

            app.PlotPanel = uipanel(app.MainGrid);
            app.PlotPanel.Title = 'Realtime Curves';
            app.PlotPanel.Layout.Row = 1;
            app.PlotPanel.Layout.Column = 1;

            app.PlotGrid = uigridlayout(app.PlotPanel, [3 2]);
            app.PlotGrid.RowHeight = {'1x', '1x', '1x'};
            app.PlotGrid.ColumnWidth = {'1x', '1x'};

            app.UIAxes1 = uiaxes(app.PlotGrid);
            app.UIAxes1.Layout.Row = 1;
            app.UIAxes1.Layout.Column = 1;
            app.UIAxes2 = uiaxes(app.PlotGrid);
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;
            app.UIAxes3 = uiaxes(app.PlotGrid);
            app.UIAxes3.Layout.Row = 2;
            app.UIAxes3.Layout.Column = 1;
            app.UIAxes4 = uiaxes(app.PlotGrid);
            app.UIAxes4.Layout.Row = 2;
            app.UIAxes4.Layout.Column = 2;
            app.UIAxes5 = uiaxes(app.PlotGrid);
            app.UIAxes5.Layout.Row = 3;
            app.UIAxes5.Layout.Column = 1;
            app.UIAxes6 = uiaxes(app.PlotGrid);
            app.UIAxes6.Layout.Row = 3;
            app.UIAxes6.Layout.Column = 2;

            app.configureAxes(app.UIAxes1, 'Mag', 'dBmag');
            app.configureAxes(app.UIAxes2, 'Phase', 'Phase(deg)');
            app.configureAxes(app.UIAxes3, 'submag', 'submag');
            app.configureAxes(app.UIAxes4, 'S21 0.3v-0v', 'S21 high-low');
            app.configureAxes(app.UIAxes5, 'S11 mag', 'S11 mag');
            app.configureAxes(app.UIAxes6, 'S11 submag', 'S11 submag');

            app.PlotLines.MagLow = plot(app.UIAxes1, nan, nan, 'b');
            hold(app.UIAxes1, 'on');
            app.PlotLines.MagHigh = plot(app.UIAxes1, nan, nan, 'r');
            app.PlotLines.PhaseLow = plot(app.UIAxes2, nan, nan, 'b');
            hold(app.UIAxes2, 'on');
            app.PlotLines.PhaseHigh = plot(app.UIAxes2, nan, nan, 'r');
            app.PlotLines.SubMagLow = plot(app.UIAxes3, nan, nan, 'b');
            hold(app.UIAxes3, 'on');
            app.PlotLines.SubMagHigh = plot(app.UIAxes3, nan, nan, 'r');
            app.PlotLines.DeltaS21 = plot(app.UIAxes4, nan, nan, 'b');
            hold(app.UIAxes4, 'on');
            app.PlotLines.S11MagLow = plot(app.UIAxes5, nan, nan, 'b');
            hold(app.UIAxes5, 'on');
            app.PlotLines.S11MagHigh = plot(app.UIAxes5, nan, nan, 'r');
            app.PlotLines.S11SubLow = plot(app.UIAxes6, nan, nan, 'b');
            hold(app.UIAxes6, 'on');
            app.PlotLines.S11SubHigh = plot(app.UIAxes6, nan, nan, 'r');

            app.ControlPanel = uipanel(app.MainGrid);
            app.ControlPanel.Title = 'Parameters';
            app.ControlPanel.Layout.Row = 1;
            app.ControlPanel.Layout.Column = 2;
            app.ControlPanel.Scrollable = 'on';

            app.ControlGrid = uigridlayout(app.ControlPanel, [50 2]);
            app.ControlGrid.ColumnWidth = {165, '1x'};
            app.ControlGrid.RowHeight = repmat({26}, 1, 50);
            app.ControlGrid.RowSpacing = 6;
            app.ControlGrid.Padding = [10 10 10 10];

            row = 1;
            app.addSection(row, 'Acquisition');
            row = row + 1;
            app.BackgroundFileEditField = app.addEditField(row, 'Background File', 'without.txt');
            row = row + 1;
            app.BrowseBackgroundButton = app.addButton(row, '', 'Browse...', @BrowseBackgroundButtonPushed);
            row = row + 1;
            app.SaveFolderEditField = app.addEditField(row, 'Save Folder', pwd);
            row = row + 1;
            app.BrowseOutputButton = app.addButton(row, '', 'Select Folder', @BrowseOutputButtonPushed);
            row = row + 1;
            app.PrefixEditField = app.addEditField(row, 'File Prefix', 'sensor_scan');
            row = row + 1;

            app.addSection(row, 'Motion');
            row = row + 1;
            app.XDistanceEditField = app.addNumericField(row, 'X Distance (mm)', 21);
            row = row + 1;
            app.XStepEditField = app.addNumericField(row, 'X Step (mm)', 1);
            row = row + 1;
            app.XDirectionDropDown = app.addDropDown(row, 'X Positive Dir', {'+X', '-X'}, '+X');
            row = row + 1;
            app.XModelDropDown = app.addDropDown(row, 'X Axis Model', app.AxisModels, 'TSA200-B(F)');
            row = row + 1;
            app.YDistanceEditField = app.addNumericField(row, 'Y Distance (mm)', 21);
            row = row + 1;
            app.YStepEditField = app.addNumericField(row, 'Y Step (mm)', 1);
            row = row + 1;
            app.YDirectionDropDown = app.addDropDown(row, 'Y Positive Dir', {'+Y', '-Y'}, '-Y');
            row = row + 1;
            app.YModelDropDown = app.addDropDown(row, 'Y Axis Model', app.AxisModels, 'TSA200-B(F)');
            row = row + 1;
            app.ZDistanceEditField = app.addNumericField(row, 'Z Distance (mm)', 30);
            row = row + 1;
            app.ZStepEditField = app.addNumericField(row, 'Z Step (mm)', 2);
            row = row + 1;
            app.ZDirectionDropDown = app.addDropDown(row, 'Z Positive Dir', {'+Z', '-Z'}, '+Z');
            row = row + 1;
            app.ZModelDropDown = app.addDropDown(row, 'Z Axis Model', app.AxisModels, 'TSA200-B(F)');
            row = row + 1;
            app.MotionPauseEditField = app.addNumericField(row, 'Motion Pause (s)', 2);
            row = row + 1;

            app.addSection(row, 'VNA');
            row = row + 1;
            app.InstrumentIPEditField = app.addEditField(row, 'Instrument IP', '169.254.111.39');
            row = row + 1;
            app.StartFreqEditField = app.addNumericField(row, 'Start Freq (MHz)', 65);
            row = row + 1;
            app.StopFreqEditField = app.addNumericField(row, 'Stop Freq (MHz)', 95);
            row = row + 1;
            app.SweepPointsEditField = app.addNumericField(row, 'Sweep Points', 301);
            row = row + 1;
            app.IFBWEditField = app.addNumericField(row, 'IFBW (Hz)', 1000);
            row = row + 1;
            app.PowerEditField = app.addNumericField(row, 'Power (dBm)', 18);
            row = row + 1;
            app.TimeoutEditField = app.addNumericField(row, 'Timeout (s)', 100);
            row = row + 1;
            app.SweepCommandEditField = app.addEditField(row, 'Sweep Command', 'CALCulate:DATA:MSD? "1,2"');
            row = row + 1;

            app.addSection(row, 'NI DAQ');
            row = row + 1;
            app.AIDeviceEditField = app.addEditField(row, 'AI Device', 'Dev1');
            row = row + 1;
            app.AIChannelEditField = app.addEditField(row, 'AI Channel', 'ai0');
            row = row + 1;
            app.AIRangeMinEditField = app.addNumericField(row, 'AI Range Min (V)', 0);
            row = row + 1;
            app.AIRangeMaxEditField = app.addNumericField(row, 'AI Range Max (V)', 1);
            row = row + 1;
            app.AIRateEditField = app.addNumericField(row, 'AI Rate (Hz)', 100);
            row = row + 1;
            app.AODeviceEditField = app.addEditField(row, 'AO Device', 'Dev1');
            row = row + 1;
            app.AOChannelEditField = app.addEditField(row, 'AO Channel', 'ao0');
            row = row + 1;
            app.AOStartEditField = app.addNumericField(row, 'AO Start (V)', 0);
            row = row + 1;
            app.AOStopEditField = app.addNumericField(row, 'AO Stop (V)', 0.3);
            row = row + 1;
            app.AOStepEditField = app.addNumericField(row, 'AO Step (V)', 0.05);
            row = row + 1;
            app.AORangeMinEditField = app.addNumericField(row, 'AO Range Min (V)', 0);
            row = row + 1;
            app.AORangeMaxEditField = app.addNumericField(row, 'AO Range Max (V)', 1);
            row = row + 1;
            app.AOToleranceEditField = app.addNumericField(row, 'AO Tolerance (V)', 1e-3);
            row = row + 1;
            app.AOPollPauseEditField = app.addNumericField(row, 'AO Poll Pause (s)', 0.1);
            row = row + 1;

            app.addSection(row, 'Python / SDK');
            row = row + 1;
            app.PythonExeEditField = app.addEditField(row, 'Python Exe', 'D:\python\python.exe');
            row = row + 1;
            app.SDKPathEditField = app.addEditField(row, 'SDK Module Path', 'C:\Users\zhaoj\Desktop\TMC-USB SDK-32&64bit\Demo\Python');
            row = row + 1;

            app.StartButton = uibutton(app.ControlGrid, 'push');
            app.StartButton.Text = 'Start';
            app.StartButton.Layout.Row = row;
            app.StartButton.Layout.Column = 1;
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);

            app.StopButton = uibutton(app.ControlGrid, 'push');
            app.StopButton.Text = 'Stop';
            app.StopButton.Layout.Row = row;
            app.StopButton.Layout.Column = 2;
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            row = row + 1;

            app.PositionValueLabel = app.addValueLabel(row, 'Position', '(0.00, 0.00, 0.00) mm');
            row = row + 1;
            app.VoltageValueLabel = app.addValueLabel(row, 'Voltage', '0.0000 V');
            row = row + 1;
            app.StatusValueLabel = app.addValueLabel(row, 'Status', 'Idle');

            registerApp(app, app.UIFigure);
            runStartupFcn(app, @startupFcn);
            app.UIFigure.Visible = 'on';
        end

        function configureAxes(~, ax, plotTitle, yLabelText)
            title(ax, plotTitle);
            xlabel(ax, 'Freq (MHz)');
            ylabel(ax, yLabelText);
            grid(ax, 'on');
        end

        function field = addEditField(app, row, labelText, defaultValue)
            label = uilabel(app.ControlGrid);
            label.Text = labelText;
            label.Layout.Row = row;
            label.Layout.Column = 1;
            field = uieditfield(app.ControlGrid, 'text');
            field.Value = defaultValue;
            field.Layout.Row = row;
            field.Layout.Column = 2;
        end

        function field = addNumericField(app, row, labelText, defaultValue)
            label = uilabel(app.ControlGrid);
            label.Text = labelText;
            label.Layout.Row = row;
            label.Layout.Column = 1;
            field = uieditfield(app.ControlGrid, 'numeric');
            field.Value = defaultValue;
            field.Layout.Row = row;
            field.Layout.Column = 2;
        end

        function field = addDropDown(app, row, labelText, items, defaultValue)
            label = uilabel(app.ControlGrid);
            label.Text = labelText;
            label.Layout.Row = row;
            label.Layout.Column = 1;
            field = uidropdown(app.ControlGrid);
            field.Items = items;
            field.Value = defaultValue;
            field.Layout.Row = row;
            field.Layout.Column = 2;
        end

        function button = addButton(app, row, labelText, buttonText, callbackFcn)
            label = uilabel(app.ControlGrid);
            label.Text = labelText;
            label.Layout.Row = row;
            label.Layout.Column = 1;
            button = uibutton(app.ControlGrid, 'push');
            button.Text = buttonText;
            button.ButtonPushedFcn = createCallbackFcn(app, callbackFcn, true);
            button.Layout.Row = row;
            button.Layout.Column = 2;
        end

        function addSection(app, row, textValue)
            label = uilabel(app.ControlGrid);
            label.Text = textValue;
            label.FontWeight = 'bold';
            label.Layout.Row = row;
            label.Layout.Column = [1 2];
        end

        function valueLabel = addValueLabel(app, row, nameText, valueText)
            label = uilabel(app.ControlGrid);
            label.Text = nameText;
            label.Layout.Row = row;
            label.Layout.Column = 1;
            valueLabel = uilabel(app.ControlGrid);
            valueLabel.Text = valueText;
            valueLabel.Layout.Row = row;
            valueLabel.Layout.Column = 2;
        end
    end

    methods (Access = public)
        function app = SensorDomainAcquisitionApp()
            createComponents(app);
        end

        function delete(app)
            app.cleanupHardware();
            delete(app.UIFigure);
        end
    end
end
