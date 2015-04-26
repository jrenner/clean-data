library("plyr")

data_dir <- "UCI HAR Dataset"

data_file <- function(path) {
  paste(data_dir, path, sep="/")
}

x_test_file <- data_file("test/X_test.txt")
x_train_file <- data_file("train/X_train.txt")
features_file <- data_file("features.txt")
activity_labels_file <- data_file("activity_labels.txt")
test_activities_file <- data_file("test/y_test.txt")
train_activities_file <- data_file("train/y_train.txt")
subject_test_file <- data_file("test/subject_test.txt")
subject_train_file <- data_file("train/subject_train.txt")

# combine train and test data sets into single data set
train_dat <- read.table(x_train_file)
test_dat <- read.table(x_test_file)
combined_dat <- rbind(train_dat, test_dat)

# create new column for feature names
feature_names_df <- read.table(features_file)
feature_names_factor <- feature_names_df[[2]]
colnames(combined_dat) <- feature_names_factor

# make names more readable for humans
cnames <- colnames(combined_dat)
cnames <- gsub("^t", "TIME_", cnames)
cnames <- gsub("^f", "FREQ_", cnames)
cnames <- gsub("-", "_", cnames)
cnames <- gsub("mean", "MEAN", cnames, ignore.case=TRUE)
cnames <- gsub("std", "STDDEV", cnames, ignore.case=TRUE)
cnames <- gsub("\\(", "", cnames)
cnames <- gsub("\\)", "", cnames)
cnames <- gsub("BODYBODY", "BODY", cnames, ignore.case=TRUE)
colnames(combined_dat) <- cnames

# create a mapping of activity id to activity name
activity_names <- read.table(activity_labels_file)
colnames(activity_names) <- c("activity_ID", "activity_NAME")

# create list of activities with names added from activity_names
test_act <- read.table(test_activities_file)
train_act <- read.table(train_activities_file)
combined_act <- rbind(test_act, train_act)
colnames(combined_act) <- c("activity_ID")
all_act <- join(activity_names, combined_act, by="activity_ID")

# now put the activity names into the main data set
combined_dat <- cbind(activity=all_act$activity_NAME, combined_dat)

# take only the mean, stddev, and activity names from teh data set
mean_std_act <- combined_dat[,grep("mean|stddev|activity", colnames(combined_dat), ignore.case=TRUE)]

# get subject ids and include into sub-selected data for MEAN, STDDEV and Activity name
subject_test <- read.table(subject_test_file)
subject_train <- read.table(subject_train_file)
combined_subj <- rbind(subject_test, subject_train)
colnames(combined_subj) <- c("subject")
mean_std_act <- cbind(combined_subj, mean_std_act)

mean_std_act_sorted <- mean_std_act[order(mean_std_act$subject, mean_std_act$activity),]

# create temporary subset of data with no activity column
# this avoids generating warnings with aggregate function for trying to find the mean
# of a non-numeric column
final_no_act <- mean_std_act_sorted[,names(mean_std_act_sorted) != 'activity']

# find the mean for each activity for each subject
tidy <- aggregate(final_no_act[,names(final_no_act) != 'subject'],
                  by=list(activity=mean_std_act_sorted$activity,
                          subject=final_no_act$subject), mean)


# write data to file
write.table(tidy, './tidy_data_mean_per_act_per_subj.txt',row.names=TRUE,sep='\t');