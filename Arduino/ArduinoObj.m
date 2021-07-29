classdef ArduinoObj < handle
    %ARDUINOOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent;
        Conn;
        Port;
        State;
    end
    
    methods
        function obj = ArduinoObj(parent)
            obj.Parent=parent;

        end
        
        function CloseAllConn(obj)
            if ~isempty(instrfind)
                 fclose(instrfind);
                  delete(instrfind);
            end
        end
        
        function SetupConn(obj)
            s = serialport('COM4',115200,'Timeout',2);
            configureTerminator(s,'CR/LF');
            obj.Conn=s;
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
            CloseAllConn(obj);
            SetupConn(obj);
            pause(2);
        end
        
        function CloseConnection(obj)
            delete(obj.Conn);
        end
    end
end

