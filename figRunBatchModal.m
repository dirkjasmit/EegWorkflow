function varargout = figRunBatchModal(varargin)
% FIGRUNBATCHMODAL MATLAB code for figRunBatchModal.fig
%      FIGRUNBATCHMODAL, by itself, creates a new FIGRUNBATCHMODAL or raises the existing
%      singleton*.
%
%      H = FIGRUNBATCHMODAL returns the handle to a new FIGRUNBATCHMODAL or the handle to
%      the existing singleton*.
%
%      FIGRUNBATCHMODAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGRUNBATCHMODAL.M with the given input arguments.
%
%      FIGRUNBATCHMODAL('Property','Value',...) creates a new FIGRUNBATCHMODAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before figRunBatchModal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to figRunBatchModal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figRunBatchModal

% Last Modified by GUIDE v2.5 07-May-2025 15:56:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figRunBatchModal_OpeningFcn, ...
                   'gui_OutputFcn',  @figRunBatchModal_OutputFcn, ...
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


% --- Executes just before figRunBatchModal is made visible.
function figRunBatchModal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figRunBatchModal (see VARARGIN)

% Choose default command line output for figRunBatchModal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% parse the passed parameter
if length(varargin)<2
    error('Must supply handle to parent and INIDIR variable!')
end

% Get data of this window and the parent window to store the data back
% into. Varargin{1} holds the parent window hanlde
data = guidata(hObject);
data.Parent = varargin{1};
data.INIDIR = varargin{2};

% UIWAIT makes figRunBatchModal wait for user response (see UIRESUME)
% uiwait(handles.figure1);

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

% fill the path and file fields
data.pathname = data.editSelectFilePath.String;
data.filenames = {};
fid = fopen(sprintf('%s/.figRunBatch_Filenames.ini', data.INIDIR), 'r');
if fid>0
    tmp = fgetl(fid);
    while tmp~=-1
        data.filenames{end+1} = tmp;
        tmp = fgetl(fid);
    end
    fclose(fid);
end
% update the editbox with the numberof files in data.filenames. 
data.editSelectFileNum.String = sprintf('%d files', length(data.filenames));

% store the gui data
guidata(hObject, data)



% GETUICONTROLDATA strlist with the values in all uicontrols ------------
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
            case {'uipanel'}
                tmp = GetUIControlData(ch);
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
                    try
                        if isnumeric(strlist.val)
                            set(ch(c),'string', sprintf('%.4f', strlist.val(ndx)));
                        else
                            set(ch(c),'string', sprintf('%s', strlist.val{ndx}));
                        end
                    catch E
                        warning(sprintf('Set value failed for %s', get(ch(c),'tag')))
                    end
                end
                pause(0.005)
                
            case {'checkbox','popupmenu'}
                ndx = find(strcmpi(strlist.key, get(ch(c),'tag')));
                if length(ndx)==1
                    try
                        if isnumeric(strlist.val)
                            set(ch(c),'value', strlist.val(ndx));
                        else
                            set(ch(c),'value', str2num(strlist.val{ndx}));
                        end
                    catch E
                        warning(sprintf('Set value failed for %s', get(ch(c),'tag')))
                    end
                end
                pause(0.005);
                
            case {'slider'}
                ndx = find(strcmpi(strlist.key, get(ch(c),'tag')));
                if length(ndx)==1
                    try
                        if isnumeric(strlist.val)
                            set(ch(c),'value', strlist.val(ndx));
                        else
                            set(ch(c),'value', str2num(strlist.val{ndx}));
                        end
                    catch E
                        warning(sprintf('Set value failed for %s', get(ch(c),'tag')))
                    end
                end
                %ch(c).Callback(ch(c),[])
                pause(0.005);
        end
    end
end             




% --- Outputs from this function are returned to the command line.
function varargout = figRunBatchModal_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonStart.
function pushbuttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);
data_parent.batchpathname = data.pathname;
data_parent.batchfilenames = data.filenames;
% get the checkboxes ticked (1-14)
checked = [];
for cb=1:15
    if get(eval(sprintf('data.checkbox%d',cb)),'Value')
        checked = [checked cb];
    end
end
data_parent.batchchecked = checked;
    
% store the data
guidata(hObject, data);
guidata(data.Parent, data_parent);

% continue with the close of the figure
close(gcf);


% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);
data_parent = guidata(data.Parent);
% empty the batch files and path in parent. this will trigger the cancel
% upon close
data_parent.batchpathname = '';
data_parent.batchfilenames = {};
data_parent.batchchecked = [];
guidata(hObject, data);
guidata(data.Parent, data_parent);
pause(0.05)

% continue with the close of the figure
close(gcf);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in checkbox12.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in checkbox12.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12



