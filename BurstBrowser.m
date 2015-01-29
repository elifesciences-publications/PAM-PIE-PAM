function BurstBrowser %Burst Browser

hfig=findobj('Name','BurstBrowser');
global UserValues BurstMeta BurstData
LSUserValues(0);
Look=UserValues.Look;

if isempty(hfig)
    %% define main window
    h.BurstBrowser = figure(...
    'Units','normalized',...
    'Name','BurstBrowser',...
    'MenuBar','none',...
    'OuterPosition',[0.01 0.05 0.98 0.95],...
    'UserData',[],...
    'Visible','on',...
    'Tag','BurstBrowser');
    %'WindowScrollWheelFcn',@Bowser_Wheel,...
    %'KeyPressFcn',@Bowser_KeyPressFcn,...
    whitebg(h.BurstBrowser, Look.Fore);
    set(h.BurstBrowser,'Color',Look.Back);
    
    %%% define menu items
    %%% Load Burst Data Callback
    h.Load_Bursts = uimenu(...
    'Parent',h.BurstBrowser,...
    'Label','Load Burst Data',...
    'Callback',@Load_Burst_Data_Callback,...
    'Tag','Load_Burst_Data');
    
    %%% Save Analysis State
     h.Load_Bursts = uimenu(...
    'Parent',h.BurstBrowser,...
    'Label','Save Analysis State',...
    'Callback',@Save_Analysis_State_Callback,...
    'Tag','Save_Analysis_State');

    %define tabs
    %main tab
    h.Main_Tab = uitabgroup(...
        'Parent',h.BurstBrowser,...
        'Tag','Main_Tab',...
        'Units','normalized',...
        'Position',[0 0.01 0.65 0.98],...
        'SelectionChangedFcn',@MainTabSelectionChange);

    h.Main_Tab_General = uitab(h.Main_Tab,...
        'title','General',...
        'Tag','Main_Tab_General'...
        ); 

    h.MainTabGeneralPanel = uibuttongroup(...
        'Parent',h.Main_Tab_General,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabGeneralPanel');
    
    h.Main_Tab_Corrections= uitab(h.Main_Tab,...
        'title','Corrections',...
        'Tag','Main_Tab_Corrections'...
        ); 
    
    h.MainTabCorrectionsPanel = uibuttongroup(...
        'Parent',h.Main_Tab_Corrections,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabCorrectionsPanel');
    
    h.Main_Tab_Lifetime= uitab(h.Main_Tab,...
        'title','Lifetime',...
        'Tag','Main_Tab_Lifetime'...
        ); 
    
    h.MainTabLifetimePanel = uibuttongroup(...
        'Parent',h.Main_Tab_Lifetime,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','MainTabLifetimePanel');
    
    %% secondary tab selection gui
    h.Secondary_Tab = uitabgroup(...
    'Parent',h.BurstBrowser,...
    'Tag','Secondary_Tab',...
    'Units','normalized',...
    'Position',[0.65 0.01 0.34 0.98]);

    h.Secondary_Tab_Selection = uitab(h.Secondary_Tab,...
    'title','Selection',...
    'Tag','Secondary_Tab_Selection'...
    );
    
    h.SecondaryTabSelectionPanel = uibuttongroup(...
        'Parent',h.Secondary_Tab_Selection,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SecondaryTabSelectionPanel');
    
    h.Secondary_Tab_Corrections= uitab(h.Secondary_Tab,...
        'title','Corrections/Fitting',...
        'Tag','Secondary_Tab_Corrections'...
        ); 
    
    h.SecondaryTabCorrectionsPanel = uibuttongroup(...
        'Parent',h.Secondary_Tab_Corrections,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SecondaryTabCorrectionsPanel');
    
    h.Secondary_Tab_Options= uitab(h.Secondary_Tab,...
        'title','Options',...
        'Tag','Secondary_Tab_DisplayOptions'...
        ); 

    h.SecondaryTabOptionsPanel = uibuttongroup(...
        'Parent',h.Secondary_Tab_Options,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','SecondaryTabOptionsPanel');
    
    %%% Species List Right-click Menu
    h.SpeciesListMenu = uicontextmenu;
    
    h.AddSpeciesMenuItem = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Add Species',...
        'Tag','AddSpeciesMenuItem',...
        'Callback',@AddSpecies);
    
    h.RemoveSpeciesMenuItem = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Remove Species',...
        'Tag','RemoveSpeciesMenuItem',...
        'Callback',@RemoveSpecies);
    
    h.RenameSpeciesMenuItem = uimenu(...
        'Parent',h.SpeciesListMenu,...
        'Label','Rename Species',...
        'Tag','RenameSpeciesMenuItem',...
        'Callback',@RenameSpecies);
    
    %%% Define Species List
    h.SpeciesList = uicontrol(...
    'Parent',h.SecondaryTabSelectionPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Disabled,...
    'KeyPressFcn',@List_KeyPressFcn,...
    'Max',5,...
    'Position',[0 0 1 0.2],...
    'Style','listbox',...
    'Tag','SpeciesList',...
    'UIContextMenu',h.SpeciesListMenu); 
    %'ButtonDownFcn',@List_ButtonDownFcn,...
    %'CallBack',@List_ButtonDownFcn,...
    % for right click selection to work, we need to access the underlying
    % java object
    %see: http://undocumentedmatlab.com/blog/setting-listbox-mouse-actions
    drawnow;
    jScrollPane = findjobj(h.SpeciesList);
    jSpeciesList = jScrollPane.getViewport.getComponent(0);
    jSpeciesList = handle(jSpeciesList, 'CallbackProperties');
    set(jSpeciesList, 'MousePressedCallback',{@SpeciesList_ButtonDownFcn,h.SpeciesList});
    
    %define the cut table
    cname = {'min','max','active','delete'};
    cformat = {'numeric','numeric','logical','logical'};
    ceditable = [true true true true];
    table_dat = {'','',false,false};
    cwidth = {'auto','auto',50,50};
    
    h.CutTable = uitable(...
    'Parent',h.SecondaryTabSelectionPanel,...
    'Units','normalized',...
    'BackgroundColor',[Look.Axes;Look.Fore],...
    'ForegroundColor',Look.Disabled,...
    'Position',[0 0.2 1 0.3],...
    'Tag','CutTable',...
    'ColumnName',cname,...
    'ColumnFormat',cformat,...
    'ColumnEditable',ceditable,...
    'Data',table_dat,...
    'ColumnWidth',cwidth,...
    'CellEditCallback',@CutTableChange); 
    
    %define the parameter selection listboxes
    h.ParameterListX = uicontrol(...
    'Parent',h.SecondaryTabSelectionPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Axes,...
    'ForegroundColor', Look.Disabled,...
    'Max',5,...
    'Position',[0 0.55 0.5 0.3],...
    'Style','listbox',...
    'Tag','ParameterListX',...
    'Enable','on');
    
    h.ParameterListY = uicontrol(...
    'Parent',h.SecondaryTabSelectionPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Axes,...
    'ForegroundColor', Look.Disabled,...
    'Max',5,...
    'Position',[0.5 0.55 0.5 0.3],...
    'Style','listbox',...
    'Tag','ParameterListY',...
    'Enable','on');

    % for right click selection to work, we need to access the underlying
    % java object
    %see: http://undocumentedmatlab.com/blog/setting-listbox-mouse-actions
    drawnow;
    jScrollPaneX = findjobj(h.ParameterListX); %%% Execute twice because it fails to work on the first call
    jScrollPaneY = findjobj(h.ParameterListY);
    jParameterListX = jScrollPaneX.getViewport.getComponent(0);
    jParameterListY = jScrollPaneY.getViewport.getComponent(0);
    jParameterListX = handle(jParameterListX, 'CallbackProperties');
    jParameterListY = handle(jParameterListY, 'CallbackProperties');
    set(jParameterListX, 'MousePressedCallback',{@ParameterList_ButtonDownFcn,h.ParameterListX});
    set(jParameterListY, 'MousePressedCallback',{@ParameterList_ButtonDownFcn,h.ParameterListY});
    
    %%% Define MultiPlot Button
    h.MultiPlotButton = uicontrol(...
    'Parent',h.SecondaryTabSelectionPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0 0.51 0.3 0.03],...
    'Style','pushbutton',...
    'Tag','MutliPlotButton',...
    'String','Plot multiple species',...
    'FontSize',14,...
    'Callback',@MultiPlot);

    %define manual cut button
     h.CutButton = uicontrol(...
    'Parent',h.SecondaryTabSelectionPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.6 0.51 0.2 0.03],...
    'Style','pushbutton',...
    'Tag','CutButton',...
    'String','Manual Cut',...
    'FontSize',14,...
    'Callback',@ManualCut);

    %% secondary tab corrections
    %%% Buttons
    %%% Button to determine CrossTalk and DirectExcitation
    h.DetermineCorrectionsButton = uicontrol(...
    'Parent',h.SecondaryTabCorrectionsPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0 0.91 0.4 0.03],...
    'Style','pushbutton',...
    'Tag','DetermineCorrectionsButton',...
    'String','Determine Corrections',...
    'FontSize',14,...
    'Callback',@DetermineCorrections);

    %%% Button for manual gamma determination
    h.DetermineGammaManuallyButton = uicontrol(...
    'Parent',h.SecondaryTabCorrectionsPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0 0.86 0.5 0.03],...
    'Style','pushbutton',...
    'Tag','DetermineGammaManuallyButton',...
    'String','Determine Gamma Manually',...
    'FontSize',14,...
    'Callback',@DetermineGammaManually);
    
    %%% Button to determine gamma from lifetime
    h.DetermineGammaLifetimeButton = uicontrol(...
    'Parent',h.SecondaryTabCorrectionsPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.86 0.5 0.03],...
    'Style','pushbutton',...
    'Tag','DetermineGammaLifetimeButton',...
    'String','Determine Gamma from Lifetime',...
    'FontSize',14,...
    'Callback',@DetermineGammaLifetime);

    %%% Button to apply custom correction factors
    h.ApplyCorrectionsButton = uicontrol(...
    'Parent',h.SecondaryTabCorrectionsPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0 0.81 0.4 0.03],...
    'Style','pushbutton',...
    'Tag','ApplyCorrectionsButton',...
    'String','Apply Corrections',...
    'FontSize',14,...
    'Callback',@ApplyCorrections);

    %%% Table for Corrections factors
    Corrections_Rownames = {'Gamma','Crosstalk','Direct Exc.','BG GG par','BG GG perp','BG GR par',...
        'BG GR perp','BG RR par','BG RR perp','G factor Green','G factor Red','l1','l2'};
    Corrections_Columnnames = {'Correction Factors'};
    Corrections_Editable = true;
    Corrections_Data = {1;0;0;0;0;0};
    Corrections_Columnformat = {'numeric'};
    
    h.CorrectionsTable = uitable(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'Tag','CorrectionsTable',...
        'Position',[0 0.36 0.7 0.4],...
        'Data',Corrections_Data,...sdfgh
        'RowName',Corrections_Rownames,...
        'ColumnName',Corrections_Columnnames,...
        'ColumnEditable',Corrections_Editable,...
        'ColumnFormat',Corrections_Columnformat,...
        'ColumnWidth','auto',...
        'CellEditCallback',@UpdateCorrections,...
        'BackgroundColor',[Look.Axes;Look.Fore],...
        'ForegroundColor',Look.Disabled);
    
    uicontrol('Style','text',...
        'Tag','T_Threshold_Text',...
        'String','Threshold |TGX-TRR| for Corrections',...
        'FontSize',14,...
        'Units','normalized',...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Position',[0.45 0.91 0.35 0.03],...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore);
    
    h.T_Threshold_Edit =  uicontrol('Style','edit',...
        'Tag','T_Threshold_Edit',...
        'String','0.1',...
        'FontSize',14,...
        'Units','normalized',...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Position',[0.8 0.91 0.15 0.03],...
        'BackgroundColor',Look.Control,...
        'ForegroundColor',Look.Fore);
    
    %%% Uipanel for fitting lifetime-related quantities
    h.FitLifetimeRelatedPanel = uipanel(...
        'Parent',h.SecondaryTabCorrectionsPanel,...
        'Units','normalized',...
        'Position',[0 0 1 0.3],...
        'Tag','DisplayOptionsPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Lifetime Plots',...
        'FontSize',14);
    
    h.FitAnisotropyButton = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0 0.85 0.4 0.1],...
    'Style','pushbutton',...
    'Tag','FitAnisotropyButton',...
    'String','Fit Anisotropy',...
    'FontSize',14,...
    'Callback',@UpdateLifetimeFits);

    h.ManualAnisotropyButton = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0 0.75 0.4 0.1],...
    'Style','pushbutton',...
    'Tag','ManualAnisotropyButton',...
    'String','Manual Perrin Fit',...
    'FontSize',14,...
    'Callback',@UpdateLifetimeFits);

    h.PlotStaticFRETButton = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.85 0.4 0.1],...
    'Style','pushbutton',...
    'Tag','PlotStaticFRETButton',...
    'String','Plot Static FRET Line',...
    'FontSize',14,...
    'Callback',@UpdateLifetimeFits);
        
    uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.75 0.35 0.07],...
    'Style','text',...
    'Tag','SelectDonorDyeText',...
    'String','Donor Lifetime',...
    'FontSize',14);
    
    h.DonorLifetimeEdit = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
    'Position',[0.87 0.75 0.1 0.07],...
    'Style','edit',...
    'Tag','DonorLifetimeEdit',...
    'String',num2str(UserValues.BurstBrowser.Corrections.DonorLifetime),...
    'FontSize',14,...
    'Callback',@UpdateCorrections);

    uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.65 0.35 0.07],...
    'Style','text',...
    'Tag','SelectAcceptorDyeText',...
    'String','Acceptor Lifetime',...
    'FontSize',14);
    
    h.AcceptorLifetimeEdit = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
    'Position',[0.87 0.65 0.1 0.07],...
    'Style','edit',...
    'Tag','AcceptorLifetimeEdit',...
    'String',num2str(UserValues.BurstBrowser.Corrections.AcceptorLifetime),...
    'FontSize',14,...
    'Callback',@UpdateCorrections);

    h.DonorLifetimeFromDataCheckbox = uicontrol(....
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.55 0.45 0.07],...
    'Style','checkbox',...
    'Tag','DonorLifetimeFromDataCheckbox',...
    'String','Get Donor only Lifetime from Data',...
    'Value',0,...
    'enable','off',...
    'FontSize',10,...
    'Callback',@DonorOnlyLifetimeCallback);

    uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.45 0.35 0.07],...
    'Style','text',...
    'Tag','F?rsterRadiusText',...
    'String','F?rster Radius [A]',...
    'FontSize',14);
    
    h.FoersterRadiusEdit = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
    'Position',[0.87 0.45 0.1 0.07],...
    'Style','edit',...
    'Tag','F?rsterRadiusEdit',...
    'String',num2str(UserValues.BurstBrowser.Corrections.FoersterRadius),...
    'FontSize',14,...
    'Callback',@UpdateCorrections);

    uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.35 0.35 0.07],...
    'Style','text',...
    'Tag','LinkerLengthText',...
    'String','Linker Length [A]',...
    'FontSize',14);
    
    h.LinkerLengthEdit = uicontrol(...
    'Parent',h.FitLifetimeRelatedPanel,...
    'Units','normalized',...
    'BackgroundColor', Look.Fore,...
    'ForegroundColor', Look.Back,...
    'Position',[0.87 0.35 0.1 0.07],...
    'Style','edit',...
    'Tag','F?rsterRadiusEdit',...
    'String',num2str(UserValues.BurstBrowser.Corrections.LinkerLength),...
    'FontSize',14,...
    'Callback',@UpdateCorrections);

    %% secondary tab options
    
    %%% Display Options Panel
    h.DisplayOptionsPanel = uipanel(...
        'Parent',h.SecondaryTabOptionsPanel,...
        'Units','normalized',...
        'Position',[0 0.6 1 0.4],...
        'Tag','DisplayOptionsPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Display Options',...
        'FontSize',14);
    
    %%% Specify the Number of Bins
    uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Number of Bins',...
        'Tag','Text_Number_of_Bins',...
        'Units','normalized',...
        'Position',[0 0.85 0.4 0.07],...
        'FontSize',14,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    h.NumberOfBinsEdit = uicontrol(...
        'Style','edit',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Units','normalized',...
        'Position',[0.4 0.85 0.2 0.07],...
        'FontSize',14,...
        'Tag','NumberOfBinsEdit',...
        'String',UserValues.BurstBrowser.Display.NumberOfBins,...
        'Callback',@UpdatePlot...
        );
    
    %%% Specify the Plot Type
    uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Plot Type',...
        'Tag','Text_Plot_Type',...
        'Units','normalized',...
        'Position',[0 0.75 0.4 0.07],...
        'FontSize',14,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    PlotType_String = {'Image','Contour'};
    h.PlotTypePopumenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Disabled,...
        'Units','normalized',...
        'Position',[0.4 0.75 0.2 0.07],...
        'FontSize',14,...
        'Tag','PlotTypePopupmenu',...
        'String',PlotType_String,...
        'Value',find(strcmp(PlotType_String,UserValues.BurstBrowser.Display.PlotType)),...
        'Callback',@UpdatePlot...
        );
    
    %%% Specify the colormap
    uicontrol('Style','text',...
        'Parent',h.DisplayOptionsPanel,...
        'String','Colormap',...
        'Tag','Text_ColorMap',...
        'Units','normalized',...
        'Position',[0 0.65 0.4 0.07],...
        'FontSize',14,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore);
    
    Colormaps_String = {'jet','hot','bone','gray'};
    h.ColorMapPopupmenu = uicontrol(...
        'Style','popupmenu',...
        'Parent',h.DisplayOptionsPanel,...
        'BackgroundColor', Look.Axes,...
        'ForegroundColor', Look.Disabled,...
        'Units','normalized',...
        'Position',[0.4 0.65 0.2 0.07],...
        'FontSize',14,...
        'Tag','ColorMapPopupmenu',...
        'String',Colormaps_String,...
        'Value',find(strcmp(Colormaps_String,UserValues.BurstBrowser.Display.ColorMap)),...
        'Callback',@UpdatePlot...
        );
    
    %%% Data Processing Options Panel
    h.DataProcessingPanel = uipanel(...
        'Parent',h.SecondaryTabOptionsPanel,...
        'Units','normalized',...
        'Position',[0 0.2 1 0.4],...
        'Tag','DataProcessingPanel',...
        'BackgroundColor',Look.Back,...
        'ForegroundColor',Look.Fore,...
        'Title','Data Processing Options',...
        'FontSize',14);
    %% define axes in main_tab_general
    %define 2d axis
    h.axes_general =  axes(...
    'Parent',h.MainTabGeneralPanel,...
    'Units','normalized',...
    'Position',[0.07 0.06 0.73 0.75],...
    'Box','on',...
    'Tag','Axes_General',...
    'FontSize',14,...
    'View',[0 90],...
    'nextplot','add');
    
    %define 1d axes
    h.axes_1d_x =  axes(...
    'Parent',h.MainTabGeneralPanel,...
    'Units','normalized',...
    'Position',[0.07 0.81 0.73, 0.15],...
    'Box','on',...
    'Tag','Axes_1D_X',...
    'FontSize',14,...
    'XAxisLocation','top',...
    'nextplot','add',...
    'View',[0 90]);

    h.axes_1d_y =  axes(...
    'Parent',h.MainTabGeneralPanel,...
    'Units','normalized',...
    'Position',[0.8 0.06 0.15, 0.75],...
    'Tag','Main_Tab_General_Plot',...
    'Box','on',...
    'Tag','Axes_1D_Y',...
    'FontSize',20,...
    'XAxisLocation','top',...
    'nextplot','add',...
    'View',[90 90]);
    %% define axes in Corrections tab
    h.axes_crosstalk =  axes(...
    'Parent',h.MainTabCorrectionsPanel,...
    'Units','normalized',...
    'Position',[0.05 0.55 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_crosstalk',...
    'Box','on',...
    'FontSize',14,...
    'nextplot','add',...
    'View',[0 90]);
    
    h.axes_direct_excitation =  axes(...
    'Parent',h.MainTabCorrectionsPanel,...
    'Units','normalized',...
    'Position',[0.55 0.55 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_direct_excitation',...
    'Box','on',...
    'FontSize',14,...
    'nextplot','add',...
    'View',[0 90]);

    h.axes_gamma=  axes(...
    'Parent',h.MainTabCorrectionsPanel,...
    'Units','normalized',...
    'Position',[0.05 0.05 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_gamma',...
    'Box','on',...
    'FontSize',14,...
    'nextplot','add',...
    'View',[0 90]);

    h.axes_gamma_lifetime =  axes(...
    'Parent',h.MainTabCorrectionsPanel,...
    'Units','normalized',...
    'Position',[0.55 0.05 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_gamma_lifetime',...
    'Box','on',...
    'FontSize',14,...
    'nextplot','add',...
    'View',[0 90]);

    %% Define Axes in Lifetime Tab
    h.axes_EvsTauGG =  axes(...
    'Parent',h.MainTabLifetimePanel,...
    'Units','normalized',...
    'Position',[0.05 0.55 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_EvsTauGG',...
    'Box','on',...
    'FontSize',14,...
    'nextplot','add',...
    'View',[0 90]);
    
    h.axes_EvsTauRR =  axes(...
    'Parent',h.MainTabLifetimePanel,...
    'Units','normalized',...
    'Position',[0.55 0.55 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_EvsTauRR',...
    'Box','on',...
    'FontSize',14,...
    'nextplot','add',...
    'View',[0 90]);

    h.axes_rGGvsTauGG =  axes(...
    'Parent',h.MainTabLifetimePanel,...
    'Units','normalized',...
    'Position',[0.05 0.05 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_rGGvsTauGG',...
    'Box','on',...
    'FontSize',14,...
    'nextplot','add',...
    'View',[0 90]);

    h.axes_rRRvsTauRR=  axes(...
    'Parent',h.MainTabLifetimePanel,...
    'Units','normalized',...
    'Position',[0.55 0.05 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_rRRvsTauRR',...
    'Box','on',...
    'FontSize',14,...
    'nextplot','add',...
    'View',[0 90]);

    guidata(h.BurstBrowser,h);    
    %% Initialize Global Variable
    BurstMeta.Plots = [];
    %% set UserValues in GUI
    UpdateCorrections([],[]);
else
    figure(hfig);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Load *.bur file  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Burst_Data_Callback(~,~)

h = guidata(gcbo);
global BurstData UserValues BurstMeta

LSUserValues(0);
[FileName,PathName] = uigetfile({'*.bur'}, 'Choose a file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');

if FileName == 0
    return;
end

UserValues.File.BurstBrowserPath=PathName;
LSUserValues(1);
load('-mat',fullfile(PathName,FileName));

%%% Determine if an APBS or DCBS file was loaded
%%% This is important because for APBS, the donor only lifetime can be
%%% determined from the measurement!
if ~isempty(strfind(FileName,'APBS'))
    %%% Enable the donor only lifetime checkbox
    h.DonorLifetimeFromDataCheckbox.Enable = 'on';
end
%find positions of Efficiency and Stoichiometry in NameArray
posE = find(strcmp(BurstData.NameArray,'Efficiency'));
if sum(strcmp(BurstData.NameArray,'Stoichiometry')) == 0
    BurstData.NameArray{strcmp(BurstData.NameArray,'Stochiometry')} = 'Stoichiometry';
end
posS = find(strcmp(BurstData.NameArray,'Stoichiometry'));

set(h.ParameterListX, 'String', BurstData.NameArray);
set(h.ParameterListX, 'Value', posE);

set(h.ParameterListY, 'String', BurstData.NameArray);
set(h.ParameterListY, 'Value', posS);

if ~isfield(BurstData,'Cut')
    %initialize Cut Cell Array
    BurstData.Cut{1} = {};
    %add species to list
    BurstData.SpeciesNames{1} = 'Global Cuts';
    %update species list
    set(h.SpeciesList,'String',BurstData.SpeciesNames,'Value',1);
    BurstData.SelectedSpecies = 1;
end
    
BurstData.DataCut = BurstData.DataArray;

if isfield(BurstData,'SpeciesNames') %%% Previous Cuts exist
    if ~isempty(BurstData.SpeciesNames)
        %%% Update the Species List
        h.SpeciesList.String = BurstData.SpeciesNames;
        h.SpeciesList.Value = BurstData.SelectedSpecies;
    end
end

if ~isempty(BurstMeta.Plots)
    %%% Clear Plots
    plots = struct2cell(BurstMeta.Plots);
    for i = 1:numel(plots)
        delete(plots{i});
    end
    BurstMeta.Plots = [];
end
UpdateCorrections([],[]);
UpdateCutTable(h);
UpdateCuts();
UpdatePlot([]);
UpdateLifetimePlots([],[]);

function ParameterList_ButtonDownFcn(jListbox,jEventData,hListbox)
% Determine the click type
% (can similarly test for CTRL/ALT/SHIFT-click)
if jEventData.isMetaDown  % right-click is like a Meta-button
  clickType = 'Right-click';
else
  clickType = 'Left-click';
end

% Determine the current listbox index
% Remember: Java index starts at 0, Matlab at 1
mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
clickedIndex = jListbox.locationToIndex(mousePos) + 1;
%listValues = get(hListbox,'string');
%clickedValue = listValues{clickedIndex};

h = guidata(hListbox);
global BurstData

if strcmpi(clickType,'Right-click')
    %%%add to cut list if right-clicked
    if ~isfield(BurstData,'Cut')
        %initialize Cut Cell Array
        BurstData.Cut{1} = {};
        %add species to list
        BurstData.SpeciesNames{1} = 'Global Cuts';
        %update species list
        set(h.SpeciesList,'String',BurstData.SpeciesNames,'Value',1);
        BurstData.SelectedSpecies = 1;
    end
    species = get(h.SpeciesList,'Value');
    param = clickedIndex;
    
    BurstData.Cut{species}{end+1} = {BurstData.NameArray{param}, min(BurstData.DataArray(:,param)),max(BurstData.DataArray(:,param)), true,false};
    UpdateCutTable(h);
    UpdateCuts();
    %UpdateCorrections;
elseif strcmpi(clickType,'Left-click') %%% Update Plot
    %%% Update selected value
    hListbox.Value = clickedIndex;
end
UpdatePlot([],[]);
UpdateLifetimePlots([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Mouse-click Callback for Species List       %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Left-click: Change plot to selected Species %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Right-click: Open menu                      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpeciesList_ButtonDownFcn(jListbox,jEventData,hListbox)
% Determine the click type
% (can similarly test for CTRL/ALT/SHIFT-click)
if jEventData.isMetaDown  % right-click is like a Meta-button
  clickType = 'Right-click';
else
  clickType = 'Left-click';
end


% Determine the current listbox index
% Remember: Java index starts at 0, Matlab at 1
mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
clickedIndex = jListbox.locationToIndex(mousePos) + 1;

listValues = get(hListbox,'string');
if isempty(listValues)
    return;
end

clickedString = listValues{clickedIndex};

h = guidata(hListbox);
global BurstData
if strcmpi(clickType,'Right-click')
%     if numel(get(hListbox,'String')) > 1 %remove selected field
%         val = clickedIndex;
%         BurstData.SpeciesNames(val) = [];
%         set(hListbox,'Value',val-1);
%         set(hListbox,'String',BurstData.SpeciesNames); 
%     end
else %leftclick
    set(hListbox,'Value',clickedIndex);
    BurstData.SelectedSpecies = clickedIndex;
end
UpdateCutTable(h);
UpdateCuts();
UpdatePlot(hListbox);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Add Species to List (Right-click menu item)  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AddSpecies(~,~)
global BurstData
h = guidata(gcbo);
hListbox = h.SpeciesList;
%add a species to the list
BurstData.SpeciesNames{end+1} = ['Species ' num2str(numel(get(hListbox,'String')))];
set(hListbox,'String',BurstData.SpeciesNames);
%set to new species
set(hListbox,'Value',numel(get(hListbox,'String')));
BurstData.SelectedSpecies = get(hListbox,'Value');

%initialize new species Cut array - Copy from Global Cuts
BurstData.Cut{BurstData.SelectedSpecies} = BurstData.Cut{1};

UpdateCutTable(h);
UpdateCuts();
UpdatePlot([],[]);
UpdateLifetimePlots([],[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Remove Selected Species (Right-click menu item)  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RemoveSpecies(obj,~)
global BurstData
h = guidata(obj);
if numel(get(h.SpeciesList,'String')) > 1 %remove selected field
    val = h.SpeciesList.Value;
    BurstData.SpeciesNames(val) = [];
    set(h.SpeciesList,'Value',val-1);
    set(h.SpeciesList,'String',BurstData.SpeciesNames); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Rename Selected Species (Right-click menu item)  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RenameSpecies(obj,~)
global BurstData
h = guidata(obj);
SelectedSpecies = h.SpeciesList.Value;
SelectedSpeciesName = BurstData.SpeciesNames{SelectedSpecies};
NewName = inputdlg('Specify the new species name','Rename Species',[1 50],{SelectedSpeciesName},'on');

if ~isempty(NewName)
    BurstData.SpeciesNames{SelectedSpecies} = NewName{1};
    set(h.SpeciesList,'String',BurstData.SpeciesNames); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Plot in the Main Axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdatePlot(obj,~)
%% Preparation
if ~isempty(obj)
    h = guidata(obj);
else
    h = guidata(gcf);
end

global BurstData UserValues
LSUserValues(0);
if (gcbo ~= h.DetermineCorrectionsButton) && (gcbo ~= h.DetermineGammaManuallyButton) && (h.Main_Tab.SelectedTab ~= h.Main_Tab_Lifetime) && (gcbo ~= h.DetermineGammaLifetimeButton)
    %%% Change focus to GeneralTab
    h.Main_Tab.SelectedTab = h.Main_Tab_General;
end
%%% If a display option was changed, update the UserValues!
if obj == h.NumberOfBinsEdit
    nbins = str2double(h.NumberOfBinsEdit.String);
    if ~isnan(nbins)
        if nbins > 0
            UserValues.BurstBrowser.Display.NumberOfBins = nbins;
        else
            h.NumberOfBinsEdit.String = UserValues.BurstBrowser.Display.NumberOfBins;
        end
    else
        h.NumberOfBinsEdit.String = UserValues.BurstBrowser.Display.NumberOfBins;
    end
end

if obj == h.PlotTypePopumenu
    UserValues.BurstBrowser.Display.PlotType = h.PlotTypePopumenu.String{h.PlotTypePopumenu.Value};
end

if obj == h.ColorMapPopupmenu
    UserValues.BurstBrowser.Display.ColorMap = h.ColorMapPopupmenu.String{h.ColorMapPopupmenu.Value};
end
LSUserValues(1);

axes(h.axes_general);
cla(gca);
x = get(h.ParameterListX,'Value');
y = get(h.ParameterListY,'Value');

%%% Read out the Number of Bins
nbins = UserValues.BurstBrowser.Display.NumberOfBins + 1;

%% Update Plot
datatoplot = BurstData.DataCut;

[H, xbins_hist, ybins_hist] = hist2d([datatoplot(:,x) datatoplot(:,y)],nbins, nbins, [min(datatoplot(:,x)) max(datatoplot(:,x))], [min(datatoplot(:,y)) max(datatoplot(:,y))]);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end-1,:); H(end,:) = [];
l = H>0;
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
%xbins1d=linspace(min(datatoplot(:,x)),max(datatoplot(:,x)),50)+(max(datatoplot(:,x))-min(datatoplot(:,x)))/100;
%ybins1d=linspace(min(datatoplot(:,y)),max(datatoplot(:,y)),50)+(max(datatoplot(:,y))-min(datatoplot(:,y)))/100;

switch UserValues.BurstBrowser.Display.PlotType
    case 'Image' %%%image plot
        BurstData.PlotHandle = imagesc(xbins,ybins,H./max(max(H)));
        set(BurstData.PlotHandle,'AlphaData',l);
        set(gca,'YDir','normal');
    case 'Contour' %%%contour plot
        zc=linspace(1, ceil(max(max(H))),10);
        set(gca,'CLim',[0 ceil(2*max(max(H)))]);
        H(H==0) = NaN;
        [~, BurstData.PlotHandle]=contourf(xbins,ybins,H,[0 zc]);
        set(BurstData.PlotHandle,'EdgeColor','none');
end
axis('tight');
set(gca,'FontSize',20);
xlabel(h.ParameterListX.String{x});
ylabel(h.ParameterListY.String{y});

%plot 1D hists    
axes(h.axes_1d_x);
cla(gca);
hx = histc(datatoplot(:,x),xbins_hist);
hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
bar(xbins,hx,'BarWidth',1);
axis('tight');
set(gca,'XAxisLocation','top','FontSize',20,'YTickMode','auto')
yticks= get(gca,'YTick');
set(gca,'YTick',yticks(2:end));

axes(h.axes_1d_y);
cla(gca);
hy = hist(datatoplot(:,y),ybins_hist);
hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
bar(ybins,hy,'BarWidth',1);
axis('tight');
set(gca,'View',[90 90],'XDir','reverse');
set(gca,'XAxisLocation','top','FontSize',20,'YTickMode','auto')
yticks = get(gca,'YTick');
set(gca,'YTick',yticks(2:end));

%%% Update ColorMap
eval(['colormap(' UserValues.BurstBrowser.Display.ColorMap ')']);

function MultiPlot(~,~)
h = guidata(gcf);
global BurstData UserValues

axes(h.axes_general);
cla(gca);

x = get(h.ParameterListX,'Value');
y = get(h.ParameterListY,'Value');

%%% Read out the Number of Bins
nbins = UserValues.BurstBrowser.Display.NumberOfBins + 1;

num_species = numel(get(h.SpeciesList,'String')) - 1;
if num_species == 1
    return;
end
if num_species > 3
    num_species = 3;
end

datatoplot = cell(num_species,1);
for i = 1:num_species
    UpdateCuts(i+1);
    if ~isfield(BurstData,'Cut') || isempty(BurstData.Cut{i+1})
        datatoplot{i} = BurstData.DataArray;
    elseif isfield(BurstData,'Cut')
        datatoplot{i} = BurstData.DataCut;
    end
end

%find data ranges
minx = zeros(num_species,1);
miny = zeros(num_species,1);
maxx = zeros(num_species,1);
maxy = zeros(num_species,1);
for i = 1:num_species
    minx(i) = min(datatoplot{i}(:,x));
    miny(i) = min(datatoplot{i}(:,y));
    maxx(i) = max(datatoplot{i}(:,x));
    maxy(i) = max(datatoplot{i}(:,y));
end
x_boundaries = [min(minx) max(maxx)];
y_boundaries = [min(miny) max(maxy)];

H = cell(num_species,1);
for i = 1:num_species
    [H{i}, xbins_hist, ybins_hist] = hist2d([datatoplot{i}(:,x) datatoplot{i}(:,y)],nbins, nbins, x_boundaries, y_boundaries);
    H{i}(H{i}==0) = NaN;
    H{i}(:,end-1) = H{i}(:,end-1) + H{i}(:,end); H{i}(:,end) = [];
    H{i}(end-1,:) = H{i}(end-1,:) + H{i}(end-1,:); H{i}(end,:) = [];
end

xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;

%%% prepare image plot
white = 1;
axes(h.axes_general);
if num_species == 2
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,3) = H{1}/max(max(H{1})); %%% blue
        zz(:,:,1) = H{2}/max(max(H{2})); %%% red
    elseif white == 1
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
    end
elseif num_species == 3
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    H{3}(isnan(H{3})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,3) = H{1}/max(max(H{1})); %%% blue
        zz(:,:,1) = H{2}/max(max(H{2})); %%% red
        zz(:,:,2) = H{3}/max(max(H{3})); %%% green
    elseif white == 1
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
        zz(:,:,1) = zz(:,:,1) - H{3}./max(max(H{3})); %%% green
        zz(:,:,3) = zz(:,:,3) - H{3}./max(max(H{3})); %%% greenrt?f?
    end
else
    return;
end


%%% plot
imagesc(xbins,ybins,zz);
set(gca,'YDir','normal');
set(gca,'FontSize',20);
xlabel(h.ParameterListX.String{x});
ylabel(h.ParameterListY.String{y});

axes(h.axes_1d_x);
cla(gca);
%plot first histogram
hx = histc(datatoplot{1}(:,x),xbins_hist);
hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
%normalize
hx = hx./sum(hx); hx = hx';
%barx(1) = bar(xbins,hx,'BarWidth',1,'FaceColor',[0 0 1],'EdgeColor',[0 0 1]);
stairsx = zeros(num_species,1);
stairsx(1) = stairs([xbins(1)-min(diff(xbins))/2 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','b','LineWidth',2);
hold on;
%plot rest of histograms
%color = {[1 0 0], [0 1 0]};
for i = 2:num_species
    hx = histc(datatoplot{i}(:,x),xbins_hist);
    hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
    %normalize
    hx = hx./sum(hx); hx = hx';
    if i == 2 %%% plot red
        stairsx(i) = stairs([xbins(1)-min(diff(xbins))/2 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','r','LineWidth',2);
    elseif i == 3 %%% plot green
        stairsx(i) = stairs([xbins(1)-min(diff(xbins))/2 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','g','LineWidth',2);
    end
    %barx(i) =bar(xbins,hx,'BarWidth',1,'FaceColor',color{i-1},'EdgeColor',color{i-1});
end

axis('tight');
set(gca,'XAxisLocation','top','FontSize',20,'YTickMode','auto')
yticks = get(gca,'YTick');
set(gca,'YTick',yticks(2:end));

axes(h.axes_1d_y);
cla(gca);
%plot first histogram
hy = histc(datatoplot{1}(:,y),ybins_hist);
hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
%normalize
hy = hy./sum(hy); hy = hy';
%bary(1) = bar(ybins,hy,'BarWidth',1,'FaceColor',[0 0 1],'EdgeColor',[0 0 1]);
stairsy = zeros(num_species,1);
stairsy(1) = stairs([ybins(1)-min(diff(ybins))/2 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','b','LineWidth',2);
hold on;
%plot rest of histograms
for i = 2:num_species
    hy = histc(datatoplot{i}(:,y),ybins_hist);
    hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
    %normalize
    hy = hy./sum(hy); hy = hy';
    %bary(i) = bar(ybins,hy,'BarWidth',1,'FaceColor',color{i-1},'EdgeColor',color{i-1});
    if i == 2 %%% plot red
        stairsy(i) = stairs([ybins(1)-min(diff(ybins))/2 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','r','LineWidth',2);
    elseif i == 3 %%% plot green
        stairsy(i) = stairs([ybins(1)-min(diff(ybins))/2 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','g','LineWidth',2);
    end
end
axis('tight');
set(gca,'View',[90 90],'XDir','reverse','YTickMode','auto');
set(gca,'XAxisLocation','top','FontSize',20)
yticks = get(gca,'YTick');
set(gca,'YTick',yticks(2:end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Manual Cut by selecting an area in the current selection  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
function ManualCut(~,~)

h = guidata(gcbo);
global BurstData
set(gcf,'Pointer','cross');
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;           % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
set(gcf,'Pointer','Arrow');
point1 = point1(1,1:2);
point2 = point2(1,1:2);

if (all(point1(1:2) == point2(1:2)))
    disp('error');
    return;
end
    
if ~isfield(BurstData,'Cut')
    %initialize Cut Cell Array
    BurstData.Cut{1} = {};
    %add species to list
    BurstData.SpeciesNames{1} = 'Species 1';
    %update species list
    set(h.SpeciesList,'String',BurstData.SpeciesNames,'Value',1);
    BurstData.SelectedSpecies = 1;
end

species = get(h.SpeciesList,'Value');
BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};

UpdateCutTable(h);
UpdateCuts();
UpdatePlot([],[]);
UpdateLifetimePlots([],[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates/Initializes the Cut Table in GUI with stored Cuts  %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCutTable(h)
global BurstData
species = BurstData.SelectedSpecies;

if ~isempty(BurstData.Cut{species})
    data = vertcat(BurstData.Cut{species}{:});
    rownames = data(:,1);
    data = data(:,2:end);
else %data has been deleted, reset to default values
    data = {'','',false,false};
    rownames = {''};
end

set(h.CutTable,'Data',data,'RowName',rownames);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Cuts to Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCuts(species)
global BurstData
%%% If no species is specified, read out selected species.
if nargin < 1
    species = BurstData.SelectedSpecies;
end

%%% If no Cuts are specified yet, return.
if ~isfield(BurstData,'Cut')
    return;
end

CutState = vertcat(BurstData.Cut{species}{:});
Valid = true(size(BurstData.DataArray,1),1);
if ~isempty(CutState) %%% only procede if there are elements in the CutTable
    for i = 1:size(CutState,1)
        if CutState{i,4} == 1 %%% only if the Cut is set to "active"
            Index = find(strcmp(CutState(i,1),BurstData.NameArray));
            Valid = Valid & (BurstData.DataArray(:,Index) >= CutState{i,2}) & (BurstData.DataArray(:,Index) <= CutState{i,3});
        end
    end
end

BurstData.DataCut = BurstData.DataArray(Valid,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on change in the Cut Table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Cut Array and GUI/Plots     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CutTableChange(hObject,eventdata)
%this executes if a value in the CutTable is changed
h = guidata(hObject);
global BurstData
%check which cell was changed
index = eventdata.Indices;
%read out the parameter name
ChangedParameterName = BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{1};
%change value in structure
NewData = eventdata.NewData;
switch index(2)
    case {1} %min boundary was changed
        if BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{3} < eventdata.NewData
            NewData = eventdata.PreviousData;
        end
    case {2} %max boundary was changed
        if BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{2} > eventdata.NewData
            NewData = eventdata.PreviousData;
        end
    case {3} %active/inactive change
        NewData = eventdata.NewData;
end

if index(2) ~= 4        
    BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{index(2)+1}=NewData;
elseif index(2) == 4 %delete this entry
    BurstData.Cut{BurstData.SelectedSpecies}(index(1)) = [];
end

%%% If a change was made to the GlobalCuts Species, update all other
%%% existent species with the changes
if BurstData.SelectedSpecies == 1
    if numel(BurstData.Cut) > 1 %%% Check if there are other species defined
        %%% cycle through the number of other species
        for j = 2:numel(BurstData.Cut)
            %%% Check if the parameter already exists in the species j
            ParamList = vertcat(BurstData.Cut{j}{:});
            if ~isempty(ParamList)
                ParamList = ParamList(1:numel(BurstData.Cut{j}),1);
                CheckParam = strcmp(ParamList,ChangedParameterName);
                if any(CheckParam)
                    %%% Check wheter do delete or change the parameter
                    if index(2) ~= 4 %%% Parameter added or changed
                        %%% Override the parameter with GlobalCut
                        BurstData.Cut{j}(CheckParam) = BurstData.Cut{1}(index(1));
                    elseif index(2) == 4 %%% Parameter was deleted
                        BurstData.Cut{j}(CheckParam) = [];
                    end
                else %%% Parameter is new to GlobalCut
                    BurstData.Cut{j}(end+1) = BurstData.Cut{1}(index(1));
                end
            else %%% Parameter is new to GlobalCut
                BurstData.Cut{j}(end+1) = BurstData.Cut{1}(index(1));
            end
        end
    end
end

%%% Update GUI elements
UpdateCutTable(h);
UpdateCuts();
UpdatePlot([],[]);
UpdateLifetimePlots(hObject,[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Determines the Correction Factors automatically  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineCorrections(~,~)
global BurstData BurstMeta UserValues
LSUserValues(0);
h = guidata(gcbo);

%%% Change focus to CorrectionsTab
h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;

indS = find(strcmp(BurstData.NameArray,'Stoichiometry'));
indE = find(strcmp(BurstData.NameArray,'Efficiency'));
indDur = find(strcmp(BurstData.NameArray,'Duration [ms]'));
indNGG = find(strcmp(BurstData.NameArray,'Number of Photons (GG)'));
indNGR = find(strcmp(BurstData.NameArray,'Number of Photons (GR)'));
indNRR = find(strcmp(BurstData.NameArray,'Number of Photons (RR)'));

T_threshold = str2double(h.T_Threshold_Edit.String);
if isnan(T_threshold)
    T_threshold = 0.1;
end
cutT = 1;
if cutT == 0
    data_for_corrections = BurstData.DataArray;
elseif cutT == 1
    T = strcmp(BurstData.NameArray,'|TGX-TRR| Filter');
    valid = (BurstData.DataArray(:,T) < T_threshold);
    data_for_corrections = BurstData.DataArray(valid,:);
end

%%% Read out corrections
Background_GR = UserValues.BurstBrowser.Corrections.Background_GRpar + UserValues.BurstBrowser.Corrections.Background_GRperp;
Background_GG = UserValues.BurstBrowser.Corrections.Background_GGpar + UserValues.BurstBrowser.Corrections.Background_GGperp;
Background_RR = UserValues.BurstBrowser.Corrections.Background_RRpar + UserValues.BurstBrowser.Corrections.Background_RRperp;

%% plot raw Efficiency for S>0.9
%%% check if plot exists
x_axis = linspace(0,0.3,50);
axes(h.axes_crosstalk);
if ~isfield(BurstMeta.Plots,'histE_donly')
    Smin = 0.9;
    S_threshold = (data_for_corrections(:,indS)>Smin);
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
    E_raw = NGR./(NGR+NGG);
    BurstData.Corrections.histE_donly = histc(E_raw,x_axis);
    BurstMeta.Plots.histE_donly = bar(x_axis, BurstData.Corrections.histE_donly,'BarWidth',1);
    axis tight;
    xlabel('Proximity Ratio');
    ylabel('#');
    title('Proximity Ratio of Donor only');
end
%%% check if fit exists
if isfield(BurstMeta.Plots,'FitCrosstalk')
    delete(BurstMeta.Plots.FitCrosstalk);
end
%fit single gaussian
[mean_ct, BurstMeta.Plots.FitCrosstalk] = GaussianFit(x_axis',BurstData.Corrections.histE_donly,1,1);
UserValues.BurstBrowser.Corrections.CrossTalk_GR = mean_ct./(1-mean_ct);
%% plot raw data for S > 0.3 for direct excitation
%%% check if plot exists
Smax = 0.2;
x_axis = linspace(0,Smax,20);
axes(h.axes_direct_excitation);
if ~isfield(BurstMeta.Plots,'histS_aonly')
    S_threshold = (data_for_corrections(:,indS)<Smax);
    NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
    NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
    NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
    S_raw = (NGG+NGR)./(NGG+NGR+NRR);
    BurstData.Corrections.histS_aonly = histc(S_raw,x_axis);
    BurstMeta.Plots.histS_aonly = bar(x_axis, BurstData.Corrections.histS_aonly,'BarWidth',1);
    axis tight;
    xlabel('Stoiciometry (raw)');
    ylabel('#');
    title('Raw Stoichiometry of Acceptor only');
end
%%% check if fit exists
if isfield(BurstMeta.Plots,'FitDirectExcitation')
    delete(BurstMeta.Plots.FitDirectExcitation);
end
%fit single gaussian
[mean_de, BurstMeta.Plots.FitDirectExcitation] = GaussianFit(x_axis',BurstData.Corrections.histS_aonly,1,1);
UserValues.BurstBrowser.Corrections.DirectExcitation_GR = mean_de./(1-mean_de);
%% plot gamma plot for two populations (or lifetime versus E)
axes(h.axes_gamma);
%%% clear previous plot
delete(h.axes_gamma.Children);
%%% get E-S values between 0.3 and 0.8;
S_threshold = ( (data_for_corrections(:,indS) > 0.3) & (data_for_corrections(:,indS) < 0.9) );
%%% Calculate "raw" E and S with gamma = 1, but still apply direct
%%% excitation,crosstalk, and background corrections!
NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
NGR = NGR - UserValues.BurstBrowser.Corrections.DirectExcitation_GR.*NRR - UserValues.BurstBrowser.Corrections.CrossTalk_GR.*NGG;
E_raw = NGR./(NGR+NGG);
S_raw = (NGG+NGR)./(NGG+NGR+NRR);
BurstMeta.Plots.GammaPlot_Fit = plot2dhist(E_raw,1./S_raw,[0 1], [min(1./S_raw) max(1./S_raw)],51);
BurstMeta.Corrections.E_raw = E_raw;
BurstMeta.Corrections.S_raw = S_raw;
xlabel('Efficiency');
ylabel('1/Stoichiometry');
title('1/Stoichiometry vs. Efficiency for gamma = 1');

%%% check if fit exists
if isfield(BurstMeta.Plots,'GammaFit')
    delete(BurstMeta.Plots.GammaFit);
end
%%% Fit linearly
fitGamma = fit(BurstMeta.Corrections.E_raw,1./BurstMeta.Corrections.S_raw,'poly1');
BurstMeta.Plots.GammaFit = plot(fitGamma);legend('off');
BurstMeta.Plots.GammaFit.Color = [0 0 1];
BurstMeta.Plots.GammaFit.LineWidth = 3;
set(BurstMeta.Plots.GammaFit,'LineWidth',2);
%%% Determine Gamma and Beta
coeff = coeffvalues(fitGamma); m = coeff(1); b = coeff(2);
UserValues.BurstBrowser.Corrections.Gamma_GR = (b - 1)/(b + m - 1);
%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[]);
%%% Apply Corrections
ApplyCorrections;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General 1D-Gauss Fit Function  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mean,plot_handles] = GaussianFit(x_data,y_data,N_gauss,display,start_param)
if N_gauss == 1
    Gauss = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;
    if nargin <5 %no start parameters specified
        A = max(y_data);%set amplitude as max value
        m = sum(y_data.*x_data)./sum(y_data);%mean as center value
        s = sqrt(sum(y_data.*(x_data-m).^2)./sum(y_data));%std as sigma
        b=0;%assume zero background
        param = [A,m,s,b];
    end
    gauss = fit(x_data,y_data,Gauss,'StartPoint',param);
    coefficients = coeffvalues(gauss);
    mean = coefficients(2);
elseif N_gauss == 2
    Gauss = @(A1,m1,s1,A2,m2,s2,b,x) A1*exp(-(x-m1).^2./s1^2)+A2*exp(-(x-m2).^2./s2^2)+b;
    if nargin <5 %no start parameters specified
        A1 = max(y_data);%set amplitude as max value
        A2 = A1;
        m1 = sum(y_data.*x_data)./sum(y_data);%mean as center value
        m2 = m1;
        s1 = sqrt(sum(y_data.*(x_data-m1).^2)./sum(y_data));%std as sigma
        s2 = s1;
        b=0;%assume zero background
        param = [A1,m1,s1,A2,m2,s2,b];
    end
    gauss = fit(x_data,y_data,Gauss,'StartPoint',param);
    coefficients = coeffvalues(gauss);
    %get maximum amplitude
    [~,Amax] = max([coefficients(1) coefficients(4)]);
    if Amax == 1
        mean = coefficients(2);
    elseif Amax == 2
        mean = coefficients(5);
    end
end
if display
    axes(gca);
    pfit = plot(gauss);
    set(pfit,'LineWidth',2);
    plot_handles = pfit;
    if N_gauss == 2
        Gauss1 = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;
        G1 = Gauss1(coefficients(1),coefficients(2),coefficients(3),coefficients(7),x_data);
        G2 = Gauss1(coefficients(4),coefficients(5),coefficients(6),coefficients(7),x_data);
        plot_handles(2) = plot(x_data,G1,'LineStyle','--','Color','r');
        plot_handles(3) = plot(x_data,G2,'LineStyle','--','Color','r');
    end
    legend('off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Corrections in GUI and UserValues  %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateCorrections(obj,~)
global UserValues

if isempty(obj) %%% Just change the data to what is stored in UserValues
    h = guidata(gcf);
    h.CorrectionsTable.Data = {UserValues.BurstBrowser.Corrections.Gamma_GR;...
        UserValues.BurstBrowser.Corrections.CrossTalk_GR;...
        UserValues.BurstBrowser.Corrections.DirectExcitation_GR;...
        UserValues.BurstBrowser.Corrections.Background_GGpar;...
        UserValues.BurstBrowser.Corrections.Background_GGperp;...
        UserValues.BurstBrowser.Corrections.Background_GRpar;...
        UserValues.BurstBrowser.Corrections.Background_GRperp;...
        UserValues.BurstBrowser.Corrections.Background_RRpar;...
        UserValues.BurstBrowser.Corrections.Background_RRperp;...
        UserValues.BurstBrowser.Corrections.GfactorGreen;...
        UserValues.BurstBrowser.Corrections.GfactorRed;...
        UserValues.BurstBrowser.Corrections.l1;...
        UserValues.BurstBrowser.Corrections.l2};
else %%% Update UserValues with new values
    h = guidata(obj);
    LSUserValues(0);
    switch obj
        case h.CorrectionsTable
            UserValues.BurstBrowser.Corrections.Gamma_GR = obj.Data{1};
            UserValues.BurstBrowser.Corrections.CrossTalk_GR = obj.Data{2};
            UserValues.BurstBrowser.Corrections.DirectExcitation_GR= obj.Data{3};
            UserValues.BurstBrowser.Corrections.Background_GGpar= obj.Data{4};
            UserValues.BurstBrowser.Corrections.Background_GGperp= obj.Data{5};
            UserValues.BurstBrowser.Corrections.Background_GRpar= obj.Data{6};
            UserValues.BurstBrowser.Corrections.Background_GRperp= obj.Data{7};
            UserValues.BurstBrowser.Corrections.Background_RRpar= obj.Data{8};
            UserValues.BurstBrowser.Corrections.Background_RRperp= obj.Data{9};
            UserValues.BurstBrowser.Corrections.GfactorGreen = obj.Data{10};
            UserValues.BurstBrowser.Corrections.GfactorRed = obj.Data{11};
            UserValues.BurstBrowser.Corrections.l1 = obj.Data{12};
            UserValues.BurstBrowser.Corrections.l2 = obj.Data{13};
        case h.DonorLifetimeEdit
            if ~isnan(str2double(h.DonorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.DonorLifetime = str2double(h.DonorLifetimeEdit.String);
            else %%% Reset value
                h.DonorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.DonorLifetime);
            end
        case h.AcceptorLifetimeEdit
            if ~isnan(str2double(h.AcceptorLifetimeEdit.String))
                UserValues.BurstBrowser.Corrections.AcceptorLifetime = str2double(h.AcceptorLifetimeEdit.String);
            else %%% Reset value
                h.AcceptorLifetimeEdit.String = num2str(UserValues.BurstBrowser.Corrections.AcceptorLifetime);
            end
        case h.FoersterRadiusEdit
            if ~isnan(str2double(h.FoersterRadiusEdit.String))
                UserValues.BurstBrowser.Corrections.FoersterRadius = str2double(h.FoersterRadiusEdit.String);
            else %%% Reset value
                h.FoersterRadiusEdit.String = num2str(UserValues.BurstBrowser.Corrections.FoersterRadius);
            end
        case h.LinkerLengthEdit
            if ~isnan(str2double(h.LinkerLengthEdit.String))
                UserValues.BurstBrowser.Corrections.LinkerLength = str2double(h.LinkerLengthEdit.String);
            else %%% Reset value
                h.LinkerLengthEdit.String = num2str(UserValues.BurstBrowser.Corrections.LinkerLength);
            end
    end
    LSUserValues(1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Corrections to data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ApplyCorrections(~,~)
global BurstData UserValues
%% FRET and Stoichiometry Corrections
%%% Read out indices of parameters
indS = strcmp(BurstData.NameArray,'Stoichiometry');
indE = strcmp(BurstData.NameArray,'Efficiency');
indDur = strcmp(BurstData.NameArray,'Duration [ms]');
indNGG = strcmp(BurstData.NameArray,'Number of Photons (GG)');
indNGR = strcmp(BurstData.NameArray,'Number of Photons (GR)');
indNRR = strcmp(BurstData.NameArray,'Number of Photons (RR)');

%%% Read out photons counts and duration
NGG = BurstData.DataArray(:,indNGG);
NGR = BurstData.DataArray(:,indNGR);
NRR = BurstData.DataArray(:,indNRR);
Dur = BurstData.DataArray(:,indDur);

%%% Read out corrections
LSUserValues(0);
gamma_gr = UserValues.BurstBrowser.Corrections.Gamma_GR;
ct_gr = UserValues.BurstBrowser.Corrections.CrossTalk_GR;
de_gr = UserValues.BurstBrowser.Corrections.DirectExcitation_GR;
BG_GG = UserValues.BurstBrowser.Corrections.Background_GGpar + UserValues.BurstBrowser.Corrections.Background_GGperp;
BG_GR = UserValues.BurstBrowser.Corrections.Background_GRpar + UserValues.BurstBrowser.Corrections.Background_GRperp;
BG_RR = UserValues.BurstBrowser.Corrections.Background_RRpar + UserValues.BurstBrowser.Corrections.Background_RRperp;

%%% Apply Background corrections
NGG = NGG - Dur.*BG_GG;
NGR = NGR - Dur.*BG_GR;
NRR = NRR - Dur.*BG_RR;

%%% Apply CrossTalk and DirectExcitation Corrections
NGR = NGR - de_gr.*NRR - ct_gr.*NGG;

%%% Recalculate Efficiency and Stoichiometry
E = NGR./(NGR + gamma_gr.*NGG);
S = (NGR + gamma_gr.*NGG)./(NGR + gamma_gr.*NGG + NRR);

%%% Update Values in the DataArray
BurstData.DataArray(:,indE) = E;
BurstData.DataArray(:,indS) = S;

%% Anisotropy Corrections
%%% Read out indices of parameters
ind_rGG = strcmp(BurstData.NameArray,'Anisotropy GG');
ind_rRR = strcmp(BurstData.NameArray,'Anisotropy RR');
indDur = strcmp(BurstData.NameArray,'Duration [ms]');
indNGGpar = strcmp(BurstData.NameArray,'Number of Photons (GG par)');
indNGGperp = strcmp(BurstData.NameArray,'Number of Photons (GG perp)');
indNRRpar = strcmp(BurstData.NameArray,'Number of Photons (RR par)');
indNRRperp = strcmp(BurstData.NameArray,'Number of Photons (RR perp)');

%%% Read out photons counts and duration
NGGpar = BurstData.DataArray(:,indNGGpar);
NGGperp = BurstData.DataArray(:,indNGGperp);
NRRpar = BurstData.DataArray(:,indNRRpar);
NRRperp = BurstData.DataArray(:,indNRRperp);
Dur = BurstData.DataArray(:,indDur);

%%% Read out corrections
LSUserValues(0);
Ggreen = UserValues.BurstBrowser.Corrections.GfactorGreen;
Gred = UserValues.BurstBrowser.Corrections.GfactorRed;
l1 = UserValues.BurstBrowser.Corrections.l1;
l2 = UserValues.BurstBrowser.Corrections.l2;
BG_GGpar = UserValues.BurstBrowser.Corrections.Background_GGpar;
BG_GGperp = UserValues.BurstBrowser.Corrections.Background_GGperp;
BG_RRpar = UserValues.BurstBrowser.Corrections.Background_RRpar;
BG_RRperp = UserValues.BurstBrowser.Corrections.Background_RRperp;

%%% Apply Background corrections
NGGpar = NGGpar - Dur.*BG_GGpar;
NGGperp = NGGperp - Dur.*BG_GGperp;
NRRpar = NRRpar - Dur.*BG_RRpar;
NRRperp = NRRperp - Dur.*BG_RRperp;

%%% Recalculate Anisotropies
rGG = (Ggreen.*NGGpar - NGGperp)./( (1-3*l2).*Ggreen.*NGGpar + (2-3*l1).*NGGperp);
rRR = (Gred.*NRRpar - NRRperp)./( (1-3*l2).*Gred.*NRRpar + (2-3*l1).*NRRperp);

%%% Update Values in the DataArray
BurstData.DataArray(:,ind_rGG) = rGG;
BurstData.DataArray(:,ind_rRR) = rRR;

%%% Update Display
UpdateCuts;
UpdatePlot([],[]);
UpdateLifetimePlots([],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Manual gamma determination by selecting the mid-points %%%%%%%%%%%%
%%%%%%% of two populations                                     %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGammaManually(~,~)
global BurstData UserValues BurstMeta
h = guidata(gcf);
%%% Delete Previous Plot
delete(h.axes_gamma.Children);
%%% change the plot in axes_gamma to S vs E (instead of default 1/S vs. E)
axes(h.axes_gamma);
[H, xbins_hist, ybins_hist] = hist2d([BurstData.Corrections.E_raw BurstData.Corrections.S_raw],51, 51, [0 1], [0 1]);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end-1,:); H(end,:) = [];
l = H>0;
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
im = imagesc(xbins,ybins,H./max(max(H)));
set(im,'AlphaData',l);
set(gca,'YDir','normal');
axis('tight');
BurstData.Plots.GammaPlot = im;

%%% Update Axis Labels
xlabel('Efficiency');
ylabel('Stoichiometry');
title('Stoichiometry vs. Efficiency for gamma = 1');

[e, s] = ginput(2);
hold on;
scatter(e,s,1000,'o','LineWidth',4,'MarkerEdgeColor','b');
scatter(e,s,1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b');
s = 1./s;
m = (s(2)-s(1))./(e(2)-e(1));
b = s(2) - m.*e(2);

UserValues.BurstBrowser.Corrections.Gamma_GR = (b - 1)/(b + m - 1);


%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[]);
%%% Apply Corrections
ApplyCorrections;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Saves the state of the analysis to the .bur file %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_Analysis_State_Callback(~,~)
global BurstData

save(BurstData.FileName,'BurstData');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates lifetime-related plots in Lifetime Tab %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimePlots(obj,~)
global BurstData
if ~isempty(obj)
    h = guidata(obj);
else
    h = guidata(gcf);
end

if isempty(BurstData)
    return;
end

%%% Use the current cut Data (of the selected species) for plots
datatoplot = BurstData.DataCut;
%%% read out the indices of the parameters to plot
idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
idx_rGG = strcmp('Anisotropy GG',BurstData.NameArray);
idx_rRR = strcmp('Anisotropy RR',BurstData.NameArray);
idxE = strcmp('Efficiency',BurstData.NameArray);
%% Plot E vs. tauGG in first plot
%%% Check, whether a static FRET line already existed
StaticFRETexisted = ~isempty(findobj(h.axes_EvsTauGG.Children,'Type','Line'));
cla(h.axes_EvsTauGG);
axes(h.axes_EvsTauGG);
legend('off');

[H, xbins_hist, ybins_hist] = hist2d([datatoplot(:,idx_tauGG), datatoplot(:,idxE)],51, 51, [0 5], [0 1]);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end-1,:); H(end,:) = [];
l = H>0;
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
im = imagesc(xbins,ybins,H./max(max(H)));
set(im,'AlphaData',l);
set(gca,'YDir','normal');
axis('tight');
ylabel('Efficiency');
xlabel('Lifetime GG [ns]');
title('Efficiency vs. Lifetime GG');
ylim([0 1]);
if StaticFRETexisted
    %%% replot the static FRET line
    UpdateLifetimeFits(h.PlotStaticFRETButton,[]);
end
%% Plot E vs. tauRR in second plot
cla(h.axes_EvsTauRR);
axes(h.axes_EvsTauRR);
legend('off');

[H, xbins_hist, ybins_hist] = hist2d([datatoplot(:,idx_tauRR),datatoplot(:,idxE)],51, 51, [0 6], [0 1]);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end-1,:); H(end,:) = [];
l = H>0;
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
im = imagesc(xbins,ybins,H./max(max(H)));
set(im,'AlphaData',l);
set(gca,'YDir','normal');
axis('tight');
xlabel('Lifetime RR [ns]');
ylabel('Efficiency');
title('Efficiency vs. Lifetime RR');
%% Plot rGG vs. tauGG in third plot
cla(h.axes_rGGvsTauGG);
axes(h.axes_rGGvsTauGG);
legend('off');

[H, xbins_hist, ybins_hist] = hist2d([datatoplot(:,idx_tauGG), datatoplot(:,idx_rGG)],51, 51, [0 5], [-0.1 0.5]);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end-1,:); H(end,:) = [];
l = H>0;
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
im = imagesc(xbins,ybins,H./max(max(H)));
set(im,'AlphaData',l);
set(gca,'YDir','normal');
axis('tight');
xlabel('Lifetime GG [ns]');
ylabel('Anisotropy GG');
title('Anisotropy GG vs. Lifetime GG');
%% Plot rRR vs. tauRR in third plot
cla(h.axes_rRRvsTauRR);
axes(h.axes_rRRvsTauRR);
legend('off');

[H, xbins_hist, ybins_hist] = hist2d([datatoplot(:,idx_tauRR), datatoplot(:,idx_rRR)],51, 51, [0 6], [-0.1 0.5]);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end-1,:); H(end,:) = [];
l = H>0;
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
im = imagesc(xbins,ybins,H./max(max(H)));
set(im,'AlphaData',l);
set(gca,'YDir','normal');
axis('tight');
xlabel('Lifetime RR [ns]');
ylabel('Anisotropy RR');
title('Anisotropy RR vs. Lifetime RR');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Fits/theoretical Curves in Lifetime Tab %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimeFits(obj,~)
global BurstData UserValues
if ~isempty(obj)
    h = guidata(obj);
else
    h = guidata(gcf);
end
%%% Use the current cut Data (of the selected species) for plots
datatoplot = BurstData.DataCut;
%%% read out the indices of the parameters to plot
idx_tauGG = strcmp('Lifetime GG [ns]',BurstData.NameArray);
idx_tauRR = strcmp('Lifetime RR [ns]',BurstData.NameArray);
idx_rGG = strcmp('Anisotropy GG',BurstData.NameArray);
idx_rRR = strcmp('Anisotropy RR',BurstData.NameArray);
idxE = strcmp('Efficiency',BurstData.NameArray);
%% Add Fits
if obj == h.PlotStaticFRETButton
    %% Add a static FRET line EvsTau plots
    haxes = h.axes_EvsTauGG;
    axes(haxes);
    %%% Calculate static FRET line in presence of linker fluctuations
    tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
    staticFRETline = conversion_tau(UserValues.BurstBrowser.Corrections.DonorLifetime,...
        UserValues.BurstBrowser.Corrections.FoersterRadius,UserValues.BurstBrowser.Corrections.LinkerLength,...
        tau);
    %%% find previous line plot if it exists
    PreviousFit = findobj(h.axes_EvsTauGG.Children,'Type','Line');
    if ~isempty(PreviousFit)
        delete(PreviousFit);
    end
    hold on;
    plot_staticFRETline = plot(tau,staticFRETline);
    legend('off');
    plot_staticFRETline.Color = [0 0 1];
    plot_staticFRETline.LineWidth = 3;
end
if obj == h.FitAnisotropyButton
    %% Add Perrin Fits to Anisotropy Plot
    %%% GG
    %%% find previous line plot if it exists
    PreviousFit = findobj(h.axes_rGGvsTauGG.Children,'Type','Line');
    if ~isempty(PreviousFit)
        delete(PreviousFit);
    end
    r0 = 0.4;
    fPerrin = @(rho,x) r0./(1+x./rho); %%% x = tau
    PerrinFitGG = fit(datatoplot(:,idx_tauGG),datatoplot(:,idx_rGG),fPerrin,'StartPoint',1);
    axes(h.axes_rGGvsTauGG);
    hold on;
    plotPerrinGG = plot(PerrinFitGG);
    legend('off');
    plotPerrinGG.Color = [0 0 1];
    plotPerrinGG.LineWidth = 3;
    BurstData.Parameters.rhoGG = coeffvalues(PerrinFitGG);
    xlabel('Lifetime GG [ns]');
    ylabel('Anisotropy GG');
    title(['rhoGG = ' num2str(BurstData.Parameters.rhoGG) ' ns']);
    %% RR
    %%% find previous line plot if it exists
    PreviousFit = findobj(h.axes_rRRvsTauRR.Children,'Type','Line');
    if ~isempty(PreviousFit)
        delete(PreviousFit);
    end
    r0 = 0.4;
    fPerrin = @(rho,x) r0./(1+x./rho); %%% x = tau
    PerrinFitRR = fit(datatoplot(:,idx_tauRR),datatoplot(:,idx_rRR),fPerrin,'StartPoint',1);
    axes(h.axes_rRRvsTauRR);
    hold on;
    plotPerrinRR = plot(PerrinFitRR);
    legend('off');
    plotPerrinRR.Color = [0 0 1];
    plotPerrinRR.LineWidth = 3;
    BurstData.Parameters.rhoRR = coeffvalues(PerrinFitRR);
    xlabel('Lifetime RR [ns]');
    ylabel('Anisotropy RR');
    title(['rhoRR = ' num2str(BurstData.Parameters.rhoRR) ' ns']);
end
%% Manual Perrin plots
if obj == h.ManualAnisotropyButton
    [x,y,button] = ginput(1);
    if button == 1 %%% left mouse click, reset plot and plot one perrin line
        if (gca == h.axes_rGGvsTauGG) || (gca == h.axes_rRRvsTauRR)
            haxes = gca;
            legend('off');
            %%% find previous line plot if it exists
            PreviousFit = findobj(haxes.Children,'Type','Line');
            if ~isempty(PreviousFit)
                delete(PreviousFit);
            end
            %%% Determine rho
            r0 = 0.4;
            rho = x/(r0/y - 1);
            fitPerrin = @(x) r0./(1+x./rho);
            %%% plot
            hold on;
            tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
            plotPerrin = plot(tau,fitPerrin(tau));
            plotPerrin.Color = [0 0 1];
            plotPerrin.LineWidth = 3;
            switch haxes
                case h.axes_rGGvsTauGG
                    title(['rhoGG = ' num2str(rho)]);
                case h.axes_rRRvsTauRR
                    title(['rhoRR = ' num2str(rho)]);
            end
        end
    elseif button == 3 %%% right mouse click, add plot if a Perrin plot already exists
        if (gca == h.axes_rGGvsTauGG) || (gca == h.axes_rRRvsTauRR)
            haxes = gca;
            legend('off');
            %%% find previous line plot if it exists
            PreviousFit = findobj(haxes.Children,'Type','Line');
            if isempty(PreviousFit) %%% no plot exists, just add a plot as is the case for left click
                %%% Determine rho
                r0 = 0.4;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                %%% plot
                hold on;
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                plotPerrin = plot(tau,fitPerrin(tau));
                plotPerrin.Color = [0 0 1];
                plotPerrin.LineWidth = 3;
                switch haxes
                    case h.axes_rGGvsTauGG
                        title(['rhoGG = ' num2str(rho) ' ns']);
                    case h.axes_rRRvsTauRR
                        title(['rhoRR = ' num2str(rho) ' ns']);
                end
            elseif ~isempty(PreviousFit)
                %%% Determine second rho
                r0 = 0.4;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                %%% plot
                hold on;
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                plotPerrin = plot(tau,fitPerrin(tau));
                if numel(PreviousFit) == 1
                    plotPerrin.Color = [0 1 0];
                elseif numel(PerrinFit) == 2
                    plotPerrin.Color = [1 1 0];
                else
                    plotPerrin.Color = [1 1 1];
                end
                plotPerrin.LineWidth = 3;
                %%% add rho2 to title
                new_title = [haxes.Title.String ' and ' num2str(rho) ' ns'];
                title(new_title);
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on Tab-Change in Main Window and updates Plots %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MainTabSelectionChange(obj,e)
h = guidata(obj);
if e.NewValue == h.Main_Tab_Lifetime
    if isempty(h.axes_EvsTauGG.Children)
        %%% Update Lifetime Plots
        UpdateLifetimePlots(obj,[]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Reads out the Donor only lifetime from Donor only bursts %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DonorOnlyLifetimeCallback(obj,~)
global BurstData UserValues
h = guidata(obj);
if obj.Value == 1 %%% Checkbox was clicked on
    %%% Determine Donor Only lifetime from data with S > 0.98
    idx_tauGG = strcmp(BurstData.NameArray,'Lifetime GG [ns]');
    idxS = strcmp(BurstData.NameArray,'Stoichiometry');
    valid = (BurstData.DataArray(:,idxS) > 0.98);
    DonorOnlyLifetime = mean(BurstData.DataArray(valid,idx_tauGG));
    %%% Update GUI
    h.DonorLifetimeEdit.String = num2str(DonorOnlyLifetime);
    h.DonorLifetimeEdit.Enable = 'off';
    UserValues.BurstBrowser.Corrections.DonorLifetime = DonorOnlyLifetime;
    LSUserValues(1);
else
    h.DonorLifetimeEdit.Enable = 'on';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates static FRET line with Linker Dynamics %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, coefficients] = conversion_tau(tauD,R0,s,xval)
% s = 6;
res = 1000;
%range of RDA center values, i.e. 100 values in 0.1*R0 to 10*R0
R = linspace(0*R0,5*R0,res);

%for every R calculate gaussian distribution
p = zeros(numel(R),res);
r = zeros(numel(R),res);
for j = 1:numel(R)
    x = linspace(R(j)-4*s,R(j)+4*s,res);
    dummy = exp(-((x-R(j)).^2)./(2*s^2));
    dummy(x < 0) = 0;
    dummy = dummy./sum(dummy);
    p(j,:) = dummy;
    r(j,:) = x;
end

%calculate lifetime distribution
tau = zeros(numel(R),res);
for j = 1:numel(R)
    tau(j,:) = tauD./(1+((R0./r(j,:)).^6));
end

%calculate species weighted taux
taux = zeros(1,numel(R));
for j = 1:numel(R)
taux(j) = sum(p(j,:).*tau(j,:));
end

%calculate intensity weighted tauf
tauf = zeros(1,numel(R));
for j = 1:numel(R)
tauf(j) = sum(p(j,:).*(tau(j,:).^2))./taux(j);
end

coefficients = polyfit(tauf,taux,3);

out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates the Gamma Factor using the lifetime information %%%%%%%%
%%%%%%% by minimizing the deviation from the static FRET line      %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DetermineGammaLifetime(obj,~)
global BurstData UserValues
h = guidata(obj);

%%% Prepare photon counts
%%% Change focus to CorrectionsTab
h.Main_Tab.SelectedTab = h.Main_Tab_Corrections;

indS = (strcmp(BurstData.NameArray,'Stoichiometry'));
indDur = (strcmp(BurstData.NameArray,'Duration [ms]'));
indNGG = (strcmp(BurstData.NameArray,'Number of Photons (GG)'));
indNGR = (strcmp(BurstData.NameArray,'Number of Photons (GR)'));
indNRR = (strcmp(BurstData.NameArray,'Number of Photons (RR)'));
indTauGG = (strcmp(BurstData.NameArray,'Lifetime GG [ns]'));
T_threshold = str2double(h.T_Threshold_Edit.String);
if isnan(T_threshold)
    T_threshold = 0.1;
end
cutT = 1;
if cutT == 0
    data_for_corrections = BurstData.DataArray;
elseif cutT == 1
    T = strcmp(BurstData.NameArray,'|TGX-TRR| Filter');
    valid = (BurstData.DataArray(:,T) < T_threshold);
    data_for_corrections = BurstData.DataArray(valid,:);
end

%%% Read out corrections
Background_GR = UserValues.BurstBrowser.Corrections.Background_GRpar + UserValues.BurstBrowser.Corrections.Background_GRperp;
Background_GG = UserValues.BurstBrowser.Corrections.Background_GGpar + UserValues.BurstBrowser.Corrections.Background_GGperp;
Background_RR = UserValues.BurstBrowser.Corrections.Background_RRpar + UserValues.BurstBrowser.Corrections.Background_RRperp;

%%% get E-S values between 0.3 and 0.8;
S_threshold = ( (data_for_corrections(:,indS) > 0.3) & (data_for_corrections(:,indS) < 0.9) );
%%% Calculate "raw" E and S with gamma = 1, but still apply direct
%%% excitation,crosstalk, and background corrections!
NGR = data_for_corrections(S_threshold,indNGR) - Background_GR.*data_for_corrections(S_threshold,indDur);
NGG = data_for_corrections(S_threshold,indNGG) - Background_GG.*data_for_corrections(S_threshold,indDur);
NRR = data_for_corrections(S_threshold,indNRR) - Background_RR.*data_for_corrections(S_threshold,indDur);
NGR = NGR - UserValues.BurstBrowser.Corrections.DirectExcitation_GR.*NRR - UserValues.BurstBrowser.Corrections.CrossTalk_GR.*NGG;

%%% Calculate static FRET line in presence of linker fluctuations
tau = linspace(0,5,100);
[~, coeff] = conversion_tau(UserValues.BurstBrowser.Corrections.DonorLifetime,...
    UserValues.BurstBrowser.Corrections.FoersterRadius,UserValues.BurstBrowser.Corrections.LinkerLength,...
    tau);
staticFRETline = @(x) 1 - (coeff(1).*x.^3 + coeff(2).*x.^2 + coeff(3).*x + coeff(4))./UserValues.BurstBrowser.Corrections.DonorLifetime;
%%% minimize deviation from static FRET line as a function of gamma
dev = @(gamma) sum( ( ( NGR./(gamma.*NGG+NGR) ) - staticFRETline(data_for_corrections(S_threshold,indTauGG) ) ).^2 );
gamma_fit = fmincon(dev,1,[],[],[],[],0,10);
E =  NGR./(gamma_fit.*NGG+NGR);
%%% plot E versus tau with static FRET line
cla(h.axes_gamma_lifetime);
axes(h.axes_gamma_lifetime);
BurstData.Plots.GammaPlot = plot2dhist(data_for_corrections(S_threshold,indTauGG),E,[0 5],[-0.1 1]);

%%% add static FRET line
tau = linspace(h.axes_gamma_lifetime.XLim(1),h.axes_gamma_lifetime.XLim(2),100);
hold on;
staticFRETplot = plot(tau,staticFRETline(tau));
legend('off');
staticFRETplot.Color = [0 0 1];
staticFRETplot.LineWidth = 3;
%%% Update Axis Labels
xlabel('Lifetime GG [ns]');
ylabel('Efficiency');
title('Efficiency vs. Lifetime GG');
ylim([0 1]);
%%% Update UserValues
UserValues.BurstBrowser.Corrections.Gamma_GR =gamma_fit;
%%% Save UserValues
LSUserValues(1);
%%% Update Correction Table Data
UpdateCorrections([],[]);
%%% Apply Corrections
ApplyCorrections;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General Functions for plotting 2d-Histogram of data %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [plot_handle] = plot2dhist(x,y,limx,limy,nbins,haxes)
global UserValues
if nargin <2
    return;
end
%%% if no limits are specified, set limits to min-max
if nargin < 3
    limx = [min(x) max(x)];
    limy = [min(y) max(y)];
end

%%% if number of bins is not specified, read from UserValues struct
if nargin < 5
    nbins = UserValues.BurstBrowser.Display.NumberOfBins;
end
%%% set axes
if nargin == 6
    axes(haxes);
end

[H, xbins_hist, ybins_hist] = hist2d([x y], nbins, nbins, limx, limy);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end-1,:); H(end,:) = [];
l = H>0;
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
%%% determine the plot type
switch UserValues.BurstBrowser.Display.PlotType
    case 'Image' %%%image plot
        plot_handle = imagesc(xbins,ybins,H./max(max(H)));
        set(plot_handle,'AlphaData',l);
        set(gca,'YDir','normal');
    case 'Contour' %%%contour plot
        zc=linspace(1, ceil(max(max(H))),10);
        set(gca,'CLim',[0 ceil(2*max(max(H)))]);
        H(H==0) = NaN;
        [~, plot_handle]=contourf(xbins,ybins,H,[0 zc]);
        set(plot_handle,'EdgeColor','none');
end
axis('tight');
function [Hout, Xbins, Ybins] = hist2d(D, varargin) %Xn, Yn, Xrange, Yrange)
%HIST2D 2D histogram
%
% [H XBINS YBINS] = HIST2D(D, XN, YN, [XLO XHI], [YLO YHI])
% [H XBINS YBINS] = HIST2D(D, 'display' ...)
%
% HIST2D calculates a 2-dimensional histogram and returns the histogram
% array and (optionally) the bins used to calculate the histogram.
%
% Inputs:
%     D:         N x 2 real array containing N data points or N x 1 array 
%                 of N complex values 
%     XN:        number of bins in the x dimension (defaults to 200)
%     YN:        number of bins in the y dimension (defaults to 200)
%     [XLO XHI]: range for the bins in the x dimension (defaults to the 
%                 minimum and maximum of the data points)
%     [YLO YHI]: range for the bins in the y dimension (defaults to the 
%                 minimum and maximum of the data points)
%     'display': displays the 2D histogram as a surf plot in the current
%                 axes
%
% Outputs:
%     H:         2D histogram array (rows represent X, columns represent Y)
%     XBINS:     the X bin edges (see below)
%     YBINS:     the Y bin edges (see below)
%       
% As with histc, h(i,j) is the number of data points (dx,dy) where 
% x(i) <= dx < x(i+1) and y(j) <= dx < y(j+1). The last x bin counts 
% values where dx exactly equals the last x bin value, and the last y bin 
% counts values where dy exactly equals the last y bin value.
%
% If D is a complex array, HIST2D splits the complex numbers into real (x) 
% and imaginary (y) components.
%
% Created by Amanda Ng on 5 December 2008

% Modification history
%   25 March 2009 - fixed error when min and max of ranges are equal.
%   22 November 2009 - added display option; modified code to handle 1 bin

    % PROCESS INPUT D
    if nargin < 1 %check D is specified
        error 'Input D not specified'
    end
    
    Dcomplex = false;
    if ~isreal(D) %if D is complex ...
        if isvector(D) %if D is a vector, split into real and imaginary
            D=[real(D(:)) imag(D(:))];
        else %throw error
            error 'D must be either a complex vector or nx2 real array'
        end
        Dcomplex = true;
    end

    if (size(D,1)<size(D,2) && size(D,1)>1)
        D=D';
    end
    
    if size(D,2)~=2;
        error('The input data matrix must have 2 rows or 2 columns');
    end
    
    % PROCESS OTHER INPUTS
    var = varargin;

    % check if DISPLAY is specified
    index = find(strcmpi(var,'display'));
    if ~isempty(index)
        display = true;
        var(index) = [];
    else
        display = false;
    end

    % process number of bins    
    Xn = 200; %default
    Xndefault = true;
    if numel(var)>=1 && ~isempty(var{1}) % Xn is specified
        if ~isscalar(var{1})
            error 'Xn must be scalar'
        elseif var{1}<1 || mod(var{1},1)
            error 'Xn must be an integer greater than or equal to 1'
        else
            Xn = var{1};
            Xndefault = false;
        end
    end

    Yn = 200; %default
    Yndefault = true;
    if numel(var)>=2 && ~isempty(var{2}) % Yn is specified
        if ~isscalar(var{2})
            error 'Yn must be scalar'
        elseif var{2}<1 || mod(var{2},1)
            error 'Xn must be an integer greater than or equal to 1'
        else
            Yn = var{2};
            Yndefault = false;
        end
    end
    
    % process ranges
    if numel(var) < 3 || isempty(var{3}) %if XRange not specified
        Xrange=[min(D(:,1)),max(D(:,1))]; %default
    else
        if nnz(size(var{3})==[1 2]) ~= 2 %check is 1x2 array
            error 'XRange must be 1x2 array'
        end
        Xrange = var{3};
    end
    if Xrange(1)==Xrange(2) %handle case where XLO==XHI
        if Xndefault
            Xn = 1;
        else
            Xrange(1) = Xrange(1) - floor(Xn/2);
            Xrange(2) = Xrange(2) + floor((Xn-1)/2);
        end
    end
    
    if numel(var) < 4 || isempty(var{4}) %if XRange not specified
        Yrange=[min(D(:,2)),max(D(:,2))]; %default
    else
        if nnz(size(var{4})==[1 2]) ~= 2 %check is 1x2 array
            error 'YRange must be 1x2 array'
        end
        Yrange = var{4};
    end
    if Yrange(1)==Yrange(2) %handle case where YLO==YHI
        if Yndefault
            Yn = 1;
        else
            Yrange(1) = Yrange(1) - floor(Yn/2);
            Yrange(2) = Yrange(2) + floor((Yn-1)/2);
        end
    end
        
    % SET UP BINS
    Xlo = Xrange(1) ; Xhi = Xrange(2) ;
    Ylo = Yrange(1) ; Yhi = Yrange(2) ;
    if Xn == 1
        XnIs1 = true;
        Xbins = [Xlo Inf];
        Xn = 2;
    else
        XnIs1 = false;
        Xbins = linspace(Xlo,Xhi,Xn) ;
    end
    if Yn == 1
        YnIs1 = true;
        Ybins = [Ylo Inf];
        Yn = 2;
    else
        YnIs1 = false;
        Ybins = linspace(Ylo,Yhi,Yn) ;
    end
    
    Z = linspace(1, Xn+(1-1/(Yn+1)), Xn*Yn);
    
    % split data
    Dx = floor((D(:,1)-Xlo)/(Xhi-Xlo)*(Xn-1))+1;
    Dy = floor((D(:,2)-Ylo)/(Yhi-Ylo)*(Yn-1))+1;
    Dz = Dx + Dy/(Yn) ;
    
    % calculate histogram
    h = reshape(histc(Dz, Z), Yn, Xn);
    
    if nargout >=1
        Hout = h;
    end
    
    if XnIs1
        Xn = 1;
        Xbins = Xbins(1);
        h = sum(h,1);
    end
    if YnIs1
        Yn = 1;
        Ybins = Ybins(1);
        h = sum(h,2);
    end
    
    % DISPLAY IF REQUESTED
    if ~display
        return
    end
        
    [x y] = meshgrid(Xbins,Ybins);
    dispH = h;

    % handle cases when Xn or Yn
    if Xn==1
        dispH = padarray(dispH,[1 0], 'pre');
        x = [x x];
        y = [y y];
    end
    if Yn==1
        dispH = padarray(dispH, [0 1], 'pre');
        x = [x;x];
        y = [y;y];
    end

    surf(x,y,dispH);
    colormap(jet);
    if Dcomplex
        xlabel real;
        ylabel imaginary;
    else
        xlabel x;
        ylabel y;
    end