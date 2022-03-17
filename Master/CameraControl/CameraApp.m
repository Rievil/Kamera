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
        Session;
        SchedTable table;
        UISTable;
        UIHours;
        UIMinutes;
        UIDatePicker;
        UISpinner;
    end
    
    methods
        function obj = CameraApp(parent)
            obj@GenApp(parent);
            obj.Session=Session(obj);
        end
        
        function UpdateImage(obj,img)
            if obj.UIFigBool
                obj.ImAxes.ImageSource =img;
            end
        end
    end
    
    
    methods %abstract
        function CloseChild(obj)
%             obj.Session.Save;
        end
        
        
        
        function AppDrawGui(obj)
            g = uigridlayout(obj.UIFig);
            g.RowHeight = {'1x','1x','1x'};
            g.ColumnWidth = {250,300,'1x'};
            
            p1=uipanel(g,'Title','Controls');
            p1.Layout.Row=1;
            p1.Layout.Column=1;
            
            p2 = uiimage(g);
            p2.Layout.Row=[1 2];
            p2.Layout.Column=3;
            obj.ImAxes=p2;
            
            p3=uiaxes(g);
            p3.Layout.Row=3;
            p3.Layout.Column=3;
            obj.TimeLinesAxes=p3;
            
            p4=uipanel(g,'Title','Scheduler');
            p4.Layout.Row=[2 3];
            p4.Layout.Column=1;
            
            p5=uipanel(g,'Title','Image panel');
            p5.Layout.Row=[1 3];
            p5.Layout.Column=2;
            
            DrawControls(obj,p1);
           
            
            SetFig(obj.Session,p5);

            CheckForOpenSession(obj.Session);  

            DrawGui(obj.Session);
                      
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
%             obj.LightBool=obj.Device.Arduino.StateBool;
            
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
            
            if obj.Session.Init
                path=obj.Session.Folder;
                SetPhotoFolder(obj.Device,path);
            else
                path="";
            end
            
            l2=uieditfield(g,'text','Editable','off','Value',path);
            l2.Layout.Row=4;
            l2.Layout.Column=3;
            
            but2=uibutton(g,'Text','Pick folder',...
                'ButtonPushedFcn',@obj.MSelectFolder,'UserData',{l2});
            but2.Layout.Row=4;
            but2.Layout.Column=[1 2];
            
     
            
        end
        
        function DrawScheduler(obj,pan)
            
            g = uigridlayout(pan);
            g.RowHeight = {50,50,50,'1x',25,30};
            g.ColumnWidth = {25,'1x',50,50};
            
            uib1=uibutton(g,'Text','Run scheduler','ButtonPushedFcn',@obj.MRunScheduler);
            uib1.Layout.Row=1;
            uib1.Layout.Column=[1 2];
            
            uib1=uibutton(g,'Text','Stop Scheduler','ButtonPushedFcn',@obj.MStopScheduler);
            uib1.Layout.Row=1;
            uib1.Layout.Column=[3 4];
            
            lb1=uilabel(g,'Text','Start date:');
            lb1.Layout.Row=2;
            lb1.Layout.Column=[1 2];
                        
            d = uidatepicker(g,'DisplayFormat','dd-MM-yyyy','Value',obj.Session.StartDate,...
                'ValueChangedFcn',@obj.MStartDateSet);

            d.Layout.Row=2;
            d.Layout.Column=[3 4];
            obj.UIDatePicker=d;

            lb1=uilabel(g,'Text','Start time:');
            lb1.Layout.Row=3;
            lb1.Layout.Column=[1 2];
            
            efH= uieditfield(g,'numeric',...
                      'Limits', [0 23],...
                      'Value', obj.Session.HourStartSet,...
                      'ValueChangedFcn',@obj.MHoursSet);
                  
            efH.Layout.Row=4;
            efH.Layout.Column=3;
            obj.UIHours=efH;

            efM= uieditfield(g,'numeric',...
                      'Limits', [0 59],...
                      'Value', obj.Session.MinutesStartSet,...
                      'ValueChangedFcn',@obj.MMinutesSet);
            efM.Layout.Row=3;
            efM.Layout.Column=4;
            obj.UIMinutes=efM;

            if size(obj.Session.SchedTable,1)==0
                obj.Session.SchedTable=GetSchedRow(obj.Session);
            end
            
            uit=uitable(g,'Data',obj.Session.SchedTable,'ColumnWidth',{80,'1x',80,'1x'},...
            'ColumnEditable',[true true true true],...
                'CellEditCallback',@obj.MSetSchTable);
            uit.Layout.Row=4;
            uit.Layout.Column=[1 4];

            obj.UISTable=uit;
            
            lb1=uilabel(g,'Text','Parts');
            lb1.Layout.Row=5;
            lb1.Layout.Column=[1 2];
            
            spin = uispinner(g,'Limits', [1 10],'ValueChangedFcn',@obj.MSchedulerRowChange);
            spin.Layout.Row=5;
            spin.Layout.Column=[3 4];
            obj.UISpinner=spin;
            
            uib1=uibutton(g,'Text','Generate schedule','ButtonPushedFcn',@obj.MGenerateSchedule);
            uib1.Layout.Row=6;
            uib1.Layout.Column=[1 4];
            
            PlotScheduler(obj);
            
        end
        
        
        
        function DrawMissingImage(obj)
            I=zeros(300,300,3);
