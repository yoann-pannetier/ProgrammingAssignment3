# Getting and Cleaning Data Project John Hopkins Coursera:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


library("dplyr")
library("reshape2")

#Initialisation and Data download
wd <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(wd, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")


# 1. Merges the training and the test sets to create one data set.

# load each table into an object and use the rbind function to combine the data into a mergedDataset object

train <- read.table(file.path(wd, "UCI HAR Dataset/train/X_train.txt"))
test <- read.table(file.path(wd, "UCI HAR Dataset/test/X_test.txt"))

mergedDataset <- rbind(train, test)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

# create a new object containing standard deviation and mean for each measurement calles extractDataset


extractDataset <- rbind(sapply(mergedDataset, mean) , sapply(mergedDataset, sd))
rownames(extractDataset) <- c("mean", "sd")


# 3. Uses descriptive activity names to name the activities in the data set

# capture activities for each measurement out of the y_train and y_test files and convert them into
# an activityNames object ready for use thank to the resolution kex activityLabels

trainRefAct <- read.table(file.path(wd, "UCI HAR Dataset/train/Y_train.txt"), 
                          col.names = c("Activity"))
testRefAct <- read.table(file.path(wd, "UCI HAR Dataset/test/Y_test.txt"), 
                         col.names = c("Activity"))
activityRef <- rbind(trainRefAct, testRefAct)

activityLabels <- read.table(file.path(wd, "UCI HAR Dataset/activity_labels.txt"), 
                             col.names = c("activityRef", "activityName"))

activityNames <- merge(activityRef, activityLabels, by.x = "Activity", by.y = "activityRef", sort = FALSE)


trainRefSubject <- read.table(file.path(wd, "UCI HAR Dataset/train/subject_train.txt"), 
                              col.names = c("SubjectNumber"))
testRefSubject <- read.table(file.path(wd, "UCI HAR Dataset/test/subject_test.txt"), 
                             col.names = c("SubjectNumber"))
subjectRef <- rbind(trainRefSubject, testRefSubject)

mergedDatasetLabels <- cbind(subjectRef, activityNames$activityName, mergedDataset)


# 4. Appropriately labels the data set with descriptive variable names.

# extract the fatures list from the file features.txt and apply it to the two datasets
# extractDataset and mergedDataset

features <- read.table(file.path(wd, "UCI HAR Dataset/features.txt"), 
                       col.names = c("featureRef", "featureName"))
featureLabels <- as.character(t(features$featureName))
colnames(extractDataset) <- featureLabels
colnames(mergedDataset) <- featureLabels

mergedDatasetLabels <- cbind(subjectRef, activityNames$activityName, mergedDataset)


# 5. From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable for each activity and each subject.

# apply the subject and activity key to the dataset and break it down to variables
# depending on SubjectNumer and activityName using melt and dcast functions

mergedDatasetNext <- cbind(subjectRef, activityNames$activityName, mergedDataset)
mergedDatasetNext <- melt(mergedDatasetNext, id = c("SubjectNumber", "activityNames$activityName"))
mergedDatasetNext <- dcast(mergedDatasetNext, SubjectNumber + activityNames$activityName ~ variable, 
                           fun.aggregate = mean)

write.csv(mergedDatasetNext, file="TidyData.csv")
