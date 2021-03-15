t = timer;
t.StartDelay = 3;
t.TimerFcn = @(myTimerObj, thisEvent)disp('3 seconds have elapsed');
start(t)
%%
t = timer;
t.StartFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
    datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t.TimerFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
     datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t.StopFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
    datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t.Period = 10;
t.TasksToExecute = 3;
t.ExecutionMode = 'fixedRate';
start(t)
%%
t=timer;
t.TasksToExecute=5;
t.Period = 3;
t.StartDelay=2;
t.ExecutionMode='fixedSpacing';
t.UserData=0;
t.StartFcn = @(myTimerObj, thisEvent)disp('Start of timer');
t.TimerFcn = @(myTimerObj, thisEvent)disp('2 seconds have elapsed');
t.StopFcn = @(myTimerObj, thisEvent)disp('End of all periods');
% start(t);
startat(t,2021,3,4,19,52,00);
%%
Start = datetime(now,'ConvertFrom','datenum','Format','yyyy-MM-dd HH:mm:ss');
Start2=Start+minutes(2);
%%
test=MyTimer;
%%
delete(test);
