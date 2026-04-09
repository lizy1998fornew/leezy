% Standalone App Designer class extracted from LSS_Upper.mlapp.
% Run in MATLAB with:
%   app = LSS_UpperStandalone;
classdef LSS_UpperStandalone < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        DataIntervalEditField     matlab.ui.control.NumericEditField
        IntervalLabel             matlab.ui.control.Label
        RMSpeedx05rpsLabel        matlab.ui.control.Label
        HelicalEditFieldLabel     matlab.ui.control.Label
        HelicalEditField          matlab.ui.control.NumericEditField
        SwingAngleEditFieldLabel   matlab.ui.control.Label
        SwingAngleEditField        matlab.ui.control.NumericEditField
        TumblingEditFieldLabel    matlab.ui.control.Label
        TumblingEditField         matlab.ui.control.NumericEditField
        KdFinishEditField         matlab.ui.control.NumericEditField
        KdFinishEditFieldLabel    matlab.ui.control.Label
        KiFinishEditField         matlab.ui.control.NumericEditField
        KiFinishEditFieldLabel    matlab.ui.control.Label
        KpFinishEditField         matlab.ui.control.NumericEditField
        KpFinishEditFieldLabel    matlab.ui.control.Label
        FindingHomeLabel          matlab.ui.control.Label
        ChiralityDropDown         matlab.ui.control.DropDown
        PFDDistMEditField         matlab.ui.control.NumericEditField
        PFDDistMEditFieldLabel    matlab.ui.control.Label
        MoverZPosEditField        matlab.ui.control.NumericEditField
        MoverYPosEditField        matlab.ui.control.NumericEditField
        MoverXPosEditField        matlab.ui.control.NumericEditField
        MovermmLabel              matlab.ui.control.Label
        ZLabel                    matlab.ui.control.Label
        MoverZDataEditField       matlab.ui.control.NumericEditField
        NavModeDropDown           matlab.ui.control.DropDown
        NavModeLabel              matlab.ui.control.Label
        CoopModeDropDown          matlab.ui.control.DropDown
        CoopModeLabel             matlab.ui.control.Label
        ZDistEditField            matlab.ui.control.NumericEditField
        AOIumLabel_2              matlab.ui.control.Label
        ManualMoveLabel           matlab.ui.control.Label
        GoHomeButton              matlab.ui.control.Button
        VzmmsLabel_5              matlab.ui.control.Label
        ManualYPosEditField       matlab.ui.control.NumericEditField
        VzmmsLabel_4              matlab.ui.control.Label
        ManualXPosEditField       matlab.ui.control.NumericEditField
        VzmmsLabel_3              matlab.ui.control.Label
        ManualZPosEditField       matlab.ui.control.NumericEditField
        FindHomeButton            matlab.ui.control.Button
        MoveButton                matlab.ui.control.Button
        ManualRotateLabel         matlab.ui.control.Label
        AzEditField               matlab.ui.control.NumericEditField
        AzEditFieldLabel          matlab.ui.control.Label
        AlignToInputButton        matlab.ui.control.Button
        PoEditField               matlab.ui.control.NumericEditField
        PoEditFieldLabel          matlab.ui.control.Label
        MoverCmdLabel             matlab.ui.control.Label
        RotorCmdLabel             matlab.ui.control.Label
        RobotmmLabel              matlab.ui.control.Label
        YLabel_2                  matlab.ui.control.Label
        XLabel_5                  matlab.ui.control.Label
        MoverYDataEditField       matlab.ui.control.NumericEditField
        MoverXDataEditField       matlab.ui.control.NumericEditField
        PFDCountEditField         matlab.ui.control.NumericEditField
        PFDCountEditFieldLabel    matlab.ui.control.Label
        PFDDistREditField         matlab.ui.control.NumericEditField
        PFDDistREditFieldLabel    matlab.ui.control.Label
        DestYEditField            matlab.ui.control.NumericEditField
        DestYmmLabel              matlab.ui.control.Label
        DestXEditField            matlab.ui.control.NumericEditField
        DestXmmLabel              matlab.ui.control.Label
        ErrorAt90EditField        matlab.ui.control.NumericEditField
        AvgErrorumLabel_2         matlab.ui.control.Label
        MeanErrorEditField        matlab.ui.control.NumericEditField
        AvgErrorumLabel           matlab.ui.control.Label
        RunTimeEditField          matlab.ui.control.NumericEditField
        ComplTimesEditFieldLabel  matlab.ui.control.Label
        AOIDiameterEditField      matlab.ui.control.NumericEditField
        AOIumLabel                matlab.ui.control.Label
        DataLoggingLamp           matlab.ui.control.Lamp
        EnableLoggingButton       matlab.ui.control.Button
        DisableLoggingButton      matlab.ui.control.Button
        SystemStatusLabel         matlab.ui.control.Label
        SystemControlLabel        matlab.ui.control.Label
        SystemConfigLabel         matlab.ui.control.Label
        PSYEditField_10           matlab.ui.control.NumericEditField
        PSXEditField_10           matlab.ui.control.NumericEditField
        PSYEditField_9            matlab.ui.control.NumericEditField
        PSXEditField_9            matlab.ui.control.NumericEditField
        PSYEditField_8            matlab.ui.control.NumericEditField
        PSXEditField_8            matlab.ui.control.NumericEditField
        PSYEditField_7            matlab.ui.control.NumericEditField
        PSXEditField_7            matlab.ui.control.NumericEditField
        PSYEditField_6            matlab.ui.control.NumericEditField
        PSXEditField_6            matlab.ui.control.NumericEditField
        PSYEditField_5            matlab.ui.control.NumericEditField
        PSXEditField_5            matlab.ui.control.NumericEditField
        PSYEditField_4            matlab.ui.control.NumericEditField
        PSXEditField_4            matlab.ui.control.NumericEditField
        PSYEditField_3            matlab.ui.control.NumericEditField
        PSXEditField_3            matlab.ui.control.NumericEditField
        PSYEditField_2            matlab.ui.control.NumericEditField
        PSXEditField_2            matlab.ui.control.NumericEditField
        PSYEditField              matlab.ui.control.NumericEditField
        PSXEditField              matlab.ui.control.NumericEditField
        Label_10                  matlab.ui.control.Label
        Label_9                   matlab.ui.control.Label
        Label_8                   matlab.ui.control.Label
        Label_7                   matlab.ui.control.Label
        Label_6                   matlab.ui.control.Label
        Label_5                   matlab.ui.control.Label
        Label_4                   matlab.ui.control.Label
        Label_3                   matlab.ui.control.Label
        PSNumberLabel             matlab.ui.control.Label
        PresetWaypointsLabel      matlab.ui.control.Label
        PS10Button                matlab.ui.control.Button
        PS9Button                 matlab.ui.control.Button
        PS8Button                 matlab.ui.control.Button
        PS7Button                 matlab.ui.control.Button
        PS6Button                 matlab.ui.control.Button
        PS5Button                 matlab.ui.control.Button
        PS4Button                 matlab.ui.control.Button
        PS3Button                 matlab.ui.control.Button
        PS2Button                 matlab.ui.control.Button
        PS1Button                 matlab.ui.control.Button
        YmmLabel                  matlab.ui.control.Label
        XmmLabel                  matlab.ui.control.Label
        Label_2                   matlab.ui.control.Label
        Label                     matlab.ui.control.Label
        KdPathingEditField        matlab.ui.control.NumericEditField
        KdPathingEditFieldLabel   matlab.ui.control.Label
        KpPathingEditField        matlab.ui.control.NumericEditField
        KpPathingEditFieldLabel   matlab.ui.control.Label
        KiPathingEditField        matlab.ui.control.NumericEditField
        KiPathingEditFieldLabel   matlab.ui.control.Label
        YPosmmEditField           matlab.ui.control.NumericEditField
        PosmmEditField            matlab.ui.control.NumericEditField
        CSplineTEditField         matlab.ui.control.NumericEditField
        SplineTensionLabel        matlab.ui.control.Label
        RotorYDataEditField       matlab.ui.control.NumericEditField
        RotorXDataEditField       matlab.ui.control.NumericEditField
        TSUDistEditField          matlab.ui.control.NumericEditField
        TSUDistEditFieldLabel     matlab.ui.control.Label
        SegIntvEditField          matlab.ui.control.NumericEditField
        WPRDistLabel              matlab.ui.control.Label
        COMEnableLamp             matlab.ui.control.Lamp
        COMSelectDropDown         matlab.ui.control.DropDown
        COMShutdownButton         matlab.ui.control.Button
        COMActivateButton         matlab.ui.control.Button
        PauseButton               matlab.ui.control.Button
        ExecuteButton             matlab.ui.control.Button
        FinishPlanningButton      matlab.ui.control.Button
        StartPlanningButton       matlab.ui.control.Button
        MainOverlayUIAxes         matlab.ui.control.UIAxes
        MainImageUIAxes           matlab.ui.control.UIAxes
        Log3UIAxes                matlab.ui.control.UIAxes
        Log2UIAxes                matlab.ui.control.UIAxes
        Log1UIAxes                matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        %% UI & basic logical elements
        SerialObject % COM port
        CameraActive
        COMActive % 1=COM port active        
        PlanningActive % 1=Path planning active
        PathAvailable % 1=A path is ready to be followed
        PathFinished % 1=Finished
        AvgLoopTime
        LastLoopTime
        CVIsFirstRun

        %% TMC controller
        TMC1
        TMCHandle
        TMCWorking
        TMCxCorrection
        TMCyCorrection
        TMCzCorrection
        TMCxLimit
        TMCyLimit
        TMCzLimit
        TMCFoundCenter
                
        %% CV related
        CameraFeed % Camera        
        CVCapturedPos % Live position of microbot by CV

        RadiusMask1
        RadiusMask2
        RadiusMask3

        SE
        GlobalFrameCounter
        
        %% Path tracking & PID
        
        PIDParam_Pathing % Kp,Ki,Kd
        PIDParam_FinishDealer
        PIDIntegral % Integral memory of PID
        PIDIntegralLimit % Limiter for integral part of PID
        PIDDerivative % Derivative memory of PID
        VxOutput
        VyOutput
                
        AxialOutputLimit
        TrackingStep % Indicates which waypoint the program is currently tracking
        RotorPathFinishDist
        MoverPathFinishDist
        PathFinishCount      
        
        PredictObj
        PosAfterLastMove
        
        WaypointX % Space for waypoints of path planner
        WaypointY % =XData,YData
        GeneratedPathX % Space for path generated by spline program
        GeneratedPathY % =set1x,set1y
        RepickPointX % Space for waypoints re-picked from spline
        RepickPointY % =set2x,set2y

        UsingPresetInputs
        PresetInputX
        PresetInputY
        IsFinishingPath
        FinishDealerCounter
        LastTargetDistance
        SlowProgressCounter
        SwingState
        ActiveSwingAngle
        ActiveSwingSpeed
        RadiusOfOperation % Camera observed radius of operation in digits
        SplineConfiguration % Tension,N        
        WaypointRepickDist % distance between repicked points


        StopCmd
        %BLEStarterCmd

        %% Data collection
        SaveDataEnabled
        PickDataCounter % Counts whether data logging should be done in current cycle
        PickDataNumber % Serializes data logged in storage space
        DataGrabInterval % No. of cycles between each auto logging
        RunTimer
        LoggedPath
        LoggedCVPos
        LoggedPosAtWP
        LoggedError
        LoggedDeviation
        LoggedClickPos
        
        %% Plots
        ResizedImage
        PathPlot
        WaypointPlot
        BoxPlot
        TargetPlot
        MoverPlot
    end
    
    methods (Access = private)
    
        function MainSystemCycle(app)
            %% Image acquisition 0.015~0.02s

            tic
            CaptureFrame = peekdata(app.CameraFeed,1);
            if isempty(CaptureFrame)
                return
            end
            app.GlobalFrameCounter = app.GlobalFrameCounter+1;
                        
            if mod(app.GlobalFrameCounter, 3) == 0
                app.GlobalFrameCounter = 0;
                flushdata(app.CameraFeed);
            end
            
%           Since crop and resize is done on streaming side, imcrop is no longer needed
%             CFResize = imcrop(CaptureFrame,[240 0 800 800]);
%             app.ResizedImage = imshow(CFResize,'Parent',app.MainImageUIAxes);
            CFResize = CaptureFrame;
%             CFResize = wiener2(CFResize,[3 3]);
            app.ResizedImage = imshow(CFResize,'Parent',app.MainImageUIAxes);

            %% Pre-process 0.005-0.01s

            CFResize = imresize(CFResize,[256 256]);
            CFPreProcess = wiener2(CFResize,[3 3]);

            % Thresholding

            CFPreProcess = imbinarize(CFPreProcess,0.65);
            CFPreProcess = imcomplement(CFPreProcess);
            CFPreProcess = imopen(CFPreProcess,app.SE);
            CFPreProcess = imclearborder(CFPreProcess,8);
%                 app.ResizedImage = imshow(CFPreProcess,'Parent',app.MainImageUIAxes);

            %% Image marking <0.002s
            
            [CFMark,LabelCount] = bwlabel(CFPreProcess,8);
            CFStats = regionprops(CFMark,'Area','BoundingBox','Centroid','PixelIdxList');

            % CV picks marked object with darkest color
            if (LabelCount ~= 0) % If detected objects, do CV

                % Search and calculate average grayness of each object
                ObjGrayness = [];
                ObjPixels = []; 
                for i=1:LabelCount                     
                    for j=1:length(CFStats(i).PixelIdxList)
                        
                        PixelIndex = CFStats(i).PixelIdxList(j);
                        PixelVal = CFResize(PixelIndex);
                        ObjPixels(j) = PixelVal;
                        
                    end
                    ObjGrayness(i) = mean(ObjPixels,"all");
                end
                [~,TgtID] = min(ObjGrayness);

                % Validate if object is within set distance of last
                % known location to prevent teleporting glitch
                if (app.CVIsFirstRun == 1)
                    PosValid = 1;
                else
                    MinusOnePos = app.PredictObj.Centroid;
                    CurrentPos = CFStats(TgtID).Centroid;
                    DeltaPos = norm(MinusOnePos-CurrentPos);

                    if (DeltaPos <= 50) % If no teleport, object valid
                        PosValid = 1;
                    else % If teleported, object invalid
                        PosValid = 0;
                    end
                end

                % Validate if object is microrobot by comparing size                    
                TgtSize = CFStats(TgtID).Area; 
                if (TgtSize >= 4)
                    ShapeValid = 1;                        
                else
                    ShapeValid = 0;                        
                end

                % If all conditions are met, object is microrobot
                if (PosValid == 1 && ShapeValid == 1)
                    CVValid = 1;           
                    CVObj = CFStats(TgtID);
                    app.PredictObj = CFStats(TgtID);

                % If object is not microrobot, use previous position
                % and expected movement to predict current position
                else
                    CVValid = 0;
                    DeltaX = app.RotorXDataEditField.Value*7*app.LastLoopTime/2047;
                    DeltaY = app.RotorYDataEditField.Value*7*app.LastLoopTime/2047;
                    PredX = app.PredictObj.Centroid(1)+DeltaX;
                    PredY = app.PredictObj.Centroid(2)+DeltaY;                        
                    app.PredictObj.Centroid = [PredX PredY];
                    CVObj = app.PredictObj;
                end

            else % If no object is detected, return
                return  
            end
            
            CenterBox = CVObj.Centroid;
            app.CVCapturedPos = CenterBox;
            app.WaypointX = CenterBox(1);
            app.WaypointY = CenterBox(2);
            CVPosX = CenterBox(1)*app.AOIDiameterEditField.Value/255;
            CVPosY = CenterBox(2)*app.AOIDiameterEditField.Value/255;
            app.PosmmEditField.Value = CVPosX;
            app.YPosmmEditField.Value = CVPosY;
                        

            %% Grab data at preset interval
            if (mod(app.PickDataCounter, app.DataGrabInterval) == 0)
                if (app.SaveDataEnabled == 1)
                    if(app.PathFinished == 0)
