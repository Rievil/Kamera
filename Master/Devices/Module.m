classdef Module < handle
    %MODULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        Parent;
        Fig;
        FigBool=false;
        ListDevices;
    end
    
    methods
        function obj = Module(parent)
            obj.Parent=parent;

        end
        
        function SetFig(obj,fig)
            obj.Fig=fig;
            obj.FigBool=true;
        end
        
        function ClearGui(obj)
            if obj.FigBool==true
                a=obj.Fig.Children;
                a.delete;
            end
        end
        

    end
    
    methods (Abstract)
%         GetDeviceList;
        Pack
        Populate
        DrawGui
    end
end


