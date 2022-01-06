classdef DeviceMonitor < handle
    %CAMERACONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Fig;
        DevFig;
        DeviceBool=0;
        Device;
        DeviceTypes;
        SelectedDevice=0;
        SelectedDeviceType;
        UIDeviceList;
    end
    
    methods
        function obj = DeviceMonitor(~)
            obj.DeviceTypes=["CameraControl"];
        end
        
        function StartWindow(obj)
            obj.Fig=uifigure;
            obj.DrawGui;
        end
        
        function Start(obj)
            DrawDeviceSelection(obj);
            SelectDeviceType(obj);
        end
        
        function StartDevice(obj)
            if obj.SelectedDevice>0 && obj.DeviceBool
                close(obj.Fig);
                delete(obj.Fig);
                obj.Fig=[];
                try
                    obj.Device.StartDevice;
                    DrawGui(obj);
                    DrawGui(obj.Device);
                catch ME
                    disp('Cant start to selected device');
                    disp(ME.message);
                end
            end
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

        
        function ListDevices(obj)
            if obj.DeviceBool
                T=obj.Device.GetDeviceList;
                if size(T,1)>0
                    obj.UIDeviceList.Data=T;
                end
            end
        end
        
        function SelectDeviceType(obj)
            if ~isempty(obj.Device)
                delete(obj.Device);
                obj.Device=[];
            end
            MakeDevice(obj);
            obj.DeviceBool=true;
            ListDevices(obj);
        end
        
        
        
        function MakeDevice(obj)
            name=obj.DeviceTypes(obj.SelectedDeviceType);
            switch name
                case 'CameraControl'
                    obj2=CameraControl(obj);
                case 'TiePieSampler'
            end
            obj.Device = obj2;
        end
        
        function stash=Pack(obj)
            
        end
        
        function Populate(obj,stash)
            
        end
        
        function dim=GetScreenDim(obj,W,H)
            Pix_SS = get(0,'screensize');
            dim=[Pix_SS(3)/2-W/2,Pix_SS(4)/2-H/2,W,H];
        end
        
        function DrawDeviceSelection(obj)

            obj.Fig=uifigure('position',GetScreenDim(obj,900,400));
            
            g=uigridlayout(obj.Fig);
            g.RowHeight={25,'1x',25};
            g.ColumnWidth={150,150,'1x',150,150};
            
            lab1=uilabel(g,'Text','Select type of device:');
            lab1.Layout.Row=1;
            lab1.Layout.Column=1;
            
            
            
            dd = uidropdown(g,'Items',obj.DeviceTypes,'ItemsData',1:1:numel(obj.DeviceTypes),'Value',1,...
                'ValueChangedFcn',@obj.MSelectDeviceType);
            dd.Layout.Row=1;
            dd.Layout.Column=2;
            obj.SelectedDeviceType=1;
            
            uit=uitable(g,'CellSelectionCallback',@obj.MRowSelected);
            uit.Layout.Row=2;
            uit.Layout.Column=[1 5];            
            obj.UIDeviceList=uit;
            
            but1=uibutton(g,'Text','Select device','ButtonPushedFcn',@obj.MSelectDevice);
            but1.Layout.Row=3;
            but1.Layout.Column=4;
            
            but2=uibutton(g,'Text','Cancle and exit','ButtonPushedFcn',@obj.MExit);
            but2.Layout.Row=3;
            but2.Layout.Column=5;     
            
            but3=uibutton(g,'Text','List devices of selected type','ButtonPushedFcn',@obj.MListDevice);
            but3.Layout.Row=1;
            but3.Layout.Column=[3 4];     
        end
        
        
        function DrawGui(obj)
%             obj.DevFig=uifigure;
            obj.DevFig=uifigure('position',GetScreenDim(obj,900,600));

            

            g=uigridlayout(obj.DevFig);
            g.RowHeight = {25,75,'1x',25};
            g.ColumnWidth = {300,'3x',250};
            
            uit=uitable(g);
            uit.Layout.Row=[2 3];
            uit.Layout.Column=1;
            
            
            bu1=uibutton(g,'Text','Select folder',...
                'ButtonPushedFcn',@obj.MSetFolder);
            bu1.Layout.Row=1;
            bu1.Layout.Column=1;
            
            p1=uipanel(g,'Title','Device control panel');
            p1.Layout.Row=[2 4];
            p1.Layout.Column=2;            
            SetFig(obj.Device,p1);
            
            
            p2=uipanel(g,'Title','Marker Control');
            p2.Layout.Row=2;
            p2.Layout.Column=3;
            
            p3=uipanel(g,'Title','Export settings');
            p3.Layout.Row=[3 4];
            p3.Layout.Column=3;
            
        end
    end
    
    methods %callbacks
        function MSetFolder(obj,~,~)
            SetFolder(obj);
        end
        
        function MSelectDeviceType(obj,src,evnt)
            obj.SelectedDeviceType=src.Value;
            SelectDeviceType(obj);
        end
        
        function MSelectDevice(obj,~,~)
            StartDevice(obj);
        end
        
        function MExit(obj,~,~)
            close(obj.Fig);
        end
        
        function MRowSelected(obj,src,evnt)
            obj.SelectedDevice=evnt.Indices(1);
            obj.Device.DeviceListRow=evnt.Indices(1);
        end
        
        function MListDevice(obj,~,~)
            ListDevices(obj);
        end
    end
    
end

