function varargout = omnispect(varargin)
% OMNISPECT MATLAB code for omnispect.fig
%      OMNISPECT, by itself, creates a new OMNISPECT or raises the existing
%      singleton*.
%
%      H = OMNISPECT returns the handle to a new OMNISPECT or the handle to
%      the existing singleton*.
%
%      OMNISPECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OMNISPECT.M with the given input arguments.
%
%      OMNISPECT('Property','Value',...) creates a new OMNISPECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before omnispect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to omnispect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help omnispect

% Last Modified by GUIDE v2.5 15-Oct-2012 11:40:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @omnispect_OpeningFcn, ...
                   'gui_OutputFcn',  @omnispect_OutputFcn, ...
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


% --- Executes just before omnispect is made visible.
function omnispect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to omnispect (see VARARGIN)

% Choose default command line output for omnispect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.formatgroup, 'SelectedObject', handles.radio_CDF);
set(handles.edit_File1,'String','Enter CDF file.');
set(handles.edit_File2,'String','Enter time file.');
set(handles.edit_File3,'String','Enter position file.');
set(handles.edit_nmf,'String','1');
set(handles.edit_mz1,'String','0');
set(handles.edit_mz2,'String','-1');
set(handles.edit_mz3,'String','-1');
set(handles.edit_pm1,'String','1');
set(handles.edit_pm2,'String','1');
set(handles.edit_pm3,'String','1');
handles.figs=[];
% Update handles structure
guidata(handles.figure1, handles);

% UIWAIT makes omnispect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = omnispect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2



function edit_File1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_File1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_File1 as text
%        str2double(get(hObject,'String')) returns contents of edit_File1 as a double


% --- Executes during object creation, after setting all properties.
function edit_File1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_File1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_File2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_File2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_File2 as text
%        str2double(get(hObject,'String')) returns contents of edit_File2 as a double


% --- Executes during object creation, after setting all properties.
function edit_File2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_File2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_File3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_File3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_File3 as text
%        str2double(get(hObject,'String')) returns contents of edit_File3 as a double


% --- Executes during object creation, after setting all properties.
function edit_File3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_File3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_File1.
function pushbutton_File1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_File1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(get(handles.formatgroup,'SelectedObject'),'Tag'),
    case 'radio_CDF'
        [filename,pathname]=uigetfile('*.cdf','Pick CDF file');
    case 'radio_mzXML'
        [filename,pathname]=uigetfile('*.mzXML;*.mzxml','Pick mzXML file');
    case 'radio_Analyze75'
        [filename,pathname]=uigetfile('*.hdr','Pick Header file');
    case 'radio_imzML'
        [filename,pathname]=uigetfile('*.imzML;*.imzml','Pick imzML file');
    otherwise
        filename='';
        pathname='';
end;
set(handles.edit_File1,'String',[pathname filename]);

% --- Executes on button press in pushbutton_File2.
function pushbutton_File2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_File2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(get(handles.formatgroup,'SelectedObject'),'Tag'),
    case {'radio_CDF', 'radio_mzXML'}
        [filename,pathname]=uigetfile('*.time','Pick Time file');
    case 'radio_Analyze75'
        [filename,pathname]=uigetfile('*.img','Pick Image file');
    case 'radio_imzML'
        [filename,pathname]=uigetfile('*.ibd','Pick ibd file');
    otherwise
        filename='';
        pathname='';
end;
set(handles.edit_File2,'String',[pathname filename]);

% --- Executes on button press in pushbutton_File3.
function pushbutton_File3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_File3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(get(handles.formatgroup,'SelectedObject'),'Tag'),
    case {'radio_CDF', 'radio_mzXML'}
        [filename,pathname]=uigetfile('*.pos','Pick Position file');
    case 'radio_Analyze75'
        [filename,pathname]=uigetfile('*.t2m','Pick T2M file');
    otherwise
        filename='';
        pathname='';
end;
set(handles.edit_File3,'String',[pathname filename]);

% --- Executes when selected object is changed in formatgroup.
function formatgroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in formatgroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag')
    case 'radio_CDF'
        set(handles.edit_File1,'String','Enter CDF file.');
        set(handles.edit_File2,'String','Enter time file.');
        set(handles.edit_File3,'String','Enter position file.');
    case 'radio_mzXML'
        set(handles.edit_File1,'String','Enter mzXML file.');
        set(handles.edit_File2,'String','Enter time file.');
        set(handles.edit_File3,'String','Enter position file.');        
    case 'radio_Analyze75'
        set(handles.edit_File1,'String','Enter HDR file.');
        set(handles.edit_File2,'String','Enter IMG file.');
        set(handles.edit_File3,'String','Enter T2M file.');        
    case 'radio_imzML'
        set(handles.edit_File1,'String','Enter imzML file.');
        set(handles.edit_File2,'String','Enter IBD file.');
        set(handles.edit_File3,'String','');                
    otherwise
