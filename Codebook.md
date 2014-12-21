Codebook for the GCD Project
============================

The Tidy.txt contains the tidy dataset from the function run_analysis.R. It contains only the Time Domain data as follows from the requirements for measurements. It does not contain any calculated quantities such as angles, magnitudes or jerks. For detailed discussion see Readme.

The dataset containes the following seven columns, obtained by metling an spreading the original dataset: 

1. subject - a factor with 30 levels representing a test subject id, coded as 's01'... 's30'.
2. activity - a factor with 6 levels representing the activity performed by the test subject during the measurement. The labels are: 'WALKING', 'WALKING_UPSTAIRS', 'WALKING_DOWNSTAIRS', 'SITTING', 'STANDING', 'LAYING'.
3. signal.cmpnt - a factor with two levels representing the component of the measured signal encoded as 'Body' and 'Gravity'.
4. sensor - a factor with two levels representing the smartphone sensor used to obtain the signal, encoded as 'Acc' for accelerometer and 'Gyro' for gyroscope.
5. axis - a factor with three levels representing the corresponding measurement axis ecoded as 'X', 'Y' and 'Z'. For accelerometer signal this should be read as 'acceleration *along* the X axis', whereas for the gyroscope signal this should be read as 'angular velocity *about* the X axis'.
6. mean - mean measurement, averaged for each activity and each subject.
7. std - std measurement, averaged for each activity and each subject.

The above column names were obtained by the following manipulations of the original features names:

* the "()" were striped off as well as the 't' prefix
* hyphens '-' were replaced with periods '.'
* Periods '.' Were inserted where missing

these manipulations resulted in following name change:
'tBodyAcc-mean()-X' --> 'Body.Acc.mean.X'. The periodes were then used to separate the factors from the variables.

