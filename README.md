# Comparison of Texture-based Classification and Deep Learning for Plantar Soft Tissue Histology Segmentation
Semantic segmentation of plantar soft tissue histology images using several machine learning techniques. Publication *under review*



## Sup Deep Morphology
### Texture-based Classification
* classifierims: images of all classes used to train the "classic" computer vision features-based ML framework. Can be found at <UW research works link>
* lbp folder: code to complete local binary patterns
* subroutines folder: all subroutines needed to run the main scripts
* perceptual: code to extract [kather or original link](perceptual features)
* SNIC_mex: Slightly adapted [snic link](SNIC method ). 
* UGM folder: [UGM link](open-source files) needed to run the undirected graphical model

Running instructions
* use main_create_texture_feature_dataset.m to extract desired features from all classifier images. 
* use main_select_features.m to reduce the size of the feature set
* use main_train_classifier_reduced.m to train the classifier on the training data extracted in step 1
* use one of the main_deploy_classifier*.m to apply the trained classifier to the whole slide images using desired strategy (block or superpixel)

### Deep Learning
* UNet7Channel is the caffe prototxt file describing the network architecture. Use [netscope](https://dgschwend.github.io/netscope/#/editor) to visualize the architecture. 
* Make*Data.m files will take in images and batch crop or augment and save resulting files for input into deep neural network
* getRangAug.m is used to randomly augment the data; function called by Make*Data.m
* StitchDigitsOutput.m and AverageOverlap_Stitch.m are used to stitch the network output back into the original input size. 
* caffe installation adapted from []()

### Ground Truth
Contains .mat files with ground truth for segmented images. 

### Images
Sample Images are hosted on [Google Drive](https://drive.google.com/drive/folders/1i1C-IXEV6JHNO4-seWuAgR4h89YdVR1a?usp=sharing)
* ground truth folder contains raw images correlating to ground truth label matrices
* other files selected at random



### System info
* MATLAB code was run on windows and Liunux systems (Win 7, 10; Ubuntu 12)
* Python code for caffe run on Win 7. 
* All other O.S. have not been tested