%             I = insertText(I,[150,150],'Missing image','AnchorPoint','center','FontSize',16);
            obj.ImAxes.ImageSource =I;
        end


        
        function RunScheduler(obj)
%             DrawSchedule(obj.Session,obj.Device.ExpTime);
%             UpdateUITable(obj.Session);
        end
        
        function PlotScheduler(obj)
            ax=obj.TimeLinesAxes;
            hold(ax,'on');
            grid(ax,'on');
            cla(ax);
            
            nowar=datetime(now(),'ConvertFrom','datenum','Format','HH:mm:ss dd.MM.yyyy');

            Tout=CreatePlan(obj.Session);
            
            x=Tout.Time;
            y=Tout.Count;

            scatter(ax,x,y,'.');
            plot(ax,[nowar nowar],[0 max(y)],'r-');
            
            x2=[nowar; x];
            if nowar>max(x)
                text(ax,nowar-hours(1),max(y)*0.8,sprintf('Current time %s',nowar),'Color','r',...
                'HorizontalAlignment','right');
            else
                text(ax,nowar+hours(1),max(y)*0.8,sprintf('Current time %s',nowar),'Color','r',...
                'HorizontalAlignment','left');
            end

            ylabel(ax,'Photo count');
            xlabel(ax,'Time');
            ylim(ax,[min(y),max(y)]);
            xlim(ax,[min(x2)-hours(2), max(x2)+hours(2)]);
            datetick(ax,'x','yyyy-mm-dd','keeplimits')
        end
    end
    
    
    methods %callbacks

        
        function MStopScheduler(obj,src,evnt)
            StopScheduleShooting(obj.Session);
        end
        
        function MRunScheduler(obj,src,evnt)
            StartScheduleShooting(obj.Session);
        end
        
        function MGenerateSchedule(obj,src,evnt)
            DrawSchedule(obj.Session,obj.Device.ExpTime);
            UpdateUITable(obj.Session);
        end
        
        function MSetSchTable(obj,src,evnt)
            obj.Session.SchedTable=src.Data;
            MakeStartDate(obj.Session);
            PlotScheduler(obj);
        end
        
        function MSchedulerRowChange(obj,src,~)
            if src.Value>size(obj.Session.SchedTable,1)
                AddSchRow(obj.Session);
            elseif src.Value<size(obj.Session.SchedTable,1)
                RemoveSchRow(obj.Session);
            end
            obj.UISTable.Data=obj.Session.SchedTable;
            MakeStartDate(obj.Session);
            PlotScheduler(obj);
        end
        
        
        function MShoot(obj,src,evnt)
            img=GetCurrentImage(obj.Device);
            obj.ImAxes.ImageSource =img;
            date=datetime(now,'ConvertFrom','datenum','Format','dd-MM-yyyy HH-mm-ss');
            AddImage(obj.Session,img,date,obj.Device.ExpTime,"InMem","Manual","desc");
            UpdateUITable(obj.Session);
        end
        
        function MSelectFolder(obj,src,~)
            selpath = uigetdir;
            if numel(selpath)>1
                if exist(selpath)
                    src.UserData{1}.Value=selpath;
                    SetFolder(obj.Session,selpath);
                    SetPhotoFolder(obj.Device,selpath);
                end
            end
        end
        
        function MStartDateSet(obj,src,~)
            obj.Session.StartDate=src.Value;
            MakeStartDate(obj.Session);
            PlotScheduler(obj);
        end
        
        function MHoursSet(obj,src,~)
            obj.Session.HourStartSet=src.Value;
            MakeStartDate(obj.Session);
            PlotScheduler(obj);
        end
        
        function MMinutesSet(obj,src,~)
            obj.Session.MinutesStartSet=src.Value;
            MakeStartDate(obj.Session);
            PlotScheduler(obj);
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

