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
    end
    
    
    
    methods
        function obj = Session(parent)
            obj@Module(parent);
            obj.PhotoCount=1;
            obj.States={'InMem','Saved','Deleted','Missing'};
            obj.Sources={'Manual','Automatic'};
            obj.TNames={'ID','Name','DateTime','Exposure','State','Source','Note'};
        end
        
        function SetFolder(obj,folder)
            obj.Folder=folder;
            CheckForOpenSession(obj);
        end
        
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
            stash=obj.Pack;
            filename=[char(obj.Folder) '\Session.mat'];
            save(filename,'stash');
            fprintf("   Session saved at path '%s'\n",filename);
        end
        
        function ResetList(obj)

            obj.ImageList=table([],[],[],[],[],[],[],'VariableNames',obj.TNames);
            obj.Memory=table([],{},'VariableNames',{'ID','Img'});
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
            
            obj.Memory=[table(obj.PhotoCount,{img},'VariableNames',{'ID','Img'});...
                obj.Memory];
            
            T=table(obj.PhotoCount,name,date,desc.Exposure,string(state),...
                string(source),string(note),'VariableNames',obj.TNames);
            
            obj.ImageList=[obj.ImageList; T];
            
            
            if size(obj.Memory,1)>obj.MaxImInMemory
                ID=obj.Memory.ID(11:end);
                DeleteImage(obj,ID);
            end
            
%             obj.Memory{obj.PhotoCount}=img;
            

            
            obj.UITable.Data=obj.ImageList;
        end
        
        function DeleteImage(obj,id)
            for i=1:numel(id)
                obj.Memory(obj.Memory.ID==id(i),:)=[];
                obj.ImageList.State(obj.ImageList.ID==id(i))='Deleted';
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
        end
    end
    
    methods %callbacks
        function MRowSelect(obj,src,evnt)
            coor=evnt.Indices;
            ID=obj.ImageList.ID(coor(1));
            switch lower(obj.ImageList.State(coor(1)))
                case 'inmem'
                    img=obj.Memory.Img{obj.Memory.ID==ID};
                    UpdateImage(obj.Parent,img);
                case 'saved'
                    
                case 'deleted'
                    
                case 'missing'
                    
            end
            
            
        end
           
    end
end

