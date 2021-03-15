classdef CameraObj < handle
    properties 
        Timer;
        Namer;
        PhotoTMP cell;
        CurrPhoto;
        PhotoFolder='';
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
        
        function SetPhotoFolder(obj)
            obj.PhotoFolder = uigetdir('C:\','Select folder for storing images');
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
            snapshot(g);
        end
        
        function Shoot(obj)
            tic;
            TestShoot(obj);
            
            img = snapshot(g);
            
            AddLogLine(obj,"ShootTime",toc);
            AddPhoto(obj,img);
            StorePhoto(obj);
        end
        
        function ResetDriver(obj)
            tic;
            
            close(obj.Driver);
            delete(obj.Driver);
            Conn(obj);
            
            AddLogLine(obj,"ResetTime",toc);
        end
        
        function StorePhoto(obj)
            tic;
            if ~strcmp(obj.PhotoFolder,'')
                nowArr=char(CameraObj.GetNow);
                obj.NPhoto=obj.NPhoto+1;
                filename=[objPhotoFolder, char(sprintf('%d_Image_%s.npg',obj.NPhoto,nowArr))];
                imwrite(obj.PhotoTmp{end},filename);            
            end
            AddLogLine(obj,"StoreTime",toc);
        end
        
        function AddPhoto(obj,img)
            tic;
            obj.CurrPhoto=obj.CurrPhoto+1;
            if obj.CurrPhoto<11
                obj.PhotoTmp{obj.CurrPhoto}=img;
            else
                obj.PhotoTmp{obj.CurrPhoto}=img;
                obj.PhotoTmp{1}=[];
                obj.CurrPhoto=obj.CurrPhoto-1;
            end
            AddLogLine(obj,"MemSaveTime",toc);
        end                
    end
    
    
    methods (Static)
        function nowArr=GetNow(~)
            nowArr=datetime(now,'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss.ss');
        end
    end
end