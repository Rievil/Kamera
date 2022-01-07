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
            
%             g = uigridlayout(fig);
%             g.RowHeight = {250,'1x'};
%             g.ColumnWidth = {'1x'};
%             
%             p=uipanel(g,'Title','Device panel');
%             p.Layout.Row=2;
%             p.Layout.Column=1;
%             
%             obj.UIDevPanel=p;
%             
%             tabgp = uitabgroup(f,'Position',[.05 .05 .3 .8]);
%             for i=1:obj.Parent.ConDeviceCount
%                 tab1 = uitab(tabgp,'Title','CameraObj');
%             end
%             obj.UIDevPanel=tab1;
            
            AppDrawGui(obj);
        end
    end
    
    methods %callbacks
        function MFigClose(obj,src,evnt)
            obj.UIFigBool=false;
            delete(obj.UIFig);
        end
    end
    
    methods (Abstract)
        AppDrawGui;
    end
end

