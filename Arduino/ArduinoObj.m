classdef ArduinoObj < handle
    %ARDUINOOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent;
        Conn;
        Port;
        State;
        ComPort='COM5';
        BaudRate=115200;
        TimeOut=2;
        TermnatorConf='CR/LF';
        Connected=false;
    end
    
    methods
        function obj = ArduinoObj(parent)
            obj.Parent=parent;
        end
        
        function CloseAllConn(obj)
            if ~isempty(instrfind)
                 fclose(instrfind);
                  delete(instrfind);
                  obj.Connected=false;
            end
        end
        
        function SetupConn(obj)
            s = serialport(obj.ComPort,obj.BaudRate,'Timeout',obj.TimeOut);

            configureTerminator(s,obj.TermnatorConf);

            obj.Conn=s;
            pause(3);
            obj.Connected=true;
        end
        
        function FindPorts(obj)
            Skey = 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM';
            % Find connected serial devices and clean up the output
            [~, list] = dos(['REG QUERY ' Skey]);
            list = string(strread(list,'%s','delimiter',' '));
            list(contains(list,Skey))=[];
            idx=1:numel(list);
            A=contains(list,"COM");
            idx=idx(A);
            
            for i=1:numel(idx)
                obj.ComPort=char(list(idx(i)));
                try
                    SetupConn(obj);
                    
                    if TestBoard(obj)
                        fprintf("Cam arduino connected on port '%s'\n",obj.ComPort);
                        break;
                    else
                        CloseConnection(obj);
                    end
                catch ME
                    CloseConnection(obj);
                end
            end
        end
        
        function result=TestBoard(obj)
            write(obj.Conn,0,"int8");
            obj.State=readline(obj.Conn);

            if strcmp(obj.State,'ACam')
                result=true;
            else
                result=false;
            end
        end
        
        function LightUp(obj)
            write(obj.Conn,1,"int8");
            obj.State=readline(obj.Conn);
        end
        
        function GoDark(obj)
            write(obj.Conn,2,"int8");
            obj.State=readline(obj.Conn);
        end
        
        function OpenConnection(obj)
            if ~obj.Connected
                CloseAllConn(obj);
                FindPorts(obj);
                pause(0.5);
            end
        end
        
        function CloseConnection(obj)
            delete(obj.Conn);
            obj.Connected=false;
            fprintf("Closing connection with '%s'\n",obj.ComPort);
        end
    end
end

