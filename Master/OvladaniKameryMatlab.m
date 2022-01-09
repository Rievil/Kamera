
% h=CameraObserver('H:\Google drive\Škola\Mìøení\2020\Kamera\OptimalizaceSpousteni\');
obj=CameraObj;
%%
clear g;
list=gigecamlist;
IP=char(char(list.IPAddress(1)));
g = gigecam(IP);
%executeCommand(g, 'ColorTransformationResetToFactoryList')
g.ColorTransformationAuto='continuous';
g.AcquisitionFrameRateEnable = 'True';
g.AcquisitionFrameRate = 1;
g.ExposureTime = 50e+3;
g.PixelFormat='BGR8';
g.TriggerMode='off';
%%
test=table([],[],'VariableNames',{'Name','Time'});
test=[test; table("Find time",25,'VariableNames',{'Name','Time'})];
%%
figure('Name', 'My Custom Preview Window'); 

h=g.AutoFeatureHeight;
w=g.AutoFeatureWidth;

hImage = image(zeros(h , w, 3)); 

preview(g,hImage);
axis on;

grid on;
%axis image;

if w>h
    r=double(h)/double(w);
else
    r=double(w)/double(h);
end
ax=axis;
fig=gcf;
pbaspect([1 r 1]);
set(fig,'position',[417 272 1086 701]);
%%
delete(g);

%%
exp=[40e+3 45e+3 50e+3 55e+3 60e+3];

for i=1
    tic;
    %g.ExposureTime = 50e+3;
    img = snapshot(g);
    filename=['E:\Google Drive\Škola\Mìøení\2020\Kamera\MatlabAcq\img_' num2str(i) '.png'];
    imwrite(img,filename); 
    pause(1);
    toc
end
%%
imgshow(img)
%%

%%
%puštìní videa
%g.ExposureTime = 20000;
g.PixelFormat='BGR8';
%g.AcquisitionFrameRate=3;
%%
preview(g);
%%
closePreview(g);
%%
close(g);
%%
%poøízení snímku
g.ExposureTime = 40e+3;
g.PixelFormat='BGR8';
%%
img = snapshot(g);
imshow(img);
%%
filename='E:\Google Drive\Škola\Mìøení\2020\Kamera\MatlabAcq\img.png';
imwrite(img,filename);
%clear g;
%%
snapshot = getsnapshot(g);

% Display the frame in a figure window.
%imagesc(snapshot)
%%
vid = videoinput('gige', 1, 'BGR8');
src = getselectedsource(vid);
src.PacketDelay = 10;
snapshot = getsnapshot(vid);
%%
vid.FramesPerTrigger = 1;

triggerconfig(vid, 'manual');

src.AcquisitionFrameRateEnable = 'True';

src.AcquisitionStatusSelector = 'AcquisitionTriggerWait';
%
preview(vid);
start(vid);
trigger(vid);
snapshot = getsnapshot(vidobj);
stoppreview(vid);
stop(vid);
%%
vid = videoinput('gige', 1, 'BGR8');
src = getselectedsource(vid);

vid.SelectedSourceName = 'input1';
src_obj = getselectedsource(vid);
get(src_obj)
src.AcquisitionStatusSelector='AcquisitionActive';
%%
% vid.FramesPerTrigger = 1;
% vid.TriggerRepeat = 0;
% triggerconfig(vid, 'manual');
% src.TriggerMode = 'Off';
% 
% src.AcquisitionStatusSelector = 'AcquisitionTriggerWait';

% snapshot = getsnapshot(vid);
%%
