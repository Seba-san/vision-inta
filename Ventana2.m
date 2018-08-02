function varargout = Ventana2(varargin)
% VENTANA2 MATLAB code for Ventana2.fig
%      VENTANA2, by itself, creates a new VENTANA2 or raises the existing
%      singleton*.
%
%      H = VENTANA2 returns the handle to a new VENTANA2 or the handle to
%      the existing singleton*.
%
%      VENTANA2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VENTANA2.M with the given input arguments.
%
%      VENTANA2('Property','Value',...) creates a new VENTANA2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Ventana2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Ventana2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Ventana2

% Last Modified by GUIDE v2.5 21-Jul-2017 21:56:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Ventana2_OpeningFcn, ...
                   'gui_OutputFcn',  @Ventana2_OutputFcn, ...
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


% --- Executes just before Ventana2 is made visible.
function Ventana2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Ventana2 (see VARARGIN)

% Choose default command line output for Ventana2
addpath('C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
Frame=51;
handles.output = hObject;
handles.Ventana=[140 95];% Alto ancho
handles.Solapamiento=[130 90];% en vertical, en horizontal
handles.Data=varargin;
axes(handles.axes1)
Ventana=handles.Ventana;
Solapamiento=handles.Solapamiento;
I1=readimage(handles.Data{1}{1},Frame);
I2=readimage(handles.Data{1}{1},Frame+1); 
imshow(I2)
handles.bbox=FunPira(I2,Ventana,Solapamiento); 
[handles.I,a,outs]=FunProf(I1,I2,handles.Data{1}{4});

b=a;
S=size(a);
for k=1:S(1)
    for j=1:S(2)
        if (a(k,j)<0 || a(k,j)>4000 )
            b(k,j)=0;  % Recorto alturas negativas y mayores a 4m (supongo que 1000 es 1 metro)
        end
    end
end
handles.b=b;
handles.I2=I2;
%handles.Data{1}{1}
%set(handles.edit1,'String',handles.Data{1}{1})
%handles.Data

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Ventana2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Ventana2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double





% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I2=handles.I2;b=handles.b;I=handles.I;Ventana=handles.Ventana;bbox=handles.bbox;
[x,y]=ginput(1); Punto=[x,y];
[indice]=Buscbbox(Punto,bbox,handles.Ventana);
Ss=size(indice);
Ici=zeros(Ventana(1)+1,Ventana(2)+1,Ss(2));
Icd=zeros(Ventana(1)+1,Ventana(2)+1,Ss(2));Ica=Icd;
 for i=1:Ss(2)
Ii = imresize(I2,bbox(indice(i),5));
Id=imresize(I,bbox(indice(i),5));
Ia=imresize(b,bbox(indice(i),5));
Ici(:,:,i) = rgb2gray(imcrop(Ii,bbox(indice(i),1:4)));
Icd(:,:,i) =imcrop(Id,bbox(indice(i),1:4));
Ica(:,:,i) = imcrop(Ia,bbox(indice(i),1:4));
% imwrite(Ici,sprintf('%s%d_%d.jpg',Pos,FRAME,indice(i)))
% save(sprintf('%s%d_%d.mat',Pos,FRAME,indice(i)),'Icd','Ica')
 end
 x=1:1:Ss(2);
 %set(handles.slider1,'String',x);
 set(handles.popupmenu1,'String',x);
 handles.Ici=Ici;handles.Icd=Icd;handles.Ica=Ica;
 guidata(hObject, handles);
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%a=get(handles.slider1,'Value')
% axes(handles.axes2)
% imshow(handles.Ici(:,:,:,a))
% axes(handles.axes3)
% imagesc(handles.Icd(:,:,a),[3000 7000]);colormap jet;colorbar; 
% axes(handles.axes4)
% imagesc(handles.Ica(:,:,a),[0 4000]); colormap jet;colorbar;



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
a=get(handles.popupmenu1,'Value');
axes(handles.axes2)
imshow(handles.Ici(:,:,a))
axes(handles.axes3)
imagesc(handles.Icd(:,:,a),[3000 7000]);colormap jet;%colorbar; 
axes(handles.axes4)
imagesc(handles.Ica(:,:,a),[0 4000]); colormap jet;%colorbar;

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
