---
output: html_document
---
README: GettingCleaningDataCourseProject
================================

1, This file contains an overview of the raw data files, and the process followed in the **run_analysis.R** code to clean the data and prepare it as a tidy data set. A description of the resulting tidy data set is provided.

## Raw Data Description
2. The raw data files were downloaded from this URL:
http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
to the R working directory. 

3. The raw data consist of eight files, as described below. Data are distributed to two separate sets, identified as "test" and "train". Each test set has supporting meta-data files containing lists of subject identifiers and activity label identifiers.  
+ *activity_labels.txt*: activity class labels with their activity name
+ *features*: list of 561 types of observations taken for each subject and activity.
+ *subject_test.txt*: list of subject identifiers to be matched to each row of observations in the test data.
+ *subject_train.txt*: list of subject identifiers to be matched to each row of observations in the train data.
+ *X_test.txt*: observations per subject per activity from the test data set.
+ *X_train.txt*: observations per subject per activity from the train data set.
+ *y_test.txt*: list of activity identifiers to be matched to each row of observations in the test data.
+ *y_train.txt*: list of activity identifiers to be matched to each row of observations in the train data.

4. Data files were combined to create a data frame with these characteristics:
+ 561 variable names provided via the *features.txt* file,
+ a variable called **subject**, containing values from the "Subject_" files.
+ a variable called **activity**, containing values from the **y-** and **activity_labels** files.
+ 561 observations for each of the 10,299 rows of data coming from the **X-** files.

5. Variable names are described in detail in the accompanying CodeBook.md file. These names are descriptive for each type of observation, with a general format as follows, shown in camelCase: **domainObservationStatistic...Axis**
+ *domain* can be "time" or "frequency"
+ *Observation* is one of 561 observation types. Only a subset of these observations were passed on to the final tidy data set, and these are described in detail in the CodeBook.md.
+ *Statistic* either *mean* or *std*, corresponding to an average value or its standard deviation, respectively.
+ *Axis* refers to a dimensional orientation detected by sensors in the device used to gather data. Values are X, Y, or Z.

## Overview of the "run_analysis.R" code
6. The **run_analysis.R** code performs the following operations:
+ Three R packages are specifically opened for the analysis: plyr, dplyr, and tidyr.
+ The eight previously described data .txt files are read as data frames into the R environment from the working directory, and are suitably identified.
+ Duplications and vague labelling issues are resolved in the data frame *features* by substituting values through sub() functions.
+ The corrected values in *features* are applied as variable names to the data frames *X_test* and *X_train* using the make.names() function.
+ Specific column names are added to the data frames *y_test*, *y_train*, *subject_test*, and *subject_train*.
+ Columns from the *y-* and *Subject_* data frames are copied to the respective *X_* data frames, and are coerced to factor in the process.
+ With both *X_* data frames now given column names, the *X_test* and *X_train* data frames are combined via rbind() and the resulting data frame is called *X_combined*.
+ The columns in the data frame *activity_labels* are given names and converted to factors. 
+ The data frames *activity_labels* and *X_combined* are joined based on the key column activityclass found in each data frame. This pulls the column of activity names into the *X_combined* data frame. 
+ A new data frame is created by using the select() function along with regular expressions and metacharacters to capture only the columns with names matching the required criteria: containing **.mean..**, **.std..**, **subject**, or **activity**. This single command created a 68-column data frame called *X_fixed*.
+ *X_fixed* does not meet the tidy data requirement of one column per variable. There are 66 columns that have column names that are values, and should be in a variable called **feature**. The gather() function is used to create a "tall and skinny" data frame called *X_tidy* that brings these values into a single column. The corresponding numeric values in the 66 columns are brought into a column called **measurement** using the same command. The columns **subject** and **activity** are kept as columns of factors for the next step.
+ Using the dplyr functions group by() and summarize each(), the data are grouped by **subject**, **activity**, and **feature**, and then means are calculated for each combination of subject, activity, and feature. This results in a "tall and skinny" data frame called *X_final*.
+ Columns in *X_final" are coerced back into classes that are suitable for sorting, and the arrange() function is called to put the entire data frame in order first by subject, then activity, then feature.
+ Finally, a file **HARUStidy.txt** is written to the R working directory.