%                         CVPosX = CenterBox(1)*app.AOIDiameterEditField.Value/255;
%                         CVPosY = CenterBox(2)*app.AOIDiameterEditField.Value/255;
                        app.LoggedCVPos(app.PickDataNumber,1) = CVPosX;
                        app.LoggedCVPos(app.PickDataNumber,2) = CVPosY;

                        plot(app.Log1UIAxes,CVPosX,CVPosY,'Marker','.','Color','r');
                        plot(app.Log2UIAxes,CVPosX,CVPosY,'Marker','.','Color','r');

                        Dist2Compare = [];

                        for FinderIndex = 1:length(app.GeneratedPathX)                            
                            CVPos = [CenterBox(1) CenterBox(2)];
                            Point2Compare = [app.GeneratedPathX(FinderIndex) app.GeneratedPathY(FinderIndex)];
                            Dist2Compare(FinderIndex) = abs(norm(CVPos-Point2Compare));
                        end
                        Dist2Log = min(Dist2Compare)*app.AOIDiameterEditField.Value/255;
                        app.LoggedDeviation(app.PickDataNumber,1) = app.PickDataNumber;
                        app.LoggedDeviation(app.PickDataNumber,2) = Dist2Log;
                        plot(app.Log3UIAxes,app.PickDataNumber,Dist2Log,'Marker','.','Color','r');                        


                        app.PickDataNumber = app.PickDataNumber+1;
                        app.PickDataCounter = 0;                        
                    end
                end
            end
            
            app.PickDataCounter = app.PickDataCounter+1;
            
            hold(app.MainOverlayUIAxes,'on');
                        
            %% Get Mover positions            
                app.MoverXPosEditField.Value = double(app.TMC1.tmc_get_position(app.TMCHandle, uint8(0x00)));
                app.MoverYPosEditField.Value = double(app.TMC1.tmc_get_position(app.TMCHandle, uint8(0x01)));
                app.MoverZPosEditField.Value = 0;
                
                delete(app.MoverPlot);
                
                DrawX = (1*app.MoverXPosEditField.Value+0.5*app.AOIDiameterEditField.Value)*255/app.AOIDiameterEditField.Value;
                DrawY = ( -1*app.MoverYPosEditField.Value+0.5*app.AOIDiameterEditField.Value)*255/app.AOIDiameterEditField.Value;

                DrawSize = 10;
                app.MoverPlot = plot(app.MainOverlayUIAxes, DrawX, DrawY,'Color','m','LineStyle','none','Marker','o','MarkerSize',DrawSize);

            %% Draw UI elements 0.015s
            
            pause(0.001); % This gives UI time to update
                        
            % CV bounding box
            delete(app.BoxPlot);
            
            if (CVValid == 1)
                app.BoxPlot = rectangle(app.MainOverlayUIAxes,'position',CVObj.BoundingBox,'edgecolor','g');
            else
                app.BoxPlot = rectangle(app.MainOverlayUIAxes,'position',CVObj.BoundingBox,'edgecolor','r');
            end
                                                           
            app.CVIsFirstRun = 0;
            LoopTime = toc
            app.LastLoopTime = LoopTime;

%             hold(app.MainOverlayUIAxes,'off');

            % Begin path following dealer
            if (app.PathFinished==0)
                TargetSwitchDist = app.TSUDistEditField.Value;
             
                %% Variable controller params based on status
                kPIDRotor = app.PIDParam_Pathing;
                
                if(app.IsFinishingPath == 1)
                    % Force precise PID params
                    kPIDRotor = app.PIDParam_FinishDealer;
                end
            
                %% Path tracking
                % Determines which waypoint is to be tracked
                % Switches to next tracking target when:
                % a)Object is close enough to current target
                % b)Object is closer to next target than current
                
                CurrentTarget = [app.RepickPointX(app.TrackingStep),app.RepickPointY(app.TrackingStep)];                    
                CTDist = norm(CurrentTarget-app.CVCapturedPos);

                %% Step to next target dealer
                % This only activates when current target is not end of path

                if (app.TrackingStep < length(app.RepickPointX))
                    % Prevents attempting to switch beyond available waypoints
                    app.IsFinishingPath = 0;
                    NextTarget = [app.RepickPointX(app.TrackingStep+1),app.RepickPointY(app.TrackingStep+1)];
                    NTDist = norm(NextTarget-app.CVCapturedPos);
                    
                    if (CTDist<=TargetSwitchDist || NTDist<CTDist)                            
                        % Grab data at each waypoint switch
                        if (app.SaveDataEnabled == 1)
                            if (mod(app.TrackingStep,2) == 0)
                            % CVPos at switching
                            XAtWP = CenterBox(1)*app.AOIDiameterEditField.Value/255;
                            YAtWP = CenterBox(2)*app.AOIDiameterEditField.Value/255;                        
                            app.LoggedPosAtWP(app.TrackingStep,1) = XAtWP;
                            app.LoggedPosAtWP(app.TrackingStep,2) = YAtWP;
                            
                            % Waypoints
                            WPX = CurrentTarget(1)*app.AOIDiameterEditField.Value/255;
                            WPY = CurrentTarget(2)*app.AOIDiameterEditField.Value/255;
                            app.LoggedPath(app.TrackingStep,1) = WPX;
                            app.LoggedPath(app.TrackingStep,2) = WPY;
                            plot(app.Log2UIAxes,WPX,WPY,'Marker','o','Color','b','MarkerSize',3);  
                            end
                        end                            
                        app.TrackingStep = app.TrackingStep+1;
                    end

                else
                    app.IsFinishingPath = 1;
                end
                
                % Draw current target
                delete(app.TargetPlot);         
                app.TargetPlot = plot(app.MainOverlayUIAxes,CurrentTarget(1),CurrentTarget(2),'bo','MarkerSize',5);
                 
                % Controller related variables
                ObjectError = [app.RepickPointX(app.TrackingStep),app.RepickPointY(app.TrackingStep)]-app.CVCapturedPos;

                %% Mover Follows Robot   
                if(app.CoopModeDropDown.Value == 1 && app.IsFinishingPath == 0)
                    % Mover Follows Rotor - Mover always place EMC-Magnet
                    % system directly below microrobot
                    [MoverXInAOI, MoverYInAOI] = TMC_TransformToCV(app, app.MoverXPosEditField.Value, app.MoverYPosEditField.Value);
                    DistBetween = norm([CVPosX CVPosY]-[MoverXInAOI MoverYInAOI]); 
                    
                    if(DistBetween >= 5)
                        % Move to microrobot
                        TMC_Goto(app, CenterBox(1), CenterBox(2), app.ZDistEditField.Value);
                    end
                    
                elseif(app.CoopModeDropDown.Value == 1 && app.IsFinishingPath == 1)
                    TMC_Goto(app,app.RepickPointX(app.TrackingStep), ...
                                 app.RepickPointY(app.TrackingStep), ...
                                 app.ZDistEditField.Value)
                end                
                
                %% Mover Follows Waypoints
                if(ismember(app.CoopModeDropDown.Value,[2 4]))
                    % Coop Mode 2,4
                    % Mover moves to segmented waypoint during waypoint
                    % switch
                    TMC_Goto(app,app.RepickPointX(app.TrackingStep), ...
                                 app.RepickPointY(app.TrackingStep), ...
                                 app.ZDistEditField.Value);
                end
                       
                %% PID controller
                % Rotor PID is disabled in Mover Only and NAV Steering mode
                UsingPID = 0;
                if(ismember(app.CoopModeDropDown.Value,[1 2 3]) && ...
                   ismember(app.NavModeDropDown.Value ,[1 2 3 4 6]))
                    UsingPID = 1;

                    % Rotor PID
                    app.PIDIntegral = kPIDRotor(2)*ObjectError;
                    POUT = kPIDRotor(1)*ObjectError;
                    IOUT = max(-app.PIDIntegralLimit, min(app.PIDIntegralLimit, app.PIDIntegral));
                    DOUT = kPIDRotor(3)*(ObjectError-app.PIDDerivative);
                    PIDOUT = POUT+IOUT+DOUT;
                    app.PIDDerivative = ObjectError;
                    if(app.PIDIntegral >= app.PIDIntegralLimit)
                        app.PIDIntegral = 0;
                    end
                    
                    % Output clamping
                    if(max(abs(PIDOUT))>app.AxialOutputLimit)
                        PIDOUT = PIDOUT*(app.AxialOutputLimit/max(abs(PIDOUT)));
                    end
                    app.VxOutput = PIDOUT(1);
                    app.VyOutput = PIDOUT(2);
    
%                     % Slow down during finish
%                     if(app.IsFinishingPath == 1)                
%                         app.VxOutput = app.VxOutput*0.75;
%                         app.VyOutput = app.VyOutput*0.75;
%                     end
               
                    % Chirality correction for spiral effectors
                    if(ismember(app.NavModeDropDown.Value,[2 3 4]) && ...
                                app.ChiralityDropDown.Value == 1)
                        
                        app.VxOutput = 1*app.VxOutput;
                        app.VyOutput = 1*app.VyOutput;

                    elseif(ismember(app.NavModeDropDown.Value,[2 3 4]) && ...
                                    app.ChiralityDropDown.Value == 2)
                        
                        app.VxOutput = -1*app.VxOutput;
                        app.VyOutput = -1*app.VyOutput;

                    end

%                     %% Magnetic pull compensation                    
%                     X_Ctr = app.CVCapturedPos(1)-127;
%                     Y_Ctr = app.CVCapturedPos(2)-127;
%                     app.VxOutput = app.VxOutput+1*X_Ctr;
%                     app.VyOutput = app.VyOutput+1*Y_Ctr;
    
                    app.RotorXDataEditField.Value = app.VxOutput;
                    app.RotorYDataEditField.Value = app.VyOutput;
    
                    %% Rotor COM sender
                    VxData = round(app.VxOutput+2047);
                    VyData = round(app.VyOutput+2047);
                    if(VxData<0)
                        VxData = 0;
                    end
                    if(VyData<0)
                        VyData = 0;
                    end
                    
                    % Add NAVMODE and SPEEDMODE to data
                    NavModeCmd = [0x0000 0x1000 0x2000 0x3000 0x0000 0x4000];
                    Cmd1 = NavModeCmd(app.NavModeDropDown.Value);

                    SwingAngle = max(0, min(90, app.SwingAngleEditField.Value));
                    if(app.NavModeDropDown.Value == 6)
                        [SwingAngle, SelectSpeed] = GetAdaptiveSwingParams(app, CTDist);
                    elseif(ismember(app.NavModeDropDown.Value,[2 3 4]))
                        SelectSpeed = app.HelicalEditField.Value;
                    else
                        SelectSpeed = app.TumblingEditField.Value;
                    end

                    if(app.IsFinishingPath == 1 && app.NavModeDropDown.Value ~= 6) % Slow down during finish
                        SelectSpeed = SelectSpeed-1;
                    end
                    SelectSpeed = max(1, min(15, round(SelectSpeed)));
                    Cmd2 = bitshift(SelectSpeed,12);
                        
                    VxD1 = bitshift(bitand(VxData,0x0F00)+Cmd1,-8);
                    VxD2 = bitand(VxData,0x00FF);
                    VyD1 = bitshift(bitand(VyData,0x0F00)+Cmd2,-8);
                    VyD2 = bitand(VyData,0x00FF);
    
                    TransmitData = [VxD1,VxD2,VyD1,VyD2];
                    if(app.NavModeDropDown.Value == 6)
                        SendSwingConfig(app, SwingAngle);
                    end
                    write(app.SerialObject,TransmitData,"uint8");
                 
    
                    %% Path finish dealer
                    % Stops moving when:
                    % Tracking final waypoint AND position is within set margin
    
                    if(app.TrackingStep == length(app.RepickPointX) && CTDist <= app.RotorPathFinishDist)
                        app.FinishDealerCounter = app.FinishDealerCounter+1;
                    elseif(app.FinishDealerCounter ~= 0)
                        app.FinishDealerCounter = 0;
                    end
                
                elseif (ismember(app.CoopModeDropDown.Value,[1 2 3]) && ...
                    app.NavModeDropDown.Value == 5)                    
                    [AlignAzim,~] = cart2pol(ObjectError(1),ObjectError(2));
                    AzimData = round((rad2deg(AlignAzim)/360)*4095);
                    PolarData = 0x07FF;
                    
                    PolarD1 = bitshift(bitand(PolarData,0xFF00),-8);
                    PolarD2 = bitand(PolarData,0x00FF);
                    AzimD1 = bitshift(bitand(AzimData,0xFF00),-8);
                    AzimD2 = bitand(AzimData,0x00FF);
        
                    AlignData = [PolarD1,PolarD2,AzimD1,AzimD2];
                    write(app.SerialObject,app.StopCmd,"uint8");
                    pause(0.005);
                    write(app.SerialObject,AlignData,"uint8");
                    
                end

                
                % Surrogate path finish dealer when rotor control is disabled
                if(UsingPID == 0 && CTDist <= app.MoverPathFinishDist)

                    if(app.TrackingStep == length(app.RepickPointX))
                        app.FinishDealerCounter = app.PathFinishCount;
                    end
                end

                if(app.FinishDealerCounter >= app.PathFinishCount)

                    % Stop at target                        
                    write(app.SerialObject,app.StopCmd,"uint8");
                    pause(0.01);
                    write(app.SerialObject,app.StopCmd,"uint8");
                        
                    % Finalize UI data plots by connecting points to a line
                    % Disabled due to negative impact on readability
                    plot(app.Log1UIAxes,app.LoggedCVPos(:,1),app.LoggedCVPos(:,2),'LineStyle','-','Marker','none','Color','r');
%                         plot(app.Log2UIAxes,app.LoggedCVPos(:,1),app.LoggedCVPos(:,2),'LineStyle','-','Marker','none','Color','r');
%                         plot(app.Log3UIAxes,app.LoggedDeviation(:,1),app.LoggedDeviation(:,2),'LineStyle','-','Marker','none','Color','r');

                    % Display logged data
                    app.RunTimeEditField.Value = toc(app.RunTimer);
                    app.MeanErrorEditField.Value = mean(app.LoggedDeviation(:,2));
                    app.ErrorAt90EditField.Value = prctile(app.LoggedDeviation(:,2),90);
                    app.DestXEditField.Value = app.GeneratedPathX(end)*app.AOIDiameterEditField.Value/255;
                    app.DestYEditField.Value = app.GeneratedPathY(end)*app.AOIDiameterEditField.Value/255;
                    
                    % Other result generation
                    

                    % Save logged data to files
                    if (app.SaveDataEnabled == 1)
                        writematrix(app.LoggedClickPos,['LoggedClickPos_',datestr(datetime('now'),'yyyy-mm-dd-HH-MM'),'.xlsx']);
                        writematrix(app.LoggedPath,['LoggedPath_',datestr(datetime('now'),'yyyy-mm-dd-HH-MM'),'.xlsx']);
                        writematrix(app.LoggedCVPos,['LoggedCVPos_',datestr(datetime('now'),'yyyy-mm-dd-HH-MM'),'.xlsx']);
                        writematrix(app.LoggedPosAtWP,['LoggedPAWP_',datestr(datetime('now'),'yyyy-mm-dd-HH-MM'),'.xlsx']);
