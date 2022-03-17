classdef Session < Module
    %SESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Folder char;
        FolderSet=false;
        ScheduleSet=false;
        ImageList table;
        DescList;      
        Timer;
        PhotoCount double;
        States;
        Sources;
        UITable;
        Memory table;
        MaxImInMemory=1;
        TNames;
        Init=false;
        StoreOverflow=true;
        SchedTable;
        StartDate datetime;
        FinStartDateTime datetime;
        EndDate datetime;
        MinutesStartSet=0;
        HourStartSet=0;
        EpochCount=1;
        RowSel;
        TimerRunning=false;
    end
    
    
    
    methods
        function obj = Session(parent)
            obj@Module(parent);
            obj.Timer = SessionTimer(obj);
            obj.PhotoCount=1;
            obj.States={'InMem','Saved','Deleted','Missing','Planned'};
            obj.Sources={'Manual','Automatic'};
            obj.TNames={'ID','Name','DateTime','Exposure','State','Source','Note','Img'};

            obj.StartDate=datetime(now(),'ConvertFrom','datenum','Format','dd-MM-yyyy');
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
            obj.EpochCount=size(obj.SchedTable,1);
        end
        
        function RemoveSchRow(obj)
            obj.SchedTable(end,:)=[];
            obj.EpochCount=size(obj.SchedTable,1);
        end


        function MakeStartDate(obj)
            obj.FinStartDateTime=obj.StartDate+hours(obj.HourStartSet)+minutes(obj.MinutesStartSet);
        end
        
        function T=MakeSchedule(obj)
            MakeStartDate(obj);
            T0=obj.SchedTable;
            schcount=size(T0,1);
            T=table;
            if schcount>0
                for i=1:schcount
                    T=[T; table(CameraTimer.GetTimeVar(char(T0.LengthType(i)),T0.nL(i)),...
                        CameraTimer.GetTimeVar(char(T0.PeriodType(i)),T0.nP(i)),'VariableNames',{'Len','Per'})];
                end
            end
        end
        
        function Tout=CreatePlan(obj)
            T=MakeSchedule(obj);
            x=[];
            y2=[];
            epoch=1;
            for i=1:size(T,1)
                len=seconds(T.Len(i));
                per=seconds(T.Per(i));

                count=len/per;
                time=linspace(per,per*count,count);
                period=linspace(per,per,count);

                y2=[y2; period'];

                if i>1
                    time=time+x(end);
                    x=[x; time'];
                else
                    x=[x; time'];
                end
                
                epoch=[epoch; linspace(i,i,numel(time))'];
            end

            x=[0; x];
            
            
            y2=[0; y2];
            x=seconds(x)+obj.FinStartDateTime;
            y=1:1:numel(x);
            y=y';
            Tout=table(x,y,y2,epoch,'VariableNames',{'Time','Count','Seconds','Etap'});
        end
        
        function CheckForOpenSession(obj)
            if ~isempty(obj.Folder)
                
                if exist(obj.Folder)
                    obj.FolderSet=true;
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
                        FillAppFields(obj);
                        CheckImageList(obj);

                        disp('Session successfully loaded ...');
                    elseif sum(A)==0
                        fprintf("No session found. Creating new session at path '%s' ...\n",obj.Folder);
                        Save(obj);
                    else
                        disp('Found multiple sessions, please pick which has to be loaded ...');
                        %have to add GUI whitch session to select
                    end
                else
                    obj.FolderSet=false;
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
            fprintf("... Session saved at path '%s'\n",filename);
        end
        
        function ResetList(obj)
            obj.ImageList=table([],[],[],[],[],[],[],{},'VariableNames',obj.TNames);
        end
        
        function StoreImage(obj,id)
            for i=1:numel(id,1)
%                 filename=[char(obj.Folder) '\' char(obj.)];
            end
        end
        
        function DrawSchedule(obj,exp)
            Tout=CreatePlan(obj);
            if size(obj.ImageList,1)>0
                obj.ImageList(obj.ImageList.State=="Planned",:)=[];
            end
            
            if size(Tout,1)>0
                obj.ScheduleSet=true;
                for i=1:size(Tout,1)
                    AddBlankImage(obj,{},Tout.Time(i),exp,"Planned","Automatic","-");
                end
            end
            
            
        end
        
        function StopScheduleShooting(obj)
            if obj.TimerRunning
                obj.TimerRunning=false;
                obj.Timer.ClearTimer;
            end
        end
        
        function state=CheckSchedule(obj)
            state=false;
            T=obj.ImageList(obj.ImageList.State=="Planned" & obj.ImageList.DateTime>date,:);
            if size(T,1)>0
                state=true;
                obj.ScheduleSet=true;
            end
        end
        
        function StartScheduleShooting(obj)
            if CheckSchedule(obj)
                date=datetime(now,'ConvertFrom','datenum','Format','dd-MM-yyyy HH-mm-ss');
                T=obj.ImageList(obj.ImageList.State=="Planned" & obj.ImageList.DateTime>date,:);
                if size(T,1)>0
                    obj.TimerRunning=true;
                    SetSpecificTimes(obj.Timer,obj.ImageList(obj.ImageList.State=="Planned",[1,2,3,4,5,6,7]));
                    StartTimer(obj.Timer);
                else
                    obj.TimerRunning=false;
                end
            end
        end
        
        function AddImage(obj,img,date,exp,state,source,note)
            obj.PhotoCount=obj.PhotoCount+1;
            
            name=sprintf("%d_image",obj.PhotoCount);
            obj.TNames={'ID','Name','DateTime','Exposure','State','Source','Note','Img'};
            T=table(obj.PhotoCount,name,date,exp,state,source,note,{img},...
                'VariableNames',obj.TNames);
            
            obj.ImageList=[obj.ImageList; T];
            obj.StoreOverflow=true;
            
            CheckMemory(obj);
        end
        
        function ShootPlannedImage(obj,id)
            idx=find(obj.ImageList.ID==id);
            
            cam=obj.Parent.Device;
            if cam.ExpTime~=obj.ImageList.Exposure(idx)
                cam.ExpTime=obj.ImageList.Exposure(idx);
                ChangeSettings(cam);
            end
            
            cam.LightUp;
            pause(0.5);
            
            img=GetCurrentImage(cam);
            
            cam.GoDark;
            
            obj.ImageList.Name(idx)=sprintf("%d_image",id);
            obj.ImageList.Img{idx}=img;
            obj.ImageList.State(idx)='InMem';
            obj.StoreOverflow=true;
            
            if obj.FolderSet
                StorePhoto(obj,id);
            end
            
            CheckMemory(obj);
            UpdateUITable(obj);
        end
        
        function AddBlankImage(obj,img,date,exp,state,source,note)
            name="-";
            obj.PhotoCount=obj.PhotoCount+1;
%             obj.TNames={'ID','Name','DateTime','Exposure','State','Source','Note','Img'};
            T=table(obj.PhotoCount,name,date,exp,state,source,note,{img},...
                'VariableNames',obj.TNames);
            
            obj.ImageList=[obj.ImageList; T];
            obj.StoreOverflow=true;
            
            CheckMemory(obj);
        end
        
        function str=Filename(obj,id)
            str=sprintf("%s\\%s.png",obj.Folder,obj.ImageList.Name(obj.ImageList.ID==id));
        end

        function CheckImageList(obj)
            disp('test');
            for i=1:size(obj.ImageList,1)
                filename=[char(obj.Folder) '\' char(obj.ImageList.Name(i)) '.png'];
                switch obj.ImageList.State(i)
                    case 'InMem'
                    case 'Saved'
                        if exist(filename)
                            obj.ImageList.State(i)="Saved";
                        else
                            obj.ImageList.State(i)="Missing";
                        end
                    case 'Planned'
                    otherwise
                end
            end
            obj.UITable.Data=obj.ImageList;
        end
        
        function CheckMemory(obj)
            if size(obj.ImageList,1)>0
                %Mem loop
                T=obj.ImageList(obj.ImageList.State=="InMem",:);

                if size(T,1)>obj.MaxImInMemory
                    count=size(obj.ImageList(obj.ImageList.State=="InMem",:),1)-obj.MaxImInMemory;
                    for i=1:count
                        try
                            DeleteImage(obj,min(obj.ImageList.ID(obj.ImageList.State=="InMem",:)));
                        catch
                            disp("You dont have permision to delete '%s'\n");
                        end
                    end
                end
            end
        end
        
        function UpdateUITable(obj)
            T=sortrows(obj.ImageList,'DateTime');
            if obj.Parent.UIFigBool
                obj.UITable.Data=T;

    %             obj.UITable.ColumnWidth ={10,0,35,25,25,25,25,0};
                removeStyle(obj.UITable);
                col=lines(4);
                s = uistyle('BackgroundColor',col(2,:));

                rownum=1:1:size(T,1);
                idx=rownum(T.State=="Planned")';
                colidx=linspace(1,1,numel(idx))';
                if sum(idx)>0
                    addStyle(obj.UITable,s,'cell',[idx,colidx]);
                end
            end
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
%                 Save(obj);
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
            stash.StartDate=obj.StartDate;
            stash.MinutesStartSet=obj.MinutesStartSet;
            stash.HourStartSet=obj.HourStartSet;
            stash.FinStartDateTime=obj.FinStartDateTime;
            stash.EpochCount=obj.EpochCount;
            stash.Timer=Pack(obj.Timer);
            stash.TimerRunning=obj.TimerRunning;
            stash.ScheduleSet=obj.ScheduleSet;
        end

        function FillAppFields(obj)
            obj.Parent.UISTable.Data=obj.SchedTable;
            obj.Parent.UIHours.Value=obj.HourStartSet;
            obj.Parent.UIMinutes.Value=obj.MinutesStartSet;
            obj.UITable.Data=obj.ImageList;
            obj.Parent.PlotScheduler;
            obj.Parent.UISpinner.Value=obj.EpochCount;
        end

        function Populate(obj,stash)
            
            fnames = fieldnames(stash);
            
            for i=1:numel(fnames)
                    switch fnames{i}
                        case 'Timer'
                            obj.Timer.Populate(stash.(fnames{i}));
                        otherwise
                            obj.(fnames{i})=stash.(fnames{i});
                    end
            end
            UpdateUITable(obj);
            
            if obj.TimerRunning
                msg = 'Unfinished running timer found, do you want to continue?';
                fig=obj.Parent.UIFig;
                selection = uiconfirm(fig,msg,'Continue in shooting?');
                switch selection
                    case 'OK'
                        StartScheduleShooting(obj);
                    case 'Cancel'
                        return
                end
                
            end
            
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

            uib1=uibutton(g,'Text','Delete image','ButtonPushedFcn',@obj.MDeleteImage);
            uib1.Layout.Row=3;
            uib1.Layout.Column=[3 4];
        end
    end
    
    methods %callbacks
        function MMaxMemCount(obj,src,~)
            obj.MaxImInMemory=src.Value;
            CheckMemory(obj);
        end
        
        
        function MRowSelect(obj,src,evnt)
            coor=evnt.Indices;
            ID=src.Data.ID(coor(1));
            ILRow=obj.ImageList.ID==ID;
%             ID=obj.ImageList.ID(coor(1));
            
            obj.RowSel=coor(1);
            switch lower(obj.ImageList.State(ILRow))
                case 'inmem'
                    img=obj.ImageList.Img{ILRow};
                    UpdateImage(obj.Parent,img);
                case 'saved'
                    file=Filename(obj,ID);
                    if exist(file)
                        img=imread(file);
                        UpdateImage(obj.Parent,img);
                    else
                        obj.ImageList.State(ILRow)='Missing';
                        obj.UITable.Data.State(coor(1))='Missing';
                    end
                case 'deleted'
                    
                case 'missing'
                    DrawMissingImage(obj.Parent);
                case 'planned'
                    DrawMissingImage(obj.Parent);
            end
            
            
        end

        function MDeleteImage(obj,~,~)
            if size(obj.ImageList,1)>1
                if obj.RowSel==0
                    obj.RowSel=size(obj.ImageList,1);
                end
                obj.ImageList.State(obj.RowSel)="Deleted";
                filename=[char(obj.Folder) '\' char(obj.ImageList.Name(obj.RowSel)) '.png'];
                delete(filename);
                
                obj.UITable.Data=obj.ImageList;
                obj.RowSel=0;
            end
        end
           
    end
end

