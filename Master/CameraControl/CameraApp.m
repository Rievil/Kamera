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
            obj.Session.Save;
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
            DrawGui(obj.Session);
            CheckForOpenSession(obj.Session);
            
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
            g.RowHeight = {50,50,'1x',25,25};
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
            
            if size(obj.Session.SchedTable,1)==0
                obj.Session.SchedTable=GetSchedRow(obj.Session);
            end
            
            uit=uitable(g,'Data',obj.Session.SchedTable,'ColumnWidth',{80,'1x',80,'1x'},...
            'ColumnEditable',[true true true true],...
                'CellEditCallback',@obj.MSetSchTable);
            uit.Layout.Row=3;
            uit.Layout.Column=[1 4];
            obj.Session.UISTable=uit;
            
            lb1=uilabel(g,'Text','Parts');
            lb1.Layout.Row=4;
            lb1.Layout.Column=[1 2];
            
            spin = uispinner(g,'Limits', [1 10],'ValueChangedFcn',@obj.MSchedulerRowChange);
            spin.Layout.Row=4;
            spin.Layout.Column=[3 4];
            
            PlotScheduler(obj);
            
        end
        
        
        
        function DrawMissingImage(obj)
            I=zeros(300,300);
            I = insertText(I,[150,150],'Missing image','AnchorPoint','center','FontSize',16);
            obj.ImAxes.ImageSource =I;
        end
        
        function MakeStartDate(obj)
            obj.FinStartDateTime=obj.DateStartSet+hours(obj.HourStartSet)+minutes(obj.MinutesStartSet);
        end
        
        function T=MakeSchedule(obj)
            T0=obj.Session.SchedTable;
            schcount=size(T0,1);
            T=table;
            if schcount>0
                for i=1:schcount
                    T=[T; table(GetTimeVar(obj,char(T0.LengthType(i)),T0.nL(i)),...
                        GetTimeVar(obj,char(T0.PeriodType(i)),T0.nP(i)),'VariableNames',{'Len','Per'})];
                end
            end
            
            
        end
        
        function PlotScheduler(obj)
            ax=obj.TimeLinesAxes;
            hold(ax,'on');
            grid(ax,'on');
            cla(ax);
            T=MakeSchedule(obj);
            MakeStartDate(obj);
            x=[];
            y2=[];
            nowar=datetime(now(),'ConvertFrom','datenum');
            for i=1:size(T,1)
                len=seconds(T.Len(i));
                per=seconds(T.Per(i));

                count=len/per;
                time=linspace(per,per*count,count);
                period=linspace(per,per,count);

                y2=[y2; period'];

                if i>1
                    time=time+x(end);
                    x=[x; time'];
                else
                    x=[x; time'];
                end
            end

            x=[0; x];
            
            
            y2=[0; y2];
            x=seconds(x)+obj.FinStartDateTime;
            y=1:1:numel(x);
            y=y';

            scatter(ax,x,y,'o');
            plot(ax,[nowar nowar],[0 max(y)],'r-');
            ylabel(ax,'Photo count');
            xlabel(ax,'Time');
            ylim(ax,[min(y),max(y)]);
            xlim(ax,[min(x)-hours(1), max(x)+hours(1)]);
            datetick(ax,'x','yyyy-mm-dd','keeplimits')
%             xlim(ax,[nowar,nowar+days(1)]);
        end
        
        
        function val=GetTimeVar(obj,type,count)
            
            switch lower(char(type))
                case 'minute'
                    val=minutes(count);
                case 'hour'
                    val=hours(count);
                case 'day'
                    val=hours(count*24);
                case 'week'
                    val=hours(count*24*7);
            end
        end
        
    end
    
    
    methods %callbacks
        
        function MSetSchTable(obj,src,evnt)
            obj.Session.SchedTable=src.Data;
            PlotScheduler(obj);
        end
        
        function MSchedulerRowChange(obj,src,~)
            if src.Value>size(obj.Session.SchedTable,1)
                AddSchRow(obj.Session);
            elseif src.Value<size(obj.Session.SchedTable,1)
                RemoveSchRow(obj.Session);
            end
            obj.Session.UISTable.Data=obj.Session.SchedTable;
            PlotScheduler(obj);
        end
        
        
        function MShoot(obj,src,evnt)
            img=GetCurrentImage(obj.Device);
            obj.ImAxes.ImageSource =img;
            %AddImage(obj,img,desc,state,source,note)
            desc=struct;
            desc.Exposure=obj.Device.ExpTime;
            AddImage(obj.Session,img,desc,'InMem','Manual','desc');

        end
        
        function MSelectFolder(obj,src,~)
            selpath = uigetdir;
            if exist(selpath)
                src.UserData{1}.Value=selpath;
                SetFolder(obj.Session,selpath);
                SetPhotoFolder(obj.Device,selpath);
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