%                         writematrix(app.LoggedError,['LoggedError_',datestr(datetime('now'),'yyyy-mm-dd-HH-MM'),'.xlsx']);
                        writematrix(app.LoggedDeviation,['LoggedDeviation_',datestr(datetime('now'),'yyyy-mm-dd-HH-MM'),'.xlsx']);
                    end
                    
%                     plot(app.Log3UIAxes,0,0,'Marker','+','Color','b');

                    hold(app.Log1UIAxes,"off");
                    hold(app.Log2UIAxes,"off");
                    hold(app.Log3UIAxes,"off");

                    app.PickDataNumber = 1;

                    app.TrackingStep = 1;
                    app.PathAvailable = 0;
                    app.PathFinished = 1;
                    PauseButtonPushed(app);
                end
            end 
        end
                
        function SerialConfig(app)
            if(app.COMActive == 1)
                delete(app.SerialObject);
                app.COMEnableLamp.Color = [0,1,0];
                try
                    app.SerialObject = serialport(app.COMSelectDropDown.Value, ...
                                              115200, ...
                                   "DataBits",8,...
                                   "StopBits",1, ...
                                     "Parity","none");
                    
                    %app.SerialObject.OutputBufferSize = 4096;
                    configureTerminator(app.SerialObject,"LF");
                    configureCallback(app.SerialObject,"terminator",@SerialCallback);
                catch 
                    errordlg('串口启动失败');
                    app.COMEnableLamp.Color = [1,0,0];
                    delete(app.SerialObject);
                    app.COMActive = 0;
                    app.COMShutdownButton.Visible = 'off';
                    app.COMActivateButton.Visible = 'on';
                end              
            elseif(app.COMActive == 0)
                delete(app.SerialObject);
                app.COMEnableLamp.Color = [1,0,0];
            end
            
            function SerialCallback(~,~)
                pause(0.1);
            end
        end
        
%         Legacy Goto Function        
%         function TMC_Goto(app,XPosTgt,YPosTgt,ZDistTgt)
%             % Moves TMC to set position
%             % Solves coordinate mismatch between CV and TMC
%             % TMC: Center of AOI as origin, left as X+, fwd as Y, in mm
%             % CV: left top of AOI as origin, right as X+, back as Y+, in px
% 
%             XPosTMC = -1*((XPosTgt-127.5)/255)*app.AOIDiameterEditField.Value;
%             YPosTMC =  1*((YPosTgt-127.5)/255)*app.AOIDiameterEditField.Value;
%             ZPosTMC = app.TMCzLimit-ZDistTgt;
% 
% %             XCurrTMC = double(app.TMC1.tmc_get_position(app.TMCHandle, uint8(0x00)));
% %             YCurrTMC = double(app.TMC1.tmc_get_position(app.TMCHandle, uint8(0x01)));
% %             ZCurrTMC = double(app.TMC1.tmc_get_position(app.TMCHandle, uint8(0x02)));
% 
% %             app.TMC1.tmc_line_interpolation_2d(app.TMCHandle, uint8(0x00), double(XPosTMC), ...
% %                                                               uint8(0x01), double(YPosTMC), ...
% %                                                               uint8(0x02), double(ZPosTMC));
% 
%             app.TMC1.tmc_absolute_move(app.TMCHandle, uint8(0x00), double(XPosTMC));
%             app.TMC1.tmc_absolute_move(app.TMCHandle, uint8(0x01), double(YPosTMC));
%             app.TMC1.tmc_absolute_move(app.TMCHandle, uint8(0x02), double(ZPosTMC));
% 
%             app.MoverXDataEditField.Value = XPosTMC;
%             app.MoverYDataEditField.Value = YPosTMC;
%             app.MoverZDataEditField.Value = ZPosTMC;
%         end

        function TMC_Goto(app,XPosTgt,YPosTgt,ZDistTgt)
            % Moves TMC in XY only. Z-axis commands are intentionally disabled.
            %#ok<INUSD>
            XPosTMC =  1*((XPosTgt-127.5)/255)*app.AOIDiameterEditField.Value;
            YPosTMC = -1*((YPosTgt-127.5)/255)*app.AOIDiameterEditField.Value;

            XCurrTMC = double(app.TMC1.tmc_get_position(app.TMCHandle, uint8(0x00)));
            YCurrTMC = double(app.TMC1.tmc_get_position(app.TMCHandle, uint8(0x01)));

            XDeltaTMC = XPosTMC - XCurrTMC;
            YDeltaTMC = YPosTMC - YCurrTMC;

            app.TMC1.tmc_line_interpolation_2d(app.TMCHandle, uint8(0x00), double(XDeltaTMC), ...
                                                              uint8(0x01), double(YDeltaTMC));

            app.MoverXDataEditField.Value = XPosTMC;
            app.MoverYDataEditField.Value = YPosTMC;
            app.MoverZDataEditField.Value = 0;
        end

        
        function [PosXDisp, PosYDisp] = TMC_TransformToCV(app, XPosRead, YPosRead)
            % Transforms TMC coordinate to system/CV coordinate
            PosXDisp = -255*(XPosRead/app.AOIDiameterEditField.Value)+127.5;
            PosYDisp = -255*(YPosRead/app.AOIDiameterEditField.Value)+127.5;

        end
        
        function [PixelX, PixelY] = Mil2Pixel(app, MilX, MilY)
            % Transform real life distance based coordinates to pixel based
            % CV & Pathing coordinates
            PixelX = (MilX/app.AOIDiameterEditField.Value)*255;
            PixelY = (MilY/app.AOIDiameterEditField.Value)*255;
        end
        function [SwingAngle, SwingSpeed] = GetAdaptiveSwingParams(app, TargetDist)
            BaseAngle = max(0, min(90, app.SwingAngleEditField.Value));
            BaseSpeed = max(1, min(15, round(app.TumblingEditField.Value)));
            ProgressThreshold = max(0.2, app.TSUDistEditField.Value * 0.08);
            ResetThreshold = max(5, app.TSUDistEditField.Value * 1.5);

            if(isempty(app.LastTargetDistance) || app.LastTargetDistance < 0 || TargetDist > app.LastTargetDistance + ResetThreshold)
                app.SlowProgressCounter = 0;
                Progress = inf;
            else
                Progress = app.LastTargetDistance - TargetDist;
                if(TargetDist > max(app.TSUDistEditField.Value * 1.5, 6) && Progress < ProgressThreshold)
                    app.SlowProgressCounter = app.SlowProgressCounter + 1;
                else
                    app.SlowProgressCounter = max(0, app.SlowProgressCounter - 1);
                end
            end

            if(app.IsFinishingPath == 1)
                SwingAngle = max(5, min(45, BaseAngle * 0.5));
                SwingSpeed = max(1, BaseSpeed - 1);
                app.SwingState = 'Finish';
            elseif(app.SlowProgressCounter >= 10)
                SwingAngle = min(90, BaseAngle + 20);
                SwingSpeed = min(15, BaseSpeed + 1);
                app.SwingState = 'Recovery';
            elseif(TargetDist >= max(app.TSUDistEditField.Value * 2.5, 12))
                SwingAngle = min(90, BaseAngle + 10);
                SwingSpeed = BaseSpeed;
                app.SwingState = 'Assist';
            else
                SwingAngle = BaseAngle;
                SwingSpeed = BaseSpeed;
                app.SwingState = 'Track';
            end

            if(~isfinite(Progress))
                Progress = 0;
            end
            app.LastTargetDistance = TargetDist;
            app.ActiveSwingAngle = SwingAngle;
            app.ActiveSwingSpeed = SwingSpeed;
            app.SystemStatusLabel.Text = sprintf('Swing %s | d=%.1f | p=%.2f | A=%.0f | S=%d', ...
                app.SwingState, TargetDist, Progress, SwingAngle, SwingSpeed);
        end


        function SendSwingConfig(app, SwingAngle)
            if(nargin < 2)
                SwingAngle = max(0, min(90, app.SwingAngleEditField.Value));
            end
            AngleData = round((SwingAngle/90)*4095) + 0xE000;
            ReservedData = 0xE7FF;

            AngleD1 = bitshift(bitand(AngleData,0xFF00),-8);
            AngleD2 = bitand(AngleData,0x00FF);
            ReserveD1 = bitshift(bitand(ReservedData,0xFF00),-8);
            ReserveD2 = bitand(ReservedData,0x00FF);

            SwingConfigData = [AngleD1,AngleD2,ReserveD1,ReserveD2];
            write(app.SerialObject,SwingConfigData,"uint8");
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %% COM port
            app.COMSelectDropDown.Items = serialportlist("all");
            app.COMActive = 0;

            %% Positioning Platform
            % Config params
            app.TMCxCorrection = -13.5;% Offsets xy center of AOI for TMC
            app.TMCyCorrection = -2.5;
            app.TMCzCorrection = 0;% Offsets z distance to WP
            app.TMCxLimit = 180;
            app.TMCyLimit = 180;
            app.TMCzLimit = 200; 

            % Import libraries
            app.TMCWorking = 0;
            env = pyenv;
            if(env.Status == "NotLoaded")
                pyenv('Version', 'D:\python\python.exe');
            end
            modulePath = 'C:\Users\zhaoj\Desktop\TMC-USB SDK-32&64bit\Demo\Python';
            py.sys.path().append(modulePath);
            de = py.importlib.import_module('devices_TMC_USB');
            app.TMC1 = de.TMC_USB();

            % Connect to controller
            enum_dev = app.TMC1.tmc_device_count();
            try
                app.TMCHandle = app.TMC1.tmc_open(int32(enum_dev - 1));
                app.TMCWorking = 1;
            catch
                error('TMC init fail');
            end

            % Init actuators
            app.TMC1.tmc_init(app.TMCHandle, uint8(0x00), 'TSA200-B(F)');% x
            app.TMC1.tmc_init(app.TMCHandle, uint8(0x01), 'TSA200-B(F)');% y
            % Enable
            app.TMC1.tmc_set_axis_enable(app.TMCHandle, uint8(0x00), true);
            app.TMC1.tmc_set_axis_enable(app.TMCHandle, uint8(0x01), true);        
            % Set unit
            % unit2->mm
            app.TMC1.tmc_set_unit(app.TMCHandle, uint8(0x00), int32(2));
            app.TMC1.tmc_set_unit(app.TMCHandle, uint8(0x01), int32(2));
            % Set speed            
            app.TMC1.tmc_set_init_speed(app.TMCHandle, uint8(0x00), double(5));
            app.TMC1.tmc_set_init_speed(app.TMCHandle, uint8(0x01), double(5));            
            app.TMC1.tmc_set_speed(app.TMCHandle, uint8(0x00), double(40));
            app.TMC1.tmc_set_speed(app.TMCHandle, uint8(0x01), double(40));
            app.TMC1.tmc_set_max_speed(app.TMCHandle, uint8(0x00), double(45));
            app.TMC1.tmc_set_max_speed(app.TMCHandle, uint8(0x01), double(45));
            app.TMC1.tmc_set_home_speed(app.TMCHandle, uint8(0x00), double(30));
            app.TMC1.tmc_set_home_speed(app.TMCHandle, uint8(0x01), double(30));
            % Set accel
            app.TMC1.tmc_set_acc_speed(app.TMCHandle, uint8(0x00), double(100));
            app.TMC1.tmc_set_acc_speed(app.TMCHandle, uint8(0x01), double(100));
            app.TMC1.tmc_set_dec_speed(app.TMCHandle, uint8(0x00), double(100));
            app.TMC1.tmc_set_dec_speed(app.TMCHandle, uint8(0x01), double(100));            
            % Stop
            app.TMC1.tmc_stop(app.TMCHandle, uint8(0x00));
            app.TMC1.tmc_stop(app.TMCHandle, uint8(0x01));
            % Find home
            FindHomeButtonPushed(app);
                              
            %% Image acquisition device
            app.GlobalFrameCounter = 0;
            try

                %% Search for OBS streaming service
                targetName = 'OBS'; 
                
                % Get info of all winvideo devices
                info = imaqhwinfo('winvideo');
                targetID = [];
                
                % Search for OBS service, extract ID
                for k = 1:length(info.DeviceInfo)
                    deviceName = info.DeviceInfo(k).DeviceName;
                    deviceID   = info.DeviceInfo(k).DeviceID;

                    if contains(deviceName, targetName) 
                        targetID = deviceID;
                        break;
                    end
                end

                %% Config for OBS streaming service
                app.CameraFeed = videoinput('winvideo',targetID,'I420_1000x1000');
                app.CameraFeed.ReturnedColorspace = 'grayscale';

                app.CameraFeed.FramesPerTrigger = 1;
                app.CameraFeed.TriggerRepeat = Inf;
                app.CameraFeed.FrameGrabInterval = 1;
                app.CameraFeed.FramesAcquiredFcnCount = 1;
                app.CameraFeed.FramesAcquiredFcn = @(~,~) MainSystemCycle(app);
                %% End config for OBS streaming service

                flushdata(app.CameraFeed);
                start(app.CameraFeed);
                app.CameraActive = 1;

            catch
                app.CameraActive = 0;
                errordlg("相机启动失败");
            end

            %% CV related settings
            app.RadiusOfOperation = 125;
            app.CVCapturedPos = [0 0]; 
            
            % Radius masks: divide image into 3 
            app.RadiusMask1 = zeros(256,256);
            for i=1:256
                for j=1:256
                    if(norm([i,j]-[127,127])<95)
                        app.RadiusMask1(i,j) = 1;
                    end
                end
            end

            app.RadiusMask2 = zeros(256,256);
            for i=1:256
                for j=1:256
                    if(norm([i,j]-[127,127])<140)
                        app.RadiusMask2(i,j) = 1;
                    end
                end
            end
            app.RadiusMask2 = app.RadiusMask2 - app.RadiusMask1;

            app.RadiusMask3 = ones(256,256);
            app.RadiusMask3 = app.RadiusMask3-app.RadiusMask2-app.RadiusMask1;
            
            app.SE=strel('square',1);
            
            %% Controller presets
            KpP = app.KpPathingEditField.Value;
            KiP = app.KiPathingEditField.Value;
            KdP = app.KdPathingEditField.Value;            
            app.PIDParam_Pathing = [KpP KiP KdP];

            KpF = app.KpFinishEditField.Value;
            KiF = app.KiFinishEditField.Value;
            KdF = app.KdFinishEditField.Value;
            app.PIDParam_FinishDealer = [KpF KiF KdF];

            app.PIDDerivative = 0;
            app.PIDIntegral = 0;
            app.PIDIntegralLimit = 100;
            app.AxialOutputLimit = 2047;
            app.SplineConfiguration = [app.CSplineTEditField.Value 100];
            app.WaypointRepickDist = app.SegIntvEditField.Value;
            app.TrackingStep = 1;
            app.StopCmd = [7,255,7,255];
            app.IsFinishingPath = 0;
            app.FinishDealerCounter = 0;
            app.LastTargetDistance = -1;
            app.SlowProgressCounter = 0;
            app.SwingState = 'Idle';
            app.ActiveSwingAngle = app.SwingAngleEditField.Value;
            app.ActiveSwingSpeed = app.TumblingEditField.Value;
            %app.BLEStarterCmd = [65,84,43,83,69,78,68,61,49,44,52,44,49,48,48,48];%"AT+SEND=1,4,1000"
                        
            %% UI elements
            disableDefaultInteractivity(app.MainImageUIAxes);
            disableDefaultInteractivity(app.MainOverlayUIAxes);
            
