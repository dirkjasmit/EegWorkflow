gesfunction varargout = guiEpoch(varargin)
% GUIEPOCH MATLAB code for guiEpoch.fig
%      GUIEPOCH, by itself, creates a new GUIEPOCH or raises the existing
%      singleton*.
%
%      H = GUIEPOCH returns the handle to a new GUIEPOCH or the handle to
%      the existing singleton*.
%
%      GUIEPOCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIEPOCH.M with the given input arguments.
%
%      GUIEPOCH('Property','Value',...) creates a new GUIEPOCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiEpoch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiEpoch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiEpoch

% Last Modified by GUIDE v2.5 22-Dec-2016 11:56:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiEpoch_OpeningFcn, ...
                   'gui_OutputFcn',  @guiEpoch_OutputFcn, ...
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


% --- Executes just before guiEpoch is made visible.
function guiEpoch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiEpoch (see VARARGIN)

% Choose default command line output for guiEpoch
handles.output = hObject;

% check parameter passing
if isempty(varargin) || ~isfield(varargin{1},'event') || length(varargin)<2
    error('Must pass and EEG struct and parent window handle when opening this window.');
end
pause(0.05);
% save figure handle of window calling this window (2nd argument in call).
handles.Parent = varargin{2};
handles.EEG = varargin{1};
handles.checkboxSpecialPRT.Value = 0;

% Update handles structure
guidata(hObject, handles);

guiEpoch_FillCheckbox(hObject, handles);
pause(0.1)


function guiEpoch_FillCheckbox(hObject, handles)
% EEG struct passed in hObject as .EEG. Get event types and clear & fill
% the panel with checkboxes for each event type. Event types should have
% been trimmed by now (whitespace error in reading certain input files.)

% data = guidata(hObject); <<- not necessary, already in handles

evt = unique({handles.EEG.event.type});
if handles.checkboxSpecialPRT.Value
    evt = setdiff(evt,arrayfun(@(x)sprintf('%d',x),1:218,'uniform',false));
else
    evt = setdiff(evt,{'A','B','C','D'});
end
[~,idx] = sort(str2double(evt));
evt = evt(idx);

% clear the earlier checkboxes
for x=1:299
    h = findall(gcf, 'tag', sprintf('check_%d', x));
    if ~isempty(h)
        delete(h);
    end
end

nrow = 10;
ncol = ceil(length(evt)/nrow);
pos = get(gcf, 'position');
set(gcf, 'position', [pos(1:2) max(pos(3),ncol*60+60) pos(4)]);
pause(0.05);

for e=1:length(evt)
    pos = [10+floor((e-1)/nrow)*60 10+mod(e-1,nrow)*15 60 15];
    h = uicontrol(handles.uipanel,'Style','checkbox', 'Tag', sprintf('check_%d',e), 'String', evt{e}, 'Position',pos);
    set(h,'value',1);
    set(h,'tooltipstring', 'check to select as epoch event');
end

pause(0.1)


% --- Outputs from this function are returned to the command line.
function varargout = guiEpoch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on sliderPost movement.
function sliderPre_Callback(hObject, eventdata, handles)
% hObject    handle to sliderPre (see GCBO)
% eventdata  reserved - to be defined in a future version of
% MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of sliderPost
%        get(hObject,'Min') and get(hObject,'Max') to determine range of sliderPost

data = guidata(hObject);
set(hObject,'value',round(get(hObject,'value')./10)*10);
data.textPre.String = sprintf('%d',round(get(hObject,'value')));
guidata(hObject,data);

% --- Executes during object creation, after setting all properties.
function sliderPre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderPre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: sliderPost controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on sliderPost movement.
function sliderPost_Callback(hObject, eventdata, handles)
% hObject    handle to sliderPost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of sliderPost
%        get(hObject,'Min') and get(hObject,'Max') to determine range of sliderPost

data = guidata(hObject);
set(hObject,'value',round(get(hObject,'value')./10)*10);
data.textPost.String = sprintf('%d',round(get(hObject,'value')));
guidata(hObject,data);


% --- Executes during object creation, after setting all properties.
function sliderPost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderPost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: sliderPost controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf);

% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the main data and apply the epoching
data = guidata(hObject);
data_parent = guidata(data.Parent);

evtlist = {};
for x=1:699
    h = findall(gcf, 'tag', sprintf('check_%d',x));
    if ~isempty(h)
        if get(h,'value')
            evtlist = [evtlist {get(h,'string')}];
        end
    end
end

data.EEG = pop_epoch(data.EEG, evtlist, [data.sliderPre.Value./1000 data.sliderPost.Value./1000]);
data.EEG = pop_rmbase(data.EEG, [data.EEG.xmin*1000 0]);
data.EEG.eventlist = evtlist;

% store in local gui data
guidata(hObject, data);

% stroe in parent gui data. Push existing data onto stack. Update <data_parent.EEG> to tmp.
data_parent.Stack{length(data_parent.Stack)+1} = data_parent.EEG;
data_parent.StackLabel{length(data_parent.Stack)+1} = 'Epoch';
data_parent.EEG = data.EEG;
guidata(data.Parent, data_parent);

close(gcf);


% --- Executes on button press in pushbuttonCheckAll.
function pushbuttonCheckAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCheckAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbuttonCheckAll

setval = strcmpi(hObject.String,'Check all');
if setval
    set(hObject, 'string', 'Uncheck all');
else
    set(hObject, 'string', 'Check all');
end

% set values of the checkboxes.
for x=1:299
    h = findall(gcf, 'tag', sprintf('check_%d',x));
    set(h,'value', setval)
end
pause(0.5);


% --- Executes on button press in checkboxSpecialPRT.
function checkboxSpecialPRT_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSpecialPRT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxSpecialPRT

% data = guidata(hObject);

if get(hObject, 'value') && ~ismember('A',{handles.EEG.event.type})
    % only needs to be performed once upon checking
    for e=1:length(handles.EEG.event);
        if isnumeric(handles.EEG.event(e).type)
            val = handles.EEG.event(e).type;
        else
            val = str2double(handles.EEG.event(e).type);
        end
        if ~isnan(val)
            if val<=50
                ins = 'A';
            elseif val<=100
                ins = 'B';
            elseif val<=150
                ins = 'C';
            elseif val<=200
                ins = 'D';
            else
                ins='';
            end
            if ~isempty(ins)
                handles.EEG.event(end+1).latency = handles.EEG.event(e).latency; % copy latency
                handles.EEG.event(end).type = ins;
            end
        end
    end
    handles.EEG = eeg_checkset(handles.EEG, 'eventconsistency');
    
    guidata(hObject, handles);
end
        
guiEpoch_FillCheckbox(hObject, handles);
