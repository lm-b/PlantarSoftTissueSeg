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
        blob.channels = 1
        blob.height, blob.width = mean.shape
        blob.data.extend(mean.astype(float).flat)
        with open(filename, 'wb+') as outfile:
            outfile.write(blob.SerializeToString())

    elif filename.endswith(('.jpg', '.jpeg', '.png')):
        imageio.imwrite(filename, mean)
    else:
        raise ValueError('unrecognized file extension')


N = 100
path='F:\\From Finite\\newsupdeep\\DeepLearningData'

img_files = [f for f in glob.glob(path + "\\Train600_6\\*.png", recursive=True)]
lab_files = [f for f in glob.glob(path + "\\Label600_6\\*.png", recursive=True)]
weight_files = [f for f in glob.glob(path + "\\Weight600_6\\*.png", recursive=True)]

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

train_img=[img_files[i] for i in rand_order[0:int(len(img_files)*train_split)]]
test_img=[img_files[i] for i in rand_order[0:int(len(img_files)*(1-train_split))]]

train_lab=[lab_files[i] for i in rand_order[0:int(len(lab_files)*train_split)]]
test_lab=[lab_files[i] for i in rand_order[0:int(len(lab_files)*(1-train_split))]]

train_weight=[weight_files[i] for i in rand_order[0:int(len(weight_files)*train_split)]]
test_weight=[weight_files[i] for i in rand_order[0:int(len(weight_files)*(1-train_split))]]

#WRITE IMAGES TO LMDB
# We need to prepare the database for the size. We'll set it 10 times
# greater than what we theoretically need. There is little drawback to
# setting this too big. If you still run into problem after raising
# this, you might want to try saving fewer entries in a single
# transaction.
sizemap=3*600*600*(len(train_img)+7)
env = lmdb.open(os.getcwd()+'\\SDML600_train\\train_img_onehot', map_size=sizemap)
imgavg=np.zeros((1, 600, 600))
with env.begin(write=True) as txn:
    # txn is a Transaction object
    for i in range(0, len(train_img)):
        datum = caffe.proto.caffe_pb2.Datum()
        img_data=imageio.imread(train_img[i]).transpose(2,0,1)
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
_save_mean(avgimg[0], os.path.join( 'SDML600_train\\ train_mean.png'))
_save_mean(avgimg[0], os.path.join('SDML600_train\\ train_mean.binaryproto' ))

sizemap=8*600*600*(len(train_lab)+7)
#WRITE LABELS TO LMDB
#sizemap=lab_data.nbytes*10
env = lmdb.open(os.getcwd()+'\\SDML600_train\\train_lab_onehot', map_size=sizemap)

with env.begin(write=True) as txn:
    # txn is a Transaction object
    for i in range(0, len(train_lab)):
        datum = caffe.proto.caffe_pb2.Datum()
        lab_idx=imageio.imread(train_lab[i])
        lab_onehot=(np.arange(lab_idx.max()) == lab_idx[...,None]).astype(int)
        lab_data=lab_onehot.transpose(2,0,1) # convert to ch, h, w
        datum.channels = lab_data.shape[0] # number of channels in image
        datum.height = lab_data.shape[1] # dim of H of image
        datum.width = lab_data.shape[2] # dim of w of image
        datum.data = lab_data.tobytes()  # or .tostring() if numpy < 1.9  ** this is just the image
        str_id = '{:08}'.format(i)

        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())

        
#WRITE train WEIGHTS TO LMDB
#sizemap=weight_data.nbytes*10    
sizemap=600*600*(len(train_weight)+7)
env = lmdb.open(os.getcwd()+'\\SDML600_train\\train_weight_onehot', map_size=sizemap)

with env.begin(write=True) as txn:
    # txn is a Transaction object
    for i in range(0, len(train_weight)):
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



        
        
sizemap=3*600*600*(len(test_img)+1)
env = lmdb.open(os.getcwd()+'\\SDML600_test\\test_img_onehot', map_size=sizemap)
imgavg=np.zeros((1, 600, 600))
with env.begin(write=True) as txn:
    # txn is a Transaction object
    for i in range(0, len(test_img)):
        datum = caffe.proto.caffe_pb2.Datum()
        img_data=imageio.imread(test_img[i]).transpose(2,0,1)
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


sizemap=7*600*600*(len(test_lab)+7)
# WRITE LABELS TO LMDB
#sizemap=lab_data.nbytes*10
env = lmdb.open(os.getcwd()+'\\SDML600_test\\test_lab_onehot', map_size=sizemap)

with env.begin(write=True) as txn:
    # txn is a Transaction object
    for i in range(0, len(test_lab)):
        datum = caffe.proto.caffe_pb2.Datum()
        lab_idx=imageio.imread(test_lab[i])
        lab_onehot=(np.arange(lab_idx.max()) == lab_idx[...,None]).astype(int)
        lab_data=lab_onehot.transpose(2,0,1) # convert to ch x h x w
        datum.channels = lab_data.shape[0] # number of channels in image
        datum.height = lab_data.shape[1] # dim of H of image
        datum.width = lab_data.shape[2] # dim of w of image
        datum.data = lab_data.tobytes()  # or .tostring() if numpy < 1.9  ** this is just the image
        str_id = '{:08}'.format(i)

        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())

        
#WRITE test WEIGHTS TO LMDB
        
sizemap=600*600*(len(test_weight)+7)
env = lmdb.open(os.getcwd()+'\\SDML600_test\\test_weight_onehot', map_size=sizemap)

with env.begin(write=True) as txn:
    # txn is a Transaction object
    for i in range(0, len(test_weight)):
        datum = caffe.proto.caffe_pb2.Datum()
        weight_data=imageio.imread(test_weight[i])
        datum.channels = 1
        datum.height = weight_data.shape[0]
        datum.width = weight_data.shape[1]
        datum.data = weight_data.tobytes()  # or .tostring() if numpy < 1.9
        str_id = '{:08}'.format(i)

        # The encode is only essential in Python 3
        txn.put(str_id.encode('ascii'), datum.SerializeToString())
        
env.close() # close the lmdb environment
print('Successfully Created Databases')


