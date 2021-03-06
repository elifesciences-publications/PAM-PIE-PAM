function Sim(~,~)
global UserValues SimData PathToApp
h.Sim=findobj('Tag','Sim');

if ~isempty(h.Sim) % Creates new figure, if none exists
    return
end

addpath(genpath(['.' filesep 'functions']));

if isempty(PathToApp)
    GetAppFolder();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Loads user profile
LSUserValues(0);
%%% To save typing
Look=UserValues.Look;
%%% Generates the Sim figure

h.Sim = figure(...
    'Units','normalized',...
    'Tag','Sim',...
    'Name','Simulations for PAM',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'UserData',[],...
    'OuterPosition',[0.01 0.1 0.98 0.9],...
    'CloseRequestFcn',@Close_Sim,...
    'Visible','on');

%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes Pam background; must be called after whitebg
h.Sim.Color=Look.Back;

%%% Main Sim Panel
h.Sim_Panel = uibuttongroup(...
    'Parent',h.Sim,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Progressbar and file name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% Panel for progressbar
h.Progress_Panel = uibuttongroup(...
    'Parent',h.Sim,...
    'Tag','Progress_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.004 0.955 0.992 0.035]);
%%% Axes for progressbar
h.Progress_Axes = axes(...
    'Parent',h.Progress_Panel,...
    'Tag','Progress_Axes',...
    'Units','normalized',...
    'Color',Look.Control,...
    'Position',[0 0 1 1]);
h.Progress_Axes.XTick=[]; h.Progress_Axes.YTick=[];
%%% Progress and filename text
h.Progress_Text=text(...
    'Parent',h.Progress_Axes,...
    'Tag','Progress_Text',...
    'Units','normalized',...
    'FontSize',12,...
    'FontWeight','bold',...
    'String','',...
    'Interpreter','none',...
    'HorizontalAlignment','center',...
    'BackgroundColor','none',...
    'Color',Look.Fore,...
    'Position',[0.5 0.5]);

%% File parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General Sim Settings Panel
h.Sim_File_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Files',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.502 0.75 0.496 0.2]);

%%% Button to start simulation
h.Sim_Start = uicontrol(...
    'Parent',h.Sim_File_Panel,...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Start',...
    'Callback',@Start_Simulation,...
    'Position',[0.01 0.8 0.1 0.15]);

%%% Checkbox for saving files
h.Sim_Save = uicontrol(...
    'Parent',h.Sim_File_Panel,...
    'Units','normalized',...
    'Style','popup',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Value',3,...
    'String',{'Save to workspace', 'Save as TIFFs', 'Save as .sim'},...
    'Position',[0.12 0.8 0.25 0.15]);
if ismac
    h.Sim_Save.ForegroundColor = [0 0 0];
    h.Sim_Save.BackgroundColor = [1 1 1];
end
%%% Button to select filepath
h.Sim_Folder = uicontrol(...
    'Parent',h.Sim_File_Panel,...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Path:',...
    'Callback',@Sim_Settings,...
    'Position',[0.38 0.8 0.1 0.15]);

%%% Editbox for filepath
h.Sim_Path = uicontrol(...
    'Parent',h.Sim_File_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',UserValues.File.SimPath,...
    'Position',[0.49 0.8 0.5 0.15]);

%%% Editbox for filename
h.Sim_FileName = uicontrol(...
    'Parent',h.Sim_File_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'HorizontalAlignment', 'left',...
    'String','Simulation1',...
    'Callback',@Sim_Settings,...
    'Position',[0.01 0.63 0.49 0.15]);

%%% Multicore support
h.Sim_MultiCore = uicontrol(...
    'Parent',h.Sim_File_Panel,...
    'Units','normalized',...
    'Style','checkbox',...
    'FontSize',12,...
    'Value', 1,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Use Multicore',...
    'Callback',@Sim_Settings,...
    'Position',[0.51 0.63 0.49 0.15]);

%%% Button to start simulation
h.Sim_File_List = uicontrol(...
    'Parent',h.Sim_File_Panel,...
    'Units','normalized',...
    'Style','list',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'String',{'Simulation1'},...
    'Callback', {@File_List_Callback,3},...
    'KeyPressFcn',{@File_List_Callback,0},...
    'Position',[0.01 0.01 0.98 0.6]);

%% General parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% General Sim Settings Panel
h.Sim_General_Panel = uibuttongroup(...
    'Parent',h.Sim,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Title', 'General Settings',...
    'Position', [0.002 0.75 0.496 0.2]);
%%% Scanning type selection
h.Sim_Scan = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','popup',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'Point','Raster','Line','Circle','Camera'},...
    'Callback',@Sim_Settings,...
    'Position',[0.01 0.8 0.12 0.15]);
if ismac
    h.Sim_Scan.ForegroundColor = [0 0 0];
    h.Sim_Scan.BackgroundColor = [1 1 1];
end
%%% Text
h.Text_BS = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Box Size X/Y/Z [nm]:',...
    'Position',[0.01 0.62 0.25 0.1]);
%%% Editboxes for Boxsize
for i=1:3
    h.Sim_BS{i} = uicontrol(...
        'Parent',h.Sim_General_Panel,...
        'Units','normalized',...
        'Style','edit',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','5000',...
        'Callback',@Sim_Settings,...
        'Position',[0.26+(i-1)*0.1 0.62 0.09 0.1]);
end

%%% Text
h.Text_MIRange = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Microtime Range [ns]:',...
    'Position',[0.63 0.62 0.23 0.1]);

h.Sim_MIRange = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','edit',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','80',...
    'Callback',@Sim_Settings,...
    'Position',[0.86 0.62 0.09 0.1]);
           
%%% Text
h.Text_SF = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Sim Frequency [khz]:',...
    'Position',[0.01 0.5 0.25 0.1]);
%%% Simulation Frequency
h.Sim_Freq = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1000',...
    'Callback',@Sim_Settings,...
    'Position',[0.26 0.5 0.09 0.1]);
%%% Text
h.Text_ST = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Sim Time [s]:',...
    'Position',[0.01 0.38 0.25 0.1]);
%%% Simulation Time
h.Sim_Time = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','10',...
    'Callback',@Sim_Settings,...
    'Position',[0.26 0.38 0.09 0.1]);
%%% Text
h.Text_F = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Frames:',...
    'Position',[0.36 0.38 0.09 0.1]);
%%% Number of Frames
h.Sim_Frames = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','10',...
    'Callback',@Sim_Settings,...
    'Position',[0.56 0.38 0.09 0.1]);
%%% Text
h.Text_P{1} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Pixels in X:',...
    'Position',[0.01 0.26 0.25 0.1]);
%%% Number of pixels in x
h.Sim_Px{1} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','100',...
    'Callback',@Sim_Settings,...
    'Position',[0.26 0.26 0.09 0.1]);
%%% Text
h.Text_S{1}= uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Pixel size [nm]:',...
    'Position',[0.36 0.26 0.19 0.1]);
%%% Pixel size in x
h.Sim_Size{1} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','50',...
    'Callback',@Sim_Settings,...
    'Position',[0.56 0.26 0.09 0.1]);
%%% Text
h.Text_D{1} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Size in X [nm]:',...
    'Position',[0.66 0.26 0.19 0.1]);
%%% Scan range in x
h.Sim_Dim{1} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','5000',...
    'Callback',@Sim_Settings,...
    'Position',[0.86 0.26 0.09 0.1]);
%%% Text
h.Text_P{2} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Lines in Y:',...
    'Position',[0.01 0.14 0.25 0.1]);
%%% Number of lines in y
h.Sim_Px{2} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','100',...
    'Callback',@Sim_Settings,...
    'Position',[0.26 0.14 0.09 0.1]);
%%% Text
h.Text_S{2} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Line distance [nm]:',...
    'Position',[0.36 0.14 0.19 0.1]);
%%% Pixel size in x
h.Sim_Size{2} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','50',...
    'Callback',@Sim_Settings,...
    'Position',[0.56 0.14 0.09 0.1]);
%%% Text
h.Text_D{2} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Size in Y [nm]:',...
    'Position',[0.66 0.14 0.19 0.1]);
%%% Scan range in x
h.Sim_Dim{2} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','5000',...
    'Callback',@Sim_Settings,...
    'Position',[0.86 0.14 0.09 0.1]);
%%% Text
h.Text_T{1} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Pixel time [?s]:',...
    'Position',[0.01 0.02 0.25 0.1]);
%%% Pixel time in x
h.Sim_Px_Time{1} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','100',...
    'Callback',@Sim_Settings,...
    'Position',[0.26 0.02 0.09 0.1]);
%%% Text
h.Text_T{2} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Line time [ms]:',...
    'Position',[0.36 0.02 0.19 0.1]);
%%% Line time in y
h.Sim_Px_Time{2} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','10',...
    'Callback',@Sim_Settings,...
    'Position',[0.56 0.02 0.09 0.1]);
%%% Text
h.Text_T{3} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Frame time [s]:',...
    'Position',[0.66 0.02 0.25 0.1]);
%%% Frame time
h.Sim_Px_Time{3} = uicontrol(...
    'Parent',h.Sim_General_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Callback',@Sim_Settings,...
    'Position',[0.86 0.02 0.09 0.1]);

%% Species parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General Sim Settings Panel
h.Sim_Species_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Species Settings',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.002 0.5 0.496 0.25]);

%%% Button to start simulation
h.Sim_List = uicontrol(...
    'Parent',h.Sim_Species_Panel,...
    'Units','normalized',...
    'Style','list',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'String',{'Species 1'},...
    'Callback', {@Species_List_Callback,3},...
    'KeyPressFcn',{@Species_List_Callback,0},...
    'Position',[0.01 0.01 0.19 0.98]);

%%% Species Name
h.Sim_Name = uicontrol(...
    'Parent',h.Sim_Species_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Species 1',...
    'Callback',@Sim_Settings,...
    'Position',[0.21 0.9 0.78 0.1]);

%%% Color selection
h.Sim_Color = uicontrol(...
    'Parent',h.Sim_Species_Panel,...
    'Units','normalized',...
    'Style','popup',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'1Color','2Color','3Color','4Color'},...
    'Callback',@Sim_Settings,...
    'Position',[0.21 0.78 0.12 0.1]);
if ismac
    h.Sim_Color.ForegroundColor = [0 0 0];
    h.Sim_Color.BackgroundColor = [1 1 1];
end

%%% FRET type selection
h.Sim_FRET = uicontrol(...
    'Parent',h.Sim_Species_Panel,...
    'Units','normalized',...
    'Style','popup',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'No FRET','Static FRET','Dynamic FRET'},...
    'Callback',@Sim_Settings,...
    'Position',[0.34 0.78 0.2 0.1]);
if ismac
    h.Sim_FRET.ForegroundColor = [0 0 0];
    h.Sim_FRET.BackgroundColor = [1 1 1];
end
%%% Barrier type selection
h.Sim_Barrier = uicontrol(...
    'Parent',h.Sim_Species_Panel,...
    'Units','normalized',...
    'Style','popup',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'Free Diffusion','Free Diffusion with quenching','Restricted Zones','Diffusion Barriers','Asymmetric Diffusion Barriers','Dynamic Restricted Zones','Dynamic Diffusion Barriers','Different Diffusion Parameters'},...
    'Callback',@Sim_Settings,...
    'Position',[0.55 0.78 0.25 0.1]);
if ismac
    h.Sim_Barrier.ForegroundColor = [0 0 0];
    h.Sim_Barrier.BackgroundColor = [1 1 1];
end
%%% Text
h.Text_Brightness = uicontrol(...
    'Parent',h.Sim_Species_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',... 
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String',{'Brightness', '[kHz]'},...
    'Position',[0.31 0.56 0.12 0.18]);
%%% Text
h.Text_Focus_Size = uicontrol(...
    'Parent',h.Sim_Species_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String',{'Focus Size [nm]', 'Lateral/Axial '},...
    'Position',[0.44 0.56 0.18 0.18]);
%%% Text
h.Text_Focus_Shift = uicontrol(...
    'Parent',h.Sim_Species_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Focus Shift in X\Y\Z [nm]',...
    'Position',[0.63 0.56 0.28 0.12]);


for i=1:4
    %%% Text
    h.Text_Color{i} = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i) ':'],...
        'Position',[0.21 0.54-0.1*i 0.1 0.08]);
    %%% Brightness 
    h.Sim_Brightness{i} = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','1000',...
        'Callback',@Sim_Settings,...
        'Position',[0.33 0.54-0.1*i 0.08 0.08]);
    %%% Focus size lateral
    h.Sim_wr{i} = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','200',...
        'Callback',@Sim_Settings,...
        'Position',[0.45 0.54-0.1*i 0.08 0.08]);
    %%% Focus size axial
    h.Sim_wz{i} = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','0',...
        'Callback',@Sim_Settings,...
        'Position',[0.54 0.54-0.1*i 0.06 0.08]);
    %%% Focus Shift X
    h.Sim_dX{i} = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','1000',...
        'Callback',@Sim_Settings,...
        'Position',[0.64 0.54-0.1*i 0.08 0.08]);
    %%% Focus Shift Y
    h.Sim_dY{i} = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','0',...
        'Callback',@Sim_Settings,...
        'Position',[0.73 0.54-0.1*i 0.08 0.08]);
    %%% Focus Shift X
    h.Sim_dZ{i} = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','0',...
        'Callback',@Sim_Settings,...
        'Position',[0.82 0.54-0.1*i 0.08 0.08]);
end
    h.Text_Diff = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','D [?m?/s]:',...
        'Position',[0.21 0.04 0.12 0.08]);
    h.Sim_D = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','1',...
        'Callback',@Sim_Settings,...
        'Position',[0.33 0.04 0.08 0.08]);    
    h.Text_N = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String','Number of particles:',...
        'Position',[0.5 0.04 0.22 0.08]);
    h.Sim_N = uicontrol(...
        'Parent',h.Sim_Species_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','edit',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'String','10',...
        'Callback',@Sim_Settings,...
        'Position',[0.73 0.04 0.08 0.08]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

%% Advanced parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Sim Settings Panel
h.Sim_Advanced_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Advanced Settings',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.502 0.5 0.246 0.25]);
%%% Parameter display selection
h.Sim_Param_Plot = uicontrol(...
    'Parent',h.Sim_Advanced_Panel,...
    'Units','normalized',...
    'Style','popup',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String',{'Excitation probability','Crosstalk','Detection probability','Bleaching probability'},...
    'Callback',@Sim_Settings,...
    'Position',[0.02 0.88 0.5 0.1]);
if ismac
        h.Sim_Param_Plot.ForegroundColor = [0 0 0];
        h.Sim_Param_Plot.BackgroundColor = [1 1 1];
end
%%% Text
h.Text_FromTo = uicontrol(...
    'Parent',h.Sim_Advanced_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','From \ To',...
    'Position',[0.02 0.74 0.24 0.08]);

for i=1:4
    %%% Text
    h.Text_Param1{i} = uicontrol(...
        'Parent',h.Sim_Advanced_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i) ':'],...
        'Position',[0.02 0.74-0.15*i 0.2 0.08]);
    %%% Text
    h.Text_Param2{i} = uicontrol(...
        'Parent',h.Sim_Advanced_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i) ':'],...
        'Position',[0.05+0.19*i 0.74 0.19 0.08]);
   for j=1:4
       %%% Brightness
       h.Sim_Param{i,j} = uicontrol(...
           'Parent',h.Sim_Advanced_Panel,...
           'Units','normalized',...
           'FontSize',12,...
           'Style','edit',...
           'BackgroundColor', Look.Control,...
           'ForegroundColor', Look.Fore,...
           'String','1',...
           'Callback',@Sim_Settings,...
           'Position',[0.06+0.19*i 0.74-0.15*j 0.16 0.08]);             
   end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Lifetime parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Sim Settings Panel
