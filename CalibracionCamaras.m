% [LEFT_CAM_HD]
% fx=692.964
% fy=692.964
% cx=576.186
% cy=367.798
% k1=-0.182798
% k2=0.0277213
% 
% [RIGHT_CAM_HD]
% fx=698.848
% fy=698.848
% cx=737.995
% cy=361.795
% k1=-0.1634
% k2=0.0214219
% Pagina: https://www.stereolabs.com/developers/calib/?SN=2587


IntrinsicMatrixL = [692.964   0       0;
                      0     692.964  0;
                  576.186  367.798  1];
radialDistortionL = [-0.182798 0.0277213];
cameraParamsL = cameraParameters('IntrinsicMatrix',IntrinsicMatrixL,...
            'RadialDistortion',radialDistortionL);
        
IntrinsicMatrixR = [698.848   0       0;
                      0     698.848  0;
                  737.995  361.795  1];
radialDistortionR = [-0.1634 0.0214219];
cameraParamsR = cameraParameters('IntrinsicMatrix',IntrinsicMatrixR,...
            'RadialDistortion',radialDistortionR);
        
     %   Remove distortion from the image.
img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Calibracion\HD\image';
%img_dir= 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Dataset\CalibrandoAulaB\image';
FRAME1=80;
IL = imread(sprintf('%s%1di.jpg',img_dir,FRAME1));
IR = imread(sprintf('%s%1dd.jpg',img_dir,FRAME1));
figure(1); imshowpair(imresize(IL,1), imresize(IR,1), 'montage');
title('Imagenes estereo sin rectificar');
 IRc = undistortImage(IR,cameraParamsR);
 ILc = undistortImage(IL,cameraParamsL);
figure(2); imshowpair(imresize(ILc,1), imresize(IRc,1), 'montage');
title('Izq y Der rectificadas');
% Ojo que las siguientes instrucciones consumen bastante
J2 = undistortImage(IL,cameraParamsL,'OutputView','full');
figure; imshow(J2); title('Full Output View');
% [STEREO]
% CV_2K=-0.265461
% RX_2K=-0.0586351
% RZ_2K=0.042639
% BaseLine=120.647
% CV_FHD=-0.265461
% RX_FHD=-0.0586351
% RZ_FHD=0.042639
% CV_HD=-0.265461 
% RX_HD=-0.0586351 ROTACIONES 
% RZ_HD=0.042639 ROTACIONES 
% CV_RESOLUTION_VGA=-0.265461
% RX_RESOLUTION_VGA=-0.0586351
% RZ_RESOLUTION_VGA=0.042639
%----------------------------------------------
%lo nuevo:
Baseline=120;
CV_2K=0.00726642;
CV_FHD=0.00726642;
CV_HD=0.00726642;
CV_VGA=0.00726642;
RX_2K=-0.00474904;
RX_FHD=-0.00474904;
RX_HD=-0.00474904;
RX_VGA=-0.00474904;
RZ_2K=-0.00199802;
RZ_FHD=-0.00199802;
RZ_HD=-0.00199802;
RZ_VGA=-0.00199802;

R1=RX_HD;
R2=CV_HD;
R3=RZ_HD;
 
R1=-0.0586351; R2=-0.0265461; R3=0.042639;
R1=0;R2=0;R3=0;
rotationMatrix = rotationVectorToMatrix([R1 R2 R3]); % 123 puede ser
Ra = rotationVectorToMatrix([R1 0 0]); % 123 puede ser
Rb = rotationVectorToMatrix([0 R2 0]); % 123 puede ser
Rc = rotationVectorToMatrix([0 0 R3]); % 123 puede ser
R=Ra*Rb*Rc;
rotationMatrix = rotationVectorToMatrix([R1 R3 R2]); % 132
rotationMatrix = rotationVectorToMatrix([R3 R1 R2]); % 312
rotationMatrix = rotationVectorToMatrix([R2 R1 R3]); % 213
rotationMatrix = rotationVectorToMatrix([R3 R2 R1]); % 321 puede ser
rotationMatrix = rotationVectorToMatrix([R2 R3 R1]); % 231 puede ser




stereoParams = stereoParameters(cameraParamsR,cameraParamsL,rotationMatrix,[-120.647 0 0]);
  [ILc, IRc] = rectifyStereoImages(IL,IR,stereoParams); % OJO que recorta
imshow(stereoAnaglyph(IRc, ILc))
  imtool(cat(3,IRc(:,:,1),ILc(:,:,2:3)))

  figure(3); imshowpair(imresize(ILc,1), imresize(IRc,1), 'montage');
title('Izq y Der rectificadas');
imshow(stereoAnaglyph(IRc, ILc))



  %%  
