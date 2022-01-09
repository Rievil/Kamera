Skey = 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM';
% Find connected serial devices and clean up the output
[~, list] = dos(['REG QUERY ' Skey]);
list = string(strread(list,'%s','delimiter',' '));
list(contains(list,Skey))=[];

A=contains(list,"COM");

