function varargout = figMatchChannels(varargin)
% FIGMATCHCHANNELS MATLAB code for figMatchChannels.fig
%      FIGMATCHCHANNELS, by itself, creates a new FIGMATCHCHANNELS or raises the existing
%      singleton*.
%
%      H = FIGMATCHCHANNELS returns the handle to a new FIGMATCHCHANNELS or the handle to
%      the existing singleton*.
%
%      FIGMATCHCHANNELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGMATCHCHANNELS.M with the given input arguments.
%
%      FIGMATCHCHANNELS('Property','Value',...) creates a new FIGMATCHCHANNELS or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before figMatchChannels_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to figMatchChannels_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figMatchChannels

% Last Modified by GUIDE v2.5 28-Oct-2020 10:58:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figMatchChannels_OpeningFcn, ...
                   'gui_OutputFcn',  @figMatchChannels_OutputFcn, ...
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


% --- Executes just before figMatchChannels is made visible.
function figMatchChannels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figMatchChannels (see VARARGIN)

% Choose default command line output for figMatchChannels
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes figMatchChannels wait for user response (see UIRESUME)
% uiwait(handles.figMatchChannels);

if length(varargin)<1
    error('Must supply handle to parent!')
end

% Get data of this window and the parent window to store the data back
% into. Varargin{1} holds the parent window hanlde
data = guidata(hObject);
data.Parent = varargin{1};

data_parent = guidata(data.Parent);
pause(0.005);

if ~isfield(data_parent,'EEG') || isempty(data_parent.EEG.data)
    msgbox('No data available');
    beep();
    return
end

data.EEG = data_parent.EEG;

guidata(hObject, data);



% --- Outputs from this function are returned to the command line.
function varargout = figMatchChannels_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

ndx = FindSetNdx({data.MatchEEG.chanlocs.labels},{data.EEG.chanlocs.labels});
ndxback = FindSetNdx({data.EEG.chanlocs.labels},{data.MatchEEG.chanlocs.labels});
data.EEG.chanlocs(sort(ndxback)) = data.MatchEEG.chanlocs(ndx);

if data.checkboxNonmatching.Value==1.0
    data.EEG = pop_select(data.EEG, 'channel', ndx);
end

% guidata(data.Parent, data_parent);

close(gcf);

% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf)

% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.english)
    set(handles.text4, 'String', 'lb/cu.in');
    set(handles.text5, 'String', 'cu.in');
    set(handles.text6, 'String', 'lb');
else
    set(handles.text4, 'String', 'kg/cu.m');
    set(handles.text5, 'String', 'cu.m');
    set(handles.text6, 'String', 'kg');
end


function editFilepath_Callback(hObject, eventdata, handles)
% hObject    handle to editFilepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilepath as text
%        str2double(get(hObject,'String')) returns contents of editFilepath as a double


% --- Executes during object creation, after setting all properties.
function editFilepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSelect.
function pushbuttonSelect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);

[file, path] = uigetfile('*.set');
data.editFilepath.String = path;
data.MatchEEG = pop_loadset([path '/' file]);

data.textNMatch.String = sprintf('Matching channels: %d',sum(ismember({data_parent.EEG.chanlocs.labels},{data.MatchEEG.chanlocs.labels})));

guidata(hObject, data);

% --- Executes on button press in checkboxNonmatching.
function checkboxNonmatching_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxNonmatching (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxNonmatching


% --- Executes when user attempts to close figMatchChannels.
function figMatchChannels_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figMatchChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

delete(hObject);



function editFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFilename as text
%        str2double(get(hObject,'String')) returns contents of editFilename as a double


% --- Executes during object creation, after setting all properties.
function editFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
