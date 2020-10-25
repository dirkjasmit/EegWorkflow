function varargout = guiEegAutoflow(varargin)
% GUIEEGAUTOFLOW MATLAB code for guiEegAutoflow.fig
%      GUIEEGAUTOFLOW, by itself, creates a new GUIEEGAUTOFLOW or raises the existing
%      singleton*.
%
%      H = GUIEEGAUTOFLOW returns the handle to a new GUIEEGAUTOFLOW or the handle to
%      the existing singleton*.
%
%      GUIEEGAUTOFLOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIEEGAUTOFLOW.M with the given input arguments.
%
%      GUIEEGAUTOFLOW('Property','Value',...) creates a new GUIEEGAUTOFLOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiEegAutoflow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiEegAutoflow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiEegAutoflow

% Last Modified by GUIDE v2.5 24-Oct-2020 10:34:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @guiEegAutoflow_OpeningFcn, ...
    'gui_OutputFcn',  @guiEegAutoflow_OutputFcn, ...
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



% --- Executes just before guiEegAutoflow is made visible.
function guiEegAutoflow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiEegAutoflow (see VARARGIN)

% Choose default command line output for guiEegAutoflow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiEegAutoflow wait for user response (see UIRESUME)
% uiwait(handles.fig_eeg_workflow);

if ~exist('ALLEEG')
    eeglab;
end

data = guidata(hObject);

filename = '/Volumes/FiveTB/Documents/Onderzoeksmap/Misofonie_ArjenSchroder/EEG/EEG_misophonia_MMN/C004/C004.cnt';
try
    data.EEG = pop_loadeep_v4(filename);
catch
    pause(1);
end

guidata(hObject, data);

% The timerFcn is called after the window becomes visible.
%function timerFcn(obj,event,arg1)




% --- Outputs from this function are returned to the command line.
function varargout = guiEegAutoflow_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
pause(0.05);
% WinOnTop(hObject);



% --- Executes on button press in pb1.
function pb1_Callback(hObject, eventdata, handles)
% hObject    handle to pb1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on button press in pbOpen.
function pushbuttonOpen_Callback(hObject, eventdata, handles)
% hObject    handle to pbOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
hObject.BackgroundColor = [.3 .6 .3];

FilterSpec = {
    '*.cnt','ANT continuous w/ trig';
    '*.cnt','Neuroscan continuous';
    '*.set', 'EEGLAB continuous'  ;
    '*.eeg', 'EEGLAB epoched'     ;
    '*.bdf', 'Biosemi'            };