h.Sim_Lifetime_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Lifetime Settings',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.752 0.5 0.121 0.25]);
%%% Parameter display selection
h.Sim_UseLT = uicontrol(...
    'Parent',h.Sim_Lifetime_Panel,...
    'Units','normalized',...
    'Style','checkbox',...
    'FontSize',12,...
    'Value', 1,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Use Lifetime [ns]',...
    'Callback',@Sim_Settings,...
    'Position',[0.04 0.88 0.92 0.1]);
   for i=1:4
       h.Text_LT{i} = uicontrol(...
           'Parent',h.Sim_Lifetime_Panel,...
           'Units','normalized',...
           'FontSize',12,...
           'HorizontalAlignment','left',...
           'Style','text',...
           'BackgroundColor', Look.Back,...
           'ForegroundColor', Look.Fore,...
           'String',['Color ', num2str(i), ':'],...
           'Position',[0.04 0.74-0.15*i 0.38 0.08]);
       h.Sim_LT{i} = uicontrol(...
           'Parent',h.Sim_Lifetime_Panel,...
           'Units','normalized',...
           'FontSize',12,...
           'Style','edit',...
           'BackgroundColor', Look.Control,...
           'ForegroundColor', Look.Fore,...
           'String','4.0',...
           'Callback',@Sim_Settings,...
           'Position',[0.5 0.74-0.15*i 0.38 0.08]);             
   end
%%% IRF parameters
h.Sim_UseIRF = uicontrol(...
    'Parent',h.Sim_Lifetime_Panel,...
    'Units','normalized',...
    'Style','checkbox',...
    'FontSize',12,...
    'Value', 0,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Include IRF? Width [ps]:',...
    'Callback',@Sim_Settings,...
    'Position',[0.04 0.78 0.92 0.1]);

h.Sim_IRF_Width_Edit = uicontrol(...
    'Parent',h.Sim_Lifetime_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'Value', 1,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','250',...
    'Callback',@Sim_Settings,...
    'Position',[0.695 0.78 0.195 0.08]);
%% Noise parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Sim Settings Panel
h.Sim_Noise_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Noise Settings',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.877 0.5 0.121 0.25]);
%%% Parameter display selection
h.Sim_UseNoise = uicontrol(...
    'Parent',h.Sim_Noise_Panel,...
    'Units','normalized',...
    'Style','checkbox',...
    'FontSize',12,...
    'Value', 0,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Apply Noise [kHz]',...
    'Callback',@Sim_Settings,...
    'Position',[0.04 0.88 0.92 0.1]);

   for i=1:4
       %%% Noise
       h.Text_Noise{i} = uicontrol(...
           'Parent',h.Sim_Noise_Panel,...
           'Units','normalized',...
           'FontSize',12,...
           'HorizontalAlignment','left',...
           'Style','text',...
           'BackgroundColor', Look.Back,...
           'ForegroundColor', Look.Fore,...
           'String',['Color ', num2str(i), ':'],...
           'Position',[0.04 0.74-0.15*i 0.38 0.08]);
       
       %%% Noise
       h.Sim_Noise{i} = uicontrol(...
           'Parent',h.Sim_Noise_Panel,...
           'Units','normalized',...
           'FontSize',12,...
           'Style','edit',...
           'BackgroundColor', Look.Control,...
           'ForegroundColor', Look.Fore,...
           'String','0.2',...
           'Callback',@Sim_Settings,...
           'Position',[0.5 0.74-0.15*i 0.38 0.08]);             
   end

%% F?rster Radii parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Sim Settings Panel
h.Sim_FRET_General_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','General FRET Settings',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Visible','off',...
    'Position',[0.002 0.25 0.246 0.25]);
%%% Parameter display selection
h.Text_FRET = uicontrol(...
    'Parent',h.Sim_FRET_General_Panel,...
    'Units','normalized',...
    'Style','text',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','F?rster radius [Angstrom]' ,...
    'Callback',@Sim_Settings,...
    'Position',[0.02 0.88 0.6 0.1]);

%%% Text
h.Text_FRET_FromTo = uicontrol(...
    'Parent',h.Sim_FRET_General_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','From \ To',...
    'Position',[0.02 0.74 0.24 0.08]);

h.Sim_R0 = cell(4,4); for k = 1:9;h.Sim_R0{k} = 0;end;
for i=1:3
    %%% Text
    h.Text_FRET1{i} = uicontrol(...
        'Parent',h.Sim_FRET_General_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i) ':'],...
        'Position',[0.02 0.74-0.15*i 0.2 0.08]);
    %%% Text
    h.Text_FERT2{i} = uicontrol(...
        'Parent',h.Sim_FRET_General_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i+1) ':'],...
        'Position',[0.05+0.19*i 0.74 0.19 0.08]);
   for j=1:3
       if j<=i
           %%% F?rster radius
           h.Sim_R0{i+1,j} = uicontrol(...
               'Parent',h.Sim_FRET_General_Panel,...
               'Units','normalized',...
               'FontSize',12,...
               'Style','edit',...
               'BackgroundColor', Look.Control,...
               'ForegroundColor', Look.Fore,...
               'String','0',...
               'Callback',@Sim_Settings,...
               'Position',[0.06+0.19*i 0.74-0.15*j 0.16 0.08]);
       end
   end
    
end

%% Static FRET distances %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Sim Settings Panel
h.Sim_FRET_Static_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Static FRET settings',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Visible','off',...
    'Position',[0.252 0.25 0.246 0.25]);
%%% Parameter display selection
h.Text_FRET_Static = uicontrol(...
    'Parent',h.Sim_FRET_Static_Panel,...
    'Units','normalized',...
    'Style','text',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Distance between dyes [Angstrom]',...
    'Callback',@Sim_Settings,...
    'Position',[0.02 0.88 0.96 0.1]);

%%% Text
h.Text_FRET_Static_FromTo = uicontrol(...
    'Parent',h.Sim_FRET_Static_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','From \ To',...
    'Position',[0.02 0.74 0.24 0.08]);

h.Sim_R = cell(4,4); for k = 1:9;h.Sim_R{k} = 0;end;
for i=1:3
    %%% Text
    h.Text_FRET_Static1{i} = uicontrol(...
        'Parent',h.Sim_FRET_Static_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i) ':'],...
        'Position',[0.02 0.74-0.15*i 0.2 0.08]);
    %%% Text
    h.Text_FRET_Static2{i} = uicontrol(...
        'Parent',h.Sim_FRET_Static_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i+1) ':'],...
        'Position',[0.05+0.19*i 0.74 0.19 0.08]);
   for j=1:3
       if j<=i
           %%% Dye distances radius
           h.Sim_R{i+1,j} = uicontrol(...
               'Parent',h.Sim_FRET_Static_Panel,...
               'Units','normalized',...
               'FontSize',12,...
               'Style','edit',...
               'BackgroundColor', Look.Control,...
               'ForegroundColor', Look.Fore,...
               'String','50',...
               'Callback',@Sim_Settings,...
               'Position',[0.06+0.19*i 0.74-0.15*j 0.16 0.08]);
       end
   end
    
end

%% Distance heterogeneity %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Sim Settings Panel
h.Sim_FRET_Width_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Distance distribution widths',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Visible','off',...
    'Position',[0.502 0.25 0.246 0.25]);
%%% Parameter display selection
h.Use_FRET_Width = uicontrol(...
    'Parent',h.Sim_FRET_Width_Panel,...
    'Units','normalized',...
    'Style','checkbox',...
    'Value',0,...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Use distance distribution width [Angstrom]',...
    'Callback',@Sim_Settings,...
    'Position',[0.02 0.88 0.96 0.1]);

%%% Text
h.Text_FRET_Width_Between = uicontrol(...
    'Parent',h.Sim_FRET_Width_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Between',...
    'Position',[0.02 0.74 0.24 0.08]);
h.Sim_sigma = cell(4,4); for k = 1:9;h.Sim_sigma{k} = 0;end;
for i=1:3
    %%% Text
    h.Text_FRET_Width1{i} = uicontrol(...
        'Parent',h.Sim_FRET_Width_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i) ':'],...
        'Position',[0.02 0.74-0.15*i 0.2 0.08]);
    %%% Text
    h.Text_FRET_Width2{i} = uicontrol(...
        'Parent',h.Sim_FRET_Width_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'Style','text',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'String',['Color ' num2str(i+1) ':'],...
        'Position',[0.05+0.19*i 0.74 0.19 0.08]);
   for j=1:3
       if j<=i
           %%% Dye distances radius
           h.Sim_sigma{i+1,j} = uicontrol(...
               'Parent',h.Sim_FRET_Width_Panel,...
               'Units','normalized',...
               'FontSize',12,...
               'Style','edit',...
               'BackgroundColor', Look.Control,...
               'ForegroundColor', Look.Fore,...
               'String','5',...
               'Callback',@Sim_Settings,...
               'Position',[0.06+0.19*i 0.74-0.15*j 0.16 0.08]);
       end
   end
   
end
%%% Update time for distance heterogeneity
h.Text_FRET_Width_UpdateTime = uicontrol(...
    'Parent',h.Sim_FRET_Width_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Update Time [ms]:',...
    'Position',[0.02 0.14 0.58 0.08]);
h.Sim_sigma_update = uicontrol(...
   'Parent',h.Sim_FRET_Width_Panel,...
   'Units','normalized',...
   'FontSize',12,...
   'Style','edit',...
   'BackgroundColor', Look.Control,...
   'ForegroundColor', Look.Fore,...
   'String','10',...
   'Callback',@Sim_Settings,...
   'Position',[0.63 0.14 0.16 0.08]);

h.Use_Linker_Width = uicontrol(...
    'Parent',h.Sim_FRET_Width_Panel,...
    'Units','normalized',...
    'Style','checkbox',...
    'Value',0,...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Use linker fluctuations width [Angstrom]',...
    'Callback',@Sim_Settings,...
    'Position',[0.02 0.04 0.58 0.08]);
h.Linker_Width = uicontrol(...
    'Parent',h.Sim_FRET_Width_Panel,...
    'Units','normalized',...
    'Style','edit',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','5',...
    'Callback',@Sim_Settings,...
    'Position',[0.63 0.04 0.16 0.08]);

%% Anisotropy parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Sim Settings Panel
h.Sim_Ani_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Anisotropy Settings',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.752 0.25 0.246 0.25]);
%%% Parameter display selection
h.Sim_UseAni = uicontrol(...
    'Parent',h.Sim_Ani_Panel,...
    'Units','normalized',...
    'Style','checkbox',...
    'FontSize',12,...
    'Value', 0,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','<html>Use Anisotropy - &rho [ns]</html>',...
    'Callback',@Sim_Settings,...
    'Position',[0.04 0.88 0.92 0.1]);
   h.Text_Ani_r0 = uicontrol(...
           'Parent',h.Sim_Ani_Panel,...
           'Units','normalized',...
           'FontSize',12,...
           'HorizontalAlignment','center',...
           'Style','text',...
           'BackgroundColor', Look.Back,...
           'ForegroundColor', Look.Fore,...
           'String','r0',...
           'Position',[0.25 0.74 0.19 0.08]);
   h.Text_Ani_rho= uicontrol(...
       'Parent',h.Sim_Ani_Panel,...
       'Units','normalized',...
       'FontSize',12,...
       'HorizontalAlignment','center',...
       'Style','text',...
       'BackgroundColor', Look.Back,...
       'ForegroundColor', Look.Fore,...
       'String','rho',...
       'Position',[0.45 0.74 0.19 0.08]);
   h.Text_Ani_rinf= uicontrol(...
       'Parent',h.Sim_Ani_Panel,...
       'Units','normalized',...
       'FontSize',12,...
       'HorizontalAlignment','center',...
       'Style','text',...
       'BackgroundColor', Look.Back,...
       'ForegroundColor', Look.Fore,...
       'String','r(infinity)',...
       'Position',[0.65 0.74 0.19 0.08]);
   values = {'0.4','1','0'};
   for i=1:4
       h.Text_Ani{i} = uicontrol(...
           'Parent',h.Sim_Ani_Panel,...
           'Units','normalized',...
           'FontSize',12,...
           'HorizontalAlignment','left',...
           'Style','text',...
           'BackgroundColor', Look.Back,...
           'ForegroundColor', Look.Fore,...
           'String',['Color ', num2str(i), ':'],...
           'Position',[0.02 0.74-0.15*i 0.19 0.08]);
       for j=1:3
           h.Sim_Ani{i,j} = uicontrol(...
               'Parent',h.Sim_Ani_Panel,...
               'Units','normalized',...
               'FontSize',12,...
               'Style','edit',...
               'BackgroundColor', Look.Control,...
               'ForegroundColor', Look.Fore,...
               'String',values{j},...
               'Callback',@Sim_Settings,...
               'Position',[0.25+0.2*(j-1) 0.74-0.15*i 0.19 0.08]);
       end
   end
   
%% Dynamic parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Advanced Sim Settings Panel
h.Sim_Dyn_Panel = uibuttongroup(...
    'Parent',h.Sim_Panel,...
    'Units','normalized',...
    'Title','Dynamics Settings - Interconversion Rates [ms^(-1)] - From\To',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Visible','off',...
    'Position',[0.002 0 0.246 0.25]);

h.Sim_Dyn_Table = uitable(...
    'Parent',h.Sim_Dyn_Panel,...
    'Units','normalized',...
    'ColumnFormat',{'numeric'},...
    'ColumnEditable',true,...
    'ColumnName',{'Species1'},...
    'RowName',{'Species1'},...
    'Data',{0},...
    'ColumnWidth','auto',...
    'CellEditCallback',@Sim_Settings,...
    'Position',[0.002 0.002 0.996 0.996]);
%% Global variable initialization
SimData.General = struct;

SimData.General(1).Name = 'Simulation1';
SimData.General(1).BS = [5000 5000 5000];
SimData.General(1).Freq = 1000;
SimData.General(1).SimTime = 10;
SimData.General(1).Frames = 10;
SimData.General(1).Px = [100 100];
SimData.General(1).Size = [50 50];
SimData.General(1).Dim = [5000 5000];
SimData.General(1).Time = [100 10 1];
SimData.General(1).ScanType = 1;
SimData.General(1).UseNoise = 0;
SimData.General(1).Noise = [0.2 0.2 0.2 0.2];
SimData.General(1).MIRange = 80;
SimData.General(1).IRFWidth = 250;
SimData.General(1).HeterogeneityUpdate = 10;
SimData.General(1).LinkerWidth = 5;
SimData.General(1).DynamicRate = 0;
SimData.Species = struct;
SimData.Species(1).Name = 'Species 1';
SimData.Species(1).Color = 1;
SimData.Species(1).FRET = 1;
SimData.Species(1).Barrier = 1;
SimData.Species(1).Brightness = [1000,1000,1000,1000];
SimData.Species(1).D = 1;
SimData.Species(1).N = 10;
SimData.Species(1).wr = [200, 200, 200, 200];
SimData.Species(1).wz = [1000, 1000, 1000, 1000];
SimData.Species(1).dX = [0 0 0 0];
SimData.Species(1).dY = [0 0 0 0];
SimData.Species(1).dZ = [0 0 0 0];

SimData.Species(1).ExP = diag(ones(4,1));
SimData.Species(1).Cross = diag(ones(4,1));
SimData.Species(1).DetP = ones(4,4);
SimData.Species(1).BlP = zeros(4,4);
SimData.Species(1).UseLT = 1;
SimData.Species(1).UseIRF = 0;
SimData.Species(1).LT = 4*ones(4,1);

SimData.Species(1).R0 = zeros(4,4);
SimData.Species(1).R0(2,1) = 63;
SimData.Species(1).R0(3,1) = 51;
SimData.Species(1).R0(4,1) = 65;
SimData.Species(1).R0(3,2) = 68;
SimData.Species(1).R0(4,2) = 50;
SimData.Species(1).R0(4,3) = 60;

SimData.Species(1).R = zeros(4,4);
SimData.Species(1).R(2,1) = 50;
SimData.Species(1).R(3,1) = 50;
SimData.Species(1).R(4,1) = 50;
SimData.Species(1).R(3,2) = 50;
SimData.Species(1).R(4,2) = 50;
SimData.Species(1).R(4,3) = 50;

SimData.Species(1).Aniso = repmat([0.4 1 0 1],4,1); % r0,rho[ns],residual r, G factor
SimData.Species(1).DistanceWidth = zeros(4,4);
SimData.Species(1).DistanceWidth(2,1) = 5;
SimData.Species(1).DistanceWidth(3,1) = 5;
SimData.Species(1).DistanceWidth(4,1) = 5;
SimData.Species(1).DistanceWidth(3,2) = 5;
SimData.Species(1).DistanceWidth(4,2) = 5;
SimData.Species(1).DistanceWidth(4,3) = 5;

