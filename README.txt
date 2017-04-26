# Bass2017-PixelBasedClassifier
This code was adapted from Kyle Bradbury's code used by Energy Data Analytics Lab team in Kaggle Competition Fall 2016. 

This is the comprehensive code for building detection from high-resolution aerial images using a random-forest classifier.

The code is split into function files that perform various tasks (classification, feature extraction, data/file location, result generation and run initialization).

To run the program, run the "runObjectIdentification" file after ensuring that the training/testing images are in a subfolder called 'data'. 

After running, a 'Result' object will be generated. Functions can be applied to Result to view the resulting confidence map or ROC/PR curve. A 'RegionResult', which is the Result after more post-processing and region detection steps, can also be generated. 

makeShpFile function can be used to create shapefiles which can directly be applied in GIS software, such as ARCGIS. 


