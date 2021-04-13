function varargout = figBadChansModal(varargin)
% FIGBADCHANSMODAL MATLAB code for figBadChansModal.fig
%      FIGBADCHANSMODAL, by itself, creates a new FIGBADCHANSMODAL or raises the existing
%      singleton*.
%
%      H = FIGBADCHANSMODAL returns the handle to a new FIGBADCHANSMODAL or the handle to
%      the existing singleton*.
%
%      FIGBADCHANSMODAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGBADCHANSMODAL.M with the given input arguments.
%
%      FIGBADCHANSMODAL('Property','Value',...) creates a new FIGBADCHANSMODAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before figBadChansModal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to figBadChansModal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figBadChansModal

% Last Modified by GUIDE v2.5 28-Oct-2020 15:10:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figBadChansModal_OpeningFcn, ...
                   'gui_OutputFcn',  @figBadChansModal_OutputFcn, ...
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


% --- Executes just before figBadChansModal is made visible.
function figBadChansModal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figBadChansModal (see VARARGIN)

% Choose default command line output for figBadChansModal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes figBadChansModal wait for user response (see UIRESUME)
% uiwait(handles.figure1);

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

% hObject is the figure that's being opened, not a button or other control.
% So 'pos' will give the window position.
%{
pos = get(hObject,'pos');
chbx = {};
colsize = 18;
for ch=1:data_parent.EEG.nbchan
    chbx{ch} = uicontrol(hObject,'Style','checkbox','String',data_parent.EEG.chanlocs(ch).labels,...
        'Position',[8+floor((ch-1)/colsize)*60 pos(4)-(mod(ch-1,colsize)*18+20) 60 20], 'tag', sprintf('chbx%d',ch));
    if isfield(data_parent.EEG.chanlocs,'badchan') && data_parent.EEG.chanlocs(ch).badchan
        chbx{ch}.Value = 1;
    else
        chbx{ch}.Value = 0;
    end
end
%}

data.saveEEG = data_parent.EEG;

tmp = data_parent.EEG; 
data.startpos = 1;
data.plotscale = 50;
data.nbchan = tmp.nbchan;
data.srate = tmp.srate;
data.data = tmp.data;
data.offset = 0;
data.labels = {tmp.chanlocs.labels};

data.exclude = false(1,tmp.nbchan);

if isfield(tmp.chanlocs,'bad')
    data.isbad = [tmp.chanlocs.bad];
else
    data.isbad = false(1,tmp.nbchan);
    for ch=1:tmp.nbchan
        tmp.chanlocs(ch).bad = false;
    end
