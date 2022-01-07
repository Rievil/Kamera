classdef ArduinoObj < handle
    %ARDUINOOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent;
        Conn;
        Port;
        State;
        ComPort='COM5';
        KnownPort='';
        KnownPortBool=false;
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
            fprintf("... Trying to connect on port '%s'\n",obj.ComPort);
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
            fprintf("Cam arduino is on port '%s' !\n",obj.ComPort);
            if strcmp(obj.State,'ACam')
                result=true;
                obj.KnownPort=obj.ComPort;
                obj.KnownPortBool=true;
            else
                result=false;
                obj.KnownPortBool=false;
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
                if obj.KnownPortBool
                    obj.ComPort=obj.KnownPort;
                    SetupConn(obj);
                    TestBoard(obj);
                else
                    FindPorts(obj);
                end
                
                
                
                pause(0.5);
                
                if obj.KnownPortBool
                    disp("Successfully connected to CamArduino");
                else
                    disp("Can't find Cam arduino in com ports. Is arduino connected?");
                end
            end
        end
        
        function CloseConnection(obj)
            delete(obj.Conn);
            obj.Connected=false;
            fprintf("... disconnecting from port '%s'\n",obj.ComPort);
        end
    end
end

