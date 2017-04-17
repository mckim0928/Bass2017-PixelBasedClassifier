classdef Features < handle
    % FEATURES - Class Summary
    %
    %   The Features class takes a Data class object as an input and
    %   extracts features from it for use with the Classifier class.
    %
    %   Author:         Kyle Bradbury
    %   Email:          kyle.bradbury@duke.edu
    %   Organization:   Duke University Energy Initiative
    
    properties
        dataSource
        featureType % Brief descriptor of the type of features that are extracted
        windowSize  % Radius of the window size for calculating features from (i.e. mean and variance for the example) 
        nFeatures   % Total number of features that will be calculated
        features    % Variable in which to store the extracted features
        labels      % Labels for each of the features (only non-empty for training and validation data)
        
        
        
    end
    
    methods
        %------------------------------------------------------------------
        % Features - Class Constructor
        %
        %   Extract features 
        %------------------------------------------------------------------
        function F = Features(Data)
            % Set parameters
            F.dataSource = Data;
            % Load, process, and save the data
            fprintf('Extracting features from %s...\n', F.dataSource.imageFilename)
            F.extractFeatures() ;
            F.extractLabels() ;
            fprintf('Completed loading data from %s.\n', F.dataSource.imageFilename)
            
        end
        
        %------------------------------------------------------------------
        % extractAllFeatures
        %
        %   Extract all the features from the dataset. In this case the
        %   mean and variance are calculated form a 3-by-3 window around
        %   each pixel and is calculated for each of the three color
        %   channels for a total of 6 features (consider modifying this)
        %------------------------------------------------------------------
        function F = extractFeatures(F)
            
            % Create convolutional mask
            F.nFeatures = 17; %
            F.windowSize = 7; %
            F.featureType = 'channel_mean_and_variance' ;
            windowDiameter = 2*F.windowSize-1 ;
            nPixelsInWindow = windowDiameter^2 ;
            convMask = ones(windowDiameter) ;
           
            edgeMask = ones(40);
            edgeMask(16:25,16:25) = 0;
            nPixelsGrad = numel(find(edgeMask));
            
            % Extract each of the three color channels
            
            img = F.dataSource.imageData;
            pixels = im2double(img(:,:,1:3)) ;
            HSVimg = rgb2hsv(img(:,:,1:3));
            grayimg = rgb2gray(img(:,:,1:3));
            grayBorder = grayimg;
            
            
            % Initialize feature vector
            F.features = nan(F.dataSource.nPixels,F.nFeatures) ;
            %[Gmag, Gdir] = imgradient(grayimg);
            
            
            for iChannel = 1:3
                % Extract features
                cChannel = squeeze(double(img(:,:,iChannel))) ;
                cChannelMean       = (1/nPixelsInWindow) * conv2(cChannel,convMask,'same') ;
                cChannelMeanSquare = (1/nPixelsInWindow) * conv2(cChannel.^2,convMask,'same') ;
                cChannelVariance   = cChannelMeanSquare - cChannelMean.^2 ;

                % Store the features
                F.features(:,2*(iChannel-1)+1) = cChannelMean(:) ;
                F.features(:,2*iChannel)       = cChannelVariance(:) ;
                
                cChannelHSV = squeeze(HSVimg(:,:,iChannel));
                cChannelHSVMean = (1/nPixelsInWindow)*conv2(cChannelHSV,convMask,'same');
                cChannelHSVMeanSquare = (1/nPixelsInWindow)*conv2(cChannelHSV.^2,convMask,'same');
                cChannelHSVVariance = cChannelHSVMeanSquare-cChannelHSVMean.^2;
                
                F.features(:,6+2*(iChannel-1)+1) = cChannelHSVMean(:) ;
                F.features(:,6+2*iChannel)       = cChannelHSVVariance(:) ;
                
            end
                entropyImg = entropyfilt(grayimg);
                F.features(:,13) = entropyImg(:);
                
                stdImg = stdfilt(grayimg);
                F.features(:,14) = stdImg(:);
                
                sobelMaskx = (1/8).*[-1 0 1; -2 0 2; -1 0 1];
                sobelMasky = (1/8).*[1 2 1; 0 0 0; -1 -2 -1];
                sobelRingx = conv2(edgeMask,sobelMaskx,'same');
                sobelRingy = conv2(edgeMask,sobelMasky,'same');
                grayimg = double(grayimg);
                edgeGradient = (1/nPixelsGrad) * (abs(conv2(grayimg,sobelRingx,'same'))+abs(conv2(grayimg,sobelRingy,'same')));
                
                F.features(:,15) = edgeGradient(:);
                
                
                IRChannel = squeeze(double(img(:,:,4))) ;
                RChannel = squeeze(double(img(:,:,1))) ;
                NDVI = (IRChannel-RChannel)/(IRChannel+RChannel);
                
                F.features(:,16) = NDVI(:);
                                
                Rs = (HSVimg(:,:,2)-HSVimg(:,:,3))./(HSVimg(:,:,2)+HSVimg(:,:,3));
                F.features(:,17) = Rs(:);
                
               % normMax = [255,255^2,255,255^2,255,255^2,1,1,1,1,1,1,6.5,255,7,1,1];
                
              %  [X,Y] = meshgrid(normMax,1:length(F.features));
                
               % normFeats = ((F.features./X).*65535);
                
               % F.features = uint16(normFeats);
                
                
                
                %imgSize = size(grayimg);
                 %8
%            for p=1:numel(grayimg)
%                 [rowP, colP] = ind2sub(imgSize,p);
%                 maxRow = imgSize(1);
%                 maxCol = imgSize(2);
%                 
%                 if rowP-eps < 1
%                     up = 1;
%                 else
%                     up = rowP-eps;
%                 end
%                 if colP-eps < 1
%                     left = 1;
%                 else
%                     left = colP-eps;
%                 end
%                 if rowP+eps > maxRow
%                     down = maxRow;
%                 else
%                     down =  rowP + eps;
%                 end
% 
%                 if colP+eps > maxCol
%                     right = maxCol;
%                 else
%                     right = colP+eps;
%                 end
%                 regionImg = double(grayimg(up:down,left:right,:));
%                 regionImg = (regionImg ./ 255);
%                 [glcms,SI] = graycomatrix(regionImg,'offset',[-1 1;-1 -1;1 -1; 1 1]);
%                 %fprintf('at gray stats');
%                 %grayStats = graycoprops(glcms);
%                % fprintf('finished graystats');
%                 F.features(p,18:21) = grayStats.Contrast;               
%                 F.features(p,22:25) = grayStats.Correlation;
%                 F.features(p,26:29) = grayStats.Energy;
%                 F.features(p,30:33) = grayStats.Homogeneity;
%                 
%            end
              
                
%                 [Gmag, Gdir] = imgradient(rgb2gray(img));
%                 F.features(:,7) = Gmag(:);
%                 F.features(:,8) = Gdir(:);
%                  
%                 cornerMetric = cornermetric(rgb2gray(img));
%                 cornerMetric = imhmax(cornerMetric, mean(cornerMetric(:))+2*std(cornerMetric(:)));
%                 cornerMax = ordfilt2(cornerMetric,5*5,ones(5,5));
%                 F.features(:,9) = cornerMax(:);
        end
        
        %------------------------------------------------------------------
        % extractLabels
        %
        %   Extract pixel labels (reshape into a vector of values)
        %------------------------------------------------------------------
        function F = extractLabels(F)
            F.labels = double(F.dataSource.labels(:)) ;
        end
    end
end