DefaultPath = '/Users/dirksmit/OneDrive/Transfer';
[FileName,PathName,FilterIndex] = uigetfile(FilterSpec,'Select an EEG file', DefaultPath);
%try
switch FilterIndex
    case 1
        data.EEG = pop_loadeep_v4([PathName FileName], 'triggerfile', 'on');
        data.EEG.filename = [PathName FileName];
        tmp = data.EEG;
        
        % insert boundaries and events
        evtcnt = 0;
        for ev=1:length(tmp.event)
            if tmp.event(ev).latency>1
                evtcnt = evtcnt + 1;
                if strcmp(tmp.event(ev).type,'__')
                    typ = 'boundary';
                else
                    typ = strtrim(tmp.event(ev).type);
                end
                tmp.event(evtcnt).type = typ;
                tmp.event(evtcnt).latency = data.EEG.event(ev).latency;
                tmp.event(evtcnt).duration = data.EEG.event(ev).duration;
            end
        end
        
        % check for event length (>10 events), start of first event named 31 (>100 sec), and
        % existence of a boundary event. If not, search for a "jump" in
        % activity just before the first event and put in a boundary
        % event (segment will not work otherwise.)
        if length(tmp.event)>10 && ~isempty(str2num(tmp.event(1).type)) ...
                && tmp.event(1).latency>100*tmp.srate ...
                && sum(strcmpi('boundary',{tmp.event.type}))==0
            sig = tmp.data(:,(tmp.event(1).latency-tmp.srate*4):tmp.event(1).latency);
            z = abs(zscore(mean(abs(diff(sig')')))');
            ndx = tmp.event(1).latency-tmp.srate*4 + min(find(z>10)) + 0;
            dummy = tmp.event(1);
            dummy.type = 'boundary';
            dummy.latency = ndx;
            dummy.duration = 0;
            tmp.event = cat(1,dummy,tmp.event(:));
        end
        
        data.EEG = tmp;
        
    case 2
        data.EEG = pop_loadcnt([PathName FileName]);
        data.EEG.filename = [PathName FileName];
    
    case 3
        data.EEG = pop_loadset([PathName FileName]);
        data.EEG.filename = [PathName FileName];
    
    case 4
        data.EEG = pop_loadeeg([PathName FileName]);
        data.EEG.filename = [PathName FileName];
    
    case 5
        data.EEG = pop_readbdf([PathName FileName], [] , [],1);
        data.EEG.filename = Filename;
        
end
%catch E
%    throw(E)
%end

data.EEG = eeg_checkset(data.EEG);
if isfield(data.EEG,'event')
    for ev=1:length(data.EEG.event)
        if ischar(data.EEG.event(ev).type)
            data.EEG.event(ev).type = data.EEG.event(ev).type(~ismember(data.EEG.event(ev).type,[0 9:13 32]));
        end
    end
end

list = fieldnames(data);
for l=1:length(list)
    if isfield(getfield(data,list{l}),'style')
        sty = get(getfield(data,list{l}),'style');
        if strcmpi(sty,'pushbutton')
            set(getfield(data,list{l}),'backgroundcolor',[1 .6 .6])
        end
        pause(0.005);
    end
end
data.pushbuttonFlatline.BackgroundColor = [.6 1 .6];
hObject.BackgroundColor = [1 .6 .6];

guidata(hObject,data)
listboxEegProperties_Update(hObject)




% --- Executes on selection change in listboxEegProperties.
function listboxEegProperties_Callback(hObject, eventdata, handles)
% hObject    handle to listboxEegProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxEegProperties contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxEegProperties




% --- Executes during object creation, after setting all properties.
function listboxEegProperties_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxEegProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in pushbuttonChanlocs.
function pushbuttonChanlocs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonChanlocs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
set(hObject, 'BackgroundColor', [.3 .6 .3]);
pause(0.005)

if ~isfield(data,'EEG')
    msgbox('No data available');
    data.pushbuttonChanlocs.BackgroundColor = [1 .6 .6];
    return
end

if data.checkboxAddCPz.Value && sum(strcmpi({data.EEG.chanlocs.labels},'CPz'))==0
    data.EEG.data(end+1,:) = 0;
    data.EEG.nbchan = data.EEG.nbchan+1;
    data.EEG.chanlocs(end+1).labels = 'CPz';
    data.EEG.icaweights = [];
    data.EEG.icawinv = [];
    data.EEG.icasphere = [];
end

if sum(strcmpi('pz',{data.EEG.chanlocs.labels})) || sum(strcmpi('fp1',{data.EEG.chanlocs.labels}))
    pause(.005);
else
    warning('Cannot find Pz and Fp1 channels. Assuming channel labels are not 10/10 nomenclature.\nOnly 10/10 is supported for now.')
end
data.EEG = pop_chanedit(data.EEG, 'lookup','standard-10-5-cap385.elp');

guidata(hObject,data)
listboxEegProperties_Update(hObject)

set(hObject, 'BackgroundColor', [.9 .8 .5]);
data.pushbuttonResample.BackgroundColor = [.6 1 .6];






% --- Executes on button press in pushbuttonFilter.
function pbFilter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data.pbFilter.BackgroundColor = [.3 .6 .3];
pause(0.005)

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pbFilter.BackgroundColor = [1 .6 .6];
    return
end


if data.radiobuttonFIR.Value
    data.EEG = filter_fir(data.EEG, data.EEG.srate, data.sliderLow.Value, data.sliderHigh.Value, 3.0, true, false, true);
    if data.chbxNotch.Value
        data.EEG = filter_fir(data.EEG, data.EEG.srate, 47, 53, 3.0, true, true);
    end
else
    data.EEG = filter_butter(data.EEG, data.EEG.srate, data.sliderLow.Value, data.sliderHigh.Value, [], true, false, true);
    if data.chbxNotch.Value
        data.EEG = filter_butter(data.EEG, data.EEG.srate, 47, 53, 6, true, true);
    end
end

data.pbFilter.BackgroundColor = [1 .6 .6];
guidata(hObject,data);





% --- Call this to update the listbox.
function listboxEegProperties_Update(hObject)
% hObject    handle to pbOpen (see GCBO)

data = guidata(hObject);

fields = fieldnames(data.EEG);
tmpstr = {};
for f=1:length(fields)
    if ischar(data.EEG.(fields{f}))
        tmpstr = [tmpstr ; {sprintf('%-12s "%s"',fields{f}, data.EEG.(fields{f}))}];
    elseif isinteger(data.EEG.(fields{f})) && length(data.EEG.(fields{f}))==1
        tmpstr = [tmpstr ; {sprintf('%-12s %d',fields{f}, data.EEG.(fields{f}))}];
    elseif isnumeric(data.EEG.(fields{f})) && length(data.EEG.(fields{f}))==1
        tmpstr = [tmpstr ; {sprintf('%-12s %f',fields{f}, data.EEG.(fields{f}))}];
    else
        tmpstr = [tmpstr ; {sprintf('%-12s <%s>',fields{f}, class(data.EEG.(fields{f})))}];
    end
end
data.listboxEegProperties.String = tmpstr;





% --- Executes on slider movement.
function sliderLow_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);
data.textLow.String = sprintf('low: %.1f', get(hObject,'Value'));






% --- Executes during object creation, after setting all properties.
function sliderLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





% --- Executes on slider movement.
function sliderHigh_Callback(hObject, eventdata, handles)
% hObject    handle to sliderHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);
data.textHigh.String = sprintf('low: %.1f', get(hObject,'Value'));






% --- Executes during object creation, after setting all properties.
function sliderHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





% --- Executes on button press in chbxNotch.
function chbxNotch_Callback(hObject, eventdata, handles)
% hObject    handle to chbxNotch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chbxNotch





% --- Executes during object creation, after setting all properties.
function fig_eeg_workflow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig_eeg_workflow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called





% --- Executes on button press in pbView.
function pbView_Callback(hObject, eventdata, handles)
% hObject    handle to pbView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data.pbView.BackgroundColor = [.3 .6 .3];
pause(0.005)

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pbView.BackgroundColor = [1 .6 .6];
    return
end

screensize = get(groot, 'Screensize' );
tmp = data.EEG;
eegplot(tmp.data,'srate',tmp.srate,'eloc_file',tmp.chanlocs,'spacing',50,...
    'limits',[tmp.xmin tmp.xmax],'winlength',12,'position',screensize,...
    'events',tmp.event);

data.pbView.BackgroundColor = [.6 1 .6];
guidata(hObject,data);






% --- Executes on button press in pbReref.
function pbReref_Callback(hObject, eventdata, handles)
% hObject    handle to pbReref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data.pbReref.BackgroundColor = [.3 .6 .3];
tmp = data.EEG;
if size(tmp.data,3) ~= tmp.trials
    tmp.trials = size(tmp.data,3);
end
if tmp.trials==1 && tmp.pnts~=size(tmp.data,2)
    tmp.pnts = size(tmp.data,2);
end


if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pbReref.BackgroundColor = [.6 1 .6];
    return
end

switch data.popupmenuReref.Value
    case 1, tmp = pop_reref(tmp, find(ismember(upper({tmp.chanlocs.labels}),'CPZ')));
    case 2, tmp = pop_reref(tmp, find(ismember(upper({tmp.chanlocs.labels}),{'M1','M2'})));
    case 3, tmp = pop_reref(tmp, [], 'exclude', find(ismember(upper({tmp.chanlocs.labels}),{'HEOG','VEOG'})));
