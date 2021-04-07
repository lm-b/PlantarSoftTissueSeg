
"""
Created on Fri Oct 25 08:23:02 2019

@author: Lynda
"""

from pylab import *
#matplotlib inline


import time
import scipy.io as sio

caffe_root = 'C:/Users/Lynda/Documents/caffe-windows-ms/caffe-windows-ms/Build/x64/Release/'  # this file should be run from {caffe_root}/examples (otherwise change this line)

import sys
sys.path.insert(0, caffe_root + 'pycaffe')
import caffe

# run scripts from caffe root
import os
os.chdir('C:/Users/Lynda/Documents/caffe/')
# Download data!
#caffe_rootdata/UNet/get_UNet.sh
# Prepare data
#!examples/UNet/create_UNet.sh
# back to examples
os.chdir('examples')
os.environ['GLOG_log_dir'] = "."

from caffe import layers as L, params as P

train_net_path = 'UNettest/Unet28_run576_DiceTrain.prototxt'
test_net_path = 'UNettest/Unet28_run576_DiceTest.prototxt'
solver_config_path = 'UNettest/Unet28_run576_Dicesolver.prototxt'


### define solver
from caffe.proto import caffe_pb2
s = caffe_pb2.SolverParameter()

# Set a seed for reproducible experiments:
# this controls for randomization in training.
s.random_seed = 0xCAFFE

# Specify locations of the train and (maybe) test networks.
s.train_net = train_net_path
s.test_net.append(test_net_path)
s.test_interval = 300  # Test after every 500 training iterations.
s.test_iter.append(30) # Test on 100 batches each time we test.

s.max_iter = 30000    # no. of times to update the net (training iterations)
s.iter_size=45    # no of batches to accumulate before upadting gradients
 
# EDIT HERE to try different solvers
# solver types include "SGD", "Adam", and "Nesterov" among others.
s.type = "Adam"

# Set the initial learning rate for SGD.
s.base_lr = 0.00028 # EDIT HERE to try different learning rates
# Set momentum to accelerate learning by
# taking weighted average of current and previous updates.
s.momentum = 0.9
# Set weight decay to regularize and prevent overfitting
s.weight_decay = 2e-6

# Set `lr_policy` to define how the learning rate changes during training.
# This is the same policy as our default LeNet.
s.lr_policy = 'step'
s.gamma = .91
s.stepsize =300

#s.lr_policy = 'step'
#s.gamma = 1.02
#s.stepsize =1
# EDIT HERE to try the fixed rate (and compare with adaptive solvers)
# `fixed` is the simplest policy that keeps the learning rate constant.
# s.lr_policy = 'fixed'

# Display the current training loss and accuracy every 1000 iterations.
s.display = 1000

# Snapshots are files used to store networks we've trained.
# We'll snapshot every 5K iterations -- twice during training.
s.snapshot = 1250
s.snapshot_prefix = 'UNettest/Unet28_576_Dice1'


#s.debug_info=True
# Train on the GPU
#s.solver_mode = caffe_pb2.SolverParameter.GPU

# Write the solver to a temporary file and return its filename.
with open(solver_config_path, 'w') as f:
    f.write(str(s))


caffe.set_device(0)
caffe.set_mode_gpu()
    
### load the solver and create train and test nets
#solver = None  # ignore this workaround for lmdb data (can't instantiate two solvers on the same data)
solver = caffe.get_solver(solver_config_path)

### solve
niter = 1500# EDIT HERE increase to train for longer  - make sure divisible byb batch + accum
test_interval = niter /50
# losses will also be stored in the log
train_loss = zeros(niter)
test_acc = zeros(int(np.ceil(niter / test_interval)))
test_loss=zeros(int(np.ceil(niter / test_interval)))

tmp = sys.stdout
sys.stdout = open('Unet28_Cleaned576_Dice1_log.txt', 'wt')

