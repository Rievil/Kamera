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
        Period;    
        StatLog table;
        IP;
    end
    
    methods
        function obj=CameraObj(~)
            obj.Timer=CameraTimer(obj);
            AddLogLine(obj,[],[]);
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
        
        function Conn(obj)
            AddLogLine(obj,"ConnTime_start",0)
            tic;
            
            g = gigecam(obj.IP);
            %executeCommand(g, 'ColorTransformationResetToFactoryList')
            g.ColorTransformationAuto='continuous';
            g.AcquisitionFrameRateEnable = 'True';
            g.AcquisitionFrameRate = 1;
            g.ExposureTime = 2.5e+4;
            g.PixelFormat='BGR8';
            g.TriggerMode='off';
            obj.Driver=g;
            
            AddLogLine(obj,"ConnTime_end",toc);
        end
        
        function TestShoot(obj)            
            img=snapshot(obj.Driver);
            imshow(img);
        end
        
        function Shoot(obj)
            tic;

            obj.Image = snapshot(obj.Driver);
            obj.Filename=[obj.PhotoFolder,'\', char(sprintf('%d_Image_%s.jpg',obj.NPhoto,CameraObj.GetNow()))];
            
            AddLogLine(obj,"ShootTime",toc);
%             AddPhoto(obj,obj.Image);
            StorePhoto(obj);
            ResetDriver(obj);
        end
        
        function ResetDriver(obj)
            tic;
            
            clear obj.Driver;
            delete(obj.Driver);
            obj.Driver=[];
            
            Conn(obj);
            pause(5);
            
            AddLogLine(obj,"ResetTime",toc);
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
    end
    
    
    methods (Static)
        function nowArr=GetNow(~)
            nowArr=datetime(now,'ConvertFrom','datenum','Format','dd-MM-yyyy hh-mm-ss');
        end
    end
end