end

data.EEG = tmp;
data.pbReref.BackgroundColor = [1 .6 .6];
guidata(hObject,data);





% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pbReref.
function pbReref_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pbReref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);





% --- Executes on selection change in popupmenuReref.
function popupmenuReref_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuReref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuReref contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuReref





% --- Executes during object creation, after setting all properties.
function popupmenuReref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuReref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in pushbuttonBadChans.
function pushbuttonBadChans_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBadChans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

data.pbFlatline.BackgroundColor = [.3 .6 .3];
pause(0.005)

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pbFlatline.BackgroundColor = [1 .6 .6];
    return
end

% open bad channel gui for additional selection of bad channels. Open
% modal! Wait for window to close. Data will be collected upon passing the
% handle to the current window.
h = figBadChansModal(gcf);
uiwait(h);

data.pushbuttonBadChans.BackgroundColor = [.9 .8 .6];





% --- Executes on button press in pbSegment.
function pbSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pbSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if isempty(data.EEG.event)
    uialert(hObject,'No boundary events detected. No segmentation performed.','segment warning')
else
    data.pbSegment.BackgroundColor = [.3 .6 .3];
    pause(0.005);
    
    data.nsegments = sum(strcmpi({data.EEG.event.type},'boundary'))+1;
    if data.nsegments>1
        data.popupmenuSegments.String = {'Single segment'};
        ndx = strcmpi({data.EEG.event.type},'boundary');
        cut = [1 data.EEG.event(ndx).latency data.EEG.pnts+1];
        tmp = struct;
        for seg=1:data.nsegments
            tmp(seg).EEG = data.EEG;
            tmp(seg).EEG.data = data.EEG.data(:,cut(seg):cut(seg+1)-1);
            tmp(seg).EEG.pnts = size(data.segment(seg).EEG.data,2);
            del = [];
            for ev=1:length(tmp(seg).EEG.event)
                if tmp(seg).EEG.event(ev).latency>=cut(seg)&&tmp(seg).EEG.event(ev).latency<cut(seg+1)
                    tmp(seg).EEG.event(ev).latency = tmp(seg).EEG.event(ev).latency - cut(seg) + 1;
                else
                    del = [del ev];
                end
            end
            if ~isempty(del)
                tmp(seg).EEG = pop_editeventvals(tmp(seg).EEG, 'delete', del);
            end
            tmp(seg).EEG = eeg_checkset(tmp(seg).EEG);
            tmp(seg).bad = [];
            tmp(seg).cut = [];
        end
        
        % create UI to select segment and overwrite EEG
    else
        uialert(hObject,'No boundary events detected. No segmentation performed.','segment warning')
    end
end

data.pbSegment.BackgroundColor = [1 .6 .6];
data.pbAutoRej.BackgroundColor = [.6 1 .6];
data.pbViewSeg.BackgroundColor = [.6 1 .6];
guidata(hObject,data);





% --- Executes on selection change in popupmenuSegments.
%function popupmenuSegments_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSegments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSegments


% --- Executes during object creation, after setting all properties.
function popupmenuSegments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function pbSegment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called





% --- Executes on selection change in popupmenuSegments.
function popupmenuSegments_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSegments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSegments

data = guidata(hObject);
data.ViewSegmentNumber = get(hObject,'Value');
guidata(hObject, data);





% --- Executes on button press in pbViewSeg.
function pbViewSeg_Callback(hObject, eventdata, handles)
% hObject    handle to pbViewSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global viewseg_tmprej;

data = guidata(hObject);
data.pbViewSeg.BackgroundColor = [.3 .6 .3];
pause(0.005);

if ~isfield(data,'nsegments') || data.nsegments==0
    fprintf('No available segments');
    beep;
    data.pbViewSeg.BackgroundColor = [1 .6 .6];
    return
end

% some data available. Open data with eegplot but first open bad channel
% selector.
h = figBadChans;
WinOnTop(h);
set(h,'units','pixels')
pos = get(h,'pos');
data.hBadChans = h;

% set a counter for tagging the eegplot window
if ~isfield(data,'hWindowCounter')
    data.hWindowCounter = 1;
else
    data.hWindowCounter = data.hWindowCounter + 1;
end

% open data
screensize = get(groot, 'Screensize' );
ndx = data.popupmenuSegments.Value;
switch ndx
    case 1,
        tmp = data.EEG;
        if isfield(data,'cut')
            tmpcut = data.cut;
        else
            tmpcut = [];
        end
        
    otherwise,
        tmp = data.segment(ndx-1).EEG;
        if isfield(data.segment(ndx-1),'cut')
            tmpcut = data.segment(ndx-1).cut;
        else
            tmpcut = [];
        end
end

%{
        chbx = {};
        for ch=1:tmp.nbchan
            chbx{ch} = uicontrol(h,'Style','checkbox','String',tmp.chanlocs(ch).labels,...
                'Position',[8+floor((ch-1)/32)*60 pos(4)-(mod(ch-1,32)*16+20) 60 20], 'tag', sprintf('chbx%d',ch));
            if isfield(tmp.chanlocs,'badchan') && tmp.chanlocs(ch).badchan
                chbx{ch}.Value = 1;
            else
                chbx{ch}.Value = 0;
            end
        end
        
        if isfield(data,'cut')
            winrej = [data.cut repmat([.5 .5 1],size(data.cut,1),1) ones(size(data.cut,1),tmp.nbchan)];
            eegplot(tmp.data,'srate',tmp.srate,'eloc_file',tmp.chanlocs,'spacing',50,...
                'limits',[tmp.xmin tmp.xmax],'winlength',12,'position',screensize,...
                'events',tmp.event,'winrej',winrej,'command', 'global viewseg_tmprej, viewseg_tmprej=TMPREJ',...
                'tag',sprintf('figRejectViewer_%d',data.hWindowCounter));
        else
            eegplot(tmp.data,'srate',tmp.srate,'eloc_file',tmp.chanlocs,'spacing',50,...
                'limits',[tmp.xmin tmp.xmax],'winlength',12,'position',screensize,...
                'events',tmp.event,'command', 'global viewseg_tmprej, viewseg_tmprej=TMPREJ',...
                'tag',sprintf('figRejectViewer_%d',data.hWindowCounter));
        end
%}

