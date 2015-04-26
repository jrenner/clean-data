#Getting and Cleaning Data - Course Project Part 2

The main script in this repo is `run_analysis.R`

The script depends on the Human Activity Recognition data set from [UCI Machine Learning](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

Extract the data into the cloned repository directory.

The script will read all the test and training data from the appropriate directories (once you have extraced the data there) and output a file `tidy_data_mean_per_act_per_subj.txt`

This file is a tab delimited file with numbers indicating the mean value of each variable for each activity for every subject.
