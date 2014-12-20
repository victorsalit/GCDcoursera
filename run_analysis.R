#run_analysis.R
#
# R script for tidying the data collected from the accelerometers from the Samsung Galaxy S smartphone
#
# Course: Getting and Cleaning Data
# Author: Victor Salit


# Step 0. houskeeping
# The data folder must reside in the same working directory were this script resides and runs.

rm(list=ls())
current_dir<-getwd()
print(paste("current working directory: ", current_dir,sep=" "))
if(!file.exists("UCI HAR Dataset")){stop("Can't find the folder with data in the working directory.")}

# Step 1. reading and merging the data

# 1.1 Reading:
print("Found the Dataset folder, trying to read the data")

features   <- read.table("./UCI HAR Dataset/features.txt")                      # measurements' labels 
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")             # activites' labels

data_train       <- read.table("./UCI HAR Dataset/train/X_train.txt")               # training data
activities_train <- read.table("./UCI HAR Dataset/train/y_train.txt")         # training activities' IDs
subjects_train   <- read.table("./UCI HAR Dataset/train/subject_train.txt")     # subjects' IDs

data_test       <- read.table("./UCI HAR Dataset/test/X_test.txt")
activities_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjects_test   <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# 1.2 Merging:
print("reading completed, trying to merge")
my_data <- rbind(data_train,data_test)
my_act  <- rbind(activities_train,activities_test)
my_subj <- rbind(subjects_train,subjects_test)
#subject <- factor(my_subj,1:30)

# 2. extracting the mean and standard deviation
index_means_std <- grepl("mean",features[,2]) | grepl("std",features[,2])
meanstd         <- my_data[,index_means_std]

# 3. descriptive activity names
print("replacing the activity indices with corresponding labels")
activity <- factor(my_act[,1], labels = activities[,2])

# 4. descriptive variable names
colnames(meanstd)<-features[index_means_std,2]

# 5. tidying
library(data.table)
library(dplyr)
library(tidyr)
# 5.1 complete the dataframe
merged <- cbind(my_subj,activity,meanstd)
names(merged)[1] <- "subject"
merged<-tbl_df(merged)

# 5.2 computing the averages and removing identicals
merged <- group_by(merged,subject,activity)
merged <- merged[order(merged$subject,merged$activity),]
dt<-data.table(merged)
for(cols in names(merged))
tidydata<-mutate(merged,"tBodyAcc-mean()-X":"fBodyBodyGyroJerkMag-meanFreq()",mean("tBodyAcc-mean()-X":"fBodyBodyGyroJerkMag-meanFreq()"))
  
# 5.3 adding new columns
# 5.4 spreading the data