obj=CameraObj;
%
SetPhotoFolder(obj,'C:\Users\uzivatel\OneDrive - Vysoké učení technické v Brně\Photos')
%
FindCamera(obj);
%
Conn(obj);
%%
Shoot(obj);
%%
ResetDriver(obj);
%%
StartTimerShoot(obj);