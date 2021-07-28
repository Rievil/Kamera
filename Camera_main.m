obj=CameraObj;
%
SetPhotoFolder(obj,'C:\Users\Richard\OneDrive\Měření\2021\Fotky_Disertace')
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