chbx = {};
for ch=1:tmp.nbchan
    chbx{ch} = uicontrol(h,'Style','checkbox','String',tmp.chanlocs(ch).labels,...
        'Position',[8+floor((ch-1)/32)*60 pos(4)-(mod(ch-1,32)*16+20) 60 20], 'tag', sprintf('chbx%d',ch));
    if isfield(tmp.chanlocs,'badchan') && tmp.chanlocs(ch).badchan
        chbx{ch}.Value = 1;
    else
        chbx{ch}.Value = 0;
    end
end

viewseg_tmprej = [];
if ~isempty(tmpcut)
    winrej = [tmpcut repmat([.5 .5 1],size(tmpcut,1),1) ones(size(tmpcut,1), tmp.nbchan)];
    eegplot(tmp.data,'srate',tmp.srate,'eloc_file',tmp.chanlocs,'spacing',50,...
        'limits',[tmp.xmin tmp.xmax],'winlength',12,'position',screensize,...
        'events',tmp.event,'winrej', winrej,'command', 'global viewseg_tmprej, viewseg_tmprej=TMPREJ',...
        'tag',sprintf('figRejectViewer_%d',data.hWindowCounter));
else
    % data3D = reshape(tmp.data(:,1:floor(tmp.pnts/tmp.srate)*tmp.srate),tmp.nchan,tmp.srate,floor(tmp.pnts/tmp.srate));
    eegplot(tmp.data,'srate',tmp.srate,'eloc_file',tmp.chanlocs,'spacing',50,...
        'limits',[tmp.xmin tmp.xmax],'winlength',12,'position',screensize,...
        'events',tmp.event,'command', 'global viewseg_tmprej, viewseg_tmprej=TMPREJ',...
        'tag',sprintf('figRejectViewer_%d',data.hWindowCounter));
end

% start checking timer. This will check whether windows were closed (reject
% or not reject, or delete button in channel rejection window)
data.ViewSegmentNumber = ndx; % 1 for full data, 2 for first segment, etc.
data.ViewSegmentTimer = timer('StartDelay', 1, 'Period', 1, 'TasksToExecute', Inf, ...
    'ExecutionMode', 'fixedDelay', 'busymode', 'drop');
data.ViewSegmentTimer.TimerFcn = {@viewsegtimerFcn, hObject};
start(data.ViewSegmentTimer);

% update button color
data.pbViewSeg.BackgroundColor = [1 .6 .6];
guidata(hObject, data);






% The timerFcn is called after the window becomes visible.
function viewsegtimerFcn(obj,event,arg1)

% arg1 is the parent window passed in the viewsegtimerFcn specification above
data = guidata(arg1);
global viewseg_tmprej;

stop(obj);

% check if data rejection window is still open. Get the handle. Return is
% window still open. If the bad channel window "reject" button was pressed,
% then continue to remove bad channels.
hWindow = findall(0,'tag',sprintf('figRejectViewer_%d',data.hWindowCounter));
try
    % try to get the bad channel window data. Exception handles situation
    % where bad channel window was closed before the data rejection window.
    badchans_data = guidata(data.hBadChans);
    if ~isempty(hWindow) && ~badchans_data.DeletePressed
        % data rejection window still open. (as well as channel data
        % window) restart timer and continue waiting.
        start(obj);
        return
    end
