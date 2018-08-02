tic
I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image520i.jpg');
I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image520d.jpg');
disparityRange = [0 64];
disparityMap = disparity(rgb2gray(I1),rgb2gray(I2),'BlockSize',15,'DisparityRange',disparityRange,'Method','BlockMatching');
disparityMap1 = disparity(rgb2gray(I1),rgb2gray(I2),'BlockSize',15,'DisparityRange',disparityRange);%,'Method','BlockMatching');

%figure(1)
subplot(2,2,1)
imshow(disparityMap,disparityRange);
title('BlockMatching');
%colormap jet
colormap default
colorbar
%figure(2)
subplot(2,2,2)
imshow(disparityMap1,disparityRange);
title('SemiGlobal');
colormap hot
colorbar
toc
subplot(2,2,3)
imshow(I1)
subplot(2,2,4)
imshow(I2)
%%
disparityMap=disparity(rgb2gray(I1),rgb2gray(I2),'Method','SemiGlobal','BlockSize',9,'DisparityRange',[0 128],'ContrastThreshold',0.5);
disparityMap2=disparity(rgb2gray(I1),rgb2gray(I2),'Method','BlockMatching','BlockSize',9,'DisparityRange',[0 64],'ContrastThreshold',0.5,'TextureThreshold',0.05);

hfiltro=ones(3,3)/10;
filtrada=imfilter(disparityMap2,hfiltro);
figure(1)
imshow(disparityMap2)
figure(2)
imshow(filtrada)

