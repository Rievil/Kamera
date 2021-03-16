a = arduino("COM3");
%%

ports=serialportlist("available");
%%
%serial_Port=serial("COM1",'BaudRate',9600);
serial_Port=serial(ports(3),'BaudRate',115200,'Timeout',2,'Terminator','CR/LF'); %'CR/LF' or 'LF/CR'
%%
tic;
fopen(serial_Port);

%fprintf(serial_Port,'1');
% try
    %data=fread(serial_Port,10);
%      configureTerminator(serial_Port,10);
%     set(serial_Port, 'terminator', 'LF'); 
%     data = readline(serial_Port);
%     fprintf(serial_Port,'uint8','2')
%     readData=fscanf(serial_Port);
%     pause(.1);

    fprintf(serial_Port,'%i',5);
%     fwrite(a,'0','uint8','async');
%     pause(.5);
%     readData=fscanf(serial_Port);
%     fgets

    readData=fscanf(serial_Port,'%s');

% catch
%     fclose(serial_Port);    
% end
fclose(serial_Port);

% ValRaw=split(readData,' ');
% Val=[str2double(ValRaw{1}), str2double(ValRaw{end})];
toc

%%
clear all;

if ~isempty(instrfind)
     fclose(instrfind);
      delete(instrfind);
end
%%
ports=serialportlist("available");


%%
s = serialport('COM4',115200,'Timeout',2);
configureTerminator(s,'CR/LF');
%%
write(s,8,"int8");
%%
writeline(s,'1');
%%
% writeline(s,'5');
% write(s,8,"int8");
% result=readline(s);
% writeline(s,'1');
% pause(.1);
% flush(s);
% writeline(s,'1');
% write(s,7,"double");
% pause(0.5);
write(s,1,"int8");
result=readline(s);
pause(5);
delete(s);
%%
tic;
obj=ArduinoObj(25);

OpenConnection(obj);

pause(2);
%%
LightUp(obj)

%%
%

GoDark(obj);
%%
CloseConnection(obj);