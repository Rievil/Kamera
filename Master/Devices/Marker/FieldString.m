classdef FieldString < Field
    %FIELDSTRING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UnTable;
        UIUnTable;
        IDRow;
    end
    
    properties (Dependent)
        Count;
    end
        
    
    methods
        function obj = FieldString(parent)
            obj@Field(parent);
            obj.Type='string';
        end
        
        function count=get.Count(obj)
            count=size(obj.UnTable,1);
        end
            
    end
    
    methods %abstract
        function t=GetRow(obj)
            id=obj.Count+1;
            text=string(sprintf('Popis %d',id));
            t=table(text,'VariableNames',{'Class'});
        end
        
        function InitTable(obj)
            if isempty(obj.UnTable)
                AddClass(obj);
                obj.UnTable=GetRow(obj);
            end
        end
        
        function AddClass(obj)
            obj.UnTable=[obj.UnTable; GetRow(obj)];
        end
        
        function RemoveClass(obj)
            if obj.Count>0
                obj.UnTable(end,:)=[];
            end
        end
        
        function RefreshTable(obj)
            obj.UIUnTable.Data=obj.UnTable;
        end
        
        function stash=CoPack(obj)
            stash=struct;
            stash.UnTable=obj.UnTable;
        end
        
        
        function CoPopulate(obj,stash)
            obj.UnTable=stash.UnTable;    
        end

        
        function out=GetOutput(obj)
            if obj.Count>0
                out=string(obj.UnTable.Class);
            else
                out=strings(0,0);
            end
        end
        
        function DrawGui(obj)
            
            g=uigridlayout(obj.Fig);
            g.RowHeight = {25,'1x'};
            g.ColumnWidth = {'1x',75,75};
            
            InitTable(obj);
            
            uit=uitable(g,'Data',obj.UnTable,'ColumnEditable',true,'CellSelectionCallback',@obj.MTableRowSelect,...
                'CellEditCallback',@obj.MTableChange);
            uit.Layout.Row=2;
            uit.Layout.Column=[1 3];
            obj.UIUnTable=uit;
            
            but1=uibutton(g,'Text','Add class','ButtonPushedFcn',@obj.MAddClass);
            but1.Layout.Row=1;
            but1.Layout.Column=2;
            
            but2=uibutton(g,'Text','Remove class','ButtonPushedFcn',@obj.MRemoveClass);
            but2.Layout.Row=1;
            but2.Layout.Column=3;
        end
    end
    
    methods %callbacks
        function MAddClass(obj,~,~)
            AddClass(obj);
            RefreshTable(obj);
        end
        
        function MRemoveClass(obj,~,~)
            RemoveClass(obj);
            RefreshTable(obj);
        end
        
        function MTableRowSelect(obj,src,evnt)
            obj.IDRow=evnt.Indices(1);
        end
        
        function MTableChange(obj,~,~)
            obj.UnTable=obj.UIUnTable.Data;
        end
    end
end