%             % Draw AOI indicator ring
%             DrawDiam = app.RadiusOfOperation*2;
%             DrawPos = 128-app.RadiusOfOperation;
% %             rectangle(app.MainOverlayUIAxes,'Position',[5,5,245,245],'Curvature',[1,1],'LineStyle',"--","EdgeColor",[0 0 1]);
%                         
%             rectangle(app.MainOverlayUIAxes,'Position',[DrawPos,DrawPos,DrawDiam,DrawDiam],'Curvature',[1,1],'LineStyle',"--","EdgeColor",[0 0 1]);
            
            %% Data logging elements
            app.SaveDataEnabled = 0;            
            app.PickDataNumber = 1;
            app.PickDataCounter = 0;
            app.LoggedPath = [0 0];
            app.LoggedCVPos = [0 0];
            app.LoggedPosAtWP = [0 0];
            app.LoggedDeviation = [0 0];

            %% Other elements
            app.AvgLoopTime = 50;% Average time per Main loop execution in ms
            app.LastLoopTime = 0;
            app.CVIsFirstRun = 1;


        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            
            if(app.CameraActive == 1)
                stop(app.CameraFeed);
                flushdata(app.CameraFeed);
                delete(app.CameraFeed);
            end

            if(app.TMCWorking == 1)
                app.TMC1.tmc_close(app.TMCHandle);            
            end

            delete(app)            
        end

        % Callback function
        function COMListRefreshButtonPushed(app, event)
            app.COMSelectDropDown.Items = serialportlist("all");
        end

        % Value changed function: COMSelectDropDown
        function COMSelectDropDownValueChanged(app, event)
            SerialConfig(app);
        end

        % Button pushed function: StartPlanningButton
        function StartPlanningButtonPushed(app, event)
            stop(app.CameraFeed);
            
            %% Clear UI overlay
            cla(app.MainOverlayUIAxes);
            hold(app.MainOverlayUIAxes,"on");
            app.WaypointX = [];
            app.WaypointY = [];

            % Draw AOI indicator ring
%             DrawDiam = app.RadiusOfOperation*2;
%             DrawPos = 128-app.RadiusOfOperation;
% %             rectangle(app.MainOverlayUIAxes,'Position',[5,5,245,245],'Curvature',[1,1],'LineStyle',"--","EdgeColor",[0 0 1]);            
%                         
%             rectangle(app.MainOverlayUIAxes,'Position',[DrawPos,DrawPos,DrawDiam,DrawDiam],'Curvature',[1,1],'LineStyle',"--","EdgeColor",[0 0 1]);
            

            %% Change app status
            app.StartPlanningButton.Visible = 'off';
            app.FinishPlanningButton.Visible = 'on';
            app.SplineConfiguration(1) = app.CSplineTEditField.Value;
            app.PlanningActive = 1;
            app.TrackingStep = 1;

            app.PS1Button.Enable = 'on';
            app.PS2Button.Enable = 'on';
            app.PS3Button.Enable = 'on';
            app.PS4Button.Enable = 'on';
            app.PS5Button.Enable = 'on';
            app.PS6Button.Enable = 'on';
            app.PS7Button.Enable = 'on';
            app.PS8Button.Enable = 'on';
            app.PS9Button.Enable = 'on';
            app.PS10Button.Enable = 'on';
            
            %% Display starting position
            plot(app.MainOverlayUIAxes,app.CVCapturedPos(1,1),app.CVCapturedPos(1,2),'rd',"MarkerSize",7);
            
            %% 1st waypoint is set as last seen position
            app.WaypointX(1) = app.CVCapturedPos(1);
            app.WaypointY(1) = app.CVCapturedPos(2);

        end

        % Button pushed function: FinishPlanningButton
        function FinishPlanningButtonPushed(app, event)
            start(app.CameraFeed);
            
            app.WaypointRepickDist = app.SegIntvEditField.Value;
            %% Pick waypoints from spline
            len = length(app.GeneratedPathX);
            Count1 = 1;
            Count2 = 1;
            app.RepickPointX = [];
            app.RepickPointY = [];            
            for i=1:len
                if (norm([app.GeneratedPathX(Count1),app.GeneratedPathY(Count1)]- ...
                        [app.GeneratedPathX(i),app.GeneratedPathY(i)]) >= app.WaypointRepickDist)                
                    app.RepickPointX(Count2) = app.GeneratedPathX(i);
                    app.RepickPointY(Count2) = app.GeneratedPathY(i);
                    Count1 = i;
                    Count2 = Count2+1;
                end
            end

            % Add destination to end of waypoint set 
            app.RepickPointX(Count2) = app.GeneratedPathX(end);
            app.RepickPointY(Count2) = app.GeneratedPathY(end);

            %% Record Path Data
            app.LoggedClickPos = [];
            app.LoggedClickPos(1,:) = app.WaypointX;
            app.LoggedClickPos(2,:) = app.WaypointY;
            
            %% Change app status
            app.PlanningActive = 0;
            len = length(app.RepickPointX);
            if (len>1)
                app.PathAvailable = 1;
            end            
            app.StartPlanningButton.Visible = 'on';
            app.FinishPlanningButton.Visible = 'off';

            app.PS1Button.Enable = 'off';
            app.PS2Button.Enable = 'off';
            app.PS3Button.Enable = 'off';
            app.PS4Button.Enable = 'off';
            app.PS5Button.Enable = 'off';
            app.PS6Button.Enable = 'off';
            app.PS7Button.Enable = 'off';
            app.PS8Button.Enable = 'off';
            app.PS9Button.Enable = 'off';
            app.PS10Button.Enable = 'off';         
            
        end

        % Button pushed function: ExecuteButton
        function ExecuteButtonPushed(app, event)
            if(app.COMActive==1 && app.PathAvailable==1)
                %% Load path tracking parameters
                app.RotorPathFinishDist = app.PFDDistREditField.Value;
                app.MoverPathFinishDist = app.PFDDistMEditField.Value;
                app.PathFinishCount = app.PFDCountEditField.Value;

                KpP = app.KpPathingEditField.Value;
                KiP = app.KiPathingEditField.Value;
                KdP = app.KdPathingEditField.Value;
                app.PIDParam_Pathing = [KpP KiP KdP];
                
                KpF = app.KpFinishEditField.Value;
                KiF = app.KiFinishEditField.Value;
                KdF = app.KdFinishEditField.Value;
                app.PIDParam_FinishDealer = [KpF KiF KdF];

                %% Other parameters
                app.DataGrabInterval = app.DataIntervalEditField.Value;

                %% Reset result displays
                cla(app.Log1UIAxes);
                cla(app.Log2UIAxes);
                cla(app.Log3UIAxes);
                
                app.Log1UIAxes.XLim = [0 app.AOIDiameterEditField.Value];
                app.Log1UIAxes.YLim = [0 app.AOIDiameterEditField.Value];

                app.Log2UIAxes.XLim = [0 app.AOIDiameterEditField.Value];
                app.Log2UIAxes.YLim = [0 app.AOIDiameterEditField.Value];

                app.LoggedPath = [0 0];
                app.LoggedCVPos = [0 0];
                app.LoggedPosAtWP = [0 0];
                app.LoggedError = [0 0];
                app.LoggedDeviation = [0 0];

                app.RunTimeEditField.Value = 0;
                app.MeanErrorEditField.Value = 0;
                app.ErrorAt90EditField.Value = 0;

                hold(app.Log1UIAxes,"on");
                hold(app.Log2UIAxes,"on");
                hold(app.Log3UIAxes,"on");

                %% Change app status
                app.IsFinishingPath = 0;
                app.PathFinished  = 0;
                app.PickDataCounter = 0;
                app.PickDataNumber = 1;
                app.FinishDealerCounter = 0;
                app.LastTargetDistance = -1;
                app.SlowProgressCounter = 0;
                app.SwingState = 'Track';
                app.ActiveSwingAngle = app.SwingAngleEditField.Value;
                app.ActiveSwingSpeed = app.TumblingEditField.Value;
                app.ExecuteButton.Visible = 'off';
                app.PauseButton.Visible = 'on';
                app.AlignToInputButton.Enable = 'off';
                app.RunTimer = tic;
            else
                errordlg('串口未启动');
            end
        end

        % Button pushed function: PauseButton
        function PauseButtonPushed(app, event)
            if(app.PathFinished == 0)
                app.PathFinished = 1;
            end                        
            
%             % Stop Mover
%             app.TMC1.tmc_stop(app.TMCHandle, uint8(0x00));
%             app.TMC1.tmc_stop(app.TMCHandle, uint8(0x01));
%
            %write(app.SerialObject,app.BLEStarterCmd,"uint8");
            write(app.SerialObject,app.StopCmd,"uint8");
            app.RotorXDataEditField.Value = 0;
            app.RotorYDataEditField.Value = 0;
            app.ExecuteButton.Visible = 'on';
            app.PauseButton.Visible = 'off';
            app.AlignToInputButton.Enable = 'on';
            app.SwingState = 'Idle';
            app.SystemStatusLabel.Text = 'Paused';
        end

        % Button pushed function: COMActivateButton
        function COMActivateButtonPushed(app, event)
            app.COMShutdownButton.Visible = 'on';
            app.COMActivateButton.Visible = 'off';
            app.COMActive = 1;
            SerialConfig(app);
        end

        % Button pushed function: COMShutdownButton
        function COMShutdownButtonPushed(app, event)
            app.COMShutdownButton.Visible = 'off';
            app.COMActivateButton.Visible = 'on';
            app.COMActive = 0;
            SerialConfig(app);
        end

        % Button down function: MainOverlayUIAxes
        function MainOverlayUIAxesButtonDown(app, event)
            %Click detection is disabled if path planning is not active
            if(app.PlanningActive == 1)
                if app.UsingPresetInputs == 1

                    ClickedButton = 'normal';

                else

                    ClickedButton = get(app.UIFigure,'SelectionType');

                end

                %LMB to create new waypoint, RMB to remove last waypoint
                if strcmp(ClickedButton,'normal')
                    %% LMB click: add new waypoint
                    if app.UsingPresetInputs == 1
                        
                        ClickedPos(1,1) = app.PresetInputX;
                        ClickedPos(1,2) = app.PresetInputY;

                    else
                    
                        ClickedPos = get(app.MainOverlayUIAxes,'CurrentPoint');
                    
                    end
                    
%                     % Check if clicked point is within ROI - unnecessary
%                     % for V2FPC system
%                     if(norm([ClickedPos(1,1),ClickedPos(1,2)]-[127,127])<=app.RadiusOfOperation)
                        len = length(app.WaypointX);
                        app.WaypointX(len+1) = ClickedPos(1,1);
                        app.WaypointY(len+1) = ClickedPos(1,2);
                        app.WaypointPlot = plot(app.MainOverlayUIAxes,app.WaypointX(2:len+1),app.WaypointY(2:len+1),'rx','MarkerSize',5);
                        if(len>=2)
                            %% Expand WaypointX&Y, generate & draw spline
                            app.GeneratedPathX = [];
                            app.GeneratedPathY = [];
                            X_Temp = zeros(1,len+2);
                            Y_Temp = zeros(1,len+2);
                            X_Temp(1) = app.WaypointX(1);
                            X_Temp(2:end) = app.WaypointX;
                            X_Temp(end+1) = app.WaypointX(end);
                            Y_Temp(1) = app.WaypointY(1);
                            Y_Temp(2:end) = app.WaypointY;
                            Y_Temp(end+1) = app.WaypointY(end);
                            for k=1:len
                                [xvec,yvec] = EvaluateCardinal2DAtNplusOneValues( ...
                                    [X_Temp(k  ),Y_Temp(k  )],[X_Temp(k+1),Y_Temp(k+1)], ...
                                    [X_Temp(k+2),Y_Temp(k+2)],[X_Temp(k+3),Y_Temp(k+3)], ...
                                    app.SplineConfiguration(1),app.SplineConfiguration(2));                                
                                    app.GeneratedPathX = [app.GeneratedPathX,xvec];
                                    app.GeneratedPathY = [app.GeneratedPathY,yvec];
                            end
                            if(len>=3)
                                delete(app.PathPlot);
                            end
                            app.PathPlot = plot(app.MainOverlayUIAxes,app.GeneratedPathX,app.GeneratedPathY,'r','LineWidth',1);

                        end

%                     elseif(app.UsingPresetInputs == 1)
%                         msgbox('Selected waypoint position is invalid.')
%                     end
                    app.UsingPresetInputs = 0;
                    
                elseif strcmp(ClickedButton,'alt')&&(length(app.WaypointX)>=4)                   
                    %% RMB click: remove latest waypoint
                    %The user is prohibited to remove waypoints when there
                    %are <=3 points present, to prevent path generation
                    %problems. RMB click removes last number in Waypoint
                    %and clears UIAxes so that new Waypoint and
                    %GeneratedPath can be plotted.
                    
                    %% Reset UI overlay
                    app.WaypointX(end) = [];
                    app.WaypointY(end) = [];
                    cla(app.MainOverlayUIAxes);

                    % Draw AOI indicator ring
%                     DrawDiam = app.RadiusOfOperation*2;
%                     DrawPos = 128-app.RadiusOfOperation;
% %                     rectangle(app.MainOverlayUIAxes,'Position',[5,5,245,245],'Curvature',[1,1],'LineStyle',"--","EdgeColor",[0 0 1]);            
%                     rectangle(app.MainOverlayUIAxes,'Position',[DrawPos,DrawPos,DrawDiam,DrawDiam],'Curvature',[1,1],'LineStyle',"--","EdgeColor",[0 0 1]);
                    
                    plot(app.MainOverlayUIAxes,app.CVCapturedPos(1,1),app.CVCapturedPos(1,2),'rd',"MarkerSize",10);
                    
                    %% Remove one waypoint
                    len = length(app.WaypointX);
                    plot(app.MainOverlayUIAxes,app.WaypointX(2:len),app.WaypointY(2:len),'rx','MarkerSize',5);
                    
                    if(len>=2)
                        app.GeneratedPathX = [];
                        app.GeneratedPathY = [];                        
                        X_Temp = zeros(1,len+1);
                        Y_Temp = zeros(1,len+1);                        
                        %% Reform Waypoint X&Y, generate & draw spline
                        X_Temp(1) = app.WaypointX(1);
                        X_Temp(2:end) = app.WaypointX;
                        X_Temp(end+1) = app.WaypointX(end);
                        Y_Temp(1) = app.WaypointY(1);
                        Y_Temp(2:end) = app.WaypointY;
                        Y_Temp(end+1) = app.WaypointY(end);
                        for k=1:len-1
                            [xvec,yvec] = EvaluateCardinal2DAtNplusOneValues( ...
                                [X_Temp(k  ),Y_Temp(k  )],[X_Temp(k+1),Y_Temp(k+1)], ...
                                [X_Temp(k+2),Y_Temp(k+2)],[X_Temp(k+3),Y_Temp(k+3)], ...
                                app.SplineConfiguration(1),app.SplineConfiguration(2));                                
                                app.GeneratedPathX = [app.GeneratedPathX,xvec];
                                app.GeneratedPathY = [app.GeneratedPathY,yvec];
                        end
                        if(len>=3)
                            delete(app.PathPlot);
                        end
                        app.PathPlot = plot(app.MainOverlayUIAxes,app.GeneratedPathX,app.GeneratedPathY,'r','LineWidth',1);
                       
                        
                    end
                end
                
            end
        end

        % Drop down opening function: COMSelectDropDown
        function COMSelectDropDownOpening(app, event)
            app.COMSelectDropDown.Items = serialportlist("all");
        end

        % Button pushed function: PS1Button
        function PS1ButtonPushed(app, event)
            
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField.Value, app.PSYEditField.Value);            
            MainOverlayUIAxesButtonDown(app);

        end

        % Button pushed function: PS2Button
        function PS2ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_2.Value, app.PSYEditField_2.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: PS3Button
        function PS3ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_3.Value, app.PSYEditField_3.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: PS4Button
        function PS4ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_4.Value, app.PSYEditField_4.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: PS5Button
        function PS5ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_5.Value, app.PSYEditField_5.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: PS6Button
        function PS6ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_6.Value, app.PSYEditField_6.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: PS7Button
        function PS7ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_7.Value, app.PSYEditField_7.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: PS8Button
        function PS8ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_8.Value, app.PSYEditField_8.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: PS9Button
        function PS9ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_9.Value, app.PSYEditField_9.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: PS10Button
        function PS10ButtonPushed(app, event)
            app.UsingPresetInputs = 1;
            [app.PresetInputX, app.PresetInputY] = Mil2Pixel(app,app.PSXEditField_10.Value, app.PSYEditField_10.Value);
            MainOverlayUIAxesButtonDown(app);
        end

        % Button pushed function: DisableLoggingButton
        function DisableLoggingButtonPushed(app, event)
            app.SaveDataEnabled = 0;
            app.DisableLoggingButton.Enable = 'off';
            app.DisableLoggingButton.Visible = 'off';
            app.EnableLoggingButton.Enable = 'on';
            app.EnableLoggingButton.Visible = 'on';
            app.DataLoggingLamp.Color = [1,0,0];
        end

        % Button pushed function: EnableLoggingButton
        function EnableLoggingButtonPushed(app, event)
            app.SaveDataEnabled = 1;
            app.DisableLoggingButton.Enable = 'on';
            app.DisableLoggingButton.Visible = 'on';
            app.EnableLoggingButton.Enable = 'off';
            app.EnableLoggingButton.Visible = 'off';
            app.DataLoggingLamp.Color = [0,1,0];
        end

        % Button pushed function: AlignToInputButton
        function AlignToInputButtonPushed(app, event)
            if(app.COMActive == 1)
                
                PolarData = round((app.PoEditField.Value/180)*4095);
                AzimData = round((app.AzEditField.Value/360)*4095);
    
                %Add F&F mode indicator to data
                PolarData = PolarData+0xF000;
                AzimData = AzimData+0xF000;
    
                PolarD1 = bitshift(bitand(PolarData,0xFF00),-8);
                PolarD2 = bitand(PolarData,0x00FF);
                AzimD1 = bitshift(bitand(AzimData,0xFF00),-8);
                AzimD2 = bitand(AzimData,0x00FF);
    
                AlignData = [PolarD1,PolarD2,AzimD1,AzimD2];
                write(app.SerialObject,app.StopCmd,"uint8");
                pause(0.005);
                write(app.SerialObject,AlignData,"uint8");

            else
                errordlg('串口未启动');
            end
        end

        % Button pushed function: FindHomeButton
        function FindHomeButtonPushed(app, event)
            
