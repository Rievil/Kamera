obj=CameraObj(1);
%
SetPhotoFolder(obj,'C:\Users\uzivatel\OneDrive - Vysoké učení technické v Brně\Měření\2022\Data')
%
FindCamera(obj);

Conn(obj);
%%
% SetPhotoFolder(obj,'C:\Users\uzivatel\OneDrive - Vysoké učení technické v Brně\Alkali_1')
%%
length=[hours(12),days(2)];
period=[minutes(5),minutes(30)];
%%
SetSchedule(obj,length,period);
%%
T=table(length',period','VariableNames',{'Len','Per'});
%%
fig=uifigure;

hold on;
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

scatter(x,y,'o');
plot([nowar nowar],[0 max(y)],'r-');
ylabel('Photo count');
xlabel('Time');
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
img=obj.Image;

imshow(img);
%%
obj = CameraControl(1);
%%
obj.StartWindow;
%%
gimg=rgb2gray(img);
histogram(gimg);
%%
T=70;
BW = imbinarize(gimg,'adaptive', 'Sensitivity',0.4,'ForegroundPolarity','dark');

imshow(BW);
%%
dm=DeviceMonitor;
%%
dm.Start;
%%
dm.StartDevice;
