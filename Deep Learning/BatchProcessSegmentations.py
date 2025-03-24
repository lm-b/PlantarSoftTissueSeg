# -*- coding: utf-8 -*-
"""
Created on Tue Jun 25 10:30:10 2019

@author: Lynda
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import sys
import caffe
import os
#import skimage
from itertools import product
from scipy.special import softmax
import scipy.io as sio
import glob
from natsort import natsorted, ns
import time

def process_by_caffe(M, net, transformer, blk_size, overlap, num_classes=7):
    # truncate M to a multiple of blk_size
    output = np.zeros((*M.shape[0:2],num_classes)) # asterisk unpacks tuple
    
    dz = np.asarray(blk_size)
    # shape give maximum edges indices
    shape = M.shape - (np.mod(np.asarray(M.shape), 
                          blk_size))
    shape[0:2]=shape[0:2]-np.asarray(blk_size[0:2])*(1-overlap/100)
    #output = np.zeros((*shape[0:2],num_classes)) # asterisk unpacks tuple
    for indices in product(*[range(0, stop, step) 
                        for stop,step in zip(shape, np.round(np.asarray(blk_size)*(1-overlap/100)).astype(int))]):
        # Don't overrun the end of the array.
        #max_ndx = np.min((np.asarray(indices) + dz, M.shape), axis=0)
        #slices = [slice(s, s + f, None) for s,f in zip(indices, dz)] 
        # copy the image data into the memory allocated for the net
        output[indices[0]:indices[0]+dz[0],indices[1]:indices[1]+dz[1]][:,:] += apply_net_forward(
                M[indices[0]:indices[0]+dz[0], indices[1]:indices[1]+dz[1]], net, transformer)    
    return output

def apply_net_forward (img, net, transformer):
   transformed_image = transformer.preprocess('data', img)
   net.blobs['data'].data[...] = transformed_image
   result = net.forward()
   try:
       output_prob = result['scorecrop'][0].transpose(1,2,0)
   except:
       output_prob = result['score'][0].transpose(1,2,0)    
   return output_prob

#_Main_#
 
# Load Net
#digits_root='D:/Digits_jobs/'
## get all available UNet networks
#Unetmodels=glob.glob(digits_root+'/U*')
#Unetmodels=[Unetmodels[4]]
#for model in Unetmodels:
#    #model=Unetmodels[3]
#    model_root = model +'/'+str(os.listdir(model)[0])+'/'
model_root='C:/Users/user/Documents/caffe/examples/Unettest/Unet28_16_'
#test all saved models?
#allmodels=glob.glob(model_root + '*.caffemodel')
#test last model saved
#for model_weights in [natsorted(glob.glob(model_root + '*iter_10000.caffemodel'), alg=ns.IGNORECASE)[-1]]:
model_weights='C:\\Users\\user\\Documents\\caffe\\examples\\Unettest\\Unet28_576_16_iter_8000.caffemodel'    
net = caffe.Net('C:\\Users\user\\Documents\\caffe\\examples\\Unettest\\UNet28_run576_Deploy.prototxt',      # defines the structure of the model
                'C:\\Users\\user\\Documents\\caffe\\examples\\Unettest\\Unet28_576_16_iter_8000.caffemodel'    ,  # contains the trained weights
                caffe.TEST)     # use test mode (e.g., don't perform dropout)\\

    # get size of input image for network
img_size=net.blobs['data'].data.shape[-1]


#load image mean
#dataset_root='Datasets\\SevenImage_600\\20190627-221820-ef8d' 
meanfile='C:\\Users\\user\\Documents\\caffe\\examples\\SDML576_train2_r\\train_mean.binaryproto'
blob = caffe.proto.caffe_pb2.BlobProto()
data = open( meanfile , 'rb' ).read()

blob.ParseFromString(data)
mu = np.array(caffe.io.blobproto_to_array(blob) )
mu = mu.mean(0)  # average over pixels to obtain the mean (BGR) pixel values 
# create transformer for the input called 'data'
# transformer comes from caffe/io.py; stransforms input for feeding into Net
transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
transformer.set_transpose('data', (2,0,1))  # move image channels to outermost dimension
transformer.set_mean('data', mu)            # subtract the dataset-mean value in each channel; mu is dataset mean image
#transformer.set_raw_scale('data', 255)      # rescale from [0, 1] to [0, 255] IF PNG INPUT ONLY, if itff input, comment out
transformer.set_channel_swap('data', (2,1,0))  # swap channels from RGB to BGR

# set the size of the input (we can skip this if we're happy
#  with the default; we can also change it later, e.g., for different batch sizes)
net.blobs['data'].reshape(1,        # batch size **
                          3,         # 3-channel (BGR) images
                          img_size, img_size)  # image size is 227x227


# get all validation images
image_root='D:/DeepLearningFiles/Segmentations/'
#image_root='D:/Digits_jobs/IncludeTiff/'
#image_root='D:/Digits_jobs/IncludeTiff/incl1/'
testims=glob.glob(image_root+'*.tif')
#testims= [testims[i] for i in [1,2,5,11,12]]
#testims=testims[137:]
if not os.path.isdir(image_root+ 'AllSegmentations16_WCE/'):
        os.mkdir(image_root+ 'AllSegmentations16_WCE/')
        
#apply network to validation images & save as mat file 
for stitch_overlap in [10,20,30,40,50]: #10,20,30,40,
#stitch_overlap=0 #%
    effective_img_size=int(img_size*(1-stitch_overlap/100))
    for k in testims:
        WSI=mpimg.imread(k).astype(np.float32)
        #image = caffe.io.load_image(image_root+ 'examples/images/cat.jpg')
        #q=WSI.shape
        tic=time.time()
        krg=np.pad(WSI, ((0, img_size-WSI.shape[0]%effective_img_size+img_size%effective_img_size+1), (0, img_size-WSI.shape[1]%effective_img_size+img_size%effective_img_size+1),(0, 0)), 'constant', constant_values=(0))
        #label=np.zeros((q[0], q[1])) #make matrix to store the label image
        img=process_by_caffe(krg, net,transformer, blk_size=(img_size, img_size,3), overlap=stitch_overlap)
        #plt.imshow(img[:,:,1]), plt.colorbar()
        m = softmax(img, axis=2)
        #plt.imshow(m[:,:,4])
        finalpredictions=np.argmax(m,axis=2)
        #fig2=plt.figure(figsize=(14,12))
        #ax3 = fig2.add_subplot(111)
        #ax3.imshow(finalpredictions)
        toc=time.time()
        elapsedtime=toc-tic
        #outfile=image_root+ '/AllSegmentations16_WCE/'+ k[len(image_root):-4]+ '_' + str(stitch_overlap)  +'overlap_finalprediction_nomean_modelIter'+model_weights[-16:-11]+ '.mat'
        outfile=image_root+ '/AllSegmentations16_WCE/'+ k[len(image_root):-4]+ '_' + str(stitch_overlap)  +'overlap_elapsedtime_modelIter'+model_weights[-16:-11]+ '.mat'
        #matlabdictionary={"initialPrediction":img, "finalPrediction": finalpredictions}
        matlabdictionary={"elapsedTime": elapsedtime}
        sio.savemat(outfile, matlabdictionary)
        
        #plt.close(all)        


 