# the main solver loop
for it in range(niter):
    solver.step(1)  # SGD by Caffe
    
    # store the train loss
    train_loss[it] = solver.net.blobs['loss'].data
    # run a full test every so often
    # (Caffe can also do this for us and write to a log, but we show here
    #  how to do it directly in Python, where more complicated things are easier.)
    if it % test_interval == 0:
        print ('Iteration', it, 'testing...')
        correct = 0
        valoss=0
        for test_it in range(30):
            solver.test_nets[0].forward()
            correct += sum(solver.test_nets[0].blobs['score'].data.argmax(1)
                           == solver.test_nets[0].blobs['label'].data.transpose(1,0,2,3)[0])/size(solver.test_nets[0].blobs['label'].data)
            valoss+=solver.test_nets[0].blobs['loss'].data
        test_acc[int(it // test_interval)] = correct /30
        test_loss[int(it // test_interval)]=valoss/30
        print('test loss', test_loss[int(it // test_interval)], 'acc', test_acc[int(it // test_interval)], 'train loss', train_loss[it] )


#plot(np.power(s.gamma,arange(1,(int(niter)+1),1))*s.base_lr, train_loss)
sys.stdout.close()
sys.stdout = tmp

_, ax1 = subplots()
ax2 = ax1.twinx()
ax1.plot(arange(niter), train_loss, 'b', label='train loss')
ax1.plot(test_interval * arange(len(test_acc)), test_loss, 'y', label='test loss')
ax2.plot(test_interval * arange(len(test_acc)), test_acc, 'r', label='test accuracy')
ax1.set_xlabel('iteration')
ax1.set_ylabel('train loss')
ax1.legend(('trainloss', 'test loss'))
ax2.set_ylabel('test accuracy')
ax2.legend(['test accuracy'], loc='upper center')
ax2.set_title('Custom Test Accuracy: {:.2f}'.format(test_acc[-1]))
savefig('SDML576_train2_r/Unet28_Cleaned576_Dice1_baselR' +str(s.base_lr)+'gamma'+str(s.gamma)+'.png')

_, ax1 = subplots()
ax2 = ax1.twinx()
ax1.plot(arange(test_interval,niter), train_loss[int(test_interval):])
ax1.plot(test_interval * arange(1,len(test_acc)), test_loss[1:])
ax2.plot(test_interval * arange(1,len(test_acc)), test_acc[1:], 'r')
ax1.set_xlabel('iteration')
ax1.set_ylabel('train loss')
ax2.set_ylabel('test accuracy')
ax2.set_title('Custom Test Accuracy: {:.2f}'.format(test_acc[-1]))
savefig('SDML576_train2_r/Unet28_Cleaned576_Dice1_baselR' +str(s.base_lr)+'gamma'+str(s.gamma)+'LossCrop.png')


#plot(np.power(s.gamma,arange(1,(int(niter)+1),1))*s.base_lr, train_loss)
#plt.show()

fig, (ax1, ax2) = plt.subplots(figsize=(10, 2), ncols=2)
pos = ax1.imshow(solver.test_nets[0].blobs['score'].data.argmax(1)[0])
fig.colorbar(pos, ax=ax1)
pos2 = ax2.imshow(solver.test_nets[0].blobs['label'].data[0][0])
fig.colorbar(pos2, ax=ax2)
#pos3 = ax3.imshow(solver.test_nets[0].blobs['score'].data.argmax(1)[2])
#fig.colorbar(pos3, ax=ax3)
plt.show()
fig.savefig('SDML576_train2_r/Unet28_Cleaned576_Dice1_baselR' +str(s.base_lr)+'gamma'+str(s.gamma)+'score.png')

solver.test_nets[0].forward()
fig, (ax1, ax2) = plt.subplots(figsize=(10, 2), ncols=2)
pos = ax1.imshow(solver.test_nets[0].blobs['score'].data.argmax(1)[0])
fig.colorbar(pos, ax=ax1)
pos2 = ax2.imshow(solver.test_nets[0].blobs['label'].data[0][0])
fig.colorbar(pos2, ax=ax2)
##pos3 = ax3.imshow(solver.test_nets[0].blobs['label'].data[2][0])
#fig.colorbar(pos3, ax=ax3)
plt.show()
fig.savefig('SDML576_train2_r/Unet28_Cleaned576_Dice_baselR' +str(s.base_lr)+'gamma'+str(s.gamma)+'GT.png')

outfile='C:\\Users\\Lynda\\Documents\\caffe\\examples\\Unettest\\Unet28_Cleaned576_Dice1_baselR' +str(s.base_lr)+'gamma'+str(s.gamma)+'trainCurves.png'
matlabdictionary={"train_loss":train_loss, "test_loss": test_loss, "test_acc": test_acc}
sio.savemat(outfile, matlabdictionary)


