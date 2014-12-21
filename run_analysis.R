run_analysis <- function(datafolder = "UCI HAR Dataset", save = FALSE, fname = "tidy.txt"){
    #run_analysis.R
    #
    # A function for tidying the data collected from the sensors of the Samsung Galaxy S II smartphone
    #
    # Arguments:
    # datafolder  a character string naming the data folder which is assumed to reside in the working directory.    
    # save        a logical controlling whether to export the result to a file.
    # fname       a character string naming the file to which to write the result in case save=TRUE.
    #
    # Course: Getting and Cleaning Data
    # Author: Victor Salit
    
    # libraries/packages    
    if (!require(data.table)) {install.packages("data.table")}
    library(data.table)
    if (!require(dplyr)) {install.packages("dplyr")}
    library(dplyr)
    if (!require(tidyr)) {install.packages("tidyr")}
    library(tidyr)
    if (!require(reshape2)) {install.packages("reshape2")}
    library(reshape2)
    
    
    
    # Step 0. houskeeping
    # The data folder must reside in the same working directory were this script resides and runs.
    
    current_dir<-getwd()
    cat(paste("current working directory: ", current_dir,sep=" "),'\n')
    
    datafolder  <- file.path(current_dir,datafolder)
    trainfolder <- file.path(datafolder,"train")
    testfolder  <- file.path(datafolder,"test")
    
    
    # Step 1. reading and merging the data
    
    # 1.1 Reading:
    if(!file.exists(datafolder)){stop("Can't find the specified data folder in the working directory.")}
    cat("Found the Data folder\n")
    if(!file.exists(trainfolder)){stop("Can't find the subfolder with train data in the data folder.")}
    cat("Found the Train Dataset folder\n")
    if(!file.exists(testfolder)){stop("Can't find the subfolder with test data in the data folder.")}
    cat("Found the Test Dataset folder\n")
    
    cat('Step 1. Reading and merging the data:\n')
    
    cat("features.......... ")
    features   <- read.table(file.path(datafolder,"features.txt"))                  # measurements' labels 
    cat("done.\n")
    
    cat('activity_labels... ')
    activities <- read.table(file.path(datafolder,"activity_labels.txt"))           # activites' labels
    cat("done.\n")
    
    cat("x_train........... ")
    data_train       <- read.table(file.path(trainfolder,"X_train.txt"))            # training data
    cat("done.\n")
    
    cat('y_train........... ')
    activities_train <- read.table(file.path(trainfolder,"y_train.txt"))            # training activities' IDs
    cat("done.\n")
    
    cat('subject_train..... ')
    subjects_train   <- read.table(file.path(trainfolder,"subject_train.txt"))      # subjects' IDs
    cat("done.\n")
    
    cat('x_test............ ')
    data_test       <- read.table(file.path(testfolder,"X_test.txt"))
    cat("done.\n")
    
    cat('y_test............ ')
    activities_test <- read.table(file.path(testfolder,"y_test.txt"))
    cat("done.\n")
    
    cat('subject_test...... ')
    subjects_test   <- read.table(file.path(testfolder,"subject_test.txt"))
    cat("done.\n")
    
    # 1.2 Merging:
    cat("=== Merging:\n")
    cat('data (x).......... ')
    my_data <- rbind(data_train,data_test)
    cat("done.\n")
    cat('activitites (y)... ')
    my_act  <- rbind(activities_train,activities_test)
    cat("done.\n")
    cat('subjects ids...... ')
    my_subj <- rbind(subjects_train,subjects_test)
    cat("done.\n")
    df <- cbind(my_subj,my_act,my_data)
    
    
    # Step 2. "Extracts only the measurements on the mean and standard deviation for each measurement." 
    # see Readme for detailed explanations on this step
    # short: we extract only the time domain quantities (measurements),
    #        magnitudes, angles and jerks are computed quantities, frequencies too.
    
    
    cat("Step 2. Extracting the measurements on the mean and standard deviation for each measurement... ")
    index_means_std <- grepl("^[t]", features[,2]) & 
                      !grepl("Mag", features[,2])  &
                      !grepl("Jerk", features[,2])  &
                      (grepl("-mean()", features[,2], fixed=TRUE) | 
                       grepl("-std()", features[,2], fixed=TRUE))
    
    df <- df[,c(1, 2, which(index_means_std) + 2)] # offset of two columnes because of subj & activ
    cat("done.\n")
    
    
    # Step 3. descriptive activity names
    cat("Step 3. Replacing the activity indices with corresponding labels... ")
    df[,2] <- factor(df[,2], labels = activities[,2])
    cat('done.\n')
    
    
    # 4. descriptive variable names (features)
    # The column names are stored in the 'features' vector and can be extracted 
    # using the logical index vector computed in the step 2.
    # These names, however, must be slightly corrected not only because of style 
    # considerations, but to make the tidying easier later on. 
    #
    # In case one would like to tidy the frequency domain data, there might be a 
    # need to first remove the "BodyBody" typo with: 
    # cnames <- gsub("BodyBody", "Body", features[index_means_std,2], fixed=TRUE)
    
    cat("Step 4. Replacing the column names... ")
    cnames <- gsub("()", "", features[index_means_std,2], fixed=TRUE)  # remove "()"
    cnames <- gsub("-", ".", cnames, fixed=TRUE)                       # replace "-" with "."
    cnames <- gsub("^t", "", cnames)                                   # remove initial "t"
    cnames <- gsub("Body", "Body.", cnames)                            # insert "." after "Body"
    cnames <- gsub("Gravity", "Gravity.", cnames)                      # insert "." after "Gravity" 
    
    colnames(df) <- c("subject","activity",cnames)
    cat("done.\n")
    
    
    # Step 5. tidying
    
    cat("Step 5. Tidying the data... ")
    
    # computing the averages:
    # it is possible to include this step later into spreading the molten dataset,
    # however for debugging reasons it was beneficial to perform this step before 
    # final reshaping. The values in 'averaged' correspond to values posted on
    # https://class.coursera.org/getdata-016/forum/thread?thread_id=50#comment-123
    # by Brandon. 
    averaged <- aggregate(df[,3:(length(cnames)+2)],by=list(subject=df$subject,activity=df$activity),mean)
    averaged <- data.table(averaged)
    
    # tidying
    melted <- melt(averaged,id=c("subject","activity"))
    tidier <- separate(melted,variable,into=c("signal.cmpnt","sensor","stats","axis"),sep = "\\.")
    tidy <- spread(tidier,stats,value)
    
    # converting the non-variables to factors:
    tidy$subject <- paste("s", formatC(tidy$subject, width=2, flag="0"), sep="")
    tidy <- data.table(data.frame(unclass(tidy), stringsAsFactors = TRUE))
    setkey(tidy,subject,activity,signal.cmpnt,sensor,axis) # reordering
    cat("done.\n")
    
    # 6 Output
    if(save) {
        write.table(tidy,file=fname,row.names=FALSE)
        cat('The Data hase been written to ',fname,'\n')
    }
    cat("Analysis completed.\n")
    tidy
}