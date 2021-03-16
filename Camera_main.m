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
%%

%%
T=readtable('Statlog.xlsx');
T.Name=string(T.Name);

T=T(T.Name=="ShootTime",:);
bar(T.Duration);
%%
