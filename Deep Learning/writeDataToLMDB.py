# -*- coding: utf-8 -*-
"""
Write data to lmdb template

Created on Sun Nov 10 19:49:24 2019

@author: admin

This code makes a separate lmdb database for train and test of 
"""

import numpy as np
import lmdb
import caffe
import glob
import imageio
import random
import os


def _save_mean(mean, filename):
    """
    Saves mean to file
    Arguments:
    mean -- the mean as an np.ndarray
    filename -- the location to save the image
    """
    if filename.endswith('.binaryproto'):
        blob = caffe.proto.caffe_pb2.BlobProto()
        blob.num = 1
        blob.channels,blob.height, blob.width = mean.shape
        blob.data.extend(mean.astype(float).flat)
        with open(filename, 'wb+') as outfile:
            outfile.write(blob.SerializeToString())

    elif filename.endswith(('.jpg', '.jpeg', '.png')):
        imageio.imwrite(filename, mean.transpose(1,2,0))
    else:
        raise ValueError('unrecognized file extension')


#N = 100
path='D:\\DeepLearningFiles'

img_files = [f for f in glob.glob(path + "\\DeepLearnTrain15\\*.png", recursive=True)]
lab_files = [f for f in glob.glob(path + "\\DeepLearnLabel15\\*.png", recursive=True)]
weight_files = [f for f in glob.glob(path + "\\DeepLearnWeights15\\*.png", recursive=True)]

img_testfiles = [f for f in glob.glob(path + "\\DeepLearnTest12\\*.png", recursive=True)]
lab_testfiles = [f for f in glob.glob(path + "\\DeepLearnTestLabel12\\*.png", recursive=True)]
weight_testfiles = [f for f in glob.glob(path + "\\DeepLearnTestWeights12\\*.png", recursive=True)]

# Let's pretend this is interesting data
    # remove this data initialization and replace with file read-in 
#img_data = np.zeros((N, 3, 32, 32), dtype=np.uint8)
#lab_data = np.zeros((N, 1,32,32),dtype=np.int8)
#weight_data =np.zeros((N, 1, 32,32), dtype=np.float16) #keep larger than 0.000061035
    
# split into train and test set; shuffle into random order
train_split= 0.9 #%
random.seed(2) # set random seed for reproducibility
rand_order=list(range(0,len(img_files)))
random.shuffle(rand_order) # shuffle order
rand_order2=list(range(0,len(img_testfiles)))
random.shuffle(rand_order2) # shuffle order

train_img=[img_files[i] for i in rand_order[0:int(len(img_files))]]#*train_split)]]
test_img=[img_testfiles[i] for i in rand_order2[0:int(len(img_testfiles))]]#*(1-train_split))]]

train_lab=[lab_files[i] for i in rand_order[0:int(len(lab_files))]]#*train_split)]]
test_lab=[lab_testfiles[i] for i in rand_order2[0:int(len(lab_testfiles))]]#*(1-train_split))]]

train_weight=[weight_files[i] for i in rand_order[0:int(len(weight_files))]]#**train_split)]]
test_weight=[weight_testfiles[i] for i in rand_order2[0:int(len(weight_testfiles))]]#**(1-train_split))]]

#WRITE IMAGES TO LMDB
# We need to prepare the database for the size. We'll set it 10 times
# greater than what we theoretically need. There is little drawback to
# setting this too big. If you still run into problem after raising
# this, you might want to try saving fewer entries in a single
# transaction.
sizemap=3*576*576*(len(train_img)+25)
os.makedirs(os.getcwd()+'\\SDML576_train2_r\\train_img')
env = lmdb.open(os.getcwd()+'\\SDML576_train2_r\\train_img', map_size=sizemap)
imgavg=np.zeros((3, 576, 576))
storeorder=np.random.permutation(len(train_img))
with env.begin(write=True) as txn:
 #    txn is a Transaction object
#for i in range(0, len(train_img)):
    for i in storeorder:
        datum = caffe.proto.caffe_pb2.Datum()
        img_data=imageio.imread(train_img[i]).transpose(2,0,1)
        img_data=img_data[[2,1,0],:,:] # convert from rgb to bgr for caffe input
        imgavg+=img_data
        datum.channels = img_data.shape[0] # number of channels in image
        datum.height = img_data.shape[1] # dim of H of image
        datum.width = img_data.shape[2] # dim of w of image
        datum.data = img_data.tobytes()  # or .tostring() if numpy < 1.9  ** this is just the image
        str_id = '{:08}'.format(i)
    #
    #        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())
        
avgimg=imgavg/(len(img_files)) # ** Mean image!! don't forget to save!
_save_mean(avgimg, os.path.join( 'SDML576_train2_r\\train_mean.png'))
_save_mean(avgimg, os.path.join('SDML576_train2_r\\train_mean.binaryproto' ))
env.close()
#WRITE LABELS TO LMDB
# redefine sie map -don't need 3 channels worth of storage space
# but do need to increase size needed for overead.
# can re-use this size map for one-channel weights lmdb
sizemap=576*576*(len(train_lab)+85)
#sizemap=lab_data.nbytes*10
os.makedirs(os.getcwd()+'\\SDML576_train2_r\\train_lab')
env = lmdb.open(os.getcwd()+'\\SDML576_train2_r\\train_lab', map_size=sizemap)

