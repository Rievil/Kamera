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
                    otherwise
                end
                val(1:2)=[];
            end
        end
        
        function TestStart(obj)
            obj.RCount=0;
            Count(obj);
            
            Shoot(obj.Parent);
            StartTimer(obj);
        end

        function StartTimer(obj)
            if obj.RCount==1
                obj.Start=datetime(now,'ConvertFrom','datenum','Format','yyyy-MM-dd HH:mm:ss');            
                obj.NextTime=obj.Start+minutes(obj.Period);    
            else
                obj.NextTime=obj.NextTime+minutes(obj.Period);
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
        end
        
        function Stop(obj)
            out = timerfind;
            for t=out
                stop(t);
            end
        end
        
    end
end

