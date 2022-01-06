classdef DeviceShell < handle
    %DEVICESHELL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent
        DeviceList
    end
    
    
    methods
        function obj = DeviceShell(parent)
            obj.Parent=parent;

        end
        
        
    end
    
    methods (Abstract)
        GetDeviceList;
    end
end