end;



function edit_mz1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mz1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mz1 as text
%        str2double(get(hObject,'String')) returns contents of edit_mz1 as a double


% --- Executes during object creation, after setting all properties.
function edit_mz1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mz1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mz2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mz2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mz2 as text
%        str2double(get(hObject,'String')) returns contents of edit_mz2 as a double


% --- Executes during object creation, after setting all properties.
function edit_mz2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mz2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mz3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mz3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mz3 as text
%        str2double(get(hObject,'String')) returns contents of edit_mz3 as a double


% --- Executes during object creation, after setting all properties.
function edit_mz3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mz3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pm1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pm1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pm1 as text
%        str2double(get(hObject,'String')) returns contents of edit_pm1 as a double


% --- Executes during object creation, after setting all properties.
function edit_pm1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pm1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pm2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pm2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pm2 as text
%        str2double(get(hObject,'String')) returns contents of edit_pm2 as a double


% --- Executes during object creation, after setting all properties.
function edit_pm2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pm2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pm3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pm3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pm3 as text
%        str2double(get(hObject,'String')) returns contents of edit_pm3 as a double


% --- Executes during object creation, after setting all properties.
function edit_pm3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pm3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_ion.
function pushbutton_ion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=1:length(handles.figs),
    try
        close(handles.figs(i)); 
    catch
    end;
end;
handles.figs=[]; guidata(handles.figure1,handles);

handles=loadData(handles);

mz1=sscanf(get(handles.edit_mz1,'String'),'%f');
mz2=sscanf(get(handles.edit_mz2,'String'),'%f');
mz3=sscanf(get(handles.edit_mz3,'String'),'%f');
pm1=sscanf(get(handles.edit_pm1,'String'),'%f');
pm2=sscanf(get(handles.edit_pm2,'String'),'%f');
pm3=sscanf(get(handles.edit_pm3,'String'),'%f');
target=handles.target;
cube_file = [target '_cube.mat'];
wh=msgbox('Please wait for ion visualization...','modal');
mz=[mz1,mz2,mz3];
pm=[pm1,pm2,pm3];
fig_files={};
for i=1:3,
	if mz(i)>=0,
		fig_files{end+1} = sprintf('%s_mz%08.1f_pm%05.1f',target,mz(i),pm(i));
	end;
end;
sum_image = sprintf('%s_mz%08.1f-%08.1f-%08.1f-_pm%05.1f-%05.1f-%05.1f-_sum',...
			target,mz(1),mz(2),mz(3),pm(1),pm(2),pm(3));
composite_image = sprintf('%s_mz%08.1f-%08.1f-%08.1f-_pm%05.1f-%05.1f-%05.1f-_sum',...
			target,mz(1),mz(2),mz(3),pm(1),pm(2),pm(3));

h=analyze_Individual(cube_file,[mz1,mz2,mz3],[pm1,pm2,pm3],fig_files,sum_image,composite_image);
try close(wh); end;
handles.figs=h;
guidata(handles.figure1,handles);

function edit_nmf_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nmf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_nmf as text
%        str2double(get(hObject,'String')) returns contents of edit_nmf as a double


% --- Executes during object creation, after setting all properties.
function edit_nmf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nmf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_nmf.
function pushbutton_nmf_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_nmf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=1:length(handles.figs),
    try
        close(handles.figs(i)); 
    end;
end;
handles.figs=[]; guidata(handles.figure1,handles);
handles=loadData(handles);
target=handles.target;
cube_file=[target '_cube.mat'];
noc=str2num(get(handles.edit_nmf,'String'));
k=1;
for i=1:noc, 
	fig_files{k} = sprintf('%s_nmf%d-%d_img',target,noc,i); k=k+1;
	fig_files{k} = sprintf('%s_nmf%d-%d_spec',target,noc,i); k=k+1;
end;

wh=msgbox('Please wait for NMF...','modal');
h=analyze_NMF(cube_file,noc,fig_files);
try close(wh); end;
handles.figs=h;
guidata(handles.figure1,handles);

% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object deletion, before destroying properties.
function uipanel1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if numel(handles)>0,
for i=1:length(handles.figs),
    try
        close(handles.figs(i)); 
    end;
