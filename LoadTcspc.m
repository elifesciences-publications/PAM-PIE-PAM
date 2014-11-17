function LoadTcspc(~,~,Update_Data,Calibrate_Detector,Caller)
global UserValues TcspcData FileInfo

%%% Dialog box for selecting files to be loaded
[FileName, Path, Type] = uigetfile({'*0.spc','B&H-SPC files recorded with FabSurf (*0.spc)';...
                                    '*_m1.spc','B&H-SPC files recorded with B&H-Software (*_m1.spc)'}, 'Choose a TCSPC data file',UserValues.File.Path,'MultiSelect', 'on');
%%% Only execues if any file was selected
if iscell(FileName) || ~all(FileName==0)    
    %%% Transforms FileName into cell, if it is not already
    %%%(e.g. when only one file was selected)
    if ~iscell(FileName)
        FileName={FileName};
    end
    %%% Saves Path
    UserValues.File.Path=Path;
    LSUserValues(1);
    %%% Sorts FileName by alphabetical order
    FileName=sort(FileName);
    %%% Clears previously loaded data
    FileInfo=[];
    TcspcData.MT=cell(1,1);
    TcspcData.MI=cell(1,1);
    
    %%% Findes handles for progress axes and text
    h=guidata(Caller);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Checks which file type was selected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch (Type)        
        case 1 
            %% 1: .spc Files generated with Fabsurf    
            FileInfo.FileType = 'FabsurfSPC';
            %%% Reads info file generated by Fabsurf
            FileInfo.Fabsurf=FabsurfInfo(fullfile(Path,FileName{1}));
            %%% General FileInfo
            FileInfo.NumberOfFiles=numel(FileName);
            FileInfo.Type=Type;
            FileInfo.MI_Bins=4096;
            FileInfo.MeasurementTime=FileInfo.Fabsurf.Imagetime/1000;
            FileInfo.SyncPeriod=FileInfo.Fabsurf.RepRate/1000;
            FileInfo.Lines=FileInfo.Fabsurf.Imagelines;
            FileInfo.LineTimes=zeros(FileInfo.Lines+1,numel(FileName));
            FileInfo.Pixels=FileInfo.Fabsurf.Imagelines^2;   
            FileInfo.FileName=FileName;
            FileInfo.Path=Path;
            %%% Initializes microtime and macotime arrays
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));  
            
            Totaltime=0;
            %%% Reads all selected files
            for i=1:numel(FileName)               
                %%% Calculates Imagetime in clock ticks for concaternating
                %%% files                
                Info=FabsurfInfo(fullfile(Path,FileName{i}),1);
                Imagetime=round(Info.Imagetime/1000/FileInfo.SyncPeriod);
                %%% Checks, which cards to load
                card=unique(UserValues.Detector.Det);
                %%% Checks, which and how many card exist for each file
                for j=card;
                    if ~exist(fullfile(Path,[FileName{i}(1:end-5) num2str(j-1) '.spc']),'file')
                        card(card==j)=[];
                    end
                end                
                
                Linetimes=[];
                %%% Reads data for each tcspc card
                for j=card
                    %%% Update Progress
                    Progress((i-1)/numel(FileName)+(j-1)/numel(card)/numel(FileName),h.Progress_Axes, h.Progress_Text,['Loading File ' num2str((i-1)*numel(card)+j) ' of ' num2str(numel(FileName)*numel(card))]);
                    
                    %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
                    [MT, MI, PLF,~] = Read_BH(fullfile(Path,[FileName{i}(1:end-5) num2str(j-1) '.spc']),Inf,[0 0 0]);
                    %%% Finds, which routing bits to use
                    Rout=unique(UserValues.Detector.Rout(UserValues.Detector.Det==j))';
                    Rout(Rout>numel(MI))=[];
                    %%% Concaternates data to previous files and adds Imagetime
                    %%% to consecutive files
                    if any(~cellfun(@isempty,MI))
                        for k=Rout
                            %%% Removes photons detected after "official"
                            %%% end of file are discarded
                            MI{k}(MT{k}>Imagetime)=[];
                            MT{k}(MT{k}>Imagetime)=[];
                            TcspcData.MT{j,k}=[TcspcData.MT{j,k}; Totaltime + MT{k}];   MT{k}=[];
                            TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{k}];   MI{k}=[];
                        end
                    end
                    %%% Determines last photon for each file
                    for k=find(~cellfun(@isempty,TcspcData.MT(j,:)));
                        FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
                    end
                    
                    %%% Determines, if linesync was used
                    if isempty(Linetimes) && ~isempty(PLF{1})
                        Linetimes=[0 PLF{1}];
                    elseif isempty(Linetimes) && ~isempty(PLF{2})
                        Linetimes=[0 PLF{2}];
                    elseif isempty(Linetimes) && ~isempty(PLF{3})
                        Linetimes=[0 PLF{3}];
                    end
                end 
                %%% Creates linebreak entries
                if isempty(Linetimes)
                    FileInfo.LineTimes(:,i)=linspace(0,FileInfo.MeasurementTime/FileInfo.SyncPeriod,FileInfo.Lines+1)+Totaltime;
                elseif numel(Linetimes)==FileInfo.Lines+1
                    FileInfo.LineTimes(:,i)=Linetimes+Totaltime;                    
                elseif numel(Linetimes)<FileInfo.Lines+1
                    %%% I was to lazy to program this case out yet
                end
                %%% Calculates total time to get one trace from several
                %%% files
                Totaltime=Totaltime + Imagetime;

            end
        case 2
            %% 2: .spc Files generated with B&H Software
            %%% Usually, here no Imaging Information is needed
            FileInfo.FileType = 'SPC';           
            %%% General FileInfo
            FileInfo.NumberOfFiles=numel(FileName);
            FileInfo.Type=Type;
            FileInfo.MI_Bins=4096;
            FileInfo.MeasurementTime=[];
            FileInfo.SyncPeriod= [];
            FileInfo.TACRange = [];
            FileInfo.Lines=1;
            FileInfo.LineTimes=[];
            FileInfo.Pixels=1;   
            FileInfo.FileName=FileName;
            FileInfo.Path=Path;
            
            %%% Initializes microtime and macotime arrays
            TcspcData.MT=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));
            TcspcData.MI=cell(max(UserValues.Detector.Det),max(UserValues.Detector.Rout));  
            
            %%% Reads all selected files
            for i=1:numel(FileName)
                %%% there are a number of *_m(i).spc files associated with the
                %%% *_m1.spc file
                
                %%% Checks, which cards to load
                card=unique(UserValues.Detector.Det);
                %%% Checks, which and how many card exist for each file
                for j=card;
                    if ~exist(fullfile(Path,[FileName{i}(1:end-5) num2str(j) '.spc']),'file')
                        card(card==j)=[];
                    end
                end      
                Progress((i-1)/numel(FileName),h.Progress_Axes, h.Progress_Text,'Loading:');           
                
                %%% if multiple files are loaded, consecutive files need to
                %%% be offset in time with respect to the previous file
                MaxMT = 0;
                if any(~cellfun(@isempty,TcspcData.MT))
                    MaxMT = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))));
                end
                %%% Reads data for each tcspc card
                for j=card    
                    %%% Update Progress
                    Progress((i-1)/numel(FileName)+(j-1)/numel(card)/numel(FileName),h.Progress_Axes, h.Progress_Text,['Loading File ' num2str((i-1)*numel(card)+j) ' of ' num2str(numel(FileName)*numel(card))]);
                    %%% Reads Macrotime (MT, as double) and Microtime (MI, as uint 16) from .spc file
                    [MT, MI, ~, SyncRate] = Read_BH(fullfile(Path,[FileName{i}(1:end-5) num2str(j) '.spc']),Inf,[0 0 0]);
                    
                    if isempty(FileInfo.SyncPeriod)
                        FileInfo.SyncPeriod = 1/SyncRate;
                    end
                    %%% Finds, which routing bits to use
                    Rout=unique(UserValues.Detector.Rout(UserValues.Detector.Det==j))';
                    Rout(Rout>numel(MI))=[];
                    %%% Concaternates data to previous files and adds Imagetime
                    %%% to consecutive files
                    if any(~cellfun(@isempty,MI))
                        for k=Rout
                            TcspcData.MT{j,k}=[TcspcData.MT{j,k}; MaxMT + MT{k}];   MT{k}=[];
                            TcspcData.MI{j,k}=[TcspcData.MI{j,k}; MI{k}];   MI{k}=[];
                        end
                    end
                    %%% Determines last photon for each file
                    for k=find(~cellfun(@isempty,TcspcData.MT(j,:)));
                        FileInfo.LastPhoton{j,k}(i)=numel(TcspcData.MT{j,k});
                    end
                end
            end
            FileInfo.MeasurementTime = max(cellfun(@max,TcspcData.MT(~cellfun(@isempty,TcspcData.MT))))*FileInfo.SyncPeriod;
            FileInfo.LineTimes = [0 FileInfo.MeasurementTime];
            try 
                %%% try to read the TACRange from the *_m1.set file
                FileInfo.TACRange = GetTACrange(fullfile(FileInfo.Path,[FileInfo.FileName{1}(1:end-3) 'set']));
            catch 
                %%% instead, approximate the TAC range from the microtime
                %%% range and Repetition Rate
                MicrotimeRange = double(max(cellfun(@(x) max(x)-min(x),TcspcData.MI(~cellfun(@isempty,TcspcData.MI)))));
                FileInfo.TACRange = (FileInfo.MI_Bins/MicrotimeRange)*FileInfo.SyncPeriod;
            end
    end
Progress(1,h.Progress_Axes, h.Progress_Text);
%%% Applies detector shift immediately after loading data    
Calibrate_Detector([],[],0) 
%%% Updates the Pam meta Data; needs inputs 3 and 4 to be zero
Update_Data([],[],0,0);  
end

function [TACrange] = GetTACrange(FileName)
%%% This functions reads out the set TAC range from the *.set file
%%% generated by the B&H software

%read data into array
TextArray = importdata(FileName);

%find the cells with TAC range and gain

%TAC range is given by 'SP_TAC_R'
idx_range = find(~cellfun(@isempty, (strfind(TextArray, 'SP_TAC_R'))));
dummy = strsplit(TextArray{idx_range},',');
%now the last element contains the value
range = dummy{end};
%last character is a ']'
range = str2double(range(1:end-1));
%TAC gain is given by 'SP_TAC_G'
idx_gain = find(~cellfun(@isempty, (strfind(TextArray, 'SP_TAC_G'))));
dummy = strsplit(TextArray{idx_gain},',');
gain = dummy{end};
gain = str2double(gain(1:end-1));

%calculate the TACrange
TACrange = range/gain;


