library(data.table)
library(dplyr)
library(quantmod)

##1 DOWNLOADING AND UNZIPPING DATA ##

if(!file.exists("./data")){dir.create("./data")}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile = "./data/Dataset.zip")

## Unzip data ##

unzip(zipfile = "./data/Dataset.zip")

##2 MERGES THE TRAINING AND TEST SETS TO ONE DATASET ##

  #reading training tables

x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

  #reading testing tables

x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

  #reading feature vector

features <- read.table("./data/UCI HAR Dataset/features.txt")

  #reading activity labels

activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")


  ## ASSIGNING COLUMN NAMES ##

colnames(x_train) <- features[,2] 
colnames(y_train) <- "activityId"
colnames(subject_train) <- "subjectId"

colnames(x_test) <- features[,2]
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"

colnames(activityLabels) <- c("activityId" ,"activityType")


   ## Merging all data set into one 

mrg_train <- cbind(y_train, subject_train, x_train)
mrg_test  <- cbind(y_test, subject_test, x_test)

setAllInOne <- rbind(mrg_train, mrg_test)

   ## EXTRACTING ONLY THE MEASUREMENTS ON MEAN AND STD FOR EACH MEASUREMENT##

  # reading columns

colNames <- colnames(setAllInOne)

  # create vector for defining id, mean and std 

mean_and_std <- (grepl("activityId" , colNames) | 
                   grepl("subjectId" , colNames) | 
                   grepl("mean.." , colNames) | 
                   grepl("std.." , colNames) )

  # making subset on setAllInOne

setForMeanAndStd <- setAllInOne[, mean_and_std == TRUE]

  ## 4 USES DESCRIPTIVE ACTIVITY NAMES TO NAME THE ACTIVITIES IN THE DATA SET ##


setWithActivityNames <- merge(setForMeanAndStd, activityLabels,by= "activityId", all.x=TRUE)


head(setAllInOne$activity, 30)

names(setAllInOne) <- gsub("^t" , "time" ,names(setAllInOne))
names(setAllInOne) <- gsub("^f" , "frequency" ,names(setAllInOne))
names(setAllInOne) <- gsub("^Acc" , "Accuracy" ,names(setAllInOne))
names(setAllInOne) <- gsub("^Gyro" , "Gyroscope" ,names(setAllInOne))
names(setAllInOne) <- gsub("^Mag" , "Magnitude" ,names(setAllInOne))
names(setAllInOne) <- gsub("^BodyBody" , "Body" ,names(setAllInOne))

names(setAllInOne)

    
## 5 Creating a second, independent tidy data set with the average of each variable for each activity and each subject:      

  # making second tidy data set

secTidySet <- aggregate(. ~subjectId + activityId, setWithActivityNames, mean)
secTidySet <- secTidySet[order(secTidySet$subjectId, secTidySet$activityId),]

  # writing second tidy data set in txt file

write.table(secTidySet, "secTidySet.txt", row.name=FALSE)

















