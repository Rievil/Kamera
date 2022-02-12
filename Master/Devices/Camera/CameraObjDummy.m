classdef CameraObjDummy < Device
    properties 
        Timer;
        Namer;
        PhotoTMP cell;
        CurrPhoto=0;
        PhotoFolder='';
        Image;
        Filename="";
        NPhoto=0;
        Driver;
        VSrc;
        Period=10;    
        StatLog table;
        IP;
        Arduino;
        
        TimerRunning=0;
        UIAxes;
        ExpTime=2500;
        ImgNum=0;
    end
    
    methods
        function obj=CameraObjDummy(parent)
            obj@Device(parent);
            
            obj.Timer=CameraTimer(obj);
            AddLogLine(obj,[],[]);

            %--------------------------------------------------------------
            obj.Arduino=ArduinoObjDummy(obj);
            %--------------------------------------------------------------
        end
        
        function SetPhotoFolder(obj,path)
            if path
                obj.PhotoFolder=path;
            else
                obj.PhotoFolder = uigetdir('C:\','Select folder for storing images');
            end
            
            if exist(obj.PhotoFolder)
                CheckForSession(obj)
            end
        end
        
        function CheckForSession(obj)
            statfilename=[char(obj.PhotoFolder) '\Statlog.xlsx'];
            if exist(statfilename)
                T=readtable(statfilename);
                obj.StatLog=T;
            end
        
        end

        function StartTimerShoot(obj)
            TestStart(obj.Timer);
            obj.TimerRunning=1;
        end
        
        function AddLogLine(obj,name,duration)
            nowArr=CameraObj.GetNow;
            if isempty(obj.StatLog)
                
                obj.StatLog=table(1,nowArr,obj.Filename,"StartUp",0,'VariableNames',{'N','DateTime','FileName','Name','Duration'});
            else
                t=table(max(obj.StatLog{:,1})+1,...
                    nowArr-seconds(duration),name,obj.Filename,duration,'VariableNames',{'N','DateTime','FileName','Name','Duration'});
                obj.StatLog=[obj.StatLog; t];
            end
        end
        
        function FindCamera(obj)
            tic;
            list=gigecamlist;
            obj.IP=char(char(list.IPAddress(1)));

            AddLogLine(obj,"FindTime",toc);
        end
        
        function Conn(obj)
            if ~obj.IsRunning
                obj.IsRunning=true;
                AddLogLine(obj,"ConnTime",toc);
                disp('Device ready');
            else
                disp('Device is already running.');
            end
        end
        
        function ChangeSettings(obj)
            tic;
            
            obj.VSrc.ColorTransformationFactoryListSelector='OptimizedMatrixFor3000K';
            obj.VSrc.ColorTransformationAuto='off';
%             obj.VSrc.ColorTransformationValue=1;
            
            
            obj.VSrc.AcquisitionFrameRateEnable = 'True';
            obj.VSrc.AcquisitionFrameRate = 2;
            obj.VSrc.ExposureTime = obj.ExpTime;
            
            
            obj.VSrc.Gain=1;
            disp('Settings changed');
            AddLogLine(obj,"SettingsChange",toc);
        end
        
        function LightUp(obj)
            OpenConnection(obj.Arduino);
            LightUp(obj.Arduino);
        end
        
        function GoDark(obj)
            OpenConnection(obj.Arduino);
            GoDark(obj.Arduino);
        end

        
        function TestShoot(obj)            

%             if ~obj.Arduino.Connected
            OpenConnection(obj.Arduino);
%             end

            LightUp(obj.Arduino);
            obj.Image = GetDummySnapshot(obj);  
            
            GoDark(obj.Arduino);
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
        
        function img=GetCurrentImage(obj)
            img=GetDummySnapshot(obj);  
%             AddPhoto(obj,img);
        end
        
        function I = GetDummySnapshot(obj)
            obj.ImgNum=obj.ImgNum+1;
            I=zeros(300,300);
            I = insertText(I,[150,150],sprintf("Dummy image %d",obj.ImgNum),'AnchorPoint','center','FontSize',16);
        end

        function Shoot(obj)
            tic;
            try
                
                obj.Filename=[obj.PhotoFolder,'\', char(sprintf('%d_Image_%s.png',obj.NPhoto,CameraObj.GetNow()))];
                OpenConnection(obj.Arduino);
                LightUp(obj.Arduino);
                
                obj.Image = GetDummySnapshot(obj);  
                
                disp('-----Image succesfully stored----:-)');
                
                GoDark(obj.Arduino);
                
                pause(1);
                AddLogLine(obj,"ShootTime",toc);

                StorePhoto(obj);

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
            obj.obj.IsRunning=false;
            tic;
            disp('Reseting driver...');
            delete(obj.Driver);
            obj.VSrc=[];
            
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
            image(obj.Image,'Parent',obj.UIAxes); 
            set(obj.UIAxes,'visible','on');
            
            sz=size(obj.Image(:,:,1));
            
            xlim(obj.UIAxes,[0 sz(2)]);
            ylim(obj.UIAxes,[0 sz(1)]);
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

        function list=GetDeviceList(obj)
            %-----------------

            list=table("Dummy camera object","IP");
            obj.DeviceList=list;
        end
        
        
        function Connect(obj)
            obj.IP=obj.DeviceList.IP(obj.DeviceListRow);
            AddLogLine(obj,"FindTime",toc);
            
        end
        
        function StartDevice(obj)
            Conn(obj);        
            OpenConnection(obj.Arduino);
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