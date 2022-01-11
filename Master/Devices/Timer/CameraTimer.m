classdef CameraTimer < handle
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
        
        ScheduleRow=0;
        TimeSchedule table;
        Schedule=0;
    end
    
    methods
        function obj = CameraTimer(parent)
            obj.Parent=parent;
            
            ClearTimer(obj);
            
            t=timer;
            
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
            
%             StartTimer(obj);
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
        
        function SetSpecificTimes(obj,length,period)
            starttime=now();
            T=table([],[],[],'VariableNames',{'Etap','Period','Time'});
            etaps=numel(length);

            for j=1:etaps
                samplesperetap=length(j)/period(j);
                cycle=0;
                if j==1
                    d = datetime(starttime,'ConvertFrom','datenum','Format','yyyy.MM.dd HH:mm:ss');
                else
                    d=T.Time(end);
                end

                for i=1:1:samplesperetap
                    cycle=cycle+1;
                    next=datetime(datenum(d)+i*datenum(period(j)),'ConvertFrom','datenum','Format','yyyy.MM.dd HH:mm:ss');

                    T=[T; table(j,cycle,next,'VariableNames',{'Etap','Period','Time'})];
                end
            end
            disp('Scheduler setuped...');
            obj.TimeSchedule=T;
            obj.Schedule=1;
        end
        
        function TestStart(obj)
            obj.RCount=0;
            Count(obj);
            
            Shoot(obj.Parent);
            StartTimer(obj);
        end

        function StartTimer(obj)

            if obj.Schedule==1
                obj.ScheduleRow=obj.ScheduleRow+1;
                obj.NextTime=obj.TimeSchedule.Time(obj.ScheduleRow);
            else
                if obj.RCount==1
                    obj.Start=datetime(now,'ConvertFrom','datenum','Format','yyyy-MM-dd HH:mm:ss');            
                    obj.NextTime=obj.Start+minutes(obj.Period);    
                else
                    obj.NextTime=obj.NextTime+minutes(obj.Period);
                end
            end
           
            startat(obj.Timer,year(obj.NextTime),month(obj.NextTime),day(obj.NextTime),hour(obj.NextTime),minute(obj.NextTime),second(obj.NextTime));
        end
        
        function obj=TimerExec(obj)
            Shoot(obj.Parent);
        end
        
        function obj=EndTimer(obj)
            disp('End of shooting');
            Count(obj);
            StartTimer(obj);
            SaveLog(obj.Parent);
        end
        
        function Count(obj)
            obj.RCount=obj.RCount+1;
        end
        
        function obj=MyStart(obj)
            msg=sprintf('Waiting for another photo at time: %s',char(obj.NextTime));
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
        end
        
        function Stop(obj)
            out = timerfind;
            for t=out
                stop(t);
            end
        end
        
    end
end

