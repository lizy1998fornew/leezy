
classdef VNA_RealtimeApp_General < matlab.apps.AppBase
    % General VNA realtime collector supporting LibreVNA and E5080A.

    properties (Access = public)
        UIFigure             matlab.ui.Figure
        GridLayout           matlab.ui.container.GridLayout
        LeftPanel            matlab.ui.container.Panel
        LeftGrid             matlab.ui.container.GridLayout
        RightPanel           matlab.ui.container.Panel

        InstrumentToggleButton matlab.ui.control.Button
        InstrumentPanel      matlab.ui.container.Panel
        SweepToggleButton    matlab.ui.control.Button
        SweepPanel           matlab.ui.container.Panel
        FilterToggleButton   matlab.ui.control.Button
        FilterPanel          matlab.ui.container.Panel
        ModeToggleButton     matlab.ui.control.Button
        ModePanel            matlab.ui.container.Panel
        ActionPanel          matlab.ui.container.Panel

        ParamLabel           matlab.ui.control.Label
        VNATypeLabel         matlab.ui.control.Label
        VNATypeDropDown      matlab.ui.control.DropDown
        AddressLabel         matlab.ui.control.Label
        AddressEdit          matlab.ui.control.EditField
        PortLabel            matlab.ui.control.Label
        PortEdit             matlab.ui.control.NumericEditField
        PeakModeLabel        matlab.ui.control.Label
        PeakModeDropDown     matlab.ui.control.DropDown

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
        vi
        libreHost = 'localhost'
        librePort = 19542
        e5080aAddress = '169.254.111.39'

        cfg
        refFreq

        allS21 = {}
        latestData = []
        S21b = []
        peakFreq = []
        peakFreq1 = []
        f0time = []
        Movestatus = []
        Moven = 0
        lastf0time = 0

        hLineRaw
        hLineFiltered
        hLineF0
        hLineF1

        AcquisitionTimer
        StopScheduleTimer

        start_time
        currentSegmentStartIndex = 1
        instrumentPanelExpanded = true
        sweepPanelExpanded = false
        filterPanelExpanded = false
        modePanelExpanded = true
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'General VNA Realtime Collector', ...
                'Position', [100 100 1180 700]);

            app.GridLayout = uigridlayout(app.UIFigure, [1, 2]);
            app.GridLayout.ColumnWidth = {390, '1x'};

            app.LeftPanel = uipanel(app.GridLayout, 'Title', 'Control');
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            app.LeftGrid = uigridlayout(app.LeftPanel, [11, 1]);
            app.LeftGrid.RowHeight = {84, 24, 110, 24, 0, 24, 0, 0, '1x', 112, 132};
            app.LeftGrid.ColumnWidth = {'1x'};
            app.LeftGrid.Padding = [10 10 10 10];
            app.LeftGrid.RowSpacing = 6;
            app.LeftGrid.ColumnSpacing = 0;

            app.StatusLabel = uitextarea(app.LeftGrid, ...
                'Value', {'Ready - Not connected'}, ...
                'Editable', 'off', ...
                'FontSize', 11);
            app.StatusLabel.Layout.Row = 1;
            app.StatusLabel.Layout.Column = 1;

            app.InstrumentToggleButton = uibutton(app.LeftGrid, 'push', ...
                'Text', '[-] Instrument', ...
                'ButtonPushedFcn', @(btn, event) toggleSection(app, 'instrument')); %#ok<INUSD>
            app.InstrumentToggleButton.Layout.Row = 2;
            app.InstrumentToggleButton.Layout.Column = 1;
            app.InstrumentPanel = uipanel(app.LeftGrid, 'Title', '');
            app.InstrumentPanel.Layout.Row = 3;
            app.InstrumentPanel.Layout.Column = 1;

            instrumentGrid = uigridlayout(app.InstrumentPanel, [3, 2]);
            instrumentGrid.RowHeight = {22, 22, 22};
            instrumentGrid.ColumnWidth = {120, '1x'};
            instrumentGrid.Padding = [10 8 10 8];
            instrumentGrid.RowSpacing = 6;
            instrumentGrid.ColumnSpacing = 10;

            app.VNATypeLabel = uilabel(instrumentGrid, 'Text', 'VNA Type');
            app.VNATypeLabel.Layout.Row = 1;
            app.VNATypeLabel.Layout.Column = 1;
            app.VNATypeDropDown = uidropdown(instrumentGrid, ...
                'Items', {'LibreVNA', 'E5080A'}, 'Value', 'LibreVNA', ...
                'ValueChangedFcn', @(src, event) onVNATypeChanged(app)); %#ok<INUSD>
            app.VNATypeDropDown.Layout.Row = 1;
            app.VNATypeDropDown.Layout.Column = 2;
            app.AddressLabel = uilabel(instrumentGrid, 'Text', 'Address / Host');
            app.AddressLabel.Layout.Row = 2;
            app.AddressLabel.Layout.Column = 1;
            app.AddressEdit = uieditfield(instrumentGrid, 'text', ...
                'Value', app.libreHost);
            app.AddressEdit.Layout.Row = 2;
            app.AddressEdit.Layout.Column = 2;
            app.PortLabel = uilabel(instrumentGrid, 'Text', 'Port');
            app.PortLabel.Layout.Row = 3;
            app.PortLabel.Layout.Column = 1;
            app.PortEdit = uieditfield(instrumentGrid, 'numeric', ...
                'Value', app.librePort, 'RoundFractionalValues', 'on', ...
                'Limits', [1 Inf]);
            app.PortEdit.Layout.Row = 3;
            app.PortEdit.Layout.Column = 2;

            app.SweepToggleButton = uibutton(app.LeftGrid, 'push', ...
                'Text', '[+] Sweep / Peak', ...
                'ButtonPushedFcn', @(btn, event) toggleSection(app, 'sweep')); %#ok<INUSD>
            app.SweepToggleButton.Layout.Row = 4;
            app.SweepToggleButton.Layout.Column = 1;
            app.SweepPanel = uipanel(app.LeftGrid, 'Title', '');
            app.SweepPanel.Layout.Row = 5;
            app.SweepPanel.Layout.Column = 1;

            sweepGrid = uigridlayout(app.SweepPanel, [6, 2]);
            sweepGrid.RowHeight = {22, 22, 22, 22, 22, 22};
            sweepGrid.ColumnWidth = {120, '1x'};
            sweepGrid.Padding = [10 8 10 8];
            sweepGrid.RowSpacing = 6;
            sweepGrid.ColumnSpacing = 10;

            app.PeakModeLabel = uilabel(sweepGrid, 'Text', 'Peak Mode');
            app.PeakModeLabel.Layout.Row = 1;
            app.PeakModeLabel.Layout.Column = 1;
            app.PeakModeDropDown = uidropdown(sweepGrid, ...
                'Items', {'Single', 'Double'}, 'Value', 'Single', ...
                'ValueChangedFcn', @(src, event) onPeakModeChanged(app)); %#ok<INUSD>
            app.PeakModeDropDown.Layout.Row = 1;
            app.PeakModeDropDown.Layout.Column = 2;
            startFreqLabel = uilabel(sweepGrid, 'Text', 'Start Freq (MHz)');
            startFreqLabel.Layout.Row = 2;
            startFreqLabel.Layout.Column = 1;
            app.StartFreqEdit = uieditfield(sweepGrid, 'numeric', 'Value', 60);
            app.StartFreqEdit.Layout.Row = 2;
            app.StartFreqEdit.Layout.Column = 2;
            stopFreqLabel = uilabel(sweepGrid, 'Text', 'Stop Freq (MHz)');
            stopFreqLabel.Layout.Row = 3;
            stopFreqLabel.Layout.Column = 1;
            app.StopFreqEdit = uieditfield(sweepGrid, 'numeric', 'Value', 90);
            app.StopFreqEdit.Layout.Row = 3;
            app.StopFreqEdit.Layout.Column = 2;
            pointsLabel = uilabel(sweepGrid, 'Text', 'Points');
            pointsLabel.Layout.Row = 4;
            pointsLabel.Layout.Column = 1;
            app.PointsEdit = uieditfield(sweepGrid, 'numeric', 'Value', 501);
            app.PointsEdit.Layout.Row = 4;
            app.PointsEdit.Layout.Column = 2;
            ifbwLabel = uilabel(sweepGrid, 'Text', 'IFBW (Hz)');
            ifbwLabel.Layout.Row = 5;
            ifbwLabel.Layout.Column = 1;
            app.IFBWEdit = uieditfield(sweepGrid, 'numeric', 'Value', 1000);
            app.IFBWEdit.Layout.Row = 5;
            app.IFBWEdit.Layout.Column = 2;
            powerLabel = uilabel(sweepGrid, 'Text', 'Power (dBm)');
            powerLabel.Layout.Row = 6;
            powerLabel.Layout.Column = 1;
            app.PowerEdit = uieditfield(sweepGrid, 'numeric', 'Value', 0);
            app.PowerEdit.Layout.Row = 6;
            app.PowerEdit.Layout.Column = 2;

            app.FilterToggleButton = uibutton(app.LeftGrid, 'push', ...
                'Text', '[+] Filter', ...
                'ButtonPushedFcn', @(btn, event) toggleSection(app, 'filter')); %#ok<INUSD>
            app.FilterToggleButton.Layout.Row = 6;
            app.FilterToggleButton.Layout.Column = 1;
            app.FilterPanel = uipanel(app.LeftGrid, 'Title', '');
            app.FilterPanel.Layout.Row = 7;
            app.FilterPanel.Layout.Column = 1;

            filterGrid = uigridlayout(app.FilterPanel, [3, 2]);
            filterGrid.RowHeight = {22, 22, 26};
            filterGrid.ColumnWidth = {120, '1x'};
            filterGrid.Padding = [10 8 10 8];
            filterGrid.RowSpacing = 6;
            filterGrid.ColumnSpacing = 10;

            filterOrderLabel = uilabel(filterGrid, 'Text', 'Filter Order');
            filterOrderLabel.Layout.Row = 1;
            filterOrderLabel.Layout.Column = 1;
            app.FilterOrderEdit = uieditfield(filterGrid, 'numeric', ...
                'Value', 3, 'Limits', [1 10], 'RoundFractionalValues', 'on');
            app.FilterOrderEdit.Layout.Row = 1;
            app.FilterOrderEdit.Layout.Column = 2;
            filterCutoffLabel = uilabel(filterGrid, 'Text', 'Cutoff (0-1)');
            filterCutoffLabel.Layout.Row = 2;
            filterCutoffLabel.Layout.Column = 1;
            app.FilterCutoffEdit = uieditfield(filterGrid, 'numeric', ...
                'Value', 0.05, 'Limits', [0.001 0.999], ...
                'LowerLimitInclusive', 'on', 'UpperLimitInclusive', 'on');
            app.FilterCutoffEdit.Layout.Row = 2;
            app.FilterCutoffEdit.Layout.Column = 2;
            app.UpdateFilterButton = uibutton(filterGrid, 'push', 'Text', 'Update Filter', ...
                'ButtonPushedFcn', @(btn, event) onUpdateFilter(app)); %#ok<INUSD>
            app.UpdateFilterButton.Layout.Row = 3;
            app.UpdateFilterButton.Layout.Column = [1 2];

            app.ModeToggleButton = uibutton(app.LeftGrid, 'push', ...
                'Text', '[+] Trace / Acquisition', ...
                'ButtonPushedFcn', @(btn, event) toggleSection(app, 'mode')); %#ok<INUSD>
            app.ModeToggleButton.Layout.Row = 8;
            app.ModeToggleButton.Layout.Column = 1;
            app.ModeToggleButton.Visible = 'off';
            app.ModePanel = uipanel(app.LeftGrid, 'Title', '');
            app.ModePanel.Layout.Row = 10;
            app.ModePanel.Layout.Column = 1;

            modeGrid = uigridlayout(app.ModePanel, [3, 2]);
            modeGrid.RowHeight = {22, 22, 22};
            modeGrid.ColumnWidth = {120, '1x'};
            modeGrid.Padding = [10 8 10 8];
            modeGrid.RowSpacing = 6;
            modeGrid.ColumnSpacing = 10;

            app.TraceModeLabel = uilabel(modeGrid, 'Text', 'Trace Mode');
            app.TraceModeLabel.Layout.Row = 1;
            app.TraceModeLabel.Layout.Column = 1;
            app.TraceModeDropDown = uidropdown(modeGrid, ...
                'Items', {'dB', 'Phase'}, 'Value', 'dB', ...
                'ValueChangedFcn', @(src, event) onTraceModeChanged(app)); %#ok<INUSD>
            app.TraceModeDropDown.Layout.Row = 1;
            app.TraceModeDropDown.Layout.Column = 2;
            app.AcqModeLabel = uilabel(modeGrid, 'Text', 'Acq Mode');
            app.AcqModeLabel.Layout.Row = 2;
            app.AcqModeLabel.Layout.Column = 1;
            app.AcqModeDropDown = uidropdown(modeGrid, ...
                'Items', {'Continuous', 'Timed'}, 'Value', 'Continuous', ...
                'ValueChangedFcn', @(src, event) onAcqModeChanged(app)); %#ok<INUSD>
            app.AcqModeDropDown.Layout.Row = 2;
            app.AcqModeDropDown.Layout.Column = 2;
            app.TimedDurationLabel = uilabel(modeGrid, 'Text', 'Timed Duration (s)');
            app.TimedDurationLabel.Layout.Row = 3;
            app.TimedDurationLabel.Layout.Column = 1;
            app.TimedDurationEdit = uieditfield(modeGrid, 'numeric', ...
                'Value', 10, 'Limits', [0.1 Inf]);
            app.TimedDurationEdit.Layout.Row = 3;
            app.TimedDurationEdit.Layout.Column = 2;

            app.ActionPanel = uipanel(app.LeftGrid, 'Title', 'Actions');
            app.ActionPanel.Layout.Row = 11;
            app.ActionPanel.Layout.Column = 1;
            actionGrid = uigridlayout(app.ActionPanel, [2, 3]);
            actionGrid.RowHeight = {40, 40};
            actionGrid.ColumnWidth = {'1x', '1x', '1x'};
            actionGrid.Padding = [10 16 10 16];
            actionGrid.RowSpacing = 12;
            actionGrid.ColumnSpacing = 10;

            app.ConnectSetButton = uibutton(actionGrid, 'push', 'Text', 'Connect and Set', ...
                'ButtonPushedFcn', @(btn, event) onConnectSet(app)); %#ok<INUSD>
            app.ConnectSetButton.Layout.Row = 1;
            app.ConnectSetButton.Layout.Column = 1;
            app.CollectBGButton = uibutton(actionGrid, 'push', 'Text', 'Collect BG', ...
                'ButtonPushedFcn', @(btn, event) onCollectBG(app)); %#ok<INUSD>
            app.CollectBGButton.Layout.Row = 1;
            app.CollectBGButton.Layout.Column = 2;
            app.AddS21Button = uibutton(actionGrid, 'push', 'Text', 'Add S21', ...
                'ButtonPushedFcn', @(btn, event) onAddS21(app)); %#ok<INUSD>
            app.AddS21Button.Layout.Row = 1;
            app.AddS21Button.Layout.Column = 3;
            app.StartButton = uibutton(actionGrid, 'push', 'Text', 'Start', ...
                'ButtonPushedFcn', @(btn, event) onStart(app)); %#ok<INUSD>
            app.StartButton.Layout.Row = 2;
            app.StartButton.Layout.Column = 1;
            app.StopButton = uibutton(actionGrid, 'push', 'Text', 'Stop', ...
                'ButtonPushedFcn', @(btn, event) onStop(app)); %#ok<INUSD>
            app.StopButton.Layout.Row = 2;
            app.StopButton.Layout.Column = 2;
            app.SaveButton = uibutton(actionGrid, 'push', 'Text', 'Save', ...
                'ButtonPushedFcn', @(btn, event) onSave(app)); %#ok<INUSD>
            app.SaveButton.Layout.Row = 2;
            app.SaveButton.Layout.Column = 3;

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
            app.hLineF0 = plot(app.AxesF0, nan, nan, 'r', 'LineWidth', 1.2, 'DisplayName', 'Peak 1');
            app.hLineF1 = plot(app.AxesF0, nan, nan, 'b', 'LineWidth', 1.2, 'DisplayName', 'Peak 2');
            legend(app.AxesF0, 'show');

            drawnow;
            pause(0.2);

            p = app.RightPanel.Position;
            h = p(4) / 2;
            app.AxesS21.Position = [10, h, p(3) - 20, h - 10];
            app.AxesF0.Position = [10, 5, p(3) - 20, h - 10];

            app.updateSectionLayout();
            app.updateTraceAxesForMode();
            app.onAcqModeChanged();
            app.onVNATypeChanged();
            app.onPeakModeChanged();
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

        function toggleSection(app, sectionName)
            sectionName = lower(sectionName);
            switch sectionName
                case 'instrument'
                    target = ~app.instrumentPanelExpanded;
                    app.instrumentPanelExpanded = target;
                    if target
                        app.sweepPanelExpanded = false;
                        app.filterPanelExpanded = false;
                        app.modePanelExpanded = false;
                    end
                case 'sweep'
                    target = ~app.sweepPanelExpanded;
                    app.sweepPanelExpanded = target;
                    if target
                        app.instrumentPanelExpanded = false;
                        app.filterPanelExpanded = false;
                        app.modePanelExpanded = false;
                    end
                case 'filter'
                    target = ~app.filterPanelExpanded;
                    app.filterPanelExpanded = target;
                    if target
                        app.instrumentPanelExpanded = false;
                        app.sweepPanelExpanded = false;
                        app.modePanelExpanded = false;
                    end
                case 'mode'
                    app.modePanelExpanded = true;
            end
            app.updateSectionLayout();
        end

        function updateSectionLayout(app)
            if app.instrumentPanelExpanded
                app.InstrumentToggleButton.Text = '[-] Instrument';
                instrumentH = 110;
                app.InstrumentPanel.Visible = 'on';
            else
                app.InstrumentToggleButton.Text = '[+] Instrument';
                instrumentH = 0;
                app.InstrumentPanel.Visible = 'off';
            end

            if app.sweepPanelExpanded
                app.SweepToggleButton.Text = '[-] Sweep / Peak';
                sweepH = 190;
                app.SweepPanel.Visible = 'on';
            else
                app.SweepToggleButton.Text = '[+] Sweep / Peak';
                sweepH = 0;
                app.SweepPanel.Visible = 'off';
            end

            if app.filterPanelExpanded
                app.FilterToggleButton.Text = '[-] Filter';
                filterH = 102;
                app.FilterPanel.Visible = 'on';
            else
                app.FilterToggleButton.Text = '[+] Filter';
                filterH = 0;
                app.FilterPanel.Visible = 'off';
            end

            app.modePanelExpanded = true;
            modeH = 112;
            app.ModePanel.Visible = 'on';
            app.LeftGrid.RowHeight = {84, 24, instrumentH, 24, sweepH, 24, filterH, 0, '1x', modeH, 132};
        end

        function tf = isE5080A(app)
            tf = strcmp(char(app.VNATypeDropDown.Value), 'E5080A');
        end

        function tf = isLibreVNA(app)
            tf = strcmp(char(app.VNATypeDropDown.Value), 'LibreVNA');
        end

        function mode = getTraceMode(app)
            mode = char(app.TraceModeDropDown.Value);
        end

        function mode = getPeakMode(app)
            mode = char(app.PeakModeDropDown.Value);
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

        function updatePeakPlotVisibility(app)
            if strcmp(app.getPeakMode(), 'Double')
                app.hLineF1.Visible = 'on';
            else
                app.hLineF1.Visible = 'off';
            end
            legend(app.AxesF0, 'show');
        end

        function cleanupInstruments(app)
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
                if ~isempty(app.vi)
                    if strcmp(app.vi.Status, 'open')
                        fclose(app.vi);
                    end
                    delete(app.vi);
                end
            catch
            end
            app.vi = [];
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

        function [f_peak, mag_peak] = extract_two_peaks(~, freq, traceData, minHeight)
            if isempty(freq) || isempty(traceData)
                f_peak = [NaN; NaN];
                mag_peak = [NaN; NaN];
                return;
            end
            if nargin < 4 || isempty(minHeight)
                [pks, locs] = findpeaks(traceData, freq);
            else
                [pks, locs] = findpeaks(traceData, freq, 'MinPeakHeight', minHeight, 'MinPeakDistance', 2e6);
            end
            if isempty(pks)
                f_peak = [NaN; NaN];
                mag_peak = [NaN; NaN];
                return;
            end
            if numel(pks) == 1
                f_peak = [locs(1); NaN];
                mag_peak = [pks(1); NaN];
                return;
            end
            if numel(pks) == 2
                [f_peak, idx] = sort(locs, 'ascend');
                mag_peak = pks(idx);
                return;
            end
            [mag2, idx2] = maxk(pks, 2);
            f2 = locs(idx2);
            [f_peak, idxSort] = sort(f2, 'ascend');
            mag_peak = mag2(idxSort);
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

        function [x_plot, raw_trace, filtered_trace, peakVals] = computeActiveTrace(app, freq, s21)
            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
            order = app.cfg.filterOrder;
            cutoff = app.cfg.filterCutoffNorm;
            s21_corrected = app.apply_background_correction(freq, s21);
            traceMode = app.getTraceMode();
            peakMode = app.getPeakMode();

            if strcmp(traceMode, 'Phase')
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
                if strcmp(peakMode, 'Double')
                    peakVals = app.extract_two_peaks(freq_my, s21_phasecorr, 0.2);
                else
                    peakVals = [app.extract_peak_frequency(freq_my, s21_phasecorr); NaN];
                end
            else
                s21_db = 20 * log10(abs(s21_corrected) + eps);
                s21_db_filtered = app.filter_trace(s21_db, order, cutoff);
                x_plot = freq(:);
                raw_trace = s21_db(:);
                filtered_trace = s21_db_filtered(:);
                if strcmp(peakMode, 'Double')
                    peakVals = app.extract_two_peaks(freq, s21_db_filtered, []);
                else
                    peakVals = [app.extract_peak_frequency(freq, s21_db_filtered); NaN];
                end
            end
            peakVals = peakVals(:);
            if numel(peakVals) < 2
                peakVals = [peakVals; NaN];
            end
        end

        function [added, totalSets] = appendLatestS21(app)
            added = false;
            totalSets = numel(app.allS21);
            if isempty(app.latestData)
                return;
            end
            app.allS21{end + 1} = app.latestData;
            added = true;
            totalSets = numel(app.allS21);
        end

        function discardCurrentSegment(app)
            idx = app.currentSegmentStartIndex;
            if idx <= numel(app.f0time)
                app.f0time(idx:end) = [];
                app.peakFreq(idx:end) = [];
                app.peakFreq1(idx:end) = [];
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
                set(app.hLineF1, 'XData', app.f0time, 'YData', app.peakFreq1);
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
            [x_plot, raw_trace, filtered_trace, peakVals] = app.computeActiveTrace(freq, s21);
            try
                set(app.hLineRaw, 'XData', x_plot / 1e6, 'YData', raw_trace);
                set(app.hLineFiltered, 'XData', x_plot / 1e6, 'YData', filtered_trace);
                if updateLastPeak && ~isempty(app.peakFreq)
                    app.peakFreq(end) = peakVals(1) / 1e6;
                    app.peakFreq1(end) = peakVals(2) / 1e6;
                    set(app.hLineF0, 'XData', app.f0time, 'YData', app.peakFreq);
                    set(app.hLineF1, 'XData', app.f0time, 'YData', app.peakFreq1);
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

        function setInstrumentUi(app)
            if app.isLibreVNA()
                app.AddressEdit.Value = app.libreHost;
                app.PortEdit.Value = app.librePort;
                app.PortEdit.Enable = 'on';
            else
                app.AddressEdit.Value = app.e5080aAddress;
                app.PortEdit.Enable = 'off';
            end
        end

        function onVNATypeChanged(app)
            app.setInstrumentUi();
            app.setStatus(sprintf('Instrument type switched to %s.', char(app.VNATypeDropDown.Value)));
        end

        function onPeakModeChanged(app)
            app.updatePeakPlotVisibility();
            app.refreshLatestDisplay(~isempty(app.f0time));
            app.setStatus(sprintf('Peak mode switched to %s.', app.getPeakMode()));
        end

        function connectLibreVNA(app)
            app.libreHost = char(app.AddressEdit.Value);
            app.librePort = round(double(app.PortEdit.Value));
            app.vna = libreVNA(app.libreHost, app.librePort);
            try
                app.vna.cmd(':DEV:CONN');
                dev = strtrim(app.vna.query(':DEV:CONN?'));
                app.setStatus(['Connected: ' dev]);
            catch
                app.setStatus('Connected to LibreVNA');
            end
            startHz = double(app.StartFreqEdit.Value) * 1e6;
            stopHz = double(app.StopFreqEdit.Value) * 1e6;
            Npts = round(double(app.PointsEdit.Value));
            IFBW = double(app.IFBWEdit.Value);
            power = double(app.PowerEdit.Value);
            app.vna.cmd(':DEV:MODE VNA');
            app.vna.cmd(':VNA:SWEEP FREQUENCY');
            app.vna.cmd(sprintf(':VNA:ACQ:POINTS %d', Npts));
            app.vna.cmd(sprintf(':VNA:ACQ:IFBW %d', IFBW));
            app.vna.cmd(sprintf(':VNA:FREQuency:START %d', round(startHz)));
            app.vna.cmd(sprintf(':VNA:FREQuency:STOP %d', round(stopHz)));
            app.vna.cmd(sprintf(':VNA:STIM:LVL %g', power));
            app.vna.cmd('VNA:ACQuisition:SINGLE FALSE');
            app.refFreq = linspace(startHz, stopHz, Npts).';
        end

        function connectE5080A(app)
            obj = instrfind;
            if ~isempty(obj)
                fclose(obj);
                delete(obj);
            end
            clear obj;
            app.e5080aAddress = char(app.AddressEdit.Value);
            resource = ['TCPIP0::' app.e5080aAddress '::hislip0::INSTR'];
            app.vi = visa('AGILENT', resource);
            set(app.vi, 'InputBufferSize', 200000, 'Timeout', 10);
            fopen(app.vi);
            idn = query(app.vi, '*IDN?');
            app.setStatus(['Connected: ' strtrim(idn)]);
            startMHz = double(app.StartFreqEdit.Value);
            stopMHz = double(app.StopFreqEdit.Value);
            Npts = round(double(app.PointsEdit.Value));
            IFBW = double(app.IFBWEdit.Value);
            power = double(app.PowerEdit.Value);
            fprintf(app.vi, sprintf('SOUR:POWER %g', power));
            fprintf(app.vi, sprintf('SENS:FREQ:START %gMHz', startMHz));
            fprintf(app.vi, sprintf('SENS:FREQ:STOP %gMHz', stopMHz));
            fprintf(app.vi, sprintf('SENS:SWEEP:POINTS %d', Npts));
            fprintf(app.vi, sprintf('SENS:BAND %g', IFBW));
            fprintf(app.vi, 'CALC:PAR:MNUM 1');
            fprintf(app.vi, 'FORM:BORD SWAP');
            fprintf(app.vi, 'FORM REAL,64');
            fprintf(app.vi, ':INIT:CONT OFF');
            app.refFreq = linspace(startMHz * 1e6, stopMHz * 1e6, Npts).';
        end
        function onConnectSet(app)
            app.cleanupInstruments();
            app.setStatus(sprintf('Connecting to %s...', char(app.VNATypeDropDown.Value)));
            try
                if app.isLibreVNA()
                    app.connectLibreVNA();
                else
                    app.connectE5080A();
                end
                app.cfg.vnaType = char(app.VNATypeDropDown.Value);
                app.cfg.traceMode = app.getTraceMode();
                app.cfg.peakMode = app.getPeakMode();
                app.cfg.acqMode = app.getAcqMode();
                app.cfg.timedDuration = app.getTimedDuration();
                [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
                app.cfg.startFreq_MHz = app.StartFreqEdit.Value;
                app.cfg.stopFreq_MHz = app.StopFreqEdit.Value;
                app.cfg.numPoints = app.PointsEdit.Value;
                app.cfg.ifBW = app.IFBWEdit.Value;
                app.cfg.powerLevel = app.PowerEdit.Value;
                app.setStatus(sprintf(['Connected and configured.\nInstrument: %s\nTrace: %s\nPeak mode: %s'], ...
                    app.cfg.vnaType, app.cfg.traceMode, app.cfg.peakMode));
            catch ME
                app.cleanupInstruments();
                app.setStatus(['Connect failed: ' ME.message]);
            end
        end

        function [freqVec, S21vec] = collectS21(app)
            freqVec = [];
            S21vec = [];
            if app.isLibreVNA()
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
                return;
            end
            if isempty(app.vi)
                return;
            end
            try
                fprintf(app.vi, 'CALCulate:DATA? SDATA');
                rawdata = binblockread(app.vi, 'double');
                try
                    fscanf(app.vi);
                catch
                end
                if isempty(rawdata)
                    return;
                end
                realPart = rawdata(1:2:end);
                imagPart = rawdata(2:2:end);
                S21vec = realPart + 1i * imagPart;
                if ~isempty(app.refFreq)
                    freqVec = app.refFreq;
                else
                    s = str2double(query(app.vi, 'SENS:FREQ:START?'));
                    e = str2double(query(app.vi, 'SENS:FREQ:STOP?'));
                    freqVec = linspace(s, e, numel(S21vec)).';
                end
            catch ME
                app.setStatus(['Collect S21 error: ' ME.message]);
            end
        end

        function startInstrumentAcquisition(app)
            if app.isLibreVNA()
                app.vna.cmd(':VNA:ACQ:RUN');
            else
                fprintf(app.vi, ':INITiate1:IMMediate; *WAI');
                fprintf(app.vi, 'INIT:CONT ON');
                fprintf(app.vi, 'TRIG:SOUR IMM');
                fprintf(app.vi, 'SENSe1:SWEep:MODE CONT');
            end
        end

        function stopInstrumentAcquisition(app)
            if app.isLibreVNA()
                app.vna.cmd(':VNA:ACQ:STOP');
            else
                fprintf(app.vi, 'INIT:CONT OFF');
            end
        end

        function fetchAndDisplay(app)
            [freq, s21] = app.collectS21();
            if isempty(freq) || isempty(s21)
                return;
            end
            app.latestData = [freq(:), s21(:)];
            [x_plot, raw_trace, filtered_trace, peakVals] = app.computeActiveTrace(freq, s21);
            try
                set(app.hLineRaw, 'XData', x_plot / 1e6, 'YData', raw_trace);
                set(app.hLineFiltered, 'XData', x_plot / 1e6, 'YData', filtered_trace);
            catch
            end
            if isempty(app.start_time)
                app.start_time = tic;
                tnow = 0;
            else
                tnow = toc(app.start_time);
            end
            app.f0time(end + 1) = tnow + app.lastf0time; %#ok<AGROW>
            app.peakFreq(end + 1) = peakVals(1) / 1e6; %#ok<AGROW>
            app.peakFreq1(end + 1) = peakVals(2) / 1e6; %#ok<AGROW>
            app.Movestatus(end + 1) = app.Moven; %#ok<AGROW>
            try
                set(app.hLineF0, 'XData', app.f0time, 'YData', app.peakFreq);
                set(app.hLineF1, 'XData', app.f0time, 'YData', app.peakFreq1);
                drawnow limitrate;
            catch
            end
        end
    end

    methods (Access = public)
        function app = VNA_RealtimeApp_General()
            createComponents(app);
            app.cfg = struct();
            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
            app.cfg.traceMode = app.getTraceMode();
            app.cfg.peakMode = app.getPeakMode();
            app.cfg.acqMode = app.getAcqMode();
            app.cfg.timedDuration = app.getTimedDuration();
            app.AcquisitionTimer = [];
            app.StopScheduleTimer = [];
            app.refFreq = [];
            app.setStatus('Ready - please Connect and Set');
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
            app.cleanupInstruments();
            try
                delete(app.UIFigure);
            catch
            end
        end
    end

    methods (Access = private)
        function onStart(app)
            if app.isLibreVNA() && isempty(app.vna)
                app.setStatus('Please Connect first');
                return;
            end
            if app.isE5080A() && isempty(app.vi)
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
            app.cfg.traceMode = app.getTraceMode();
            app.cfg.peakMode = app.getPeakMode();
            app.cfg.acqMode = app.getAcqMode();
            app.cfg.timedDuration = app.getTimedDuration();
            app.currentSegmentStartIndex = numel(app.f0time) + 1;
            app.startInstrumentAcquisition();
            pause(0.5);
            app.AcquisitionTimer = timer( ...
                'ExecutionMode', 'fixedRate', ...
                'Period', 0.1, ...
                'BusyMode', 'drop', ...
                'TimerFcn', @(~, ~) fetchAndDisplay(app));
            if strcmp(app.cfg.acqMode, 'Timed')
                app.StopScheduleTimer = timer( ...
                    'ExecutionMode', 'singleShot', ...
                    'StartDelay', app.cfg.timedDuration, ...
                    'TimerFcn', @(~, ~) onStop(app));
                start(app.StopScheduleTimer);
            end
            app.start_time = [];
            start(app.AcquisitionTimer);
            app.setStatus(sprintf(['Acquisition started.\nInstrument: %s\nTrace: %s\nPeak mode: %s'], ...
                char(app.VNATypeDropDown.Value), app.cfg.traceMode, app.cfg.peakMode));
        end

        function onStop(app)
            try
                app.stopScheduledTimer();
                if ~isempty(app.AcquisitionTimer) && isvalid(app.AcquisitionTimer)
                    stop(app.AcquisitionTimer);
                    delete(app.AcquisitionTimer);
                    app.AcquisitionTimer = [];
                end
                app.start_time = [];
                app.stopInstrumentAcquisition();
                if app.currentSegmentStartIndex <= numel(app.f0time)
                    selection = uiconfirm(app.UIFigure, ...
                        ['Keep the current segment f0/time data and save the current S21 curve?', newline, ...
                        'Keep: keep this segment and save current S21', newline, ...
                        'Discard: remove this segment and continue from the previous kept time'], ...
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
                        app.setStatus(sprintf('Acquisition stopped. Current segment kept. Raw S21 saved. Total sets: %d', totalSets));
                    else
                        app.setStatus('Acquisition stopped. Current segment kept. No S21 data available to save.');
                    end
                else
                    app.discardCurrentSegment();
                    app.setStatus(sprintf('Acquisition stopped. Current segment discarded. Next start continues after %.6f s', app.lastf0time));
                end
            catch ME
                app.setStatus(['Stop error: ' ME.message]);
            end
        end

        function onUpdateFilter(app)
            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
            if isempty(app.latestData)
                app.setStatus(sprintf('Filter updated. Order: %d, cutoff: %.3f. Waiting for data.', ...
                    app.cfg.filterOrder, app.cfg.filterCutoffNorm));
                return;
            end
            app.refreshLatestDisplay(~isempty(app.f0time));
            app.setStatus(sprintf('Filter updated immediately. Order: %d, cutoff: %.3f', ...
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
                app.setStatus(sprintf('Acquisition mode switched to Timed. Duration: %.2f s', app.getTimedDuration()));
            else
                app.setStatus('Acquisition mode switched to Continuous.');
            end
        end
        function onCollectBG(app)
            if app.isLibreVNA() && isempty(app.vna)
                app.setStatus('Not connected');
                return;
            end
            if app.isE5080A() && isempty(app.vi)
                app.setStatus('Not connected');
                return;
            end
            app.setStatus('Collecting background.');
            [freq, s21] = app.collectS21();
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
            app.setStatus(sprintf('BG collected %d points', numel(s21)));
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
                fprintf(fid2, 'time(s),f0(MHz),f1(MHz),MovenStatus\n');
                for i = 1:numel(app.f0time)
                    fprintf(fid2, '%.6f,%.6f,%.6f,%d\n', app.f0time(i), app.peakFreq(i), app.peakFreq1(i), app.Movestatus(i));
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




