%% Demo Object Identification Code for the Kaggle Competition: Edifice Rex

% The following code will take in an aerial image as training, trains a
% Random Forest Classifier, and validates with another aerial image. The
% output is a Result object and RegionResult object, both with information
% about classifier scores and performance metrics. Some code needs to be
% uncommented to output the RegionResult. These .mat files can be saved
% onto the same folder. 
% All the image data should be saved into a folder called 'data' that is in
% the same folder.

%   Authors:    Duke Bass Connections 2017-2018 Energy Data Analytics
%   Organization:   Duke University Energy Initiative

%% Load the data

% Load training data: change paramTraing.imageFilename to name of aerial
% image file for training. 
paramTraing.imageFilename = 'Norfolk_02.tif';
  paramTraing.file          = paramTraing.imageFilename(1:end-7);
  paramTraing.directory     = ['Z:\data\objectidentification\FigShare\Cities\' paramTraing.file] ;
  paramTraing.labelFilename = 'Norfolk_02_buildingCell.mat' ;
  paramTraing.dataset       = 'buildings';
  paramTraing.type          = 'training';
 TrainingData = Data(paramTraing) ;


% Load validation data: change paramValidation.imageFilename to name of aerial
% image file for validation.
 paramValidation.imageFilename = 'Norfolk_01.tif' ;
 paramValidation.file = paramValidation.imageFilename(1:end-7);
 paramValidation.directory     = ['Z:\data\objectidentification\FigShare\Cities\' paramValidation.file] ;
 paramValidation.labelFilename = 'Norfolk_01_buildingCell.mat' ;
 paramValidation.dataset       = 'buildings' ;
 paramValidation.type          = 'validation' ;
 
 ValidationData = Data(paramValidation) ;



%% Extract features
TrainingFeatures = Features(TrainingData) ;
ValidationFeatures = Features(ValidationData) ;

%% Train classifier
FldClassifier = Classifier() ;
FldClassifier.train(TrainingFeatures);

%% Run the trained classifier on the validation data
Result = FldClassifier.classifyValidationData(ValidationFeatures) ;
TestingFeatures.imageSize = TestData.imageSize(1:2);
Scores = FldClassifier.classifyTestData(TestingFeatures);
OG_CM = reshape(Result.classifierScore,ValidationData.imageSize(1:2));



%% Saving Results from Validation Data
title = [paramTraing.imageFilename(1:end-4) '_' ValidationData.imageFilename(1:end-4)];
Result.trainingData = 'leave1';%paramTraing.imageFilename(1:end-4);
Result.validationData = ValidationData.imageFilename(1:end-4);
save(['Result_' title],'Result')

% Uncomment following code to produce and save Region-based (object)
% results:
% RegionResult = RegionResult(Result,0.1);
%  RegionResult.validationData = ValidationData.imageFilename(1:end-4);
%  save(['RegionResult_' title],'RegionResult')


