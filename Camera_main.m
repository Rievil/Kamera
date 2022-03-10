obj=CameraObj(1);
%
SetPhotoFolder(obj,'C:\Users\uzivatel\Vysoké učení technické v Brně\22-02098S - General\Data\Kamera\Measurements\01122022_Hydrox_Uhlic\Images')
%
FindCamera(obj);

Conn(obj);
%%
% SetPhotoFolder(obj,'C:\Users\uzivatel\OneDrive - Vysoké učení technické v Brně\Alkali_1')
%%
length=[days(1),days(7)];
period=[minutes(15),hours(1)];

SetSchedule(obj,length,period);
%%
T=table(length',period','VariableNames',{'Len','Per'});
%%
fig=uifigure;


ax=uiaxes(fig);
hold(ax,'on');
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
%         y2=[y2; period'];
    end
end

x=[0; x];
y2=[0; y2];

x=nowar+seconds(x);
y=1:1:numel(x);
y=y';

scatter(ax,x,y,'o');
plot(ax,[nowar nowar],[0 max(y)],'r-');
ylabel(ax,'Photo count');
xlabel(ax,'Time');
% xlim([nowar nowar+hours(24)]);
%%

SetTimer(obj,'period',2);
%%
ChangeSettings(obj);
%%
Shoot(obj);     
%%
obj.Arduino.OpenConnection;
%%
obj.Arduino.LightUp;
%%
obj.Arduino.GoDark;
%%
img=GetCurrentImage(obj);
%%
imshow(img);
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
dm=DeviceMonitor;

dm.Start;
%%
dm.StartDevice;
%%
dm.Device.GoDark;
%%
dm.App.Session.SchedTable.Properties.VariableNames={'LengthType','nL','PeriodType','nP'};
dm.App.Session.SchedTable.UIStable.Data.Properties.VariableNames={'LengthType','nL','PeriodType','nP'};