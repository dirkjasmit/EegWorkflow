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

% Last Modified by GUIDE v2.5 07-May-2025 15:52:40

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

% end of function ---------------------------------------------------------


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

data = guidata(hObject);

AddToListbox(data.listboxStdout, '  *** Warning *** EEGLAB with specific plugins is required')
AddToListbox(data.listboxStdout, '   - EEGLAB V2020 has been tested, requires signal processing toolbox')
AddToListbox(data.listboxStdout, '   - AAR')
AddToListbox(data.listboxStdout, '   - CleanRawdata')
AddToListbox(data.listboxStdout, '   - ICLabel')
AddToListbox(data.listboxStdout, '   - file import plugins (ANT, Biosemi, EDF)')
AddToListbox(data.listboxStdout, '   - and several support functions')

if isempty(which("eeglab.m"))
    AddToListbox(data.listboxStdout, '*** warning *** cannot find EEGLAB. Please activate locate.')
    data.listboxStdout;
    if strcmpi(E.identifier,'MATLAB:UndefinedFunction')
        filepath = uigetdir(pwd, "Locate EEGLAB");
        addpath(filepath)
        eeglab;
    end
end

% initialise data
data.EEG = eeg_emptyset();
data.Stack = {};

% set the values of the uicontrols. Read 
if ismac()
    data.INIDIR = '~/Application Support/Matlab_EegAutoFlow';
elseif isunix
    data.INIDIR = '~/.config/Matlab_EegAutoFlow';
elseif ispc
    data.INIDIR = '~/AppData/Matlab_EegAutoFlow';
else
    warning('unknown system')
    data.INIDIR = './';
end

% read the defualt values
try
    FN = sprintf('%s/%s.ini', data.INIDIR, get(hObject,'name'));
    opts = detectImportOptions(FN, 'TextType', 'string', 'filetype', 'text');
    opts.DataLines = [2 Inf];
    opts.VariableTypes(:) = {'string'};  % Force all columns to string
    strlist = readtable(FN, opts);
    SetUIControlData(hObject, strlist);
catch E
    warning('Initialization file not found. Will be created on close.')
end

% initialise fontsize
if ispc
    data.fontsize = 9;
else
    data.fontsize = 10;
end
setFontSize(hObject.Parent, data.fontsize)

% push the data to the object
guidata(hObject, data);

% end of function ---------------------------------------------------------





function AddToListbox(listboxObject, str)

old = listboxObject.String;
new = str;
oldsize = size(old);
newsize = size(str);
if newsize(2)>oldsize(2)
    old = [old repmat(' ',oldsize(1),newsize(2)-oldsize(2))];
elseif newsize(2)<oldsize(2)
    new = [new repmat(' ',1,oldsize(2)-newsize(2))];
end
listboxObject.String = cat(1,old,new);
nlines = size(listboxObject.String,1);
if length(nlines)>100
    listboxObject.String = listboxObject.String(2:end,:);
end

listboxObject.Value = size(listboxObject.String,1);

pause(0.005);

% end of function ---------------------------------------------------------




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

% end of function ---------------------------------------------------------




% --- Executes on button press in pbOpen.
function pushbuttonOpen_Callback(hObject, eventdata, handles)
% hObject    handle to pbOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
savecolour = hObject.BackgroundColor; % save colour for after cancel
hObject.BackgroundColor = [.3 .6 .3];

FilterSpec = {'*.*', 'All files'
    '*.bdf', 'Biosemi'
    '*.cnt', 'ANT Neuro / Neuroscan'
    '*.edf', 'European data format'
    '*.set', 'EEGLAB'
    '*.vhdr', 'BrainVision'
    };
fid = fopen(sprintf('%s/.EegWorkflow_DefaultPath.ini', data.INIDIR), 'r');
DefaultPath = '.';
if fid>0
    try
        DefaultPath = fgetl(fid);
        fclose(fid);
    catch
    end
end 
[FileName, PathName, FilterIndex] = uigetfile(FilterSpec,'Select an EEG file', DefaultPath);

% save the default folder.
if ~exist(data.INIDIR)
    mkdir(data.INIDIR);
end
fid = fopen(sprintf('%s/.EegWorkflow_DefaultPath.ini', data.INIDIR), 'w');
if fid>0
    fprintf(fid, '%s', PathName);
    fclose(fid);
end 

% try block here?
if isnumeric(FileName) && FileName==0
    AddToListbox(data.listboxStdout, '*** warning *** no file selected');
    hObject.BackgroundColor = savecolour;