%             msgbox("Finding Home");
            app.FindingHomeLabel.Visible = 'on';
            
            % Move to travel limit            app.TMC1.tmc_continuous_move(app.TMCHandle, uint8(0x00), uint8(1));% X Left
            pause(8);
            app.TMC1.tmc_continuous_move(app.TMCHandle, uint8(0x01), uint8(1));% Y Back
            pause(8);            
            
            % Move to AOI center                  
            app.TMC1.tmc_relative_move(app.TMCHandle, uint8(0x00), double(-100+app.TMCxCorrection));
            app.TMC1.tmc_relative_move(app.TMCHandle, uint8(0x01), double(-100+app.TMCyCorrection));
%             app.TMC1.tmc_relative_move(app.TMCHandle, uint8(0x02), double( 100+app.TMCzCorrection));
            pause(5);
            
            % Set as origin
            % XY axis center of travel, Z axis bottom
            app.TMC1.tmc_set_position(app.TMCHandle, uint8(0x00), double(0));
            app.TMC1.tmc_set_position(app.TMCHandle, uint8(0x01), double(0));            
            % Set UI display value
            app.MoverXDataEditField.Value = 0;
            app.MoverYDataEditField.Value = 0;
            app.MoverZDataEditField.Value = 0;

%             msgbox("Find Home complete");
            app.FindingHomeLabel.Visible = 'off';



        end

        % Button pushed function: GoHomeButton
        function GoHomeButtonButtonPushed(app, event)
            
            app.TMC1.tmc_absolute_move(app.TMCHandle, uint8(0x00), double(0));
            app.TMC1.tmc_absolute_move(app.TMCHandle, uint8(0x01), double(0));
%             app.TMC1.tmc_line_interpolation_3d(app.TMCHandle, uint8(0x00), double(0), ...
%                                                               uint8(0x01), double(0), ...
%                                                               uint8(0x02), double(0));

            app.MoverXDataEditField.Value = 0;
            app.MoverYDataEditField.Value = 0;
            app.MoverZDataEditField.Value = 0;
                        
        end

        % Button pushed function: MoveButton
        function MoveButtonPushed(app, event)
                            
            app.TMC1.tmc_absolute_move(app.TMCHandle, uint8(0x00), double(app.ManualXPosEditField.Value));
            app.TMC1.tmc_absolute_move(app.TMCHandle, uint8(0x01), double(app.ManualYPosEditField.Value));
