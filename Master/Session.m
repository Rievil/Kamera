classdef Session < Module
    %SESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Folder char;
        ImageList table;
        DescList;      
        PhotoCount double;
        States;
        Sources;
        UITable;
        Memory table;
        MaxImInMemory=10;
        TNames;
        Init=false;
        StoreOverflow=true;
        SchedTable;
        UISTable;
    end
    
    
    
    methods
        function obj = Session(parent)
            obj@Module(parent);
            obj.PhotoCount=1;
            obj.States={'InMem','Saved','Deleted','Missing'};
            obj.Sources={'Manual','Automatic'};
            obj.TNames={'ID','Name','DateTime','Exposure','State','Source','Note','Img'};
        end
        
        function SetFolder(obj,folder)
            obj.Folder=folder;
            CheckForOpenSession(obj);
        end
        
        function T=GetSchedRow(obj)
            lentype=categorical({'minute','hour','day','week'});
            
            T=table(lentype(1),1,lentype(1),1,'VariableNames',...
                {'LengthType','nL','PeriodType','nP'});
        end
        
        function AddSchRow(obj)
            obj.SchedTable=[obj.SchedTable; GetSchedRow(obj)];
        end
        
        function RemoveSchRow(obj)
            obj.SchedTable(end,:)=[];
        end
        
