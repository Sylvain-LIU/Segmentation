from pyAudioAnalysis import audioBasicIO
from pyAudioAnalysis import audioFeatureExtraction
import numpy as np
import math
import matplotlib.pyplot as plt


[Fs, x] = audioBasicIO.readAudioFile("data/diarizationExample.wav")

TIME_OF_WINDOW = 0.050	#a window = 0.05s
TIME_OF_STEP = 0.025		#step = 0.01s
SIZE_OF_WINDOW = int(TIME_OF_WINDOW * Fs)	#the number of frame for one window
SIZE_OF_STEP = int(TIME_OF_STEP * Fs)		#the number of frame for one step
BLOCK_SIZE = 4		#a block has (6 * SIZE_OF_STEP) frame
BLOCK_STEP = 2



# variables 
END_OF_FILE = 0
FIRST_PAIR = 1
INDEX_BOUCLE = 1

# feature extraction from the library pyAudioAnalysis
attribute = audioFeatureExtraction.stFeatureExtraction(x, Fs, SIZE_OF_WINDOW, SIZE_OF_STEP)

# relationship between the similarity and the timestamp in the audio
relation = [[1 for col in range(2)] for row in range(attribute.shape[1]/BLOCK_STEP)] 


def getMFCCs(block_start, block_end):
	return attribute[8:20,block_start:block_end+1]

def gauss(x, mean, cov):
	[n, d] = x.shape
	[j, k] = cov.shape
	if (j != n) | (k != n):
		raise Exception("Dimension of the covariance matrix and data should match")
	invcov = cov.T
	mean = np.reshape(mean, (1, n))

	x = x - (np.ones((d, 1))*mean).T
	fact = np.sum(((np.dot(invcov, x))*x), axis = 1)

	y = np.exp(-0.5*fact)

	y = np.divide(y, math.pow((2*math.pi), n)*np.std(cov))

	return y

def getCutpoints(relation):
	return 0


while (END_OF_FILE == 0):
	if (FIRST_PAIR == 1):
		# for the first pari of the block
		block_i_index_start = 0
		block_i_index_end = BLOCK_SIZE
		block_i_attribute = getMFCCs(block_i_index_start, block_i_index_end)


		block_i_mean = np.mean(block_i_attribute, axis=1)
		block_i_cov = np.cov(block_i_attribute)
		block_i_log_like = np.log(gauss(block_i_attribute, mean=block_i_mean, cov=block_i_cov))



		block_j_index_start = block_i_index_end + 1
		block_j_index_end = block_j_index_start + BLOCK_SIZE - 1
		block_j_attribute = getMFCCs(block_j_index_start, block_j_index_end)


		block_j_mean = np.mean(block_j_attribute, axis=1)
		block_j_cov = np.cov(block_j_attribute)
		block_j_log_like = np.log(gauss(block_j_attribute, mean=block_j_mean, cov=block_j_cov))


		FIRST_PAIR = 0
	else:
		#for the rest of the block
		block_j_index_start += BLOCK_STEP
		block_j_index_end += BLOCK_STEP

		new_attribute = getMFCCs(block_j_index_end-BLOCK_STEP+1, block_j_index_end)

		#the following code is for the object that to avoid recalculate the overlap between the block after moved and before moved
		block_i_index_start += BLOCK_STEP
		block_i_index_end += BLOCK_STEP
		block_i_attribute[:,0:block_i_attribute.shape[1]-new_attribute.shape[1]] = block_i_attribute[:,new_attribute.shape[1]:block_i_attribute.shape[1]]
		block_i_attribute[:,block_i_attribute.shape[1]-new_attribute.shape[1]:block_i_attribute.shape[1]] = block_j_attribute[:,0:new_attribute.shape[1]]

		block_i_mean = np.mean(block_i_attribute, axis=1)
		block_i_cov = np.cov(block_i_attribute)
		block_i_log_like = np.log(gauss(block_i_attribute, mean=block_i_mean, cov=block_i_cov))


		block_j_attribute[:,0:block_j_attribute.shape[1]-new_attribute.shape[1]] = block_j_attribute[:,new_attribute.shape[1]:block_j_attribute.shape[1]]
		block_j_attribute[:,block_j_attribute.shape[1]-new_attribute.shape[1]:block_j_attribute.shape[1]] = new_attribute[:,0:new_attribute.shape[1]]

		block_j_mean = np.mean(block_j_attribute, axis=1)
		block_j_cov = np.cov(block_j_attribute)
		block_j_log_like = np.log(gauss(block_j_attribute, mean=block_j_mean, cov=block_j_cov))


	block_union_index_start = block_i_index_start
	block_union_index_end = block_j_index_end
	block_union_attribute = np.concatenate((block_i_attribute, block_j_attribute), axis = 1)
	block_union_mean = np.mean(block_union_attribute, axis=1)
	block_union_cov = np.cov(block_union_attribute)
	block_union_log_like = np.log(gauss(block_union_attribute, mean=block_union_mean, cov=block_union_cov))

	relation[INDEX_BOUCLE-1][0] = np.sum(block_i_log_like) + np.sum(block_j_log_like) - np.sum(block_union_log_like)
	relation[INDEX_BOUCLE-1][1] = (block_i_index_end + block_j_index_start) / 2 * TIME_OF_STEP


	INDEX_BOUCLE += 1

	if block_j_index_end + BLOCK_STEP > attribute.shape[1]:
		END_OF_FILE = 1

x = []
y = []

relation_new = filter(lambda t: t[1] != 1, relation)

for i in xrange(0,len(relation_new)-1):
	x.append(relation_new[i][0])
	y.append(relation_new[i][1])
	

plt.plot(y, x)
# plt.show()


relation_cut = filter(lambda t: t[0] >= 0, relation)

for item in relation_cut:
	print item