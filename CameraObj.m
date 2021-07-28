classdef CameraObj < Device
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
        VSrc;
        Period=10;    
        StatLog table;
        IP;
        Arduino;
        TimerRunning=0;
        UIAxes;
    end
    
    methods
        function obj=CameraObj(parent)
            obj@Device(parent);
            
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
%             obj.Driver=videoinput('gige', 1, 'BGR8');;
%             vidobj = videoinput('gige', 1, 'BGR8');
            list=gigecamlist;
            obj.IP=char(char(list.IPAddress(1)));

            AddLogLine(obj,"FindTime",toc);
        end
        
        function Conn(obj)
            tic;
            
            obj.Driver = videoinput('gige', 1, 'BGR8');
            obj.VSrc= getselectedsource(obj.Driver);
            
            ChangeSettings(obj);
            
            AddLogLine(obj,"ConnTime",toc);
            disp('Device ready');
        end
        
        function ChangeSettings(obj)
            tic;
            
            obj.VSrc.ColorTransformationFactoryListSelector='OptimizedMatrixFor3000K';
            obj.VSrc.ColorTransformationAuto='off';
%             obj.VSrc.ColorTransformationValue=1;
            
            
            obj.VSrc.AcquisitionFrameRateEnable = 'True';
            obj.VSrc.AcquisitionFrameRate = 2;
            obj.VSrc.ExposureTime = 2500;
            
            
            obj.VSrc.Gain=1;
            disp('Settings changed');
            AddLogLine(obj,"SettingsChange",toc);
        end
        

        
        function TestShoot(obj)            

%             if isvalid(obj.Arduino)
            OpenConnection(obj.Arduino);
%             end
            LightUp(obj.Arduino);
            obj.Image = getsnapshot(obj.Driver);  
            
            GoDark(obj.Arduino);
            pause(1);
            CloseConnection(obj.Arduino);
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
                if isvalid(obj.Arduino)
                    OpenConnection(obj.Arduino);
                end
                LightUp(obj.Arduino);
%                 snapshot = getsnapshot(vidobj);
                obj.Image = getsnapshot(obj.Driver);              
                disp('-----Image succesfully stored----:-)');
                GoDark(obj.Arduino);
                pause(1);
                AddLogLine(obj,"ShootTime",toc);
    %             AddPhoto(obj,obj.Image);
                StorePhoto(obj);
                CloseConnection(obj.Arduino);
%                 ResetDriver(obj);
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
%             delete(obj.VSrc);
            obj.VSrc=[];
%             obj.Driver=[];
%             clear obj.Driver;
            
            AddLogLine(obj,"ResetTime",toc);
            obj.Image=[];
            pause(1);
            Conn(obj);

        end
        
        function SetSchedule(obj,length,period)
            SetSpecificTimes(obj.Timer,length,period)
        end
        
        function ResetTimer(obj)
            Stop(obj.Timer);
            ClearTimer(obj.Timer);   
            obj.TimerRunning=0;
        end
        
        function UIDrawImage(obj)
%             h=app.CamObj.AutoFeatureHeight;
%             w=app.CamObj.AutoFeatureWidth;
%             
%             hImage = image(app.UIAxes,zeros(h , w, 3)); 
% %             pause(5);
%             
%             if w>h
%                 r=double(h)/double(w);
%             else
%                 r=double(w)/double(h);
%             end
%             %ax=axis;
%             %fig=gcf;
%             app.UIAxes.Xlim=[0 w];
%             app.UIAxes.Ylim=[0 h];
%             pbaspect(app.UIAxes,[1 r 1]);
%             preview(app.CamObj,hImage);
            image(obj.Image,'Parent',obj.UIAxes);
%             image(RGB,'Parent',ax);    
            set(obj.UIAxes,'visible','on');
            sz=size(obj.Image(:,:,1));
            xlim(obj.UIAxes,[0 sz(2)]);
            ylim(obj.UIAxes,[0 sz(1)]);
            %app.UIAxes.Layer ='top';
            %app.UIAxes='on';
            %app.UIAxes.Grid
            %grid on;
            %set(fig,'position',[417 272 1086 701]);
        end
        
        function UIPreview(obj)
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
    
    methods %abstract

        function list=ListDevices(obj)
            list=gigecamlist;
            obj.DeviceList=list;
        end
        
        
        function Connect(obj)
            obj.IP=obj.DeviceList.IP(obj.DeviceListRow);
            AddLogLine(obj,"FindTime",toc);
            
        end
        
        function StartDevice(obj)
            Conn(obj);            
        end
        
        function DrawGui(obj)
            g=uigridlayout(obj.Fig);
            g.RowHeight = {25,'1x'};
            g.ColumnWidth = {75,'1x'};
            
            uia=uiaxes(g,'XLimMode','manual','YLimMode','manual');
            uia.Layout.Row=2;
            uia.Layout.Column=[1 2];
            
            obj.UIAxes=uia;
            axis(obj.UIAxes, 'tight');
            bu1=uibutton(g,'Text','Shoot','ButtonPushedFcn',@obj.MUIShoot);
            bu1.Layout.Row=1;
            bu1.Layout.Column=1;
            
        end
    end
    
    methods %callbacks
        function MUIShoot(obj,src,~)
            TestShoot(obj);
            UIDrawImage(obj);
        end
    end
    
    
    methods (Static)
        function nowArr=GetNow(~)
            nowArr=datetime(now,'ConvertFrom','datenum','Format','dd-MM-yyyy hh-mm-ss');
        end
    end
end