%             app.TMC1.tmc_line_interpolation_3d(app.TMCHandle, uint8(0x00), double(app.ManualXPosEditField.Value), ...
%                                                               uint8(0x01), double(app.ManualYPosEditField.Value), ...
%                                                               uint8(0x02), double(app.ManualZPosEditField.Value));

            app.MoverXDataEditField.Value = app.ManualXPosEditField.Value;
            app.MoverYDataEditField.Value = app.ManualYPosEditField.Value;
            app.MoverZDataEditField.Value = 0;
            
                
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1108 735];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {2, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 2};
            app.GridLayout.RowHeight = {22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 10, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22};
            app.GridLayout.RowSpacing = 2;
            app.GridLayout.Padding = [10 2 10 2];

            % Create Log1UIAxes
            app.Log1UIAxes = uiaxes(app.GridLayout);
            title(app.Log1UIAxes, 'Path Following')
            xlabel(app.Log1UIAxes, 'X [mm]')
            ylabel(app.Log1UIAxes, 'Y [um]')
            zlabel(app.Log1UIAxes, 'Z')
            app.Log1UIAxes.XLim = [0 18000];
            app.Log1UIAxes.YLim = [0 18000];
            app.Log1UIAxes.YDir = 'reverse';
            app.Log1UIAxes.Layout.Row = [21 31];
            app.Log1UIAxes.Layout.Column = [2 12];

            % Create Log2UIAxes
            app.Log2UIAxes = uiaxes(app.GridLayout);
            title(app.Log2UIAxes, 'Waypoints vs Actual Path')
            xlabel(app.Log2UIAxes, 'X [mm]')
            ylabel(app.Log2UIAxes, 'Y [um]')
            zlabel(app.Log2UIAxes, 'Z')
            app.Log2UIAxes.XLim = [0 18000];
            app.Log2UIAxes.YLim = [0 18000];
            app.Log2UIAxes.YDir = 'reverse';
            app.Log2UIAxes.Layout.Row = [21 31];
            app.Log2UIAxes.Layout.Column = [13 23];

            % Create Log3UIAxes
            app.Log3UIAxes = uiaxes(app.GridLayout);
            title(app.Log3UIAxes, 'Tracking Error')
            xlabel(app.Log3UIAxes, 'Index of Data')
            ylabel(app.Log3UIAxes, 'Deviation from Path [um]')
            zlabel(app.Log3UIAxes, 'Z')
            app.Log3UIAxes.YGrid = 'on';
            app.Log3UIAxes.Layout.Row = [21 31];
            app.Log3UIAxes.Layout.Column = [24 39];

            % Create MainImageUIAxes
            app.MainImageUIAxes = uiaxes(app.GridLayout);
            app.MainImageUIAxes.DataAspectRatio = [1 1 1];
            app.MainImageUIAxes.PlotBoxAspectRatio = [999 999 1];
            app.MainImageUIAxes.XLim = [0 999];
            app.MainImageUIAxes.YLim = [0 999];
            app.MainImageUIAxes.XTick = [];
            app.MainImageUIAxes.YTick = [];
            app.MainImageUIAxes.XGrid = 'on';
            app.MainImageUIAxes.YGrid = 'on';
            app.MainImageUIAxes.Box = 'on';
            app.MainImageUIAxes.Layout.Row = [1 20];
            app.MainImageUIAxes.Layout.Column = [2 19];

            % Create MainOverlayUIAxes
            app.MainOverlayUIAxes = uiaxes(app.GridLayout);
            app.MainOverlayUIAxes.DataAspectRatio = [1 1 1];
            app.MainOverlayUIAxes.XLim = [0 255];
            app.MainOverlayUIAxes.YLim = [0 255];
            app.MainOverlayUIAxes.YDir = 'reverse';
            app.MainOverlayUIAxes.XAxisLocation = 'top';
            app.MainOverlayUIAxes.XTick = [];
            app.MainOverlayUIAxes.YTick = [];
            app.MainOverlayUIAxes.Color = 'none';
            app.MainOverlayUIAxes.Box = 'on';
            app.MainOverlayUIAxes.Layout.Row = [1 20];
            app.MainOverlayUIAxes.Layout.Column = [2 19];
            app.MainOverlayUIAxes.ButtonDownFcn = createCallbackFcn(app, @MainOverlayUIAxesButtonDown, true);

            % Create StartPlanningButton
            app.StartPlanningButton = uibutton(app.GridLayout, 'push');
            app.StartPlanningButton.ButtonPushedFcn = createCallbackFcn(app, @StartPlanningButtonPushed, true);
            app.StartPlanningButton.FontSize = 15;
            app.StartPlanningButton.FontWeight = 'bold';
            app.StartPlanningButton.Layout.Row = [18 19];
            app.StartPlanningButton.Layout.Column = [21 25];
            app.StartPlanningButton.Text = 'Draw Path';

            % Create FinishPlanningButton
            app.FinishPlanningButton = uibutton(app.GridLayout, 'push');
            app.FinishPlanningButton.ButtonPushedFcn = createCallbackFcn(app, @FinishPlanningButtonPushed, true);
            app.FinishPlanningButton.FontSize = 15;
            app.FinishPlanningButton.FontWeight = 'bold';
            app.FinishPlanningButton.Visible = 'off';
            app.FinishPlanningButton.Layout.Row = [18 19];
            app.FinishPlanningButton.Layout.Column = [21 25];
            app.FinishPlanningButton.Text = 'Finish Path';

            % Create ExecuteButton
            app.ExecuteButton = uibutton(app.GridLayout, 'push');
            app.ExecuteButton.ButtonPushedFcn = createCallbackFcn(app, @ExecuteButtonPushed, true);
            app.ExecuteButton.FontSize = 15;
            app.ExecuteButton.FontWeight = 'bold';
            app.ExecuteButton.Layout.Row = [18 19];
            app.ExecuteButton.Layout.Column = [26 30];
            app.ExecuteButton.Text = 'Track Path';

            % Create PauseButton
            app.PauseButton = uibutton(app.GridLayout, 'push');
            app.PauseButton.ButtonPushedFcn = createCallbackFcn(app, @PauseButtonPushed, true);
            app.PauseButton.FontSize = 15;
            app.PauseButton.FontWeight = 'bold';
            app.PauseButton.Visible = 'off';
            app.PauseButton.Layout.Row = [18 19];
            app.PauseButton.Layout.Column = [26 30];
            app.PauseButton.Text = 'Pause';

            % Create COMActivateButton
            app.COMActivateButton = uibutton(app.GridLayout, 'push');
            app.COMActivateButton.ButtonPushedFcn = createCallbackFcn(app, @COMActivateButtonPushed, true);
            app.COMActivateButton.Layout.Row = 16;
            app.COMActivateButton.Layout.Column = [21 25];
            app.COMActivateButton.Text = 'Start COM';

            % Create COMShutdownButton
            app.COMShutdownButton = uibutton(app.GridLayout, 'push');
            app.COMShutdownButton.ButtonPushedFcn = createCallbackFcn(app, @COMShutdownButtonPushed, true);
            app.COMShutdownButton.Visible = 'off';
            app.COMShutdownButton.Layout.Row = 16;
            app.COMShutdownButton.Layout.Column = [21 25];
            app.COMShutdownButton.Text = 'Stop COM';

            % Create COMSelectDropDown
            app.COMSelectDropDown = uidropdown(app.GridLayout);
            app.COMSelectDropDown.DropDownOpeningFcn = createCallbackFcn(app, @COMSelectDropDownOpening, true);
            app.COMSelectDropDown.ValueChangedFcn = createCallbackFcn(app, @COMSelectDropDownValueChanged, true);
            app.COMSelectDropDown.Layout.Row = 16;
            app.COMSelectDropDown.Layout.Column = [26 29];

            % Create COMEnableLamp
            app.COMEnableLamp = uilamp(app.GridLayout);
            app.COMEnableLamp.Layout.Row = 16;
            app.COMEnableLamp.Layout.Column = 30;
            app.COMEnableLamp.Color = [1 0 0];

            % Create WPRDistLabel
            app.WPRDistLabel = uilabel(app.GridLayout);
            app.WPRDistLabel.HorizontalAlignment = 'center';
            app.WPRDistLabel.Layout.Row = 5;
            app.WPRDistLabel.Layout.Column = [26 28];
            app.WPRDistLabel.Text = 'Seg. Intv.';

            % Create SegIntvEditField
            app.SegIntvEditField = uieditfield(app.GridLayout, 'numeric');
            app.SegIntvEditField.Layout.Row = 5;
            app.SegIntvEditField.Layout.Column = [29 30];
            app.SegIntvEditField.Value = 8;

            % Create TSUDistEditFieldLabel
            app.TSUDistEditFieldLabel = uilabel(app.GridLayout);
            app.TSUDistEditFieldLabel.HorizontalAlignment = 'center';
            app.TSUDistEditFieldLabel.Layout.Row = 5;
            app.TSUDistEditFieldLabel.Layout.Column = [31 33];
            app.TSUDistEditFieldLabel.Text = 'TSU Dist.';

            % Create TSUDistEditField
            app.TSUDistEditField = uieditfield(app.GridLayout, 'numeric');
            app.TSUDistEditField.Layout.Row = 5;
            app.TSUDistEditField.Layout.Column = [34 35];
            app.TSUDistEditField.Value = 6;

            % Create RotorXDataEditField
            app.RotorXDataEditField = uieditfield(app.GridLayout, 'numeric');
            app.RotorXDataEditField.ValueDisplayFormat = '%.0f';
            app.RotorXDataEditField.Editable = 'off';
            app.RotorXDataEditField.Layout.Row = 12;
            app.RotorXDataEditField.Layout.Column = [29 31];

            % Create RotorYDataEditField
            app.RotorYDataEditField = uieditfield(app.GridLayout, 'numeric');
            app.RotorYDataEditField.ValueDisplayFormat = '%.0f';
            app.RotorYDataEditField.Editable = 'off';
            app.RotorYDataEditField.Layout.Row = 13;
            app.RotorYDataEditField.Layout.Column = [29 31];

            % Create SplineTensionLabel
            app.SplineTensionLabel = uilabel(app.GridLayout);
            app.SplineTensionLabel.HorizontalAlignment = 'center';
            app.SplineTensionLabel.Layout.Row = 5;
            app.SplineTensionLabel.Layout.Column = [21 23];
            app.SplineTensionLabel.Text = 'C-Spline T';

            % Create CSplineTEditField
            app.CSplineTEditField = uieditfield(app.GridLayout, 'numeric');
            app.CSplineTEditField.Layout.Row = 5;
            app.CSplineTEditField.Layout.Column = [24 25];
            app.CSplineTEditField.Value = 1;

            % Create PosmmEditField
            app.PosmmEditField = uieditfield(app.GridLayout, 'numeric');
            app.PosmmEditField.ValueDisplayFormat = '%.3f';
            app.PosmmEditField.Editable = 'off';
            app.PosmmEditField.Layout.Row = 12;
            app.PosmmEditField.Layout.Column = [23 25];

            % Create YPosmmEditField
            app.YPosmmEditField = uieditfield(app.GridLayout, 'numeric');
            app.YPosmmEditField.ValueDisplayFormat = '%.3f';
            app.YPosmmEditField.Editable = 'off';
            app.YPosmmEditField.Layout.Row = 13;
            app.YPosmmEditField.Layout.Column = [23 25];

            % Create KiPathingEditFieldLabel
            app.KiPathingEditFieldLabel = uilabel(app.GridLayout);
            app.KiPathingEditFieldLabel.HorizontalAlignment = 'center';
            app.KiPathingEditFieldLabel.Layout.Row = 3;
            app.KiPathingEditFieldLabel.Layout.Column = [26 28];
            app.KiPathingEditFieldLabel.Text = 'Ki Pathing';

            % Create KiPathingEditField
            app.KiPathingEditField = uieditfield(app.GridLayout, 'numeric');
            app.KiPathingEditField.Layout.Row = 3;
            app.KiPathingEditField.Layout.Column = [29 30];

            % Create KpPathingEditFieldLabel
            app.KpPathingEditFieldLabel = uilabel(app.GridLayout);
            app.KpPathingEditFieldLabel.HorizontalAlignment = 'center';
            app.KpPathingEditFieldLabel.Layout.Row = 3;
            app.KpPathingEditFieldLabel.Layout.Column = [21 23];
            app.KpPathingEditFieldLabel.Text = 'Kp Pathing';

            % Create KpPathingEditField
            app.KpPathingEditField = uieditfield(app.GridLayout, 'numeric');
            app.KpPathingEditField.Layout.Row = 3;
            app.KpPathingEditField.Layout.Column = [24 25];
            app.KpPathingEditField.Value = 200;

            % Create KdPathingEditFieldLabel
            app.KdPathingEditFieldLabel = uilabel(app.GridLayout);
            app.KdPathingEditFieldLabel.HorizontalAlignment = 'center';
            app.KdPathingEditFieldLabel.Layout.Row = 3;
            app.KdPathingEditFieldLabel.Layout.Column = [31 33];
            app.KdPathingEditFieldLabel.Text = 'Kd Pathing';

            % Create KdPathingEditField
            app.KdPathingEditField = uieditfield(app.GridLayout, 'numeric');
            app.KdPathingEditField.Layout.Row = 3;
            app.KdPathingEditField.Layout.Column = [34 35];
            app.KdPathingEditField.Value = 20;

            % Create Label
            app.Label = uilabel(app.GridLayout);
            app.Label.HorizontalAlignment = 'center';
            app.Label.Layout.Row = 4;
            app.Label.Layout.Column = 37;
            app.Label.Text = '1';

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout);
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.Layout.Row = 5;
            app.Label_2.Layout.Column = 37;
            app.Label_2.Text = '2';

            % Create XmmLabel
            app.XmmLabel = uilabel(app.GridLayout);
            app.XmmLabel.HorizontalAlignment = 'center';
            app.XmmLabel.Layout.Row = 3;
            app.XmmLabel.Layout.Column = [38 39];
            app.XmmLabel.Text = 'X [mm]';

            % Create YmmLabel
            app.YmmLabel = uilabel(app.GridLayout);
            app.YmmLabel.HorizontalAlignment = 'center';
            app.YmmLabel.Layout.Row = 3;
            app.YmmLabel.Layout.Column = [40 41];
            app.YmmLabel.Text = 'Y [mm]';

            % Create PS1Button
            app.PS1Button = uibutton(app.GridLayout, 'push');
            app.PS1Button.ButtonPushedFcn = createCallbackFcn(app, @PS1ButtonPushed, true);
            app.PS1Button.Enable = 'off';
            app.PS1Button.Layout.Row = 4;
            app.PS1Button.Layout.Column = [42 43];
            app.PS1Button.Text = 'Set';

            % Create PS2Button
            app.PS2Button = uibutton(app.GridLayout, 'push');
            app.PS2Button.ButtonPushedFcn = createCallbackFcn(app, @PS2ButtonPushed, true);
            app.PS2Button.Enable = 'off';
            app.PS2Button.Layout.Row = 5;
            app.PS2Button.Layout.Column = [42 43];
            app.PS2Button.Text = 'Set';

            % Create PS3Button
            app.PS3Button = uibutton(app.GridLayout, 'push');
            app.PS3Button.ButtonPushedFcn = createCallbackFcn(app, @PS3ButtonPushed, true);
            app.PS3Button.Enable = 'off';
            app.PS3Button.Layout.Row = 6;
            app.PS3Button.Layout.Column = [42 43];
            app.PS3Button.Text = 'Set';

            % Create PS4Button
            app.PS4Button = uibutton(app.GridLayout, 'push');
            app.PS4Button.ButtonPushedFcn = createCallbackFcn(app, @PS4ButtonPushed, true);
            app.PS4Button.Enable = 'off';
            app.PS4Button.Layout.Row = 7;
            app.PS4Button.Layout.Column = [42 43];
            app.PS4Button.Text = 'Set';

            % Create PS5Button
            app.PS5Button = uibutton(app.GridLayout, 'push');
            app.PS5Button.ButtonPushedFcn = createCallbackFcn(app, @PS5ButtonPushed, true);
            app.PS5Button.Enable = 'off';
            app.PS5Button.Layout.Row = 8;
            app.PS5Button.Layout.Column = [42 43];
            app.PS5Button.Text = 'Set';

            % Create PS6Button
            app.PS6Button = uibutton(app.GridLayout, 'push');
            app.PS6Button.ButtonPushedFcn = createCallbackFcn(app, @PS6ButtonPushed, true);
            app.PS6Button.Enable = 'off';
            app.PS6Button.Layout.Row = 9;
            app.PS6Button.Layout.Column = [42 43];
            app.PS6Button.Text = 'Set';

            % Create PS7Button
            app.PS7Button = uibutton(app.GridLayout, 'push');
            app.PS7Button.ButtonPushedFcn = createCallbackFcn(app, @PS7ButtonPushed, true);
            app.PS7Button.Enable = 'off';
            app.PS7Button.Layout.Row = 10;
            app.PS7Button.Layout.Column = [42 43];
            app.PS7Button.Text = 'Set';

            % Create PS8Button
            app.PS8Button = uibutton(app.GridLayout, 'push');
            app.PS8Button.ButtonPushedFcn = createCallbackFcn(app, @PS8ButtonPushed, true);
            app.PS8Button.Enable = 'off';
            app.PS8Button.Layout.Row = 11;
            app.PS8Button.Layout.Column = [42 43];
            app.PS8Button.Text = 'Set';

            % Create PS9Button
            app.PS9Button = uibutton(app.GridLayout, 'push');
            app.PS9Button.ButtonPushedFcn = createCallbackFcn(app, @PS9ButtonPushed, true);
            app.PS9Button.Enable = 'off';
            app.PS9Button.Layout.Row = 12;
            app.PS9Button.Layout.Column = [42 43];
            app.PS9Button.Text = 'Set';

            % Create PS10Button
            app.PS10Button = uibutton(app.GridLayout, 'push');
            app.PS10Button.ButtonPushedFcn = createCallbackFcn(app, @PS10ButtonPushed, true);
            app.PS10Button.Enable = 'off';
            app.PS10Button.Layout.Row = 13;
            app.PS10Button.Layout.Column = [42 43];
            app.PS10Button.Text = 'Set';

            % Create PresetWaypointsLabel
            app.PresetWaypointsLabel = uilabel(app.GridLayout);
            app.PresetWaypointsLabel.HorizontalAlignment = 'center';
            app.PresetWaypointsLabel.FontWeight = 'bold';
            app.PresetWaypointsLabel.Layout.Row = 2;
            app.PresetWaypointsLabel.Layout.Column = [37 43];
            app.PresetWaypointsLabel.Text = 'Preset Waypoints';

            % Create PSNumberLabel
            app.PSNumberLabel = uilabel(app.GridLayout);
            app.PSNumberLabel.HorizontalAlignment = 'center';
            app.PSNumberLabel.Layout.Row = 3;
            app.PSNumberLabel.Layout.Column = 37;
            app.PSNumberLabel.Text = '#';

            % Create Label_3
            app.Label_3 = uilabel(app.GridLayout);
            app.Label_3.HorizontalAlignment = 'center';
            app.Label_3.Layout.Row = 6;
            app.Label_3.Layout.Column = 37;
            app.Label_3.Text = '3';

            % Create Label_4
            app.Label_4 = uilabel(app.GridLayout);
            app.Label_4.HorizontalAlignment = 'center';
            app.Label_4.Layout.Row = 7;
            app.Label_4.Layout.Column = 37;
            app.Label_4.Text = '4';

            % Create Label_5
            app.Label_5 = uilabel(app.GridLayout);
            app.Label_5.HorizontalAlignment = 'center';
            app.Label_5.Layout.Row = 8;
            app.Label_5.Layout.Column = 37;
            app.Label_5.Text = '5';

            % Create Label_6
            app.Label_6 = uilabel(app.GridLayout);
            app.Label_6.HorizontalAlignment = 'center';
            app.Label_6.Layout.Row = 9;
            app.Label_6.Layout.Column = 37;
            app.Label_6.Text = '6';

            % Create Label_7
            app.Label_7 = uilabel(app.GridLayout);
            app.Label_7.HorizontalAlignment = 'center';
            app.Label_7.Layout.Row = 10;
            app.Label_7.Layout.Column = 37;
            app.Label_7.Text = '7';

            % Create Label_8
            app.Label_8 = uilabel(app.GridLayout);
            app.Label_8.HorizontalAlignment = 'center';
            app.Label_8.Layout.Row = 11;
            app.Label_8.Layout.Column = 37;
            app.Label_8.Text = '8';

            % Create Label_9
            app.Label_9 = uilabel(app.GridLayout);
            app.Label_9.HorizontalAlignment = 'center';
            app.Label_9.Layout.Row = 12;
            app.Label_9.Layout.Column = 37;
            app.Label_9.Text = '9';

            % Create Label_10
            app.Label_10 = uilabel(app.GridLayout);
            app.Label_10.HorizontalAlignment = 'center';
            app.Label_10.Layout.Row = 13;
            app.Label_10.Layout.Column = 37;
            app.Label_10.Text = '10';

            % Create PSXEditField
            app.PSXEditField = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField.Limits = [0 255];
            app.PSXEditField.ValueDisplayFormat = '%.1f';
            app.PSXEditField.Layout.Row = 4;
            app.PSXEditField.Layout.Column = [38 39];
            app.PSXEditField.Value = 40;

            % Create PSYEditField
            app.PSYEditField = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField.Limits = [0 255];
            app.PSYEditField.ValueDisplayFormat = '%.1f';
            app.PSYEditField.Layout.Row = 4;
            app.PSYEditField.Layout.Column = [40 41];
            app.PSYEditField.Value = 140;

            % Create PSXEditField_2
            app.PSXEditField_2 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_2.Limits = [0 255];
            app.PSXEditField_2.ValueDisplayFormat = '%.1f';
            app.PSXEditField_2.Layout.Row = 5;
            app.PSXEditField_2.Layout.Column = [38 39];
            app.PSXEditField_2.Value = 90;

            % Create PSYEditField_2
            app.PSYEditField_2 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_2.Limits = [0 255];
            app.PSYEditField_2.ValueDisplayFormat = '%.1f';
            app.PSYEditField_2.Layout.Row = 5;
            app.PSYEditField_2.Layout.Column = [40 41];
            app.PSYEditField_2.Value = 140;

            % Create PSXEditField_3
            app.PSXEditField_3 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_3.Limits = [0 255];
            app.PSXEditField_3.ValueDisplayFormat = '%.1f';
            app.PSXEditField_3.Layout.Row = 6;
            app.PSXEditField_3.Layout.Column = [38 39];
            app.PSXEditField_3.Value = 140;

            % Create PSYEditField_3
            app.PSYEditField_3 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_3.Limits = [0 255];
            app.PSYEditField_3.ValueDisplayFormat = '%.1f';
            app.PSYEditField_3.Layout.Row = 6;
            app.PSYEditField_3.Layout.Column = [40 41];
            app.PSYEditField_3.Value = 140;

            % Create PSXEditField_4
            app.PSXEditField_4 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_4.Limits = [0 255];
            app.PSXEditField_4.ValueDisplayFormat = '%.1f';
            app.PSXEditField_4.Layout.Row = 7;
            app.PSXEditField_4.Layout.Column = [38 39];
            app.PSXEditField_4.Value = 40;

            % Create PSYEditField_4
            app.PSYEditField_4 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_4.Limits = [0 255];
            app.PSYEditField_4.ValueDisplayFormat = '%.1f';
            app.PSYEditField_4.Layout.Row = 7;
            app.PSYEditField_4.Layout.Column = [40 41];
            app.PSYEditField_4.Value = 90;

            % Create PSXEditField_5
            app.PSXEditField_5 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_5.Limits = [0 255];
            app.PSXEditField_5.ValueDisplayFormat = '%.1f';
            app.PSXEditField_5.Layout.Row = 8;
            app.PSXEditField_5.Layout.Column = [38 39];
            app.PSXEditField_5.Value = 90;

            % Create PSYEditField_5
            app.PSYEditField_5 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_5.Limits = [0 255];
            app.PSYEditField_5.ValueDisplayFormat = '%.1f';
            app.PSYEditField_5.Layout.Row = 8;
            app.PSYEditField_5.Layout.Column = [40 41];
            app.PSYEditField_5.Value = 90;

            % Create PSXEditField_6
            app.PSXEditField_6 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_6.Limits = [0 255];
            app.PSXEditField_6.ValueDisplayFormat = '%.1f';
            app.PSXEditField_6.Layout.Row = 9;
            app.PSXEditField_6.Layout.Column = [38 39];
            app.PSXEditField_6.Value = 140;

            % Create PSYEditField_6
            app.PSYEditField_6 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_6.Limits = [0 255];
            app.PSYEditField_6.ValueDisplayFormat = '%.1f';
            app.PSYEditField_6.Layout.Row = 9;
            app.PSYEditField_6.Layout.Column = [40 41];
            app.PSYEditField_6.Value = 90;

            % Create PSXEditField_7
            app.PSXEditField_7 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_7.Limits = [0 255];
            app.PSXEditField_7.ValueDisplayFormat = '%.1f';
            app.PSXEditField_7.Layout.Row = 10;
            app.PSXEditField_7.Layout.Column = [38 39];
            app.PSXEditField_7.Value = 40;

            % Create PSYEditField_7
            app.PSYEditField_7 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_7.Limits = [0 255];
            app.PSYEditField_7.ValueDisplayFormat = '%.1f';
            app.PSYEditField_7.Layout.Row = 10;
            app.PSYEditField_7.Layout.Column = [40 41];
            app.PSYEditField_7.Value = 40;

            % Create PSXEditField_8
            app.PSXEditField_8 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_8.Limits = [0 255];
            app.PSXEditField_8.ValueDisplayFormat = '%.1f';
            app.PSXEditField_8.Layout.Row = 11;
            app.PSXEditField_8.Layout.Column = [38 39];
            app.PSXEditField_8.Value = 90;

            % Create PSYEditField_8
            app.PSYEditField_8 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_8.Limits = [0 255];
            app.PSYEditField_8.ValueDisplayFormat = '%.1f';
            app.PSYEditField_8.Layout.Row = 11;
            app.PSYEditField_8.Layout.Column = [40 41];
            app.PSYEditField_8.Value = 40;

            % Create PSXEditField_9
            app.PSXEditField_9 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_9.Limits = [0 255];
            app.PSXEditField_9.ValueDisplayFormat = '%.1f';
            app.PSXEditField_9.Layout.Row = 12;
            app.PSXEditField_9.Layout.Column = [38 39];
            app.PSXEditField_9.Value = 140;

            % Create PSYEditField_9
            app.PSYEditField_9 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_9.Limits = [0 255];
            app.PSYEditField_9.ValueDisplayFormat = '%.1f';
            app.PSYEditField_9.Layout.Row = 12;
            app.PSYEditField_9.Layout.Column = [40 41];
            app.PSYEditField_9.Value = 40;

            % Create PSXEditField_10
            app.PSXEditField_10 = uieditfield(app.GridLayout, 'numeric');
            app.PSXEditField_10.Limits = [0 255];
            app.PSXEditField_10.ValueDisplayFormat = '%.1f';
            app.PSXEditField_10.Layout.Row = 13;
            app.PSXEditField_10.Layout.Column = [38 39];

            % Create PSYEditField_10
            app.PSYEditField_10 = uieditfield(app.GridLayout, 'numeric');
            app.PSYEditField_10.Limits = [0 255];
            app.PSYEditField_10.ValueDisplayFormat = '%.1f';
            app.PSYEditField_10.Layout.Row = 13;
            app.PSYEditField_10.Layout.Column = [40 41];

            % Create SystemConfigLabel
            app.SystemConfigLabel = uilabel(app.GridLayout);
            app.SystemConfigLabel.HorizontalAlignment = 'center';
            app.SystemConfigLabel.FontWeight = 'bold';
            app.SystemConfigLabel.Layout.Row = 2;
            app.SystemConfigLabel.Layout.Column = [21 35];
            app.SystemConfigLabel.Text = 'System Config';

            % Create SystemControlLabel
            app.SystemControlLabel = uilabel(app.GridLayout);
            app.SystemControlLabel.HorizontalAlignment = 'center';
            app.SystemControlLabel.FontWeight = 'bold';
            app.SystemControlLabel.Layout.Row = 15;
            app.SystemControlLabel.Layout.Column = [21 30];
            app.SystemControlLabel.Text = 'System Control';

            % Create SystemStatusLabel
            app.SystemStatusLabel = uilabel(app.GridLayout);
            app.SystemStatusLabel.HorizontalAlignment = 'center';
            app.SystemStatusLabel.FontWeight = 'bold';
            app.SystemStatusLabel.Layout.Row = 10;
            app.SystemStatusLabel.Layout.Column = [22 34];
            app.SystemStatusLabel.Text = 'System Status';

            % Create DisableLoggingButton
            app.DisableLoggingButton = uibutton(app.GridLayout, 'push');
            app.DisableLoggingButton.ButtonPushedFcn = createCallbackFcn(app, @DisableLoggingButtonPushed, true);
            app.DisableLoggingButton.Enable = 'off';
            app.DisableLoggingButton.Visible = 'off';
            app.DisableLoggingButton.Layout.Row = 17;
            app.DisableLoggingButton.Layout.Column = [21 25];
            app.DisableLoggingButton.Text = 'Disable Logging';

            % Create EnableLoggingButton
            app.EnableLoggingButton = uibutton(app.GridLayout, 'push');
            app.EnableLoggingButton.ButtonPushedFcn = createCallbackFcn(app, @EnableLoggingButtonPushed, true);
            app.EnableLoggingButton.Layout.Row = 17;
            app.EnableLoggingButton.Layout.Column = [21 25];
            app.EnableLoggingButton.Text = 'Enable Logging';

            % Create DataLoggingLamp
            app.DataLoggingLamp = uilamp(app.GridLayout);
            app.DataLoggingLamp.Layout.Row = 17;
            app.DataLoggingLamp.Layout.Column = 30;
            app.DataLoggingLamp.Color = [1 0 0];

            % Create AOIumLabel
            app.AOIumLabel = uilabel(app.GridLayout);
            app.AOIumLabel.HorizontalAlignment = 'center';
            app.AOIumLabel.Layout.Row = 7;
            app.AOIumLabel.Layout.Column = [31 33];
            app.AOIumLabel.Text = 'DOI [mm]';

            % Create AOIDiameterEditField
            app.AOIDiameterEditField = uieditfield(app.GridLayout, 'numeric');
            app.AOIDiameterEditField.ValueDisplayFormat = '%.0f';
            app.AOIDiameterEditField.Layout.Row = 7;
            app.AOIDiameterEditField.Layout.Column = [34 35];
            app.AOIDiameterEditField.Value = 180;

            % Create ComplTimesEditFieldLabel
            app.ComplTimesEditFieldLabel = uilabel(app.GridLayout);
            app.ComplTimesEditFieldLabel.HorizontalAlignment = 'center';
            app.ComplTimesEditFieldLabel.Layout.Row = 21;
            app.ComplTimesEditFieldLabel.Layout.Column = [40 43];
            app.ComplTimesEditFieldLabel.Text = 'Compl. Time [s]';

            % Create RunTimeEditField
            app.RunTimeEditField = uieditfield(app.GridLayout, 'numeric');
            app.RunTimeEditField.Layout.Row = 22;
            app.RunTimeEditField.Layout.Column = [40 43];

            % Create AvgErrorumLabel
            app.AvgErrorumLabel = uilabel(app.GridLayout);
            app.AvgErrorumLabel.HorizontalAlignment = 'center';
            app.AvgErrorumLabel.Layout.Row = 23;
            app.AvgErrorumLabel.Layout.Column = [40 43];
            app.AvgErrorumLabel.Text = 'Mean Error [mm]';

            % Create MeanErrorEditField
            app.MeanErrorEditField = uieditfield(app.GridLayout, 'numeric');
            app.MeanErrorEditField.ValueDisplayFormat = '%.3f';
            app.MeanErrorEditField.Layout.Row = 24;
            app.MeanErrorEditField.Layout.Column = [40 43];

            % Create AvgErrorumLabel_2
            app.AvgErrorumLabel_2 = uilabel(app.GridLayout);
            app.AvgErrorumLabel_2.HorizontalAlignment = 'center';
            app.AvgErrorumLabel_2.Layout.Row = 25;
            app.AvgErrorumLabel_2.Layout.Column = [40 43];
            app.AvgErrorumLabel_2.Text = '90% Error [mm]';

            % Create ErrorAt90EditField
            app.ErrorAt90EditField = uieditfield(app.GridLayout, 'numeric');
            app.ErrorAt90EditField.ValueDisplayFormat = '%.3f';
            app.ErrorAt90EditField.Layout.Row = 26;
            app.ErrorAt90EditField.Layout.Column = [40 43];

            % Create DestXmmLabel
            app.DestXmmLabel = uilabel(app.GridLayout);
            app.DestXmmLabel.HorizontalAlignment = 'center';
            app.DestXmmLabel.Layout.Row = 27;
            app.DestXmmLabel.Layout.Column = [40 43];
            app.DestXmmLabel.Text = 'Dest. X [mm]';

            % Create DestXEditField
            app.DestXEditField = uieditfield(app.GridLayout, 'numeric');
            app.DestXEditField.ValueDisplayFormat = '%.3f';
            app.DestXEditField.Layout.Row = 28;
            app.DestXEditField.Layout.Column = [40 43];

            % Create DestYmmLabel
            app.DestYmmLabel = uilabel(app.GridLayout);
            app.DestYmmLabel.HorizontalAlignment = 'center';
            app.DestYmmLabel.Layout.Row = 29;
            app.DestYmmLabel.Layout.Column = [40 43];
            app.DestYmmLabel.Text = 'Dest. Y [mm]';

            % Create DestYEditField
            app.DestYEditField = uieditfield(app.GridLayout, 'numeric');
            app.DestYEditField.ValueDisplayFormat = '%.3f';
            app.DestYEditField.Layout.Row = 30;
            app.DestYEditField.Layout.Column = [40 43];

            % Create PFDDistREditFieldLabel
            app.PFDDistREditFieldLabel = uilabel(app.GridLayout);
            app.PFDDistREditFieldLabel.HorizontalAlignment = 'center';
            app.PFDDistREditFieldLabel.Layout.Row = 6;
            app.PFDDistREditFieldLabel.Layout.Column = [21 23];
            app.PFDDistREditFieldLabel.Text = 'PFD Dist R';

            % Create PFDDistREditField
            app.PFDDistREditField = uieditfield(app.GridLayout, 'numeric');
            app.PFDDistREditField.Layout.Row = 6;
            app.PFDDistREditField.Layout.Column = [24 25];
            app.PFDDistREditField.Value = 2;

            % Create PFDCountEditFieldLabel
            app.PFDCountEditFieldLabel = uilabel(app.GridLayout);
            app.PFDCountEditFieldLabel.HorizontalAlignment = 'right';
            app.PFDCountEditFieldLabel.Layout.Row = 6;
            app.PFDCountEditFieldLabel.Layout.Column = [31 33];
            app.PFDCountEditFieldLabel.Text = 'PFD Count';

            % Create PFDCountEditField
            app.PFDCountEditField = uieditfield(app.GridLayout, 'numeric');
            app.PFDCountEditField.Layout.Row = 6;
            app.PFDCountEditField.Layout.Column = [34 35];
            app.PFDCountEditField.Value = 5;

            % Create MoverXDataEditField
            app.MoverXDataEditField = uieditfield(app.GridLayout, 'numeric');
            app.MoverXDataEditField.ValueDisplayFormat = '%.3f';
            app.MoverXDataEditField.Editable = 'off';
            app.MoverXDataEditField.Layout.Row = 12;
            app.MoverXDataEditField.Layout.Column = [32 34];

            % Create MoverYDataEditField
            app.MoverYDataEditField = uieditfield(app.GridLayout, 'numeric');
            app.MoverYDataEditField.ValueDisplayFormat = '%.3f';
            app.MoverYDataEditField.Editable = 'off';
            app.MoverYDataEditField.Layout.Row = 13;
            app.MoverYDataEditField.Layout.Column = [32 34];

            % Create XLabel_5
            app.XLabel_5 = uilabel(app.GridLayout);
            app.XLabel_5.HorizontalAlignment = 'center';
            app.XLabel_5.Layout.Row = 12;
            app.XLabel_5.Layout.Column = 22;
            app.XLabel_5.Text = 'X';

            % Create YLabel_2
            app.YLabel_2 = uilabel(app.GridLayout);
            app.YLabel_2.HorizontalAlignment = 'center';
            app.YLabel_2.Layout.Row = 13;
            app.YLabel_2.Layout.Column = 22;
            app.YLabel_2.Text = 'Y';

            % Create RobotmmLabel
            app.RobotmmLabel = uilabel(app.GridLayout);
            app.RobotmmLabel.HorizontalAlignment = 'center';
            app.RobotmmLabel.Layout.Row = 11;
            app.RobotmmLabel.Layout.Column = [23 25];
            app.RobotmmLabel.Text = 'Robot [mm]';

            % Create RotorCmdLabel
            app.RotorCmdLabel = uilabel(app.GridLayout);
            app.RotorCmdLabel.HorizontalAlignment = 'center';
            app.RotorCmdLabel.Layout.Row = 11;
            app.RotorCmdLabel.Layout.Column = [29 31];
            app.RotorCmdLabel.Text = 'Rotor Cmd';

            % Create MoverCmdLabel
            app.MoverCmdLabel = uilabel(app.GridLayout);
            app.MoverCmdLabel.HorizontalAlignment = 'center';
            app.MoverCmdLabel.Layout.Row = 11;
            app.MoverCmdLabel.Layout.Column = [32 34];
            app.MoverCmdLabel.Text = 'Mover Cmd';

            % Create PoEditFieldLabel
            app.PoEditFieldLabel = uilabel(app.GridLayout);
            app.PoEditFieldLabel.HorizontalAlignment = 'center';
            app.PoEditFieldLabel.Layout.Row = 16;
            app.PoEditFieldLabel.Layout.Column = [31 32];
            app.PoEditFieldLabel.Text = 'Po. [°]';

            % Create PoEditField
            app.PoEditField = uieditfield(app.GridLayout, 'numeric');
            app.PoEditField.Layout.Row = 17;
            app.PoEditField.Layout.Column = [31 32];
            app.PoEditField.Value = 90;

            % Create AlignToInputButton
            app.AlignToInputButton = uibutton(app.GridLayout, 'push');
            app.AlignToInputButton.ButtonPushedFcn = createCallbackFcn(app, @AlignToInputButtonPushed, true);
            app.AlignToInputButton.FontSize = 15;
            app.AlignToInputButton.FontWeight = 'bold';
            app.AlignToInputButton.Layout.Row = [18 19];
            app.AlignToInputButton.Layout.Column = [31 34];
            app.AlignToInputButton.Text = 'Align';

            % Create AzEditFieldLabel
            app.AzEditFieldLabel = uilabel(app.GridLayout);
            app.AzEditFieldLabel.HorizontalAlignment = 'center';
            app.AzEditFieldLabel.Layout.Row = 16;
            app.AzEditFieldLabel.Layout.Column = [33 34];
            app.AzEditFieldLabel.Text = 'Az. [°]';

            % Create AzEditField
            app.AzEditField = uieditfield(app.GridLayout, 'numeric');
            app.AzEditField.Layout.Row = 17;
            app.AzEditField.Layout.Column = [33 34];

            % Create ManualRotateLabel
            app.ManualRotateLabel = uilabel(app.GridLayout);
            app.ManualRotateLabel.HorizontalAlignment = 'center';
            app.ManualRotateLabel.FontWeight = 'bold';
            app.ManualRotateLabel.Layout.Row = 15;
            app.ManualRotateLabel.Layout.Column = [31 34];
            app.ManualRotateLabel.Text = 'Manual Rotate';

            % Create MoveButton
            app.MoveButton = uibutton(app.GridLayout, 'push');
            app.MoveButton.ButtonPushedFcn = createCallbackFcn(app, @MoveButtonPushed, true);
            app.MoveButton.FontSize = 15;
            app.MoveButton.FontWeight = 'bold';
            app.MoveButton.Layout.Row = [18 19];
            app.MoveButton.Layout.Column = [41 43];
            app.MoveButton.Text = 'Move';

            % Create FindHomeButton
            app.FindHomeButton = uibutton(app.GridLayout, 'push');
            app.FindHomeButton.ButtonPushedFcn = createCallbackFcn(app, @FindHomeButtonPushed, true);
            app.FindHomeButton.FontSize = 15;
            app.FindHomeButton.FontWeight = 'bold';
            app.FindHomeButton.Layout.Row = [18 19];
            app.FindHomeButton.Layout.Column = [38 40];
            app.FindHomeButton.Text = {'Find'; 'Home'};

                        % Create ManualZPosEditField
            app.ManualZPosEditField = uieditfield(app.GridLayout, 'numeric');
            app.ManualZPosEditField.Limits = [0 200];
            app.ManualZPosEditField.Layout.Row = 17;
            app.ManualZPosEditField.Layout.Column = [41 43];
            app.ManualZPosEditField.Editable = 'off';
            app.ManualZPosEditField.Value = 0;