end;
end;
function handles=loadData(handles)
steps=1;
h=waitbar(0,'','Name','Load Data...');
switch get(get(handles.formatgroup,'SelectedObject'),'Tag'),
    case 'radio_CDF'
        cdffile=get(handles.edit_File1,'String');
        timefile=get(handles.edit_File2,'String');
        posfile=get(handles.edit_File3,'String');
        target=cdffile(1:end-4);
        matfile=[target '.mat'];
        cubefile=[target '_cube.mat'];
        steps=3;
        step=0;
        waitbar(step/steps,h,'Converting CDF to MAT','Name','Load Data...');
            
        if ~exist(matfile,'file'),
            cdf2mat(cdffile,matfile);
        end;
        step=step+1;
        waitbar(step/steps,h,'Converting MAT to Cube','Name','Load Data...');
        if ~exist(cubefile,'file')
            makeImageCube(target,posfile,timefile,cubefile);
        end;
    case 'radio_mzXML'
        xmlfile=get(handles.edit_File1,'String');
        timefile=get(handles.edit_File2,'String');
        posfile=get(handles.edit_File3,'String');
        target=xmlfile(1:end-6);
        matfile=[target '.mat'];
        cubefile=[target '_cube.mat'];

        steps=3;
        step=0;
        waitbar(step/steps,h,'Converting mzXML to MAT','Name','Load Data...');
        
        if ~exist(matfile,'file'),
            xml2mat(xmlfile,matfile);
        end;
        step=step+1;
        waitbar(step/steps,h,'Converting MAT to Cube','Name','Load Data...');
        if ~exist(cubefile,'file')
            makeImageCube(target,posfile,timefile,cubefile);
        end;
    case 'radio_Analyze75'
	hdr_file=get(handles.edit_File1,'String');
	img_file=get(handles.edit_File2,'String');
        t2m_file=get(handles.edit_File3,'String');
        target=t2m_file(1:end-4);
        cube_file=[target '_cube.mat'];
	rawimage_file = [target '_rawimage.png'];
        steps=2;
        step=0;
        waitbar(step/steps,h,'Converting Analyze 7.5 to Cube','Name','Load Data...');
        if ~exist(cube_file,'file');
            load_Analyze_7_5_image_cube(t2m_file,[],hdr_file,img_file,[],cube_file,rawimage_file);
        end;
    case 'radio_imzML'
        imzML_file=get(handles.edit_File1,'String');
        ibd_file=get(handles.edit_File2,'String');
        target=imzML_file(1:end-6);
        cube_file=[target '_cube.mat'];
	rawimage_file = [target '_rawimage.png'];
        steps=2;
        step=0;
        waitbar(step/steps,h,'Converting imzML to Cube','Name','Load Data...');
        if ~exist(cube_file,'file');
            load_imzML_image_cube(imzML_file,ibd_file,[],cube_file,rawimage_file);
        end;
    otherwise
end;
step=step+1;
waitbar(step/steps,h,'Generating Raw Image (PNG)','Name','Load Data...');
rawimagefile=[target '_rawimage.png'];
if ~exist(rawimagefile,'file'),
    cube_file = [target '_cube.mat'];
    makeRawImage(cube_file,rawimagefile);
end;
step=step+1;
waitbar(step/steps,h,'Done!','Name','Load Data...');
pause(0.5);
close(h);
handles.target = target;
guidata(handles.figure1, handles);
disp('Data loaded');


% --- Executes on button press in pushbutton_test.
function pushbutton_test_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set up test cases
set(handles.edit_nmf,'String','2');
set(handles.edit_mz1,'String','0');
set(handles.edit_mz2,'String','300');
set(handles.edit_mz3,'String','600');
set(handles.edit_pm1,'String','1');
set(handles.edit_pm2,'String','1');
set(handles.edit_pm3,'String','1');

p='./upload/';
d=dir(p);
for i=84:length(d),
    if d(i).name(1) == '.', continue; end;
    go=1;
    if d(i).isdir,
        target=[p d(i).name '/' d(i).name];
        if exist([target '.t2m']),
            set(handles.formatgroup, 'SelectedObject', handles.radio_Analyze75);
            set(handles.edit_File1,'String',[target '.hdr']);
            set(handles.edit_File2,'String',[target '.img']);
            set(handles.edit_File3,'String',[target '.t2m']);
        elseif exist([target '.mzXML']),
            set(handles.formatgroup, 'SelectedObject', handles.radio_mzXML);
            set(handles.edit_File1,'String',[target '.mzXML']);
            set(handles.edit_File2,'String',[target '.time']);
            set(handles.edit_File3,'String',[target '.pos']);
        elseif exist([target '.cdf'],'file'),
            set(handles.formatgroup, 'SelectedObject', handles.radio_CDF);
            set(handles.edit_File1,'String',[target '.cdf']);
            set(handles.edit_File2,'String',[target '.time']);
            set(handles.edit_File3,'String',[target '.pos']);
        else
            go=0;
        end;
    end;
    if go==1,
        pushbutton_nmf_Callback(hObject, eventdata, handles);
        handles=guidata(handles.figure1);
        pushbutton_ion_Callback(hObject, eventdata, handles);
        handles=guidata(handles.figure1);
    end;
end;