else
    
    data.EEG = loadfile(PathName, FileName, data.listboxStdout, data.checkboxBiosig);
    data.EEG = eeg_checkset(data.EEG);
    
    % correct amplitude of Nihon Koden files (EOGH EOGV Fp1 Fp2 , possibly F7 F8 had
    % different gain settings. Heuristic is to divide all channels but
    % these by two (half the gain settings). CHECK WITH PSD
    if data.checkboxCorrectNK.Value
        AddToListbox(data.listboxStdout, '*** warning *** correcting Nihon Koden files');
        adjust = FindSetNdx({data.EEG.chanlocs.labels},{'EOGH','EOGV','Fp1','Fp2','F7','F8'});
        % adjust = setdiff(1:data.EEG.nbchan, adjust);
        data.EEG.data(adjust,:) = data.EEG.data(adjust,:)*2;
    end
    
    % reset the stack for Undo operations
    data.Stack = {};
    data.StackLabel = {};
    %if isfield(data.EEG,'event')
    %    for ev=1:length(data.EEG.event)
    %        if ischar(data.EEG.event(ev).type)
    %            data.EEG.event(ev).type = data.EEG.event(ev).type(~ismember(data.EEG.event(ev).type,[0 9:13 32]));
    %        end
    %    end
    %end

    % make all button red (except the next one)
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
    % Flatline and Remove Resting may turn green
    data.pushbuttonFlatline.BackgroundColor = [.6 1 .6];
    % The remainder should be red.
    data.pushbuttonLookup.BackgroundColor = [1 .6 .6];
    data.pushbuttonChanlocs.BackgroundColor = [1 .6 .6];
    data.pushbuttonResample.BackgroundColor = [1 .6 .6];
    data.pushbuttonFilter.BackgroundColor = [1 .6 .6];
    data.pushbuttonReref.BackgroundColor = [1 .6 .6];
    data.pushbuttonInitialICA.BackgroundColor = [1 .6 .6];
    data.pushbuttonAAR.BackgroundColor = [1 .6 .6];
    data.pushbuttonBadChans.BackgroundColor = [1 .6 .6];
    data.pushbuttonClean.BackgroundColor = [1 .6 .6];
    data.pushbuttonICA.BackgroundColor = [1 .6 .6];
    data.pushbuttonICLabel.BackgroundColor = [1 .6 .6];
    data.pushbuttonAARWinSec.BackgroundColor = [1 .6 .6];
    hObject.BackgroundColor = [1 .6 .6];

end

% start a meta-data table line. Fill it as struct, then use struct2table to
% create the table. Every call (every buttonpresss will fill a struct
% field.
data.tabLine = struct();
data.tabLine.starttime = size(data.EEG.data(:,:),2) / data.EEG.srate;

guidata(hObject,data)

% end of function ---------------------------------------------------------



function EEG = loadfile(PathName, FileName, listboxStdout, checkboxBiosig)

if PathName(end)~='/'
    PathName = [PathName '/'];
end

zz = strsplit(FileName,'.');
switch zz{end}
    case 'cnt'
        try
            cLoadANTNeuro = true;
            EEG = pop_loadeep_v4([PathName FileName], 'triggerfile', 'on');
        catch E
            if strcmpi(E.message, 'Error getting samples')
                cLoadANTNeuro = false;
                % try loading Neuroscan
                EEG = pop_loadcnt([PathName FileName] , 'dataformat', 'auto', 'memmapfile', '');
            end
        end

        % add filename
        EEG.filename = [PathName FileName];

        if cLoadANTNeuro
            % some event editing needs to be done for ANT Neuro files

            % copy to tmp variable and work on that
            tmp = EEG;

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
                    tmp.event(evtcnt).latency = EEG.event(ev).latency;
                    tmp.event(evtcnt).duration = EEG.event(ev).duration;
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
            EEG = tmp;
            AddToListbox(listboxStdout, 'Read ANT CNT file')

        else
            AddToListbox(listboxStdout, 'Read Neuroscan CNT file')
        end

    case 'set'
        EEG = pop_loadset([PathName FileName]);
        EEG.filename = [PathName FileName];
        AddToListbox(listboxStdout, 'Read EEGLAB file')

    case 'bdf'
        if checkboxBiosig.Value ~= 0
            AddToListbox(listboxStdout, 'Read BDF file with pop_biosig');
            EEG = pop_biosig([PathName FileName], 'bdfeventmode',1);
            AddToListbox(listboxStdout, ' - data read');
        else
            AddToListbox(listboxStdout, 'Read BDF file with pop_readbdf');
            AddToListbox(listboxStdout, ' - read file header');
            tmp = sopen([PathName FileName]);
            AddToListbox(listboxStdout, sprintf(' - %d channels', tmp.NS));
            EEG = pop_readbdf([PathName FileName], [], tmp.NS);
            AddToListbox(listboxStdout, ' - data read');
        end
        EEG.filename = FileName;
        AddToListbox(listboxStdout, ' - *** NOTE Data are raw. Please rereference in the next steps.');
        AddToListbox(listboxStdout, ' - *** NOTE Renaming EXG* to EXT*.');
        for ch=1:EEG.nbchan
            if strncmp(EEG.chanlocs(ch).labels, "EXG", 3)
                EEG.chanlocs(ch).labels(3) = "T";
            end
        end

    case 'edf'
        % read header
        EEG = pop_biosig([PathName FileName]);
        EEG.filename = FileName;
        AddToListbox(listboxStdout, 'Read EDF file.');     

    case 'vhdr'
        % read header
        EEG = pop_loadbv(PathName, FileName, [], []);
        EEG.filename = FileName;
        AddToListbox(listboxStdout, 'Read BrainVision file.');     
end

% end of function ---------------------------------------------------------



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

AddToListbox(data.listboxStdout, 'Reading channel locations.');
tmp = data.EEG;

if data.checkboxAddCpz.Value 
    if sum(strcmpi({tmp.chanlocs.labels},'CPz'))==0
        AddToListbox(data.listboxStdout, ' - Adding CPz channel as flatline.');
        tmp.data(end+1,:) = 0;
        tmp.nbchan = data.EEG.nbchan+1;
        tmp.chanlocs(end+1).labels = 'CPz';
        AddToListbox(data.listboxStdout, ' - Removing ICA decomposition.');
        tmp.icaweights = [];
        tmp.icawinv = [];
        tmp.icasphere = [];
        tmp = eeg_checkset(tmp);
    else
        AddToListbox(data.listboxStdout, 'Warning: CPz already in data. Not adding a flatine CPz reference channel.');
    end 
end

switch data.popupmenuLookupType.Value
    case 1
        AddToListbox(data.listboxStdout, ' - Looking up channels in standard-10-5-cap385.elp.');
        tmp = pop_chanedit(tmp, 'lookup','standard-10-5-cap385.elp');
    case 2
        AddToListbox(data.listboxStdout, ' - Renaming Biosemi channels to 10/10 and looking up channels in standard-10-5-cap385.elp.');
        labs = readtable('BioSemi68_labels.txt');
        for ch=1:length(labs.Label)
            ndx = find(strcmp(labs.Label{ch}, {tmp.chanlocs.labels})); 
            if length(ndx)==1
                tmp.chanlocs(ndx).labels = labs.ten10{ch};
            elseif length(ndx)>2
                pause;
            else
                AddToListbox(data.listboxStdout, sprintf( '   channel %s not found', labs.Label{ch}));
            end 
        end
        tmp = pop_chanedit(tmp, 'lookup','standard-10-5-cap385.elp');
        
    case 3
        AddToListbox(data.listboxStdout, ' - Copying channel locations from a 128 channel EEGLAB dataset.');
        lookup = pop_loadset('Biosemi128.set');
        for ch=1:tmp.nbchan
            ndx = find(strcmp(tmp.chanlocs(ch).labels, {lookup.chanlocs.labels}));
            if length(ndx)==1
                tmp.chanlocs(ch) = lookup.chanlocs(ndx);
            else
                AddToListbox(data.listboxStdout, sprintf( '   channel %s not found', tmp.chanlocs(ch).labels));
            end 
        end
        
    case 4
        AddToListbox(data.listboxStdout, ' - TD Brain channel locations');
        lookup = pop_loadset('TDBRain.set');
        for ch=1:tmp.nbchan
            ndx = find(strcmp(tmp.chanlocs(ch).labels, {lookup.chanlocs.labels}));
            if length(ndx)==1
                tmp.chanlocs(ch) = lookup.chanlocs(ndx);
            else
                AddToListbox(data.listboxStdout, sprintf( '   channel %s not found', tmp.chanlocs(ch).labels));
            end
        end
        
    case 5
        AddToListbox(data.listboxStdout, ' - EGI 128 EEG channels lookup');
        tmp = pop_chanedit(tmp, {'lookup','/Users/dirksmit/MATLAB/eeglab2023.1/plugins/dipfit/standard_BEM/elec/standard_1005.elc'},'load',{'/Users/dirksmit/MATLAB/eeglab2023.1/functions/supportfiles/channel_location_files/philips_neuro/GSN-HydroCel-128.sfp','filetype','autodetect'});
end

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Lookup';
data.EEG = tmp;
guidata(hObject,data)

listboxEegProperties_Update(hObject)
set(hObject, 'BackgroundColor', [.9 .8 .5]);
data.pushbuttonResample.BackgroundColor = [.6 1 .6];

% end of function ---------------------------------------------------------


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
    AddToListbox(data.listboxStdout, 'Applying FIR filter while observing transition band.');
    data.EEG = filter_fir(data.EEG, data.EEG.srate, data.sliderLow.Value, data.sliderHigh.Value, 3.0, true, false, false);
    if data.chbxNotch.Value
        AddToListbox(data.listboxStdout, ' Notch FIR filter 47 to 53 Hz');
        data.EEG = filter_fir(data.EEG, data.EEG.srate, 47, 53, 3.0, true, true);
    end
else
    AddToListbox(data.listboxStdout, ' Applying 3rd order Butterworth IIR filter (zerophase)');
    data.EEG = filter_butter(data.EEG, data.EEG.srate, data.sliderLow.Value, data.sliderHigh.Value, 3, true, false, false);
    if data.chbxNotch.Value
        AddToListbox(data.listboxStdout, ' Notch FIR filter 47 to 53 Hz');
        data.EEG = filter_butter(data.EEG, data.EEG.srate, 47, 53, 3, true, true);
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
data.textLow.String = sprintf('Low: %.1f', get(hObject,'Value'));






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
data.textHigh.String = sprintf('High: %.1f', get(hObject,'Value'));






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

% end of function ---------------------------------------------------------




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

% end of function ---------------------------------------------------------




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

% end of function ---------------------------------------------------------




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

% end of function ---------------------------------------------------------




% --- Executes during object creation, after setting all properties.
function pbSegment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% end of function ---------------------------------------------------------




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


% end of function ---------------------------------------------------------



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

% end of function ---------------------------------------------------------





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

% save all the settings

strlist = GetUIControlData(hObject);

% Save the data in the INI directry
if ~exist(data.INIDIR,'dir')
    mkdir(data.INIDIR)
end
writetable(strlist,sprintf('%s/%s.ini', data.INIDIR, get(hObject,'name')), 'delimiter','\t','filetype','text')

% remove the binica files in current directory
files = dir('binica*'); % Get all matching files
for f = 1:length(files)
    delete(fullfile(files(f).folder, files(f).name));
end

delete(hObject);


% pass a handle to the gui, and it will extract all the UIControl object
% data (slider, checkbox value and edit strings).
function strlist = GetUIControlData(hObject)

strlist = struct;

ch = get(hObject,'ch');
count = 0;
for c=1:length(ch)
    if strcmpi(get(ch(c),'Type'),'uicontrol')
        skip=false;
        switch get(ch(c),'Style')
            case 'edit'
                tmp1 = sprintf('%s',get(ch(c),'tag'));
                tmp2 = sprintf('%s',get(ch(c),'string'));
            case {'checkbox','slider','popupmenu'}
                tmp1 = sprintf('%s',get(ch(c),'tag'));
                tmp2 = sprintf('%.4f',get(ch(c),'value'));
            otherwise
                skip=true;
        end
        if ~skip
            count = count + 1;
            strlist(count).key = tmp1;
            strlist(count).val = tmp2;
        end
    end
end             

strlist = struct2table(strlist);


% SETUICONTROLDATA fills the data with the values in strlist ------------
function SetUIControlData(hObject, strlist)

ch = get(hObject,'ch');
for c=1:length(ch)
    if strcmpi(get(ch(c),'Type'),'uicontrol')
        switch get(ch(c),'Style')
            
            case 'edit'
                ndx = find(strcmpi(strlist.key, get(ch(c),'tag')));
                if length(ndx)==1
                    if isnumeric(strlist.val)
                        set(ch(c),'string', sprintf('%.4f', strlist.val(ndx)));
                    else
                        set(ch(c),'string', sprintf('%s', strlist.val{ndx}));
                    end
                end
                pause(0.005)
                
            case {'checkbox','popupmenu'}
                ndx = find(strcmpi(strlist.key, get(ch(c),'tag')));
                if length(ndx)==1
                    if isnumeric(strlist.val)
                        set(ch(c),'value', strlist.val(ndx));
                    else
                        set(ch(c),'value', str2num(strlist.val{ndx}));
                    end
                end
                pause(0.005);
                
            case {'slider'}
                ndx = find(strcmpi(strlist.key, get(ch(c),'tag')));
                if length(ndx)==1
                    if isnumeric(strlist.val)
                        set(ch(c),'value', strlist.val(ndx));
                    else
                        set(ch(c),'value', str2num(strlist.val{ndx}));
                    end
                end
                ch(c).Callback(ch(c),[])
                pause(0.005);
        end
    end
end             




% --- Executes on button press in pushbuttonRemoveNoEEG.
function pushbuttonRemoveNoEEG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemoveNoEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

tmp = data.EEG;

notEEG = find(cellfun(@isempty, {tmp.chanlocs.X}));
AddToListbox(data.listboxStdout, sprintf('Removing %d non-EEG channels', length(notEEG)))
tmp = pop_select(tmp, 'nochannel', notEEG);
if data.popupmenuReref.Value && strcmpi(data.popupmenuReref.String{data.popupmenuReref.Value}, 'Average')
    AddToListbox(data.listboxStdout, sprintf('- redo avg reference'))
    tmp = pop_reref(tmp, []);
end

% tmp = data.EEG;
% 
% ncomps = data.sliderNComps.Value;
% if ncomps<10
%     ncomps = 10;
%     AddToListbox(data.listboxStdout, 'Too few components selected for ICA. Taking the minimum of 10.')
% end
% if ncomps>tmp.nbchan
%     ncomps=tmp.nbchan;
%     AddToListbox(data.listboxStdout, 'Too many components selected for ICA. Taking the maximum.')
% end
% 
% try
%     try
%         AddToListbox(data.listboxStdout, 'Running ICA.')
%         tmp = pop_runica(tmp,'icatype','binica','pca',ncomps);
%     catch E
%         AddToListbox(data.listboxStdout, 'Running ICA failed. Reverting to slower version.')
%         tmp = pop_runica(tmp,'icatype','runica','extended',1,'pca',ncomps);
%     end
%     data.EEG = tmp;
%     guidata(hObject, data);
% catch E
%     throw(E);
% end
% 
% % push existing data onto stack. Update <data.EEG> to tmp.

data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Remove non-EEG';
data.EEG = tmp;
guidata(hObject, data);
pause(0.01)




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

ncomps = data.sliderNComps.Value;
if ncomps<10
    ncomps = 10;
    AddToListbox(data.listboxStdout, 'Too few components selected for ICA. Taking the minimum of 10.')
end
if ncomps>tmp.nbchan
    ncomps=tmp.nbchan;
    AddToListbox(data.listboxStdout, 'Too many components selected for ICA. Taking the maximum.')
end

try
    try
        AddToListbox(data.listboxStdout, 'Running ICA.')
        tmp = pop_runica(tmp,'icatype','binica','pca',ncomps);
    catch E
        AddToListbox(data.listboxStdout, 'Running ICA failed. Reverting to slower version.')
        tmp = pop_runica(tmp,'icatype','runica','extended',1,'pca',ncomps);
    end
    data.EEG = tmp;
    guidata(hObject, data);
catch E
    throw(E);
end

% IC label part
AddToListbox(data.listboxStdout, 'Performing IC labelling')

tmp = pop_iclabel(tmp, 'default');
% brainlabel = FindSetNdx(tmp.etc.ic_classification.ICLabel.classes,'Brain');
artifactlabel = FindSetNdx(tmp.etc.ic_classification.ICLabel.classes,{'Muscle','Eye','Heart','Line Noise','Channel Noise'});
if data.checkboxKeepOther.Value == 0.0
    % add the 'other' category
    artifactlabel = [artifactlabel {'Other'}];
end

% select components that are >45% certain brain. take sum per row i.e. for
% all artefacts (along columns). This will allow uncertainty about which
% artefact is present.
icdeselect = sum(tmp.etc.ic_classification.ICLabel.classifications(:,artifactlabel),2) >= data.sliderMinICLabelPercent.Value;
fprintf('Removing components: ')
fprintf(' %d',find(icdeselect))
fprintf('\n')
if sum(icdeselect)>0
    % use subtraction method for each component (repmat not required this
    % way!
    for comp=find(icdeselect)'
        tmp.data(:,:) = tmp.data(:,:) - tmp.icaact(comp,:);
    end
    data.tabLine.iclabelDeselect = sum(icdeselect);
end

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'ICLabel';
data.EEG = tmp;
guidata(hObject, data);

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
    if isnumeric(tmp.epoch(1).eventtype)
        numflag = true;
    end
    evtlist = {};
    for ep=1:length(tmp.epoch)
        try
            ndx = find(ismember(tmp.eventlist, tmp.epoch(ep).eventtype));
        catch
            ndx = [];
        end
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

% open modal dialog and wait
h = figSaveModal(tmp, tmp.filename, data.fontsize, data.INIDIR);
uiwait(h);





% --- Executes on button press in pushbuttonResample.
function pushbuttonResample_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonResample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'backgroundcolor', [.3 .6 .3])
pause(0.005);
data = guidata(hObject);

AddToListbox(data.listboxStdout,'Resampling data');

tmp = data.EEG;

% resample if sampling rate different
fs_new = str2num(data.popupmenuRerefFreq.String{data.popupmenuRerefFreq.Value});
if ~data.popupmenuRerefFreq.Value>1 && NewSrate~=data.EEG.srate
    AddToListbox(data.listboxStdout,'*** warning *** no change in sampling rate.');
    return
end

% check what alogorithm to use
fs_old = tmp.srate;
isint = (fs_new/fs_old==round(fs_new/fs_old)) | (fs_old/fs_new==round(fs_old/fs_new));
if ~isint
    AddToListbox(data.listboxStdout,'*** warning *** resampling with spline (noninteger divide)');
end

% do the resampling
if isint
    tmp = pop_resample(tmp, fs_new);
else
    warning('Resampling by spline interpolation!')
    dummy = pop_resample(tmp, fs_new);
    t_old = (0:tmp.pnts-1)/fs_old;
    t_new = (0:dummy.pnts-1)/fs_new;

    % copy all info to tmp. Overwrite data with spline later.
    tmp = dummy;
    
    % Resample using spline interpolation
    for ch=1:tmp.nbchan
        tmp.data(ch,:) = interp1(t_old, data.EEG.data(ch,:), t_new, 'spline');  
    end
    
end

data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Resample';
data.EEG = tmp;
guidata(hObject, data);

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

% always work with a tmp variable.
tmp = data.EEG;
crit = data.sliderFlatlineSD.Value;
AddToListbox(data.listboxStdout, sprintf('Removing channels with <%.1f stdev.', crit));


% get very low StdDev for channels
SD = std(data.EEG.data(:,:)');
ndx = find(SD < crit);
if ~isempty(ndx)
    AddToListbox(data.listboxStdout, sprintf('- Removing %d channels ', length(ndx)));
    tmp = pop_select(tmp,'nochannel',ndx);
    data.tabLine.flatline = length(ndx);
else
    AddToListbox(data.listboxStdout, '- NO channels removed');
    data.tabLine.flatline = 0;
end

if data.checkboxFlatlineEpochs.Value
    AddToListbox(data.listboxStdout, '- Remove flatline periods');
end
    

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Flatline';
data.EEG = tmp;
guidata(hObject, data);

% set the button colors
set(hObject, 'BackgroundColor', [.9 .8 .5]);
set(data.pushbuttonExcessive, 'BackgroundColor', [.6 1 .6]);



% --- Executes on button press in pushbuttonFilter.
function pushbuttonFilter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data.pushbuttonFilter.BackgroundColor = [.3 .6 .3];
pause(0.005)

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    AddToListbox(data.listboxStdout,'*** error *** No EEG data avilable');
    msgbox('No data available');
    data.pushbuttonFilter.BackgroundColor = [1 .6 .6];
    return
end

tmp = data.EEG;

if data.radiobuttonFIR.Value
    AddToListbox(data.listboxStdout,'Filtering with FIR filter.');    
    tmp = pop_eegfiltnew(tmp, data.sliderLow.Value, data.sliderHigh.Value, [], false);
    if data.checkboxNotch.Value
        AddToListbox(data.listboxStdout,'Notch filter 47 to 53 Hz.');    
        tmp = pop_eegfiltnew(tmp, 47, 53, [], true);
    end
else
    AddToListbox(data.listboxStdout,'Filtering with 2nd order Butterworth');    
    tmp = filter_butter(tmp, tmp.srate, data.sliderLow.Value, data.sliderHigh.Value, 9, true, false, true);
    if data.checkboxNotch.Value
        tmp = filter_butter(tmp, tmp.srate, 47, 53, 2, true, true);
    end
end

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Filter';
data.EEG = tmp;
guidata(hObject, data);

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



% --- Executes on button press in pushbuttonReref.
function pushbuttonReref_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
set(hObject, 'BackgroundColor', [.3 .6 .3]);
pause(.005);

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pushbuttonReref.BackgroundColor = [.6 1 .6];
    return
end

tmp = data.EEG;
if size(tmp.data,3) ~= tmp.trials
    tmp.trials = size(tmp.data,3);
end
if tmp.trials==1 && tmp.pnts~=size(tmp.data,2)
    tmp.pnts = size(tmp.data,2);
end
    
AddToListbox(data.listboxStdout, sprintf('Rereferencing data (%s)',data.popupmenuReref.String{data.popupmenuReref.Value}));

switch data.popupmenuReref.Value
    case 1, tmp = pop_reref(tmp, find(ismember(upper({tmp.chanlocs.labels}),'CPZ')));
    case 2, tmp = pop_reref(tmp, find(ismember(upper({tmp.chanlocs.labels}),{'M1','M2'})));
    case 3, tmp = pop_reref(tmp, [], 'exclude', find(ismember(upper({tmp.chanlocs.labels}),{'HEOG','VEOG'})));
    case 4, tmp = eeg_REST_reref(tmp);
    case 5, tmp = pop_reref(tmp, find(ismember(upper({tmp.chanlocs.labels}),{'A1','A2'})));
        
    case 6  % special case for a special dataset, first avg then A1A2
        tmp = pop_reref(tmp, []);
        tmp = pop_reref(tmp, find(ismember(upper({tmp.chanlocs.labels}),{'A1','A2'})));
        
    case 7  % special case for BECAUSE dataset: EXT5/6 are A1/A2
        tmp = pop_reref(tmp, {'EXT5','EXT6'});
    case 8
        trodes = {};
        for ch=1:tmp.nbchan
            if ~isempty(tmp.chanlocs(ch).X)
                trodes = cat(1, trodes, {tmp.chanlocs(ch).labels});
            end
        end
        if length(trodes)<tmp.nbchan
            warning('DOWNSIZING DATA. Only channels with  location info can be used for CSD')
            tmp = pop_select(tmp,'channel',trodes);
        end
        %% Get Montage for use with CSD Toolbox
        Montage_64 = ExtractMontage('/Users/dirksmit/MATLAB/CSDtoolbox/resource/10-5-System_Mastoids_EGI129.csd',trodes);
        [G,H] = GetGH(Montage_64);
        [s1,s2,s3] = size(tmp.data);
        tmp.data = CSD(tmp.data(:,:),G,H);
        if s3>1
            tmp.data = reshape(tmp.data, [s1,s2,s3]);
        end
        
end

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Rereference';
data.EEG = tmp;
guidata(hObject, data);

set(hObject, 'BackgroundColor', [.9 .8 .6]);
data.pushbuttonFilter.BackgroundColor = [1 .6 .6];
pause(0.005);



% --- Executes on button press in checkboxAddCpz.
function checkboxAddCpz_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxAddCpz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxAddCpz


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

AddToListbox(data.listboxStdout, 'Running intial ICA of 16 PCs');

tmp = data.EEG;
if (tmp.trials==1)
    tmp.data = detrend(tmp.data','constant')';
end
try
    tmp = pop_runica(tmp,'icatype','binica','pca',ifthen(tmp.nbchan<16,tmp.nbchan,16));
catch E
    tmp = pop_runica(tmp,'icatype','runica','extended',1,'pca',ifthen(tmp.nbchan<16,tmp.nbchan,16));
end

if isempty(tmp.icaact)
    AddToListbox(data.listboxStdout, ' Recalculate ICA activations.');
    tmp.icaact = icaact(tmp.data, tmp.icaweights*tmp.icasphere);
end

AddToListbox(data.listboxStdout, ' Get eye PCs using ICLabel.');

% determine eye ICs
tmp = pop_iclabel(tmp, 'default');
eyelabel = FindSetNdx(tmp.etc.ic_classification.ICLabel.classes,'Eye');
icdeselect = (tmp.etc.ic_classification.ICLabel.classifications(:,eyelabel)')'>.50;
AddToListbox(data.listboxStdout, sprintf(' Removing %d ICs',sum(icdeselect)));
if sum(icdeselect)>0
    AddToListbox(data.listboxStdout, sprintf(' - Remove %d eye ICs',sum(icdeselect)));
    fprintf(' - Remove %d eye ICs using subtraction method\n',sum(icdeselect));
    % use the source subtraction method to remove ICs, NOT the pop_select
    % method that reduces the dimensionality of the data.
    tmp.data(:,:) = tmp.data(:,:) - tmp.icawinv(:,icdeselect)*tmp.icaact(icdeselect,:);
    data.tabLine.removeEOG = sum(icdeselect);
end

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Initial ICA';
data.EEG = tmp;
guidata(hObject, data);

system('rm binica*.sph')
system('rm binica*.ch')

set(hObject,'backgroundcolor',[.9 .8 .6])



% --- Executes on button press in pushbuttonAltInitialEOG.
function pushbuttonAltInitialEOG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAltInitialEOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

set(hObject,'backgroundcolor',[.3 .6 .3])
pause(0.005);

AddToListbox(data.listboxStdout, 'Removing EOG with *EOG* channels');
tmp = data.EEG;
tmp.data = detrend(tmp.data','constant')';

eogndx = FindSetNdx({tmp.chanlocs.labels}, '*eog*', 'match','pattern');
if isempty(eogndx)
    AddToListbox(data.listboxStdout, 'WARNING! could not match EOG channels. Nothing performed');
    return
end

try
    tmp = pop_runica(tmp,'icatype','binica','pca',16);
catch E
    tmp = pop_runica(tmp,'icatype','runica','extended',1,'pca',16);
end

if isempty(tmp.icaact)
    AddToListbox(data.listboxStdout, '- Recalculate ICA activations.');
    tmp.icaact = icaact(tmp.data, tmp.icaweights*tmp.icasphere);
end

AddToListbox(data.listboxStdout, '- Match eye ICs to EOG channels');

% determine eye ICs after some extra lowpass filtering
EYE = filter_fir(tmp.data(eogndx,:), tmp.srate, 0, 20, 3.0, true);
ICs = filter_fir(tmp.icaact(:,:), tmp.srate, 0, 20, 3.0, true);
R = abs(corr(EYE',ICs'));
icdeselect = any(R>.66,1);
AddToListbox(data.listboxStdout, sprintf('- Removing %d ICs with subtraction method',sum(icdeselect)));
if sum(icdeselect)>0
    % use the source subtraction method to remove ICs, NOT the pop_select
    % method that reduces the dimensionality of the data.
    tmp.data = tmp.data - tmp.icawinv(:,icdeselect)*tmp.icaact(icdeselect,:);
    data.tabLine.removeEOG = sum(icdeselect);
end

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Initial EOG (alt method)';
data.EEG = tmp;
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

AddToListbox(data.listboxStdout, 'Clean data usig clean_rawdata');

tmp = pop_clean_rawdata(data.EEG, ...
    'FlatlineCriterion','on','LineNoiseCriterion','off','Highpass','off',...
    'BurstCriterionRefTolerances', [-Inf 3.0], ...
    'ChannelCriterion', data.sliderChannelMinR.Value, ...
    'BurstCriterion',data.sliderBurstCriterion.Value,...
    'WindowCriterion', 0.25 ,... % default value
    'BurstRejection',ifthen(data.checkboxBurstDelete.Value,'on','off'),...
    'Distance','Euclidian',...
    'ChannelCriterionMaxBadTime', data.sliderMaxBadTime.Value);
     
% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Clean';
data.EEG = tmp;
guidata(hObject, data);

% add info to the table.
data.tabLine.cleanDeletedTime = sum(mean((data.EEG.data(:,:)-tmp.data(:,:)).^2)>.1) / data.EEG.srate;


set(hObject,'backgroundcolor',[.9 .8 .6])
set(data.pushbuttonICLabel, 'backgroundcolor', [.6 1 .6]);
pause(0.005);


% --- Executes on button press in pushbuttonAARWinSec.
function pushbuttonAARWinSec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAARWinSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = guidata(hObject);
set(hObject,'backgroundcolor',[.3 .6 .3])
pause(0.005);

AddToListbox(data.listboxStdout, 'Clean data of muscle actvit using AAR in 40s windows.');

tmp = data.EEG;
ws = data.sliderAARWinSec.Value;
ss = data.sliderAARShift.Value;
tmp = pop_autobssemg(tmp, ws, ss, 'bsscca', {'eigratio', [1000000]}, ...
    'emg_psd', {'ratio', [10],'fs', [256],'femg', [15],...
    'estimator', spectrum.welch, 'range', [0  34]});

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'AAR';
data.EEG = tmp;
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
function sliderBurstCriterion_Callback(hObject, eventdata, handles)
% hObject    handle to sliderChannelMinR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

set(data.textBurstCriterion,'string',sprintf('%.1f',get(hObject,'value')));

guidata(hObject, data);

% --- Executes during object creation, after setting all properties.
function sliderBurstCriterion_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderChannelMinR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderChannelMinR_Callback(hObject, eventdata, handles)
% hObject    handle to sliderChannelMinR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

set(data.textChannelMinR,'string',sprintf('%.2f',get(hObject,'value')));

guidata(hObject, data);


% --- Executes during object creation, after setting all properties.
function sliderChannelMinR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderChannelMinR (see GCBO)
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


% --- Executes during object creation, after setting all properties.
function checkboxBurstDelete_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkboxBurstDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

pause(1)


% --- Executes on selection change in listboxStdout.
function listboxStdout_Callback(hObject, eventdata, handles)
% hObject    handle to listboxStdout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxStdout contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxStdout


% --- Executes during object creation, after setting all properties.
function listboxStdout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxStdout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonUseSource.
function pushbuttonUseSource_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUseSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = figMatchChannels(gcf, @figUseSource_Callback);
uiwait(h);

data.pushbuttonUseSource.BackgroundColor = [.9 .8 .6];
data.pushbuttonChanlocs.BackgroundColor = [.9 .8 .6];
data.pbFilter.BackgroundColor = [.6 1 .6];

guidata(hObject, data);



function figUseSource_Callback(hObject)

data = guidata(hObject);
data_parent = guidata(data.Parent);
data_parent.EEG = data.EEG;


function editOpenFilepath_Callback(hObject, eventdata, handles)
% hObject    handle to editOpenFilepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOpenFilepath as text
%        str2double(get(hObject,'String')) returns contents of editOpenFilepath as a double


% --- Executes during object creation, after setting all properties.
function editOpenFilepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOpenFilepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxBiosemiLookup.
function checkboxBiosemiLookup_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBiosemiLookup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxBiosemiLookup


% --- Executes on selection change in popupmenuLookupType.
function popupmenuLookupType_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuLookupType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuLookupType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuLookupType


% --- Executes during object creation, after setting all properties.
function popupmenuLookupType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuLookupType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPlot2D.
function pushbuttonPlot2D_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlot2D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
figure;
topoplot([],data.EEG.chanlocs, 'style', 'blank', ...
    'electrodes', 'labelpoint', ...
    'chaninfo', data.EEG.chaninfo);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbuttonResample.
function pushbuttonResample_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonResample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbUndo.
function pbUndo_Callback(hObject, eventdata, handles)
% hObject    handle to pbUndo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if isempty(data.Stack)
    beep;
    AddToListbox(data.listboxStdout, 'No more saved datasets.');
else
    AddToListbox(data.listboxStdout, sprintf('Undo %s',data.StackLabel{end}));
    data.EEG = data.Stack{end};
    if length(data.Stack)==1
        data.Stack = {};
        data.StackLabel = {};
    else
        data.Stack  = data.Stack(1:end-1);
        data.StackLabel  = data.StackLabel(1:end-1);
    end
end

guidata(hObject, data);


% --- Executes on button press in pushbuttonSaveMemory.
function pushbuttonSaveMemory_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveMemory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
global GlobEEG
GlobEEG = data.EEG;
AddToListbox(data.listboxStdout, 'Saving data into global variable GlobEEG');


% --- Executes on button press in pushbuttonUp.
function pushbuttonUp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if data.fontsize>15
    return
end

data.fontsize = data.fontsize + 1;

setFontSize(hObject.Parent, data.fontsize)

% push the fontsize data to the object
guidata(hObject, data);



% --- Executes on button press in pushbuttonDOWN.
function pushbuttonDOWN_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDOWN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if data.fontsize<4
    return
end

data.fontsize = data.fontsize - 1;

setFontSize(hObject.Parent, data.fontsize)

% push the fontsize data to the object
guidata(hObject, data);





function setFontSize(hObject, fs)

    try
        chlist = hObject.Children;
    catch
        return
    end
    
    for ch=1:length(chlist)
        if isprop(chlist(ch), 'fontsize')
            try
                set(chlist(ch), 'fontsize', fs);
            catch
                beep
            end
        end
        if isprop(chlist(1), 'children')
            if ~isempty(get(chlist(ch), 'children'))
                setFontSize(chlist(ch), fs);
            end
        end
    end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbuttonUp.
function pushbuttonUp_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function sliderFlatlineSD_Callback(hObject, eventdata, handles)
% hObject    handle to sliderFlatlineSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = guidata(hObject);
data.textFilterSD.String = sprintf('SD<%.1f', get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function sliderFlatlineSD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderFlatlineSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderMaxBadTime_Callback(hObject, eventdata, handles)
% hObject    handle to sliderMaxBadTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

set(data.textMaxBadTime,'string',sprintf('%.2f',get(hObject,'value')));

guidata(hObject, data);



% --- Executes during object creation, after setting all properties.
function sliderMaxBadTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderMaxBadTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonRemoveResting.
function pushbuttonRemoveResting_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemoveResting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(hObject);


% as always, work on tmp in stead of data.EEG
dims = [1 35];  % Textbox dimensions
definput = {'2.0', '2.0'};  % Default values
answer = inputdlg({'Keep data before event (s)', 'Keep data after event (s)'}, ...
    'input lower and upper bound for PSD', dims, definput);
% Convert the cell array to numbers
if ~isempty(answer) % Check if user didn't cancel
    lo = round(str2double(answer{1}));
    hi = round(str2double(answer{2}));
else
    AddToListbox(data.listboxStdout, 'User cancelled');
    return
end
cWithin = 2.0; %
AddToListbox(data.listboxStdout, sprintf('Looking for periods with events (+ %.f and - %.f s)', hi, lo));

tmp = data.EEG;
mask = false(1,tmp.pnts);
for e=1:length(tmp.event)
    if (~strcmpi(tmp.event(e).type, "boundary"))
        start = floor(tmp.event(e).latency-tmp.srate*lo);
        stop  = ceil(tmp.event(e).latency+tmp.srate*hi);
        start = ifthen(start<1, 1, start);
        stop  = ifthen(stop<1, 1, stop);
        mask(start:stop) = true;
    end
end

if data.checkboxTaskNoTask.Value>0
    AddToListbox(data.listboxStdout, sprintf('- reversing the mask (removing task data)', sum(~mask)/tmp.srate));
    mask = ~mask;
end

AddToListbox(data.listboxStdout, sprintf('- removing %f.1 seconds of data', sum(~mask)/tmp.srate));

% get points to remove, ndx1 the strat point, ndx2 the end points
ndx1 = find(diff(mask)<0);
ndx2 = find(diff(mask)>0)-1;
if ndx1(1)>ndx2(1)
    ndx1 = [1 ndx1];
end
if length(ndx1)>length(ndx2)
    ndx2=[ndx2 tmp.pnts];
end
remove = [ndx1' ndx2'];
tmp = pop_select(tmp, 'nopoint', remove);


% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Remove task or no-task';
data.EEG = tmp;
guidata(hObject, data);






% --- Executes on button press in checkboxTaskNoTask.
function checkboxTaskNoTask_Callback(hObject, eventdata, handles)

% hObject    handle to checkboxTaskNoTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxTaskNoTask

data = guidata(hObject);
tmp = ifthen(get(hObject,"Value")>0, 'Rm task', 'Rm no-task');
data.pushbuttonRemoveResting.String = tmp;


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over checkboxTaskNoTask.
function checkboxTaskNoTask_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to checkboxTaskNoTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19


% --- Executes on button press in checkboxMaskEventNum.
function checkboxMaskEventNum_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxMaskEventNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxMaskEventNum


% --- Executes on button press in pushbuttonExcessive.
function pushbuttonExcessive_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExcessive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

set(hObject, 'BackgroundColor', [.3 .6 .3]);

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    set(hObject, 'BackgroundColor', [1 .6 .6]);
    return
end

% always work with a tmp variable.
tmp = data.EEG;
crit = data.sliderExcessive.Value;
AddToListbox(data.listboxStdout, sprintf('Removing channels with Z>%.1f.', crit));

% get very low StdDev for channels
SD = std(data.EEG.data(:,:)');
Z = (SD-mean(SD))./std(SD);
ndx = find(Z > crit);
if ~isempty(ndx)
    AddToListbox(data.listboxStdout, sprintf('- Removing %d channels ', length(ndx)));
    tmp = pop_select(tmp,'nochannel',ndx);
    data.tabLine.excessive = length(ndx);
else
    AddToListbox(data.listboxStdout, '- NO channels removed');
    data.TabLine.excessive = 0;
end

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Excessive channel SD z-score';
data.EEG = tmp;
guidata(hObject, data);

% set the button colors
set(hObject, 'BackgroundColor', [.9 .8 .5]);
set(data.pushbuttonChanlocs, 'BackgroundColor', [.6 1 .6]);




% --- Executes on slider movement.
function sliderInitialBadChanSD_Callback(hObject, eventdata, handles)
% hObject    handle to sliderInitialBadChanSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = guidata(hObject);
data.textInitialBadChanSD.String = sprintf('%.1f', get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function sliderInitialBadChanSD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderInitialBadChanSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkboxBiosig.
function checkboxBiosig_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxBiosig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxBiosig


% --- Executes on button press in pushbuttonOverlay.
function pushbuttonOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(hObject);

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pbView.BackgroundColor = [1 .6 .6];
    return
end

if ~isfield(data,'EEG') || isempty(data.EEG) || data.EEG.nbchan==0
    AddToListbox(data.listboxStdout, '*** Warning *** no data available');
    return
end
if ~isfield(data,'Stack') || isempty(data.Stack)
    AddToListbox(data.listboxStdout, '*** Warning *** no comparison data available');
    return
end

screensize = get(groot, 'Screensize' );
tmp1 = data.EEG;
tmp2 = data.Stack{length(data.Stack)};
if tmp1.nbchan==tmp2.nbchan && tmp1.pnts==tmp2.pnts 
    eegplot(tmp2.data,'srate',tmp2.srate,'eloc_file',tmp2.chanlocs,'spacing',50,...
        'limits',[tmp2.xmin tmp2.xmax],'winlength',12,'position',screensize,...
        'events',tmp2.event, 'data2', tmp1.data);
else
    AddToListbox(data.listboxStdout, '*** Warning *** data and comparison data are incompatible to plot together');
    
    % try to match the data on channels
    u = union({tmp2.chanlocs.labels}, {tmp1.chanlocs.labels});
    tmp1 = pop_select(tmp1, 'channel', u);
    tmp2 = pop_select(tmp2, 'channel', u);
    % match sampling rate
    if tmp1.srate~=tmp2.srate
        newrate = min(tmp1.srate, tmp2.srate);
        tmp1 = pop_resample(tmp1,newrate);
        tmp2 = pop_resample(tmp2,newrate);
    end
    % match time
    if tmp1.pnts ~- tmp2.pnts
        newpnts = min(tmp1.pnts, tmp2.pnts);
        tmp1 = pop_select(tmp1, 'point', [1 newpnts]);
        tmp2 = pop_select(tmp2, 'point', [1 newpnts]);
    end
    eegplot(tmp2.data,'srate',tmp2.srate,'eloc_file',tmp2.chanlocs,'spacing',50,...
    'limits',[tmp2.xmin tmp2.xmax],'winlength',12,'position',screensize,...
    'events',tmp2.event, 'data2', tmp1.data);
end

guidata(hObject,data);


% --- Executes on slider movement.
function sliderExcessive_Callback(hObject, eventdata, handles)
% hObject    handle to sliderExcessive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = guidata(hObject);
data.textExcessive.String = sprintf('Z>%.1f', get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function sliderExcessive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderExcessive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttoSaveChanlocs.
function pushbuttoSaveChanlocs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttoSaveChanlocs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if ~isfield(data,'EEG')|| isempty(data.EEG.chanlocs)
    AddToListbox(data.listboxStdout, '*** Warning *** No EEG data to save channel locations.');
    return
end

Chanlocs = data.EEG;
Chanlocs.data = []; % do not save the data, only channel locations
Chanlocs.icaact = [];
save('.chanlocs.mat',"Chanlocs")
AddToListbox(data.listboxStdout, 'Saving EEG data channel locations');
AddToListbox(data.listboxStdout, sprintf('- %d channels saved', Chanlocs.nbchan));


% --- Executes on button press in pushbuttonImpute.
function pushbuttonImpute_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonImpute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if ~exist('.chanlocs.mat', 'file')
    AddToListbox(data.listboxStdout, '*** Warning *** No EEG data saved to impute with.');
    return
end

load('.chanlocs.mat') % loads Chanlocs EEG struct

remove = setdiff({data.EEG.chanlocs.labels}, {Chanlocs.chanlocs.labels});
if length(remove)>0
    AddToListbox(data.listboxStdout, 'Removing channels not in imputation list');
    for r=1:length(remove)
        AddToListbox(data.listboxStdout, sprintf(' %s', remove{r}));
    end
    data.EEG = pop_select(data.EEG, 'nochannel', remove);
end

impute = setdiff({Chanlocs.chanlocs.labels}, {data.EEG.chanlocs.labels});
AddToListbox(data.listboxStdout, sprintf('Imputing %d channels', length(impute)))
data.EEG = pop_interp(data.EEG, Chanlocs.chanlocs, 'spherical');
data.EEG.nbchan = size(data.EEG.data,1);

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Impute channels';
guidata(hObject, data);



% --- Executes on button press in pbBatch. -------------------------------
function pbBatch_Callback(hObject, eventdata, handles)
% hObject    handle to pbBatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global skipOverwrite_choice %#ok<GVMIS> 

data = guidata(hObject);

% open the batch modal window to get the settings
h = figRunBatchModal(gcf, data.INIDIR);
uiwait(h);
pause(.05)
data = guidata(hObject);

if isfield(data,'batchfilenames') &&  ~isempty(data.batchfilenames)
    % loop thourgh files and apply the checked functions
    resultTable = [];

    % check if any output file exists, then ask to overwrite or skip
    ex = false;
    for f=1:length(data.batchfilenames)
        FNOut = [data.batchpathname '/' sprintf('BatchCln_%s', data.batchfilenames{f})];    
        [pth,fle,ext] = fileparts(FNOut);
        FNOut = sprintf('%s/%s.set', pth, fle);
        if exist(FNOut)
            ex = true;
            break
        end
    end
    % ask for skip or overwrite
    if ex
        skip_or_overwrite_dialog();
    end

                

    for f=1:length(data.batchfilenames)
        try
            % filename for output
            FNOut = [data.batchpathname '/' sprintf('BatchCln_%s', data.batchfilenames{f})];    
            [pth,fle,ext] = fileparts(FNOut);
            FNOut = sprintf('%s/%s.set', pth, fle);
            % skip if it exists and so requested.
            if exist(FNOut) && strcmpi(skipOverwrite_choice, 'skip')
                continue
            end

        
            % read the file
            EEG = loadfile(data.batchpathname, data.batchfilenames{f}, data.listboxStdout, data.checkboxBiosig);
            data.EEG = EEG;
            data.tabLine = struct();
            data.tabLine.starttime = size(data.EEG.data(:,:),2) / data.EEG.srate;
            guidata(hObject, data);
            pause(0.01); % allows the upload

            % perform the selected actions in a fixed order with the
            % settings as specified. 
            for cb=data.batchchecked
                % run this checkbox
                switch cb
                    case 1
                        pushbuttonFlatline_Callback(data.pushbuttonFlatline, [], []);
                        data = guidata(hObject);
                    case 2
                        pushbuttonExcessive_Callback(data.pushbuttonExcessive, [], []);
                        data = guidata(hObject);
                    case 3
                        pushbuttonChanlocs_Callback(data.pushbuttonChanlocs, [], []);
                        data = guidata(hObject);
                    case 4
                        pushbuttonResample_Callback(data.pushbuttonResample, [], []);
                        data = guidata(hObject);
                    case 5
                        pushbuttonReref_Callback(data.pushbuttonReref, [], []);
                        data = guidata(hObject);
                    case 6
                        pushbuttonFilter_Callback(data.pushbuttonFilter, [], []);
                        data = guidata(hObject);
                        
                    case 7
                        pushbuttonInitialICA_Callback(data.pushbuttonInitialICA, [], []);
                        data = guidata(hObject);
                    case 8
                        pushbuttonAltInitialEOG_Callback(data.pushbuttonAltInitialEOG, [], []);
                        data = guidata(hObject);
                    case 9
                        pushbuttonAARWinSec_Callback(data.pushbuttonAARWinSec, [], []);
                        data = guidata(hObject);
                    case 10
                        pushbuttonAltAAR_Callback(data.pushbuttonAltAAR, [], []);
                        data = guidata(hObject);
    
                    % channel remove checkboxes
                    case 11
                        pushbuttonRemoveNoEEG_Callback(data.pushbuttonRemoveNoEEG, [], []);
                        data = guidata(hObject);
                    case 12
                        pushbuttonRemoveEOG_Callback(data.pushbuttonRemoveEOG, [], []);
                        data = guidata(hObject);

                    % remaining cleaning procedures flatline eperiods,
                    % cleanrawdata and IClabel cleanning
                    case 13
                        pushbuttonFlatPeriod_Callback(data.pushbuttonFlatPeriod, [], []);
                        data = guidata(hObject);
                    case 14
                        pushbuttonClean_Callback(data.pushbuttonClean, [], []);
                        data = guidata(hObject);
                    case 15
                        pushbuttonICLabel_Callback(data.pushbuttonICLabel, [], []);
                        data = guidata(hObject);
                end
            end
            
            % clear the stack
            data.Stack = {};
            data.StackLabel = {};
            guidata(hObject, data);
            
            % save the file with prefix batch
            pop_saveset(data.EEG, 'filename', sprintf('BatchCln_%s', data.batchfilenames{f}), ...
                                  'filepath', data.batchpathname, ...
                                  'savemode', 'onefile')
            data.tabLine.finaltime = size(data.EEG.data(:,:),2) / data.EEG.srate;


            % collect the table output
            try
                data.tabLine.filename = data.batchfilenames{f};
                if isempty(resultTable)
                    resultTable = data.tabLine;
                else
                    resultTable = cat(1, resultTable, data.tabLine);
                end
            catch
            end
        catch E
            AddToListbox(data.listboxStdout, '*** Undefined error. Continuing with next file')
            % AddToListbox(data.listboxStdout, sprintf('- %s', E.message))
        end

    end

    out = struct2table(resultTable);
    % append / update any existing file!
    batchtablefile = sprintf('%s/BatchTable.txt', data.batchpathname);
    if exist(batchtablefile)
        update = readtable(batchtablefile);
        % de the right IDs, idx<table> is correctly sorted
        [~, idxUpdate, idxOut] = intersect(update.filename, out.filename);
        
        try
            % Step 1: Update matching IDs
            update(idxUpdate, :) = out(idxOut, :);
            
            % Step 2: Find new IDs in T2 not in T1
            [newOnly, ~] = setdiff(out.filename, update.filename);
            
            % Step 3: Append new rows
            update = [update; out(ismember(out.filename, newOnly), :)];        
            out = update;
        catch E
            warning('Could not match new batch data to existing!')
        end
    end

    vars = out.Properties.VariableNames;
    vars = [{'filename'} setdiff(vars, 'filename')];
    writetable(out(:,vars), batchtablefile, 'del', '\t');

    system(sprintf('open "%s"', data.batchpathname))
end




function  skip_or_overwrite_dialog()
    % Create a UI figure
    fig = uifigure('Name', 'Action Required', 'Position', [500 500 300 150]);

    % Add text label
    lbl = uilabel(fig, ...
        'Text', 'Some output files exists. What would you like to do?', ...
        'Position', [25 80 250 40], ...
        'HorizontalAlignment', 'center');

    % Create buttons and define callbacks
    btnSkip = uibutton(fig, 'push', ...
        'Text', 'Skip all', ...
        'Position', [50 30 80 30], ...
        'ButtonPushedFcn', @(btn,event) buttonCallback(fig, 'skip'));

    btnOverwrite = uibutton(fig, 'push', ...
        'Text', 'Overwrite', ...
        'Position', [170 30 80 30], ...
        'ButtonPushedFcn', @(btn,event) buttonCallback(fig, 'overwrite'));

    % Block program execution until the user closes the figure
    uiwait(fig);




% Callback function for button actions -----------------------------------
function buttonCallback(f, choice)
    global skipOverwrite_choice;
    skipOverwrite_choice = choice;
    uiresume(f); % Resume program execution
    delete(f);   % Close the figure




% --- Executes on button press in pushbuttonImputeAll. -------------------
function pushbuttonImputeAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonImputeAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
impute = data.EEG;
AddToListbox(data.listboxStdout, 'Replacing all channels with imputed version');
for ch=1:data.EEG.nbchan
    tmp = pop_interp(data.EEG, ch, 'spherical');
    impute.data(ch,:) = tmp.data(ch,:);
end

data.EEG = impute;

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Impute all channels';
guidata(hObject, data);


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(hObject);

AddToListbox(data.listboxStdout, '- removing first 1 second of data');

% as always, work on tmp in stead of data.EEG
tmp = pop_select(data.EEG, 'rmtime', [0 1]);


% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Remove first second';
data.EEG = tmp;
guidata(hObject, data);


% --- Executes on button press in pushbuttonMaskEvt.
function pushbuttonMaskEvt_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMaskEvt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

AddToListbox(data.listboxStdout, '- masking all events types to 0-255 (numeric or not)');

% as always, work on tmp in stead of data.EEG
tmp = data.EEG;
keep = true(1,length(tmp.event));
for e=1:length(tmp.event)
    ev = tmp.event(e).type;
    evclass = class(ev);
    if isnumeric(ev)
        if ev==round(ev)
            val = bitand(ev, 255);
            if val
                ev = val;
            else
                keep(e) = false;
            end
        end
    elseif ~isnan(str2double(ev))
        val = bitand(str2double(ev), 255);
        if val
            ev = num2str(bitand(str2double(ev), 255));
        else
            keep(e) = false;
        end
    end
    tmp.event(e).type = ev;
end

tmp.event = tmp.event(keep);


% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Massk events'' to first 8 bits';
data.EEG = tmp;
guidata(hObject, data);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbuttonReref.
function pushbuttonReref_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbuttonReref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function sliderAARWinSec_Callback(hObject, eventdata, handles)
% hObject    handle to sliderAARWinSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


data = guidata(hObject); 
data.textAARWinSec.String = sprintf('win %ds',round(get(hObject, "Value")));


% --- Executes during object creation, after setting all properties.
function sliderAARWinSec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderAARWinSec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderAARShift_Callback(hObject, eventdata, handles)
% hObject    handle to sliderAARShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject); 
data.textAARShift.String = sprintf('shift %.1fs',get(hObject, "Value"));


% --- Executes during object creation, after setting all properties.
function sliderAARShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderAARShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkboxFlatlineEpochs.
function checkboxFlatlineEpochs_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxFlatlineEpochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxFlatlineEpochs


% --- Executes on button press in pbViewPSD.
function pbViewPSD_Callback(hObject, eventdata, handles)
% hObject    handle to pbViewPSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
tmp = data.EEG;
chanlocs = tmp.chanlocs;

AddToListbox(data.listboxStdout, 'Plotting PSD');

lo = data.sliderLow.Value;
hi = data.sliderHigh.Value;

[P,fs] = calc_PSD(tmp);

% Create figure if needed, otherwise put the figure in front
if ~isfield(data, 'figPSD') || isempty(data.figPSD) || ~isstruct(data.figPSD) || ~isfield(data.figPSD, 'fig') || ~isvalid(data.figPSD.fig)
    AddToListbox(data.listboxStdout, '- creating figure');
    if ~isfield(data, 'figPSD')
        data.figPSD = struct;
    end
    fig = figure('Name', 'plot Power Spectrum', 'Tag', 'figPSD', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 700, 500]); % Adjust size as needed
    % Create a frame (uipanel), checkbox, and create axes inside the panel
    frame = uipanel('Parent', fig, 'Title', 'Power spectrum', 'Tag', 'framePSD', ...
                    'Position', [0.005, 0.1, .98, 0.9]); % [x, y, width, height]
    ax = axes('Parent', frame, 'Position', [0.07, 0.1, .91, 0.88], 'Tag', 'axesPSD'); % Adjust within panel
    checkbox = uicontrol('Style', 'checkbox', 'Parent', fig, 'Tag', 'cbSummary', ...
                         'String', 'Summarize into regions', 'Fontsize', data.fontsize, ...
                         'Units', 'normalized', ...
                         'Position', [0.05, 0.03, 0.4, 0.05], ...
                         'Callback', @(src, event) checkbox_callback(src, ax, fs, P, chanlocs, data.fontsize+1, lo, hi));
    data.figPSD.fig = fig;
    data.figPSD.ax = ax;
    data.figPSD.checkbox = checkbox;
    set(ax,'xlim',[0 min(hi,45)])
    
else
    AddToListbox(data.listboxStdout, '- activating figure');
    fig = data.figPSD.fig;
    ax = data.figPSD.ax;
    checkbox = data.figPSD.checkbox;
    figure(fig);
end

checkbox_callback(checkbox, ax, fs, P, chanlocs, data.fontsize+1, lo, hi);

guidata(hObject, data);


function [P,fs] = calc_PSD(EEG)

if size(EEG.data,3)>1
    win = ones(1,size(tmp.data,2));
    [P, fs] = pfft(EEG.data(:,:)', EEG.srate, win, 0);
else
    % windows with 
    win = hanning(EEG.srate*2);
    [P, fs] = pfft(EEG.data(:,:)', EEG.srate, win, .5);
end


% Callback function for checkbox
function checkbox_callback(hObject, ax, fs, P, chanlocs, fontsize, lo, hi)

    % hardcoded limits
    
    ndx = fs>lo & fs<hi;  
    
    % plot either all channels or a summary
    if get(hObject,'Value')==0
        plot(ax, fs(ndx), 10*log10(P(ndx,:)));
        legend({chanlocs.labels}, 'location','northeast')
    else
        numlabels = {'theta','radius','X','Y','Z','sph_theta','sph_phi','sph_radius'};
        tab = struct2table(chanlocs);
        % repair: convert cell array of double to double with missings
        for lab=1:length(numlabels)
            if ismember(numlabels{lab}, tab.Properties.VariableNames)
                if iscell(tab.(numlabels{lab}))
                    values = cellfun(@(x)ifthen(isempty(x), nan, double(x)), tab.(numlabels{lab}));
                    tab.(lab) = values;
                end
            end
        end
        
        relX = tab.X ./ sqrt(tab.X.^2+tab.Y.^2+tab.Z.^2);
        relY = tab.Y ./ sqrt(tab.X.^2+tab.Y.^2+tab.Z.^2);
        % relZ = tab.Z ./ sqrt(tab.X.^2+tab.Y.^2+tab.Z.^2);
        
        ant    = relX>=-1E-5;
        post   = ~ant;
        medial = abs(relY)<.41;
        left   = relY>=.41;
        right  = relY<=.41;
        
        regP = nan(size(P,1),6);
        regP(:,1) = mean(P(:,ant & left),2);
        regP(:,2) = mean(P(:,ant & medial),2);
        regP(:,3) = mean(P(:,ant & right),2);
        regP(:,4) = mean(P(:,post & left),2);
        regP(:,5) = mean(P(:,post & medial),2);
        regP(:,6) = mean(P(:,post & right),2);

        plot(ax, fs(ndx), 10*log10(regP(ndx,:)));
        legend('ant left','ant medial','ant right','post left','post medial','post right')
 
    end
    set(gca, 'fontsize', fontsize+2)
    xlabel('frequency (Hz)')
    ylabel('Power({\mu}V^2/Hz)')   

   


% --- Executes on button press in pbDFA.
function pbDFA_Callback(hObject, eventdata, handles)
% hObject    handle to pbDFA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(hObject);
tmp = data.EEG;

AddToListbox(data.listboxStdout, 'Plotting DFA of alpha oscillations');

lo = 7.5;
hi = 13;

exp = dfa(abs(hilbert(filter_fir(tmp.data(:,:), tmp.srate, lo, hi, 3.0, true)')), tmp.srate);


% Create figure if needed, otherwise put the figure in front
if ~isfield(data, 'figDFA') || isempty(data.figDFA) || ~isstruct(data.figDFA) || ~isfield(data.figDFA, 'fig') || ~isvalid(data.figDFA.fig)
    AddToListbox(data.listboxStdout, '- creating figure');
    if ~isfield(data, 'figDFA')
        data.figDFA = struct;
    end
    fig = figure('Name', 'plot DFA topoplot', 'Tag', 'figDFA', 'NumberTitle', 'off', ...
                 'Position', [50, 50, 300, 250]); % Adjust size as needed
    ax = axes('Parent', fig); 
    data.figDFA.fig = fig;
    data.figDFA.ax = ax;
    
else
    AddToListbox(data.listboxStdout, '- activating figure');
    fig = data.figDFA.fig;
    ax = data.figDFA.ax;
    figure(fig);
end

tmp.nbchan = size(tmp.data,1);
clf;
topoplot(exp, tmp.chanlocs, 'maplimits', [.5 .8]);
colorbar;

guidata(hObject, data);


% --- Executes on button press in pushbuttonFlatPeriod.
function pushbuttonFlatPeriod_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFlatPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

AddToListbox(data.listboxStdout, 'Removing flatline periods based on Std and some heuristics.')
AddToListbox(data.listboxStdout, '* WARNING remove bad / non-eeg channels first.')
AddToListbox(data.listboxStdout, '- NOTE *eog* channels will be ignored.')
AddToListbox(data.listboxStdout, '- NOTE channels with no location info will be ignored')

tmp = data.EEG;

EOG = FindSetNdx({tmp.chanlocs.labels},'*eog*','match','pattern');
EEG = find(~cellfun(@isempty, {tmp.chanlocs.X}));
EEG = setdiff(EEG,EOG);

% get power spectra in chuncks of 200ms so as to get 5, 10, 15 ... Hz power
% in many epochs each of 200 ms. 
[~,fs, allP] = pfft(tmp.data(EEG,:)', tmp.srate, ones(1,tmp.srate/5), 0);
zz = log(squeeze(mean(allP(fs>8&fs<=20, :, :)))'); % log is to normalize
H = nan(size(zz));
H(:) = zz(:)<-3.5;


% len=10; 
% delta = nan(tmp.nbchan, tmp.pnts-len+1);
% for s=1:tmp.pnts-len+1
%     delta(:,s) = std(detrend(tmp.data(:,s:s+len-1)')); 
% end
% 
% mask = ((sum(delta<median(delta(:))/10))>tmp.nbchan/3);
% mask2=mask; 
% for s=1:length(mask)
%     if mask(s)
%         mask2(s-round(tmp.srate*.5):(s+len+4))=true; 
%     end
% end
% 
% row=0; 
% times=[];
% state=0; 
% for s=1:s(mask2) 
%     if mask2(s) && state==0
%         state=1; 
%         row=row+1; 
%         times(row,1)=s; 
%     elseif ~mask2(s) && state==1
%         state=0; 
%         times(row,2)=s-1; 
%     end
% end

row=0; 
times=[];
state=0; 
for s=1:size(H,1) 
    if any(H(s,:)) && state==0
        state = 1; 
        row = row+1; 
        times(row,1) = (s-1)*.2 - .2; % fixed! .2 depends on pfft call! 
    elseif ~any(H(s,:)) && state==1
        state = 0; 
        times(row,2) = (s-1)*.2 + .2; 
    end
end
if state==1 && times(row,2) == 0
    times(row,2) = tmp.xmax;
end

% merge lines if period inbetween to-be-removed chunks <1s
for row=1:size(times,1)-1
    if times(row+1,1)<=times(row,2)+1
        times(row+1,1) = times(row+1,1)-1;
    end
end
        

% output result and apply
AddToListbox(data.listboxStdout, sprintf('- Removing %d periods', size(times,1)))
tmp = pop_select(tmp, 'notime', times);

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Clear flatline periods';
data.EEG = tmp;

guidata(hObject, data)


% --- Executes on button press in pushbuttonAltAAR.
function pushbuttonAltAAR_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAltAAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

set(hObject,'backgroundcolor',[.3 .6 .3])
pause(0.005);

tmp = data.EEG;
[~,~,~,~,~,int_data] = InterpolationCleaning(tmp);

len = tmp.srate*5;
startpnts = 1:len:(tmp.pnts-len+1);
Forig = nan(len,tmp.nbchan,length(startpnts));
Fint  = Forig;
Fnew  = Forig;
fft_fs = linspace(0,tmp.srate,len);
fft_fs = fft_fs(1:end-1);
    
Porig = nan(tmp.srate/2+1,tmp.nbchan,length(startpnts));
Pint  = Porig;
cnt = 0;
for start=startpnts
    cnt=cnt+1;
    Forig(:,:,cnt) = fft(tmp.data(:, start:start+len-1)');
    Fint(:,:,cnt)  = fft(int_data(:, start:start+len-1)');
    [Porig(:,:,cnt), ~] = pfft(tmp.data(:, start:start+len-1)', tmp.srate, ones(1,tmp.srate), 0);
    [Pint(:,:,cnt), fs] = pfft(int_data(:, start:start+len-1)', tmp.srate, ones(1,tmp.srate), 0);
    
    % determine upward slope for original signal in high freq region. NOTE
    % negative tstat means more power in uncleaned data.
    ndx = fs>13&fs<35;
    [~,~,~,reg] = ttest(db(Pint(ndx,:,1)),db(Porig(ndx,:,1)));
    select = reg.tstat < -data.sliderTstat.Value;
    
    % assume all data is good. data_new is ordered in rows!
    data_new(:,:,cnt) = tmp.data(:, start:start+len-1);
    
    Fnew(:,:,cnt) = Forig(:,:,cnt);
    if sum(select)
        % create a linspace from 0 to one from 13 to 35 hertz FOR FFT.
        weight = zeros(1, len);
        weight(fft_fs>=35) = 1;
        weight(fft_fs>=13 & fft_fs<=35) = linspace(0,1,sum(fft_fs>=13 & fft_fs<=35));
        % duplicate around center
        weight = [weight(1:end/2) 1 weight(end/2:-1:2)];

        Fnew(:,select,cnt) = Forig(:,select,cnt) .* repmat((1-weight)',1, sum(select)) + Fint(:,select,cnt) .* repmat(weight', 1, sum(select));
        data_new(select,:,cnt) = ifft(Fnew(:,select,cnt))';
    end
end

tmp.data = data_new(:,:);
tmp.pnts = size(tmp.data,2);
tmp.xmax = (tmp.pnts-1)/tmp.srate;

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Alternate EMG cleaning';
data.EEG = tmp;

set(hObject,'backgroundcolor',[.9 .8 .6])

guidata(hObject, data)


% --- Executes on slider movement.
function sliderTstat_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTstat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

data = guidata(hObject);

data.textTstat.String = sprintf('%.1f', get(hObject,'Value'));




% --- Executes during object creation, after setting all properties.
function sliderTstat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderTstat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkboxCorrectNK.
function checkboxCorrectNK_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxCorrectNK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxCorrectNK


% --- Executes on button press in pushbuttonReview.
function pushbuttonReview_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

if ~isfield(data,'EEG') || isempty(data.EEG.data)
    msgbox('No data available');
    data.pbView.BackgroundColor = [1 .6 .6];
    return
end

setappdata(0, 'myGuiObj', hObject);

pop_eegplot(data.EEG, 1, 1, 0, [], 'title', 'Scroll EEG', ...
    'command', 'h=getappdata(0, ''myGuiObj''); TMPREJ, data=guidata(h); disp(data.EEG), data.EEG = eeg_eegrej(data.EEG, TMPREJ); guidata(h, data);');


% --- Executes on button press in pushbuttonMemoryBack.
function pushbuttonMemoryBack_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMemoryBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

global GlobEEG

data.EEG = GlobEEG;

guidata(hObject, data);


% --- Executes on button press in pushbuttonRemoveEOG.
function pushbuttonRemoveEOG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRemoveEOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

tmp = data.EEG;

ndx = contains({tmp.chanlocs.labels}, 'eog', 'IgnoreCase', true);
if sum(ndx)
    tmp = pop_select(tmp, 'nochannel', find(ndx));
end
if data.popupmenuReref.Value && strcmpi(data.popupmenuReref.String{data.popupmenuReref.Value}, 'Average')
    AddToListbox(data.listboxStdout, sprintf('- redo avg reference'))
    tmp = pop_reref(tmp, []);
end

% push existing data onto stack. Update <data.EEG> to tmp.
data.Stack{length(data.Stack)+1} = data.EEG;
data.StackLabel{length(data.Stack)+1} = 'Remove EOG';
data.EEG = tmp;

guidata(hObject, data)
