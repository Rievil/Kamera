obj=CameraObj;
%
SetPhotoFolder(obj,'C:\Users\uzivatel\OneDrive - Vysoké učení technické v Brně\Photos')
%
FindCamera(obj);
%%
Conn(obj);
%%
SetTimer(obj,'period',2);
%%
Shoot(obj);
%%
ResetDriver(obj);
%%
ResetTimer(obj);
%%
StartTimerShoot(obj);
%%
%<<<<<<< HEAD

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