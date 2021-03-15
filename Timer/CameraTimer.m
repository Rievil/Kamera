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
    end
    
    methods
        function obj = CameraTimer(parent)
            obj.Parent=parent;
            
            ClearTimer(obj);
            
            t=timer;
            
            t.TasksToExecute=5;
            t.Period = 3;
            t.StartDelay=3;
            obj.Delay=5;
            
            
            t.ExecutionMode='fixedSpacing';
            t.Name='MyClassTimer';
            
            t.StartFcn = @(src,event) MyStart(obj);
            t.TimerFcn = @(src,event) TimerExec(obj);
            t.StopFcn = @(src,event) EndTimer(obj);
            
            
            obj.Timer=t;
            
%             StartTimer(obj);
        end
        

        function StartTimer(obj)
            obj.Start=datetime(now,'ConvertFrom','datenum','Format','yyyy-MM-dd HH:mm:ss');            
            obj.NextTime=obj.Start+seconds(5);            
            startat(obj.Timer,year(obj.NextTime),month(obj.NextTime),day(obj.NextTime),hour(obj.NextTime),minute(obj.NextTime),second(obj.NextTime));
        end
        
        function obj=TimerExec(obj)
            disp('Two seconds passed');            
        end
        
        function obj=EndTimer(obj)
            disp('End of all periods');
            Repeat(obj);
            StartTimer(obj);
        end
        
        function Repeat(obj)
            obj.RCount=obj.RCount+1;
        end
        
        function obj=MyStart(obj)
            disp('Start of timer');
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