function editSelectPath_Callback(hObject, eventdata, handles)
% hObject    handle to editSelectPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelectPath as text
%        str2double(get(hObject,'String')) returns contents of editSelectPath as a double


% --- Executes during object creation, after setting all properties.
function editSelectPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelectPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSelectFileNum_Callback(hObject, eventdata, handles)
% hObject    handle to editSelectFileNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelectFileNum as text
%        str2double(get(hObject,'String')) returns contents of editSelectFileNum as a double


% --- Executes during object creation, after setting all properties.
function editSelectFileNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelectFileNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSelectPath2_Callback(hObject, eventdata, handles)
% hObject    handle to editSelectPath2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelectPath2 as text
%        str2double(get(hObject,'String')) returns contents of editSelectPath2 as a double


% --- Executes during object creation, after setting all properties.
function editSelectPath2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelectPath2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSelectFileNum2_Callback(hObject, eventdata, handles)
% hObject    handle to editSelectFileNum2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelectFileNum2 as text
%        str2double(get(hObject,'String')) returns contents of editSelectFileNum2 as a double


% --- Executes during object creation, after setting all properties.
function editSelectFileNum2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelectFileNum2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSelect2.
function pushbuttonSelect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelect2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(hObject);

FilterSpec = {'*.*', 'All files'
    '*.bdf', 'Biosemi'
    '*.cnt', 'ANT Neuro / Neuroscan'
    '*.edf', 'European data format'
    '*.set', 'EEGLAB'
    '*.vhdr', 'BrainVision'
    };

defpathfilename = sprintf('%s/.figRunBatch_DefaultPath.ini', data.INIDIR);
fid = fopen(defpathfilename, 'r');
DefaultPath = '.';
if fid>0
    try
        DefaultPath = fgetl(fid);
        fclose(fid);
    catch
    end
end 

[filenames, pathname, FilterIndex] = uigetfile(FilterSpec,...
    'Select EEG files', DefaultPath, ...
    'multiselect', 'on');

% Check if the user selected files or canceled
if isequal(filenames, 0)
    disp('User canceled file selection.');
    return;
end

% Ensure filenames is a cell array (single selection returns a char)
if ischar(filenames)
    filenames = {filenames};
end

% save the path, also add to edit
fid = fopen(defpathfilename,'w');
if fid>0
    fprintf(fid,'%s',pathname);
    fclose(fid);
end
% save the filenames
fid = fopen(sprintf('%s/.figRunBatch_Filenames.ini', data.INIDIR), 'w');
if fid>0
    for f=1:length(filenames)
        fprintf(fid,'%s\n',filenames{f});
    end
    fclose(fid);
end


% save in struct and wait for next buttonpress
data.filenames = filenames;
data.pathname = pathname;

data.editSelectFilePath.String = pathname;
data.editSelectFileNum.String = sprintf('%d files', length(filenames));

guidata(hObject,data)

% end of function ---------------------------------------------------------


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(hObject);

% save all the settings
strlist = GetUIControlData(hObject);

% Save the data in the INI directory
if ~exist(data.INIDIR,'dir')
    mkdir(data.INIDIR)
end
writetable(strlist,sprintf('%s/%s.ini', data.INIDIR, get(hObject,'name')), 'delimiter','\t','filetype','text');



% remove the binica files in current directory
files = dir('binica*'); % Get all matching files
for f = 1:length(files)
    delete(fullfile(files(f).folder, files(f).name));
end


% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in checkbox12.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in checkbox1.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox8.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
function checkbox25_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox26_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox27_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in checkbox12.
function checkbox28_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in checkbox12.
function checkbox29_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in checkbox12.
function checkbox30_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in checkbox31.
function checkbox31_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox31



function editSelectFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to editSelectFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelectFilePath as text
%        str2double(get(hObject,'String')) returns contents of editSelectFilePath as a double


% --- Executes during object creation, after setting all properties.
function editSelectFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelectFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to editSelectFileNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelectFileNum as text
%        str2double(get(hObject,'String')) returns contents of editSelectFileNum as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelectFileNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSelect.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editMask_Callback(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMask as text
%        str2double(get(hObject,'String')) returns contents of editMask as a double


% --- Executes during object creation, after setting all properties.
function editMask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on editMask and none of its controls.
function editMask_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(eventdata.Key, 'return')
    data = guidata(hObject);
    try
        files = dir(sprintf('%s/%s', data.editSelectFilePath.String, data.editMask.String));
        data.editSelectFileNum.String = sprintf('%d', length(files));
        pause(.05)
        data.filenames = {files.name};
        guidata(hObject, data);
    catch
        data.editSelectFileNum.String = sprintf('%d', 0);
        pause(.05)
        data.filenames = {};
        guidata(hObject, data);        
    end
end



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over editMask.
function editMask_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to editMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
