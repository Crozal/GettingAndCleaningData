#Validate Required Packages
if (!require("data.table")) {
        install.packages("data.table")
}
#Load Library
require("data.table")
#Set Work Directory
setwd("/Users/crozal/Desktop/Projects/Coursera/Getting and Cleaning Data/Project/")
##Raw data collection
#Download the Files
if(!file.exists("./Data")){dir.create("./Data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./data/Dataset.zip", method = "curl")
##Unzip the Files - Decompressing the data , the files are in the folder named UCI HAR Dataset
unzip(zipfile="./Data/Dataset.zip",exdir="./Project")
fSource<-file.path("./", "Data", "UCI HAR Dataset")
files<-list.files(fSource, recursive=TRUE)
#File List
files
##Read data from files and assign to data frames variables
#Read the Test and Train Activity files
dataActivityTest  <- read.table(file.path(fSource, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(fSource, "train", "Y_train.txt"),header = FALSE)
#Read the Subject Test and Train files
dataSubjectTrain <- read.table(file.path(fSource, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(fSource, "test" , "subject_test.txt"),header = FALSE)
#Read Fearures Test and Train files
dataFeaturesTest  <- read.table(file.path(fSource, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(fSource, "train", "X_train.txt"),header = FALSE)
#Display the properties of the Test and Train Data
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)
#Raw Data transformation
#Part 1. Merges the training and the test sets to create one data set
#Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
#2.set names to variables
names(dataSubject)<-c("Subject")
names(dataActivity)<- c("Activity")
dataFeaturesNames <- read.table(file.path(fSource, "features.txt"),head=FALSE)
names(dataFeaturesNames)<-c("Key","Descripcion")
names(dataFeatures)<- dataFeaturesNames$Descripcion
head(dataFeatures)
activityLabels <-  read.table(file.path(fSource, "activity_labels.txt"),head=FALSE)
names(activityLabels)<-c("Activity","Descripcion")
#3.Merge columns to get the data frame Data for all data
head(dataFeatures)
head(dataSubject)
head(dataActivity)
Data <- cbind(dataFeatures,dataSubject,dataActivity)#563 Variables
head(Data$Subject)
head(Data$Activity)
#Extracts only the measurements on the mean and standard deviation for each measurement
#load dplyr package 
suppressMessages(library(dplyr))
ColSelected <- 
        dataFeaturesNames %>%
        select(Descripcion) %>%
        filter(grepl('Mean|Std', Descripcion,ignore.case=TRUE));
ColSelected <- c(as.character(ColSelected$Descripcion), "Subject", "Activity")
Data<-Data[,ColSelected]
#Part 3 - Uses descriptive activity names to name the activities in the data set
Data <- inner_join(Data, activityLabels,by="Activity")
Data$Activity <-Data$Descripcion
Data$Descripcion<-NULL
#Part 4 - Appropriately labels the data set with descriptive variable names
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("^t", "Time", names(Data))
names(Data)<-gsub("^f", "Frequency", names(Data))
names(Data)<-gsub("tBody", "TimeBody", names(Data))
names(Data)<-gsub("-mean()", "Mean", names(Data), ignore.case = TRUE)
names(Data)<-gsub("-std()", "STD", names(Data), ignore.case = TRUE)
names(Data)<-gsub("-freq()", "Frequency", names(Data), ignore.case = TRUE)
names(Data)<-gsub("angle", "Angle", names(Data))
names(Data)<-gsub("gravity", "Gravity", names(Data))
tbl_df(Data)
#Creates a second,independent tidy data set and ouput it
#In this part a second independent tidy data set will be created with the average of each variable 
#for each activity and each subject based on the data set in step 4.
#Tidy data set      
DataT <- Data %>% 
        group_by(Subject ,Activity) %>% 
        summarise_each(funs(mean(.))) %>% 
        arrange(Activity,Subject);
write.table(DataT, file = "tidydata.txt",row.name=FALSE)
tbl_df(DataT)
