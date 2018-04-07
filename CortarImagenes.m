clear all;close all;clc;
viewId = 2;
first_frame = viewId;
last_frame = 538;
img_dir      = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\image';
img_dir2     = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas\image';
img_dir3     = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas\image';

for viewId=first_frame:last_frame
    disp(['Frame n°: ' num2str(viewId)])
Irgb1 = imread(sprintf('%s%1d.jpg',img_dir,viewId));
s=size(Irgb1);
IrgbIzq=Irgb1(:,1:s(2)/2,:); 
IrgbDer=Irgb1(:,s(2)/2+1:s(2),:); 
imwrite(IrgbIzq,sprintf('%s%di.jpg',img_dir2,viewId))
imwrite(IrgbDer,sprintf('%s%dd.jpg',img_dir3,viewId))

end
%imwrite(IrgbDer,'image1d.jpg')
%imwrite(IrgbIzq,'image1d.jpg')