SimData.General(1).Species = SimData.Species(1);

SimData.Stat = 0;


guidata(h.Sim,h); 

File_List_Callback([],[],3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that executes upon closing of Sim window %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_Sim(Obj,~)
clear global -regexp SimData
Phasor=findobj('Tag','Phasor');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Pam=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
TauFit=findobj('Tag','TauFit');
PhasorTIFF = findobj('Tag','PhasorTIFF');
if isempty(Phasor) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) && isempty(Mia) && isempty(Pam) && isempty(TauFit) && isempty(BurstBrowser) && isempty(PhasorTIFF)
    clear global -regexp UserValues
end
delete(Obj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that recalculates and adjusts simulation parameters %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Sim_Settings(Obj,~)
global SimData UserValues
h = guidata(findobj('Tag','Sim'));

File = h.Sim_File_List.Value;
Sel=h.Sim_List.Value(1); %species

switch Obj   
    case h.Sim_Folder %%% Select filepath callback     
        try
            Path = uigetdir(h.Sim_Path.String,'Select path for saving');
        catch
            Path = uigetdir(pwd,'Select path for saving');
        end        
        if any(Path~=0)
            h.Sim_Path.String = Path;
            UserValues.File.SimPath = Path;
            LSUserValues(1);
        end
        
    case h.Sim_FileName %%% Change filename
        SimData.General(File).Name = h.Sim_FileName.String;
        h.Sim_File_List.String{File} = h.Sim_FileName.String;
    
    case h.Sim_Scan %%% Scanning type
      switch h.Sim_Scan.Value
          case 1 %%% Point measurement
              h.Sim_Freq.Visible = 'on';
              h.Sim_Frames.Visible='off';
              h.Text_F.Visible='off';
              for i=1:2
                  h.Sim_Px{i}.Visible='off';
                  h.Sim_Size{i}.Visible='off';
                  h.Sim_Dim{i}.Visible='off';
                  h.Text_P{i}.Visible='off';
                  h.Text_S{i}.Visible='off';
                  h.Text_D{i}.Visible='off';
              end
              for i=1:3
                  h.Sim_Px_Time{i}.Visible='off';
                  h.Text_T{i}.Visible='off';
              end
              h.Sim_UseNoise.String = 'Apply Noise [kHz]';
              h.Sim_Lifetime_Panel.Visible = 'on';
              h.Sim_MIRange.Visible = 'on';
              h.Text_MIRange.Visible = 'on';
          case 2 %%% Raster scan
              h.Sim_Freq.Visible = 'on';
              h.Sim_Frames.Visible='on';
              h.Text_F.Visible='on';
              for i=1:2
                  h.Sim_Px{i}.Visible='on';
                  h.Sim_Size{i}.Visible='on';
                  h.Sim_Dim{i}.Visible='on';
                  h.Text_P{i}.Visible='on';
                  h.Text_S{i}.Visible='on';
                  h.Text_D{i}.Visible='on';
              end
              for i=1:3
                  h.Sim_Px_Time{i}.Visible='on';
                  h.Text_T{i}.Visible='on';
              end
              h.Sim_UseNoise.String = 'Apply Noise [kHz]';
              h.Sim_Lifetime_Panel.Visible = 'on';
              h.Sim_MIRange.Visible = 'on';
              h.Text_MIRange.Visible = 'on';
          case 3 %%% Line scan
              h.Sim_Freq.Visible = 'on';
              h.Sim_Frames.Visible='off';
              h.Text_F.Visible='off';
              h.Sim_Px{1}.Visible='on';
              h.Sim_Size{1}.Visible='on';
              h.Sim_Dim{1}.Visible='on';
              h.Text_P{1}.Visible='on';
              h.Text_S{1}.Visible='on';
              h.Text_D{1}.Visible='on';
              h.Sim_Px{2}.Visible='off';
              h.Sim_Size{2}.Visible='off';
              h.Sim_Dim{2}.Visible='off';
              h.Text_P{2}.Visible='off';
              h.Text_S{2}.Visible='off';
              h.Text_D{2}.Visible='off';
              for i=1:2
                  h.Sim_Px_Time{i}.Visible='on';
                  h.Text_T{i}.Visible='on';
              end
              h.Sim_Px_Time{3}.Visible='off';
              h.Text_T{3}.Visible='off';
              h.Sim_UseNoise.String = 'Apply Noise [kHz]';
              h.Sim_Lifetime_Panel.Visible = 'on';
              h.Sim_MIRange.Visible = 'on';
              h.Text_MIRange.Visible = 'on';
          case 4 %%% Circle scan
              h.Sim_Freq.Visible = 'on';
              h.Sim_Frames.Visible='off';
              h.Text_F.Visible='off';
              h.Sim_Px{1}.Visible='on';
              h.Sim_Size{1}.Visible='off';
              h.Sim_Dim{1}.Visible='on';
              h.Text_P{1}.Visible='on';
              h.Text_S{1}.Visible='off';
              h.Text_D{1}.Visible='on';
              h.Sim_Px{2}.Visible='off';
              h.Sim_Size{2}.Visible='off';
              h.Sim_Dim{2}.Visible='on';
              h.Text_P{2}.Visible='off';
              h.Text_S{2}.Visible='off';
              h.Text_D{2}.Visible='on';
              for i=[1,3]
                  h.Sim_Px_Time{i}.Visible='off';
                  h.Text_T{i}.Visible='off';
              end
              h.Sim_Px_Time{2}.Visible='on';
              h.Text_T{2}.Visible='on';
              h.Sim_UseNoise.String = 'Apply Noise [kHz]';
              h.Sim_Lifetime_Panel.Visible = 'on';
              h.Sim_MIRange.Visible = 'on';
              h.Text_MIRange.Visible = 'on';
          case 5 %%% Camera mode
              h.Sim_Frames.Visible='on';
              h.Sim_Freq.Visible = 'off';
              h.Text_F.Visible='on';
              for i=[1,2]
                  h.Sim_Px{i}.Visible='on';
                  h.Sim_Size{i}.Visible='on';
                  h.Sim_Dim{i}.Visible='on';
                  h.Text_P{i}.Visible='on';
                  h.Text_S{i}.Visible='on';
                  h.Text_D{i}.Visible='on';
                  h.Sim_Px_Time{i}.Visible='off';
                  h.Text_T{i}.Visible='off';
              end
              h.Sim_Px_Time{3}.Visible='on';
              h.Text_T{3}.Visible='on';
              h.Sim_UseNoise.String = 'Apply Noise [kHz/pixel]';
              h.Sim_Lifetime_Panel.Visible = 'off';
              h.Sim_MIRange.Visible = 'off';
              h.Text_MIRange.Visible = 'off';
      end
      SimData.General(File).ScanType = h.Sim_Scan.Value;
      
    case h.Sim_BS %%% Box Size changed
        for i=1:3
           SimData.General(File).BS(i) =  str2double(h.Sim_BS{i}.String);            
        end
        
    case h.Sim_Freq %%% Simulation Frequency changed
        SimData.General(File).Freq =  str2double(h.Sim_Freq.String);        
        for i=1:numel(h.Sim_List.String)
            for j=1:4
                SimData.Species(i).Brightness(j) = SimData.General(File).Freq...
                                                 * SimData.Species(i).ExP(j,j)...
                                                 * SimData.Species(i).DetP(j,j)...
                                                 /(sum(SimData.Species(i).Cross(j,:)));
                if i == Sel
                    h.Sim_Brightness{j}.String = num2str(SimData.Species(i).Brightness(j));
                end
            end
        end
        
    case h.Sim_MIRange %%% Microtime range was changed
        SimData.General(File).MIRange = str2double(h.Sim_MIRange.String);
             
    case h.Sim_Time %%% Simulation Time
        %%% Update number of frames
        Factor=str2double(h.Sim_Time.String)/SimData.General(File).SimTime;
        h.Sim_Frames.String=num2str(str2double(h.Sim_Frames.String)*Factor);
        SimData.General(File).SimTime = str2double(h.Sim_Time.String);
        SimData.General(File).Frames = str2double(h.Sim_Frames.String);
    
    case h.Sim_Frames %%% Number of Frames
        %%% Updates simulation time
        Factor=str2double(h.Sim_Frames.String)/SimData.General(File).Frames;
        h.Sim_Time.String=num2str(str2double(h.Sim_Time.String)*Factor);
        SimData.General(File).SimTime = str2double(h.Sim_Time.String);
        SimData.General(File).Frames = str2double(h.Sim_Frames.String);
    
    case h.Sim_Px %%% Number of Pixels\Lines
        %%% X
        Factor1=str2double(h.Sim_Px{1}.String)/SimData.General(File).Px(1);
        %%% Updates Pixel
        h.Sim_Size{1}.String=num2str(str2double(h.Sim_Size{1}.String)/Factor1);
        %%% Updates Pixel time
        h.Sim_Px_Time{1}.String=num2str(str2double(h.Sim_Px_Time{1}.String)/Factor1);
        
        SimData.General(File).Px(1) = str2double(h.Sim_Px{1}.String);
        SimData.General(File).Size(1) = str2double(h.Sim_Size{1}.String);
        SimData.General(File).Time(1) = str2double(h.Sim_Px_Time{1}.String);
        
        
        %%% Y
        Factor2=str2double(h.Sim_Px{2}.String)/SimData.General(File).Px(2);
        %%% Updates Line distance
        h.Sim_Size{2}.String=num2str(str2double(h.Sim_Size{2}.String)/Factor2);
        %%% Updates Frame time
        h.Sim_Px_Time{3}.String=num2str(str2double(h.Sim_Px_Time{3}.String)*Factor2);
        %%% Updates Simulation time
        h.Sim_Time.String=num2str(str2double(h.Sim_Time.String)*Factor2); 
        
        SimData.General(File).Px(2) = str2double(h.Sim_Px{2}.String);
        SimData.General(File).Size(2) = str2double(h.Sim_Size{2}.String);
        SimData.General(File).Time(3) = str2double(h.Sim_Px_Time{3}.String);                
    
    case h.Sim_Size %%% Pixel\Line Size
        %%% Updates Dimension in X\Y
        Factor1=str2double(h.Sim_Size{1}.String)/SimData.General(File).Size(1);
        Factor2=str2double(h.Sim_Size{2}.String)/SimData.General(File).Size(2);
        h.Sim_Dim{1}.String=num2str(str2double(h.Sim_Dim{1}.String)*Factor1);
        h.Sim_Dim{2}.String=num2str(str2double(h.Sim_Dim{2}.String)*Factor2);
        
        SimData.General(File).Size(1) = str2double(h.Sim_Size{1}.String);
        SimData.General(File).Size(2) = str2double(h.Sim_Size{2}.String);
        SimData.General(File).Dim(1) = str2double(h.Sim_Dim{1}.String);
        SimData.General(File).Dim(2) = str2double(h.Sim_Dim{2}.String);        
    
    case h.Sim_Dim %%% Extension in X\Y
        %%% Updates Pixel\Line size
        Factor1=str2double(h.Sim_Dim{1}.String)/SimData.General(File).Dim(1);
        Factor2=str2double(h.Sim_Dim{2}.String)/SimData.General(File).Dim(2);
        h.Sim_Size{1}.String=num2str(str2double(h.Sim_Size{1}.String)*Factor1);
        h.Sim_Size{2}.String=num2str(str2double(h.Sim_Size{2}.String)*Factor2);
        
        SimData.General(File).Size(1) = str2double(h.Sim_Size{1}.String);
        SimData.General(File).Size(2) = str2double(h.Sim_Size{2}.String);
        SimData.General(File).Dim(1) = str2double(h.Sim_Dim{1}.String);
        SimData.General(File).Dim(2) = str2double(h.Sim_Dim{2}.String);        
    
    case h.Sim_Px_Time %%% Pixel\Line\Frame Time
        %%% Updates Pixel\Line\Frame\Simulation Time
        Factor1=str2double(h.Sim_Px_Time{1}.String)/SimData.General(File).Time(1);
        Factor2=str2double(h.Sim_Px_Time{2}.String)/SimData.General(File).Time(2);
        Factor3=str2double(h.Sim_Px_Time{3}.String)/SimData.General(File).Time(3);      
        h.Sim_Px_Time{1}.String=num2str(str2double(h.Sim_Px_Time{1}.String)*Factor2*Factor3);
        h.Sim_Px_Time{2}.String=num2str(str2double(h.Sim_Px_Time{2}.String)*Factor1*Factor3);
        h.Sim_Px_Time{3}.String=num2str(str2double(h.Sim_Px_Time{3}.String)*Factor1*Factor2);
        h.Sim_Time.String=num2str(str2double(h.Sim_Time.String)*Factor1*Factor2*Factor3);
        
        SimData.General(File).Time(1) = str2double(h.Sim_Px_Time{1}.String);
        SimData.General(File).Time(2) = str2double(h.Sim_Px_Time{2}.String);
        SimData.General(File).Time(3) = str2double(h.Sim_Px_Time{3}.String);
        SimData.General(File).SimTime = str2double(h.Sim_Time.String);
           
    case h.Sim_UseNoise %%% Toggles, if noise is applied
        SimData.General(File).UseNoise = h.Sim_UseNoise.Value;
    
    case h.Sim_Noise %%% Noise values changed
        for i=1:4
            SimData.General(File).Noise(i) = str2double(h.Sim_Noise{i}.String);
        end
       
    case h.Sim_Color %%% Defines number of colors
        SimData.Species(Sel).Color = h.Sim_Color.Value;
        %%% Turns settings for selected color on
        for i=1:h.Sim_Color.Value
            h.Sim_Brightness{i}.Visible = 'on';
            h.Sim_Bleaching{i}.Visible = 'on';
            h.Sim_wr{i}.Visible = 'on';
            h.Sim_wz{i}.Visible = 'on';
            h.Sim_dX{i}.Visible = 'on';
            h.Sim_dY{i}.Visible = 'on';
            h.Sim_dZ{i}.Visible = 'on';
            h.Text_Color{i}.Visible = 'on';
        end
        %%% Turns settings for non selected color off
        for i=(h.Sim_Color.Value+1):4
            h.Sim_Brightness{i}.Visible = 'off';
            h.Sim_Bleaching{i}.Visible = 'off';
            h.Sim_wr{i}.Visible = 'off';
            h.Sim_wz{i}.Visible = 'off';
            h.Sim_dX{i}.Visible = 'off';
            h.Sim_dY{i}.Visible = 'off';
            h.Sim_dZ{i}.Visible = 'off';
            h.Text_Color{i}.Visible = 'off';
        end        
    case h.Sim_FRET %%% Defines type of FRET to be simulated
        SimData.Species(Sel).FRET = h.Sim_FRET.Value;
        switch h.Sim_FRET.Value
            case 1
                h.Sim_FRET_General_Panel.Visible = 'off';
                h.Sim_FRET_Static_Panel.Visible = 'off';
                h.Sim_FRET_Width_Panel.Visible = 'off';
                h.Sim_Dyn_Panel.Visible = 'off';
            case 2
                h.Sim_FRET_General_Panel.Visible = 'on';
                h.Sim_FRET_Static_Panel.Visible = 'on';
                h.Sim_FRET_Width_Panel.Visible = 'on';
                h.Sim_Dyn_Panel.Visible = 'off';
            case 3
                h.Sim_FRET_General_Panel.Visible = 'on';
                h.Sim_FRET_Static_Panel.Visible = 'on';   
                h.Sim_FRET_Width_Panel.Visible = 'on';
                h.Sim_Dyn_Panel.Visible = 'on';
        end
    case h.Sim_Barrier %%% Defines type of barrieres to be simulated
        SimData.Species(Sel).Barrier = h.Sim_Barrier.Value;
    case h.Sim_Name %%% Changed species name
        h.Sim_List.String{Sel}=h.Sim_Name.String;
        SimData.Species(Sel).Name=h.Sim_Name.String;
    case h.Sim_Brightness %%% Changed brightness
        for i=1:4
            SimData.Species(Sel).Brightness(i)=str2double(h.Sim_Brightness{i}.String);
            ExP_Old = SimData.Species(Sel).ExP(i,i);
            SimData.Species(Sel).ExP(i,i) = SimData.Species(Sel).Brightness(i)...
                                        / SimData.General(File).Freq...
                                        /SimData.Species(Sel).DetP(i,i)...
                                        *(sum(SimData.Species(Sel).Cross(:,i)));
            for j=1:4
                if j~=i
                    SimData.Species(Sel).ExP(j,i) = SimData.Species(Sel).ExP(i,i)/ExP_Old.*SimData.Species(Sel).ExP(j,i);
                end
                if h.Sim_Param_Plot.Value == 1
                    h.Sim_Param{j,i}.String = num2str(SimData.Species(Sel).ExP(j,i));
                end
            end
                                    
        end
    case h.Sim_D %%% Changed Diffusion coefficient
        SimData.Species(Sel).D=str2double(h.Sim_D.String);
    case h.Sim_N %%% Changed number of particles
        SimData.Species(Sel).N=str2double(h.Sim_N.String);
    case h.Sim_wr %%% Changed lateral focus size
        for i=1:4
            SimData.Species(Sel).wr(i)=str2double(h.Sim_wr{i}.String);
        end
    case h.Sim_wz %%% Changed axial focus size
        for i=1:4
            SimData.Species(Sel).wz(i)=str2double(h.Sim_wz{i}.String);
        end
    case h.Sim_dX %%% Changed focus shift in X
        for i=1:4
            SimData.Species(Sel).dX(i)=str2double(h.Sim_dX{i}.String);
        end
    case h.Sim_dY %%% Changed focus shift in Y
        for i=1:4
            SimData.Species(Sel).dY(i)=str2double(h.Sim_dY{i}.String);
        end
    case h.Sim_dZ %%% Changed focus shift in Z
        for i=1:4
            SimData.Species(Sel).dZ(i)=str2double(h.Sim_dZ{i}.String);
        end
        
    case h.Sim_UseLT %%% Toggles, if lifetime is used
        SimData.Species(Sel).UseLT = h.Sim_UseLT.Value; 
    case h.Sim_LT %%% Lifetime was changed
        for i=1:4
            SimData.Species(Sel).LT(i) = str2double(h.Sim_LT{i}.String); 
        end
    case h.Sim_UseIRF %%% Toggles, if IRF is used
        SimData.Species(Sel).UseIRF = h.Sim_UseIRF.Value;
    case h.Sim_IRF_Width_Edit
        % why is this data stored in SimData?
        SimData.General.IRFwidth = str2double(h.Sim_IRF_Width_Edit.String);
    case h.Sim_Param_Plot %%% Changed plotted advanced parameters
        for i=1:4
            for j=1:4
                switch h.Sim_Param_Plot.Value
                    case 1 %%% Excitation probability
                        h.Sim_Param{i,j}.String = num2str(SimData.Species(Sel).ExP(i,j));
                    case 2 %%% Crosstalk
                        h.Sim_Param{i,j}.String = num2str(SimData.Species(Sel).Cross(i,j));
                    case 3 %%% Detection probability
                        h.Sim_Param{i,j}.String = num2str(SimData.Species(Sel).DetP(i,j));
                    case 4 %%% Bleaching probability
                        h.Sim_Param{i,j}.String = num2str(SimData.Species(Sel).BlP(i,j));   
                end
            end
        end
    case h.Sim_Param %%% Changed advanced parameter
        for i=1:4
            for j=1:4
                switch h.Sim_Param_Plot.Value
                    case 1 %%% Excitation probability
                        SimData.Species(Sel).ExP(i,j) = str2double(h.Sim_Param{i,j}.String);
                    case 2 %%% Crosstalk
                        Cross = str2double(h.Sim_Param{i,j}.String);
                        if i==j
                            Cross = 1;
                            h.Sim_Param{i,j}.String = '1';
                        end
                        SimData.Species(Sel).Cross(i,j) = Cross;
                    case 3 %%% Detection probability
                        Det = str2double(h.Sim_Param{i,j}.String);
                        if Det<0
                            h.Sim_Param{i,j}.String = '0';
                            Det = 0;
                        elseif Det>1
                            h.Sim_Param{i,j}.String = '1';
                            Det = 1;
                        end
                        SimData.Species(Sel).DetP(i,j) = Det;                        
                    case 4 %%% Bleaching probability
                        SimData.Species(Sel).BlP(i,j) = str2double(h.Sim_Param{i,j}.String);                        
                end
            end
        end
        for i=1:4
            SimData.Species(Sel).Brightness(i) = SimData.General(File).Freq...
                * SimData.Species(Sel).ExP(i,i)...
                * SimData.Species(Sel).DetP(i,i)...
                /(sum(SimData.Species(Sel).Cross(:,i)));            
            h.Sim_Brightness{i}.String = num2str(SimData.Species(Sel).Brightness(i));
        end
    case h.Sim_R0 %%% Changed F?rster radius
        for i=1:3
            for j=1:3   
                if j<=i
                    SimData.Species(Sel).R0(i+1,j) = str2double(h.Sim_R0{i+1,j}.String);
                end
            end
        end
    case h.Sim_R %%% Changed Dye distance
        for i=1:3
            for j=1:3   
                if j<=i
                    SimData.Species(Sel).R(i+1,j) = str2double(h.Sim_R{i+1,j}.String);
                end
            end
        end
    case h.Sim_sigma %%% Changed Dye distance
        for i=1:3
            for j=1:3   
                if j<=i
                    SimData.Species(Sel).DistanceWidth(i+1,j) = str2double(h.Sim_sigma{i+1,j}.String);
                end
            end
        end
        
    case h.Sim_Ani
        for i = 1:4 % 4 colors
            for j = 1:3 % 3 shown parameters
                SimData.Species(Sel).Aniso(i,j) = str2double(h.Sim_Ani{i,j}.String);
            end
        end
        
    case h.Linker_Width
        SimData.General.LinkerWidth = str2double(h.Linker_Width.String);
    case h.Sim_sigma_update %%% Changed the update time
        SimData.General.HeterogeneityUpdate = str2double(h.Sim_sigma_update.String);
    case h.Sim_Dyn_Table
        DynRates = cell2mat(h.Sim_Dyn_Table.Data);
        DynRates(logical(eye(size(DynRates,1)))) = 0; %%% Set diagonal elements to zero
        SimData.General.DynamicRate = DynRates;
        h.Sim_Dyn_Table.Data = num2cell(DynRates);
    case    h.Sim_MultiCore
        
end

SimData.General(File).Species = SimData.Species;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%% Callbacks of File List %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function File_List_Callback(~,e,mode)
global SimData
h = guidata(findobj('Tag','Sim'));

if mode == 0 %%% Key Press Function
    switch e.Key
        case 'return'
            mode = 1;
        case 'delete'
            mode = 2;
    end
    
end

File = h.Sim_File_List.Value;
Sel = h.Sim_List.Value(1); %species

switch mode
    case 1 %%% Duplicates current file
        SimData.General(end+1) = SimData.General(File);
        h.Sim_File_List.String{end+1} = SimData.General(end).Name;
    case 2 %%% Deletes current file
        if numel(SimData.General)>1
            SimData.General(File) = [];
            h.Sim_File_List.String(File) = [];
            h.Sim_File_List.Value = h.Sim_File_List.Value-1;
            if h.Sim_File_List.Value<1
                h.Sim_File_List.Value = 1;
            end
            File_List_Callback([],e,3);
        end
    case 3 %%% Change selected file
        h.Sim_FileName.String = SimData.General(File).Name;
        
        SimData.Species = SimData.General(File).Species;
        
        h.Sim_Scan.Value = SimData.General(File).ScanType;        
        h.Sim_Freq.String = num2str(SimData.General(File).Freq);
        h.Sim_Time.String = num2str(SimData.General(File).SimTime);
        h.Sim_Frames.String =  num2str(SimData.General(File).Frames);
        for i=1:3
           h.Sim_BS{i}.String = num2str(SimData.General(File).BS(i));
           h.Sim_Px_Time{i}.String = num2str(SimData.General(File).Time(i));
        end
        for i=1:2
            h.Sim_Px{i}.String = num2str(SimData.General(File).Px(i));
            h.Sim_Size{i}.String = num2str(SimData.General(File).Size(i));
            h.Sim_Dim{i}.String = num2str(SimData.General(File).Dim(i));
        end
        h.Sim_UseNoise.Value = SimData.General(File).UseNoise;
        for i=1:4
            h.Sim_Noise{i}.String = num2str(SimData.General(File).Noise(i));
         end
        h.Sim_MIRange.String = num2str(SimData.General(File).MIRange);
        
        Species = cell(numel(SimData.Species),1);
        for i=1:numel(SimData.Species)
            Species{i} = SimData.Species(i).Name;
        end
        h.Sim_List.String = Species;
        h.Sim_List.Value = 1;
        
        % advanced settings
        % for i=1:4
        %    for j=1:4
        %        h.Sim_Param{i,j}.String = ?
        %    end
        % end

        % lifetime settings
        h.Sim_UseIRF.Value = SimData.General(File).Species(Sel).UseIRF;
        % h.Sim_IRF_Width_Edit = ?
        % for i=1:4
        %     h.Sim_LT{i} = ?
        % end

        % R0
        for i=1:3
            for j=1:3
                if j<=i
                    h.Sim_R0{i+1,j}.String = num2str(SimData.General(File).Species(Sel).R0(i+1,j));
                end
            end
        end

        % static FRET
        for i = 1:3
            for j=1:3
                if j<=i
                    h.Sim_R{i+1,j}.String = num2str(SimData.General(File).Species(Sel).R(i+1,j));
                end
            end
        end
        
        % distance distribution widths
        % h.Use_FRET_Width = ?
        for i = 1:3
            for j=1:3
                if j<=i
                    h.Sim_sigma{i+1,j}.String = num2str(SimData.General(File).Species(Sel).DistanceWidth(i+1,j));
                end
            end
        end
        
        h.Sim_sigma_update.String = num2str(SimData.General(File).HeterogeneityUpdate); %update time
        %h.Use_Linker_Width = ?
        h.Linker_Width.String = num2str(SimData.General(File).LinkerWidth);
        
        % Lifetime settings
        % h.Sim_UseAni = ?
        for i = 1:4 % 4 colors
            for j = 1:3 % 3 parameters, although there are 4
                h.Sim_Ani{i,j}.String = num2str(SimData.Species(Sel).Aniso(i,j));
            end
        end
        
        % dynamic FRET
        % h.Sim_Dyn_Table = ?
        
        Sim_Settings(h.Sim_Scan,[]);
        Species_List_Callback([],e,3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%% Callback of Species List %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Species_List_Callback(~,e,mode)
global SimData
h = guidata(findobj('Tag','Sim'));

if mode == 0 %%% Key Press Function
    switch e.Key
        case 'return'
            mode = 1;
        case 'delete'
            mode = 2;
    end   
end

Sel = h.Sim_List.Value;
switch mode
    case 1 %%% Duplicates current species
        SimData.Species(end+1) = SimData.Species(Sel);
        SimData.Species(end).Name = ['Species ' num2str(numel(SimData.Species))];
        h.Sim_List.String{end+1} = SimData.Species(end).Name;
        %%% Updates Dynamic Table
        Data_temp = h.Sim_Dyn_Table.Data;
        h.Sim_Dyn_Table.RowName = h.Sim_List.String;
        h.Sim_Dyn_Table.ColumnName = h.Sim_List.String;
        Data = cell(numel(h.Sim_List.String));Data(:) = deal({0});
        Data(1:end-1,1:end-1) = Data_temp;
        h.Sim_Dyn_Table.Data = Data;
    case 2 %%% Deletes current species
        if numel(SimData.Species)>1
            SimData.Species(Sel) = [];
            h.Sim_List.String(Sel) = [];
            h.Sim_List.Value = 1;
            Species_List_Callback([],e,3);
        end
        %%% Updates Dynamic Table
        h.Sim_Dyn_Table.Data = h.Sim_Dyn_Table.Data(1:end-1,1:end-1);
        h.Sim_Dyn_Table.RowName = h.Sim_List.String;
        h.Sim_Dyn_Table.ColumnName = h.Sim_List.String;
    case 3 %%% Change selected species
        h.Sim_Name.String = SimData.Species(Sel).Name;
        h.Sim_Color.Value = SimData.Species(Sel).Color;
        h.Sim_FRET.Value = SimData.Species(Sel).FRET;
        h.Sim_Barrier.Value = SimData.Species(Sel).Barrier;
        h.Sim_D.String = num2str(SimData.Species(Sel).D);
        h.Sim_N.String = num2str(SimData.Species(Sel).N);
        h.Sim_UseLT.Value = SimData.Species(Sel).UseLT;
        for i=1:4
            h.Sim_Brightness{i}.String = num2str(SimData.Species(Sel).Brightness(i));
            h.Sim_wr{i}.String = num2str(SimData.Species(Sel).wr(i));
            h.Sim_wz{i}.String = num2str(SimData.Species(Sel).wz(i));
            h.Sim_dX{i}.String = num2str(SimData.Species(Sel).dX(i));
            h.Sim_dY{i}.String = num2str(SimData.Species(Sel).dY(i));
            h.Sim_dZ{i}.String = num2str(SimData.Species(Sel).dZ(i)); 
            h.Sim_LT{i}.String = num2str(SimData.Species(Sel).LT(i));
            for j=1:4
               switch h.Sim_Param_Plot.Value
                    case 1 %%% Excitation probability
                        h.Sim_Param{i,j}.String = num2str(SimData.Species(Sel).ExP(i,j));
                    case 2 %%% Crosstalk
                        h.Sim_Param{i,j}.String = num2str(SimData.Species(Sel).Cross(i,j));
                    case 3 %%% Detection probability
                        h.Sim_Param{i,j}.String = num2str(SimData.Species(Sel).DetP(i,j));
                    case 4 %%% Bleaching probability
                        h.Sim_Param{i,j}.String = num2str(SimData.Species(Sel).BlP(i,j));   
               end
               if j<i
                    h.Sim_R0{i,j}.String = num2str(SimData.Species(Sel).R0(i,j));
                    h.Sim_R{i,j}.String = num2str(SimData.Species(Sel).R(i,j));
                    h.Sim_sigma{i,j}.String = num2str(SimData.Species(Sel).DistanceWidth(i,j));
               end
            end
            for j = 1:3
                h.Sim_Ani{i,j}.String = num2str(SimData.Species(Sel).Aniso(i,j));
            end
        end

        Sim_Settings(h.Sim_Color,[]); 
        Sim_Settings(h.Sim_FRET,[]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%% Start simulation procedure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Start_Simulation(~,~)
global SimData
h = guidata(findobj('Tag','Sim'));

if strcmp(h.Sim_Start.String, 'Stop')
    h.Sim_File_List.Enable = 'on';
    h.Sim_File_List.Value = 1;
    SimData.Start = 0;
    h.Sim_Start.String = 'Start';
    File_List_Callback([],[],3);
    return;
end

if ~isdir(h.Sim_Path.String)
    return;
end
h.Sim_File_List.Enable = 'off';
h.Sim_File_List.Value = 1;
h.Sim_Start.String = 'Stop';
SimData.Start = 1;

for i = 1:numel(h.Sim_File_List.String)
    File_List_Callback([],[],3);
    drawnow
    if ~SimData.Start %%% Aborts Simulation
       return; 
    end
    if h.Sim_Scan.Value<5
        Do_PointSim;
    else
        profile on
        Do_CameraSim;
        profile viewer
    end
    h.Sim_File_List.Value = h.Sim_File_List.Value+1;
end
h.Sim_File_List.Enable = 'on';
h.Sim_File_List.Value = 1;
SimData.Start = 0;
h.Sim_Start.String = 'Start';
File_List_Callback([],[],3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%% Peforms actual simulation procedure for point detector observation %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_PointSim(~,~)
global SimData UserValues PathToApp
h = guidata(findobj('Tag','Sim'));

StartParPool();
%%% ScanType
Scan_Type = h.Sim_Scan.Value;
%%% Box Size
BS(1) = str2double(h.Sim_BS{1}.String);
BS(2) = str2double(h.Sim_BS{2}.String);
BS(3) = str2double(h.Sim_BS{3}.String);
BS = floor(BS);

%%% Simulation frequency
Freq = str2double(h.Sim_Freq.String)*1000;
%%% Simulation time
Simtime = int64(str2double(h.Sim_Time.String)*Freq); 
%%% Frames
Frames = str2double(h.Sim_Frames.String);
%%% Microtime bins
MI_Bins = 2^13;

%%% Pixel/Line info
Step(1) = str2double(h.Sim_Size{1}.String); 
Pixel(1) = str2double(h.Sim_Px{1}.String);
ScanTicks(1) = str2double(h.Sim_Px_Time{1}.String)*Freq*10^-6; 
Step(2) = str2double(h.Sim_Size{2}.String); 
Pixel(2) = str2double(h.Sim_Px{2}.String); 
ScanTicks(2) = str2double(h.Sim_Px_Time{2}.String)*Freq*10^-3; 

use_aniso = h.Sim_UseAni.Value;

if use_aniso == 0
    Photons_total = cell(numel(SimData.Species),4);
    MI_total = cell(numel(SimData.Species),4);
elseif use_aniso == 1
    Photons_total = cell(numel(SimData.Species),8);
    MI_total = cell(numel(SimData.Species),8);
end

%% Split here between old simulation (basic, best for diffusion/corrlation)
%% and new additions for single-molecule FRET experiments
%%% advanced includes any of the parameters that are not in DifSim.mex,
%%% but only in DifSim_ani.mex
%%% This includes:
%%% IRF width
%%% Anisotropy
%%% Conformational heterogeneity for PDA (sigma)
%%% Linker fluctuations for TCSPC fitting
%%% dynamic interconversion
advanced = any([...
    h.Sim_UseIRF.Value,...
    h.Sim_UseAni.Value,...
    h.Use_FRET_Width.Value,...
    h.Use_Linker_Width.Value,...
    any([SimData.Species.FRET] == 3)...
    ]);
%% basic simulation 
if ~advanced
    for i = 1:numel(SimData.Species);
        if ~SimData.Start %%% Aborts Simulation
           return; 
        end
        NoP = SimData.Species(i).N;
        D = sqrt(2*SimData.Species(i).D*10^6/Freq);

        wr = zeros(4,1); wz = zeros(4,1); 
        dX = zeros(4,1); dY = zeros(4,1); dZ = zeros(4,1);

        %%% Detection probability
        DetP = SimData.Species(i).DetP;
        %%% Excitation probability (including direct excitation)
        ExP = SimData.Species(i).ExP;    
        %%% Crosstalk
        SimData.Species(i).Cross(1:5:16) = 1;
        Cross = zeros(4,4);
        for j=1:4
            for k=1:4
                Cross(j,k) =  DetP(k,k)/DetP(j,k)*SimData.Species(i).Cross(j,k);
            end
        end
        %%% Bleaching probability (1/avg(#EmittedPhotons)
        BlP = SimData.Species(i).BlP;
        %%% Calculates relative energy transfer rates
        switch SimData.Species(i).FRET
            case 1
                FRET = diag(ones(4,1));
            case 2
                FRET = (SimData.Species(i).R0./SimData.Species(i).R).^6;
                FRET(1:5:16) = 1;
            case 3
                FRET = diag(ones(4,1));
        end
        %%% Lifetime of the colors
        if SimData.Species(i).UseLT
            LT = SimData.Species(i).LT./str2double(h.Sim_MIRange.String)*MI_Bins;
        else
            LT = [0 0 0 0];
        end
        for j = SimData.Species(i).Color+1:4
            ExP(j,:) = 0;
            FRET(j,:) = 0;
        end

        %%% Determins barrier type and map (for quenching, barriers, ect.)
        Map_Type = h.Sim_Barrier.Value;
        switch Map_Type
            case 1 %%% Free Diffusion
                if ~isfield(SimData,'Map') || ~iscell(SimData.Map)
                    SimData.Map = {1};
                end
            case {2,3,4,5,8} %%% Static Maps
                if isfield(SimData,'Map') && iscell(SimData.Map)
                    SimData.Map{1} = double(SimData.Map{1});
                    if size(SimData.Map{1},1)<BS(1) || size(SimData.Map{1},2)<BS(2)
                        Map_Type = 1;
                    else
                        if size(SimData.Map{1},1)>BS(1)
                            SimData.Map{1} = SimData.Map{1}(1:BS(1),:);
                        end
                        if size(SimData.Map{1},2)>BS(2)
                            SimData.Map{1} = SimData.Map{1}(:,1:BS(1));
                        end
                        SimData.Map{1}(isnan(SimData.Map{1})) = 1;
                    end
                else
                    Map_Type = 1;
                    if ~isfield(SimData,'Map') || ~iscell(SimData.Map)
                        SimData.Map = {1};
                    end
                end
            case {6,7} %%% Diffusing Maps
                if isfield(SimData,'Map') && iscell(SimData.Map) && numel(SimData.Map) >= Frames
                    for j=1:Frames
                        SimData.Map{j} = double(SimData.Map{j});
                        if size(SimData.Map{j},1)<BS(1) || size(SimData.Map{j},2)<BS(2)
                            Map_Type = 1;
                            break;
                        else
                            if size(SimData.Map{j},1)>BS(1)
                                SimData.Map{j} = SimData.Map{j}(1:BS(1),:);
                            end
                            if size(SimData.Map{j},2)>BS(2)
                                SimData.Map{j} = SimData.Map{j}(:,1:BS(1));
                            end
                            SimData.Map{j}(isnan(SimData.Map{j})) = 1;
                        end
                    end
                else
                    Map_Type = 1;
                    if ~isfield(SimData,'Map') || ~iscell(SimData.Map)
                        SimData.Map = {1};
                    end
                end
            otherwise
                Map_Type = 1;
                if ~isfield(SimData,'Map') || ~iscell(SimData.Map)
                    SimData.Map = {1};
                end
        end


        %%% Species specific parameters for used colors
        for j = 1:SimData.Species(i).Color
            wr(j) = SimData.Species(i).wr(j);
            wz(j) = SimData.Species(i).wz(j);
            dX(j) = SimData.Species(i).dX(j);
            dY(j) = SimData.Species(i).dY(j);
            dZ(j) = SimData.Species(i).dZ(j);
        end
        Photons1 = cell(NoP,1); MI1 = cell(NoP,1);
        Photons2 = cell(NoP,1); MI2 = cell(NoP,1);
        Photons3 = cell(NoP,1); MI3 = cell(NoP,1);
        Photons4 = cell(NoP,1); MI4 = cell(NoP,1);

        fid = fopen([PathToApp,filesep,'Profiles',filesep,'timing.txt'],'w');
        fclose(fid);
        if fid == -1
            return;
        end

        Update = timer(...
            'StartFcn',{@Update_Progress,1,i,numel(SimData.Species),NoP},...
            'TimerFcn', {@Update_Progress,2,i,numel(SimData.Species),NoP},...
            'StopFcn', {@Update_Progress,3,i,numel(SimData.Species),NoP},...
            'Period',1,...
            'ExecutionMode','fixedDelay');
        start(Update)

        parfor (j = 1:NoP,UserValues.Settings.Pam.ParallelProcessing)
            %%% Generates starting position
            Pos = (BS-1).*rand(1,3);    

            %%% Pts particles in allowed areas for restricted area simulations
            if Map_Type==3
                while SimData.Map{1}(floor(Pos(1)+1),floor(Pos(2))+1) == 0
                    Pos = (BS-1).*rand(1,3);
                end
            elseif Map_Type == 6
                while SimData.Map{1}(floor(Pos(1))+1,floor(Pos(2))+1,1) == 0
                    Pos = (BS-1).*rand(1,3);
                end            
            end        
            Frametime = Simtime/Frames;

            for k=1:Frames 
                Time = clock;

                %%% Uses new map for dynamic barrier simulations
                if any(Map_Type == [6,7])
                    Sel = k;
                else
                    Sel = 1;
                end

                %%% Puts partilces back into their areas, if areas moved
                if k>1 && any(Map_Type == [6,7])
                    if SimData.Map{k-1}(floor(Pos(1)+1),floor(Pos(2))+1) ~= SimData.Map{k}(floor(Pos(1)+1),floor(Pos(2)+1))
                        [X,Y] = find(SimData.Map{k} == SimData.Map{k-1}(floor(Pos(1)+1),floor(Pos(2)+1)));
                        [~,Index] = sort((X-Pos(1)).^2 + (Y-Pos(2)).^2);
                        Pos(1) = X(Index(1));
                        Pos(2) = Y(Index(1));
                    end                
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% Main Simulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [Photons,  MI, Channel, Pos] = DifSim(...
                    Frametime, BS,... General Parameters
                    Scan_Type, Step, Pixel, ScanTicks,... Scanning Parameters 
                    D,Pos,... Particle parameters
                    wr,wz,... Focus parameters
                    dX,dY,dZ,... Focus shift parameters
                    ExP,DetP,BlP,... %%% Probability parameters (Excitation, Detection and Bleaching)
                    LT,... %%% Lifetime of the different colors
                    FRET, Cross,... %%% Relative FRET and Crosstalk rates
                    uint32(Time(end)*1000+k+j),...%%% Uses current time, frame and particle to have more precision of the random seed (second resolution)
                    Map_Type, SimData.Map{Sel});  %%% Type of barriers/quenching and barrier map
                %%% Channel is a 8 bit number that defines the exact photon type
                %%% bits 0,1 for excitation laser
                %%% bits 2,3 for excited dye
                %%% bits 4,5 for emitting dye
                %%% bits 6,7 for detection channel
                
                %%% Assigns photons according to detection channel
                Photons1{j} = [Photons1{j}; Photons(bitand(Channel,3)==0)+(k-1)*double(Frametime)];
                Photons2{j} = [Photons2{j}; Photons(bitand(Channel,3)==1)+(k-1)*double(Frametime)];
                Photons3{j} = [Photons3{j}; Photons(bitand(Channel,3)==2)+(k-1)*double(Frametime)];
                Photons4{j} = [Photons4{j}; Photons(bitand(Channel,3)==3)+(k-1)*double(Frametime)];
                MI1{j} = [MI1{j}; uint16(MI(bitand(Channel,3)==0))];
                MI2{j} = [MI2{j}; uint16(MI(bitand(Channel,3)==1))];
                MI3{j} = [MI3{j}; uint16(MI(bitand(Channel,3)==2))];
                MI4{j} = [MI4{j}; uint16(MI(bitand(Channel,3)==3))];
            end

            FID = fopen([PathToApp,filesep,'Profiles',filesep,'Timing.txt'],'a');
            fprintf(FID,['Particle' num2str(j) '\n']);
            fclose(FID);
        end
        %%% Combines photons for all particles
        Photons_total{i,1} = cell2mat(Photons1);
        MI_total{i,1} = cell2mat(MI1);
        Photons_total{i,2} = cell2mat(Photons2);
        MI_total{i,2} = cell2mat(MI2);
        Photons_total{i,3} = cell2mat(Photons3);
        MI_total{i,3} = cell2mat(MI3);
        Photons_total{i,4} = cell2mat(Photons4);
        MI_total{i,4} = cell2mat(MI4);
        clear Photons1 Photons2 Photons3 Photons4 MI1 MI2 MI3 MI4;
        
        %%% we need to adjust the MIbins here
        MI_Bins = 4*2^14+1;
        stop(Update);
    end

    Sim_Photons = cell(4,1);
    Sim_MI = cell(4,1);
    for i=1:4 %%% Combines photons of all species
        Sim_Photons{i} = cell2mat(Photons_total(:,i));
        Sim_MI{i} = cell2mat(MI_total(:,i));
    end

    if h.Sim_UseNoise.Value
        for i=1:4
            if str2double(h.Sim_Noise{i}.String) > 0 && ~isempty(Sim_Photons{i})
               AIPT = Freq/(str2double(h.Sim_Noise{i}.String)*1000);
               Noise = [];
               while (isempty(Noise) || numel(Noise) < 1E6)%Noise(end)<Simtime)
                   if isempty(Noise)
                       Noise = cumsum(exprnd(AIPT,[10000 1]));
                   else
                       Noise = [Noise; cumsum(exprnd(AIPT,[10000 1]))+Noise(end)]; %#ok<AGROW>
                   end
               end
               Noise (Noise>Simtime) = []; %#ok<AGROW>
               MI_Noise = uint16(MI_Bins*rand(numel(Noise),1));

               Sim_Photons{i} = [Sim_Photons{i}; Noise];
               Sim_MI{i} = [Sim_MI{i}; MI_Noise];
               [Sim_Photons{i}, Index] = sort(Sim_Photons{i});
               Sim_MI{i} = Sim_MI{i}(Index);
               clear Noise MI_Noise Index;
            end
        end
    end
end

%% single-molecule FRET simulation with advanced parameters
if advanced
    %% Prepare input values
    
    %%% IRF values (global for all species)
    %%% Shift is hard-coded to 1 ns
    IRFshift = floor(MI_Bins/str2double(h.Sim_MIRange.String));
    if h.Sim_UseIRF.Value
        IRFwidth = floor(MI_Bins*str2double(h.Sim_IRF_Width_Edit.String)/1000/str2double(h.Sim_MIRange.String));
    else
        IRFwidth = 1; %%% set to minimum
    end
    IRFparams = [IRFshift,IRFwidth];
    %% General parameters are taken from the first species
    %%% This includes everything that should be independent of species,
    %%% i,e:
    %%% Focal volume dimensions and shift
    %%% Crosstalk, direct excitation and detection/excitation probabilities
    %%% Bleaching rates
    %%% Diffusion/Quenching maps
    i = 1;
    wr = zeros(4,1); wz = zeros(4,1); 
    dX = zeros(4,1); dY = zeros(4,1); dZ = zeros(4,1);

    %%% Detection probability
    DetP = SimData.Species(i).DetP;
    %%% Excitation probability (including direct excitation)
    ExP = SimData.Species(i).ExP;    
    %%% Crosstalk
    SimData.Species(i).Cross(1:5:16) = 1;
    Cross = zeros(4,4);
    for j=1:4
        for k=1:4
            Cross(j,k) =  DetP(k,k)/DetP(j,k)*SimData.Species(i).Cross(j,k);
        end
    end
    %%% Bleaching probability (1/avg(#EmittedPhotons)
    BlP = SimData.Species(i).BlP;
    
    for j = SimData.Species(i).Color+1:4
        ExP(j,:) = 0; %%% Set excitation of unused colors to 0
        %FRET(j,:) = 0;
    end

    %%% Determins barrier type and map (for quenching, barriers, ect.)
    Map_Type = h.Sim_Barrier.Value;
    switch Map_Type
        case 1 %%% Free Diffusion
            if ~isfield(SimData,'Map') || ~iscell(SimData.Map)
                SimData.Map = {1};
            end
        case {2,3,4,5,8} %%% Static Maps
            if isfield(SimData,'Map') && iscell(SimData.Map)
                SimData.Map{1} = double(SimData.Map{1});
                if size(SimData.Map{1},1)<BS(1) || size(SimData.Map{1},2)<BS(2)
                    Map_Type = 1;
                else
                    if size(SimData.Map{1},1)>BS(1)
                        SimData.Map{1} = SimData.Map{1}(1:BS(1),:);
                    end
                    if size(SimData.Map{1},2)>BS(2)
                        SimData.Map{1} = SimData.Map{1}(:,1:BS(1));
                    end
                    SimData.Map{1}(isnan(SimData.Map{1})) = 1;
                end
            else
                Map_Type = 1;
                if ~isfield(SimData,'Map') || ~iscell(SimData.Map)
                    SimData.Map = {1};
                end
            end
        case {6,7} %%% Diffusing Maps
            if isfield(SimData,'Map') && iscell(SimData.Map) && numel(SimData.Map) >= Frames
                for j=1:Frames
                    SimData.Map{j} = double(SimData.Map{j});
                    if size(SimData.Map{j},1)<BS(1) || size(SimData.Map{j},2)<BS(2)
                        Map_Type = 1;
                        break;
                    else
                        if size(SimData.Map{j},1)>BS(1)
                            SimData.Map{j} = SimData.Map{j}(1:BS(1),:);
                        end
                        if size(SimData.Map{j},2)>BS(2)
                            SimData.Map{j} = SimData.Map{j}(:,1:BS(1));
                        end
                        SimData.Map{j}(isnan(SimData.Map{j})) = 1;
                    end
                end
            else
                Map_Type = 1;
                if ~isfield(SimData,'Map') || ~iscell(SimData.Map)
                    SimData.Map = {1};
                end
            end
        otherwise
            Map_Type = 1;
            if ~isfield(SimData,'Map') || ~iscell(SimData.Map)
                SimData.Map = {1};
            end
    end


    %%% Species specific parameters for used colors
    for j = 1:SimData.Species(i).Color
        wr(j) = SimData.Species(i).wr(j);
        wz(j) = SimData.Species(i).wz(j);
        dX(j) = SimData.Species(i).dX(j);
        dY(j) = SimData.Species(i).dY(j);
        dZ(j) = SimData.Species(i).dZ(j);
    end
    
    DiffStep = 1;

    if h.Use_FRET_Width.Value
        HeterogeneityStep = SimData.General(h.Sim_File_List.Value).HeterogeneityUpdate*1E-3.*Freq;
    else
        HeterogeneityStep = 0;
    end
    
    if h.Use_Linker_Width.Value
        linkerlength = SimData.General(h.Sim_File_List.Value).LinkerWidth;
    else
        linkerlength = 0;
    end
    %%% Now, read out species related parameters
    %%% and construct input arrays
    %%% for dynamic simlation, species are assigned based on species number
    %%% initially, i.e. initial state.
    %%% This means that static species are just assigned zero switching
    %%% probability!
    %%% Parameters are stacked arrays over all species
    D = [];
    aniso_params = [];
    LT = [];
    Dist = [];
    R0 = [];
    sigmaR = [];
    %%% set state to species
    for i = 1:numel(SimData.Species);
        %%% Concentration
        NoP = SimData.Species(i).N;
        %%% Diffusion
        D = [D; sqrt(2*SimData.Species(i).D*10^6/Freq)];
        %%% Lifetime
        %%% Lifetime of the colors
        if any([SimData.Species.UseLT] == 1)
            LT = [LT; SimData.Species(i).LT./str2double(h.Sim_MIRange.String)*MI_Bins];
        elseif (~any([SimData.Species.UseLT] == 1))&&(use_aniso == 1) %%% lifetime not checked, but anisotropy
        	LT = [LT; SimData.Species(i).LT./str2double(h.Sim_MIRange.String)*MI_Bins];
        else %%% don't evaluate lifetime
            LT = [LT; [0; 0; 0; 0] ];
        end
        %% new parameters
        %%% Anisotropy values
        a = SimData.Species(i).Aniso';
        aniso_params = [aniso_params; a(:)];
        %%% set initital state to species number
        initial_state{i} = (i-1)*ones(NoP,1);
        
        %%% For sigmaDist simulations, we need to provide now:
        %%% Distances (only nonzero for cross-color elements!!!)
        %%% sigma Distances (only nonzero for cross-color elements!!!)
        %%% R0 (only non-zero for cross-color elements!!!)
        %%% Step for recalculation
        %%% linkerlength (one value only for now!)
        if SimData.Species(i).FRET == 1 %%% no FRET specified, set distances to something very large
            largeDist = [0,0,0,0;10000,0,0,0;10000,10000,0,0;10000,10000,10000,0];
            Dist = [Dist;largeDist(:)];
        else %%% read out
            Dist = [Dist;SimData.Species(i).R(:)];
        end
        sigmaR = [sigmaR;SimData.Species(i).DistanceWidth(:)];
        %%% Set R0 to zero for unused colors!
        R0_temp = SimData.Species(i).R0(:);
        for j = SimData.Species(i).Color+1:4
            for k = 1:4
                R0_temp((k-1)*4+j) = 0;
            end
        end
        R0 = [R0;R0_temp];
    end
    aniso_params(2:4:end) = aniso_params(2:4:end)./str2double(h.Sim_MIRange.String)*MI_Bins;
    %%% convert aniso to array of probabilities

    p_aniso = [];
    for i = 1:numel(SimData.Species)
        for j = 1:4
            r = (aniso_params(16*(i-1)+4*(j-1)+1)-aniso_params(16*(i-1)+4*(j-1)+3)).*exp(-[1:MI_Bins]./aniso_params(16*(i-1)+4*(j-1)+2)) + aniso_params(16*(i-1)+4*(j-1)+3);
            p_aniso = [p_aniso,(1+2*r)./((1+2*r)+aniso_params(16*(i-1)+4*(j-1)+4)*(1-r))];
        end
    end
     
    n_states = numel(SimData.Species);
    if any([SimData.Species.FRET] == 3) %%% Dynamic
        %%% Dynamic Rates
        % reread from table
        DynRates = cell2mat(h.Sim_Dyn_Table.Data);
        DynRates(logical(eye(size(DynRates,1)))) = 0; %%% Set diagonal elements to zero
        if all(DynRates(:) == 0) %%% user clicked dynamic, but has not actually specified anything
            pTrans = eye(numel(SimData.Species));
            DynamicStep = 0; %%% 0 means it does not evaluate
        else
            DynRates = DynRates.*1E3./Freq; %%% convert to DiffTime
            DynamicStep = round(0.1/max(DynRates(:))); %%% Set dynamic step such that p_max = 0.1
            pTrans = DynRates.*DynamicStep;
            pTrans(isnan(pTrans)) = 0;
            %%% diagonal elements are 1-sum(p_else)
            for i = 1:size(pTrans,1)
                pTrans(i,i) = 1-sum(pTrans(i,:));
            end
        end
    else
        pTrans = eye(numel(SimData.Species));
        DynamicStep = 0; %%% 0 means it does not evaluate
    end
    %%% For input, the rates must have the following structure:
    %%% p = [p11,p12,13,...p21,p22,p23,...p31,p32,p33,...]
    p=[];
    for i = 1:size(pTrans,1)
        p = [p,pTrans(i,:)];
    end

    %% old code to access DifSim_ani.mex   
%     new = 1;
%     %%% only used if new is set to 1
%     type = 1;
%     switch type
%     case 1
%         %%% Parameters for 2color 2 state dynamic simulation
%         k12 = 1E3/Freq; %1 ms^-1
%         k21 = 0.5*1E3/Freq; %0.5 ms^-1
% 
% 
%         %%% Set dynamic step such that p_max = 0.1
%         DynamicStep = round(0.1/max([k12 k21]));
%         p12 = k12*DynamicStep;
%         p21 = k21*DynamicStep;
% 
%         n_states = 1;
%         k_dyn = [1-p12, p12,...
%                  p21, 1-p21];
% 
%         final_state = randi(n_states,NoP,1)-1;
% 
%         %%% For sigmaDist simulations, we need to provide now:
%         %%% Distances (only nonzero for cross-color elements!!!)
%         %%% sigma Distances (only nonzero for cross-color elements!!!)
%         %%% R0 (only non-zero for cross-color elements!!!)
%         %%% Step for recalculation
%         %%% linkerlength (one value only for now!)
%         Dist = SimData.Species(i).R;
%         R0 = SimData.Species(i).R0;
%         Dist(R0 == 0) = 0;
%         heterogeneity_step = round(10E-3*Freq*1E3);
%         linkerlength = 5;
%         Dist1 = [0,0,0,0;40,0,0,0;0,0,0,0;0,0,0,0];
%         Dist2 = [0,0,0,0;60,0,0,0;0,0,0,0;0,0,0,0];
%         Dist = [Dist1(:); Dist2(:)];
%         sigmaDist = Dist./10;
%         R0 = [R0(:); R0(:)];
%         R0(Dist == 0) = 0;
%         if new == 1
%             FRET1 = [1,0,0,0;3,1,0,0;0,0,0,0;0,0,0,0];
%             FRET2 = [1,0,0,0;1/3,1,0,0;0,0,0,0;0,0,0,0];
%             FRET = [FRET1(:); FRET2(:)];
%         end
%     case 2
%         %%% Parameters for 3color 2 state dynamic simulation
%         k12 = 100*1E3/Freq; %2 ms^-1
%         k21 = 100*1E3/Freq; %3 ms^-1
% 
%         DiffStep = 1;
%         %%% Set dynamic step such that p_max = 0.1
%         DynamicStep = round(0.1/max([k12 k21]));
%         p12 = k12*DynamicStep;
%         p21 = k21*DynamicStep;
% 
%         n_states = 2;
%         k_dyn = [1-p12, p12,...
%                  p21, 1-p21];
% 
%         final_state = randi(2,NoP,1)-1;
% 
%         R0 = 50;
%         RGR1 = 55;
%         RGR2 = 70;
%         RBG1 = 45;
%         RBG2 = 70;
%         RBR1 = 65;
%         RBR2 = 45;
% 
%         kGR1 = (R0/RGR1)^6;
%         kGR2 = (R0/RGR2)^6;
%         kBG1 = (R0/RBG1)^6;
%         kBG2 = (R0/RBG2)^6;
%         kBR1 = (R0/RBR1)^6;
%         kBR2 = (R0/RBR2)^6;
% 
%         if new == 1
%             FRET1 = [1,0,0,0;...
%                      kBG1,1,0,0;...
%                      kBR1,kGR1,1,0;...
%                      0,0,0,0];   
%             FRET2 = [1,0,0,0;...
%                      kBG2,1,0,0;...
%                      kBR2,kGR2,1,0;...
%                      0,0,0,0];
%             FRET = [FRET1(:); FRET2(:)];
%         end
%     end
    %% Start simulation
    
    %%% When looping over species, reassign Number of Particles and start
    %%% state for every particle
    for i = 1:numel(SimData.Species);
        if ~SimData.Start %%% Aborts Simulation
           return; 
        end
        NoP = SimData.Species(i).N;
        final_state_temp = initial_state{i};
        
        Photons1 = cell(NoP,1); MI1 = cell(NoP,1);
        Photons2 = cell(NoP,1); MI2 = cell(NoP,1);
        Photons3 = cell(NoP,1); MI3 = cell(NoP,1);
        Photons4 = cell(NoP,1); MI4 = cell(NoP,1);
        if 1%%% Include anisotropy (we need to initialize this also for no aniso determination)
            Photons1s = cell(NoP,1); MI1s = cell(NoP,1);
            Photons2s = cell(NoP,1); MI2s = cell(NoP,1);
            Photons3s = cell(NoP,1); MI3s = cell(NoP,1);
            Photons4s = cell(NoP,1); MI4s = cell(NoP,1);
        end
        fid = fopen([fileparts(mfilename('fullpath')),filesep,'Profiles',filesep,'timing.txt'],'w');
        fclose(fid);
        if fid == -1
            return;
        end

        Update = timer(...
            'StartFcn',{@Update_Progress,1,i,numel(SimData.Species),NoP},...
            'TimerFcn', {@Update_Progress,2,i,numel(SimData.Species),NoP},...
            'StopFcn', {@Update_Progress,3,i,numel(SimData.Species),NoP},...
            'Period',1,...
            'ExecutionMode','fixedDelay');
        start(Update)

        parfor (j = 1:NoP,UserValues.Settings.Pam.ParallelProcessing)
            %%% Generates starting position
            Pos = (BS-1).*rand(1,3);    

            %%% Pts particles in allowed areas for restricted area simulations
            if Map_Type==3
                while SimData.Map{1}(floor(Pos(1)+1),floor(Pos(2))+1) == 0
                    Pos = (BS-1).*rand(1,3);
                end
            elseif Map_Type == 6
                while SimData.Map{1}(floor(Pos(1))+1,floor(Pos(2))+1,1) == 0
                    Pos = (BS-1).*rand(1,3);
                end            
            end        
            Frametime = Simtime/Frames;

            for k=1:Frames 
                Time = clock;

                %%% Uses new map for dynamic barrier simulations
                if any(Map_Type == [6,7])
                    Sel = k;
                else
                    Sel = 1;
                end


                %%% Puts partilces back into their areas, if areas moved
                if k>1 && any(Map_Type == [6,7])
                    if SimData.Map{k-1}(floor(Pos(1)+1),floor(Pos(2))+1) ~= SimData.Map{k}(floor(Pos(1)+1),floor(Pos(2)+1))
                        [X,Y] = find(SimData.Map{k} == SimData.Map{k-1}(floor(Pos(1)+1),floor(Pos(2)+1)));
                        [~,Index] = sort((X-Pos(1)).^2 + (Y-Pos(2)).^2);
                        Pos(1) = X(Index(1));
                        Pos(2) = Y(Index(1));
                    end                
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% Main Simulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [Photons,  MI, Channel, Pol, Pos, final_state_temp(j)] = DifSim_ani(...
                    Frametime, BS,... General Parameters
                    Scan_Type, Step, Pixel, ScanTicks, DiffStep,... Scanning Parameters 
                    IRFparams, MI_Bins,...
                    D*sqrt(DiffStep),Pos,... Particle parameters
                    wr,wz,... Focus parameters
                    dX,dY,dZ,... Focus shift parameters
                    ExP,DetP,BlP,... %%% Probability parameters (excitation, Detection and Bleaching)
                    LT,p_aniso,... %%% Lifetime of the different coloqwdfdsfs
                    Dist, sigmaR, linkerlength, R0, HeterogeneityStep, Cross,... %%% Relative FRET and Crosstalk rates
                    n_states, p, final_state_temp(j), DynamicStep,...
                    uint32(Time(end)*1000+k+j),...%%% Uses current time, frame and particle to have more precision of the random seed (second resolution)
                    Map_Type, SimData.Map{Sel});  %%% Type of barriers/quenching and barrier map
                
                %%% Channel is a 8 bit number that defines the exact photon type
                %%% bits 0,1 for excitation laser
                %%% bits 2,3 for excited dye
                %%% bits 4,5 for emitting dye
                %%% bits 6,7 for detection channel

                if use_aniso == 0
                    %%% Assigns photons according to detection channel
                    Photons1{j} = [Photons1{j}; Photons(bitand(Channel,3)==0)+(k-1)*double(Frametime)];
                    Photons2{j} = [Photons2{j}; Photons(bitand(Channel,3)==1)+(k-1)*double(Frametime)];
                    Photons3{j} = [Photons3{j}; Photons(bitand(Channel,3)==2)+(k-1)*double(Frametime)];
                    Photons4{j} = [Photons4{j}; Photons(bitand(Channel,3)==3)+(k-1)*double(Frametime)];
                    MI1{j} = [MI1{j}; uint16(MI(bitand(Channel,3)==0))];
                    MI2{j} = [MI2{j}; uint16(MI(bitand(Channel,3)==1))];
                    MI3{j} = [MI3{j}; uint16(MI(bitand(Channel,3)==2))];
                    MI4{j} = [MI4{j}; uint16(MI(bitand(Channel,3)==3))];
                elseif use_aniso == 1
                    %%% Assigns photons according to detection channel
                    Photons1{j} = [Photons1{j}; Photons((bitand(Channel,3)==0) & (Pol==0))+(k-1)*double(Frametime)];
                    Photons1s{j} = [Photons1s{j}; Photons((bitand(Channel,3)==0) & (Pol==1))+(k-1)*double(Frametime)];
                    Photons2{j} = [Photons2{j}; Photons((bitand(Channel,3)==1) & (Pol==0))+(k-1)*double(Frametime)];
                    Photons2s{j} = [Photons2s{j}; Photons((bitand(Channel,3)==1) & (Pol==1))+(k-1)*double(Frametime)];
                    Photons3{j} = [Photons3{j}; Photons((bitand(Channel,3)==2) & (Pol==0))+(k-1)*double(Frametime)];
                    Photons3s{j} = [Photons3s{j}; Photons((bitand(Channel,3)==2) & (Pol==1))+(k-1)*double(Frametime)];
                    Photons4{j} = [Photons4{j}; Photons((bitand(Channel,3)==3) & (Pol==0))+(k-1)*double(Frametime)];
                    Photons4s{j} = [Photons4s{j}; Photons((bitand(Channel,3)==3) & (Pol==1))+(k-1)*double(Frametime)];
                    MI1{j} = [MI1{j}; MI((bitand(Channel,3)==0) & (Pol==0))];
                    MI1s{j} = [MI1s{j}; MI((bitand(Channel,3)==0) & (Pol==1))];
                    MI2{j} = [MI2{j}; MI((bitand(Channel,3)==1) & (Pol==0))];
                    MI2s{j} = [MI2s{j}; MI((bitand(Channel,3)==1) & (Pol==1))];
                    MI3{j} = [MI3{j}; MI((bitand(Channel,3)==2) & (Pol==0))];
                    MI3s{j} = [MI3s{j}; MI((bitand(Channel,3)==2) & (Pol==1))];
                    MI4{j} = [MI4{j}; MI((bitand(Channel,3)==3) & (Pol==0))];
                    MI4s{j} = [MI4s{j}; MI((bitand(Channel,3)==3) & (Pol==1))];
                end
            end

            FID = fopen([PathToApp,filesep,'Profiles',filesep,'Timing.txt'],'a');
            fprintf(FID,['Particle' num2str(j) '\n']);
            fclose(FID);
        end
        %%% Combines photons for all particles
        if use_aniso == 0
            Photons_total{i,1} = cell2mat(Photons1);
            MI_total{i,1} = cell2mat(MI1);
            Photons_total{i,2} = cell2mat(Photons2);
            MI_total{i,2} = cell2mat(MI2);
            Photons_total{i,3} = cell2mat(Photons3);
            MI_total{i,3} = cell2mat(MI3);
            Photons_total{i,4} = cell2mat(Photons4);
            MI_total{i,4} = cell2mat(MI4);
            clear Photons1 Photons2 Photons3 Photons4 MI1 MI2 MI3 MI4;
        elseif use_aniso == 1
            Photons_total{i,1} = cell2mat(Photons1);
            MI_total{i,1} = cell2mat(MI1);
            Photons_total{i,2} = cell2mat(Photons2);
            MI_total{i,2} = cell2mat(MI2);
            Photons_total{i,3} = cell2mat(Photons3);
            MI_total{i,3} = cell2mat(MI3);
            Photons_total{i,4} = cell2mat(Photons4);
            MI_total{i,4} = cell2mat(MI4);
            Photons_total{i,5} = cell2mat(Photons1s);
            MI_total{i,5} = cell2mat(MI1s);
            Photons_total{i,6} = cell2mat(Photons2s);
            MI_total{i,6} = cell2mat(MI2s);
            Photons_total{i,7} = cell2mat(Photons3s);
            MI_total{i,7} = cell2mat(MI3s);
            Photons_total{i,8} = cell2mat(Photons4s);
            MI_total{i,8} = cell2mat(MI4s);
            clear Photons1 Photons2 Photons3 Photons4 MI1 MI2 MI3 MI4 Photons1s Photons2s Photons3s Photons4s MI1s MI2s MI3s MI4s;
        end
        stop(Update);
    end
    
    if use_aniso == 0
        nChan = 4;
    elseif use_aniso == 1
        nChan = 8;
    end
    Sim_Photons = cell(nChan,1);
    Sim_MI = cell(nChan,1);
    for i=1:nChan %%% Combines photons of all species
        Sim_Photons{i} = cell2mat(Photons_total(:,i));
        Sim_MI{i} = uint16(cell2mat(cellfun(@double,MI_total(:,i),'UniformOutPut',false))); %%% conversion to double needed to combine with empty array(empty array is type double..)
    end

    if h.Sim_UseNoise.Value
        for i=1:nChan
            ix = mod(i-1,4)+1;
            if str2double(h.Sim_Noise{ix}.String) > 0 && ~isempty(Sim_Photons{ix})
               AIPT = Freq/(str2double(h.Sim_Noise{ix}.String)*1000);
               Noise = [];
               while (isempty(Noise) || Noise(end)<Simtime)% numel(Noise) < 1E6)
                   if isempty(Noise)
                       Noise = cumsum(exprnd(AIPT,[10000 1]));
                   else
                       Noise = [Noise; cumsum(exprnd(AIPT,[10000 1]))+Noise(end)]; %#ok<AGROW>
                   end
               end
               Noise (Noise>Simtime) = []; %#ok<AGROW>
               MI_Noise = uint16(MI_Bins*rand(numel(Noise),1));

               Sim_Photons{i} = [Sim_Photons{i}; Noise];
               Sim_MI{i} = [Sim_MI{i}; MI_Noise];
               [Sim_Photons{i}, Index] = sort(Sim_Photons{i});
               Sim_MI{i} = Sim_MI{i}(Index);
               clear Noise MI_Noise Index;
            end
        end
    end
    
    %%% Generate IRF
    IRFTime = 600; %%% 600 second irf measurement
    IRFTimeMT = IRFTime*Freq; %%% Time in MT bins
    N_IRF = 1E5;%floor(IRFTime*1000*noise(mod(i-1,4)+1)/4); %%% number of IRF photons
    IRF_MT = cell(nChan,1);
    IRF_MI = cell(nChan,1);
    for i = 1:nChan
        for j = 1:4 %%% loop over colors
            IRF_MT{i} = [IRF_MT{i}; floor(linspace(1,IRFTimeMT,N_IRF))'];
            IRF_MI{i} = [IRF_MI{i}; normrnd(IRFparams(1)+(j-1)*floor(MI_Bins/4),IRFparams(2),N_IRF,1)];
            IRF_MI{i} = mod(round(IRF_MI{i}),MI_Bins);
        end
       [IRF_MT{i}, Index] = sort(IRF_MT{i});
       IRF_MI{i} = IRF_MI{i}(Index);
    end
    
    %%% Generate uniform scatter pattern
    ScatTime = 600; %%% 600 second scatter measurement
    ScatTimeMT = IRFTime*Freq; %%% Time in MT bins
    %%% read out the noise in kHz
    if h.Sim_UseNoise.Value == 0
        noise = 1e-6*ones(1,4); 
    else
        for ix =1:4
            noise(ix) = str2double(h.Sim_Noise{ix}.String);
        end
    end
    Scat_MT = cell(nChan,1);
    Scat_MI = cell(nChan,1);
    for i = 1:nChan
        N_Scat = floor(ScatTime*1000*noise(mod(i-1,4)+1)); %%% number of scatter photons
        Scat_MT{i} = floor(linspace(1,ScatTimeMT,N_Scat))';
        Scat_MI{i} = randi([1,MI_Bins],N_Scat,1);
    end
end
%% clean up and save
clear Photons_total MI_total
switch h.Sim_Save.Value    
    case 1 %%% Save to workspace
        assignin('base',['Sim_Photons_' num2str(h.Sim_File_List.Value)],Sim_Photons);
        assignin('base',['Sim_MI_' num2str(h.Sim_File_List.Value)],Sim_MI);
    case 2 %%% Saves as TIFF
        for i=1:4            
            if ~isempty(Sim_Photons{i})
                Int = histc(double(Sim_Photons{i}),1:ScanTicks(1):double(Simtime));
                Int=reshape(Int,Pixel(1),Pixel(2),Frames);
                Int=uint16(Int);
                
                %%% Rotates image if needed
                Int=permute(Int,[2,1,3]);
                %%% Write File Name to save as tif
                File=fullfile(h.Sim_Path.String,[h.Sim_FileName.String '_C' num2str(i) '_F' num2str(h.Sim_File_List.Value) '.tif']);
                
                imwrite(Int(:,:,1),File,'tif','Compression','lzw');
                for k=2:Frames;
                    imwrite(Int(:,:,k),File,'tif','WriteMode','append','Compression','lzw');
                end
            end
        end
    case 3 %%% Save as .sim file for pam
        Header.Frames = Frames;
        Header.FrameTime = double(Simtime/Frames);
        Header.Lines = Pixel(2);
        Header.Freq = Freq;
        Header.MI_Bins = MI_Bins;
        Header.Info.Species(:) = SimData.Species(:);
        Header.Info.General = SimData.General(h.Sim_File_List.Value);
        for i=1:numel(Sim_Photons)
            [Sim_Photons{i,1},Index] = sort(Sim_Photons{i,1});
            Sim_Photons{i,2} = Sim_MI{i,1}(Index);
        end
        File=fullfile(h.Sim_Path.String,[h.Sim_FileName.String '_' num2str(h.Sim_File_List.Value) '.sim']);        
        save(File,'Sim_Photons','Header');  
        if exist('IRF_MT','var')
            %%% also save IRF
            Header.FrameTime = double(IRFTime*Freq/Frames);
            Sim_Photons = IRF_MT;
            for i=1:numel(Sim_Photons)
               Sim_Photons{i,2} = IRF_MI{i};
            end
            FileIRF = [File(1:end-4) '_irf.sim'];
            save(FileIRF,'Sim_Photons','Header');
            if h.Sim_UseNoise.Value
                %%% and scatter pattern/background
                Header.FrameTime = double(ScatTime*Freq/Frames);
                Sim_Photons = Scat_MT;
                for i=1:numel(Sim_Photons)
                   Sim_Photons{i,2} = Scat_MI{i};
                end
                FileScat = [File(1:end-4) '_scat.sim'];
                save(FileScat,'Sim_Photons','Header');
            end
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%% Peforms actual simulation procedure for camera observation %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_CameraSim(~,~)
global SimData
h = guidata(findobj('Tag','Sim'));
Sel = h.Sim_File_List.Value(1);

for i = 1:numel(SimData.Species)
    
    %%% Box Size
    BS(1) = str2double(h.Sim_BS{1}.String);
    BS(2) = str2double(h.Sim_BS{2}.String);
    %%% Frames
    Frames = str2double(h.Sim_Frames.String);
    
    %%% Pixel/Line info
    Step(1) = str2double(h.Sim_Size{1}.String);
    Pixel(1) = str2double(h.Sim_Px{1}.String);
    Step(2) = str2double(h.Sim_Size{2}.String);
    Pixel(2) = str2double(h.Sim_Px{2}.String);
    
    
    if BS(1)<Pixel(1)*Step(1)
        BS(1)=Pixel(1)*Step(1);
    end
    if BS(2)<Pixel(2)*Step(2)
        BS(2)=Pixel(2)*Step(2);
    end   
    
    NoP = SimData.Species(i).N;
    D = sqrt(2*SimData.Species(i).D*10^6*SimData.General(Sel).Time(3));
    
    wr = zeros(4,1);
    dX = zeros(4,1); dY = zeros(4,1);
    %%% Species specific parameters for used colors
    for j = 1:SimData.Species(i).Color
        wr(j) = SimData.Species(i).wr(j);
        dX(j) = SimData.Species(i).dX(j);
        dY(j) = SimData.Species(i).dY(j);
    end  
    
    ExP = SimData.Species(i).ExP;
    DetP = SimData.Species(i).DetP;
    BlP = SimData.Species(i).BlP;
    %%% Crosstalk
    SimData.Species(i).Cross(1:5:16) = 1;
    Cross = zeros(4,4);
    for j=1:4
        for k=1:4
            Cross(j,k) =  DetP(k,k)/DetP(j,k)*SimData.Species(i).Cross(j,k);
        end

    end
    
    %%% Calculates relative energy transfer rates
    switch SimData.Species(i).FRET
        case 1
            FRET = diag(ones(4,1));
        case 2
            FRET = (SimData.Species(i).R0./SimData.Species(i).R).^6;
            FRET(1:5:16) = 1;
        case 3
            FRET = diag(ones(4,1));
    end
    
    for j=SimData.Species(i).Color+1:4
       ExP(j,:) = 0; 
       FRET(j,:) = 0;
    end

    %%% Once FRET etc. is enabled
    if exist('Total','var')
        while size(Total,1) < SimData.Species(i).Color
            Total(end+1,:) = deal({uint16(zeros(Pixel(1),Pixel(2),Frames))});
            Total(:,end+1) = deal({uint16(zeros(Pixel(1),Pixel(2),Frames))});
        end
    else
        Total = repmat({uint16(zeros(Pixel(1),Pixel(2),Frames))}, SimData.Species(i).Color, SimData.Species(i).Color);
    end
    
    Px_Total = floor(BS./Step);
    Start = floor((Px_Total-Pixel)/2);
    Stop = floor((Px_Total+Pixel)/2);
    Filter = cell(SimData.Species(i).Color,1);
    for j = 1:SimData.Species(i).Color
        Filter{j} = fspecial('gaussian',4*wr(j),wr(j)/2);
        Px = floor(size(Filter{j})./Step);
        Filter{j} = single(Filter{j}(1:Px(1)*Step(1),1:Px(2)*Step(2)));
    end
    
    if D == 0 %%% Static particles
        for k=1:NoP
            
            Pos = round(BS.*rand(1,2));
            Pos(Pos==0) = 1;
            Int = cell(SimData.Species(i).Color,1);
            Location = cell(SimData.Species(i).Color,1);
            
            
            %%% No bleaching via FRET yet, need to still fix that
            %%% Calculates excitation and FRET dependent bleaching
            Bleach = zeros(SimData.Species(i).Color,1); 
            bleach = zeros(SimData.Species(i).Color,1); 
            while any(Bleach == 0)                
                for j=1:SimData.Species(i).Color
                    bleach(j) = exprnd(1./(sum(ExP(j,:).*BlP(j,:))./sum(FRET(find(Bleach==0),j))*str2double(h.Sim_Freq.String)*1000*SimData.General(Sel).Time(3)));
                end
                bleach(bleach==Inf) = Frames+1;
                bleach(Bleach~=0) = Inf;
                [~,Index] = sort(bleach);                
                Bleach(Index(1)) = bleach(Index(1))+max(Bleach);
            end
           
            %%% Particle is spread out over PSF into pixels
            for j = 1:SimData.Species(i).Color
                
                Shift = round(mod(Pos,Step));
                Location{j} = floor(Pos./Step);
                
                Int{j} = zeros(size(Filter{j})+Step);
                Int{j}((1:size(Filter{j},1))+Shift(1),(1:size(Filter{j},1))+Shift(2)) = Filter{j};
                
                Px = floor(size(Int{j})./Step);
                
                Int{j} = Int{j}(1:Px(1)*Step(1),1:Px(1)*Step(1));
                Int{j} = squeeze(sum(reshape(Int{j}, Step(1), []),1));
                Int{j} = squeeze(sum(reshape(Int{j}, Px(1), [], Px(2)),2));
                
                Begin = Start-Location{j};
                if any(Begin>0) %%% Particle before frame
                    Begin(Begin<0) = 0;
                    if all(Begin<size(Int{j})) %%% Particle partially before frame
                        Int{j} = Int{j}((1+Begin(1)):end,(1+Begin(2)):end);
                        Location{j} = Location{j} + Begin;
                    else %%% Particle completely before frame
                        Int{j} = [];
                    end
                end
                End = Stop-(Location{j}+size(Int{j}));
                if any(End<0) %%% Particle behind frame
                    End(End>0) = 0;
                    if all(End>-size(Int{j})) %%% Particle partially behind frame
                        Int{j} = Int{j}(1:(end+End(1)),1:(end+End(2)));
                    else %%% Particle completely behind frame
                        Int{j} = [];
                    end
                end 
                
                if Location{j}(1) == 0 && (size(Int{j},1)>1)
                   Int{j} = Int{j}(2:end,:); 
                   Location{j}(1) = 1;
                elseif size(Int{j},1) == 1
                    Int{j} = [];
                end
                
                if Location{j}(2) == 0 && (size(Int{j},2)>1)
                    Int{j} = Int{j}(:,2:end);
                    Location{j}(2) = 1;
                elseif size(Int{j},2) == 1
                    Int{j} = [];
                end
                
            end
            
            %%% Calculates actual Intensity per particle
            for m = 1:Frames
                ExP1 = ExP;                
                FRET1 = FRET;
                
                ExP1(find(Bleach < m),:) = 0;
                FRET1(find(Bleach < m),:) = 0;
                if any( floor(Bleach) == m)
                    ExP1 (find(floor(Bleach) == m),:) = ExP1 (find(floor(Bleach) == m),:).*repmat(mod(Bleach(find(floor(Bleach) == m)),1),[1 4]);
                    FRET1(find(floor(Bleach) == m),:) = FRET1(find(floor(Bleach) == m),:).*repmat(mod(Bleach(find(floor(Bleach) == m)),1),[1 4]);
                end
                
                
                Prob = zeros(SimData.Species(i).Color,SimData.Species(i).Color,SimData.Species(i).Color,SimData.Species(i).Color);
                for j = 1:SimData.Species(i).Color %%% Laser
                    for n = 1:SimData.Species(i).Color %%% excited dye
                        for o = 1:SimData.Species(i).Color %%% Emmiting dye
                            for p = 1:SimData.Species(i).Color %%% Detected channel
                                switch (o-n) %%% How many FRET ways are possible
                                    case 0 %%% No FRET
                                        Prob(j,n,o,p) = ExP1(n,j)... Excited dye n by laser j
                                                       *FRET1(o,n)/sum(FRET1(:,n))... No FRET from dye o to other dyes (n=o)
                                                       *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                                       *DetP(p,o); %%% Detection probability
                                    case 1 %%% Direct FRET                                                  
                                        Prob(j,n,o,p) = ExP1(n,j)... Excited dye n by laser j
                                                       *FRET1(o,n)/sum(FRET1(:,n))... FRET to dye o from dye n
                                                       *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                                       *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                                       *DetP(p,o); %%% Detection probability
                                    case 2 %%% 2Color distance FRET (Direct or 2 Step FRET)
                                        %%% FRET directly to dye o from n
                                        Prob(j,n,o,p) = ExP(n,j)... Excited dye n by laser j
                                                       *FRET1(o,n)/sum(FRET1(:,n))... FRET to dye o from dye n
                                                       *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                                       *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                                       *DetP(p,o); %%% Detection probability
                                        %%% FRET in 2 steps to dye o from n over n+1          
                                        Prob(j,n,o,p) = Prob(j,n,o,p) + ExP(n,j)... Excited dye n by laser j
                                                       *FRET1(n+1,n)/sum(FRET1(:,n))... FRET to dye n+1 from dye n
                                                       *FRET1(o,n+1)/sum(FRET1(:,n+1))... FRET to dye o from dye n+1
                                                       *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                                       *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                                       *DetP(p,o); %%% Detection probability                                                     
                                    case 3 %%% 3Color distance FRET(Direct, 2x2Step and 3Step FRET)
                                        %%% FRET directly to dye o from n
                                        Prob(j,n,o,p) = ExP(n,j)... Excited dye n by laser j
                                                       *FRET1(o,n)/sum(FRET1(:,n))... FRET to dye o from dye n
                                                       *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                                       *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                                       *DetP(p,o); %%% Detection probability
                                        %%% FRET in 2 steps to dye o from n over n+1          
                                        Prob(j,n,o,p) = Prob(j,n,o,p) + ExP(n,j)... Excited dye n by laser j
                                                       *FRET1(n+1,n)/sum(FRET1(:,n))... FRET to dye n+1 from dye n
                                                       *FRET1(o,n+1)/sum(FRET1(:,n+1))... FRET to dye o from dye n+1
                                                       *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                                       *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                                       *DetP(p,o); %%% Detection probability  
                                        %%% FRET in 2 steps to dye o from n over n+2
                                        Prob(j,n,o,p) = Prob(j,n,o,p) + ExP(n,j)... Excited dye n by laser j
                                                       *FRET1(n+2,n)/sum(FRET1(:,n))... FRET to dye n+2 from dye n
                                                       *FRET1(o,n+2)/sum(FRET1(:,n+2))... FRET to dye o from dye n+2
                                                       *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                                       *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                                       *DetP(p,o); %%% Detection probability
                                        %%% FRET in 3 steps to dye o from n over n+1 and n+2
                                        Prob(j,n,o,p) = Prob(j,n,o,p) + ExP(n,j)... Excited dye n by laser j
                                                       *FRET1(n+1,n)/sum(FRET1(:,n))... FRET to dye n+1 from dye n
                                                       *FRET1(n+2,n+1)/sum(FRET1(:,n+1))... FRET to dye n+2 from dye n+1
                                                       *FRET1(o,n+2)/sum(FRET1(:,n+2))... FRET to dye o from dye n+2
                                                       *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                                       *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                                       *DetP(p,o); %%% Detection probability                                         
                                end
                            end
                        end
                    end
                end
                Prob(isinf(Prob) | isnan(Prob)) = 0;
                Prob = squeeze(sum(sum(Prob,2),3));                   
                
                for j = 1:SimData.Species(i).Color
                    for n = 1:SimData.Species(i).Color
                        Image = Int{j}*str2double(h.Sim_Freq.String)*1000*SimData.General(Sel).Time(3)*Prob(j,n);
                        Image(Image>1e-4) = poissrnd(Image(Image>1e-4));
                        Total{j,n}((Location{j}(1):(Location{j}(1)+size(Int{j},1)-1))-Start(1)+1,(Location{j}(2):(Location{j}(2)+size(Int{j},2)-1))-Start(2)+1,m) = ...
                        Total{j,n}((Location{j}(1):(Location{j}(1)+size(Int{j},1)-1))-Start(1)+1,(Location{j}(2):(Location{j}(2)+size(Int{j},2)-1))-Start(2)+1,m) + uint16(Image);
                    end
                end                    
            end
        end
    else %%% Moving Particles
        Pos = ceil(repmat(BS,[NoP,1]).*rand(NoP,2));
        Pos(Pos==0) = 1;
        Bleach = zeros(SimData.Species(i).Color,NoP);
        for m = 1:Frames
            Pos = Pos + round(D*randn(NoP,2));
            
            %%% Puts particles back into box;
            %%% Unbleaches
            Out1 = (Pos(:,1) > BS(1)) | (Pos(:,1) <= 0);
            Out2 = (Pos(:,2) > BS(2)) | (Pos(:,2) <= 0);
            while any(Out1 | Out2)
                Bleach(:,find(Out1 | Out2)) = 0;
                Pos(Out1) = mod(BS(1)+Pos(Out1),BS(1));
                Pos([false(NoP,1); Out2]) = mod(BS(2)+Pos([false(NoP,1); Out2]),BS(2));
                Out1 = (Pos(:,1) > BS(1)) | (Pos(:,1) <= 0);
                Out2 = (Pos(:,2) > BS(2)) | (Pos(:,2) <= 0);
            end
            
            for k=1:NoP                
                Int = cell(SimData.Species(i).Color,1);
                Location = cell(SimData.Species(i).Color,1);                
                
                %%% Tests for bleaching
                bleach = zeros(SimData.Species(i).Color,1);
                for j=1:SimData.Species(i).Color
                    bleach(j) = exprnd(1./(sum(ExP(:,j).*BlP(:,j))./sum(FRET(find(Bleach(:,k)==0),j))*str2double(h.Sim_Freq.String)*1000*SimData.General(Sel).Time(3)));
                end
              
                %%% Particle is spread out over PSF into pixels 
                for j = 1:SimData.Species(i).Color
                    
                    Shift = round(mod(Pos(k,:),Step));
                    Location{j} = floor(Pos(k,:)./Step);
                             
                    Int{j} = zeros(size(Filter{j})+Step,'single');
                    Int{j}((1:size(Filter{j},1))+Shift(1),(1:size(Filter{j},1))+Shift(2)) = Filter{j};
                    
                    Px = floor(size(Int{j})./Step);                    
                    
                    Int{j} = squeeze(sum(reshape(Int{j}, Step(1), []),1));
                    Int{j} = squeeze(sum(reshape(Int{j}, Px(1), [], Px(2)),2));
                    
                    Begin = Start-Location{j};
                    if any(Begin>0) %%% Particle before frame
                        Begin(Begin<0) = 0;
                        if all(Begin<size(Int{j})) %%% Particle partially before frame
                            Int{j} = Int{j}((1+Begin(1)):end,(1+Begin(2)):end);
                            Location{j} = Location{j} + Begin;
                        else %%% Particle completely before frame
                            Int{j} = [];
                        end
                    end
                    End = Stop-(Location{j}+size(Int{j}));
                    if any(End<0) %%% Particle behind frame
                        End(End>0) = 0;
                        if all(End>-size(Int{j})) %%% Particle partially behind frame
                            Int{j} = Int{j}(1:(end+End(1)),1:(end+End(2)));
                        else %%% Particle completely behind frame
                            Int{j} = [];
                        end
                    end
                    
                    if Location{j}(1) == 0 && (size(Int{j},1)>1)
                        Int{j} = Int{j}(2:end,:);
                        Location{j}(1) = 1;
                    elseif size(Int{j},1) == 1
                        Int{j} = [];
                    end
                    if Location{j}(2) == 0 && (size(Int{j},2)>1)
                        Int{j} = Int{j}(:,2:end);
                        Location{j}(2) = 1;
                    elseif size(Int{j},2) == 1
                        Int{j} = [];
                    end
                    
                end
                  
                %%% Applies bleaching
                ExP1 = ExP;
                FRET1 = FRET;
                ExP1(find(Bleach == 1),:) = 0;
                FRET1(find(Bleach == 1),:) = 0;
                if any(bleach < 1)
                    ExP1 (find(bleach < 1),:) = ExP1 (find(bleach < 1),:).*repmat(bleach(find(bleach <1)),[1 4]);
                    FRET1(find(bleach < 1),:) = FRET1(find(bleach < 1),:).*repmat(bleach(find(bleach <1)),[1 4]);
                    Bleach(find(bleach < 1),k)=1;
                end
                
                %%% Calculates Photon probabilities
                Prob = zeros(SimData.Species(i).Color,SimData.Species(i).Color,SimData.Species(i).Color,SimData.Species(i).Color);
                for j = 1:SimData.Species(i).Color %%% Laser
                    for n = 1:SimData.Species(i).Color %%% excited dye
                        for o = 1:SimData.Species(i).Color %%% emiting dye
                            for p = 1:SimData.Species(i).Color %%% Detected channel
                                switch (o-n) %%% How many FRET ways are possible
                                    case 0 %%% No FRET
                                        Prob(j,n,o,p) = ExP1(n,j)... Excited dye n by laser j
                                            *FRET1(o,n)/sum(FRET1(:,n))... No FRET from dye o to other dyes (n=o)
                                            *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                            *DetP(p,o); %%% Detection probability
                                    case 1 %%% Direct FRET
                                        Prob(j,n,o,p) = ExP1(n,j)... Excited dye n by laser j
                                            *FRET1(o,n)/sum(FRET1(:,n))... FRET to dye o from dye n
                                            *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                            *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                            *DetP(p,o); %%% Detection probability
                                    case 2 %%% 2Color distance FRET (Direct or 2 Step FRET)
                                        %%% FRET directly to dye o from n
                                        Prob(j,n,o,p) = ExP(n,j)... Excited dye n by laser j
                                            *FRET1(o,n)/sum(FRET1(:,n))... FRET to dye o from dye n
                                            *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                            *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                            *DetP(p,o); %%% Detection probability
                                        %%% FRET in 2 steps to dye o from n over n+1
                                        Prob(j,n,o,p) = Prob(j,n,o,p) + ExP(n,j)... Excited dye n by laser j
                                            *FRET1(n+1,n)/sum(FRET1(:,n))... FRET to dye n+1 from dye n
                                            *FRET1(o,n+1)/sum(FRET1(:,n+1))... FRET to dye o from dye n+1
                                            *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                            *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                            *DetP(p,o); %%% Detection probability
                                    case 3 %%% 3Color distance FRET(Direct, 2x2Step and 3Step FRET)
                                        %%% FRET directly to dye o from n
                                        Prob(j,n,o,p) = ExP(n,j)... Excited dye n by laser j
                                            *FRET1(o,n)/sum(FRET1(:,n))... FRET to dye o from dye n
                                            *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                            *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                            *DetP(p,o); %%% Detection probability
                                        %%% FRET in 2 steps to dye o from n over n+1
                                        Prob(j,n,o,p) = Prob(j,n,o,p) + ExP(n,j)... Excited dye n by laser j
                                            *FRET1(n+1,n)/sum(FRET1(:,n))... FRET to dye n+1 from dye n
                                            *FRET1(o,n+1)/sum(FRET1(:,n+1))... FRET to dye o from dye n+1
                                            *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                            *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                            *DetP(p,o); %%% Detection probability
                                        %%% FRET in 2 steps to dye o from n over n+2
                                        Prob(j,n,o,p) = Prob(j,n,o,p) + ExP(n,j)... Excited dye n by laser j
                                            *FRET1(n+2,n)/sum(FRET1(:,n))... FRET to dye n+2 from dye n
                                            *FRET1(o,n+2)/sum(FRET1(:,n+2))... FRET to dye o from dye n+2
                                            *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                            *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                            *DetP(p,o); %%% Detection probability
                                        %%% FRET in 3 steps to dye o from n over n+1 and n+2
                                        Prob(j,n,o,p) = Prob(j,n,o,p) + ExP(n,j)... Excited dye n by laser j
                                            *FRET1(n+1,n)/sum(FRET1(:,n))... FRET to dye n+1 from dye n
                                            *FRET1(n+2,n+1)/sum(FRET1(:,n+1))... FRET to dye n+2 from dye n+1
                                            *FRET1(o,n+2)/sum(FRET1(:,n+2))... FRET to dye o from dye n+2
                                            *FRET1(o,o)/sum(FRET1(:,o))... No FRET from dye o to other dyes
                                            *Cross(p,o)/sum(Cross(:,o))... Detected photon on detector p
                                            *DetP(p,o); %%% Detection probability
                                end
                            end
                        end
                    end
                end
                Prob(isinf(Prob) | isnan(Prob)) = 0;
                Prob = squeeze(sum(sum(Prob,2),3));
                
                %%% Calculates actual photons
                for j = 1:SimData.Species(i).Color
                    for n = 1:SimData.Species(i).Color
                        Image = double(Int{j})*str2double(h.Sim_Freq.String)*1000*SimData.General(Sel).Time(3)*Prob(j,n);
                        Image(Image>1e-4) = poissrnd(Image(Image>1e-4));
                        Total{j,n}((Location{j}(1):(Location{j}(1)+size(Int{j},1)-1))-Start(1)+1,(Location{j}(2):(Location{j}(2)+size(Int{j},2)-1))-Start(2)+1,m) = ...
                            Total{j,n}((Location{j}(1):(Location{j}(1)+size(Int{j},1)-1))-Start(1)+1,(Location{j}(2):(Location{j}(2)+size(Int{j},2)-1))-Start(2)+1,m) + uint16(Image);
                    end
                end
            end            
        end 
    end  
end

if h.Sim_UseNoise.Value
    for i=1:4
        
        for j=1:4
            if str2double(h.Sim_Noise{i}.String) > 0 && size(Total,1)>=i && size(Total,2)>=j
               Noise = str2double(h.Sim_Noise{i}.String)*1000/SimData.General(Sel).Time(3);                
               Total{i,j} = Total{i,j} + uint16(poissrnd(Noise,size(Total{i,j})));
            end            
        end
    end
end

switch h.Sim_Save.Value
    case 1 %%% Save to workspace
        assignin('base',['Sim_Camera_' num2str(h.Sim_File_List.Value)],Total);
    case 2 %%% Saves as TIFF
        for i = 1:size(Total,1)
            for j = 1:size(Total,2)
                %%% Write File Name to save as tif
                File=fullfile(h.Sim_Path.String,[h.Sim_FileName.String '_Ex' num2str(i) '_Det' num2str(j) '_F' num2str(h.Sim_File_List.Value) '.tif']);
                imwrite(Total{i,j}(:,:,1),File,'tif','Compression','lzw');
                for k=2:Frames;
                    imwrite(Total{i,j}(:,:,k),File,'tif','WriteMode','append','Compression','lzw');
                end
            end
        end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%% Updates Progressbar during simulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Progress(~,~,mode,Species,NoS,NoP)
global PathToApp
h = guidata(findobj('Tag','Sim'));

switch mode
    case 1 %%% Simulation starts
        Progress(0,h.Progress_Axes,h.Progress_Text,['Simulating species ' num2str(Species) ' of ' num2str(NoS) ':']);
    case 2 %%% Simulation progress update
        FID = fopen([PathToApp,filesep,'Profiles',filesep,'timing.txt'],'r');
        Text = fread(FID);
        fclose(FID);
        Progress(sum(Text==10)/NoP,h.Progress_Axes,h.Progress_Text,['Simulating species ' num2str(Species) ' of ' num2str(NoS) ':']);
    case 3 %%% Simulation finished
        Progress(1,h.Progress_Axes,h.Progress_Text);
end
