with env.begin(write=True) as txn:
    # txn is a Transaction object
#    for i in range(0, len(train_lab)):
    for i in storeorder:
        datum = caffe.proto.caffe_pb2.Datum()
        lab_data=imageio.imread(train_lab[i])
        datum.channels = 1 # number of channels in image
        datum.height = lab_data.shape[0] # dim of H of image
        datum.width = lab_data.shape[1] # dim of w of image
        datum.data = lab_data.tobytes()  # or .tostring() if numpy < 1.9  ** this is just the image
        str_id = '{:08}'.format(i)

        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())
env.close()
        
#WRITE train WEIGHTS TO LMDB
#sizemap=weight_data.nbytes*10   
os.makedirs(os.getcwd()+'\\SDML576_train2_r\\train_weight')
env = lmdb.open(os.getcwd()+'\\SDML576_train2_r\\train_weight', map_size=sizemap)

with env.begin(write=True) as txn:
    # txn is a Transaction object
#    for i in range(0, len(train_weight)):
    for i in storeorder:
        datum = caffe.proto.caffe_pb2.Datum()
        weight_data=imageio.imread(train_weight[i])
        datum.channels = 1
        datum.height = weight_data.shape[0]
        datum.width = weight_data.shape[1]
        datum.data = weight_data.tobytes()  # or .tostring() if numpy < 1.9
        str_id = '{:08}'.format(i)

        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())
env.close()



        
        
sizemap=3*576*576*(len(test_img)+12)
os.makedirs(os.getcwd()+'\\SDML576_test2_r\\test_img')
env = lmdb.open(os.getcwd()+'\\SDML576_test2_r\\test_img', map_size=sizemap)
imgavg=np.zeros((1, 576, 576))
storeorder2=np.random.permutation(len(test_img))
with env.begin(write=True) as txn:
    # txn is a Transaction object
#    for i in range(0, len(test_img)):
    for i in storeorder2:
        datum = caffe.proto.caffe_pb2.Datum()
        img_data=imageio.imread(test_img[i])
        img_data=img_data[0:576, 0:576].transpose(2,0,1)
        img_data=img_data[[2,1,0],:,:] # convert from rgb to bgr for caffe input
        imgavg+=img_data.sum(0)
        datum.channels = img_data.shape[0] # number of channels in image
        datum.height = img_data.shape[1] # dim of H of image
        datum.width = img_data.shape[2] # dim of w of image
        datum.data = img_data.tobytes()  # or .tostring() if numpy < 1.9  ** this is just the image
        str_id = '{:08}'.format(i)

        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())
        
avgimg=imgavg/(imgavg.size*len(img_files)) # ** Mean image!! don't forget to save!


sizemap=576*576*(len(test_lab)+32)
# WRITE LABELS TO LMDB
#sizemap=lab_data.nbytes*10
os.makedirs(os.getcwd()+'\\SDML576_test2_r\\test_lab')
env = lmdb.open(os.getcwd()+'\\SDML576_test2_r\\test_lab', map_size=sizemap)

with env.begin(write=True) as txn:
    # txn is a Transaction object
#    for i in range(0, len(test_lab)):
    for i in storeorder2:
        datum = caffe.proto.caffe_pb2.Datum()
        lab_data=imageio.imread(test_lab[i])
        lab_data=lab_data[0:576, 0:576]
        datum.channels = 1 # number of channels in image
        datum.height = lab_data.shape[0] # dim of H of image
        datum.width = lab_data.shape[1] # dim of w of image
        datum.data = lab_data.tobytes()  # or .tostring() if numpy < 1.9  ** this is just the image
        str_id = '{:08}'.format(i)

        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())

        
#WRITE test WEIGHTS TO LMDB
#sizemap=weight_data.nbytes*10    
os.makedirs(os.getcwd()+'\\SDML576_test2_r\\test_weight')
env = lmdb.open(os.getcwd()+'\\SDML576_test2_r\\test_weight', map_size=sizemap)

with env.begin(write=True) as txn:
    # txn is a Transaction object
#    for i in range(0, len(test_weight)):
    for i in storeorder2:
        datum = caffe.proto.caffe_pb2.Datum()
        weight_data=imageio.imread(test_weight[i])
        weight_data=weight_data[0:576, 0:576]
        datum.channels = 1
        datum.height = weight_data.shape[0]
        datum.width = weight_data.shape[1]
        datum.data = weight_data.tobytes()  # or .tostring() if numpy < 1.9
        str_id = '{:08}'.format(i)

        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())
        
env.close() # close the lmdb environment
print('Successfully Created Databases')

#%%

# saveinfogainloss matrix
classmat=np.array([[0.89, 0,0,0,0,0,0], [0,0.788,0,0,0,0,0],[0,0,0.866,0,0,0,0],[0,0,0,0.941,0,0,0],[0,0,0,0,0.756,0,0],[0,0,0,0,0,0.901,0],[0,0,0,0,0,0,0.772]])
import caffe
blob = caffe.io.array_to_blobproto( classmat.reshape( (1,1,7,7) ) )
with open( 'infogainH.binaryproto', 'wb' ) as f :
    f.write( blob.SerializeToString() )
    
    

