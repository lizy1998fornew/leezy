classdef LibreVNA_RealtimeApp_dbmaxpeak < matlab.apps.AppBase
    % LibreVNA_RealtimeApp_dbmaxpeak
    % 保留 LibreVNA 实时采集、背景采集、保存等逻辑
    % 图窗仅保留两条曲线：
    % 1) S21 的 dB 曲线
    % 2) 从 S21 dB 曲线提取的最大峰位频率随时间变化

    properties (Access = public)
        UIFigure             matlab.ui.Figure
        ConnectSetButton     matlab.ui.control.Button
        CollectBGButton      matlab.ui.control.Button
        StartButton          matlab.ui.control.Button
        StopButton           matlab.ui.control.Button
        AddS21Button         matlab.ui.control.Button
        SaveButton           matlab.ui.control.Button
        StatusLabel          matlab.ui.control.Label
        GridLayout           matlab.ui.container.GridLayout
        LeftPanel            matlab.ui.container.Panel
        StartFreqEdit        matlab.ui.control.NumericEditField
        StopFreqEdit         matlab.ui.control.NumericEditField
        PointsEdit           matlab.ui.control.NumericEditField
        IFBWEdit             matlab.ui.control.NumericEditField
        PowerEdit            matlab.ui.control.NumericEditField
        FilterLabel          matlab.ui.control.Label
        FilterOrderEdit      matlab.ui.control.NumericEditField
        FilterCutoffEdit     matlab.ui.control.NumericEditField
        ParamLabel           matlab.ui.control.Label
        RightPanel           matlab.ui.container.Panel
        AxesS21              matlab.ui.control.UIAxes
        AxesF0               matlab.ui.control.UIAxes
    end

    properties (Access = private)
        % LibreVNA & acquisition
        vna
        IPofVNA = 'localhost'
        VNAPort = 19542

        % config & data
        cfg
        refFreq

        % data storage
        allS21 = {}
        latestData = []
        S21b = []
        peakFreq = []
        f0time = []
        Movestatus = []
        Moven = 0
        lastf0time = 0

        % plotting handles
        hLineS21
        hLineS21Filtered
        hLineF0

        % timer
        AcquisitionTimer

        % other
        start_time
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('Name','LibreVNA Realtime Collector','Position',[100 100 1200 700]);

            app.GridLayout = uigridlayout(app.UIFigure,[1,2]);
            app.GridLayout.ColumnWidth = {320,'1x'};

            app.LeftPanel = uipanel(app.GridLayout,'Title','Parameters & Control');
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            app.ParamLabel = uilabel(app.LeftPanel,'Text','Sweep Parameters','Position',[10 460 300 30]);

            uilabel(app.LeftPanel,'Text','Start Freq (MHz)','Position',[10 430 120 20]);
            app.StartFreqEdit = uieditfield(app.LeftPanel,'numeric','Value',60,'Position',[140 430 140 22]);

            uilabel(app.LeftPanel,'Text','Stop Freq (MHz)','Position',[10 390 120 20]);
            app.StopFreqEdit = uieditfield(app.LeftPanel,'numeric','Value',90,'Position',[140 390 140 22]);

            uilabel(app.LeftPanel,'Text','Points','Position',[10 350 120 20]);
            app.PointsEdit = uieditfield(app.LeftPanel,'numeric','Value',501,'Position',[140 350 140 22]);

            uilabel(app.LeftPanel,'Text','IFBW (Hz)','Position',[10 310 120 20]);
            app.IFBWEdit = uieditfield(app.LeftPanel,'numeric','Value',1000,'Position',[140 310 140 22]);

            uilabel(app.LeftPanel,'Text','Power (dBm)','Position',[10 270 120 20]);
            app.PowerEdit = uieditfield(app.LeftPanel,'numeric','Value',0,'Position',[140 270 140 22]);

            app.FilterLabel = uilabel(app.LeftPanel,'Text','Filter Parameters','Position',[10 225 300 22]);

            uilabel(app.LeftPanel,'Text','Filter Order','Position',[10 200 120 20]);
            app.FilterOrderEdit = uieditfield(app.LeftPanel,'numeric', ...
                'Value',3, 'Limits',[1 10], 'RoundFractionalValues','on', ...
                'Position',[140 200 140 22]);

            uilabel(app.LeftPanel,'Text','Cutoff (0-1)','Position',[10 165 120 20]);
            app.FilterCutoffEdit = uieditfield(app.LeftPanel,'numeric', ...
                'Value',0.05, 'Limits',[0.001 0.999], ...
                'LowerLimitInclusive','on', 'UpperLimitInclusive','on', ...
                'Position',[140 165 140 22]);

            app.ConnectSetButton = uibutton(app.LeftPanel,'push','Text','Connect & Set', ...
                'Position',[10 120 120 30],'ButtonPushedFcn',@(btn,event) onConnectSet_libreVNA(app)); %#ok<INUSD>

            app.CollectBGButton = uibutton(app.LeftPanel,'push','Text','Collect BG', ...
                'Position',[150 120 120 30],'ButtonPushedFcn',@(btn,event) onCollectBG(app)); %#ok<INUSD>

            app.AddS21Button = uibutton(app.LeftPanel,'push','Text','Add S21', ...
                'Position',[10 80 120 30],'ButtonPushedFcn',@(btn,event) onAddS21(app)); %#ok<INUSD>

            app.StartButton = uibutton(app.LeftPanel,'push','Text','Start', ...
                'Position',[10 40 120 30],'ButtonPushedFcn',@(btn,event) onStart_libreVNA(app)); %#ok<INUSD>
            app.StopButton = uibutton(app.LeftPanel,'push','Text','Stop', ...
                'Position',[150 40 120 30],'ButtonPushedFcn',@(btn,event) onStop_libreVNA(app)); %#ok<INUSD>
            app.SaveButton = uibutton(app.LeftPanel,'push','Text','Save', ...
                'Position',[10 5 120 30],'ButtonPushedFcn',@(btn,event) onSave(app)); %#ok<INUSD>

            app.StatusLabel = uilabel(app.LeftPanel,'Text','Ready - Not connected','Position',[10 495 280 30]);

            app.RightPanel = uipanel(app.GridLayout,'Title','Realtime Plots');
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            app.AxesS21 = uiaxes(app.RightPanel);
            hold(app.AxesS21,'on');
            grid(app.AxesS21,'on');
            title(app.AxesS21,'S21 Magnitude (dB)');
            xlabel(app.AxesS21,'Freq (MHz)');
            ylabel(app.AxesS21,'S21 (dB)');
            app.hLineS21 = plot(app.AxesS21,nan,nan,'b','LineWidth',1.0,'DisplayName','S21 dB Raw');
            app.hLineS21Filtered = plot(app.AxesS21,nan,nan,'r','LineWidth',1.4,'DisplayName','S21 dB Filtered');
            legend(app.AxesS21,'show');

            app.AxesF0 = uiaxes(app.RightPanel);
            hold(app.AxesF0,'on');
            grid(app.AxesF0,'on');
            title(app.AxesF0,'Peak Frequency From S21 dB');
            xlabel(app.AxesF0,'Time (s)');
            ylabel(app.AxesF0,'Peak Freq (MHz)');
            app.hLineF0 = plot(app.AxesF0,nan,nan,'r','LineWidth',1.2,'DisplayName','Peak Freq');

            drawnow;
            pause(2);

            p = app.RightPanel.Position;
            h = p(4) / 2;
            app.AxesS21.Position = [10, h, p(3) - 20, h - 10];
            app.AxesF0.Position = [10, 5, p(3) - 20, h - 10];
        end

        function setStatus(app,msg)
            if isvalid(app.UIFigure)
                app.StatusLabel.Text = msg;
                drawnow limitrate;
            end
        end

        function s = complexToMatlabStr(~,z)
            n = numel(z);
            s = strings(n,1);
            for ii = 1:n
                a = real(z(ii));
                b = imag(z(ii));
                s(ii) = sprintf('%+.6e%+.6ei',a,b);
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

        function [f_peak, mag_peak] = extract_peak_frequency(~, freq, S21_db)
            if isempty(freq) || isempty(S21_db)
                f_peak = NaN;
                mag_peak = NaN;
                return;
            end
            [mag_peak, idx] = max(S21_db);
            f_peak = freq(idx);
        end

        function S_filtered = filter_s21_db(~, S, order, cutoff_norm)
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

        function fetch_and_display_data_libreVNA(app)
            if isempty(app.vna)
                return;
            end

            [freq, s21] = collectS21_from_libreVNA(app);
            if isempty(freq) || isempty(s21)
                return;
            end

            app.latestData = [freq(:), s21(:)];

            if ~isempty(app.S21b)
                if numel(app.S21b) == numel(s21)
                    s21_corrected = s21 - app.S21b;
                else
                    try
                        bgFreq = app.allS21{1}(:,1);
                        bg_interp = interp1(bgFreq, app.S21b, freq, 'linear', 'extrap');
                        s21_corrected = s21 - bg_interp;
                    catch
                        s21_corrected = s21;
                    end
                end
            else
                s21_corrected = s21;
            end

            s21_db = 20 * log10(abs(s21_corrected) + eps);
            [filterOrder, filterCutoff] = app.getFilterSettings();
            s21_db_filtered = app.filter_s21_db(s21_db, filterOrder, filterCutoff);
            [f_peak, ~] = app.extract_peak_frequency(freq, s21_db_filtered);

            if isempty(app.start_time)
                app.start_time = tic;
                tnow = 0;
            else
                tnow = toc(app.start_time);
            end
            app.f0time(end+1) = tnow + app.lastf0time; %#ok<AGROW>
            app.peakFreq(end+1) = f_peak / 1e6; %#ok<AGROW>
            app.Movestatus(end+1) = app.Moven; %#ok<AGROW>

            try
                set(app.hLineS21,'XData',freq / 1e6,'YData',s21_db);
                set(app.hLineS21Filtered,'XData',freq / 1e6,'YData',s21_db_filtered);
                set(app.hLineF0,'XData',app.f0time,'YData',app.peakFreq);
                drawnow limitrate;
            catch
                % ignore plotting errors
            end
        end
    end

    methods (Access = public)
        function app = LibreVNA_RealtimeApp_dbmaxpeak()
            createComponents(app);

            app.cfg.startFreq_MHz = app.StartFreqEdit.Value;
            app.cfg.stopFreq_MHz  = app.StopFreqEdit.Value;
            app.cfg.numPoints = app.PointsEdit.Value;
            app.cfg.ifBW = app.IFBWEdit.Value;
            app.cfg.powerLevel = app.PowerEdit.Value;
            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
            app.AcquisitionTimer = [];
            app.refFreq = [];
            setStatus(app,'Ready - please Connect & Set');

            app.UIFigure.CloseRequestFcn = @(~,~) onClose(app);
        end

        function delete(app)
            onClose(app);
        end

        function onClose(app)
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
                        app.vna.cmd(":VNA:ACQ:STOP");
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
                    app.vna.cmd(":DEV:CONN");
                    dev = strtrim(app.vna.query(":DEV:CONN?"));
                    app.setStatus(['Connected: ' dev]);
                catch
                    app.setStatus('Connected to LibreVNA (no dev string)');
                end

                startHz = double(app.StartFreqEdit.Value) * 1e6;
                stopHz  = double(app.StopFreqEdit.Value) * 1e6;
                Npts    = round(double(app.PointsEdit.Value));
                IFBW    = double(app.IFBWEdit.Value);
                power   = double(app.PowerEdit.Value);
                [filterOrder, filterCutoff] = app.getFilterSettings();

                app.vna.cmd(":DEV:MODE VNA");
                app.vna.cmd(":VNA:SWEEP FREQUENCY");
                app.vna.cmd(sprintf(":VNA:ACQ:POINTS %d", Npts));
                app.vna.cmd(sprintf(":VNA:ACQ:IFBW %d", IFBW));
                app.vna.cmd(sprintf(":VNA:FREQuency:START %d", round(startHz)));
                app.vna.cmd(sprintf(":VNA:FREQuency:STOP %d", round(stopHz)));
                app.vna.cmd(sprintf(":VNA:STIM:LVL %d", power));
                app.vna.cmd("VNA:ACQuisition:SINGLE FALSE");

                app.refFreq = linspace(startHz, stopHz, Npts).';
                app.cfg.startFreq_MHz = startHz / 1e6;
                app.cfg.stopFreq_MHz = stopHz / 1e6;
                app.cfg.numPoints = Npts;
                app.cfg.ifBW = IFBW;
                app.cfg.powerLevel = power;
                app.cfg.filterOrder = filterOrder;
                app.cfg.filterCutoffNorm = filterCutoff;

                app.setStatus(sprintf('Connected & Configured (Filter: order %d, cutoff %.3f).', filterOrder, filterCutoff));
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
                raw = app.vna.query(":VNA:TRACE:DATA? S21");
                data = libreVNA.parse_VNA_trace_data(raw);
                freqVec = data(:,1);
                S21vec = data(:,2);
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

            [app.cfg.filterOrder, app.cfg.filterCutoffNorm] = app.getFilterSettings();
            app.vna.cmd(":VNA:ACQ:RUN");
            pause(2);

            app.AcquisitionTimer = timer( ...
                'ExecutionMode','fixedRate', ...
                'Period',0.1, ...
                'BusyMode','drop', ...
                'TimerFcn', @(~,~) fetch_and_display_data_libreVNA(app));

            app.start_time = [];
            start(app.AcquisitionTimer);
            app.setStatus(sprintf('Acquisition started (filter order %d, cutoff %.3f)', ...
                app.cfg.filterOrder, app.cfg.filterCutoffNorm));
        end

        function onStop_libreVNA(app)
            try
                if ~isempty(app.AcquisitionTimer) && isvalid(app.AcquisitionTimer)
                    stop(app.AcquisitionTimer);
                    delete(app.AcquisitionTimer);
                    app.AcquisitionTimer = [];
                end

                app.start_time = [];
                if ~isempty(app.f0time)
                    app.lastf0time = app.f0time(end);
                end

                app.vna.cmd(":VNA:ACQ:STOP");
                app.setStatus('Acquisition stopped.');
            catch ME
                app.setStatus(['Stop error: ' ME.message]);
            end
        end
    end

    methods (Access = private)
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
            app.setStatus(sprintf('BG collected %d pts', numel(s21)));
        end

        function onAddS21(app)
            if isempty(app.latestData)
                app.setStatus('No latest data');
                return;
            end

            app.allS21{end+1} = app.latestData;
            app.setStatus(sprintf('Added S21 (total sets %d)', numel(app.allS21)));
        end

        function onSave(app)
            if isempty(app.allS21)
                uialert(app.UIFigure,'No S21 data to save','Warning');
                return;
            end

            [file, path] = uiputfile('*.csv','Save S21 data',fullfile(pwd,'S21_data.csv'));
            if isequal(file,0)
                return;
            end

            base_name = erase(file,'.csv');
            save_dir = path;
            ref = app.allS21{1};
            freqs = ref(:,1);
            npts = numel(freqs);
            nsets = numel(app.allS21);

            data_mat = strings(npts,2 + nsets);
            if isempty(app.S21b)
                bg_str = repmat("0+0i", npts, 1);
            else
                if numel(app.S21b) == npts
                    bg_str = app.complexToMatlabStr(app.S21b);
                else
                    try
                        bg_interp = interp1(app.allS21{1}(:,1), app.S21b, freqs, 'linear', 'extrap');
                        bg_str = app.complexToMatlabStr(bg_interp);
                    catch
                        bg_str = repmat("0+0i", npts, 1);
                    end
                end
            end

            data_mat(:,1) = string(freqs);
            data_mat(:,2) = bg_str;
            for k = 1:nsets
                sdat = app.allS21{k};
                if ~isequal(size(sdat,1), npts) || any(sdat(:,1) ~= freqs)
                    s_comp = interp1(sdat(:,1), sdat(:,2), freqs, 'linear', 'extrap');
                else
                    s_comp = sdat(:,2);
                end
                data_mat(:,2 + k) = app.complexToMatlabStr(s_comp);
            end

            data_path = fullfile(save_dir, sprintf('%s_all_S21.csv', base_name));
            fid = fopen(data_path,'w');
            header = 'freq(Hz),S21b';
            for k = 1:nsets
                header = [header, sprintf(',S21_%d', k)]; %#ok<AGROW>
            end
            fprintf(fid,'%s\n',header);
            for i = 1:npts
                fprintf(fid,'%s,%s',data_mat{i,1},data_mat{i,2});
                for k = 1:nsets
                    fprintf(fid,',%s',data_mat{i,2 + k});
                end
                fprintf(fid,'\n');
            end
            fclose(fid);

            if ~isempty(app.f0time) && ~isempty(app.peakFreq)
                peak_path = fullfile(save_dir, sprintf('%s_peakfreq.csv', base_name));
                fid2 = fopen(peak_path,'w');
                fprintf(fid2,'time(s),peakFreq(MHz),MovenStatus\n');
                for i = 1:numel(app.f0time)
                    fprintf(fid2,'%.6f,%.6f,%d\n',app.f0time(i),app.peakFreq(i),app.Movestatus(i));
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
