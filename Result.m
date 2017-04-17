classdef Result < handle
    % RESULT - Class Summary
    %
    %   The Result class digests the output of the classifier into ROC and
    %   PR curves which can be used to actively calculate performance
    %

    %   Organization:   Duke University Energy Initiative
    
    properties
        trainingData        % Pointer to the training data
        validationData      % Pointer to the validation data
        roc                 % Receiver Operating Characteristic curve data
        pr                  % Precision Recall curve data
        trueLabels          % True labels of the validation data
        classifierScore     % Classifier confidence values (or scores)
        lengthThresh = 1e4 ;% Maximum length for the ROC or PR curves (to save memory when plotting)
        optrocpt
        confMat
        confMatOrder
        maxF1
        maxF1Threshold
        
    end
    
    methods
        %------------------------------------------------------------------
        % Result - Class Constructor
        %
        %   Calculates the ROC and PR curves and readies them for plotting
        %   Inputs:
        %       score =          nPixels x 1 vector of confidence values
        %       trueLabels =     nPixels x 1 vector of logical labels (0,1)
        %       validationData = pointer to the validation data
        %       trainingData =   pointer to the trainin data
        %------------------------------------------------------------------
        function R = Result(score,trueLabels, validationData, trainingData)
            % Create links to past data sources
            R.trainingData = trainingData ;
            R.validationData  = validationData ;
            
            % Generate the ROC curve data
            R.classifierScore = score ;
            R.trueLabels = int8(trueLabels) ;
            
            fprintf('Calculating ROC curve\n')
            R.calculateRoc() ;
            fprintf('Calculating PR curve\n')
            R.calculatePr() ;
        end
        


        
        
        %------------------------------------------------------------------
        % calculateRoc
        %
        %   Calculates the receiver operating characteristic curve for the
        %   given data, stored in the property 'roc'
        %------------------------------------------------------------------
        function R = calculateRoc(R)
            [R.roc.x,R.roc.y,R.roc.thresholds,R.roc.auc] = perfcurve(R.trueLabels,R.classifierScore,1) ;
            
            nPoints = length(R.roc.x) ;
            if length(nPoints) < R.lengthThresh
                % if there are not many points, leave the curve as it is
                R.roc.xPlot = R.roc.x ;
                R.roc.yPlot = R.roc.y ;
            else
                % Determine how much downsampling needs to be done
                downsampleValue = ceil(nPoints / R.lengthThresh) ;
                
                % interpolate the data for plotting
                R.roc.xPlot = downsample(R.roc.x,downsampleValue) ;
                R.roc.yPlot = downsample(R.roc.y,downsampleValue) ;
                R.roc.thresholds = downsample(R.roc.thresholds,downsampleValue);
                
            end
        end
        
        %------------------------------------------------------------------
        % calculatePr
        %
        %   Calculates the precision recall curve for the given data,
        %   stored in the property 'pr'
        %------------------------------------------------------------------
        function R = calculatePr(R)
            [R.roc.x,R.roc.y,R.roc.thresholds,R.roc.auc,R.optrocpt] = perfcurve(R.trueLabels,R.classifierScore,1) ;
            [R.pr.x,R.pr.y,~,R.pr.auc] = perfcurve(R.trueLabels,R.classifierScore, 1, 'xCrit', 'reca', 'yCrit', 'prec');
            
            nPoints = length(R.pr.x) ;
            if length(nPoints) < R.lengthThresh
                % if there are not many points, leave the curve as it is
                R.pr.xPlot = R.pr.x ;
                R.pr.yPlot = R.pr.y ;
            else
                % Determine how much downsampling needs to be done
                downsampleValue = ceil(nPoints / R.lengthThresh) ;
                
                % interpolate the data for plotting
                R.pr.xPlot = downsample(R.pr.x,downsampleValue) ;
                R.pr.yPlot = downsample(R.pr.y,downsampleValue) ;
            end
            
            R.pr.F1 = (2.*R.pr.x.*R.pr.y)./(R.pr.x+R.pr.y);
            R.maxF1 = max(R.pr.F1);
            R.maxF1Threshold = R.roc.thresholds(R.pr.F1==R.maxF1);
        
        end
        
        %------------------------------------------------------------------
        % plotRoc
        %
        %   Plot the ROC curve with AUC in the title
        %------------------------------------------------------------------
        function plotRoc(R,col)
            plot([0 1],[0 1],'k') ; hold on ;
            plot(R.roc.xPlot,R.roc.yPlot,col,'linewidth',1)
            xlabel('Probability of False Alarm')
            ylabel('Probability of Detection')
            title(['AUC = ' num2str(R.roc.auc)])
            axis square
            axis([0 1 0 1])
        end
        
        %------------------------------------------------------------------
        % plotPr
        %
        %   Plots the PR curve
        %------------------------------------------------------------------
        function plotPr(R,col)
            proportionPositive = sum(R.trueLabels) / length(R.trueLabels) ;
            plot([0 1],proportionPositive*ones(1,2),'k') ; hold on ;
            plot(R.pr.xPlot,R.pr.yPlot,col,'linewidth',1)
            xlabel('Recall')
            ylabel('Precision')
            axis square
            axis([0 1 0 1])
        end
        
        %------------------------------------------------------------------
        % plotF1s
        %
        %   Plots the F1 curve
        %------------------------------------------------------------------
         
        function plotF1(R)
            plot(R.roc.thresholds,R.pr.F1,'k-',R.maxF1Threshold,R.maxF1,'ro')
            xlabel('Thresholds')
            ylabel('F1 Values')
            title(['Max F1 = ' R.maxF1]);
        end
        
        %------------------------------------------------------------------
        % plotConfidenceMap
        %
        %   Plot the confidence map of the data output from the classifier
        %------------------------------------------------------------------
        function plotConfidenceMap(R,addPolygons)
            outputSize = R.validationData.imageSize(1:2) ;
            confidenceMap = reshape(R.classifierScore,outputSize) ;
            imagesc(confidenceMap) ; axis image ;
            colormap bone ;
            
            % Polygon plotting parameters
            edgeColor = 'g' ;
            edgeWidth = 1 ;
            faceColor = 'g' ;
            faceAlpha = 0 ;
            
            if strcmpi(addPolygons,'showpolygons')
                R.validationData.viewAddPolygons(edgeColor,edgeWidth,faceColor,faceAlpha) ;
            end
        end
        

    end
end