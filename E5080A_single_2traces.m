clear; clc;
obj = instrfind;
if ~isempty(obj)
    fclose(obj);
    delete(obj);
    clear obj;
end

% Set VISA Address String for Instrument
IPofVNA = '169.254.111.39';  
strInstr = strcat('TCPIP0::', IPofVNA, '::hislip0::INSTR');

% Create a VISA object
try
    vi = visa('AGILENT', strInstr);
    % Configure instrument object
    set(vi, 'InputBufferSize', 200000);
    set(vi, 'Timeout', 100);
    
    % Connect to instrument object
    fopen(vi);
    
    fprintf('Connected to: %s\n', query(vi, '*IDN?'));

    % Set parameters
    startFreq = 65; % 起始频率 (MHz)
    stopFreq = 95; % 终止频率 (MHz)
    numPoints = 301; % 扫频点数
    ifBW = 100; % 中频带宽 (Hz)
     % 设置功率
    powerLevel = 18; % 设置功率 (dBm)
    fprintf(vi, 'SOUR:POWER %d', powerLevel); % 设置源功率

    % 配置频率参数
    fprintf(vi, 'SENS:FREQ:START %dMHz', startFreq);
    fprintf(vi, 'SENS:FREQ:STOP %dMHz', stopFreq);
    fprintf(vi, 'SENS:SWEEP:POINTS %d', numPoints);
    fprintf(vi, 'SENS:BAND %d', ifBW);
    %fprintf(vi, 'CALCulate:PARameter:DEFine:EXT "MyMeas","S21"'); 
    fprintf(vi, 'CALC:PAR:MNUM 1');
    fprintf(vi, 'FORM:BORD SWAP');
    fprintf(vi, 'FORM REAL,64');
    % 设置LF AUTO BW
    %fprintf(vi, 'SENS:BAND:LF:AUTO ON'); % 打开 LF AUTO 中频带宽
    % 生成频率数据 (MHz)
    Freq = linspace(startFreq, stopFreq, numPoints); 
    % 每次采集前开启扫描并等待完成
    fprintf(vi, ':INIT:CONT OFF'); % 关闭连续模式
    fprintf(vi, ':INITiate1:IMMediate; *WAI'); % 启动扫描并等待完成
    % 采集数据
    S_data = collectS21(vi);
    S21=S_data(1:numPoints);
    S11=S_data(numPoints+1:end);
    % 绘制结果
%     figure;
    subplot(4,1,1)
    plot(Freq, 20 * log10(abs(S21))); % 绘图
    title('S21 Magnitude Response');
    xlabel('Frequency (GHz)');
    ylabel('Magnitude (dB)');
    grid on;

    % 绘制结果
%     figure;
    subplot(4,1,2)
    plot(Freq, angle(S21)/pi*180); % 绘图
    title('S21 Phase Response');
    xlabel('Frequency (GHz)');
    ylabel('Phase (dB)');
    grid on;

     subplot(4,1,3)
    plot(Freq, 20 * log10(abs(S11))); % 绘图
    title('S21 Magnitude Response');
    xlabel('Frequency (GHz)');
    ylabel('Magnitude (dB)');
    grid on;

    % 绘制结果
%     figure;
    subplot(4,1,4)
    plot(Freq, angle(S11)/pi*180); % 绘图
    title('S21 Phase Response');
    xlabel('Frequency (GHz)');
    ylabel('Phase (dB)');
    grid on;

   catch ME
    fprintf('Error: %s\n', ME.message);
end

% 清理
if exist('vi', 'var')
    fclose(vi);
    delete(vi);
end
[file, path] = uiputfile('*.txt', '保存 S21 数据');
    if isequal(file, 0) || isequal(path, 0)
        disp('用户取消保存');
        return;
    else
        fullPath = fullfile(path, file);
        
        writematrix(S_data, fullPath, 'Delimiter', 'tab');  % 使用 writetable 保存表格
        disp(['数据已保存到: ', fullPath]);
    end

% 采集S21的函数
function S21 = collectS21(vi)
    % 读取S21数据
%     fprintf(vi, 'CALCulate:DATA? SDATA');
    fprintf(vi, 'CALCulate:DATA:MSD? "1,2"');
    [data, ~, ~] = binblockread(vi, 'double');
    fscanf(vi); % 移除终止字符 
    % 获取S21的实部和虚部
    realPart = data(1:2:end);
    imagPart = data(2:2:end);
    S21 = realPart + 1i * imagPart;
end