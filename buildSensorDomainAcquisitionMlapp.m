function buildSensorDomainAcquisitionMlapp()
rootDir = 'D:/codex';
sourceFile = fullfile(rootDir, 'SensorDomainAcquisitionApp.m');
outputFile = fullfile(rootDir, 'SensorDomainAcquisitionApp_designer.mlapp');

if ~isfile(sourceFile)
    error('Source file not found: %s', sourceFile);
end

codeText = fileread(sourceFile);
if isfile(outputFile)
    delete(outputFile);
end
app = SensorDomainAcquisitionApp();
cleanupApp = onCleanup(@() deleteAppSafely(app));
app.UIFigure.Visible = 'off';

serializer = appdesigner.internal.serialization.MLAPPSerializer(outputFile, app.UIFigure);
serializer.OverwriteTargetFile = true;
serializer.MatlabCodeText = codeText;
serializer.ClassName = 'SensorDomainAcquisitionApp';
serializer.Callbacks = [
    makeCallback(codeText, 'BrowseBackgroundButtonPushed')
    makeCallback(codeText, 'BrowseOutputButtonPushed')
    makeCallback(codeText, 'StartButtonPushed')
    makeCallback(codeText, 'StopButtonPushed')
    makeCallback(codeText, 'UIFigureCloseRequest')
];
serializer.StartupCallback = makeCallback(codeText, 'startupFcn');
serializer.EditableSectionCode = {};

metadata = appdesigner.internal.model.MetadataModel();
metadata.Name = 'SensorDomainAcquisitionApp';
metadata.Author = 'Codex';
metadata.Version = '1.0';
metadata.Summary = 'Sensor domain acquisition app';
metadata.Description = 'Sensor domain acquisition app for VNA, TMC stages, and NI DAQ.';
metadata.ScreenshotMode = 'manual';
serializer.Metadata = metadata;
try
    serializer.save();
catch ME
    disp(getReport(ME, 'extended'));
    rethrow(ME);
end
clear cleanupApp
end

function callbackStruct = makeCallback(codeText, functionName)
lines = regexp(codeText, '\r\n|\n|\r', 'split');
startIdx = find(contains(lines, ['function ' functionName '(']), 1, 'first');
if isempty(startIdx)
    error('Callback not found: %s', functionName);
end

endIdx = startIdx + 1;
depth = 1;
while endIdx <= numel(lines)
    current = strtrim(lines{endIdx});
    if startsWith(current, 'function ')
        depth = depth + 1;
    elseif strcmp(current, 'end')
        depth = depth - 1;
        if depth == 0
            break;
        end
    end
    endIdx = endIdx + 1;
end

bodyLines = lines(startIdx + 1:endIdx - 1);
callbackStruct = struct('Name', functionName, 'Code', {bodyLines(:)});
end

function deleteAppSafely(app)
if isempty(app)
    return;
end
try
    delete(app);
catch
end
end
