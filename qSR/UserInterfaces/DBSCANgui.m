function varargout = DBSCANgui(varargin)
% DBSCANgui MATLAB code for DBSCANgui.fig
%      DBSCANgui, by itself, creates a new DBSCANgui or raises the existing
%      singleton*.
%
%      H = DBSCANgui returns the handle to a new DBSCANgui or the handle to
%      the existing singleton*.
%
%      DBSCANgui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DBSCANgui.M with the given input arguments.
%
%      DBSCANgui('Property','Value',...) creates a new DBSCANgui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DBSCANgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DBSCANgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DBSCANgui

% Last Modified by GUIDE v2.5 05-Jan-2018 17:55:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DBSCANgui_OpeningFcn, ...
                   'gui_OutputFcn',  @DBSCANgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DBSCANgui is made visible.
function DBSCANgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DBSCANgui (see VARARGIN)

handles.mainObject=varargin{1};

% Choose default command line output for DBSCANgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DBSCANgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = DBSCANgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SaveClusters.
function SaveClusters_Callback(hObject, eventdata, handles)
% hObject    handle to SaveClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if isfield(handles,'cluster_IDs')
%     mainHandles=guidata(handles.mainObject);
%     mainHandles.sp_clusters=handles.cluster_IDs;
%     mainHandles.raw_sp_clusters=handles.raw_sp_clusters;
%     mainHandles.valid_sp_clusters=true;
% 
%     mainHandles.sp_clust_algorithm = 'DBSCAN';
% 
%     lengthscale = str2num(get(handles.LengthScale,'String'));
%     nmin = str2num(get(handles.MinPoints,'String'));
%     mainHandles.dbscan_length=lengthscale;
%     mainHandles.dbscan_nmin=nmin;
% 
%     guidata(handles.mainObject,mainHandles)
%     
%     msgbox('Export complete!')
% else
%     msgbox('You must first run the analysis!')
% end

mainHandles=guidata(handles.mainObject);

if mainHandles.valid_sp_clusters
    statistics=EvaluateSpatialSummaryStatistics(mainHandles.fXpos,mainHandles.fYpos,mainHandles.sp_clusters);
    %display('This will break if I change filters after finding the clusters')
    [area_counts,area_bins]=hist([statistics(:).c_hull_area],20);
    [size_counts,size_bins]=hist([statistics(:).cluster_size],20);
    
    figure
    plot(area_bins,area_counts/sum(area_counts))
    xlabel('Cluster Area (nm^2)')
    ylabel('Frequency')
    title('Cluster Area Distribution')
    
    figure
    plot(size_bins,size_counts/sum(size_counts))
    xlabel('Number of Localizations per Cluster')
    ylabel('Frequency')
    title('Cluster Size Distribution')
    
    mainHandles.sp_statistics=statistics;
    guidata(handles.mainObject,mainHandles)
    
    if exist([mainHandles.directory,'qSR_Analysis_Output'],'dir')
    else
        mkdir([mainHandles.directory,'qSR_Analysis_Output'])
    end
    
    test_name = [mainHandles.directory,'qSR_Analysis_Output',filesep,'Spatial_Cluster_Statistics',filesep];
    n=1;
    while exist(test_name,'dir')
        n=n+1;
        test_name = [mainHandles.directory,'qSR_Analysis_Output',filesep,'Spatial_Cluster_Statistics',num2str(n),filesep];
    end
    mkdir(test_name);
    
    ExportClusterStatistics(mainHandles.sp_statistics,[test_name,'spatialstats.csv'])

    filter_status_filename = [test_name,'filter_status_for_spatialstats.txt'];
    SaveFilterStatus(handles.mainObject,mainHandles,filter_status_filename)

    fData_filename = [test_name,'filtered_data_for_spatial.csv'];
    csvwrite(fData_filename,[mainHandles.fFrames;mainHandles.fXpos;mainHandles.fYpos;mainHandles.fIntensity])

    cluster_param_file_path=[test_name,'spatial_clustering_parameters.txt'];
    SaveClusteringParameters(handles.mainObject,mainHandles,cluster_param_file_path)

    sp_cluster_filename = [test_name,'sp_clusters.csv'];
    csvwrite(sp_cluster_filename,mainHandles.sp_clusters);
    
    msgbox(['Data saved in ', test_name,' !'])
    
