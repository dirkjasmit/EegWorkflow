function varargout = figSaveModal(varargin)
% FIGSAVEMODAL MATLAB code for figSaveModal.fig
%      FIGSAVEMODAL, by itself, creates a new FIGSAVEMODAL or raises the existing
%      singleton*.
%
%      H = FIGSAVEMODAL returns the handle to a new FIGSAVEMODAL or the handle to
%      the existing singleton*.
%
%      FIGSAVEMODAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGSAVEMODAL.M with the given input arguments.
%
%      FIGSAVEMODAL('Property','Value',...) creates a new FIGSAVEMODAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before figSaveModal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to figSaveModal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figSaveModal

% Last Modified by GUIDE v2.5 22-Dec-2016 11:05:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figSaveModal_OpeningFcn, ...
                   'gui_OutputFcn',  @figSaveModal_OutputFcn, ...
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


% --- Executes just before figSaveModal is made visible.
function figSaveModal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figSaveModal (see VARARGIN)

% Choose default command line output for figSaveModal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes figSaveModal wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if length(varargin)<1
    error('Must pass an EEG struct to be saved.')
end
if length(varargin)>2
    error('Too many parameters passed')
end

data = guidata(hObject);
data.EEG = varargin{1};
if length(varargin)==2
    data.editSubject.String = varargin{2};
end

guidata(hObject, data);


% --- Outputs from this function are returned to the command line.
function varargout = figSaveModal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenuTask.
function popupmenuTask_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTask contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTask

% pass the call
editSubject_Callback(hObject,eventdata,guidata(hObject));


% --- Executes during object creation, after setting all properties.
function popupmenuTask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSubject_Callback(hObject, eventdata, handles)
% hObject    handle to editSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSubject as text
%        str2double(get(hObject,'String')) returns contents of editSubject as a double

data = guidata(hObject);

% format is 
%   <project>_<session>_<task>_<subject>_<round>
%  - if any is left empty (<none>) then it will be dropped from the list
%  - session is meant for longitudinal measurements, i.e. identical
%    measurements on different dates.
%  - round is meant for identical measurements on the same date.

list = {};

val = data.popupmenuProject.Value;
tmp = data.popupmenuProject.String{val};
if val~=1 && ~isempty(tmp)
    list = [list {tmp}];
end

val = data.popupmenuSession.Value;
tmp = data.popupmenuSession.String{val};
if val~=1 && ~isempty(tmp)
    list = [list {tmp}];
end

% extract the code from the popupmenu string between () 
val = data.popupmenuTask.Value;
tmp = data.popupmenuTask.String{val};
if val~=1 && ~isempty(tmp)
    list = [list {tmp(strfind(tmp,'(')+1:strfind(tmp,')')-1)}];
end

list = [list {data.editSubject.String}];

val = data.popupmenuRound.Value;
tmp = data.popupmenuRound.String{val};
if val~=1 && ~isempty(tmp)
    list = [list {tmp}];
end

% set mask subject format string, save it into the static text
mask = ['%s' repmat('_%s',1,length(list)-1)];
data.FN = sprintf([mask '.set'],list{:});
data.textFilename.String = data.FN;

guidata(hObject, data);

% --- Executes during object creation, after setting all properties.
function editSubject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in popupmenuProject.
function popupmenuProject_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuProject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuProject

% pass the call
editSubject_Callback(hObject,eventdata,guidata(hObject));

% --- Executes during object creation, after setting all properties.
function popupmenuProject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuRound.
function popupmenuRound_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuRound contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuRound

% pass the call
editSubject_Callback(hObject,eventdata,guidata(hObject));


% --- Executes during object creation, after setting all properties.
function popupmenuRound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if isempty(data.editSubject.String) || data.popupmenuProject.Value==1 ||  isempty(data.popupmenuProject.String)
    error('Subject and Project cannot be empty!')
end

pop_saveset(data.EEG,'filename',data.FN,'savemode','onefile');
close(gcf);


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf);

% --- Executes on selection change in popupmenuSession.
function popupmenuSession_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSession contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSession

% pass the call
editSubject_Callback(hObject,eventdata,guidata(hObject));


% --- Executes during object creation, after setting all properties.
function popupmenuSession_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
