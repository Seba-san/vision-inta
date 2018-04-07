% get access to the ZED camera
clear all; clc
zed = webcam('ZED')
img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Calibracion\image';

% set the desired resolution
zed.Resolution = zed.AvailableResolutions{1};
% get the image size
[height width channels] = size(snapshot(zed));
% Create Figure and wait for keyboard interruption to quit
% f = figure('keypressfcn','close','windowstyle','modal');
% ok = 1;
% loop over frames
BaseLine=120.647;
Foco=700;
Constante=BaseLine*Foco;
i=1;
while(1)
    %capture the current image
    img = snapshot(zed);
      
    % split the side by side image image into two images
    im_Left = img(:, 1 : width/2, :);
    im_Right = img(:, width/2 +1: width, :);
%      [I]=FunProf(im_Right,im_Left);
%   
%       
% 
%     figure (1);imagesc(I,[1300 3000]);colormap jet;colorbar;
%     title('Mapa de distancias "I"')
%     
    % display the left and right images
%     subplot(1,2,1);
%     imshow(im_Left);
%     title('Image Left');
%     subplot(1,2,2);
%     imshow(im_Right);
%     title('Image Right');
%       
%     drawnow; %this checks for interrupts
%     ok = ishandle(f); %does the figure still exist
imwrite(im_Right,sprintf('%s%dd.jpg',img_dir,i))
imwrite(im_Left,sprintf('%s%di.jpg',img_dir,i))
i=i+1
  pause(0.5)

end
  
% close the camera instance
clear cam