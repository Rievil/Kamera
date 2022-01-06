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

SetSchedule(obj,length,period);
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

dm.Start;
%%
dm.StartDevice;
