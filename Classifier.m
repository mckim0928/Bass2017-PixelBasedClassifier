classdef Classifier < handle
    % CLASSIFIER - Class Summary
    %
    %   Train and classify features previously extracted from data. Each
    %   classifier must be first trained after its initialized in order to
    %   be able to classify validation or test data. With validation data a
    %   full result is possible to be output through a performance
    %   comparison with ground truth, for test data, the classifier
    %   confidence values, or scores, are output
    %
    %   Author:         Kyle Bradbury
    %   Email:          kyle.bradbury@duke.edu
    %   Organization:   Duke University Energy Initiative
    
    properties
        status              % trained, untrained
        trainingFeatures    % available if trained
        trainingData        % available if trained
        testingData
        classifierModel     % stores trained classifier
        type = 'random forest' ; % specified for each classifier class
    end
    
    methods
        %------------------------------------------------------------------
        % Classifier - Class Constructor
        %
        %   Initialize an untrained classifier
        %------------------------------------------------------------------
        function C = Classifier()
            C.status = 'untrained' ;
        end
        
        %------------------------------------------------------------------
        % train
        %
        %   Train the classifier. The classification algorithm in this
        %   method is a linear discriminant (consider modifying this)
        %------------------------------------------------------------------
        function C = train(C,Features)
            fprintf('Training %s classifier...\n', C.type)
            C.trainingFeatures = Features ;
            C.trainingData = Features.dataSource ;
            values = Features.features;
            labels = Features.labels;
            %values = vertcat(Features.features,Features2.features) ;
            %labels = vertcat(Features.labels, Features2.labels) 
            parpool;
            C.classifierModel = TreeBagger(20,values,labels);
        
            %C.classifierModel = fitcdiscr(values,labels,'DiscrimType','linear');
            
            C.status = 'trained' ;
        end
        
        %------------------------------------------------------------------
        % classifyValidationData
        %
        %   Use a trained classifier to classify validation data and score
        %   performance through the Result class
        %------------------------------------------------------------------
        function result = classifyValidationData(C,Features)
            if strcmp(C.status,'trained')
                fprintf('Classifying data with %s...\n', C.type)
                % Generate result
                [~, score] = predict(C.classifierModel,Features.features) ;
                %cmValid = reshape(score(:,2),Features.dataSource.imageSize(1:2));
                %medFilt = medfilt2(cmValid,[4 4]);
                %SE = strel('disk',4);
                %opened = imopen(medFilt, SE);
                %trainingScores = imclose(opened,SE);

                %result = Result(trainingScores(:),Features.labels,Features.dataSource,C.trainingData) ;
                result = Result(score(:,2),Features.labels,Features.dataSource,C.trainingData) ;
            
            
            else
                error('Classifier must be trained')
            end
        end
        
        %------------------------------------------------------------------
        % classifyTestData
        %
        %   Use a trained classifier to classify test data and output the
        %   confidence values, or scores
        %------------------------------------------------------------------
        function scores = classifyTestData(C,Features)
            if strcmp(C.status,'trained')
                fprintf('Classifying data with %s...\n', C.type)
                % Generate result
                [~, score] = predict(C.classifierModel,Features.features) ;
                cmValid4 = reshape(score,Features.imageSize);
                medFilt4 = medfilt2(cmValid4,[4 4]);
                SE = strel('disk',4);
                opened4 = imopen(medFilt4, SE);
                trainingScores4 = imclose(opened4,SE);
                scores = trainingScores4(:); %overwriting the score w/ this new PostProcess
                %result = Result(scores(:,2),Features.labels,Features.dataSource,C.testingData) ;
                
            else
                error('Classifier must be trained')
            end
        end
    end
end