% Create VzmmsLabel_3
            app.VzmmsLabel_3 = uilabel(app.GridLayout);
            app.VzmmsLabel_3.HorizontalAlignment = 'center';
            app.VzmmsLabel_3.Layout.Row = 16;
            app.VzmmsLabel_3.Layout.Column = [41 43];
            app.VzmmsLabel_3.Text = 'Z Disabled';

            % Create ManualXPosEditField
            app.ManualXPosEditField = uieditfield(app.GridLayout, 'numeric');
            app.ManualXPosEditField.Limits = [-90 90];
            app.ManualXPosEditField.Layout.Row = 17;
            app.ManualXPosEditField.Layout.Column = [35 37];

            % Create VzmmsLabel_4
            app.VzmmsLabel_4 = uilabel(app.GridLayout);
            app.VzmmsLabel_4.HorizontalAlignment = 'center';
            app.VzmmsLabel_4.Layout.Row = 16;
            app.VzmmsLabel_4.Layout.Column = [35 37];
            app.VzmmsLabel_4.Text = 'X Pos [mm]';

            % Create ManualYPosEditField
            app.ManualYPosEditField = uieditfield(app.GridLayout, 'numeric');
            app.ManualYPosEditField.Limits = [-90 90];
            app.ManualYPosEditField.Layout.Row = 17;
            app.ManualYPosEditField.Layout.Column = [38 40];

            % Create VzmmsLabel_5
            app.VzmmsLabel_5 = uilabel(app.GridLayout);
            app.VzmmsLabel_5.HorizontalAlignment = 'center';
            app.VzmmsLabel_5.Layout.Row = 16;
            app.VzmmsLabel_5.Layout.Column = [38 40];
            app.VzmmsLabel_5.Text = 'Y Pos [mm]';

            % Create GoHomeButton
            app.GoHomeButton = uibutton(app.GridLayout, 'push');
            app.GoHomeButton.ButtonPushedFcn = createCallbackFcn(app, @GoHomeButtonButtonPushed, true);
            app.GoHomeButton.FontSize = 15;
            app.GoHomeButton.FontWeight = 'bold';
            app.GoHomeButton.Layout.Row = [18 19];
            app.GoHomeButton.Layout.Column = [35 37];
            app.GoHomeButton.Text = 'Home';

            % Create ManualMoveLabel
            app.ManualMoveLabel = uilabel(app.GridLayout);
            app.ManualMoveLabel.HorizontalAlignment = 'center';
            app.ManualMoveLabel.FontWeight = 'bold';
            app.ManualMoveLabel.Layout.Row = 15;
            app.ManualMoveLabel.Layout.Column = [35 43];
            app.ManualMoveLabel.Text = 'Manual Move';

            % Create AOIumLabel_2
            app.AOIumLabel_2 = uilabel(app.GridLayout);
            app.AOIumLabel_2.HorizontalAlignment = 'center';
            app.AOIumLabel_2.Layout.Row = 7;
            app.AOIumLabel_2.Layout.Column = [26 28];
            app.AOIumLabel_2.Text = 'Z Disabled';

                        % Create ZDistEditField
            app.ZDistEditField = uieditfield(app.GridLayout, 'numeric');
            app.ZDistEditField.ValueDisplayFormat = '%.0f';
            app.ZDistEditField.Editable = 'off';
            app.ZDistEditField.Layout.Row = 7;
            app.ZDistEditField.Layout.Column = [29 30];
            app.ZDistEditField.Value = 0;