end
data.viewdata = detrend(tmp.data(:,:)');
data.viewdata = data.viewdata + repmat((0:(data.nbchan-1)).*data.plotscale, size(tmp.data(:,:)',1),1);

% set the values for the scroll slider. NOTE set this in the rightorder
% otherwise the UI control will disappear!
set(data.slideScroll,'max',1);
set(data.slideScroll,'min',0);
set(data.slideScroll,'sliderstep',[.01 .1]);
set(data.slideScroll,'value',0);

guidata(hObject, data);

plotdata(data.axesPSD, data);


% plot function
function plotdata(hndlAxes, data)

cla(hndlAxes);
plot(hndlAxes,data.viewdata((1:data.srate*6)+data.offset, ~data.isbad & ~data.exclude),'k-');
hold(hndlAxes,'on');
plot(hndlAxes,data.viewdata((1:data.srate*6)+data.offset, data.isbad & ~data.exclude),'r-');
plot(hndlAxes,data.viewdata((1:data.srate*6)+data.offset, data.exclude),'g-');
ylim(hndlAxes,[-50, data.nbchan*50+50]);

set(hndlAxes,'xtick',(1:data.srate:data.srate*6),'xticklabel',1:7);
set(hndlAxes,'ytick',(1:50:data.nbchan*50),'yticklabel',data.labels);

drawnow;



% --- Outputs from this function are returned to the command line.
function varargout = figBadChansModal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonDelete.
function pushbuttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);

ndx = find(data.isbad & ~data.exclude);
if ~isempty(ndx)
    data_parent.EEG = pop_select(data_parent.EEG,'nochannel',ndx);
end
guidata(data.Parent, data_parent);

close(gcf);

% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);

data_parent.EEG = data.saveEEG;
guidata(data.Parent, data_parent);

close(gcf);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pbStd.
function pbStd_Callback(hObject, eventdata, handles) 
% hObject    handle to pbStd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

% do not simply calculate SD, but get median SD across 1 sec epochs. This
% should remove influential epochs (periods with high SD).
tmpdata = data.data';
len = data.srate;
nepochs = floor(size(tmpdata,1)/len);
% create epochs of data and remove first and last epoch
tmpdata = reshape(tmpdata(1:nepochs*len,:)',data.nbchan,len,[]);
tmpdata = permute(tmpdata(:,:,2:end-1),[2,1,3]);

SD = zscore(median(std(tmpdata),3));

for ch=1:data.nbchan
    if SD(ch)>=data.slideStd.Value
        data.isbad(ch) = true; % only add 'bad' status. use reset to set to false
    end
end

plotdata(data.axesPSD, data);

guidata(hObject,data);

% --- Executes on button press in pbLowR.
function pbLowR_Callback(hObject, eventdata, handles)
% hObject    handle to pbLowR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

% do not simply calculate SD, but get median SD across 1 sec epochs. This
% should remove influential epochs (periods with high SD).
tmpdata = data.data';
len = data.srate;
nepochs = floor(size(tmpdata,1)/len);
% create epochs of data and remove first and last epoch
tmpdata = reshape(tmpdata(1:nepochs*len,:)',data.nbchan,len,[]);
tmpdata = permute(tmpdata(:,:,2:end-1),[2,1,3]);

% get median correlation acorss 1 sec epochs
R=[];
for e=1:size(tmpdata,3)
    R(e,:) = max(corr(tmpdata(:,:,e))-eye(size(tmpdata,2)));
end
M=median(R);

% test for under minimal value of median R
for ch=1:data.nbchan
    if M(ch)<data.slideMinR.Value
        data.isbad(ch) = true; % only add 'bad' status. use reset to set to false
    end
end

% plot
plotdata(data.axesPSD, data);

guidata(hObject,data);

% --- Executes on button press in pbInterpolate.
function pbInterpolate_Callback(hObject, eventdata, handles)
% hObject    handle to pbInterpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);

tmp = data_parent.EEG;
INT = InterpolationReplace(tmp);

tmpdataEEG = tmp.data';
tmpdataINT = INT.data';

% turn into epchs. We'll look at the MEDIAN correlation.
len = data.srate;
nepochs = floor(size(tmpdataEEG,1)/len);
% create epochs of data and remove first and last epoch since these often
% have filter artefacts.
tmpdataEEG = reshape(tmpdataEEG(1:nepochs*len,:)',data.nbchan,len,[]);
tmpdataEEG = permute(tmpdataEEG(:,:,2:end-1),[2,1,3]);
tmpdataINT = reshape(tmpdataINT(1:nepochs*len,:)',data.nbchan,len,[]);
tmpdataINT = permute(tmpdataINT(:,:,2:end-1),[2,1,3]);

for e=1:size(tmpdataEEG,3)
    R(e,:) = diag(corr(tmpdataINT(:,:,e),tmpdataEEG(:,:,e)));
end
M=median(R);

% test for under minimal value of median R
for ch=1:data.nbchan
    if M(ch)<data.slideMinR.Value
        data.isbad(ch) = true; % only add 'bad' status. use reset to set to false
    end
end

plotdata(data.axesPSD, data);

guidata(hObject,data);




% --- Executes on button press in pbReset.
function pbReset_Callback(hObject, eventdata, handles)
% hObject    handle to pbReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

data.isbad = false(1,data.nbchan);

offset = data.offset;
cla(data.axesPSD);
plot(data.axesPSD,data.viewdata((1:data.srate*6)+offset,~data.isbad),'k-');
hold on;
plot(data.axesPSD,data.viewdata((1:data.srate*6)+offset,data.isbad),'r-');
ylim(data.axesPSD,[-50, data.nbchan*50+50]);
set(data.axesPSD,'xtick',(1:data.srate:data.srate*6),'xticklabel',1:7);
drawnow;

guidata(hObject,data);

% --- Executes on slider movement.
function slideStd_Callback(hObject, eventdata, handles)
% hObject    handle to slideStd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);
data.txtStd.String = sprintf('z>%d', get(hObject,'Value'));
guidata(hObject,data);


% --- Executes during object creation, after setting all properties.
function slideStd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideStd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slideMinR_Callback(hObject, eventdata, handles)
% hObject    handle to slideMinR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

set(data.txtMinR, 'String', sprintf('%.2g',get(hObject,'value')));

guidata(hObject,data);


% --- Executes during object creation, after setting all properties.
function slideMinR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideMinR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slideInterpolate_Callback(hObject, eventdata, handles)
% hObject    handle to slideInterpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

set(data.txtInterpolate, 'String', sprintf('%.1g',get(hObject,'value')));

guidata(hObject,data);


% --- Executes during object creation, after setting all properties.
function slideInterpolate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideInterpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pbViewFilt.
function pbViewFilt_Callback(hObject, eventdata, handles)
% hObject    handle to pbViewFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data.viewdata = filter_fir(data.viewdata',data.srate,1,45,3.0)';
data.viewdata = data.viewdata + repmat((0:(data.nbchan-1)).*50, size(data.data(:,:)',1),1);

plotdata(data.axesPSD, data);

guidata(hObject, data);


% --- Executes on slider movement.
function slideScroll_Callback(hObject, eventdata, handles)
% hObject    handle to slideScroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

offset = round(data.slideScroll.Value*size(data.viewdata,1));
data.offset = offset;

plotdata(data.axesPSD, data);

guidata(hObject, data);


% --- Executes during object creation, after setting all properties.
function slideScroll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideScroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on mouse press over axes background.
function axesPSD_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesPSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);


% --- Executes on button press in pushbuttonExclude.
function pushbuttonExclude_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);

data.exclude = false(1,data.nbchan);

if get(hObject,'Value')
    tmp = data_parent.EEG;
    ndx = FindSetNdx({tmp.chanlocs.labels},data.editExclude.String,'match','pattern');
    data.exclude(ndx) = true;
end

guidata(hObject,data);

plotdata(data.axesPSD, data);


function editExclude_Callback(hObject, eventdata, handles)
% hObject    handle to editExclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editExclude as text
%        str2double(get(hObject,'String')) returns contents of editExclude as a double


% --- Executes during object creation, after setting all properties.
function editExclude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonDirectDelete.
function pushbuttonDirectDelete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDirectDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);

delstr = strsplit(get(data.editDirectDelete,'String'), ';');
ndx = [];
for l=1:length(delstr)
    ndx = [ndx FindSetNdx(data.labels,delstr{l},'match','pattern')];
end
if ~isempty(ndx)
    data_parent.EEG = pop_select(data_parent.EEG,'nochannel',ndx);
        
    data.nbchan = data_parent.EEG.nbchan;
    data.data = data_parent.EEG.data;
    data.labels = {data_parent.EEG.chanlocs.labels};

    data.exclude = false(1,data_parent.EEG.nbchan);

    data.isbad = false(1,data_parent.EEG.nbchan);
    for ch=1:data_parent.EEG.nbchan
        data_parent.EEG.chanlocs(ch).bad = false;
    end
    data.viewdata = detrend(data_parent.EEG.data(:,:)');
    data.viewdata = data.viewdata + repmat((0:(data.nbchan-1)).*data.plotscale, size(data_parent.EEG.data(:,:)',1),1);
end

guidata(hObject, data);
guidata(data.Parent, data_parent);

plotdata(data.axesPSD, data);


function editDirectDelete_Callback(hObject, eventdata, handles)
% hObject    handle to editDirectDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDirectDelete as text
%        str2double(get(hObject,'String')) returns contents of editDirectDelete as a double


% --- Executes during object creation, after setting all properties.
function editDirectDelete_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDirectDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonRemove1Sec.
function pushbuttonRemove1Sec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemove1Sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);

data_parent.EEG = pop_select(data_parent.EEG,'time',[1 data_parent.EEG.xmax-1.0]);
data.viewdata = detrend(data_parent.EEG.data(:,:)');
data.viewdata = data.viewdata + repmat((0:(data.nbchan-1)).*data.plotscale, size(data_parent.EEG.data(:,:)',1),1);

guidata(data.Parent, data_parent);

plotdata(data.axesPSD, data);


% --- Executes on button press in pushbuttonRedoAvg.
function pushbuttonRedoAvg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRedoAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

data = guidata(hObject);
data_parent = guidata(data.Parent);

data_parent.EEG = pop_reref(data_parent.EEG,[],'exclude',find(data.exclude));
data.viewdata = detrend(data_parent.EEG.data(:,:)');
data.viewdata = data.viewdata + repmat((0:(data.nbchan-1)).*data.plotscale, size(data_parent.EEG.data(:,:)',1),1);

guidata(data.Parent, data_parent);

plotdata(data.axesPSD, data);
