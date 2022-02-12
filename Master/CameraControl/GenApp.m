classdef GenApp < handle
    %GENAPP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent;
        UIFig;
        UIFigBool=false;
        Device;
    end
    
    methods
        function obj = GenApp(parent)
            obj.Parent=parent;
        end
        
        function AdDevice(obj,device)
            obj.Device=device;
        end
        
        function DrawGui(obj)
            obj.UIFig=uifigure('position',obj.Parent.GetScreenDim(obj.WinDim(1),obj.WinDim(2)),...
                'CloseRequestFcn',@obj.MFigClose);
            obj.UIFigBool=true;
            
            AppDrawGui(obj);
        end
    end
    
    methods %callbacks
        function MFigClose(obj,src,evnt)
            obj.UIFigBool=false;
            CloseChild(obj);
            delete(obj.UIFig);
        end
    end
    
    methods (Abstract)
        AppDrawGui;
        CloseChild;
    end
end

