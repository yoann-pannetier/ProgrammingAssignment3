# Getting and Cleaning Data Project John Hopkins Coursera:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


library("dplyr")

#Initialisation and Data download
wd <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(wd, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")


# 1. Merges the training and the test sets to create one data set.

# load each table into an object and use the rbind function to combine the data into a mergedDataset object

features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Subject, Y, X)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

ExtractData <- Merged_Data %>% select(subject, code, contains("mean"), contains("std"))


# 3. Uses descriptive activity names to name the activities in the data set

ExtractData$code <- activities[ExtractData$code, 2]


# 4. Appropriately labels the data set with descriptive variable names.

names(ExtractData)[2] = "activity"
names(ExtractData)<-gsub("Acc", "Accelerometer", names(ExtractData))
names(ExtractData)<-gsub("Gyro", "Gyroscope", names(ExtractData))
names(ExtractData)<-gsub("BodyBody", "Body", names(ExtractData))
names(ExtractData)<-gsub("Mag", "Magnitude", names(ExtractData))
names(ExtractData)<-gsub("^t", "Time", names(ExtractData))
names(ExtractData)<-gsub("^f", "Frequency", names(ExtractData))
names(ExtractData)<-gsub("tBody", "TimeBody", names(ExtractData))
names(ExtractData)<-gsub("-mean()", "Mean", names(ExtractData), ignore.case = TRUE)
names(ExtractData)<-gsub("-std()", "STD", names(ExtractData), ignore.case = TRUE)
names(ExtractData)<-gsub("-freq()", "Frequency", names(ExtractData), ignore.case = TRUE)
names(ExtractData)<-gsub("angle", "Angle", names(ExtractData))
names(ExtractData)<-gsub("gravity", "Gravity", names(ExtractData))


# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

TidyData <- ExtractData %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(TidyData, "TidyData.txt", row.name=FALSE, sep = "\t")

