classdef Marker < Module
    %MARKER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MarkerTable table;
        SelFig;
        SelFigBool=false;
        IDCurrMarker;
        UIMarkerTable;
        UIControls;
        UIDeskriptorPanel;
        DescTable table;
        UnqComb;
    end
    
    properties (Dependent)
        Count;
        IDMain;
    end
    
    properties (Hidden)
        IDMainH=0;
    end
        
        
    
    methods
        function obj = Marker(parent)
            obj@Module(parent);
        end
        
        function count=get.Count(obj)
            count=size(obj.MarkerTable,1);
        end
        
        function id=get.IDMain(obj)
            obj.IDMainH=obj.IDMainH+1;
            id=obj.IDMainH;
        end
        
        function ShowDescription(obj,ID)
            T=obj.DescTable(ID,:);
            for i=1:numel(obj.UIControls)
                cont=obj.UIControls{i};
                obj2=obj.MarkerTable.Type{i};
                switch obj2.Type
                    case 'double'
                        cont.Value=cell2mat(T{1,i+1});
                    case 'string'
                        pat=string(T{1,i+1});
                        arr=string(cont.Items);
                        idx=find(arr==pat);
                        cont.Value=idx;
%                         obj2=FieldString(obj);
                    case 'datetime'
                        val=T{1,i+1};
                        cont.Value=val{1};
