obj=CameraObj;
%
SetPhotoFolder(obj,'C:\Users\uzivatel\OneDrive - Vysoké učení technické v Brně\Alkali_1')
%
FindCamera(obj);

Conn(obj);
%%
SetPhotoFolder(obj,'C:\Users\uzivatel\OneDrive - Vysoké učení technické v Brně\Alkali_1')
%%
length=[hours(12),days(2)];
period=[minutes(10),minutes(30)];

SetSchedule(obj,length,period);
%%

SetTimer(obj,'period',2);
%%
ChangeSettings(obj);
%%
Shoot(obj);     
%%

Preview(obj);
%%
EndPreview(obj);
%%
ResetDriver(obj);
%%

%%
ResetTimer(obj);
%%
StartTimerShoot(obj);
%%
delete(obj);
%%
%<<<<<<< HEAD
out = timerfind
%%
delete(out);
%%
T=readtable('Statlog.xlsx');
T.Name=string(T.Name);

T=T(T.Name=="ShootTime",:);
bar(T.Duration);
%%
% =======
ResetTimer(obj);
%%
clear all
%%
% >>>>>>> b58a66de2c014a593d0a3f77d5998cc307f69d63
list=gigecamlist;
IP=char(char(list.IPAddress(1)));
%%
g = gigecam(IP);
%%
preview(g);
%%
delete(g);
%%
vidobj = videoinput('gige', 1, 'BGR8');
%%
src = getselectedsource(vidobj);
src.ColorTransformationFactoryListSelector='OptimizedMatrixFor3000K';
src.ColorTransformationValue=1;

src.ColorTransformationAuto='off';
src.BalanceWhiteAuto='off';
%             g.BalanceWhite='off';
src.AcquisitionFrameRateEnable = 'True';
src.AcquisitionFrameRate = 2;
src.ExposureTime = 5e+4;
src.ColorTransformationValue=1.0;
% src.TriggerMode='off';
% src.DeviceLinkHeartbeatTimeout=600000;
% src.TimerDelay = 0;
% src.TimerDuration = 100; %this is is usec, and must be 100'!!
% src.CounterDuration=1;
%OptimizedMatrixFor3000K
%%

%%
snapshot = getsnapshot(vidobj);
%
imshow(snapshot);
%%

d = datetime(now(),'ConvertFrom','datenum','Format','yyyy.MM.dd HH:mm:ss');
length=[hours(12),days(2)];
period=[minutes(10),minutes(30)];
%%

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