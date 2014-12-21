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

datafolder <- file.path(current_dir,"UCI_HAR_Dataset")
trainfolder <- file.path(datafolder,"train")
testfolder <- file.path(datafolder,"test")
    
if(!file.exists(datafolder)){stop("Can't find the folder with data in the working directory.")}

# Step 1. reading and merging the data

# 1.1 Reading:
print("Found the Dataset folder, trying to read the data")

features   <- read.table(file.path(datafolder,"features.txt"))                      # measurements' labels 
activities <- read.table(file.path(datafolder,"activity_labels.txt"))             # activites' labels

data_train       <- read.table(file.path(trainfolder,"X_train.txt"))               # training data
activities_train <- read.table(file.path(trainfolder,"y_train.txt"))         # training activities' IDs
subjects_train   <- read.table(file.path(trainfolder,"subject_train.txt"))     # subjects' IDs

data_test       <- read.table(file.path(testfolder,"X_test.txt"))
activities_test <- read.table(file.path(testfolder,"y_test.txt"))
subjects_test   <- read.table(file.path(testfolder,"subject_test.txt"))

# 1.2 Merging:
print("reading completed, trying to merge")
my_data <- rbind(data_train,data_test)
my_act  <- rbind(activities_train,activities_test)
my_subj <- rbind(subjects_train,subjects_test)

# 2. extracting the mean and standard deviation
index_means_std <- grepl("^[t]",features[,2]) & !grepl("Mag",features[,2]) &
    (grepl("-mean()",features[,2], fixed=TRUE) | grepl("-std()",features[,2], fixed=TRUE))
meanstd         <- my_data[,index_means_std]

# 3. descriptive activity names
print("replacing the activity indices with corresponding labels")
activity <- factor(my_act[,1], labels = activities[,2])

# 4. descriptive variable names
# 4.1 removing the "BodyBody" typo
cnames<-gsub("()","",features[index_means_std,2],fixed=TRUE)
cnames<-gsub("-",".",cnames,fixed=TRUE)
cnames<-gsub("^t","",cnames)
cnames<-gsub("Body","Body.",cnames)
cnames<-gsub("Gravity","Gravity.",cnames)
cnames<-gsub("Jerk",".Jerk",cnames)
cnames<-gsub("Body.Acc.Jerk","BodyJerk.Acc",cnames)
cnames<-gsub("Body.Gyro.Jerk","BodyJerk.Gyro",cnames)


# 4.3 replacing the hyphen with period and replacing the column names
colnames(meanstd)<-cnames



# 5. tidying
library(data.table)
library(dplyr)
library(tidyr)

# 5.1 complete the dataframe
merged <- cbind(my_subj,activity,meanstd)
names(merged)[1] <- "subject"

# 5.2 computing the averages
meaned <- aggregate(merged[,3:(length(cnames)+2)],by=list(subject=merged$subject,activity=merged$activity),mean)
meaned<-data.table(meaned)
setkey(meaned,subject,activity)

# 5.3 melting
library(reshape2)
md<-melt(meaned,id=c("subject","activity"))
tidier <- separate(md,variable,into=c("SignalSource","Measurement","Stats","Axis"),sep = "\\.")
tidy <- spread(tidier,Stats,value)
setkey(tidy,subject,activity,SignalSource,Measurement,Axis)
