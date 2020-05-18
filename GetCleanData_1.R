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

# 


extractDataset <- rbind(sapply(mergedDataset, mean) , sapply(mergedDataset, sd))
rownames(extractDataset) <- c("mean", "sd")


# 3. Uses descriptive activity names to name the activities in the data set
trainRefAct <- read.table(file.path(wd, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
testRefAct <- read.table(file.path(wd, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
activityRef <- rbind(trainRefAct, testRefAct)

activityLabels <- read.table(file.path(wd, "UCI HAR Dataset/activity_labels.txt"), col.names = c("activityRef", "activityName"))

activityNames <- merge(activityRef, activityLabels, by.x = "Activity", by.y = "activityRef", sort = FALSE)


trainRefSubject <- read.table(file.path(wd, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNumber"))
testRefSubject <- read.table(file.path(wd, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNumber"))
subjectRef <- rbind(trainRefSubject, testRefSubject)

mergedDatasetLabels <- cbind(subjectRef, activityNames$activityName, mergedDataset)


# 4. Appropriately labels the data set with descriptive variable names.
features <- read.table(file.path(wd, "UCI HAR Dataset/features.txt"), col.names = c("featureRef", "featureName"))
featureLabels <- as.character(t(features$featureName))
colnames(extractDataset) <- featureLabels
colnames(mergedDataset) <- featureLabels

mergedDatasetLabels <- cbind(subjectRef, activityNames$activityName, mergedDataset)


# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

mergedDatasetNext <- cbind(subjectRef, activityNames$activityName, mergedDataset)
mergedDatasetNext <- melt(mergedDatasetNext, id = c("SubjectNumber", "activityNames$activityName"))
mergedDatasetNext <- dcast(mergedDatasetNext, SubjectNumber + activityNames$activityName ~ variable, fun.aggregate = mean)

export <- data.table(mergedDatasetNext)
write.csv(export, file="TidyData.csv")
