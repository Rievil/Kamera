classdef Device < handle
    %DEVICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Settings;
        Parent;
        DeviceList;
        DeviceListRow;
        Fig;
        FigBool=false;
        Marker;
    end
    
    methods
        function obj = Device(parent)
            obj.Parent=parent;
            obj.Marker=Marker(obj);
            InitMarker(obj.Marker);
        end
        
        function SetFig(obj,gui)
            obj.Fig=gui;
            obj.FigBool=false;
        end
        
        function ClearGui(obj)
            if obj.FigBool==true
                a=obj.Fig.Children;
                a.delete;
            end
        end

    end
    
    methods (Access=private)
        
    end
    
    methods (Abstract)
        GetDeviceList;
        Connect;
        StartDevice;
        DrawGui;
    end
end

