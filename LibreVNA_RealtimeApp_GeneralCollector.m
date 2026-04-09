classdef LibreVNA_RealtimeApp_GeneralCollector < matlab.apps.AppBase
    % LibreVNA_RealtimeApp_GeneralCollector
    % Supports dB/phase trace modes and continuous/timed acquisition modes.

    properties (Access = public)
        UIFigure             matlab.ui.Figure
        GridLayout           matlab.ui.container.GridLayout
        LeftPanel            matlab.ui.container.Panel
        RightPanel           matlab.ui.container.Panel

        ParamLabel           matlab.ui.control.Label
        StartFreqEdit        matlab.ui.control.NumericEditField
        StopFreqEdit         matlab.ui.control.NumericEditField
        PointsEdit           matlab.ui.control.NumericEditField
        IFBWEdit             matlab.ui.control.NumericEditField
        PowerEdit            matlab.ui.control.NumericEditField

        FilterLabel          matlab.ui.control.Label
        FilterOrderEdit      matlab.ui.control.NumericEditField
        FilterCutoffEdit     matlab.ui.control.NumericEditField
        UpdateFilterButton   matlab.ui.control.Button

        TraceModeLabel       matlab.ui.control.Label
        TraceModeDropDown    matlab.ui.control.DropDown
        AcqModeLabel         matlab.ui.control.Label
        AcqModeDropDown      matlab.ui.control.DropDown
        TimedDurationLabel   matlab.ui.control.Label
        TimedDurationEdit    matlab.ui.control.NumericEditField

        ConnectSetButton     matlab.ui.control.Button
        CollectBGButton      matlab.ui.control.Button
        AddS21Button         matlab.ui.control.Button
        StartButton          matlab.ui.control.Button
        StopButton           matlab.ui.control.Button
        SaveButton           matlab.ui.control.Button

        StatusLabel          matlab.ui.control.TextArea

        AxesS21              matlab.ui.control.UIAxes
        AxesF0               matlab.ui.control.UIAxes
    end

    properties (Access = private)
        vna
        IPofVNA = 'localhost'
        VNAPort = 19542

        cfg
        refFreq

        allS21 = {}
        latestData = []
        S21b = []
        peakFreq = []
        f0time = []
        Movestatus = []
        Moven = 0
        lastf0time = 0

        hLineRaw
        hLineFiltered
        hLineF0

        AcquisitionTimer
        StopScheduleTimer

        start_time
        currentSegmentStartIndex = 1
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'LibreVNA Realtime Collector', ...
                'Position', [100 100 1280 760]);

            app.GridLayout = uigridlayout(app.UIFigure, [1, 2]);
            app.GridLayout.ColumnWidth = {360, '1x'};

            app.LeftPanel = uipanel(app.GridLayout, 'Title', 'Parameters & Control');
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            app.ParamLabel = uilabel(app.LeftPanel, 'Text', 'Sweep Parameters', ...
                'Position', [10 610 320 24]);

            uilabel(app.LeftPanel, 'Text', 'Start Freq (MHz)', 'Position', [10 580 120 20]);
            app.StartFreqEdit = uieditfield(app.LeftPanel, 'numeric', ...
                'Value', 60, 'Position', [150 580 160 22]);

            uilabel(app.LeftPanel, 'Text', 'Stop Freq (MHz)', 'Position', [10 545 120 20]);
            app.StopFreqEdit = uieditfield(app.LeftPanel, 'numeric', ...
                'Value', 90, 'Position', [150 545 160 22]);

            uilabel(app.LeftPanel, 'Text', 'Points', 'Position', [10 510 120 20]);
            app.PointsEdit = uieditfield(app.LeftPanel, 'numeric', ...
                'Value', 501, 'Position', [150 510 160 22]);

            uilabel(app.LeftPanel, 'Text', 'IFBW (Hz)', 'Position', [10 475 120 20]);
            app.IFBWEdit = uieditfield(app.LeftPanel, 'numeric', ...
                'Value', 1000, 'Position', [150 475 160 22]);

            uilabel(app.LeftPanel, 'Text', 'Power (dBm)', 'Position', [10 440 120 20]);
            app.PowerEdit = uieditfield(app.LeftPanel, 'numeric', ...
                'Value', 0, 'Position', [150 440 160 22]);

            app.FilterLabel = uilabel(app.LeftPanel, 'Text', 'Filter Parameters', ...
                'Position', [10 400 320 22]);

            uilabel(app.LeftPanel, 'Text', 'Filter Order', 'Position', [10 370 120 20]);
            app.FilterOrderEdit = uieditfield(app.LeftPanel, 'numeric', ...
                'Value', 3, 'Limits', [1 10], 'RoundFractionalValues', 'on', ...
                'Position', [150 370 160 22]);

            uilabel(app.LeftPanel, 'Text', 'Cutoff (0-1)', 'Position', [10 335 120 20]);
            app.FilterCutoffEdit = uieditfield(app.LeftPanel, 'numeric', ...
                'Value', 0.05, 'Limits', [0.001 0.999], ...
                'LowerLimitInclusive', 'on', 'UpperLimitInclusive', 'on', ...
                'Position', [150 335 160 22]);

            app.UpdateFilterButton = uibutton(app.LeftPanel, 'push', 'Text', 'Update Filter', ...
                'Position', [10 295 140 30], ...
                'ButtonPushedFcn', @(btn, event) onUpdateFilter(app)); %#ok<INUSD>

            app.TraceModeLabel = uilabel(app.LeftPanel, 'Text', 'Trace Mode', ...
                'Position', [10 255 120 20]);
            app.TraceModeDropDown = uidropdown(app.LeftPanel, ...
                'Items', {'dB', 'Phase'}, 'Value', 'dB', ...
                'Position', [150 255 160 22], ...
                'ValueChangedFcn', @(src, event) onTraceModeChanged(app)); %#ok<INUSD>

            app.AcqModeLabel = uilabel(app.LeftPanel, 'Text', 'Acq Mode', ...
                'Position', [10 220 120 20]);
            app.AcqModeDropDown = uidropdown(app.LeftPanel, ...
                'Items', {'Continuous', 'Timed'}, 'Value', 'Continuous', ...
                'Position', [150 220 160 22], ...
                'ValueChangedFcn', @(src, event) onAcqModeChanged(app)); %#ok<INUSD>

            app.TimedDurationLabel = uilabel(app.LeftPanel, 'Text', 'Timed Duration (s)', ...
                'Position', [10 185 130 20]);
            app.TimedDurationEdit = uieditfield(app.LeftPanel, 'numeric', ...
                'Value', 10, 'Limits', [0.1 Inf], ...
                'Position', [150 185 160 22]);

            app.ConnectSetButton = uibutton(app.LeftPanel, 'push', 'Text', 'Connect & Set', ...
                'Position', [10 140 140 30], ...
                'ButtonPushedFcn', @(btn, event) onConnectSet_libreVNA(app)); %#ok<INUSD>

            app.CollectBGButton = uibutton(app.LeftPanel, 'push', 'Text', 'Collect BG', ...
                'Position', [170 140 140 30], ...
                'ButtonPushedFcn', @(btn, event) onCollectBG(app)); %#ok<INUSD>

            app.AddS21Button = uibutton(app.LeftPanel, 'push', 'Text', 'Add S21', ...
                'Position', [10 100 140 30], ...
                'ButtonPushedFcn', @(btn, event) onAddS21(app)); %#ok<INUSD>

            app.StartButton = uibutton(app.LeftPanel, 'push', 'Text', 'Start', ...
                'Position', [170 100 140 30], ...
                'ButtonPushedFcn', @(btn, event) onStart_libreVNA(app)); %#ok<INUSD>

            app.StopButton = uibutton(app.LeftPanel, 'push', 'Text', 'Stop', ...
                'Position', [10 60 140 30], ...
                'ButtonPushedFcn', @(btn, event) onStop_libreVNA(app)); %#ok<INUSD>

            app.SaveButton = uibutton(app.LeftPanel, 'push', 'Text', 'Save', ...
                'Position', [170 60 140 30], ...
                'ButtonPushedFcn', @(btn, event) onSave(app)); %#ok<INUSD>

            app.StatusLabel = uitextarea(app.LeftPanel, ...
                'Value', {'Ready - Not connected'}, ...
                'Position', [10 10 320 42], ...
                'Editable', 'off');

            app.RightPanel = uipanel(app.GridLayout, 'Title', 'Realtime Plots');
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            app.AxesS21 = uiaxes(app.RightPanel);
            hold(app.AxesS21, 'on');
            grid(app.AxesS21, 'on');
            app.hLineRaw = plot(app.AxesS21, nan, nan, 'b', 'LineWidth', 1.0, 'DisplayName', 'Raw');
            app.hLineFiltered = plot(app.AxesS21, nan, nan, 'r', 'LineWidth', 1.4, 'DisplayName', 'Filtered');
            legend(app.AxesS21, 'show');

            app.AxesF0 = uiaxes(app.RightPanel);
            hold(app.AxesF0, 'on');
            grid(app.AxesF0, 'on');
            title(app.AxesF0, 'Peak Frequency');
            xlabel(app.AxesF0, 'Time (s)');
            ylabel(app.AxesF0, 'Peak Freq (MHz)');
            app.hLineF0 = plot(app.AxesF0, nan, nan, 'r', 'LineWidth', 1.2, 'DisplayName', 'Peak Freq');

            drawnow;
            pause(0.2);

            p = app.RightPanel.Position;
            h = p(4) / 2;
            app.AxesS21.Position = [10, h, p(3) - 20, h - 10];
            app.AxesF0.Position = [10, 5, p(3) - 20, h - 10];

            app.updateTraceAxesForMode();
            app.onAcqModeChanged();
        end

        function setStatus(app, msg)
            if isvalid(app.UIFigure)
                if isstring(msg) || ischar(msg)
                    app.StatusLabel.Value = cellstr(string(msg));
                else
                    app.StatusLabel.Value = cellstr(string(msg(:)));
                end
                drawnow limitrate;
            end
        end

        function s = complexToMatlabStr(~, z)
            n = numel(z);
            s = strings(n, 1);
            for ii = 1:n
                a = real(z(ii));
                b = imag(z(ii));
                s(ii) = sprintf('%+.6e%+.6ei', a, b);
            end
        end

        function mode = getTraceMode(app)
            mode = char(app.TraceModeDropDown.Value);
        end

        function mode = getAcqMode(app)
            mode = char(app.AcqModeDropDown.Value);
        end

        function durationSec = getTimedDuration(app)
            durationSec = max(0.1, double(app.TimedDurationEdit.Value));
            if app.TimedDurationEdit.Value ~= durationSec
                app.TimedDurationEdit.Value = durationSec;
            end
        end

        function [order, cutoff_norm] = getFilterSettings(app)
            order = max(1, round(app.FilterOrderEdit.Value));
            cutoff_norm = min(0.999, max(0.001, app.FilterCutoffEdit.Value));
            if app.FilterOrderEdit.Value ~= order
                app.FilterOrderEdit.Value = order;
            end
            if app.FilterCutoffEdit.Value ~= cutoff_norm
                app.FilterCutoffEdit.Value = cutoff_norm;
            end
        end

        function updateTraceAxesForMode(app)
            if strcmp(app.getTraceMode(), 'Phase')
                title(app.AxesS21, 'S21 Phase Trace');
                xlabel(app.AxesS21, 'Freq (MHz)');
                ylabel(app.AxesS21, 'Phase (deg)');
                app.hLineRaw.DisplayName = 'Phase Raw';
                app.hLineFiltered.DisplayName = 'Phase Filtered';
                title(app.AxesF0, 'Peak Frequency From Phase');
            else
                title(app.AxesS21, 'S21 Magnitude (dB)');
                xlabel(app.AxesS21, 'Freq (MHz)');
                ylabel(app.AxesS21, 'S21 (dB)');
                app.hLineRaw.DisplayName = 'S21 dB Raw';
                app.hLineFiltered.DisplayName = 'S21 dB Filtered';
                title(app.AxesF0, 'Peak Frequency From S21 dB');
            end
            legend(app.AxesS21, 'show');
        end

        function s21_corrected = apply_background_correction(app, freq, s21)
            if isempty(app.S21b)
                s21_corrected = s21;
                return;
            end
            if numel(app.S21b) == numel(s21)
                s21_corrected = s21 - app.S21b;
                return;
            end
            try
                bgFreq = app.allS21{1}(:, 1);
                bg_interp = interp1(bgFreq, app.S21b, freq, 'linear', 'extrap');
                s21_corrected = s21 - bg_interp;
            catch
                s21_corrected = s21;
            end
        end

        function [f_peak, mag_peak] = extract_peak_frequency(~, freq, traceData)
            if isempty(freq) || isempty(traceData)
                f_peak = NaN;
                mag_peak = NaN;
                return;
            end
            [mag_peak, idx] = max(traceData);
            f_peak = freq(idx);
        end

        function S_filtered = filter_trace(~, S, order, cutoff_norm)
            if nargin < 3
                order = 4;
            end
            if nargin < 4
                cutoff_norm = 0.01;
            end
            if isempty(S)
                S_filtered = S;
                return;
            end
            if numel(S) < (3 * (order * 2 + 1))
                win = max(3, round(numel(S) / 10));
                kernel = ones(win, 1) / win;
                S_filtered = conv(double(S), kernel, 'same');
                return;
            end
            [b, a] = butter(order, cutoff_norm);
            S_filtered = filtfilt(b, a, double(S));
        end

        function [x_plot, raw_trace, filtered_trace, f_peak] = computeActiveTrace(app, freq, s21)
            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
            order = app.cfg.filterOrder;
            cutoff = app.cfg.filterCutoffNorm;

            s21_corrected = app.apply_background_correction(freq, s21);
            mode = app.getTraceMode();

            if strcmp(mode, 'Phase')
                s21_phase = unwrap(rad2deg(angle(s21)));
                s21_phase_filtered = app.filter_trace(s21_phase, order, cutoff);

                N = numel(s21_phase_filtered);
                i1 = max(1, floor(N / 6));
                i2 = min(N, ceil(N * 5 / 6));

                phase_my = s21_phase_filtered(i1:i2);
                s21_phaseb = linspace(phase_my(1), phase_my(end), length(phase_my));
                freq_my = freq(i1:i2);
                s21_phasecorr = phase_my(:) - s21_phaseb(:);

                s21_phasemy = s21_phase(i1:i2);
                s21_phasecorro = s21_phasemy(:) - linspace(s21_phasemy(1), s21_phasemy(end), length(s21_phasemy)).';

                x_plot = freq_my(:);
                raw_trace = s21_phasecorro(:);
                filtered_trace = s21_phasecorr(:);
                [f_peak, ~] = app.extract_peak_frequency(freq_my, s21_phasecorr);
            else
                s21_db = 20 * log10(abs(s21_corrected) + eps);
                s21_db_filtered = app.filter_trace(s21_db, order, cutoff);
                x_plot = freq(:);
                raw_trace = s21_db(:);
                filtered_trace = s21_db_filtered(:);
                [f_peak, ~] = app.extract_peak_frequency(freq, s21_db_filtered);
            end
        end

        function [added, totalSets] = appendLatestS21(app)
            added = false;
            totalSets = numel(app.allS21);
            if isempty(app.latestData)
                return;
            end
            app.allS21{end+1} = app.latestData;
            added = true;
            totalSets = numel(app.allS21);
        end

        function discardCurrentSegment(app)
            idx = app.currentSegmentStartIndex;
            if idx <= numel(app.f0time)
                app.f0time(idx:end) = [];
                app.peakFreq(idx:end) = [];
                if numel(app.Movestatus) >= idx
                    app.Movestatus(idx:end) = [];
                end
            end

            if isempty(app.f0time)
                app.lastf0time = 0;
            else
                app.lastf0time = app.f0time(end);
            end

            try
                set(app.hLineF0, 'XData', app.f0time, 'YData', app.peakFreq);
                drawnow limitrate;
            catch
            end
        end

        function refreshLatestDisplay(app, updateLastPeak)
            if nargin < 2
                updateLastPeak = false;
            end
            if isempty(app.latestData)
                return;
            end

            freq = app.latestData(:, 1);
            s21 = app.latestData(:, 2);
            [x_plot, raw_trace, filtered_trace, f_peak] = app.computeActiveTrace(freq, s21);

            try
                set(app.hLineRaw, 'XData', x_plot / 1e6, 'YData', raw_trace);
                set(app.hLineFiltered, 'XData', x_plot / 1e6, 'YData', filtered_trace);
                if updateLastPeak && ~isempty(app.peakFreq)
                    app.peakFreq(end) = f_peak / 1e6;
                    set(app.hLineF0, 'XData', app.f0time, 'YData', app.peakFreq);
                end
                drawnow limitrate;
            catch
            end
        end

        function stopScheduledTimer(app)
            try
                if ~isempty(app.StopScheduleTimer) && isvalid(app.StopScheduleTimer)
                    stop(app.StopScheduleTimer);
                    delete(app.StopScheduleTimer);
                end
            catch
            end
            app.StopScheduleTimer = [];
        end

        function fetch_and_display_data_libreVNA(app)
            if isempty(app.vna)
                return;
            end

            [freq, s21] = collectS21_from_libreVNA(app);
            if isempty(freq) || isempty(s21)
                return;
            end

            app.latestData = [freq(:), s21(:)];
            [~, ~, ~, f_peak] = app.computeActiveTrace(freq, s21);
            app.refreshLatestDisplay(false);

            if isempty(app.start_time)
                app.start_time = tic;
                tnow = 0;
            else
                tnow = toc(app.start_time);
            end

            app.f0time(end + 1) = tnow + app.lastf0time; %#ok<AGROW>
            app.peakFreq(end + 1) = f_peak / 1e6; %#ok<AGROW>
            app.Movestatus(end + 1) = app.Moven; %#ok<AGROW>

            try
                set(app.hLineF0, 'XData', app.f0time, 'YData', app.peakFreq);
                drawnow limitrate;
            catch
            end
        end
    end

    methods (Access = public)
        function app = LibreVNA_RealtimeApp_GeneralCollector()
            createComponents(app);

            app.cfg.startFreq_MHz = app.StartFreqEdit.Value;
            app.cfg.stopFreq_MHz = app.StopFreqEdit.Value;
            app.cfg.numPoints = app.PointsEdit.Value;
            app.cfg.ifBW = app.IFBWEdit.Value;
            app.cfg.powerLevel = app.PowerEdit.Value;
            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
            app.cfg.traceMode = app.getTraceMode();
            app.cfg.acqMode = app.getAcqMode();
            app.cfg.timedDuration = app.getTimedDuration();

            app.AcquisitionTimer = [];
            app.StopScheduleTimer = [];
            app.refFreq = [];
            app.setStatus('Ready - please Connect & Set');

            app.UIFigure.CloseRequestFcn = @(~, ~) onClose(app);
        end

        function delete(app)
            onClose(app);
        end

        function onClose(app)
            try
                app.stopScheduledTimer();
            catch
            end
            try
                if ~isempty(app.AcquisitionTimer) && isvalid(app.AcquisitionTimer)
                    stop(app.AcquisitionTimer);
                    delete(app.AcquisitionTimer);
                end
            catch
            end
            try
                if ~isempty(app.vna)
                    try
                        app.vna.cmd(':VNA:ACQ:STOP');
                    catch
                    end
                    app.vna = [];
                end
            catch
            end
            try
                delete(app.UIFigure);
            catch
            end
        end
    end

    methods (Access = private)
        function onConnectSet_libreVNA(app)
            try
                if ~isempty(app.vna)
                    app.vna = [];
                end
            catch
                app.vna = [];
            end

            app.setStatus('Connecting to LibreVNA...');
            try
                app.vna = libreVNA(app.IPofVNA, app.VNAPort);

                try
                    app.vna.cmd(':DEV:CONN');
                    dev = strtrim(app.vna.query(':DEV:CONN?'));
                    app.setStatus(['Connected: ' dev]);
                catch
                    app.setStatus('Connected to LibreVNA (no dev string)');
                end

                startHz = double(app.StartFreqEdit.Value) * 1e6;
                stopHz = double(app.StopFreqEdit.Value) * 1e6;
                Npts = round(double(app.PointsEdit.Value));
                IFBW = double(app.IFBWEdit.Value);
                power = double(app.PowerEdit.Value);
                [filterOrder, filterCutoff] = app.getFilterSettings();

                app.vna.cmd(':DEV:MODE VNA');
                app.vna.cmd(':VNA:SWEEP FREQUENCY');
                app.vna.cmd(sprintf(':VNA:ACQ:POINTS %d', Npts));
                app.vna.cmd(sprintf(':VNA:ACQ:IFBW %d', IFBW));
                app.vna.cmd(sprintf(':VNA:FREQuency:START %d', round(startHz)));
                app.vna.cmd(sprintf(':VNA:FREQuency:STOP %d', round(stopHz)));
                app.vna.cmd(sprintf(':VNA:STIM:LVL %d', power));
                app.vna.cmd('VNA:ACQuisition:SINGLE FALSE');

                app.refFreq = linspace(startHz, stopHz, Npts).';
                app.cfg.startFreq_MHz = startHz / 1e6;
                app.cfg.stopFreq_MHz = stopHz / 1e6;
                app.cfg.numPoints = Npts;
                app.cfg.ifBW = IFBW;
                app.cfg.powerLevel = power;
                app.cfg.filterOrder = filterOrder;
                app.cfg.filterCutoffNorm = filterCutoff;
                app.cfg.traceMode = app.getTraceMode();
                app.cfg.acqMode = app.getAcqMode();
                app.cfg.timedDuration = app.getTimedDuration();

                app.setStatus(sprintf(['Connected & Configured.\nTrace Mode: %s\nAcq Mode: %s\n', ...
                    'Filter: order %d, cutoff %.3f'], ...
                    app.cfg.traceMode, app.cfg.acqMode, filterOrder, filterCutoff));
            catch ME
                app.setStatus(['Connect failed: ' ME.message]);
                app.vna = [];
            end
        end

        function [freqVec, S21vec] = collectS21_from_libreVNA(app)
            freqVec = [];
            S21vec = [];
            if isempty(app.vna)
                return;
            end

            try
                raw = app.vna.query(':VNA:TRACE:DATA? S21');
                data = libreVNA.parse_VNA_trace_data(raw);
                freqVec = data(:, 1);
                S21vec = data(:, 2);
            catch ME
                app.setStatus(['Collect S21 error: ' ME.message]);
            end
        end

        function onStart_libreVNA(app)
            if isempty(app.vna)
                app.setStatus('Please Connect first');
                return;
            end

            try
                if ~isempty(app.AcquisitionTimer) && isvalid(app.AcquisitionTimer)
                    stop(app.AcquisitionTimer);
                    delete(app.AcquisitionTimer);
                end
            catch
            end
            app.stopScheduledTimer();

            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
            app.cfg.traceMode = app.getTraceMode();
            app.cfg.acqMode = app.getAcqMode();
            app.cfg.timedDuration = app.getTimedDuration();

            app.currentSegmentStartIndex = numel(app.f0time) + 1;

            app.vna.cmd(':VNA:ACQ:RUN');
            pause(0.5);

            app.AcquisitionTimer = timer( ...
                'ExecutionMode', 'fixedRate', ...
                'Period', 0.1, ...
                'BusyMode', 'drop', ...
                'TimerFcn', @(~, ~) fetch_and_display_data_libreVNA(app));

            if strcmp(app.cfg.acqMode, 'Timed')
                app.StopScheduleTimer = timer( ...
                    'ExecutionMode', 'singleShot', ...
                    'StartDelay', app.cfg.timedDuration, ...
                    'TimerFcn', @(~, ~) onStop_libreVNA(app));
                start(app.StopScheduleTimer);
            end

            app.start_time = [];
            start(app.AcquisitionTimer);

            if strcmp(app.cfg.acqMode, 'Timed')
                app.setStatus(sprintf(['Acquisition started.\nTrace Mode: %s\nAcq Mode: Timed\n', ...
                    'Duration: %.2f s'], app.cfg.traceMode, app.cfg.timedDuration));
            else
                app.setStatus(sprintf('Acquisition started.\nTrace Mode: %s\nAcq Mode: Continuous', ...
                    app.cfg.traceMode));
            end
        end

        function onStop_libreVNA(app)
            try
                app.stopScheduledTimer();

                if ~isempty(app.AcquisitionTimer) && isvalid(app.AcquisitionTimer)
                    stop(app.AcquisitionTimer);
                    delete(app.AcquisitionTimer);
                    app.AcquisitionTimer = [];
                end

                app.start_time = [];
                app.vna.cmd(':VNA:ACQ:STOP');

                if app.currentSegmentStartIndex <= numel(app.f0time)
                    selection = uiconfirm(app.UIFigure, ...
                        ['Keep the current segment f0/time data and save the current S21 curve?', newline, ...
                        'Yes: keep this segment and save current S21', newline, ...
                        'No: discard this segment and continue from the previous kept time'], ...
                        'Stop Options', ...
                        'Options', {'Keep', 'Discard'}, ...
                        'DefaultOption', 1, ...
                        'CancelOption', 2);
                else
                    selection = 'Keep';
                end

                if strcmp(selection, 'Keep')
                    [added, totalSets] = app.appendLatestS21();
                    if ~isempty(app.f0time)
                        app.lastf0time = app.f0time(end);
                    end
                    if added
                        app.setStatus(sprintf(['Acquisition stopped.\nCurrent segment kept.\n', ...
                            'Raw S21 saved. Total sets: %d'], totalSets));
                    else
                        app.setStatus('Acquisition stopped.\nCurrent segment kept.\nNo S21 data available to save.');
                    end
                else
                    app.discardCurrentSegment();
                    app.setStatus(sprintf(['Acquisition stopped.\nCurrent segment discarded.\n', ...
                        'Next start will continue after %.6f s'], app.lastf0time));
                end
            catch ME
                app.setStatus(['Stop error: ' ME.message]);
            end
        end

        function onUpdateFilter(app)
            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();

            if isempty(app.latestData)
                app.setStatus(sprintf(['Filter updated.\nOrder: %d\nCutoff: %.3f\n', ...
                    'Waiting for data'], app.cfg.filterOrder, app.cfg.filterCutoffNorm));
                return;
            end

            app.refreshLatestDisplay(~isempty(app.f0time));
            app.setStatus(sprintf('Filter updated immediately.\nOrder: %d\nCutoff: %.3f', ...
                app.cfg.filterOrder, app.cfg.filterCutoffNorm));
        end

        function onTraceModeChanged(app)
            app.cfg.traceMode = app.getTraceMode();
            app.updateTraceAxesForMode();
            app.refreshLatestDisplay(~isempty(app.f0time));
            app.setStatus(sprintf('Trace mode switched to %s.', app.cfg.traceMode));
        end

        function onAcqModeChanged(app)
            app.cfg.acqMode = app.getAcqMode();
            isTimed = strcmp(app.cfg.acqMode, 'Timed');
            if isTimed
                app.TimedDurationEdit.Enable = 'on';
            else
                app.TimedDurationEdit.Enable = 'off';
            end
            if isTimed
                app.setStatus(sprintf('Acquisition mode switched to Timed.\nDuration: %.2f s', app.getTimedDuration()));
            else
                app.setStatus('Acquisition mode switched to Continuous.');
            end
        end

        function onCollectBG(app)
            if isempty(app.vna)
                app.setStatus('Not connected');
                return;
            end

            app.setStatus('Collecting background.');
            [freq, s21] = collectS21_from_libreVNA(app);
            if isempty(freq)
                app.setStatus('BG collect failed');
                return;
            end

            app.latestData = [freq(:), s21(:)];
            app.S21b = s21(:);
            app.allS21 = {};
            app.allS21{1} = app.latestData;
            app.refFreq = freq(:);
            app.refreshLatestDisplay(false);
            app.setStatus(sprintf('BG collected %d pts', numel(s21)));
        end

        function onAddS21(app)
            [added, totalSets] = app.appendLatestS21();
            if ~added
                app.setStatus('No latest data');
                return;
            end
            app.setStatus(sprintf('Added S21 (total sets %d)', totalSets));
        end

        function onSave(app)
            if isempty(app.allS21)
                uialert(app.UIFigure, 'No S21 data to save', 'Warning');
                return;
            end

            [file, path] = uiputfile('*.csv', 'Save S21 data', fullfile(pwd, 'S21_data.csv'));
            if isequal(file, 0)
                return;
            end

            base_name = erase(file, '.csv');
            save_dir = path;
            ref = app.allS21{1};
            freqs = ref(:, 1);
            npts = numel(freqs);
            nsets = numel(app.allS21);

            data_mat = strings(npts, 2 + nsets);
            if isempty(app.S21b)
                bg_str = repmat("0+0i", npts, 1);
            else
                if numel(app.S21b) == npts
                    bg_str = app.complexToMatlabStr(app.S21b);
                else
                    try
                        bg_interp = interp1(app.allS21{1}(:, 1), app.S21b, freqs, 'linear', 'extrap');
                        bg_str = app.complexToMatlabStr(bg_interp);
                    catch
                        bg_str = repmat("0+0i", npts, 1);
                    end
                end
            end

            data_mat(:, 1) = string(freqs);
            data_mat(:, 2) = bg_str;
            for k = 1:nsets
                sdat = app.allS21{k};
                if ~isequal(size(sdat, 1), npts) || any(sdat(:, 1) ~= freqs)
                    s_comp = interp1(sdat(:, 1), sdat(:, 2), freqs, 'linear', 'extrap');
                else
                    s_comp = sdat(:, 2);
                end
                data_mat(:, 2 + k) = app.complexToMatlabStr(s_comp);
            end

            data_path = fullfile(save_dir, sprintf('%s_all_S21.csv', base_name));
            fid = fopen(data_path, 'w');
            header = 'freq(Hz),S21b';
            for k = 1:nsets
                header = [header, sprintf(',S21_%d', k)]; %#ok<AGROW>
            end
            fprintf(fid, '%s\n', header);
            for i = 1:npts
                fprintf(fid, '%s,%s', data_mat{i, 1}, data_mat{i, 2});
                for k = 1:nsets
                    fprintf(fid, ',%s', data_mat{i, 2 + k});
                end
                fprintf(fid, '\n');
            end
            fclose(fid);

            if ~isempty(app.f0time) && ~isempty(app.peakFreq)
                peak_path = fullfile(save_dir, sprintf('%s_peakfreq.csv', base_name));
                fid2 = fopen(peak_path, 'w');
                fprintf(fid2, 'time(s),peakFreq(MHz),MovenStatus\n');
                for i = 1:numel(app.f0time)
                    fprintf(fid2, '%.6f,%.6f,%d\n', app.f0time(i), app.peakFreq(i), app.Movestatus(i));
                end
                fclose(fid2);
            else
                peak_path = '';
            end

            fig_path = fullfile(save_dir, sprintf('%s_S21_plot.png', base_name));
            frame = getframe(app.UIFigure);
            im = frame2im(frame);
            imwrite(im, fig_path);

            uialert(app.UIFigure, sprintf('Saved:\n%s\n%s\n%s', data_path, peak_path, fig_path), 'Saved');
        end
    end
end