%                         obj2=FieldDateTime(obj);
                end
            end
        end
        
        function T=GetMarkerRow(obj)
            id=obj.Count+1;
            
            datatype=categorical({'double','string','datetime'});
            name=string(sprintf('Makrer %d',id));
            seltype=datatype(1);
            
            obj2=GetObjByName(obj,char(seltype));
            obj2.Name=name;
            
            T=table(id,seltype,name,{obj2},'VariableNames',...
                {'ID','DataType','Name','Type'});
        end
        
        function Ts=GetDescTableRow(obj)
            Ts=table;
            for i=1:obj.Count
                val=GetCurrentDesc(obj,i);
                Tsx=table({val},'VariableNames',{char(obj.MarkerTable.Type{i}.Name)});
                Ts=[Ts, Tsx];
            end
        end

        function Tfull=GetNewDescRow(obj)
            T=GetDescTableRow(obj);
            Tfull=[table(obj.IDMain,'VariableNames',{'ID'}), T];
        end
        
        function id=GetNewId(obj)
            obj.IDMain=obj.IDMain+1;
            id=obj.IDMain;
        end
        
        function id=GetNewIdSample(obj)
            
        end
        
        function CheckMeasuredSignals(obj)
            if obj.Parent.Count>0
                B=obj.DescTable(:,1);
                C=table;
                for i=1:obj.Parent.Count
                    T=GetDescTableRow(obj);
                    C=[C; T];
                end
                obj.DescTable=table;
                test=[B, C];
                obj.DescTable=test;
            end
        end
        
        function AddDescription(obj)
            T=GetNewDescRow(obj);
            obj.DescTable=[obj.DescTable; T];
        end
        
        function RemoveDescription(obj,row)
            obj.DescTable(row,:)=[];
        end
        
        function obj2=GetObjByName(obj,name)
            
            switch name
                case 'double'
                    obj2=FieldDouble(obj);
                case 'string'
                    obj2=FieldString(obj);
                case 'datetime'
                    obj2=FieldDateTime(obj);
            end
            
            SetFig(obj2,obj.UIDeskriptorPanel);
        end
        
        function CheckClassType(obj)
            if obj.Count>0
                setType=char(obj.MarkerTable.DataType(obj.IDCurrMarker));
                obj2=obj.MarkerTable.Type{obj.IDCurrMarker};
                if strcmp(setType,obj2.Type)

                else
                    obj3=GetObjByName(obj,setType);
                    delete(obj2);
                    obj.MarkerTable.Type{obj.IDCurrMarker}=obj3; 
                end
                DrawClassType(obj);
            end
        end
        
        function DrawClassType(obj)
            obj2=obj.MarkerTable.Type{obj.IDCurrMarker};
            SetFig(obj2,obj.UIDeskriptorPanel);
            ClearGui(obj2);
            DrawGui(obj2);
        end
    end
    
    methods %gui
        function ShowSelection(obj)
            obj.SelFig=true;
            obj.SelFig=uifigure;
            DrawSelection(obj);
        end
        
        function CloseSelection(obj)
            close(obj.SelFig);
            delete(obj.SelFig);
            obj.SelFig=[];
            obj.SelFigBool=false;
        end
        
        function InitMarker(obj)
            if obj.Count==0
                AddDeskriptor(obj);
            end
        end
        
        function AddDeskriptor(obj)
            obj.MarkerTable=[obj.MarkerTable; GetMarkerRow(obj)];
        end
        
        function RefreshUITable(obj)
            arr=1:1:obj.Count;
            arr=arr';
            obj.MarkerTable.ID=arr;
            obj.UIMarkerTable.Data=obj.MarkerTable(:,1:end-1);
        end
        
        function UpdateUITable(obj)
            obj.MarkerTable(:,1:end-1)=obj.UIMarkerTable.Data;
            for i=1:obj.Count
                name=obj.MarkerTable.Name(i);
                obj.MarkerTable.Type{i}.Name=name;
            end
        end
        
        
        function RemoveDeskriptor(obj)
            if obj.Count>0
                if obj.IDCurrMarker>0
                    obj.MarkerTable(obj.IDCurrMarker,:)=[];
                    obj.IDCurrMarker=obj.IDCurrMarker-1;
                else
                    obj.MarkerTable(obj.Count,:)=[];
                end
                RefreshUITable(obj);
            end
        end
        
       
        
        function DrawSelection(obj)
            obj.SelFig.CloseRequestFcn=@obj.MDrawMarkers;
            g=uigridlayout(obj.SelFig);
            g.RowHeight = {25,'1x'};
            g.ColumnWidth = {120,120,'1x'};
            
            p=uipanel(g,'Title','Deskriptor parameters');
            p.Layout.Row=[1 2];
            p.Layout.Column=3;
            
            obj.UIDeskriptorPanel=p;
            
            InitMarker(obj);

            uit=uitable(g,'Data',obj.MarkerTable(:,1:3),'CellSelectionCallback',@obj.MTableRowSelect,...
                'ColumnEditable',[false,true,true],'CellEditCallback',@obj.MUITableEdit,...
                'ColumnWidth',{25,75,'auto'});
            uit.Layout.Row=2;
            uit.Layout.Column=[1 2];
            
            obj.UIMarkerTable=uit;
            
            
            
            but1=uibutton(g,'Text','Add deskriptor','ButtonPushedFcn',@obj.MAddDeskriptor);
            but1.Layout.Row=1;
            but1.Layout.Column=1;
            
            but2=uibutton(g,'Text','Remove deskriptor','ButtonPushedFcn',@obj.MRemoveDeskriptor);
            but2.Layout.Row=1;
            but2.Layout.Column=2;
            

        end
    end
    
    methods (Access=private)
        function samp=GetDoubleStruct(obj)
            
            samp.HasLimits=false;
            samp.Limits=[0,0];
            samp.HasUniqueValues=false;
            samp.UniqueValues=[];
        end
        
        function samp=GetStringStruct(obj)
            samp=struct;