catch E
    % probably because the bad channel window was closed. Check if eegplot
    % window is still open
    if ~isempty(hWindow)
        % data rejection window still open. restart timer and continue
        % waiting (restart timer)
        start(obj);
        return
    end
    % fallthru: window is now closed (and
    warning('no bad channel selection window found');
    badchans_data = struct;
    badchans_data.DeletePressed = false;
end

% stop the timer checking if there is no rejection AND delete button was
% not pressed.
if isempty(viewseg_tmprej) && ~badchans_data.DeletePressed
    % reject button not pressed so stop checking
    try
        close(data.hBadChans);
    catch
    end
    
    delete(obj);
    set(data.pbViewSeg, 'BackgroundColor', [.6 1 .6])
    set(data.pbICA, 'BackgroundColor', [.6 1 .6]);
    return
end

% winrej data found

try
    ndx = data.ViewSegmentNumber;
    switch ndx
        case 1
            % when delete button pressed, remove channels. Otherwise,
            % remove bad parts
            if badchans_data.DeletePressed
                % look for the checkbox controls and read value
                for ch=1:data.EEG.nbchan
                    ctrl = findall(data.hBadChans,'tag',sprintf('chbx%d',ch));
                    data.bad(ch) = get(ctrl,'Value');
                    data.EEG.chanlocs(ch).badchan = data.bad(ch);
                end
                if sum(data.bad)>0
                    data.pbAutoRej.BackgroundColor = [.6 1 .6];
                    data.EEG = pop_select(data.EEG,'nochannel',find(data.bad));
                    data.bad = zeros(data.EEG.nbchan,1);
                    if data.popupmenuReref.Value==3 % average reference
                        fprintf('*** Rereferencing again to average.\n')
                        data.EEG.data = data.EEG.data - repmat(mean(data.EEG.data),size(data.EEG.data,1),1);
                    end
                end
            else
                % delete marked data or epochs
                if ndims(data.EEG.data)<3
                    % continuous data removal
                    data.EEG = eeg_eegrej(data.EEG, viewseg_tmprej(:,1:2));
                else
                    % epoched data removal
                    [tmprej tmprejE] = eegplot2trial(viewseg_tmprej, data.EEG.pnts, data.EEG.trials);
                    [data.EEG] = pop_rejepoch(data.EEG, tmprej, 0);
                end
                data.cut = [];
            end
        otherwise
            if badchans_data.DeletePressed
                % look for the checkbox controls and read value
                for ch=1:data.segment(ndx-1).EEG.nbchan
                    ctrl = findall(data.hBadChans,'tag',sprintf('chbx%d',ch));
                    data.segment(ndx-1).bad(ch) = get(ctrl,'Value');
                    data.segment(ndx-1).EEG.chanlocs(ch).badchan = data.segment(ndx-1).bad(ch);
                end
                if sum(data.segment(ndx-1).bad)>0
                    data.pbAutoRej.BackgroundColor = [.6 1 .6];
                    data.segment(ndx-1).EEG = pop_select(data.segment(ndx-1).EEG,'nochannel',find(data.segment(ndx-1).bad));
                    data.segment(ndx-1).bad = zeros(data.segment(ndx-1).EEG.nbchan,1);
                    if data.popupmenuReref.Value==3 % average reference
                        fprintf('*** Rereferencing again to average.\n')
                        data.EEG.data = data.EEG.data - repmat(mean(data.EEG.data),size(data.EEG.data,1),1);
                    end
                end
            else
                % remove data stretches or epochs
                if ndims(data.segment(ndx-1).EEG.data)<3
                    % continuous data removal
                    data.segment(ndx-1).EEG = eeg_eegrej(data.segment(ndx-1).EEG, viewseg_tmprej(:,1:2));
                else
                    % epoched data removal
                    epndx = floor(([viewseg_tmprej(:,1),viewseg_tmprej(:,2)-1])./size(data.segment(ndx-1).EEG.data,2))+1;
                    epndxall = [];
                    for row=1:size(epndx,1)
                        epndxall = union(epndxall,[epndx(row,1):epndx(row,2)]);
                    end
                    [data.segment(ndx-1).EEG] = pop_rejepoch(data.segment(ndx-1).EEG, epndxall, 0);
                end
                data.segment(ndx-1).cut = [];
            end
    end
catch E
    pause(0.005);
    % likely timer is an old one.
end

try
    close(data.hBadChans);
catch
end
try
    close(hWindow);
catch
end
guidata(arg1,data);
listboxEegProperties_Update(arg1)
delete(obj);
set(data.pbViewSeg, 'BackgroundColor', [.3 1 .3])
set(data.pbICA, 'BackgroundColor', [.6 1 .6]);



% --- Executes on REJECT
function Reject_Callback(tmprej)

fprintf('blablabla');
pause(1);






% --- Executes on slider movement.
function sliderLowdB_Callback(hObject, eventdata, handles)
% hObject    handle to sliderLowdB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);
hObject.Value = round(hObject.Value);
data.textLowdB.String = sprintf('Low dB cutoff: %d',get(hObject, 'Value'));
guidata(hObject, data);






% --- Executes during object creation, after setting all properties.
function sliderLowdB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLowdB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end






% --- Executes on slider movement.
function sliderHighdB_Callback(hObject, eventdata, handles)
% hObject    handle to sliderHighdB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);
hObject.Value = round(hObject.Value);
data.textHighdB.String = sprintf('High dB cutoff: %d',get(hObject, 'Value'));
guidata(hObject, data);






% --- Executes during object creation, after setting all properties.
function sliderHighdB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderHighdB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end






% --- Executes on mouse press over figure background.
function fig_eeg_workflow_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to fig_eeg_workflow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes when user attempts to close fig_eeg_workflow.
function fig_eeg_workflow_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fig_eeg_workflow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
data = guidata(hObject);
try
    hWindow = findall(arg1,'tag',sprintf('figRejectViewer_%d',data.hWindowCounter));
    if ~isempty(hWindow)
        close(hWindow);
    end
catch
end

try
    stop(data.ViewSegmentTimer);
    delete(data.ViewSegmentTimer);
catch
end

delete(hObject);




% --- Executes on button press in pushbuttonICA.
function pushbuttonICA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
set(hObject, 'BackgroundColor', [.3 .6 .3])
pause(0.005);

tmp = data.EEG;

if tmp.nbchan>32
    ncomps = round(tmp.nbchan*.7);
end

try
    tmp = pop_runica(tmp, 'extended',1, 'icatype','binica', 'pca', ncomps);
    data.EEG = tmp;
    guidata(hObject, data);
catch E
    throw(E);
end

guidata(hObject, data)

set(hObject, 'BackgroundColor', [.9 .8 .6])



% --- Executes on slider movement.
function sliderNComps_Callback(hObject, eventdata, handles)
% hObject    handle to sliderNComps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);
set(data.textNComps,'string', sprintf('PCA: %d', get(hObject,'Value')))







% --- Executes during object creation, after setting all properties.
function sliderNComps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderNComps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

data = guidata(hObject);
data.textPCA.String = sprintf('ncomps: %d',hObject.Value);



% --- Executes on button press in pushbuttonICLabel.
function pushbuttonICLabel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonICLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
set(hObject, 'BackgroundColor', [.3 .6 .3])

tmp = data.EEG;
tmp = pop_iclabel(tmp, 'default');
% brainlabel = FindSetNdx(tmp.etc.ic_classification.ICLabel.classes,'Brain');
artifactlabel = FindSetNdx(tmp.etc.ic_classification.ICLabel.classes,{'Muscle','Eye','Heart','Line Noise','Channel Noise'});
if get(data.checkboxKeepOther.Value) == 0.0
    % add the 'other' category
    artifactlabel = [artifactlabel {'Other'}];
end

% select components that are >45% certain brain. take sum per row i.e. for
% all artefacts (along columns). This will allow uncertainty about which
% artefact is present.
icdeselect = sum(tmp.etc.ic_classification.ICLabel.classifications(:,artifactlabel),[],2) >= data.sliderMinICLabelPercent.Value;
fprintf('Removing components: ')
fprintf(' %d',find(icdeselect))
fprintf('\n')
if sum(icdeselect)>0
    tmp = pop_subcomp(tmp, find(icdeselect), false, 0);
end

