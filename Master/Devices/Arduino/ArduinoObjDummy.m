classdef ArduinoObjDummy < handle
    %ARDUINOOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent;
        Conn;
        Port;
        State;
        StateBool=false;
        ComPort='COM5';
        KnownPort='';
        KnownPortBool=false;
        BaudRate=115200;
        TimeOut=2;
        TermnatorConf='CR/LF';
        Connected=false;
    end
    
    methods
        function obj = ArduinoObjDummy(parent)
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
            obj.Connected=true;
            obj.Conn="DummySetup";s
        end
        
        function FindPorts(obj)

            for i=1:1
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
            
            if strcmp(obj.State,'ACam')
                result=true;
                obj.KnownPort=obj.ComPort;
                obj.KnownPortBool=true;
                fprintf("Cam arduino is on port '%s' !\n",obj.ComPort);
            else
                result=false;
                obj.KnownPortBool=false;
                fprintf("Cam arduino is NOT port '%s'...!\n",obj.ComPort);
            end
        end
        
        function LightUp(obj)

%             write(obj.Conn,1,"int8");
            obj.State="Light";
            obj.StateBool=true;
        end
        
        function GoDark(obj)
%             write(obj.Conn,2,"int8");
            obj.State="Dark";
            obj.StateBool=false;
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
                    disp("Successfully connected to CamArduino!");
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

