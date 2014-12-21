# This script will prepare two tidy data sets:
        ## a set of non-aggregated but cleaned data
        ## a set of data aggregated by the means of each combination of subject, 
                # activity, and feature.

# Requirements: these files must be in the working directory:
        # activity_labels.txt
        # features.txt
        # subject_test.txt
        # subject_train.txt
        # X_test.txt
        # X_train.txt
        # y_test.txt
        # y_train.txt

# Call the required packages
library(plyr)
library(dplyr)
library(tidyr)

# Create data frames by reading in data from several text files stored in the working directory
activity_labels <- read.table("./activity_labels.txt")
features <- read.table("./features.txt")
subject_test <- read.table("./subject_test.txt")
subject_train <- read.table("./subject_train.txt")
X_test <- read.table("./X_test.txt")
y_test <- read.table("./y_test.txt")
X_train <- read.table("./X_train.txt")
y_train <- read.table("./y_train.txt")

# Fix syntax of name values in "features"
features$V2 <- sub("BodyBody", "Body", features$V2)
features$V2 <- sub("^t", "time", features$V2); 
features$V2 <- sub("^f", "frequency", features$V2)

# Add column names to the "X_train" and "X_test" dataframes from "features",
# and correct replace syntax errors with an acceptable character: "."
names(X_train) <- make.names((features$V2), unique=TRUE)
names(X_test) <- make.names((features$V2), unique=TRUE)

# The next section is for adding columns from the "subject_" and "y_" tables to the appropriate "X_" tables. 
# Because of the re-ordering behavior of the plyr function join(), we need to first pull these columns into the "X_" data frames before joining data from the "activity_labels" data.

# Add column name "activityclass" to "y_test" and "y_train"
names(y_test) <- "activityclass"
names(y_train) <- "activityclass"
# Add column name "subject" to "subject_test" and "subject_train"
names(subject_test) <- "subject"
names(subject_train) <- "subject"
# Combine "activityclass" and "subject" columns from the "y_" and "Subject_" dataframes with their respective "X_" dataframes. 
# Change the class for "activityclass" and "subject" to factor while doing this.
X_test$activityclass <- factor(y_test$activityclass)
X_test$subject <- factor(subject_test$subject)
X_train$activityclass <- factor(y_train$activityclass)
X_train$subject <- factor(subject_train$subject)
# Combine the rows from the "X_" data frames into a single new data frame.
X_combined <- rbind(X_test, X_train)
# Add column names to data frame "activity_labels", and change class of "activityclass" to factor.
names(activity_labels) <- c("activityclass", "activity")
activity_labels$activityclass <- factor(activity_labels$activityclass)
# Join the "activitylabel" column from "activity_labels" by matching to the "actvityclass" columns in "X_combined".
X_combined <- join(X_combined, activity_labels)

# Create cleaned data set by passing only needed columns to new data frame.
# These are any containing ".mean.." or ".std..", "subject" and "activity".
X_fixed <- select(X_combined,contains(".mean.."), contains(".std.."), subject, activity)

# Create tidy data set for the selected columns
X_tidy <- gather(X_fixed, feature, measurement, -subject, -activity)

# Create summary of measurement means for data grouped by subject-activity-feature.
X_final <- summarise_each(group_by(X_tidy, subject, activity, feature),funs(mean))
# Convert columns "subject", "activity", and "feature" to a sortable class, and put into order based on subject, then activity, then feature
X_final$subject <- as.numeric(X_final$subject)
X_final$activity <- as.character(X_final$activity)
X_final$feature <- as.character(X_final$feature)
X_final <- arrange(X_final, subject, activity, feature)
write.table(X_final, file = "./HARUStudy.txt", row.name = FALSE)