data.EEG = tmp;
guidata(hObject,data);
set(hObject, 'BackgroundColor', [.9 .8 .6])
set(data.pushbuttonSave, 'BackgroundColor', [.6 1 .6])





% --- Executes on button press in pbEpoch.
function pbEpoch_Callback(hObject, eventdata, handles)
% hObject    handle to pbEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

h = guiEpoch(data.EEG, gcf);
uiwait(h);





% --- Executes on button press in pbERP.
function pbERP_Callback(hObject, eventdata, handles)
% hObject    handle to pbERP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

tmp = data.EEG;

if size(tmp.data,3) == 1
    error('Data must be in epochs')
end


if isfield(tmp, 'eventlist')
    uniqueevt = tmp.eventlist;
    evtlist = {};
    for ep=1:length(tmp.epoch)
        ndx = find(ismember(tmp.eventlist,tmp.epoch(ep).eventtype));
        if ~isempty(ndx)
            evtlist{ep} = tmp.eventlist{ndx};
        else
            evtlist{ep} = [];
        end
    end
else
    % extract unique events and eventlist (only FIRST event in epoch)
    if iscell(tmp.epoch(1).eventtype)
        evtlist = arrayfun(@(x)x.eventtype(1),tmp.epoch,'uniformoutput',false);
        evtlist = [evtlist{:}];
        uniqueevt = unique(evtlist);
    else
        evtlist = {tmp.epoch.eventtype};
        uniqueevt = unique(evtlist);
    end
    uniqueevt = uniqueevt(~strcmp(uniqueevt,'boundary'));
end

% set up plotting
figure('pos',[50,50,800,600]);
nchans = size(tmp.data,1);
nrows = floor(sqrt(nchans));
ncols = ceil(sqrt(nchans));
if nrows*ncols<nchans
    ncols=ncols+1;
end

% now start plotting
colors = {[0 0 0]; [.8 .2 .2]; [.3 .3 .8]; [.2 .7 .2]; [1 0 0]; [0 0 .8]; [0 .7 0]};
times = tmp.xmin:(1/tmp.srate):tmp.xmax;
Xs = [tmp.chanlocs.Y]; % deliberate swap of X and Y!
Ys = [tmp.chanlocs.X];
Zs = [tmp.chanlocs.Z];
ERP = [];
for e=1:length(uniqueevt)
    ERP(:,:,e) = mean(tmp.data(:,:,strcmpi(evtlist,uniqueevt{e})),3);
end
for ch=1:size(tmp.data,1)
    pos = [.2+.6*(Xs(ch)-min(Xs))/range(Xs) .2+.6*(Ys(ch)-min(Ys))/range(Ys) .08 .08];
    if Zs(ch)<20, % move Zs curving under to the outside
        pos(1:2) = (pos(1:2)-.5)*(1.1+abs(.3*((Zs(ch)-20)/range([20 min(Zs)]))))+.5;
    end
    axes('position',pos);
    hold on
    for e=1:length(uniqueevt)
        plot(times, ERP(ch,:,e),'-','color',colors{e});
    end
    ylim([min(ERP(:)) max(ERP(:))])
    xlim([tmp.xmin tmp.xmax])
    box off
    axis off
    text(min(xlim)+range(xlim)*.1,min(ylim)+range(ylim)*.1,tmp.chanlocs(ch).labels)
    drawnow;
end




% --- Executes on button press in pbCompERP.
function pbCompERP_Callback(hObject, eventdata, handles)
% hObject    handle to pbCompERP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(hObject);
ndx = data.ViewSegmentNumber;

tmp = data.EEG;

if size(tmp.data,3) == 1
    error('Data must be in epochs')
end

% extract unique events and eventlist (only FIRST event in epoch)
if iscell(tmp.epoch(1).eventtype)
    evtlist = arrayfun(@(x)x.eventtype(1),tmp.epoch,'uniformoutput',false);
    try
        evtlist = [evtlist{:}];
    catch
    end
else
    evtlist = {tmp.epoch.eventtype};
end
uniqueevt = unique(evtlist);
uniqueevt = uniqueevt(~strcmp(uniqueevt,'boundary'));

% set up plotting
figure('pos',[50,50,800,600]);
nchans = size(tmp.icawinv,2);
nrows = floor(sqrt(nchans));
ncols = ceil(sqrt(nchans));
if nrows*ncols<nchans
    ncols=ncols+1;
end

% now start plotting
colors = {[0 0 0]; [.8 .2 .2]; [.3 .3 .8]; [.2 .7 .2]; [1 0 0]; [0 0 .8]; [0 .7 0]};
times = tmp.xmin:(1/tmp.srate):tmp.xmax;
Xs = [tmp.chanlocs.X];
Ys = [tmp.chanlocs.Y];
Zs = [tmp.chanlocs.Z];
if ~isfield(tmp,'icaact') || isempty(tmp.icaact)
    tmp.icaact = icaact(tmp.data, tmp.icaweights*tmp.icasphere);
end
epochdata = reshape(tmp.icaact,size(tmp.icaact,1),tmp.pnts,[]);
ERP = [];
for e=1:length(uniqueevt)
    ERP(:,:,e) = mean(epochdata(:,:,strcmpi(evtlist,uniqueevt{e})),3);
end
for ch=1:size(epochdata,1)
    h = subplot(nrows,ncols,ch);
    hold on
    for e=1:length(uniqueevt)
        plot(times, ERP(ch,:,e),'-','color',colors{e});
    end
    ylim([min(ERP(:)) max(ERP(:))])
    xlim([tmp.xmin tmp.xmax])
    box off
    title(sprintf('comp%d',ch))
    % add topographic plot
    pos = get(gca,'pos');
    axes('pos',[pos(1)+.65*pos(3) pos(2) pos(3)*.4 pos(4)*.4])
    topoplot(tmp.icawinv(:,ch),tmp.chanlocs,'electrodes','off')
    box off
    axis off
    % update
    drawnow;
end




% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
tmp = data.EEG;