% Create CoopModeLabel
            app.CoopModeLabel = uilabel(app.GridLayout);
            app.CoopModeLabel.HorizontalAlignment = 'center';
            app.CoopModeLabel.Layout.Row = 8;
            app.CoopModeLabel.Layout.Column = [26 28];
            app.CoopModeLabel.Text = 'Coop. Mode';

            % Create CoopModeDropDown
            app.CoopModeDropDown = uidropdown(app.GridLayout);
            app.CoopModeDropDown.Items = {'Mover Follows Robot', 'Mover Follows Path', 'Rotor Only', 'Mover Only'};
            app.CoopModeDropDown.ItemsData = [1 2 3 4];
            app.CoopModeDropDown.Layout.Row = 8;
            app.CoopModeDropDown.Layout.Column = [29 35];
            app.CoopModeDropDown.Value = 2;

            % Create NavModeLabel
            app.NavModeLabel = uilabel(app.GridLayout);
            app.NavModeLabel.HorizontalAlignment = 'center';
            app.NavModeLabel.Layout.Row = 9;
            app.NavModeLabel.Layout.Column = [26 28];
            app.NavModeLabel.Text = 'Nav. Mode';

                        % Create NavModeDropDown
            app.NavModeDropDown = uidropdown(app.GridLayout);
            app.NavModeDropDown.Items = {'Tumbling', 'Helical 45°', 'Helical 90°', 'Helical 135°', 'Steering Only', 'Swing'};
            app.NavModeDropDown.ItemsData = [1 2 3 4 5 6];
            app.NavModeDropDown.Layout.Row = 9;
            app.NavModeDropDown.Layout.Column = [29 33];
            app.NavModeDropDown.Value = 1;

            % Create SwingAngleEditFieldLabel
            app.SwingAngleEditFieldLabel = uilabel(app.GridLayout);
            app.SwingAngleEditFieldLabel.HorizontalAlignment = 'center';
            app.SwingAngleEditFieldLabel.Layout.Row = 10;
            app.SwingAngleEditFieldLabel.Layout.Column = [21 23];
            app.SwingAngleEditFieldLabel.Text = 'Swing [deg]';

            % Create SwingAngleEditField
            app.SwingAngleEditField = uieditfield(app.GridLayout, 'numeric');
            app.SwingAngleEditField.Limits = [0 90];
            app.SwingAngleEditField.ValueDisplayFormat = '%.0f';
            app.SwingAngleEditField.Layout.Row = 10;
            app.SwingAngleEditField.Layout.Column = [24 25];
            app.SwingAngleEditField.Value = 30;

            % Create MoverZDataEditField
            app.MoverZDataEditField = uieditfield(app.GridLayout, 'numeric');
            app.MoverZDataEditField.ValueDisplayFormat = '%.3f';
            app.MoverZDataEditField.Editable = 'off';
            app.MoverZDataEditField.Layout.Row = 14;
            app.MoverZDataEditField.Layout.Column = [32 34];

            % Create ZLabel
            app.ZLabel = uilabel(app.GridLayout);
            app.ZLabel.HorizontalAlignment = 'center';
            app.ZLabel.Layout.Row = 14;
            app.ZLabel.Layout.Column = 22;
            app.ZLabel.Text = 'Z Off';

            % Create MovermmLabel
            app.MovermmLabel = uilabel(app.GridLayout);
            app.MovermmLabel.HorizontalAlignment = 'center';
            app.MovermmLabel.Layout.Row = 11;
            app.MovermmLabel.Layout.Column = [26 28];
            app.MovermmLabel.Text = 'Mover [mm]';

            % Create MoverXPosEditField
            app.MoverXPosEditField = uieditfield(app.GridLayout, 'numeric');
            app.MoverXPosEditField.ValueDisplayFormat = '%.3f';
            app.MoverXPosEditField.Editable = 'off';
            app.MoverXPosEditField.Layout.Row = 12;
            app.MoverXPosEditField.Layout.Column = [26 28];

            % Create MoverYPosEditField
            app.MoverYPosEditField = uieditfield(app.GridLayout, 'numeric');
            app.MoverYPosEditField.ValueDisplayFormat = '%.3f';
            app.MoverYPosEditField.Editable = 'off';
            app.MoverYPosEditField.Layout.Row = 13;
            app.MoverYPosEditField.Layout.Column = [26 28];

            % Create MoverZPosEditField
            app.MoverZPosEditField = uieditfield(app.GridLayout, 'numeric');
            app.MoverZPosEditField.ValueDisplayFormat = '%.3f';
            app.MoverZPosEditField.Editable = 'off';
            app.MoverZPosEditField.Layout.Row = 14;
            app.MoverZPosEditField.Layout.Column = [26 28];

            % Create PFDDistMEditFieldLabel
            app.PFDDistMEditFieldLabel = uilabel(app.GridLayout);
            app.PFDDistMEditFieldLabel.HorizontalAlignment = 'center';
            app.PFDDistMEditFieldLabel.Layout.Row = 6;
            app.PFDDistMEditFieldLabel.Layout.Column = [26 28];
            app.PFDDistMEditFieldLabel.Text = 'PFD Dist M';

            % Create PFDDistMEditField
            app.PFDDistMEditField = uieditfield(app.GridLayout, 'numeric');
            app.PFDDistMEditField.Layout.Row = 6;
            app.PFDDistMEditField.Layout.Column = [29 30];
            app.PFDDistMEditField.Value = 5;

            % Create ChiralityDropDown
            app.ChiralityDropDown = uidropdown(app.GridLayout);
            app.ChiralityDropDown.Items = {'R', 'L'};
            app.ChiralityDropDown.ItemsData = [1 2];
            app.ChiralityDropDown.Layout.Row = 9;
            app.ChiralityDropDown.Layout.Column = [34 35];
            app.ChiralityDropDown.Value = 1;

            % Create FindingHomeLabel
            app.FindingHomeLabel = uilabel(app.GridLayout);
            app.FindingHomeLabel.HorizontalAlignment = 'center';
            app.FindingHomeLabel.FontSize = 25;
            app.FindingHomeLabel.FontWeight = 'bold';
            app.FindingHomeLabel.Visible = 'off';
            app.FindingHomeLabel.Layout.Row = [10 11];
            app.FindingHomeLabel.Layout.Column = [2 19];
            app.FindingHomeLabel.Text = 'Finding Home';

            % Create KpFinishEditFieldLabel
            app.KpFinishEditFieldLabel = uilabel(app.GridLayout);
            app.KpFinishEditFieldLabel.HorizontalAlignment = 'center';
            app.KpFinishEditFieldLabel.Layout.Row = 4;
            app.KpFinishEditFieldLabel.Layout.Column = [21 23];
            app.KpFinishEditFieldLabel.Text = 'Kp Finish';

            % Create KpFinishEditField
            app.KpFinishEditField = uieditfield(app.GridLayout, 'numeric');
            app.KpFinishEditField.Layout.Row = 4;
            app.KpFinishEditField.Layout.Column = [24 25];
            app.KpFinishEditField.Value = 100;

            % Create KiFinishEditFieldLabel
            app.KiFinishEditFieldLabel = uilabel(app.GridLayout);
            app.KiFinishEditFieldLabel.HorizontalAlignment = 'center';
            app.KiFinishEditFieldLabel.Layout.Row = 4;
            app.KiFinishEditFieldLabel.Layout.Column = [26 28];
            app.KiFinishEditFieldLabel.Text = 'Ki Finish';

            % Create KiFinishEditField
            app.KiFinishEditField = uieditfield(app.GridLayout, 'numeric');
            app.KiFinishEditField.Layout.Row = 4;
            app.KiFinishEditField.Layout.Column = [29 30];

            % Create KdFinishEditFieldLabel
            app.KdFinishEditFieldLabel = uilabel(app.GridLayout);
            app.KdFinishEditFieldLabel.HorizontalAlignment = 'center';
            app.KdFinishEditFieldLabel.Layout.Row = 4;
            app.KdFinishEditFieldLabel.Layout.Column = [31 33];
            app.KdFinishEditFieldLabel.Text = 'Kd Finish';

            % Create KdFinishEditField
            app.KdFinishEditField = uieditfield(app.GridLayout, 'numeric');
            app.KdFinishEditField.Layout.Row = 4;
            app.KdFinishEditField.Layout.Column = [34 35];
            app.KdFinishEditField.Value = 10;

            % Create TumblingEditField
            app.TumblingEditField = uieditfield(app.GridLayout, 'numeric');
            app.TumblingEditField.Limits = [1 15];
            app.TumblingEditField.ValueDisplayFormat = '%.0f';
            app.TumblingEditField.Layout.Row = 8;
            app.TumblingEditField.Layout.Column = [24 25];
            app.TumblingEditField.Value = 2;

            % Create TumblingEditFieldLabel
            app.TumblingEditFieldLabel = uilabel(app.GridLayout);
            app.TumblingEditFieldLabel.HorizontalAlignment = 'center';
            app.TumblingEditFieldLabel.Layout.Row = 8;
            app.TumblingEditFieldLabel.Layout.Column = [21 23];
            app.TumblingEditFieldLabel.Text = 'Tumbling';

            % Create HelicalEditField
            app.HelicalEditField = uieditfield(app.GridLayout, 'numeric');
            app.HelicalEditField.Limits = [1 15];
            app.HelicalEditField.ValueDisplayFormat = '%.0f';
            app.HelicalEditField.Layout.Row = 9;
            app.HelicalEditField.Layout.Column = [24 25];
            app.HelicalEditField.Value = 5;

            % Create HelicalEditFieldLabel
            app.HelicalEditFieldLabel = uilabel(app.GridLayout);
            app.HelicalEditFieldLabel.HorizontalAlignment = 'center';
            app.HelicalEditFieldLabel.Layout.Row = 9;
            app.HelicalEditFieldLabel.Layout.Column = [21 23];
            app.HelicalEditFieldLabel.Text = 'Helical';

            % Create RMSpeedx05rpsLabel
            app.RMSpeedx05rpsLabel = uilabel(app.GridLayout);
            app.RMSpeedx05rpsLabel.HorizontalAlignment = 'center';
            app.RMSpeedx05rpsLabel.Layout.Row = 7;
            app.RMSpeedx05rpsLabel.Layout.Column = [21 25];
            app.RMSpeedx05rpsLabel.Text = 'RM Speed [x0.5 rps]';

            % Create IntervalLabel
            app.IntervalLabel = uilabel(app.GridLayout);
            app.IntervalLabel.HorizontalAlignment = 'center';
            app.IntervalLabel.Layout.Row = 17;
            app.IntervalLabel.Layout.Column = [26 27];
            app.IntervalLabel.Text = 'Interval';

            % Create DataIntervalEditField
            app.DataIntervalEditField = uieditfield(app.GridLayout, 'numeric');
            app.DataIntervalEditField.Limits = [1 15];
            app.DataIntervalEditField.ValueDisplayFormat = '%.0f';
            app.DataIntervalEditField.Layout.Row = 17;
            app.DataIntervalEditField.Layout.Column = [28 29];
            app.DataIntervalEditField.Value = 6;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = LSS_UpperStandalone

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end

% Evaluate cardinal spline at N+1 values for given four points and tesion.
% Uniform parameterization is used.

% P0,P1,P2 and P3 are given four points.
% T is tension.
% N is number of intervals (spline is evaluted at N+1 values).
function [xvec,yvec] = EvaluateCardinal2DAtNplusOneValues(P0,P1,P2,P3,T,N)

xvec = [];
yvec = [];

% u varies between 0 and 1.
% at u=0 cardinal spline reduces to P1.
% at u=1 cardinal spline reduces to P2.
u = 0;
[xvec(1), yvec(1)] = EvaluateCardinal2D(P0,P1,P2,P3,T,u);
du = 1/N;
for k = 1:N
    u = k * du;
    [xvec(k+1), yvec(k+1)] = EvaluateCardinal2D(P0,P1,P2,P3,T,u);
end

end

% Evaluates 2D Cardinal Spline at parameter value u
%
% INPUT
% P0,P1,P2,P3 are given four points. Each have x and y values.
% P1 and P2 are endpoints of curve.
% P0 and P3 are used to calculate the slope of the endpoints.
% T is tension (T=0 for Catmull-Rom type)
% u is parameter at which spline is evaluated
function [xt,yt] = EvaluateCardinal2D(P0,P1,P2,P3,T,u)

s = (1 - T) ./ 2;

% MC is cardinal matrix
MC = [-s,     2-s,   s-2,        s;
      2.*s,   s-3,   3-(2.*s),  -s;
      -s,     0,     s,          0;
      0,      1,     0,          0];

GHx = [P0(1); P1(1); P2(1); P3(1)];
GHy = [P0(2); P1(2); P2(2); P3(2)];

U = [u.^3, u.^2, u, 1];

xt = U * MC * GHx;
yt = U * MC * GHy;

end