%             samp.
        end
        
        function samp=GetDateTimeStruct(obj)
            
        end
    end

    
    methods %abstract
        function stash=Pack(obj)
            stash=struct;
            stash.MarkerTable=obj.MarkerTable;
            stash.DescTable=obj.DescTable;
            stash.IDMainH=obj.IDMainH;
            stash.Count=obj.Count;
            
            for i=1:obj.Count
                TMP=Pack(obj.MarkerTable.Type{i});
                stash.MarkerTable.Type{i}=TMP;
            end
        end
        
        function Populate(obj,stash)
            obj.MarkerTable=stash.MarkerTable;
            obj.DescTable=stash.DescTable;
            obj.IDMainH=stash.IDMainH;
            
            for i=1:stash.Count
                type=stash.MarkerTable.Type{i}.Type;
                obj2=GetObjByName(obj,type);
                tmp=stash.MarkerTable.Type{i};
                obj2.Populate(tmp);
                obj.MarkerTable.Type{i}=obj2;
            end
        end
        
        function DrawGui(obj)
            
            g=uigridlayout(obj.Fig);
            
            arr=cell(1,obj.Count+1);
            arr{1}=25;
            for i=1:obj.Count
                arr{i+1}=25;
            end
            
            lab=uilabel(g,'Text','Select descriptive variables:');
            lab.Layout.Row=1;
            lab.Layout.Column=[1 2];
            
            g.RowHeight = arr;
            g.ColumnWidth = {70,'1x'};
            
            for i=1:obj.Count

                
                
                cont=DrawUnqControl(obj,g,i);

                
                obj.UIControls{i}=cont;
            end
            
        end
        
        function val=GetCurrentDesc(obj,i)
            type=obj.MarkerTable.Type{i}.Type;
            switch type 
                case 'double'
                    val=obj.UIControls{i}.Value;
                case 'string'
                    val=obj.UIControls{i}.Items{obj.UIControls{i}.Value};
                    
                case 'datetime'
                    val=obj.UIControls{i}.Value;
                    if isnat(val)
                        val=datetime(now(),'ConvertFrom','datenum');
                    end
            end
            
        end
        
        function cont=DrawUnqControl(obj,grid,i)
            obj2=obj.MarkerTable.Type{i};
            
            lab=uilabel(grid,'Text',char(obj2.Name),'BackgroundColor',[0.7 0.7 0.7],'HorizontalAlignment','left');
            lab.Layout.Row=i+1;
            lab.Layout.Column=1;
            
            switch obj2.Type
                case 'string'
                    arr=1:1:obj2.Count;
                    cont=uidropdown(grid,'Items',obj2.OutUnq,'ItemsData',arr,'UserData',i,'ValueChangedFcn',@obj.MCChanged);
                case 'double'
                    cont= uieditfield(grid,'numeric','ValueChangedFcn',@obj.MCChanged,'UserData',i);
                case 'datetime'
                    cont = uidatepicker(grid,'DisplayFormat','dd-MM-yyyy','ValueChangedFcn',@obj.MCChanged,'UserData',i);
            end
            
            cont.Layout.Row=i+1;
            cont.Layout.Column=2;
        end
    end
    
    methods %callbacks
        
        function MCChanged(obj,src,evnt)
            ID=obj.Parent.CurrIDSel;
            if ID>0
                i=src.UserData;
                type=obj.MarkerTable.Type{i}.Type;

                switch type
                    case 'double'
                        obj.DescTable{ID,i+1}={src.Value};
                    case 'string'
                        obj.DescTable(ID,i+1)={src.Items{src.Value}};
                    case 'datetime'
                        obj.DescTable{ID,i+1}={src.Value};
                end
                obj.Parent.RefreshSignalTable;
            end
        end
        
        
        function MAddDeskriptor(obj,src,~)
            AddDeskriptor(obj);
            RefreshUITable(obj);
        end
        
        function MUITableEdit(obj,src,evnt)
            UpdateUITable(obj);
            CheckClassType(obj);
        end
        
        function MTableRowSelect(obj,src,evnt)
            obj.IDCurrMarker=evnt.Indices(1);
            DrawClassType(obj);
        end
        
        function MRemoveDeskriptor(obj,src,~)
            RemoveDeskriptor(obj);
        end
        
        function MDrawMarkers(obj,~,~)
            UpdateUITable(obj);
            ClearGui(obj);
            DrawGui(obj);
            CheckMeasuredSignals(obj);
            obj.Parent.RefreshSignalTable;
            delete(obj.SelFig);
        end
    end
end