% get file string up to first _ or . or space and use that as prospective
% subject code
[pathstr,name,ext] = fileparts(tmp.filename);
pos = [strfind(name,'_'),strfind(name,'.')];
pos = pos(~isempty(pos));
if isempty(pos)
    subjstr = name;
else
    subjstr = name(1:min(pos)-1);
end

% open modal dialog and wait
h = figSaveModal(tmp, subjstr);
uiwait(h);





% --- Executes on button press in pbushbuttonResample.
function pbushbuttonResample_Callback(hObject, eventdata, handles)
% hObject    handle to pbushbuttonResample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'backgroundcolor', [.3 .6 .3])
pause(0.005);

% resample if sampling rate different
data = guidata(hObject);
NewSrate = str2num(data.popupmenuRerefFreq.String{data.popupmenuRerefFreq.Value});
if data.popupmenuRerefFreq.Value>1 && NewSrate~=data.EEG.srate
    data.EEG = pop_resample(data.EEG, NewSrate);
    guidata(hObject, data);
end

set(hObject,'backgroundcolor', [.9 .8 .6])
set(data.pushbuttonReref,'backgroundcolor', [.6 1 .6])



% --- Executes on selection change in popupmenuRerefFreq.
function popupmenuRerefFreq_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRerefFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuRerefFreq contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuRerefFreq



% --- Executes during object creation, after setting all properties.
function popupmenuRerefFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRerefFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%--------------------------------------
% CUSTOM FUNCTIONS

function choice = choosedialog

d = dialog('Position',[300 300 250 150],'Name','Select');
txt = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 80 210 40],...
    'String','Select',...
    'Callback',@popup_callback);

pop = uicontrol('Parent',d,...
    'Style','popup',...
    'Position',[85 20 70 25],...
    'String',arrayfun(@(x)sprintf('%d',x),1:length(tmp),'uni',false)',...
    'value',1.0);
btn = uicontrol('Parent',d,...
    'Position',[89 20 70 25],...
    'String','OK',...
    'Callback','delete(gcf)');

uiwait(d);




function popup_callback(popup,event)

idx = popup.Value;
popup_items = popup.String;
choice = char(popup_items(idx,:));




% --- Executes on button press in pushbuttonFlatline.
function pushbuttonFlatline_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFlatline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

set(hObject, 'BackgroundColor', [.3 .6 .3]);

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    set(hObject, 'BackgroundColor', [1 .6 .6]);
    return
end


