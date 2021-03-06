classdef CameraObj < handle
    properties 
        Timer;
        Namer;
        PhotoTMP cell;
        CurrPhoto=0;
        PhotoFolder='';
        Image;
        Filename;
        NPhoto=0;
        Driver;
        Period=10;    
        StatLog table;
        IP;
        Arduino;
        TimerRunning=0;
    end
    
    methods
        function obj=CameraObj(~)
            obj.Timer=CameraTimer(obj);
            AddLogLine(obj,[],[]);
            obj.Arduino=ArduinoObj(obj);
        end
        
        function SetPhotoFolder(obj,path)
            if path
                obj.PhotoFolder=path;
            else
                obj.PhotoFolder = uigetdir('C:\','Select folder for storing images');
            end
        end

        function StartTimerShoot(obj)
            TestStart(obj.Timer);
            obj.TimerRunning=1;
        end
        
        function AddLogLine(obj,name,duration)
            nowArr=CameraObj.GetNow;
            if isempty(obj.StatLog)
                
                obj.StatLog=table(1,nowArr,"StartUp",0,'VariableNames',{'N','DateTime','Name','Duration'});
            else
                t=table(max(obj.StatLog{:,1})+1,...
                    nowArr-seconds(duration),name,duration,'VariableNames',{'N','DateTime','Name','Duration'});
                obj.StatLog=[obj.StatLog; t];
            end
        end
        
        function FindCamera(obj)
            tic;
            
            list=gigecamlist;
            obj.IP=char(char(list.IPAddress(1)));

            AddLogLine(obj,"FindTime",toc);
            
        end
        
        function ChangeSettings(obj)
            tic;
            obj.Driver.ColorTransformationAuto='off';
            obj.Driver.BalanceWhiteAuto='off';
%             g.BalanceWhite='off';
            obj.Driver.AcquisitionFrameRateEnable = 'True';
            obj.Driver.AcquisitionFrameRate = 2;
            obj.Driver.ExposureTime = 5e+4;
            obj.Driver.PixelFormat='BGR8';
            obj.Driver.TriggerMode='off';
            obj.Driver.DeviceLinkHeartbeatTimeout=600000;
            obj.Driver.TimerDelay = 0;
            obj.Driver.TimerDuration = 100; %this is is usec, and must be 100'!!
            obj.Driver.Timeout=20;
            obj.Driver.CounterDuration=1;
%             g.DeviceLinkThroughputLimit=125000000;

%             executeCommand(obj.Driver, 'CounterReset');
%             executeCommand(obj.Driver, 'TimestampReset');
            executeCommand(obj.Driver, 'TimestampLatch');
            disp('Settings changed');
            AddLogLine(obj,"SettingsChange",toc);
        end
        
        function Conn(obj)
            tic;
            
            obj.Driver = gigecam(obj.IP);
            
            ChangeSettings(obj);
            
            AddLogLine(obj,"ConnTime",toc);
            disp('Device ready');
        end
        
        function TestShoot(obj)            
            img=snapshot(obj.Driver);
            imshow(img);
        end
        
        function SetTimer(obj,varargin)
            Set(obj.Timer,varargin);
        end
        
        function Preview(obj)
            OpenConnection(obj.Arduino);
            LightUp(obj.Arduino);
            preview(obj.Driver);
        end
        
        function EndPreview(obj)
            closePreview(obj.Driver);
            GoDark(obj.Arduino);
            CloseConnection(obj.Arduino);
            ResetDriver(obj);
        end
        
        function Shoot(obj)
            tic;
            try
                
                obj.Filename=[obj.PhotoFolder,'\', char(sprintf('%d_Image_%s.png',obj.NPhoto,CameraObj.GetNow()))];
%                 obj.Filename=[obj.PhotoFolder,'\', char(sprintf('%d_Image_%s.png',obj.NPhoto,obj.Timer.NextTime))];
                OpenConnection(obj.Arduino);
                LightUp(obj.Arduino);
                
                obj.Image = snapshot(obj.Driver);              
                disp('-----Image succesfully stored----:-)');
                GoDark(obj.Arduino);
                pause(1);
                AddLogLine(obj,"ShootTime",toc);
    %             AddPhoto(obj,obj.Image);
                StorePhoto(obj);
                CloseConnection(obj.Arduino);
                ResetDriver(obj);
            catch ME
               
                warning('Image wasnt stored');
                disp(ME.message);
                GoDark(obj.Arduino);
                AddLogLine(obj,"ShootTimeError",toc);
                CloseConnection(obj.Arduino);
                ResetDriver(obj);                
            end
            
        end
        
        function ResetDriver(obj)
            %16 seconds
            tic;
            disp('Reseting driver...');
            delete(obj.Driver);
%             obj.Driver=[];
%             clear obj.Driver;
            
            AddLogLine(obj,"ResetTime",toc);
            obj.Image=[];
            pause(1);
            Conn(obj);

        end
        
        function ResetTimer(obj)
            Stop(obj.Timer);
            ClearTimer(obj.Timer);   
            obj.TimerRunning=0;
        end
        
        function StorePhoto(obj)
            tic;
            if ~strcmp(obj.PhotoFolder,'')
                obj.NPhoto=obj.NPhoto+1;
                imwrite(obj.Image,obj.Filename);            
            end
            AddLogLine(obj,"StoreTime",toc);
        end
        
        function AddPhoto(obj,img)
            tic;
            
            obj.CurrPhoto=obj.CurrPhoto+1;
            
            
            if obj.CurrPhoto<11
                obj.PhotoTMP{obj.CurrPhoto}={img};
            else
                obj.PhotoTMP{obj.CurrPhoto}={img};
                obj.PhotoTMP{1}=[];
                obj.CurrPhoto=obj.CurrPhoto-1;
            end
            AddLogLine(obj,"MemSaveTime",toc);
        end   
        
        function SaveLog(obj)
            writetable(obj.StatLog,[obj.PhotoFolder '\Statlog.xlsx']);
        end
        
        function delete(obj)
            delete(obj.Driver);
        end
    end
    
    
    methods (Static)
        function nowArr=GetNow(~)
            nowArr=datetime(now,'ConvertFrom','datenum','Format','dd-MM-yyyy hh-mm-ss');
        end
    end
end