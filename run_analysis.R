## This script uses features of the data.table, dplyr, reshape2
## packages to transform data obtained from the Human Activity 
## Recognition Using Smartphones project into a condensed and tidy 
## dataset.
## 

## It must be run in the directory containing the 
## "UCI HAR Dataset" directory.
## More details can be found in the README file.

library(plyr); library(dplyr)
library(data.table)
library(reshape2)

## gather the required data into R session
# test set data 
testd <- data.table(   
    read.table("./UCI HAR Dataset/test/X_test.txt"))
#test set activity codes
testActs <- data.table(
    read.table("./UCI HAR Dataset/test/y_test.txt"))
#test set subject codes
testSubjects <- data.table( 
    read.table("./UCI HAR Dataset/test/subject_test.txt"))

#train set data 
traind <- data.table( 
    read.table("./UCI HAR Dataset/train/X_train.txt"))
#train set activity codes
trainActs <- data.table(    
    read.table("./UCI HAR Dataset/train/y_train.txt"))
#train set subject codes
trainSubjects <- data.table(   
    read.table("./UCI HAR Dataset/train/subject_train.txt"))

# activity labels
actLabels <-    
    read.table("./UCI HAR Dataset/activity_labels.txt")
# feature labels
features <-     
    read.table("./UCI HAR Dataset/features.txt", row.names=1,
               stringsAsFactors=FALSE)[[1]]


## apply feature names to data
setnames(testd, features)
setnames(traind, features)

## attach activity and subject codes
testd[, subject:=testSubjects][, actnum:=testActs]
traind[, subject:=trainSubjects][, actnum:=trainActs]

## combine data sets
alld <- rbind(testd, traind)

## select mean and standard deviation data
seld <- select(alld, subject, actnum, 
              contains("mean("), contains("std(") )

## apply labels for activities
names(actLabels) <- c("actnum", "activity")        
seld <- merge(seld,actLabels, by="actnum")[, actnum:=NULL]

## condense to averages by subject/activity
melted <- melt(seld, c("subject", "activity"))

avgs <- dcast.data.table(melted, 
    activity + subject ~ variable, mean)

## write to file "tidy_avgs.txt"
write.table(avgs, "tidy_avgs.txt", row.name=FALSE)

