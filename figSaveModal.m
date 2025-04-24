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

% Last Modified by GUIDE v2.5 24-Apr-2025 13:59:18

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
if length(varargin)>4
    error('Too many parameters passed')
end

% get data object and start filling
data = guidata(hObject);

data.INIDIR = varargin{4};
if data.INIDIR(1)=='~'
    data.INIDIR = sprintf("%s%s", getenv('HOME'), data.INIDIR(2:end)); 
end

% set the values of the uicontrols, including the save path
try
    FN = sprintf('%s/%s.ini', data.INIDIR, get(hObject,'name'));
    opts = detectImportOptions(FN, 'TextType', 'string', 'filetype', 'text');
    opts.DataLines = [2 Inf];
    opts.VariableTypes(:) = {'string'};  % Force all columns to string
    strlist = readtable(FN, opts);
    SetUIControlData(hObject, strlist);
catch
    warning('Initialization file not found. Will be created on close.')
end

if length(varargin)==3
    fs = varargin{3};
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
                warning('Setting fontsize failed')
            end
        end
    end
end

% get the object data (object is the modal figure). Save the passed
% parameters (EEG struct and filename). Overrides the saved uitcontrol data
% for some uicontrols
data.EEG = varargin{1};

data.Filename = varargin{2};
[a,b,c]=fileparts(varargin{2});
data.textFilenameIn.String = [b c];


% get file string up to first _ or . or space and use that as prospective
% subject code
[pathstr, name, ext] = fileparts(data.Filename);
subj = strsplit(name, data.popupmenuDelimiter.String{data.popupmenuDelimiter.Value});
try
    data.editSubject.String = subj{data.popupmenuItemNumber.Value};    
catch
    data.editSubject.String = '';    
end

% store the data
guidata(hObject, data);

% update edit box
editSubject_Callback(hObject,eventdata,guidata(hObject));





% Helper function
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

% add PREFIX within () 
val = data.popupmenuPrefix.Value;
tmp = data.popupmenuPrefix.String{val};
if val~=1 && ~isempty(tmp)
    list = [list {tmp(strfind(tmp,'(')+1:strfind(tmp,')')-1)}];
end

% add PROJECT within ()
val = data.popupmenuProject.Value;
tmp = data.popupmenuProject.String{val};
if ~isempty(tmp)
    list = [list {tmp(strfind(tmp,'(')+1:strfind(tmp,')')-1)}];
end

% add SESSION
val = data.popupmenuSession.Value;
tmp = data.popupmenuSession.String{val};
if val~=1 && ~isempty(tmp)
    list = [list {tmp}];
end

% add TASK within ()
val = data.popupmenuTask.Value;
tmp = data.popupmenuTask.String{val};
if val~=1 && ~isempty(tmp)
    list = [list {tmp(strfind(tmp,'(')+1:strfind(tmp,')')-1)}];
end

% add SUBJECT
list = [list {data.editSubject.String}];

% add ROUND
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

% projectstrings.ini file should be stored next to the EegAutoFlow figures.
T = readtable('projectStrings.ini', "FileType", 'text', "delimiter", "\t");
set(hObject, 'String', T.ProjectName);


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

if isempty(data.editSubject.String)  ||  isempty(data.popupmenuProject.String)
    error('Subject and Project cannot be empty!')
end

pop_saveset(data.EEG, 'filename',data.FN, 'filepath',data.editPath.String, 'savemode','onefile');
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




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
pause(.05)




% --- Executes on selection change in popupmenuDelimiter.
function popupmenuDelimiter_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuDelimiter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuDelimiter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuDelimiter

data = guidata(hObject);

% get file string up to first _ or . or space and use that as prospective
% subject code
[pathstr, name, ext] = fileparts(data.Filename);
subj = strsplit(name, data.popupmenuDelimiter.String{data.popupmenuDelimiter.Value});
try
    data.editSubject.String = subj{data.popupmenuItemNumber.Value};    
catch
    data.editSubject.String = '';    
end

editSubject_Callback(hObject,eventdata,guidata(hObject));




% --- Executes during object creation, after setting all properties.
function popupmenuDelimiter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuDelimiter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuItemNumber.
function popupmenuItemNumber_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuItemNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuItemNumber contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuItemNumber

data = guidata(hObject);

% get file string up to first _ or . or space and use that as prospective
% subject code
[pathstr, name, ext] = fileparts(data.Filename);
subj = strsplit(name, data.popupmenuDelimiter.String{data.popupmenuDelimiter.Value});
try
    data.editSubject.String = subj{data.popupmenuItemNumber.Value};    
catch
    data.editSubject.String = '';    
end

editSubject_Callback(hObject,eventdata,guidata(hObject));



% --- Executes during object creation, after setting all properties.
function popupmenuItemNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuItemNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

data = guidata(hObject);

try
    strlist = GetUIControlData(hObject);
    writetable(strlist, sprintf('%s/%s.ini', data.INIDIR, get(hObject,'name')), 'delimiter','\t', 'filetype','text')
catch E
    warning('An error occured on closing');
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
                tmp2 = get(ch(c),'string');
                if iscell(tmp2)
                    tmp2 = tmp2{1};
                end
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


% --- Executes on selection change in popupmenuPrefix.
function popupmenuPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuPrefix contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuPrefix

editSubject_Callback(hObject,eventdata,guidata(hObject));



% --- Executes during object creation, after setting all properties.
function popupmenuPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPath_Callback(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPath as text
%        str2double(get(hObject,'String')) returns contents of editPath as a double


% --- Executes during object creation, after setting all properties.
function editPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonPath.
function pushbuttonPath_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(hObject);

origPath = data.editPath.String;
if iscell(origPath)
    origPath = origPath{1};
end

try
    if exist(origPath)==7
        % fall thru
    elseif exist(origPath) == 2
        % file, strip path from it
        origPath = fileparts(origPath);
    end
catch
    origPath = '';
end

str = uigetdir(origPath);

if ~isempty(str)
    data.editPath.String = str;
end

guidata(hObject, data);
