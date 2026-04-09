classdef E5080A_NI_TMC_Microrobot_SeparateParams < handle
    properties
        Settings
        SettingsFile
        Fig
        ParamFig
        ImagePanel
        BottomPanel
        TracePanel
        PeakPanel
        NIPanel
        ControlPanel
        AxImage
        AxTrace
        AxPeak
        AxNI
        ImageHandle
        PathHandle
        TraceHandle
        PeakHandle
        NIHandle
        StatusLabel
        Controls = struct()
        Camera
        LatestFrame
        CameraFrameCount = 0
        VNA
        VnaTimer
        FrequencyAxis = []
        NI
        TMCModule
        PeakTimes = []
        PeakFreqs = []
        NIVoltages = []
        NITimes = []
        LastTraceFreqMHz = []
        LastTraceY = []
        MeasurementStart = []
        PathPoints = []
        IsSettingPath = false
        StopRequested = false
        ThetaTemp = 0
    end

    methods
        function app = E5080A_NI_TMC_Microrobot_SeparateParams()
            app.SettingsFile = fullfile(fileparts(mfilename('fullpath')), 'E5080A_NI_TMC_Microrobot_SeparateParams_settings.mat');
            app.Settings = app.defaultSettings();
            app.loadSettings();
            app.buildUI();
            app.applySettingsToUI();
            app.setStatus('Ready');
        end

        function delete(app)
            app.shutdown(false);
            if ~isempty(app.Fig) && ishghandle(app.Fig)
                delete(app.Fig);
            end
            if ~isempty(app.ParamFig) && ishghandle(app.ParamFig)
                delete(app.ParamFig);
            end
        end
    end

    methods (Access = private)
        function settings = defaultSettings(~)
            settings = struct();
            settings.PythonPath = 'D:\python\python.exe';
            settings.ModulePath = 'C:\Users\zhaoj\Desktop\TMC-USB SDK-32&64bit\Demo\Python';
            settings.VNAIP = '169.254.111.39';
            settings.VNAPoints = 3001;
            settings.VNAFreqStart = 65;
            settings.VNAFreqStop = 95;
            settings.VNAPower = 20;
            settings.VNABW = 10000;
            settings.VNAChannel = 1;
            settings.UseAutoPeriod = true;
            settings.VNATimerPeriod = 0.5;
            settings.EnableNI = true;
            settings.NIDevice = 'Dev1';
            settings.NIChannel = 'ai2';
            settings.NIRangeMin = -0.4;
            settings.NIRangeMax = 0.4;
            settings.NIRate = 100;
            settings.NIAverageTimeMs = 200;
            settings.OBSName = 'OBS';
            settings.OBSFormat = 'I420_1000x1000';
            settings.OBSColorspace = 'grayscale';
            settings.RotateEnabled = true;
            settings.LengthPer1000Px = 35.39;
            settings.PixelSize = settings.LengthPer1000Px / 1000;
            settings.AnalysisMode = 'Phase';
            settings.PeakMode = 'Max';
            settings.PositionTolerance = 0.01;
            settings.TMCXYSpeed = 2;
            settings.TMCRSpeed = 40;
            settings.TMCRHomeSpeed = 20;
            settings.TMCWaitStep = 0.1;
            settings.XStageDirection = 'Reverse';
            settings.YStageDirection = 'Reverse';
            settings.RStageDirection = 'Normal';
        end

        function loadSettings(app)
            if isfile(app.SettingsFile)
                data = load(app.SettingsFile, 'settings');
                if isfield(data, 'settings') && isstruct(data.settings)
                    app.Settings = app.mergeStructs(app.Settings, data.settings);
                end
            end

            if app.Settings.VNAFreqStart > 1e5
                app.Settings.VNAFreqStart = app.Settings.VNAFreqStart / 1e6;
            end
            if app.Settings.VNAFreqStop > 1e5
                app.Settings.VNAFreqStop = app.Settings.VNAFreqStop / 1e6;
            end
            if ~isfield(app.Settings, 'LengthPer1000Px') || isempty(app.Settings.LengthPer1000Px)
                app.Settings.LengthPer1000Px = app.Settings.PixelSize * 1000;
            end
            app.Settings.PixelSize = app.Settings.LengthPer1000Px / 1000;
            if ~isfield(app.Settings, 'AnalysisMode') || isempty(app.Settings.AnalysisMode)
                app.Settings.AnalysisMode = 'Phase';
            end
            if ~isfield(app.Settings, 'PeakMode') || isempty(app.Settings.PeakMode)
                app.Settings.PeakMode = 'Max';
            end
            if ~isfield(app.Settings, 'NIAverageTimeMs') || isempty(app.Settings.NIAverageTimeMs)
                if isfield(app.Settings, 'NISamplesPerPeak') && isfield(app.Settings, 'NIRate') && app.Settings.NIRate > 0
                    app.Settings.NIAverageTimeMs = 1000 * app.Settings.NISamplesPerPeak / app.Settings.NIRate;
                else
                    app.Settings.NIAverageTimeMs = 200;
                end
            end
            if ~isfield(app.Settings, 'XStageDirection') || isempty(app.Settings.XStageDirection)
                app.Settings.XStageDirection = 'Reverse';
            end
            if ~isfield(app.Settings, 'YStageDirection') || isempty(app.Settings.YStageDirection)
                app.Settings.YStageDirection = 'Reverse';
            end
            if ~isfield(app.Settings, 'RStageDirection') || isempty(app.Settings.RStageDirection)
                app.Settings.RStageDirection = 'Normal';
            end
        end

        function saveSettings(app)
            app.syncSettingsFromUI();
            settings = app.Settings; %#ok<NASGU>
            save(app.SettingsFile, 'settings');
            app.setStatus(['Settings saved: ' app.SettingsFile]);
        end

        function saveSettingsSilently(app)
            settings = app.Settings; %#ok<NASGU>
            save(app.SettingsFile, 'settings');
        end

        function out = mergeStructs(~, base, override)
            out = base;
            names = fieldnames(override);
            for k = 1:numel(names)
                out.(names{k}) = override.(names{k});
            end
        end
        function buildUI(app)
            app.Fig = figure('Name', 'E5080A NI TMC Microrobot', 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', 'Color', [0.97 0.97 0.98], 'Position', [60 70 1080 920], 'ResizeFcn', @(~,~) app.updateLayout(), 'CloseRequestFcn', @(~,~) app.onClose());
            app.ParamFig = figure('Name', 'E5080A Parameters', 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', 'Color', [0.97 0.97 0.98], 'Position', [1160 70 700 920], 'CloseRequestFcn', @(~,~) app.onClose());

            app.ImagePanel = uipanel(app.Fig, 'Units', 'normalized', 'BorderType', 'none', 'BackgroundColor', 'black');
            app.AxImage = axes('Parent', app.ImagePanel, 'Units', 'normalized', 'Position', [0 0 1 1], 'Visible', 'off');
            app.ImageHandle = imshow(zeros(1000, 1000, 'uint8'), 'Parent', app.AxImage, 'InitialMagnification', 'fit');
            axis(app.AxImage, 'image');
            axis(app.AxImage, 'off');
            hold(app.AxImage, 'on');
            app.PathHandle = plot(app.AxImage, nan, nan, 'ro-', 'LineWidth', 1.6, 'MarkerFaceColor', 'r');
            hold(app.AxImage, 'off');

            app.BottomPanel = uipanel(app.Fig, 'Units', 'normalized', 'BorderType', 'none', 'BackgroundColor', [0.97 0.97 0.98]);
            app.TracePanel = uipanel(app.BottomPanel, 'Title', 'Trace', 'Units', 'normalized', 'Position', [0.00 0.00 0.48 1.00], 'BackgroundColor', 'white');
            app.AxTrace = axes('Parent', app.TracePanel, 'Units', 'normalized', 'Position', [0.07 0.18 0.90 0.74]);
            app.TraceHandle = plot(app.AxTrace, nan, nan, 'Color', [0.10 0.55 0.20], 'LineWidth', 1.3);
            grid(app.AxTrace, 'on'); xlabel(app.AxTrace, 'Freq (MHz)'); ylabel(app.AxTrace, 'Signal');

            app.PeakPanel = uipanel(app.BottomPanel, 'Title', 'Resonance', 'Units', 'normalized', 'Position', [0.49 0.00 0.25 1.00], 'BackgroundColor', 'white');
            app.AxPeak = axes('Parent', app.PeakPanel, 'Units', 'normalized', 'Position', [0.13 0.18 0.83 0.74]);
            app.PeakHandle = plot(app.AxPeak, nan, nan, 'Color', [0.72 0.20 0.60], 'LineWidth', 1.3);
            grid(app.AxPeak, 'on'); xlabel(app.AxPeak, 'Time (s)'); ylabel(app.AxPeak, 'f0 (MHz)');

            app.NIPanel = uipanel(app.BottomPanel, 'Title', 'NI Voltage', 'Units', 'normalized', 'Position', [0.75 0.00 0.25 1.00], 'BackgroundColor', 'white');
            app.AxNI = axes('Parent', app.NIPanel, 'Units', 'normalized', 'Position', [0.13 0.18 0.83 0.74]);
            app.NIHandle = plot(app.AxNI, nan, nan, 'Color', [0.10 0.35 0.80], 'LineWidth', 1.0, 'Marker', '.');
            grid(app.AxNI, 'on'); xlabel(app.AxNI, 'Time (s)'); ylabel(app.AxNI, 'Voltage (V)');

            app.ControlPanel = uipanel(app.ParamFig, 'Title', 'Parameters', 'Units', 'normalized', 'Position', [0 0 1 1], 'BackgroundColor', 'white');

            yTop = 0.930;
            y = 0.880;
            dy = 0.043;
            xL1 = 0.04; xE1 = 0.24; wL1 = 0.18; wE1 = 0.26;
            xL2 = 0.54; xE2 = 0.76; wL2 = 0.20; wE2 = 0.20;
            xEFull = 0.24; wEFull = 0.70;

            app.Controls.InitializeButton = uicontrol(app.ControlPanel, 'Style', 'pushbutton', 'String', 'Initialize', 'Units', 'normalized', ...
                'Position', [0.04 yTop 0.20 0.032], 'BackgroundColor', [0.90 0.95 1.00], 'Callback', @(~,~) app.onInitialize());
            app.Controls.StartButton = uicontrol(app.ControlPanel, 'Style', 'pushbutton', 'String', 'Start', 'Units', 'normalized', ...
                'Position', [0.28 yTop 0.17 0.032], 'BackgroundColor', [0.90 1.00 0.90], 'Callback', @(~,~) app.onStart());
            app.Controls.StopButton = uicontrol(app.ControlPanel, 'Style', 'pushbutton', 'String', 'Stop', 'Units', 'normalized', ...
                'Position', [0.49 yTop 0.17 0.032], 'BackgroundColor', [1.00 0.90 0.90], 'Callback', @(~,~) app.onStop());
            app.Controls.ExportButton = uicontrol(app.ControlPanel, 'Style', 'pushbutton', 'String', 'Export', 'Units', 'normalized', ...
                'Position', [0.70 yTop 0.20 0.032], 'BackgroundColor', [0.96 0.96 0.90], 'Callback', @(~,~) app.onExport());

            yButtons2 = yTop - 0.055;
            app.Controls.SetPathButton = uicontrol(app.ControlPanel, 'Style', 'pushbutton', 'String', 'Set Path', 'Units', 'normalized', ...
                'Position', [0.04 yButtons2 0.20 0.030], 'Callback', @(~,~) app.onSetPath());
            app.Controls.MoveButton = uicontrol(app.ControlPanel, 'Style', 'pushbutton', 'String', 'Move', 'Units', 'normalized', ...
                'Position', [0.28 yButtons2 0.17 0.030], 'Callback', @(~,~) app.onMove());
            app.Controls.CalibrateButton = uicontrol(app.ControlPanel, 'Style', 'pushbutton', 'String', 'Calibrate', 'Units', 'normalized', ...
                'Position', [0.49 yButtons2 0.17 0.030], 'Callback', @(~,~) app.onCalibrate());
            app.Controls.SaveButton = uicontrol(app.ControlPanel, 'Style', 'pushbutton', 'String', 'Save', 'Units', 'normalized', ...
                'Position', [0.70 yButtons2 0.20 0.030], 'Callback', @(~,~) app.onSaveSettings());

            y = yButtons2 - 0.040;
            app.addEdit(app.ControlPanel, 'Python Path', 'PythonPath', xL1, xEFull, y, wL1, wEFull); y = y - dy;
            app.addEdit(app.ControlPanel, 'Module Path', 'ModulePath', xL1, xEFull, y, wL1, wEFull); y = y - dy;
            app.addEdit(app.ControlPanel, 'OBS Name', 'OBSName', xL1, xE1, y, wL1, wE1);
            app.addEdit(app.ControlPanel, 'OBS Format', 'OBSFormat', xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'VNA IP', 'VNAAddress', xL1, xEFull, y, wL1, wEFull); y = y - dy;
            app.addEdit(app.ControlPanel, 'Channel', 'VNAChannel', xL1, xE1, y, wL1, wE1);
            app.addEdit(app.ControlPanel, 'Points', 'VNAPoints', xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'Freq Start (MHz)', 'VNAFreqStartMHz', xL1, xE1, y, wL1, wE1);
            app.addEdit(app.ControlPanel, 'Freq Stop (MHz)', 'VNAFreqStopMHz', xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'Power (dBm)', 'VNAPower', xL1, xE1, y, wL1, wE1);
            app.addEdit(app.ControlPanel, 'Bandwidth (Hz)', 'VNABandwidth', xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'Timer Period (s)', 'TimerPeriod', xL1, xE1, y, wL1, wE1);
            uicontrol(app.ControlPanel, 'Style', 'text', 'String', 'Auto Timer', 'Units', 'normalized', ...
                'Position', [xL2 y wL2 0.028], 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');
            app.Controls.UseAutoPeriod = uicontrol(app.ControlPanel, 'Style', 'checkbox', 'Units', 'normalized', ...
                'Position', [xE2 y 0.20 0.032], 'BackgroundColor', 'white'); y = y - dy;
            app.addPopup(app.ControlPanel, 'Analysis', 'AnalysisMode', {'Phase', 'Magnitude'}, xL1, xE1, y, wL1, wE1);
            app.addPopup(app.ControlPanel, 'Extract By', 'PeakMode', {'Max', 'Min'}, xL2, xE2, y, wL2, wE2); y = y - dy;
            uicontrol(app.ControlPanel, 'Style', 'text', 'String', 'Enable NI', 'Units', 'normalized', ...
                'Position', [xL1 y wL1 0.028], 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');
            app.Controls.EnableNI = uicontrol(app.ControlPanel, 'Style', 'checkbox', 'Units', 'normalized', ...
                'Position', [xE1 y 0.20 0.032], 'BackgroundColor', 'white');
            uicontrol(app.ControlPanel, 'Style', 'text', 'String', 'Rotate During Move', 'Units', 'normalized', ...
                'Position', [xL2 y wL2 0.028], 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');
            app.Controls.RotateEnabled = uicontrol(app.ControlPanel, 'Style', 'checkbox', 'Units', 'normalized', ...
                'Position', [xE2 y 0.20 0.032], 'BackgroundColor', 'white'); y = y - dy;
            app.addEdit(app.ControlPanel, 'NI Device', 'NIDevice', xL1, xE1, y, wL1, wE1);
            app.addEdit(app.ControlPanel, 'NI Channel', 'NIChannel', xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'NI Avg Time (ms)', 'NIAverageTimeMs', xL1, xE1, y, wL1, wE1);
            app.addEdit(app.ControlPanel, 'NI Range Min', 'NIRangeMin', xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'NI Range Max', 'NIRangeMax', xL1, xE1, y, wL1, wE1);
            app.addEdit(app.ControlPanel, 'Length @1000 px', 'LengthPer1000Px', xL2, xE2, y, wL2, wE2);
            set(app.Controls.LengthPer1000Px, 'Callback', @(~,~) app.refreshPixelSizeFromLength()); y = y - dy;
            app.addEdit(app.ControlPanel, 'Pixel Size', 'PixelSize', xL1, xE1, y, wL1, wE1);
            set(app.Controls.PixelSize, 'Enable', 'inactive');
            app.addEdit(app.ControlPanel, 'Position Tol.', 'PositionTolerance', xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addPopup(app.ControlPanel, 'X Stage Dir', 'XStageDirection', {'Reverse', 'Normal'}, xL1, xE1, y, wL1, wE1);
            app.addPopup(app.ControlPanel, 'Y Stage Dir', 'YStageDirection', {'Reverse', 'Normal'}, xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'XY Speed', 'XYSpeed', xL1, xE1, y, wL1, wE1);
            app.addPopup(app.ControlPanel, 'R Stage Dir', 'RStageDirection', {'Normal', 'Reverse'}, xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'R Home Speed', 'RHomeSpeed', xL1, xE1, y, wL1, wE1);
            app.addEdit(app.ControlPanel, 'R Speed', 'RSpeed', xL2, xE2, y, wL2, wE2); y = y - dy;
            app.addEdit(app.ControlPanel, 'Wait Step (s)', 'WaitStep', xL1, xE1, y, wL1, wE1);

            app.StatusLabel = uicontrol(app.ControlPanel, 'Style', 'text', 'String', 'Ready', 'Units', 'normalized', ...
                'Position', [0.04 0.015 0.92 0.040], 'BackgroundColor', 'white', 'HorizontalAlignment', 'left');

            app.updateLayout();
        end
        function updateLayout(app)
            if isempty(app.Fig) || ~ishghandle(app.Fig)
                return;
            end
            margin = 0.012;
            gap = 0.015;
            bottomH = 0.220;
            topGap = 0.020;
            topY = margin + bottomH + topGap;
            topH = 1 - topY - margin;

            figPos = getpixelposition(app.Fig);
            figAspect = figPos(4) / figPos(3);
            imageW = min(topH * figAspect, 1 - 2 * margin);

            set(app.ImagePanel, 'Position', [margin topY imageW topH]);
            set(app.BottomPanel, 'Position', [margin margin 1 - 2 * margin bottomH]);

            totalBottomW = 1 - 2 * margin;
            leftFrac = imageW / totalBottomW;
            gapFrac = gap / totalBottomW;
            rightFrac = max(0.01, 1 - leftFrac - gapFrac);
            halfLeft = max(0.01, (leftFrac - gapFrac) / 2);

            set(app.PeakPanel, 'Position', [0.00 0.00 halfLeft 1.00]);
            set(app.NIPanel, 'Position', [halfLeft + gapFrac 0.00 halfLeft 1.00]);
            set(app.TracePanel, 'Position', [leftFrac + gapFrac 0.00 rightFrac 1.00]);
        end
        function addEdit(app, parent, label, fieldName, xLabel, xEdit, y, wLabel, wEdit)
            uicontrol(parent, 'Style', 'text', 'String', label, 'Units', 'normalized', 'HorizontalAlignment', 'left', 'BackgroundColor', 'white', 'Position', [xLabel y wLabel 0.032]);
            app.Controls.(fieldName) = uicontrol(parent, 'Style', 'edit', 'Units', 'normalized', 'HorizontalAlignment', 'left', 'Position', [xEdit y wEdit 0.035], 'BackgroundColor', 'white');
        end

        function addPopup(app, parent, label, fieldName, options, xLabel, xEdit, y, wLabel, wEdit)
            uicontrol(parent, 'Style', 'text', 'String', label, 'Units', 'normalized', 'HorizontalAlignment', 'left', 'BackgroundColor', 'white', 'Position', [xLabel y wLabel 0.032]);
            app.Controls.(fieldName) = uicontrol(parent, 'Style', 'popupmenu', 'String', options, 'Units', 'normalized', 'Position', [xEdit y wEdit 0.035], 'BackgroundColor', 'white');
        end

        function applySettingsToUI(app)
            names = fieldnames(app.Settings);
            for k = 1:numel(names)
                name = names{k};
                if isfield(app.Controls, name) && ishghandle(app.Controls.(name))
                    ctrl = app.Controls.(name);
                    style = get(ctrl, 'Style');
                    switch style
                        case 'checkbox'
                            set(ctrl, 'Value', logical(app.Settings.(name)));
                        case 'popupmenu'
                            options = cellstr(get(ctrl, 'String'));
                            idx = find(strcmp(options, char(app.Settings.(name))), 1);
                            if isempty(idx)
                                idx = 1;
                            end
                            set(ctrl, 'Value', idx);
                        otherwise
                            value = app.Settings.(name);
                            if isnumeric(value) || islogical(value)
                                set(ctrl, 'String', num2str(value));
                            else
                                set(ctrl, 'String', char(value));
                            end
                    end
                end
            end
            app.refreshPixelSizeFromLength();
        end

        function syncSettingsFromUI(app)
            names = fieldnames(app.Settings);
            for k = 1:numel(names)
                name = names{k};
                if ~isfield(app.Controls, name) || ~ishghandle(app.Controls.(name))
                    continue;
                end
                ctrl = app.Controls.(name);
                style = get(ctrl, 'Style');
                switch style
                    case 'checkbox'
                        app.Settings.(name) = logical(get(ctrl, 'Value'));
                    case 'popupmenu'
                        options = cellstr(get(ctrl, 'String'));
                        app.Settings.(name) = options{get(ctrl, 'Value')};
                    otherwise
                        raw = strtrim(get(ctrl, 'String'));
                        defaultValue = app.Settings.(name);
                        if isnumeric(defaultValue) || islogical(defaultValue)
                            val = str2double(raw);
                            if ~isnan(val)
                                app.Settings.(name) = val;
                            end
                        else
                            app.Settings.(name) = raw;
                        end
                end
            end
            app.refreshPixelSizeFromLength();
        end

        function refreshPixelSizeFromLength(app)
            if isfield(app.Controls, 'LengthPer1000Px') && ishghandle(app.Controls.LengthPer1000Px)
                val = str2double(strtrim(get(app.Controls.LengthPer1000Px, 'String')));
                if ~isnan(val)
                    app.Settings.LengthPer1000Px = val;
                end
            end
            if isfield(app.Settings, 'LengthPer1000Px') && ~isempty(app.Settings.LengthPer1000Px)
                app.Settings.PixelSize = app.Settings.LengthPer1000Px / 1000;
            end
            if isfield(app.Controls, 'PixelSize') && ishghandle(app.Controls.PixelSize)
                set(app.Controls.PixelSize, 'String', num2str(app.Settings.PixelSize, '%.6f'));
            end
        end

        function initializeHardware(app)
            app.syncSettingsFromUI();
            app.saveSettingsSilently();
            app.initializeTMCModule();
            app.initializeVNA();
            app.initializeNI();
            app.initializeCamera();
            app.setStatus('Hardware initialized');
        end

        function initializeTMCModule(app)
            try
                env = pyenv;
                if env.Status == "NotLoaded"
                    pyenv('Version', app.Settings.PythonPath);
                elseif ~strcmpi(string(env.Executable), string(app.Settings.PythonPath))
                    app.setStatus('Python already loaded in another environment; keeping current pyenv');
                end
                try
                    py.sys.path().append(app.Settings.ModulePath);
                catch
                end
                de = py.importlib.import_module('devices_TMC_USB');
                app.TMCModule = de.TMC_USB();
            catch ME
                error('TMC initialization failed: %s', ME.message);
            end
        end

        function initializeVNA(app)
            if ~isempty(app.VNA)
                return;
            end
            try
                ip = app.Settings.VNAIP;
                strInstr = ['TCPIP0::' ip '::hislip0::INSTR'];
                app.VNA = visa('AGILENT', strInstr);
                app.VNA.InputBufferSize = 200001 * 100;
                fopen(app.VNA);
                points = round(app.Settings.VNAPoints);
                fStart = app.Settings.VNAFreqStart * 1e6;
                fStop = app.Settings.VNAFreqStop * 1e6;
                app.FrequencyAxis = linspace(fStart, fStop, points);
                fprintf(app.VNA, 'SENSE:FREQ:START %d', round(fStart));
                fprintf(app.VNA, 'SENSE:FREQ:STOP %d', round(fStop));
                fprintf(app.VNA, 'SENS:SWEEP:POINTS %d', points);
                fprintf(app.VNA, 'SOUR:POWER %g', app.Settings.VNAPower);
                fprintf(app.VNA, 'SENS:BWID %g', app.Settings.VNABW);
                fprintf(app.VNA, 'CALC:PAR:MNUM %d', round(app.Settings.VNAChannel));
                fprintf(app.VNA, 'FORM:BORD SWAP');
                fprintf(app.VNA, 'FORM REAL,64');
                fprintf(app.VNA, 'INIT:CONT ON');
                fprintf(app.VNA, 'TRIG:SOUR IMM');
                sweepTime = str2double(query(app.VNA, 'SENS:SWEEP:TIME?'));
                if app.Settings.UseAutoPeriod && ~isnan(sweepTime)
                    app.Settings.VNATimerPeriod = max(0.05, round(2 * sweepTime, 3));
                    set(app.Controls.VNATimerPeriod, 'String', num2str(app.Settings.VNATimerPeriod));
                end
            catch ME
                app.releaseVNA();
                rethrow(ME);
            end
        end
        function initializeNI(app)
            if ~app.Settings.EnableNI
                app.NI = [];
                return;
            end
            try
                app.NI = daq('ni');
                channel = addinput(app.NI, app.Settings.NIDevice, app.Settings.NIChannel, 'Voltage');
                channel.Range = [app.Settings.NIRangeMin, app.Settings.NIRangeMax];
                app.NI.Rate = app.Settings.NIRate;
            catch ME
                app.NI = [];
                error('NI initialization failed: %s', ME.message);
            end
        end

        function initializeCamera(app)
            if ~isempty(app.Camera)
                return;
            end
            try
                info = imaqhwinfo('winvideo');
                targetID = [];
                for k = 1:numel(info.DeviceInfo)
                    if contains(info.DeviceInfo(k).DeviceName, app.Settings.OBSName, 'IgnoreCase', true)
                        targetID = info.DeviceInfo(k).DeviceID;
                        break;
                    end
                end
                if isempty(targetID)
                    names = string({info.DeviceInfo.DeviceName});
                    error('OBS device not found. winvideo devices: %s', strjoin(names, ', '));
                end
                app.Camera = videoinput('winvideo', targetID, app.Settings.OBSFormat);
                app.Camera.ReturnedColorspace = app.Settings.OBSColorspace;
                app.Camera.FramesPerTrigger = 1;
                app.Camera.TriggerRepeat = Inf;
                app.Camera.FrameGrabInterval = 1;
                app.Camera.FramesAcquiredFcnCount = 1;
                app.Camera.FramesAcquiredFcn = @(~,~) app.onCameraFrame();
                flushdata(app.Camera);
                start(app.Camera);
            catch ME
                app.releaseCamera();
                error('Camera initialization failed: %s', ME.message);
            end
        end

        function startAcquisition(app)
            app.initializeHardware();
            app.StopRequested = false;
            app.PeakTimes = [];
            app.PeakFreqs = [];
            app.NIVoltages = [];
            app.NITimes = [];
            app.LastTraceFreqMHz = [];
            app.LastTraceY = [];
            app.MeasurementStart = tic;
            if ~isempty(app.VnaTimer) && isvalid(app.VnaTimer)
                stop(app.VnaTimer);
                delete(app.VnaTimer);
            end
            app.VnaTimer = timer('ExecutionMode', 'fixedRate', 'BusyMode', 'drop', 'Period', app.Settings.VNATimerPeriod, 'TimerFcn', @(~,~) app.onVnaTimer());
            start(app.VnaTimer);
            app.setStatus('Acquisition running');
        end

        function stopAcquisition(app)
            app.StopRequested = true;
            app.shutdown(true);
        end

        function shutdown(app, promptToSave)
            if nargin < 2
                promptToSave = false;
            end
            if ~isempty(app.VnaTimer) && isvalid(app.VnaTimer)
                try
                    stop(app.VnaTimer);
                catch
                end
                delete(app.VnaTimer);
                app.VnaTimer = [];
            end
            app.releaseCamera();
            app.releaseVNA();
            app.releaseNI();
            app.saveSettingsSilently();
            if promptToSave && (~isempty(app.PeakTimes) || ~isempty(app.NITimes))
                choice = questdlg('Save measurement data?', 'Save Data', 'Yes', 'No', 'Yes');
                if strcmp(choice, 'Yes')
                    app.exportData();
                end
            end
            app.setStatus('Stopped');
        end

        function releaseCamera(app)
            if ~isempty(app.Camera)
                try
                    flushdata(app.Camera);
                catch
                end
                try
                    stop(app.Camera);
                catch
                end
                try
                    delete(app.Camera);
                catch
                end
                app.Camera = [];
            end
        end

        function releaseVNA(app)
            if ~isempty(app.VNA)
                try
                    fprintf(app.VNA, 'INIT:CONT OFF');
                catch
                end
                try
                    fclose(app.VNA);
                catch
                end
                try
                    delete(app.VNA);
                catch
                end
                app.VNA = [];
            end
        end

        function releaseNI(app)
            app.NI = [];
        end

        function onCameraFrame(app)
            if isempty(app.Camera)
                return;
            end
            frame = peekdata(app.Camera, 1);
            if isempty(frame)
                return;
            end
            app.LatestFrame = frame;
            app.CameraFrameCount = app.CameraFrameCount + 1;
            set(app.ImageHandle, 'CData', frame);
            drawnow limitrate nocallbacks;
            if mod(app.CameraFrameCount, 5) == 0
                flushdata(app.Camera);
            end
        end

        function onVnaTimer(app)
            if app.StopRequested || isempty(app.VNA)
                return;
            end
            try
                S = app.fetchVNAData();
                if isempty(S)
                    return;
                end

                numPts = numel(S);
                idx1 = max(1, floor(numPts / 6) + 1);
                idx2 = min(numPts, ceil(numPts * 5 / 6));
                freqWindow = app.FrequencyAxis(idx1:idx2);
                modeName = lower(string(app.Settings.AnalysisMode));

                if modeName == "phase"
                    rawSignal = unwrap(angle(S)) / pi * 180;
                    filtered = app.filterData(rawSignal);
                    signalWindow = filtered(idx1:idx2);
                    baseline = linspace(signalWindow(1), signalWindow(end), numel(signalWindow)).';
                    analysisSignal = signalWindow - baseline;
                    ylabel(app.AxTrace, 'Phase (deg)');
                else
                    rawSignal = 20 * log10(abs(S));
                    filtered = app.filterData(rawSignal);
                    analysisSignal = filtered(idx1:idx2);
                    ylabel(app.AxTrace, 'Magnitude (dB)');
                end

                peakFrequency = app.extractPeakFrequency(analysisSignal, freqWindow, app.Settings.PeakMode);
                tSec = toc(app.MeasurementStart);
                niVoltage = app.sampleNIVoltage();

                app.PeakTimes(end+1) = tSec;
                app.PeakFreqs(end+1) = peakFrequency;
                if ~isnan(niVoltage)
                    app.NITimes(end+1) = tSec;
                    app.NIVoltages(end+1) = niVoltage;
                end

                app.LastTraceFreqMHz = freqWindow / 1e6;
                app.LastTraceY = analysisSignal;
                set(app.TraceHandle, 'XData', app.LastTraceFreqMHz, 'YData', app.LastTraceY);
                set(app.PeakHandle, 'XData', app.PeakTimes, 'YData', app.PeakFreqs / 1e6);
                xlim(app.AxPeak, [0 max(app.PeakTimes(end), eps)]);
                if ~isempty(app.NIVoltages)
                    set(app.NIHandle, 'XData', app.NITimes, 'YData', app.NIVoltages);
                    xlim(app.AxNI, [0 max(app.NITimes(end), eps)]);
                end
                drawnow limitrate nocallbacks;
                app.setStatus(sprintf('%s | %s | f0 %.6f MHz | NI %.4f V', app.Settings.AnalysisMode, app.Settings.PeakMode, peakFrequency / 1e6, niVoltage));
            catch ME
                app.setStatus(['Acquisition error: ' ME.message]);
            end
        end
        function S = fetchVNAData(app)
            fprintf(app.VNA, 'CALCulate:DATA? SDATA');
            [data, ~, ~] = binblockread(app.VNA, 'double');
            fscanf(app.VNA);
            realPart = data(1:2:end);
            imagPart = data(2:2:end);
            S = realPart + 1i * imagPart;
        end

        function filtered = filterData(~, data)
            if numel(data) < 10
                filtered = data;
                return;
            end
            [b, a] = butter(4, 0.01);
            filtered = filtfilt(b, a, data);
        end

        function peakFreq = extractPeakFrequency(~, signal, freq, peakMode)
            if nargin < 4 || isempty(peakMode)
                peakMode = 'Max';
            end
            if strcmpi(peakMode, 'Min')
                [~, idx] = min(signal);
            else
                [~, idx] = max(signal);
            end
            peakFreq = freq(idx);
        end

        function voltage = sampleNIVoltage(app)
            voltage = NaN;
            if ~app.Settings.EnableNI || isempty(app.NI)
                return;
            end
            try
                sampleCount = max(1, round(app.Settings.NIRate * app.Settings.NIAverageTimeMs / 1000));
                data = read(app.NI, sampleCount, 'OutputFormat', 'Matrix');
                if isempty(data)
                    return;
                end
                voltage = mean(data(:, 1), 'omitnan');
            catch ME
                app.setStatus(['NI read warning: ' ME.message]);
            end
        end

        function setPath(app)
            if isempty(app.Camera)
                app.initializeCamera();
            end
            app.IsSettingPath = true;
            app.PathPoints = [];
            set(app.PathHandle, 'XData', nan, 'YData', nan);
            app.setStatus('Left click to add path points, press Enter or right click to finish');
            figure(app.Fig);
            axes(app.AxImage);
            while ishghandle(app.Fig)
                [x, y, button] = ginput(1);
                if isempty(button) || button ~= 1
                    break;
                end
                app.PathPoints(end+1, :) = [x, y];
                set(app.PathHandle, 'XData', app.PathPoints(:,1), 'YData', app.PathPoints(:,2));
                drawnow;
            end
            app.IsSettingPath = false;
            app.setStatus(sprintf('Path set with %d points', size(app.PathPoints, 1)));
        end

        function calibratePixelSize(app)
            if isempty(app.Camera)
                app.initializeCamera();
            end
            flushdata(app.Camera);
            img = getsnapshot(app.Camera);
            hFig = figure('Name', 'Pixel Calibration', 'NumberTitle', 'off', 'Position', [150 150 900 650]);
            hAx = axes('Parent', hFig, 'Position', [0.05 0.12 0.90 0.83]);
            imshow(img, 'Parent', hAx);
            title(hAx, 'Select two points, then enter actual length');
            [x, y] = ginput(2);
            if numel(x) < 2
                close(hFig);
                return;
            end
            answer = inputdlg({'Actual length:'}, 'Calibration', 1, {num2str(app.Settings.LengthPer1000Px)});
            if isempty(answer)
                close(hFig);
                return;
            end
            actualSize = str2double(answer{1});
            pixelDistance = hypot(x(2) - x(1), y(2) - y(1));
            if pixelDistance > 0 && ~isnan(actualSize)
                app.Settings.PixelSize = actualSize / pixelDistance;
                app.Settings.LengthPer1000Px = app.Settings.PixelSize * 1000;
                set(app.Controls.LengthPer1000Px, 'String', num2str(app.Settings.LengthPer1000Px, '%.6f'));
                app.refreshPixelSizeFromLength();
                app.saveSettingsSilently();
                app.setStatus(sprintf('Pixel size updated: %.6f', app.Settings.PixelSize));
            end
            close(hFig);
        end

        function movePath(app)
            if isempty(app.PathPoints) || size(app.PathPoints, 1) < 2
                errordlg('Please set at least two path points first.', 'No Path');
                return;
            end
            app.syncSettingsFromUI();
            app.saveSettingsSilently();
            app.initializeTMCModule();
            handle = [];
            try
                handle = app.initTMCHandle();
                xSign = app.getAxisDirectionSign(app.Settings.XStageDirection);
                ySign = app.getAxisDirectionSign(app.Settings.YStageDirection);
                pathPos = round([xSign * app.PathPoints(:, 1), ySign * app.PathPoints(:, 2)] * app.Settings.PixelSize, 2);
                path0 = pathPos - pathPos(1, :);
                movePathXY = diff(pathPos);
                angleMove = -round(atan2(movePathXY(:, 2), movePathXY(:, 1)) / pi * 180, 2);
                rSign = app.getAxisDirectionSign(app.Settings.RStageDirection);
                angleMove = rSign * angleMove;
                if app.Settings.RotateEnabled
                    angleDelta = angleMove - app.ThetaTemp;
                    if angleDelta(1) > 180
                        angleDelta = angleDelta - 360;
                    elseif angleDelta(1) < -180
                        angleDelta = angleDelta + 360;
                    end
                    angleTarget = app.ThetaTemp + unwrap(angleDelta / 180 * pi) / pi * 180;
                else
                    angleTarget = zeros(size(angleMove));
                end
                for k = 1:size(movePathXY, 1)
                    if app.StopRequested
                        break;
                    end
                    if app.Settings.RotateEnabled
                        app.waitForRotation(handle, angleTarget(k));
                    end
                    app.TMCModule.tmc_line_interpolation_2d(handle, uint8(0x00), double(movePathXY(k, 1)), uint8(0x01), double(movePathXY(k, 2)));
                    app.waitForXY(handle, path0(k + 1, :));
                    pause(max(0, app.Settings.TMCWaitStep));
                end
                if app.Settings.RotateEnabled && ~isempty(angleMove)
                    app.ThetaTemp = angleTarget(end);
                end
                app.setStatus('Path move finished');
            catch ME
                app.setStatus(['Move error: ' ME.message]);
                rethrow(ME);
            end
            if ~isempty(handle)
                try
                    app.TMCModule.tmc_close(handle);
                catch
                end
            end
        end
        function handle = initTMCHandle(app)
            enumDev = app.TMCModule.tmc_device_count();
            handle = app.TMCModule.tmc_open(int32(enumDev - 1));
            app.TMCModule.tmc_init(handle, uint8(0x00), 'TSA200-B(F)');
            app.TMCModule.tmc_init(handle, uint8(0x01), 'TSA200-B(F)');
            app.TMCModule.tmc_init(handle, uint8(0x03), 'TBRF60L');
            app.TMCModule.tmc_set_home_mode(handle, uint8(0x03), int32(2));
            app.TMCModule.tmc_set_home_speed(handle, uint8(0x03), double(app.Settings.TMCRHomeSpeed));
            app.TMCModule.tmc_set_axis_enable(handle, uint8(0x00), true);
            app.TMCModule.tmc_set_axis_enable(handle, uint8(0x01), true);
            app.TMCModule.tmc_set_axis_enable(handle, uint8(0x03), true);
            app.TMCModule.tmc_set_unit(handle, uint8(0x00), int32(2));
            app.TMCModule.tmc_set_unit(handle, uint8(0x01), int32(2));
            app.TMCModule.tmc_set_unit(handle, uint8(0x03), int32(0));
            app.TMCModule.tmc_set_speed(handle, uint8(0x00), double(app.Settings.TMCXYSpeed));
            app.TMCModule.tmc_set_speed(handle, uint8(0x01), double(app.Settings.TMCXYSpeed));
            app.TMCModule.tmc_set_speed(handle, uint8(0x03), double(app.Settings.TMCRSpeed));
        end

        function s = getAxisDirectionSign(~, value)
            if isstring(value) || ischar(value)
                key = char(value);
            else
                key = 'Reverse';
            end
            if strcmpi(strtrim(key), 'Normal')
                s = 1;
            else
                s = -1;
            end
        end

        function waitForRotation(app, handle, targetAngle)
            app.TMCModule.tmc_absolute_move(handle, uint8(0x03), double(targetAngle));
            while abs(double(app.TMCModule.tmc_get_position(handle, uint8(0x03))) - targetAngle) > 0.1
                if app.StopRequested
                    return;
                end
                pause(max(0.02, app.Settings.TMCWaitStep));
                drawnow;
            end
        end

        function waitForXY(app, handle, targetXY)
            tol = app.Settings.PositionTolerance;
            while true
                xNow = double(app.TMCModule.tmc_get_position(handle, uint8(0x00)));
                yNow = double(app.TMCModule.tmc_get_position(handle, uint8(0x01)));
                if (xNow - targetXY(1))^2 + (yNow - targetXY(2))^2 <= tol^2
                    break;
                end
                if app.StopRequested
                    return;
                end
                pause(max(0.02, app.Settings.TMCWaitStep));
                drawnow;
            end
            app.TMCModule.tmc_stop(handle, uint8(0x00));
            app.TMCModule.tmc_stop(handle, uint8(0x01));
        end

        function exportData(app)
            if isempty(app.PeakTimes) && isempty(app.NITimes)
                errordlg('No data to export yet.', 'Export');
                return;
            end
            [fileName, filePath] = uiputfile({'*.csv', 'CSV Files (*.csv)'}, 'Save Data');
            if isequal(fileName, 0)
                return;
            end
            maxLen = max([numel(app.PeakTimes), numel(app.NITimes), 1]);
            peakTimes = nan(maxLen, 1);
            peakFreqsMHz = nan(maxLen, 1);
            niTimes = nan(maxLen, 1);
            niVoltages = nan(maxLen, 1);
            peakTimes(1:numel(app.PeakTimes)) = app.PeakTimes(:);
            peakFreqsMHz(1:numel(app.PeakFreqs)) = app.PeakFreqs(:) / 1e6;
            niTimes(1:numel(app.NITimes)) = app.NITimes(:);
            niVoltages(1:numel(app.NIVoltages)) = app.NIVoltages(:);
            T = table(peakTimes, peakFreqsMHz, niTimes, niVoltages, 'VariableNames', {'PeakTime_s', 'PeakFreq_MHz', 'NITime_s', 'NIVoltage_V'});
            writetable(T, fullfile(filePath, fileName));
            [~, baseName] = fileparts(fileName);
            if ~isempty(app.LastTraceFreqMHz)
                Ttrace = table(app.LastTraceFreqMHz(:), app.LastTraceY(:), 'VariableNames', {'Freq_MHz', 'TraceValue'});
                writetable(Ttrace, fullfile(filePath, [baseName '_last_trace.csv']));
            end
            saveas(app.Fig, fullfile(filePath, [baseName '.png']));
            app.setStatus('Data exported');
        end

        function onClose(app)
            try
                app.shutdown(false);
            catch
            end
            if ~isempty(app.ParamFig) && ishghandle(app.ParamFig)
                set(app.ParamFig, 'CloseRequestFcn', '');
                delete(app.ParamFig);
            end
            if ~isempty(app.Fig) && ishghandle(app.Fig)
                set(app.Fig, 'CloseRequestFcn', '');
                delete(app.Fig);
            end
        end

        function setStatus(app, msg)
            if ~isempty(app.StatusLabel) && ishghandle(app.StatusLabel)
                set(app.StatusLabel, 'String', msg);
            end
            drawnow limitrate nocallbacks;
        end
    end
end


























