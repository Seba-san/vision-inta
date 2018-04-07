% Load training and test data using |imageDatastore|.
%cd 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
%cd 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab'
%addpath('C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
%syntheticDir   = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Candidatas';
%syntheticDir   ='C:\Users\seba\Dropbox\Filtradas_manual';
%syntheticDir   ='C:\Users\seba\Dropbox\Candidatas'; % Candidatas
%handwrittenDir = 'C:\Users\seba\Dropbox\Test\Test';% Test
syntheticDir   ='C:\Users\seba\Dropbox\DataComp'
%syntheticDir   ='C:\Users\sebasan.SERVER1\Dropbox\DataComp2';
%syntheticDir   ='C:\Users\sebasan.SERVER1\Desktop\DataComp';
%handwrittenDir = 'C:\Users\sebasan.SERVER1\Dropbox\Test';
% |imageDatastore| recursively scans the directory tree containing the
% images. Folder names are automatically used as labels for each image.
trainingSet = imageDatastore(syntheticDir,   'IncludeSubfolders', true, 'LabelSource', 'foldernames');
%testSet     = imageDatastore(handwrittenDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
countEachLabel(trainingSet)
% Loop over the trainingSet and extract HOG features from each image. A
% similar procedure will be used to extract features from the testSet.
img = readimage(trainingSet, 50);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);
cellSize = [8 8]; %
hogFeatureSize = length(hog_8x8);
numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');
for i = 1:numImages
    img = readimage(trainingSet, i);
    % imshow(img)
     I=rgb2hsv(img);%imshow(I11(:,:,1))
    %img = rgb2gray(img);
    %img=(img(:,:,2)-0.39*img(:,:,1)-0.61*img(:,:,3));
     I11=(1-I(:,:,3));
    %   [hog_8x8, vis8x8] = extractHOGFeatures(I11,'CellSize',[8 8]);
    [trainingFeatures(i, :)] = extractHOGFeatures(img, 'CellSize', cellSize);
    %   figure(2)
    %  imagesc(I11)
    %  hold on
    %  plot(vis8x8)
    %  hold off
end
trainingLabels=trainingSet.Labels;
TABLA=table(trainingFeatures,trainingLabels);

%%

save('Clasificadores','trainedClassifier1','trainedClassifier2','trainedClassifier3')
save('LinearSVM','SVMClassifier')
save('LinearSVMPCA','SVMPCA')
save('CosKnn886Copado','CosKnn886')
save('SVMq976','SVMq976')
save('SVMq95a','SVMq95a')
save('KNNCos959','KNNCos959')
%%
%[trainingFeatures, trainingLabels] = helperExtractHOGFeaturesFromImageSet(trainingSet, hogFeatureSize, cellSize);

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
%% Test rodimentario
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



