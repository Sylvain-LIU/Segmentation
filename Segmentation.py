from pyAudioAnalysis import audioBasicIO
from pyAudioAnalysis import audioFeatureExtraction
import numpy as np
import math
import matplotlib.pyplot as plt

# main process
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

def getMFCCs(block_start, block_end):
	return attribute[8:20,block_start:block_end+1]

def getMFCCsFromTime(moment_start, moment_end):
	block_start = int(moment_start / BLOCK_STEP / TIME_OF_STEP - 1)
	block_end = int(moment_end / BLOCK_STEP / TIME_OF_STEP - 1)
	return getMFCCs(block_start, block_end)

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


# feature extraction from the library pyAudioAnalysis
attribute = audioFeatureExtraction.stFeatureExtraction(x, Fs, SIZE_OF_WINDOW, SIZE_OF_STEP)

# relationship between the similarity and the timestamp in the audio
relation = [[1 for col in range(2)] for row in range(attribute.shape[1]/BLOCK_STEP)]

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

# cut the audio
relation_cut = filter(lambda t: t[0] > 0, relation)

print "=========The data after cutting==========="
for item in relation_cut:
	print item



# print getMFCCsFromTime(0.4, 4.0).shape


#===========Kmeans Definition=====================
#calculate Euclidean distance
def euclDistance(vector1, vector2):
	return sqrt(sum(power(vector2 - vector1, 2)))

# init centroids with random samples
def initCentroids(dataSet, k):
	numSamples, dim = dataSet.shape
	centroids = zeros((k, dim))
	for i in range(k):
		index = int(random.uniform(0, numSamples))
		centroids[i, :] = dataSet[index, :]
	return centroids

# k-means cluster
def kmeans(dataSet, k):
	numSamples = dataSet.shape[0]
	# first column stores which cluster this sample belongs to,
	# second column stores the error between this sample and its centroid
	clusterAssment = mat(zeros((numSamples, 2)))
	clusterChanged = True

	## step 1: init centroids
	centroids = initCentroids(dataSet, k)

	while clusterChanged:
		clusterChanged = False
		## for each sample
		for i in xrange(numSamples):
			minDist  = 100000.0
			minIndex = 0
			## for each centroid
			## step 2: find the centroid who is closest
			for j in range(k):
				distance = euclDistance(centroids[j, :], dataSet[i, :])
				if distance < minDist:
					minDist  = distance
					minIndex = j

			## step 3: update its cluster
			if clusterAssment[i, 0] != minIndex:
				clusterChanged = True
				clusterAssment[i, :] = minIndex, minDist**2

		## step 4: update centroids
		for j in range(k):
			pointsInCluster = dataSet[nonzero(clusterAssment[:, 0].A == j)[0]]
			centroids[j, :] = mean(pointsInCluster, axis = 0)

	print 'cluster complete!'
	return centroids, clusterAssment

def abs (input):
	if input <0 : return - input
	else : return input




print '======='

temprelation = []
for i in range(len(relation_cut)-3): #-3 because the last 3 numbers are meaningless
    temprelation.append([relation_cut[i][0],1])

#temprelation is a list which takes only first colum of relation_cut and add another colum which values are all 1
#This action alow to transefer the MFCC to a 2-dimension data which use for cluster


## step 1: load data
print "step 1: load data..."
dataSet = temprelation


# step 2: clustering...
print "step 2: clustering..."
dataSet = mat(dataSet)
k = 4
centroids, clusterAssment = kmeans(dataSet, k)
classification =[]
for indexi in range(k):
	classification .append(centroids[indexi][0])

## step 3: Mark speaker to each block
relation_cut_regonize = [] #This list is to store the information with different speakers
for indexj in range(len(dataSet)):
	min1 = abs(relation_cut[indexj][0]-classification[0])
	min2 = abs(relation_cut[indexj][0]-classification[1])
	min3 = abs(relation_cut[indexj][0]-classification[2])
	min4 = abs(relation_cut[indexj][0]-classification[3])
	if min1<min2 and min1 < min3 and min1<min4:
		relation_cut_regonize.append([relation_cut[indexj],"Speaker1"])
	else:
		if min2<min1 and min2 < min3 and min2<min4:
			relation_cut_regonize.append([relation_cut[indexj],"Speaker2"])
		else:
			if min3<min1 and min3 < min2 and min3<min4:
				relation_cut_regonize.append([relation_cut[indexj],"Speak3"])
			else:
				if min4<min1 and min4 < min2 and min4<min3:
					relation_cut_regonize.append([relation_cut[indexj],"Speak4"])


#step4: shows the result
print "=========The data after regonizing as 4 speakers==========="
for item in relation_cut_regonize:
	print item