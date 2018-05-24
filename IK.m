function varargout = IK(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IK_OpeningFcn, ...
                   'gui_OutputFcn',  @IK_OutputFcn, ...
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

function IK_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;


guidata(hObject, handles);

jinit=[90;60;-120];
assignin('base','jinit',jinit); 
assignin('base','jstart',jinit); 
axes(handles.axes1);
FKdraw(jinit(1,1),jinit(2,1),jinit(3,1));
ax_properties = get(gca);
assignin('base','pov',ax_properties.View);
FK=evalin('base','FK');
pos_start=[FK(1,16);FK(2,16);FK(3,16)];
pos_target=[FK(1,16);FK(2,16);FK(3,16)];
assignin('base','pos_start',pos_start);
assignin('base','pos_target',pos_target);


function varargout = IK_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;



function slider1_Callback(hObject, eventdata, handles)
val2=str2num(get(handles.text5,'String'));
val3=str2num(get(handles.text6,'String'));
val1 = get(hObject,'Value') ;
val=[val1;val2;val3];
assignin('base','pos_target',val);
set( handles.text4,'String', num2str(val1,3) );
axes(handles.axes1);



function slider1_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function slider2_Callback(hObject, eventdata, handles)
val1=str2num(get(handles.text4,'String'));
val3=str2num(get(handles.text6,'String'));
val2 = get(hObject,'Value') ;
val=[val1;val2;val3];
assignin('base','pos_target',val);
set( handles.text5,'String', num2str(val2,3) );
axes(handles.axes1);




function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function slider3_Callback(hObject, eventdata, handles)
val1=str2num(get(handles.text4,'String'));
val2=str2num(get(handles.text5,'String'));
val3 = get(hObject,'Value') ;
val=[val1;val2;val3];
assignin('base','pos_target',val);
set( handles.text6,'String', num2str(val3,3) );
axes(handles.axes1);




function slider3_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function Reset_Callback(hObject, eventdata, handles)
axes(handles.axes1);
jinit=evalin('base','jinit');
assignin('base','jstart',jinit); 
FKdraw(jinit(1,1),jinit(2,1),jinit(3,1));
FK=evalin('base','FK');
set( handles.text4,'String', num2str(0));
set( handles.text5,'String', num2str(12));
set( handles.text6,'String', num2str(2));
set(handles.slider1, 'value', 0);
set(handles.slider2, 'value', 12);
set(handles.slider3, 'value', 2);
assignin('base','movement',0);




function inversebutton_Callback(hObject, eventdata, handles)
pos_start=evalin('base','pos_start');
pos_target=evalin('base','pos_target');
jstart=evalin('base','jstart');
j1=jstart(1,1);
j2=jstart(2,1);
j3=jstart(3,1);
if pos_target==pos_start
   errordlg('Set target position first','No Movement'); 
   movement=0;
   assignin('base','movement',movement);
else
   movement=1;
   assignin('base','movement',movement);
   delta=divelo(pos_start,pos_target);
end

while evalin('base','movement')==1
FK=evalin('base','FK');
Jac=Jacobian(FK);
Jacinv=pinv(Jac);
dXYZ=delta(1:3,1)/10;  
dTheta=Jacinv*dXYZ;
dTheta1=radtodeg(dTheta(1,1));
dTheta2=radtodeg(dTheta(2,1));
dTheta3=radtodeg(dTheta(3,1));
j1=j1+dTheta1;
j2=j2+dTheta2;
j3=j3+dTheta3;
FKdraw(j1,j2,j3)
pos_new=[FK(1,16);FK(2,16);FK(3,16)];
delta=divelo(pos_new,pos_target);
EucError=delta(5,1)^2;
OrinError=delta(6,1)^2;
set( handles.textEucE,'String', num2str(EucError,3));

if EucError <10^-2
   movement=0; 
   assignin('base','movement',movement);
   assignin('base','pos_start',pos_new);
   jstart=[j1;j2;j3];
   assignin('base','jstart',jstart);
end 

if all(delta(:) <= 0.1)
   movement=0; 
   assignin('base','movement',movement);
   assignin('base','pos_start',pos_new);
   assignin('base','jstart',jstart);
end 

    


end
