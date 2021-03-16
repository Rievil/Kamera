a = arduino("COM1")
%%

ports=serialportlist("available")
%
%serial_Port=serial("COM1",'BaudRate',9600);
serial_Port=serial(ports(2),'BaudRate',9600,'Timeout',2);
%
tic;
fopen(serial_Port);

%fprintf(serial_Port,'1');
try
    %data=fread(serial_Port,10);
%     configureTerminator(serial_Port,'\n');
%     data = readline(serial_Port);
%     fprintf(serial_Port,'uint8','2')
    readData=fscanf(serial_Port);
    pause(.1);
%     write(serial_Port,'1','uint8')
    num=char(num2str(99));
    fprintf(serial_Port,num);
    %pause(.5);
    readData=fscanf(serial_Port);
catch
    fclose(serial_Port);    
end
fclose(serial_Port);

ValRaw=split(readData,' ');
Val=[str2double(ValRaw{1}), str2double(ValRaw{end})];
toc

