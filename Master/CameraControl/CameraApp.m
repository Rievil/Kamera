classdef CameraApp < GenApp
    %CAMERAAPP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WinDim=[900,400];
        ImAxes;
        TimeLinesAxes;
        LightBool=false;
        StartDate;
        DateStartSet;
        HourStartSet=0;
        MinutesStartSet=0;
        FinStartDateTime;
    end
    
    methods
        function obj = CameraApp(parent)
            obj@GenApp(parent);
        end
        

    end
    
    
    methods %abstract
        function AppDrawGui(obj)
            g = uigridlayout(obj.UIFig);
            g.RowHeight = {450,'1x','1x'};
            g.ColumnWidth = {250,'2x'};
            
            p1=uipanel(g,'Title','Controls');
            p1.Layout.Row=1;
            p1.Layout.Column=1;
            
            p2 = uiimage(g);
            p2.Layout.Row=[1 2];
            p2.Layout.Column=2;
            obj.ImAxes=p2;
            
            p3=uiaxes(g);
            p3.Layout.Row=3;
            p3.Layout.Column=2;
            obj.TimeLinesAxes=p3;
            
            p4=uipanel(g,'Title','Scheduler');
            p4.Layout.Row=[2 3];
            p4.Layout.Column=1;
            
            DrawControls(obj,p1);
            DrawScheduler(obj,p4);
        end
        
        function DrawControls(obj,pan)
            g = uigridlayout(pan);
            g.RowHeight = {50,50,25,25,'1x'};
            g.ColumnWidth = {25,'1x',100};
            
            but1=uibutton(g,'Text','Shoot',...
                'ButtonPushedFcn',@obj.MShoot);
            but1.Layout.Row=1;
            but1.Layout.Column=[1 3];
            
           	if obj.Device.Arduino.StateBool
                lightstate='Light on';
            else
                lightstate='Light off';
            end
            
            sw = uiswitch(g,'ValueChangedFcn',@obj.MTurnLight,'Items',{'Light off','Light on'},...
                'Value',lightstate);
            sw.Layout.Row=2;
            sw.Layout.Column=[2 3];
            
            efi= uieditfield(g,'numeric',...
                      'Limits', [1 50e+3],...
                      'LowerLimitInclusive','off',...
                      'UpperLimitInclusive','on',...
                      'Value', obj.Device.ExpTime,...
                      'ValueChangedFcn',@obj.MChangeExposureTime);
            efi.Layout.Row=3;
            efi.Layout.Column=3;
            
            l1=uilabel(g,'Text','Exposure time [us]:');
            l1.Layout.Row=3;
            l1.Layout.Column=[1 2];
            
            l2=uieditfield(g,'text','Editable','off');
            l2.Layout.Row=4;
            l2.Layout.Column=3;
            
            but2=uibutton(g,'Text','Pick folder',...
                'ButtonPushedFcn',@obj.MSelectFolder,'UserData',{l2});
            but2.Layout.Row=4;
            but2.Layout.Column=[1 2];
        end
        
        function DrawScheduler(obj,pan)
            g = uigridlayout(pan);
            g.RowHeight = {50,50,25,'1x'};
            g.ColumnWidth = {25,'1x',50,50};
            
            lb1=uilabel(g,'Text','Start date:');
            lb1.Layout.Row=1;
            lb1.Layout.Column=[1 2];
            
            nowvar=datetime(now(),'ConvertFrom','datenum','Format','dd-MM-yyyy');
            if isempty(obj.StartDate)
                obj.StartDate=nowvar;
            else
                obj.StartDate=obj.FinStartDateTime;
            end
                
            
            d = uidatepicker(g,'DisplayFormat','dd-MM-yyyy','Value',obj.StartDate,...
                'ValueChangedFcn',@obj.MStartDateSet);
            d.Layout.Row=1;
            d.Layout.Column=[3 4];
            
            lb1=uilabel(g,'Text','Start time:');
            lb1.Layout.Row=2;
            lb1.Layout.Column=[1 2];
            
            efH= uieditfield(g,'numeric',...
                      'Limits', [0 23],...
                      'Value', obj.HourStartSet,...
                      'ValueChangedFcn',@obj.MHoursSet);
                  
            efH.Layout.Row=2;
            efH.Layout.Column=3;
            
            efM= uieditfield(g,'numeric',...
                      'Limits', [0 59],...
                      'Value', obj.MinutesStartSet,...
                      'ValueChangedFcn',@obj.MMinutesSet);
            efM.Layout.Row=2;
            efM.Layout.Column=4;
            
            
            
        end
        
        function MakeStartDate(obj)
            obj.FinStartDateTime=obj.StartDate+hours(obj.HourStartSet)+minutes(obj.MinutesStartSet);
        end
        
    end
    
    
    methods %callbacks
        function MShoot(obj,src,evnt)
            img=GetCurrentImage(obj.Device);
            obj.ImAxes.ImageSource =img;

        end
        
        function MSelectFolder(obj,src,~)
            selpath = uigetdir;
            if exist(selpath)
                src.UserData{1}.Value=selpath;
            end
        end
        
        function MStartDateSet(obj,src,~)
            obj.DateStartSet=src.Value;
            MakeStartDate(obj);
        end
        
        function MHoursSet(obj,src,~)
            obj.HourStartSet=src.Value;
            MakeStartDate(obj);
        end
        
        function MMinutesSet(obj,src,~)
            obj.MinutesStartSet=src.Value;
            MakeStartDate(obj);
        end
        
        function MChangeExposureTime(obj,src,~)
            obj.Device.ExpTime=src.Value;
            obj.Device.ChangeSettings;
        end
        
        function MTurnLight(obj,~,~)
            obj.LightBool=~obj.LightBool;
            
            if obj.LightBool
                obj.Device.LightUp;
            else
                obj.Device.GoDark;
            end
        end
    end
end