%         function SetSchTable(obj)
%         end
        
        function CheckForOpenSession(obj)
            if ~isempty(obj.Folder)
                if exist(obj.Folder)
                    files=struct2table(dir([char(obj.Folder) '\*.mat']));
                    names=lower(string(files.name));
                    
                    files.name=string(files.name);
                    files.folder=string(files.folder);
                    
                    A=contains(names,'session');
                    if sum(A)==1
                        fprintf("Found a session on path '%s'\n... loading ...",char(files.folder(A)));
                        filename=[char(files.folder(A)) '\' char(files.name(A))];
                        load(filename);
                        obj.Populate(stash);
                        disp('Session successfully loaded ...');
                    elseif sum(A)==0
                        fprintf("No session found. Creating new session at path '%s' ...\n",obj.Folder);
                        Save(obj);
                    else
                        disp('Found multiple sessions, please pick which has to be loaded ...');
                    end
                    
                end
            end
        end
        
        function delete(obj)
            obj.Save;
        end
        
        function Save(obj)
            obj.Init=true;
            if size(obj.ImageList,1)>0
                T=obj.ImageList(obj.ImageList.State=='InMem',:);
                for i=1:size(T,1)
                    StorePhoto(obj,T.ID(i));
                end
            end
            
            stash=obj.Pack;
            filename=[char(obj.Folder) '\Session.mat'];
            save(filename,'stash');
            fprintf("   Session saved at path '%s'\n",filename);
        end
        
        function ResetList(obj)

            obj.ImageList=table([],[],[],[],[],[],[],{},'VariableNames',obj.TNames);
%             obj.Memory=table([],{},'VariableNames',{'ID','Img'});
        end
        
        function StoreImage(obj,id)
            for i=1:numel(id,1)
%                 filename=[char(obj.Folder) '\' char(obj.)];
            end
        end
        
        function AddImage(obj,img,desc,state,source,note)
            obj.PhotoCount=obj.PhotoCount+1;
            
            name=sprintf("%d_image",obj.PhotoCount);
            date=datetime(now,'ConvertFrom','datenum','Format','dd-MM-yyyy hh-mm-ss');
            
%             obj.Memory=[table(obj.PhotoCount,{img},'VariableNames',{'ID','Img'});...
%                 obj.Memory];
            
            T=table(obj.PhotoCount,name,date,desc.Exposure,string(state),...
                string(source),string(note),{img},'VariableNames',obj.TNames);
            
            obj.ImageList=[obj.ImageList; T];
            obj.StoreOverflow=true;
            
            CheckMemory(obj)
            
        end
        
        function str=Filename(obj,id)
            str=sprintf("%s\\%s.png",obj.Folder,obj.ImageList.Name(obj.ImageList.ID==id));
        end
        
        function CheckMemory(obj)
            if size(obj.ImageList,1)>0
                %Mem loop
                T=obj.ImageList(obj.ImageList.State=='InMem',:);

                if size(T,1)>obj.MaxImInMemory
                    count=size(obj.ImageList(obj.ImageList.State=='InMem',:),1)-obj.MaxImInMemory;
                    for i=1:count
                        DeleteImage(obj,min(obj.ImageList.ID(obj.ImageList.State=='InMem',:)));
                    end
                end
            end
            UpdateUITable(obj);
        end
        
        function UpdateUITable(obj)
            obj.UITable.Data=obj.ImageList;
        end
        
        function DeleteImage(obj,id)
            for i=1:numel(id)
                
                if obj.StoreOverflow
                    StorePhoto(obj,id);
                else
                    obj.ImageList.State(obj.ImageList.ID==id(i))='Deleted';
                end
                
                obj.ImageList.Img{obj.ImageList.ID==id(i),:}=[];
            end
        end
        
        function StorePhoto(obj,id)
            row=obj.ImageList.ID==id;
            img=obj.ImageList.Img{row};
            if size(img,1)>0
                imwrite(img,Filename(obj,id),'png');
                obj.ImageList.State(row)='Saved';
                obj.ImageList.Img{row}=[];
            end
        end
    end
    
    methods %Abstract
        function stash=Pack(obj)
            stash=struct;
            stash.ImageList=obj.ImageList;
            stash.PhotoCount=obj.PhotoCount;
            stash.DescList=obj.DescList;
            stash.Init=obj.Init;
            stash.Memory=obj.Memory;
            stash.MaxImInMemory=obj.MaxImInMemory;
            stash.StoreOverflow=obj.StoreOverflow;
            stash.SchedTable=obj.SchedTable;
        end
        
        function Populate(obj,stash)
            
            fnames = fieldnames(stash);
            
            for i=1:numel(fnames)
                if isfield(stash,'Init')
                    obj.(fnames{i})=stash.(fnames{i});
                end
            end

            obj.UITable.Data=obj.ImageList;
        end
        
        function DrawGui(obj)
            g = uigridlayout(obj.Fig);
            g.RowHeight = {'1x',25,25,25,25};
            g.ColumnWidth = {25,'1x',50,50};
            
            ResetList(obj);
            uit=uitable(g,'Data',obj.ImageList,'CellSelectionCallback',@obj.MRowSelect );
            uit.Layout.Row=1;
            uit.Layout.Column=[1 4];
            obj.UITable=uit;
            
            la1=uilabel(g,'Text','Max. img in mem:');
            la1.Layout.Row=2;
            la1.Layout.Column=[1 2];
            
            ed1=uieditfield(g,'numeric','Value',obj.MaxImInMemory,'Limits',[0 10],...
                'ValueChangedFcn',@obj.MMaxMemCount);
            ed1.Layout.Row=2;
            ed1.Layout.Column=[3 4];
            
        end
    end
    
    methods %callbacks
        function MMaxMemCount(obj,src,~)
            obj.MaxImInMemory=src.Value;
            CheckMemory(obj);
        end
        
        
        function MRowSelect(obj,src,evnt)
            coor=evnt.Indices;
            ID=obj.ImageList.ID(coor(1));
            switch lower(obj.ImageList.State(coor(1)))
                case 'inmem'
                    img=obj.ImageList.Img{obj.ImageList.ID==ID};
                    UpdateImage(obj.Parent,img);
                case 'saved'
                    file=Filename(obj,ID);
                    if exist(file)
                        img=imread(file);
                        UpdateImage(obj.Parent,img);
                    else
                        obj.ImageList.State(obj.ImageList.ID==ID)='Missing';
                        obj.UITable.Data.State(obj.ImageList.ID==ID)='Missing';
                    end
                case 'deleted'
                    
                case 'missing'
                    DrawMissingImage(obj.Parent);
            end
            
            
        end
           
    end
end

