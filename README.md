Coursera Getting and Cleaning Data course Project
=================================================


### General Info

The goal of this project is to prepare tidy data that can be used for later analysis.
The data linked to from the course website represent data collected from the sensors of the Samsung Galaxy S II smartphone.

The experiments have been carried out with a group of 30 volunteers wearing a smartphone on the waist. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING). The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal was separated into Gravity and Body motion components.

In addition to the measured signals, the data set contains many computed variables such as: 

* Jerk - time differentiation of the acceleration and angular velocity (rate of change)
* Magnitude - Euclidean norm, sqrt(x^2 + y^2 + z^2)
* Angle between two vectors
* FFT - conversion into the frequency domain

and many others. A full description is available in the features_info.txt 

The dataset, needed for this project, is stored in this repository, so cloning the repo should provide one with both the dataset and the script. Should for any reason one need the original one - it can be downloaded from: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

### Project description 
R script called run_analysis.R that does the following: 

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Implementation details

The run_analysis.R is implemented as a function accepting the datafolder name, a logical flag to save the result to the file and a file name (see below in usage). 

The implementation is neither the most efficient nor most elegant. The main point was to make it work within my limited knowledge and experience with the R language at this point. I make use of four packages: data.table, dplyr, tidyr and reshape2. The function tries to load them and if unsuccessful - it will try to install them and then load. If anything goes wrong at this point the corresponding calls to library should make the function fail immediately. See discussion on 

http://yihui.name/en/2014/07/library-vs-require/

The function is very verbose. Almost every action is wrapped into a pair of cat() to give the user an indication of what it does. 

Step 1: The merging is done using a series of rbind with subsequent cbind

Step2: Since there is no a single interpretation of the Step 2 (see the discussions on the course forum), partially owing to the somewhat ambigous naming convention of the data set authors, here is my interpretation:

* 'measurement' corresponds to the direct output of the sensors - accelerometers and gyroscopes (preprocessed or filtered, for the purpose of this exercise).
* 'Jerks' ,'magnitudes' and 'angles' are computed quantities and as such do not satisfy the requirements of Step 2
* 'frequencies' are also derived quantities (computed through FFT) and as such do not satisfy the requirements of Step 2 
* variables from frequency and time domains can not be mixed within the same data set

This leaves us with features having initial 't', mean() or std() and no 'Mag' or 'Jerk' in their names.

Step 3: The activity names are assigned using factor().
Step 4: In this step we replace the column names with features' names. However to make the subsequent tidying possible the names at this point are slightly changed:
* the "()" are striped off as well as the 't' prefix
* hyphens '-' are replaced with periods '.'
* Periods '.' are inserted where missing

these manipulations result in following name change:
'tBodyAcc-mean()-X' --> 'Body.Acc.mean.X'

Step 5: This step is basically a melt-separate-spread chain, however I have chosen to compute the required averages a-priory using the aggregate() function, instead of combining this into the spread(). The reason is to be able to cross-check with the values posted on
https://class.coursera.org/getdata-016/forum/thread?thread_id=50#comment-123
by Brandon. 

The dataframe represents only two true variables (in the sense of tidy) - mean and standard deviation. The column names are actually combined factors. To tidy this dataframe, it is first melted, so that the column names are now values (rows) stored in a single column, alongside 'subject' and 'activity' columnes. The mean and std values are also molten into a single column. In the next step the column names are separated using the periods as separators and finally the dataframe is spread into its final form of seven columns, of which five are factors: 'subject', 'activity', ' signal.cmpnt', 'sensor', 'axis' and two variables: 'mean', 'std'.


### Usage
1. fork and clone the repo https://github.com/victorsalit/GCDcoursera
2. 
```R
source("run_analysis.R")
tidy <- run_analysis(datafolder = "UCI HAR Dataset", save = FALSE, fname = "tidy.txt")
```

```
Function arguments:
datafolder  a character string naming the data folder which is assumed to reside in the working directory.    
save        a logical controlling whether to export the result to a file.
fname       a character string naming the file to which to write the result in case save=TRUE.
```

Note1: to load the saved file directly use the read.table with the option header = TRUE
```R
fromfile <- read.table(file, header = TRUE)
```
Note2: the 'subject' column is a -factor- in the run_analysis output, but it is a -int- in the read.table output.