else
    msgbox('You must first select clusters!')
end

% --- Executes on button press in PlotGraph.
function PlotGraph_Callback(hObject, eventdata, handles)
% hObject    handle to PlotGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'cluster_IDs')
    mainHandles=guidata(handles.mainObject);
    data=[mainHandles.fXpos',mainHandles.fYpos'];
    ids=handles.cluster_IDs;
    plot_2d_clusters(data,ids)
else
    msgbox('You must first run the analysis!')
end

function LengthScale_Callback(hObject, eventdata, handles)
% hObject    handle to LengthScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LengthScale as text
%        str2double(get(hObject,'String')) returns contents of LengthScale as a double

length_scale = str2num(get(handles.LengthScale,'String'));
if isempty(length_scale)
    msgbox('Length scale must be a positive number!')
    set(handles.LengthScale,'String',100)
    guidata(hObject,handles)
elseif length_scale <=0
    msgbox('Length scale must be a positive number!')
    set(handles.LengthScale,'String',100)
    guidata(hObject,handles)
end

% --- Executes during object creation, after setting all properties.
function LengthScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LengthScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinPoints_Callback(hObject, eventdata, handles)
% hObject    handle to MinPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinPoints as text
%        str2double(get(hObject,'String')) returns contents of MinPoints as a double

min_pts = str2num(get(handles.MinPoints,'String'));
if isempty(min_pts)
    msgbox('Minimum Points must be a positive integer!')
    set(handles.MinPoints,'String',10)
    guidata(hObject,handles)
elseif min_pts <=0
    msgbox('Minimum Points must be a positive integer!')
    set(handles.MinPoints,'String',10)
    guidata(hObject,handles)
end

% --- Executes during object creation, after setting all properties.
function MinPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunAnalysis.
function RunAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to RunAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lengthscale = str2num(get(handles.LengthScale,'String'));
nmin = str2num(get(handles.MinPoints,'String'));
mainHandles=guidata(handles.mainObject);
data=[mainHandles.fXpos',mainHandles.fYpos']; %mainHandles.fFrames
%[handles.cluster_IDs,~] = DBSCAN(data,lengthscale,nmin);
include_numeric = get(handles.IncludeBorderPoints,'Value');
if include_numeric ==1
    include = 'include';
else
    include = 'exclude';
end

[handles.cluster_IDs] = DBSCAN_kdtree(data,nmin,lengthscale,include); % Edit GUI to allow user to toggle between including and exlcuding edge points.
guidata(hObject,handles)
handles.sp_clusters=handles.cluster_IDs;
handles=RawClustersFromFiltered(mainHandles,handles);
guidata(hObject,handles)


%%%%%%%%%%%%%%%%
mainHandles.sp_clusters=handles.cluster_IDs;
mainHandles.raw_sp_clusters=handles.raw_sp_clusters;
mainHandles.valid_sp_clusters=true;

mainHandles.sp_clust_algorithm = 'DBSCAN';

lengthscale = str2num(get(handles.LengthScale,'String'));
nmin = str2num(get(handles.MinPoints,'String'));
mainHandles.dbscan_length=lengthscale;
mainHandles.dbscan_nmin=nmin;

guidata(handles.mainObject,mainHandles)
%%%%%%%%%%%%%%%%%%%

if isfield(handles,'cluster_IDs')
    mainHandles=guidata(handles.mainObject);
    data=[mainHandles.fXpos',mainHandles.fYpos'];
    ids=handles.cluster_IDs;
    plot_2d_clusters(data,ids)
else
    msgbox('You must first run the analysis!')
end


% --- Executes on button press in IncludeBorderPoints.
function IncludeBorderPoints_Callback(hObject, eventdata, handles)
% hObject    handle to IncludeBorderPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IncludeBorderPoints