SD = std(data.EEG.data(:,:)');
ndx = find(SD<.1);
if ~isempty(ndx)
    data.EEG = pop_select(data.EEG,'nochannel',ndx);
    guidata(hObject, data);
end

set(hObject, 'BackgroundColor', [.9 .8 .5]);
set(data.pushbuttonChanlocs, 'BackgroundColor', [.6 1 .6]);



% --- Executes on button press in pushbuttonFilter.
function pushbuttonFilter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data.pushbuttonFilter.BackgroundColor = [.3 .6 .3];
pause(0.005)

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pushbuttonFilter.BackgroundColor = [1 .6 .6];
    return
end


if data.radiobuttonFIR.Value
    data.EEG = pop_eegfiltnew(data.EEG, data.sliderLow.Value, data.sliderHigh.Value, [], false);
    if data.checkboxNotch.Value
        data.EEG = pop_eegfiltnew(data.EEG, 47, 53, [], true);
    end
else
    data.EEG = filter_butter(data.EEG, data.EEG.srate, data.sliderLow.Value, data.sliderHigh.Value, [], true, false, true);
    if data.checkboxNotch.Value
        data.EEG = filter_butter(data.EEG, data.EEG.srate, 47, 53, 6, true, true);
    end
end

data.pushbuttonFilter.BackgroundColor = [.9 .8 .6];
data.pushbuttonInitialICA.BackgroundColor = [.6 1 .6];
guidata(hObject,data);



% --- Executes on button press in pushbuttonView.
function pushbuttonView_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data.pushbuttonView.BackgroundColor = [.3 .6 .3];
pause(0.005)

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pushbuttonView.BackgroundColor = [1 .6 .6];
    return
end

screensize = get(groot, 'Screensize' );
tmp = data.EEG;
eegplot(tmp.data,'srate',tmp.srate,'eloc_file',tmp.chanlocs,'spacing',50,...
    'limits',[tmp.xmin tmp.xmax],'winlength',12,'position',screensize,...
    'events',tmp.event);

data.pushbuttonView.BackgroundColor = [.6 1 .6];
guidata(hObject,data);



% --- Executes on button press in pushbuttonSegment.
function pushbuttonSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
if isempty(data.EEG.event)
    fprintf('No segments (no boudary events). Only single segment will be available.\n')
    data.nsegments = 1;
else
    data.pushbuttonSegment.BackgroundColor = [.3 .6 .3];
    pause(0.005);

    data.nsegments = sum(strcmpi({data.EEG.event.type},'boundary'))+1;
    if data.nsegments>1
        data.popupmenuSegments.String = {'Single segment'};
        ndx = strcmpi({data.EEG.event.type},'boundary');
        cut = [1 data.EEG.event(ndx).latency data.EEG.pnts+1];
        for seg=1:data.nsegments
            data.segment(seg).EEG = data.EEG;
            data.segment(seg).EEG.data = data.EEG.data(:,cut(seg):cut(seg+1)-1);
            data.segment(seg).EEG.pnts = size(data.segment(seg).EEG.data,2);
            del = [];
            for ev=1:length(data.segment(seg).EEG.event)
                if data.segment(seg).EEG.event(ev).latency>=cut(seg)&&data.segment(seg).EEG.event(ev).latency<cut(seg+1)
                    data.segment(seg).EEG.event(ev).latency = data.segment(seg).EEG.event(ev).latency - cut(seg) + 1;
                else
                    del = [del ev];
                end
            end
            if ~isempty(del)
                data.segment(seg).EEG = pop_editeventvals(data.segment(seg).EEG, 'delete', del);
            end
            data.segment(seg).EEG = eeg_checkset(data.segment(seg).EEG);
            data.segment(seg).bad = [];
            data.segment(seg).cut = [];

            % gui adjustement (popup menu)
            data.popupmenuSegments.String = [data.popupmenuSegments.String ; {sprintf('Segment %d',seg)}];
        end
        % default popup menu to first segment
        data.popupmenuSegments.Value = 2;
    end
end

data.pushbuttonBadChans.BackgroundColor = [1 .6 .6];
data.pushbuttonSegment.BackgroundColor = [1 .6 .6];
guidata(hObject,data);


% --- Executes on selection change in listboxProgress.
function listboxProgress_Callback(hObject, eventdata, handles)
% hObject    handle to listboxProgress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxProgress contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxProgress


% --- Executes during object creation, after setting all properties.
function listboxProgress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxProgress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbuttonReref.
function pushbuttonReref_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
set(hObject, 'BackgroundColor', [.3 .6 .3]);
pause(.005);

tmp = data.EEG;
if size(tmp.data,3) ~= tmp.trials
    tmp.trials = size(tmp.data,3);
end
if tmp.trials==1 && tmp.pnts~=size(tmp.data,2)
    tmp.pnts = size(tmp.data,2);
end
    
if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pushbuttonReref.BackgroundColor = [.6 1 .6];
    return
end

switch data.popupmenuReref.Value
    case 1, tmp = pop_reref(tmp, find(ismember(upper({tmp.chanlocs.labels}),'CPZ')));
    case 2, tmp = pop_reref(tmp, find(ismember(upper({tmp.chanlocs.labels}),{'M1','M2'})));
    case 3, tmp = pop_reref(tmp, [], 'exclude', find(ismember(upper({tmp.chanlocs.labels}),{'HEOG','VEOG'})));
end

data.EEG = tmp;
guidata(hObject,data);

set(hObject, 'BackgroundColor', [.9 .8 .6]);
data.pushbuttonFilter.BackgroundColor = [1 .6 .6];
pause(0.005);



% --- Executes on button press in checkboxAddCPz.
function checkboxAddCPz_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAddCPz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAddCPz


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in checkboxNotch.
function checkboxNotch_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxNotch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxNotch


% --- Executes on button press in pushbuttonInitialICA.
function pushbuttonInitialICA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonInitialICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

set(hObject,'backgroundcolor',[.3 .6 .3])
pause(0.005);

data.EEG.data = detrend(data.EEG.data','constant')';
tmp = pop_runica(data.EEG,'icatype','binica','pca',16);
% this works out: the reconstructed data from full ICA decomposition
% results in a resuidual (all ICs above number 16). Determine the eye ICs,
% remove the IC data by subtracting the source data. Then add back the
% residual. Noise will be removed later.

if isempty(tmp.icaact)
    tmp.icaact = icaact(tmp.data, tmp.icaweights*tmp.icasphere);
end
resid = (tmp.icawinv*tmp.icaact - tmp.data);

% determine eye ICs
tmp = pop_iclabel(tmp, 'default');
eyelabel = FindSetNdx(tmp.etc.ic_classification.ICLabel.classes,'Eye');
icdeselect = (tmp.etc.ic_classification.ICLabel.classifications(:,eyelabel)')'>.60;
fprintf('Removing %d eye components\n',sum(icdeselect));
if sum(icdeselect)>0
    data.EEG.data = data.EEG.data - tmp.icawinv(:,icdeselect)*tmp.icaact(icdeselect,:);
end

guidata(hObject, data);

set(hObject,'backgroundcolor',[.9 .8 .6])


% --- Executes on button press in pushbuttonClean.
function pushbuttonClean_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonClean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
set(hObject,'backgroundcolor',[.3 .6 .3])
pause(0.005);

data.EEG = pop_clean_rawdata(data.EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off',...
    'BurstCriterion',data.sliderBurstCriterion.Value,...
    'WindowCriterion',0.15,...
    'BurstRejection',ifthen(data.checkboxBurstDelete.Value,'on','off'),...
    'Distance','Euclidian',...
    'WindowCriterionTolerances',eval(data.textBurstTolerance.String) );
     
guidata(hObject, data);
set(hObject,'backgroundcolor',[.9 .8 .6])
set(data.pushbuttonICA, 'backgroundcolor', [.6 1 .6]);
pause(0.005);


% --- Executes on button press in pushbuttonAAR.
function pushbuttonAAR_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = guidata(hObject);
set(hObject,'backgroundcolor',[.3 .6 .3])
pause(0.005);

data.EEG = pop_autobssemg(data.EEG, 40, 40, 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', [256],'femg', [15],'estimator',spectrum.welch,'range', [0  34]});

guidata(hObject, data);
set(hObject,'backgroundcolor',[.9 .8 .6])
pause(0.005);


% --- Executes on button press in checkboxBurstDelete.
function checkboxBurstDelete_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBurstDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxBurstDelete


% --- Executes on slider movement.
function sliderBurstTolerance_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBurstTolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

set(data.textBurstTolerance,'string',sprintf('[-Inf %.1f]',get(hObject,'value')));

guidata(hObject, data);

% --- Executes during object creation, after setting all properties.
function sliderBurstTolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBurstTolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderBurstCriterion_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBurstCriterion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

set(data.textBurstCriterion,'string',sprintf('%.2f',get(hObject,'value')));

guidata(hObject, data);


% --- Executes during object creation, after setting all properties.
function sliderBurstCriterion_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBurstCriterion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderMinICLabelPercent_Callback(hObject, eventdata, handles)
% hObject    handle to sliderMinICLabelPercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

set(data.textMinICLabelPercent,'string',sprintf('Remove ICs at %d%%',round(get(hObject,'value')*100)));

guidata(hObject, data);



% --- Executes during object creation, after setting all properties.
function sliderMinICLabelPercent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderMinICLabelPercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkboxKeepOther.
function checkboxKeepOther_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxKeepOther (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxKeepOther
