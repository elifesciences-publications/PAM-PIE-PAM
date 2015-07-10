function LookSetup(~,~)
global UserValues
h.Look=findobj('Tag','Look');
if ~isempty(h.Look) %%% Gives focus to Look figure if it already exists
    figure(h.Look); return;
end  
%%% Loads user profile    
LSUserValues(0);
%%% Disables negative values for log plot warning
warning('off','MATLAB:Axes:NegativeDataInLogAxis');
%%% To save typing
Look = UserValues.Look;
%% Generates the Look figure
h.Look = figure(...
    'Units','normalized',...
    'Tag','Look',...
    'Name','Pam Look Setup',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName','Times',...
    'defaultAxesFontName','Times',...
    'defaultTextFontName','Times',...
    'UserData',[],...
    'OuterPosition',[0.11 0.2 0.8 0.7],...
    'CloseRequestFcn',@Close_Look,...
    'Visible','on');

%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes Pam background; must be called after whitebg
h.Look.Color=Look.Back;

h.Look_Panel = uibuttongroup(...
    'Parent',h.Look,...
    'Tag','Progress_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.01 0.01 0.98 0.98]);

%% Axes for 2D plots
h.Look_Axes2D = axes(...
    'Parent',h.Look_Panel,...
    'Tag','Progress_Axes',...
    'Units','normalized',...
    'Color',Look.Axes,...
    'Position',[0.05 0.35 0.35 0.6],...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'XLim',[0 1000],...
    'YLim', [0 1.05]);
plot(h.Look_Axes2D, 1:1000, exp(-((1:1000)-300).^2./10000),'LineWidth',2,'Color','y');
plot(h.Look_Axes2D, 1:1000, exp(-((1:1000)-500).^2./5000),'LineWidth',2,'Color','c');
plot(h.Look_Axes2D, 1:1000, exp(-((1:1000)-700).^2./15000),'LineWidth',2,'Color','b');
h.Look_Axes2D.XLabel.String = 'X Axis Label';
h.Look_Axes2D.XLabel.Color = Look.Fore;
h.Look_Axes2D.YLabel.String = 'Y Axis Label';
h.Look_Axes2D.YLabel.Color = Look.Fore;
grid minor

%% Axes for 3D plots
h.Look_Axes3D = axes(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'ZColor',Look.Fore,...
    'NextPlot','add',...
    'View',[145,25],...
    'ZLim', [-0.05 1.05],...
    'Position',[0.5 0.35 0.48 0.6]);  
colormap(jet);
h.Look_Colorbar = colorbar;
h.Look_Colorbar.YColor = Look.Fore;
h.Look_Colorbar.Label.String = 'Colorbar';
h.Look_Colorbar.Label.Color = Look.Fore;

[X,Y] = meshgrid(1:20,(1:20)');
h.Plots.Main=surf(exp(-((X-10).^2+(Y-10).^2)./10),...
    'Parent',h.Look_Axes3D,...
    'FaceColor','Flat');
h.Look_Axes3D.XLabel.String = 'X Axis Label';
h.Look_Axes3D.XLabel.Color = Look.Fore;
h.Look_Axes3D.YLabel.String = 'Y Axis Label';
h.Look_Axes3D.YLabel.Color = Look.Fore;
h.Look_Axes3D.ZLabel.String = 'Z Axis Label';
h.Look_Axes3D.ZLabel.Color = Look.Fore;
grid minor

%% Foreground example
h.Look_Foreground = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.02 0.22 0.48 0.03],...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Tag','Look_Foreground',...
    'HorizontalAlignment','Left',...
    'FontSize',12,...
    'Style', 'Check',...
    'Callback',{@Change_Look,1},...
    'String','Change Foreground Color');
%% Control example
h.Look_Control = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.02 0.16 0.2 0.05],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Tag','Look_Checkbox',...
    'HorizontalAlignment','Left',...
    'FontSize',12,...
    'Style', 'Push',...
    'Callback',{@Change_Look,2},...
    'String','Change Control Color');
%% Disabled example
h.Look_Disabled = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.02 0.1 0.2 0.05],...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Disabled,...
    'Tag','Look_Checkbox',...
    'HorizontalAlignment','Left',...
    'FontSize',12,...
    'Style', 'Push',...
    'Callback',{@Change_Look,4},...
    'String','Change Disabled Color');
%% Background example
h.Look_Background = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.02 0.04 0.2 0.05],...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Disabled,...
    'Tag','Look_Checkbox',...
    'HorizontalAlignment','Left',...
    'FontSize',12,...
    'Style', 'Push',...
    'Callback',{@Change_Look,3},...
    'String','Change Background Color');
%% Axes example
h.Look_Axes = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.23 0.16 0.15 0.05],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Tag','Look_Popup',...
    'HorizontalAlignment','Center',...
    'FontSize',12,...
    'Style', 'Edit',...
    'Enable','inactive',...
    'ButtonDownFcn',{@Change_Look,6},...
    'String','Change axes color');
%% Popup Example
h.Look_Popup = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.23 0.1 0.15 0.045],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Tag','Look_Popup',...
    'HorizontalAlignment','Center',...
    'FontSize',12,...
    'Style', 'Popup',...
    'String','Popup example');
%% Shadow example
h.Look_Shadow = uicontrol(...
    'Parent',h.Look_Panel,...
    'Units','normalized',...
    'Position',[0.23 0.04 0.15 0.05],...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Tag','Look_Checkbox',...
    'HorizontalAlignment','Left',...
    'FontSize',12,...
    'Style', 'Push',...
    'Callback',{@Change_Look,5},...
    'String','Change Shadow');
%% Saves handles
guidata(h.Look,h);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that executes upon closing of Look window %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_Look(Obj,~)
Phasor=findobj('Tag','Phasor');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
TauFit=findobj('Tag','TauFit');
PhasorTIFF = findobj('Tag','PhasorTIFF');
Pam = findobj('Tag','Pam');
if isempty(Phasor) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) &&...
   isempty(Mia) && isempty(Sim) && isempty(BurstBrowser) && isempty(TauFit) &&...
   isempty(PhasorTIFF) && isempty(Pam)
    clear global -regexp UserValues
end
delete(Obj);


function Change_Look(~,~,mode)
global UserValues
h = guidata(findobj('Tag','Look'));

Color = uisetcolor;
if numel(Color)~=3
    return;
end

LSUserValues(0);
switch mode
    case 1 %%% Foreground
        h.Look_Foreground.ForegroundColor = Color;
        h.Look_Control.ForegroundColor = Color;
        h.Look_Axes.ForegroundColor = Color;
        h.Look_Popup.ForegroundColor = Color;
        h.Look_Shadow.ForegroundColor = Color;
        h.Look_Axes2D.XColor = Color;
        h.Look_Axes2D.YColor = Color;
        h.Look_Axes2D.XLabel.Color = Color;
        h.Look_Axes2D.YLabel.Color = Color;
        h.Look_Axes3D.XColor = Color;
        h.Look_Axes3D.YColor = Color;
        h.Look_Axes3D.ZColor = Color;
        h.Look_Axes3D.XLabel.Color = Color;
        h.Look_Axes3D.YLabel.Color = Color;
        h.Look_Axes3D.ZLabel.Color = Color;
        h.Look_Colorbar.YColor = Color;
        UserValues.Look.Fore = Color;
    case 2 %%% Control
        h.Look_Control.BackgroundColor = Color;
        h.Look_Axes.BackgroundColor = Color;
        h.Look_Popup.BackgroundColor = Color;
        h.Look_Shadow.BackgroundColor = Color;
        h.Look_Panel.HighlightColor = Color;
        UserValues.Look.Control = Color;
    case 3 %%% Background
        h.Look.Color = Color;
        h.Look_Panel.BackgroundColor = Color;
        h.Look_Foreground.BackgroundColor = Color;
        h.Look_Disabled.BackgroundColor = Color;
        h.Look_Background.BackgroundColor = Color;
        UserValues.Look.Back = Color;
    case 4 %%% Disabled
        h.Look_Disabled.ForegroundColor = Color;
        h.Look_Background.ForegroundColor = Color;
        UserValues.Look.Disabled = Color;
    case 5 %%% Shadow
        h.Look_Panel.ShadowColor = Color;
        UserValues.Look.Shadow = Color;
    case 6 %%% Axes
        h.Look_Axes2D.Color = Color;
        h.Look_Axes3D.Color = Color;
        UserValues.Look.Axes = Color;
end
LSUserValues(1);
