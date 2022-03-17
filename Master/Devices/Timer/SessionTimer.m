classdef SessionTimer < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Timer timer;
        Delay;
        Start;
        NextTime;
        RCount=0;
        Parent;
        Period;
        TimerReady=false;
        ScheduleRow=0;
        TimeSchedule table;
        Schedule=0;
    end
    
    methods
        function obj = SessionTimer(parent)
            obj.Parent=parent;
            
            ClearTimer(obj);

            InitTimer(obj);

        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.Schedule=obj.Schedule;
            stash.TimeSchedule=obj.TimeSchedule;
            stash.ScheduleRow=obj.ScheduleRow;
            stash.TimerReady=obj.TimerReady;
        end
        
        function Populate(obj,stash)
            obj.Schedule=stash.Schedule;
            obj.TimeSchedule=stash.TimeSchedule;
            obj.ScheduleRow=stash.ScheduleRow;
            obj.TimerReady=stash.TimerReady;
        end
        
        function InitTimer(obj)
            t=timer;
            obj.TimerReady=true;
            t.TasksToExecute=1;
            t.Period = 30;
            t.StartDelay=0;
            obj.Delay=5;
            
            
            t.ExecutionMode='fixedSpacing';
            t.Name='MyClassTimer';
            
            t.StartFcn = @(src,event) MyStart(obj);
            t.TimerFcn = @(src,event) TimerExec(obj);
            t.StopFcn = @(src,event) EndTimer(obj);
            obj.Timer=t;
        end
        
        function Set(obj,param)
            val=param;
            while numel(val)>0
                switch lower(val{1,1})
                    case 'period'
                        obj.Period=val{2};
                    case 'schedule'
                    otherwise
                end
                val(1:2)=[];
            end
        end
        
        function SetSpecificTimes(obj,schedule)
            date=datetime(now,'ConvertFrom','datenum','Format','dd-MM-yyyy HH-mm-ss');
            
            T=sortrows(schedule,'DateTime','Ascend');
%             obj.TNames={'ID','Name','DateTime','Exposure','State','Source','Note','Img'};
            T=T(T.DateTime>date,[1,3,4]);

            obj.TimeSchedule=T;
            obj.Schedule=1;
            obj.ScheduleRow=0;
        end
        
        function TestStart(obj)
            obj.RCount=0;
            Count(obj);
            
            Shoot(obj.Parent);
            StartTimer(obj);
        end

        function StartTimer(obj)
            if obj.TimerReady==false
                InitTimer(obj);
            end
            
            if obj.Schedule==1
                obj.ScheduleRow=obj.ScheduleRow+1;
                obj.NextTime=obj.TimeSchedule.DateTime(1);
            end
            
            startat(obj.Timer,year(obj.NextTime),month(obj.NextTime),day(obj.NextTime),hour(obj.NextTime),minute(obj.NextTime),second(obj.NextTime));
        end
        
        function obj=TimerExec(obj)
            time=datetime(now,'ConvertFrom','datenum','Format','dd-MM-yyyy HH-mm-ss');
            fprintf("... Shooting started at %s\n",char(time));
            ShootPlannedImage(obj.Parent,obj.TimeSchedule.ID(obj.ScheduleRow));
        end
        
        function obj=EndTimer(obj)
            disp('End of shooting');
            Count(obj);
            StartTimer(obj);
        end
        
        function Count(obj)
            obj.RCount=obj.RCount+1;
        end
        
        function obj=MyStart(obj)
            time=obj.NextTime;
            time.Format='dd.MM.yyyy HH:mm:ss';
            
            msg=sprintf('Waiting for another photo at time: %s',char(time));
            disp(msg);
            disp('.....................................................................');
        end  
    end
    
    methods %delete, stop, reset methods
        function delete(obj)
            ClearTimer(obj);
        end
        
        function ClearTimer(obj)
            Stop(obj);
            out = timerfind;
            delete(out);
            
            obj.TimeSchedule=[];
            obj.Schedule=0;
            obj.ScheduleRow=0;
            obj.TimerReady=false;
        end
        
        function Stop(obj)
            out = timerfind;
            for t=out
                stop(t);
            end
        end
        
    end
    
    methods (Static)
        function val=GetTimeVar(type,count)
            
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
end

