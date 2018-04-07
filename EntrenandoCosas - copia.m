% Load training and test data using |imageDatastore|.
%cd 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
cd 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab'
%addpath('C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
%syntheticDir   = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Candidatas';
%syntheticDir   ='C:\Users\seba\Dropbox\Filtradas_manual';
%syntheticDir   ='C:\Users\seba\Dropbox\Candidatas'; % Candidatas
%handwrittenDir = 'C:\Users\seba\Dropbox\Test\Test';% Test
syntheticDir   ='C:\Users\sebasan.SERVER1\Dropbox\DataComp';
%handwrittenDir = 'C:\Users\sebasan.SERVER1\Dropbox\Test';
% |imageDatastore| recursively scans the directory tree containing the
% images. Folder names are automatically used as labels for each image.
trainingSet = imageDatastore(syntheticDir,   'IncludeSubfolders', true, 'LabelSource', 'foldernames');
%testSet     = imageDatastore(handwrittenDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
countEachLabel(trainingSet)
% Loop over the trainingSet and extract HOG features from each image. A
% similar procedure will be used to extract features from the testSet.
img = readimage(trainingSet, 114);
%imshow(img)
%
% [featureVector,hogVisualization] = extractHOGFeatures(img,'CellSize',[16 16]);
% figure;
% imshow(img);
% hold on;
% plot(hogVisualization);
%
% Extract HOG features and HOG visualization
% [hog_2x2, vis2x2] = extractHOGFeatures(img,'CellSize',[2 2]);
% [hog_4x4, vis4x4] = extractHOGFeatures(img,'CellSize',[4 4]);%MUCHOS DESCRIPTORES
 [hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);
  %[hog_16x16, vis16x16] = extractHOGFeatures(img,'CellSize',[16 16]);
% % Show the original image
% figure;
% subplot(2,3,1:3); imshow(img);
% % Visualize the HOG features
% subplot(2,3,4);
% plot(vis2x2);
% title({'CellSize = [2 2]'; ['Length = ' num2str(length(hog_2x2))]});
% subplot(2,3,5);
% plot(vis4x4);
% title({'CellSize = [4 4]'; ['Length = ' num2str(length(hog_4x4))]});
% subplot(2,3,6);
% plot(vis8x8);
% title({'CellSize = [8 8]'; ['Length = ' num2str(length(hog_8x8))]});
%Seleccionar la que contenga bien detallada la info
% cellSize = [4 4]; % MUCHOS DESCRIPTORES
% hogFeatureSize = length(hog_4x4);
% cellSize = [16 16]; % 
% hogFeatureSize = length(hog_16x16);
cellSize = [8 8]; % 
hogFeatureSize = length(hog_8x8);

numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');
for i = 1:numImages
    %i=i+1;
    img = readimage(trainingSet, i);
   % imshow(img)
   % I=rgb2hsv(img);%imshow(I(:,:,1))
    %Bin=imbinarize(L,0); Bin = imfill(Bin,'holes');imshow(L)
    %img = rgb2gray(img);
    %img=(img(:,:,2)-0.39*img(:,:,1)-0.61*img(:,:,3));
    %imagesc(img)
   % pause(2)
    % Apply pre-processing steps
  % img = imbinarize(img);
 % I11=(1-I(:,:,3));
%   imagesc(I11)
%   pause()
%   [hog_8x8, vis8x8] = extractHOGFeatures(I11,'CellSize',[8 8]);
%   figure(2)
%  imagesc(I11)
%  hold on
%  plot(vis8x8)
%  hold off
     [trainingFeatures(i, :)] = extractHOGFeatures(img, 'CellSize', cellSize);
end
trainingLabels=trainingSet.Labels;
%[trainingFeatures, trainingLabels] = helperExtractHOGFeaturesFromImageSet(trainingSet, hogFeatureSize, cellSize);
TABLA=table(trainingFeatures,trainingLabels);
% Get labels for each image.
%trainingLabels = trainingSet.Labels;
% fitcecoc uses SVM learners and a 'One-vs-One' encoding scheme.
%classifier = fitcecoc(trainingFeatures, trainingLabels);
% Extract HOG features from the test set. The procedure is similar to what
% was shown earlier and is encapsulated as a helper function for brevity.
%[testFeatures, testLabels] = helperExtractHOGFeaturesFromImageSet(testSet, hogFeatureSize, cellSize);
% Make class predictions using the test features.
%[predictedLabels, score] = predict(classifier, testFeatures);
% Tabulate the results using a confusion matrix.
%confMat = confusionmat(testLabels, predictedLabels)
%helperDisplayConfusionMatrix(confMat)

%ENTRENAR={testFeatures, testLabels};


%%
classifier = fitcecoc(trainingFeatures, trainingLabels);
% Extract HOG features from the test set. The procedure is similar to what
% was shown earlier and is encapsulated as a helper function for brevity.
[testFeatures, testLabels] = helperExtractHOGFeaturesFromImageSet(testSet, hogFeatureSize, cellSize);
% Make class predictions using the test features.
[predictedLabels, score] = predict(classifier, testFeatures);
% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels)
%helperDisplayConfusionMatrix(confMat)
%%
% Clasificar imagenes para probar
load('Clasificador.mat')
cellSize = [8 8];
hogFeatureSize = 6336;
Test = 'C:\Users\seba\Dropbox\Test\Test'; % direccion a clasificar
%Neg_dir     = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Candidatas\Negativas\'; % Direccion de las Negativas
%Pos_dir     = 'C:\Users\seba\Dropbox\Positivas\';%Direccion de las Positivas
testSet     = imageDatastore(Test, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
[testFeatures, testLabels] = helperExtractHOGFeaturesFromImageSet(testSet, hogFeatureSize, cellSize);
[predictedLabels, score] = predict(classifier, testFeatures);
S=size(score);
Positivas=zeros(1,S(1));
for i=1:S(1)
   if abs(score(i,1))> abs(score(i,2))
       Positivas(i)=abs(score(i,1));
       %I=readimage(testSet,i);
       %imwrite(I,sprintf('%s%d.jpg',Pos_dir,i))
   end
end
save('indicepos','Positivas')
plot(Positivas)

%%
load('indicepos.mat')
plot(Positivas)
%%
save('Clasificadores','trainedClassifier1','trainedClassifier2','trainedClassifier3')
save('LinearSVM','SVMClassifier')
save('LinearSVMPCA','SVMPCA')
save('CosKnn886Copado','CosKnn886')
save('SVMq976','SVMq976')

%%
load('Clasificadores.mat')
classifier=trainedClassifier1.ClassificationKNN;
%syntheticDir   ='C:\Users\seba\Dropbox\Candidatas'; % Candidatas
%handwrittenDir = 'C:\Users\seba\Dropbox\Test';% Test
handwrittenDir = 'C:\Users\seba\Dropbox\Candidatas';% Test
% |imageDatastore| recursively scans the directory tree containing the
% images. Folder names are automatically used as labels for each image.
%trainingSet = imageDatastore(syntheticDir,   'IncludeSubfolders', true, 'LabelSource', 'foldernames');
testSet     = imageDatastore(handwrittenDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
img = readimage(testSet, 114);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);
cellSize = [8 8]; % 
hogFeatureSize = length(hog_8x8);
[testFeatures, testLabels] = helperExtractHOGFeaturesFromImageSet(testSet, hogFeatureSize, cellSize);
% Make class predictions using the test features.
[predictedLabels, score] = predict(classifier, testFeatures);
% Tabulate the results using a confusion matrix.
%confMat = confusionmat(testLabels, predictedLabels)
score



%%
prompt = 'Mas? Y/N [Y]: ';

numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');
for i = 559:numImages
    img = readimage(trainingSet, i);
    a=edge(rgb2gray(img));
    a=edge(img);
    imshow(a)
    %img = rgb2gray(img);
    img=(img(:,:,2)-0.39*img(:,:,1)-0.61*img(:,:,3));
    imagesc(img)
 str = input(prompt);
if(str==1)
    i
end

end
    % Apply pre-processing steps
   % img = imbinarize(img);
    %[trainingFeatures(i, :)] = extractHOGFeatures(img, 'CellSize', cellSize);
%%
Mdl = fitcknn(TABLA);%,'Distance','exhaustive','cosine')
