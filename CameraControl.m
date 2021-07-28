classdef CameraControl < Module
    %CAMERACONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        CameraObj;
        Folder;
        ImageList;
        Marker;
    end
    
    methods
        function obj = CameraControl(parent)
            obj@Module(parent);
            obj.CameraObj=CameraObj(obj);
            obj.Marker=Marker(obj);
        end
        
        function StartWindow(obj)
            fig=uifigure;
            SetFig(obj,fig);
            obj.DrawGui;
        end
    end
    
    methods (Access = private)
        function SetFolder(obj)
            selpath = uigetdir;
            
            if numel(selpath)>2
                if exist(selpath)
                    obj.Folder=selpath;
                else
                    
                end
            else
                
            end
        end
    end
    
    methods %abstract
        function stash=Pack(obj)
            
        end
        
        function Populate(obj,stash)
            
        end
        
        function DrawGui(obj)
            g=uigridlayout(obj.Fig);
            g.RowHeight = {25,75,'1x'};
            g.ColumnWidth = {100,'3x','1x'};
            
            uit=uitable;
            uit.Layout.Row=[2 3];
            uit.Layout.Column=1;
            
            bu1=uibutton(g,'Text','Select folder',...
                'ButtonPushedFcn',@obj.MSetFolder);
            bu1.Layout.Row=1;
            bu1.Layout.Column=2;
            
            p1=uipanel(g,'Title','Camera feed');
            p1.Layout.Row=[2 3];
            p1.Layout.Column=1;
            
            p2=uipanel(g,'Title','Marker Control');
            p2.Layout.Row=2;
            p2.Layout.Column=3;
            
            p3=uipanel(g,'Title','Export settings');
            p3.Layout.Row=3;
            p3.Layout.Column=3;
            
        end
    end
    
    methods %callbacks
        function MSetFolder(obj,src,evnt)
            SetFolder(obj);
        end
    end
    
end