% img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
% FRAME1=90;
% % Read in the stereo pair of images.
% IL = imread(sprintf('%s%1di.jpg',img_dir,FRAME1));
% IR = imread(sprintf('%s%1dd.jpg',img_dir,FRAME1));
%Rectify the images.
[ILc, IRc] = rectifyStereoImages(IL,IR,stereoParams);
%Compute the disparity.
DisparityRange=[0 64];
BlockSize=5;
DistanceThreshold=64;
disparityMap = disparity(rgb2gray(ILc), rgb2gray(IRc),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
figure (4);imagesc(disparityMap,DisparityRange);colormap jet;colorbar;%[0 80]
Constante=120.647*692.964;
I=Constante./disparityMap;
figure (4);imagesc(I,[0 6000]);colormap jet;colorbar;%[0 80]


figure(5)
imshow(cat(3,IRc(:,:,1),ILc(:,:,2:3)),'InitialMagnification',50);

imtool(cat(3,IR(:,:,1),IL(:,:,2:3)))


% disparityMap = disparity(rgb2gray(ILc), rgb2gray(IRc));
%disparityMap = disparity(rgb2gray(J1), rgb2gray(J2));
%figure
%imshow(disparityMap,[0,64],'InitialMagnification',50);
figure (1);imagesc(disparityMap,[0 320]);colormap jet;colorbar;%[0 80]
figure (1);imagesc(disparityMap);colormap jet;colorbar;%[0 80]

%Reconstruct the 3-D world coordinates of points corresponding to each pixel from the disparity map.

d=zeros(736,1287);
s=size(disparityMap);
d(1:s(1),1:s(2))=disparityMap;
dd=uint8(zeros(736,1287,3));
s=size(disparityMap);
dd(1:s(1),1:s(2),:)=ILc;
xyzPoints = reconstructScene(d,stereoParams);
%Segment out a person located between 3.2 and 3.7 meters away from the camera.

Z = xyzPoints(:,:,3);
imagesc(Z,[1000 6000])

mask = repmat(Z > 1300 & Z < 2000,[1,1,3]);
[ILca, IRca] = rectifyStereoImages(IL,IR,stereoParams);
dd(~mask) = 0;
imshow(dd,'InitialMagnification',50);



points3D = reconstructScene(d, stereoParams);

ptCloud = pointCloud(points3D, 'Color', dd);

% Create a streaming point cloud viewer
player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');

% Visualize the point cloud
view(player3D, ptCloud);


%%



d = procrustes(X,Y)

%%


blobs1 = detectSURFFeatures(rgb2gray(IRc), 'MetricThreshold', 2000);
blobs2 = detectSURFFeatures(rgb2gray(ILc), 'MetricThreshold', 2000);
[features1, validBlobs1] = extractFeatures(rgb2gray(IRc), blobs1);
[features2, validBlobs2] = extractFeatures(rgb2gray(ILc), blobs2);
indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', ...
  'MatchThreshold', 5);
matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);
figure(2);
showMatchedFeatures(IRc, ILc, matchedPoints1, matchedPoints2);


[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);

if status ~= 0 || isEpipoleInImage(fMatrix, size(IRc)) ...
  || isEpipoleInImage(fMatrix', size(ILc))
  error(['Either not enough matching points were found or '...
         'the epipoles are inside the images. You may need to '...
         'inspect and improve the quality of detected features ',...
         'and/or improve the quality of your images.']);
end

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

figure(1);
showMatchedFeatures(IRc, ILc, inlierPoints1, inlierPoints2);
legend('Inlier points in I1', 'Inlier points in I2');

[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
  inlierPoints1.Location, inlierPoints2.Location, size(ILc));
tform1 = projective2d(t1);
tform2 = projective2d(t2);
[I1Rect, I2Rect] = rectifyStereoImages(IRc, ILc, tform1, tform2);
figure(3);
imshow(stereoAnaglyph(I1Rect, I2Rect));
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');

%%
[a]=cvexRectifyImages(sprintf('%s%1di.jpg',img_dir,FRAME1), sprintf('%s%1dd.jpg',img_dir,FRAME1));
%%
camMatrixR = cameraMatrix(cameraParamsR,rotationMatrix,[-120.647  0 0]);
camMatrixL = cameraMatrix(cameraParamsL,rotationMatrix,[0 0 0]);

D=Constante/(677-576.186+630-737.995)
D2=Constante/(665+631-1314)
point3d = triangulate([677 371], [630 370], camMatrixR,camMatrixL);
distanceInMeters = norm(point3d)




%%
listFrame=[20 36 52 63 80 91 108 121 144 159];
img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Calibracion\HD\image';
%img_dir= 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Dataset\CalibrandoAulaB\image';
FRAME1=80;
P_distancia=zeros(1,175);
for i=1:numel(listFrame)
    IL = imread(sprintf('%s%1di.jpg',img_dir,listFrame(i)));
    IR = imread(sprintf('%s%1dd.jpg',img_dir,listFrame(i)));
%     IRc = undistortImage(IR,Camara.R);
%     ILc = undistortImage(IL,Camara.L);
    DisparityRange=[0 80];
    BlockSize=5;
    DistanceThreshold=80;
    I = disparity(rgb2gray(IL), rgb2gray(IR),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
%     figure (4);imagesc(I,DisparityRange);colormap jet;colorbar;%[0 80]
    [P_d,delta] = polyval(p,I,Ss,mu);
          P_distancia=1./P_d;   
    %     P_distancia(i)
    figure (4);imagesc(P_distancia,[0 700]);colormap jet;colorbar;%[0 80]
   
    %figure(4); imshow(I,DisparityRange)
%     la=1;
%     while(la)
%         [x,y]=ginput(1);
%         Pdisp=I(round(x),round(y));
%         if Pdisp>10
%             la=0;
%         end
%     end
%     [P_d,delta] = polyval(p,Pdisp,S,mu);
%     P_distancia=1/P_d
    pause()
    i
end
% Pdisp=48;
% [P_d,delta] = polyval(p,Pdisp,S,mu);
%      P_distancia=1/P_d

disp('listo')
k=find(P_distancia<700&P_distancia>90);
plot(P_distancia(k),'rx')
%%
Disparidad=[63 47 40.5 36.19 33.13 35.63 40.75 46.63 60.81];
Distancia=[205.9155 305.7292 396.1154 500 600 500 400 317.79 212.2824];

plot(Disparidad,1./Distancia,'rx')

[p,S,mu] = polyfit(Disparidad,1./Distancia,2);
hold on
x=1:1:70;
[y,delta] = polyval(p,x,S,mu);
plot(x,y)
hold off
S.normr

plot(Disparidad,Distancia,'rx')
hold on
y = polyval(p,x);
plot(x,1./y)
hold off

x = linspace(0,70);

save('Polinomio.mat','p','S','mu')
