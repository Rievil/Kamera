obj=CameraObj;
%
SetPhotoFolder(obj,'C:\Users\uzivatel\OneDrive - Vysoké učení technické v Brně\Photos')
%
FindCamera(obj);

Conn(obj);

SetTimer(obj,'period',2);
%%
Shoot(obj);
%%
ResetDriver(obj);
%%
StartTimerShoot(obj);
%%
ResetTimer(obj);
%%
clear all
