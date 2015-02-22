# Getting and Cleaning Data
##Getting and Cleaning Data
###Course Project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

###Raw Data collection
<ol>
  <li>Get the data
         <ul>
                <li>Download the Files</li>
                fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                download.file(fileURL, destfile = "./Data/Dataset.zip", method = "curl")
                <li>Unzip the Files - Decompressing the data , the files are in the folder named UCI HAR Dataset</li>
                unzip(zipfile="./Data/Dataset.zip",exdir="./Project")
                <li>Get the list of the files in UCI HAR Dataset folder</li>
                <ul>
                <li>fSource = file.path("./", "Data", "UCI HAR Dataset")</li>
                <li>files = list.files(fSource, recursive=TRUE)</li>
                <li>files</li>
                </ul>
        </ul>
  </li>
  
  <li>Read data from files and assign to data frames variables
        <ul>
                <li>Read the Test and Train Activity files
                       <ul>
                        <li>dataActivityTest  = read.table(file.path(fSource, "test" , "Y_test.txt" ), header = FALSE)</li>
                        <li>dataActivityTrain = read.table(file.path(fSource, "train", "Y_train.txt"), header = FALSE)</li>
                        </ul>
                </li>
                <li>Read the Subject Test and Train files
                         <ul>
                         <li>dataSubjectTrain = read.table(file.path(fSource, "train", "subject_train.txt"), header = FALSE)</li>
                         <li>dataSubjectTest  = read.table(file.path(fSource, "test" , "subject_test.txt"), header = FALSE)</li>
                         </ul>
                </li>
                <li>Read Fearures Test and Train files
                         <ul>
                         <li>dataFeaturesTest  = read.table(file.path(fSource, "test" , "X_test.txt" ),header = FALSE)</li>
                         <li>dataFeaturesTrain = read.table(file.path(fSource, "train", "X_train.txt"),header = FALSE)</li>
                        </ul>
                </li>
        </ul>
  </li>
</ol>

###Raw Data transformation

#####The R script run_analysis.R does the following.
<ol>
  <li>Merges the training and the test sets to create one data set
        <ul>
                <li>Concatenate the data tables by rows
                         <ul>
                         <li>dataSubject = rbind(dataSubjectTrain, dataSubjectTest)</li>
                         <li>dataActivity= rbind(dataActivityTrain, dataActivityTest)</li>
                         <li>dataFeatures= rbind(dataFeaturesTrain, dataFeaturesTest)</li>
                         </ul>
                </li>
                <li>Set names to variables
                         <ul>
                         <li>names(dataSubject)=c("Subject")</li>
                         <li>names(dataActivity)= c("Activity")</li>
                         <li>dataFeaturesNames = read.table(file.path(fSource, "features.txt"), head=FALSE)</li>
                         <li>names(dataFeaturesNames)=c("Key","Descripcion")</li>
                         <li>names(dataFeatures)= dataFeaturesNames$Descripcion</li>
                         <li>head(dataFeatures)</li>
                         <li>activityLabels =  read.table(file.path(fSource, "activity_labels.txt"), head=FALSE)</li>
                         <li>names(activityLabels)=c("Activity","Descripcion")</li>
                         </ul>
                </li>
                <li>Merge Columns
                         <ul><li>
                         Data = cbind(dataFeatures,dataSubject,dataActivity)#563 Variables
                        </li></ul>
                </li>
        </ul>
  </li>
  <li>Extracts only the measurements on the mean and standard deviation for each measurement
        <ul>
                <li>load dplyr package
                         <ul>
                         <li>suppressMessages(library(dplyr))
                         <li>ColSelected = 
                         dataFeaturesNames %>%
                                 select(Descripcion) %>%
                                 filter(grepl('Mean|Std', Descripcion,ignore.case=TRUE));</li>
                         <li>ColSelected = c(as.character(ColSelected$Descripcion), "Subject", "Activity")</li>
                         <li>Data=Data[,ColSelected]</li>
                         </ul>
                </li>
        </ul>
  </li>
  <li>Uses descriptive activity names to name the activities in the data set
        <ul>
                <li>Using Inner Join to Merge de Data
                         <ul>
                         <li>Data = inner_join(Data, activityLabels,by="Activity")</li>
                         <li>Data$Activity = Data$Descripcion</li>
                         <li>Data$Descripcion = NULL</li>
                        </ul>
                        
                </li>
        </ul>
  </li>
  <li>Appropriately labels the data set with descriptive variable names 
        <ul>
                <li>Pattern Matching and Replacement
                         <ul>
                         <li>names(Data)=gsub("Acc", "Accelerometer", names(Data))</li>
                         <li>names(Data)=gsub("Gyro", "Gyroscope", names(Data))</li>
                         <li>names(Data)=gsub("BodyBody", "Body", names(Data))</li>
                         <li>names(Data)=gsub("Mag", "Magnitude", names(Data))</li>
                         <li>names(Data)=gsub("^t", "Time", names(Data))</li>
                         <li>names(Data)=gsub("^f", "Frequency", names(Data))</li>
                         <li>names(Data)=gsub("tBody", "TimeBody", names(Data))</li>
                         <li>names(Data)=gsub("-mean()", "Mean", names(Data), ignore.case = TRUE)</li>
                         <li>names(Data)=gsub("-std()", "STD", names(Data), ignore.case = TRUE)</li>
                         <li>names(Data)=gsub("-freq()", "Frequency", names(Data), ignore.case = TRUE)</li>
                         <li>names(Data)=gsub("angle", "Angle", names(Data))</li>
                         <li>names(Data)=gsub("gravity", "Gravity", names(Data))</li>
                         <li>tbl_df(Data)</li>
                        </ul>
                </li>
        </ul>
  </li>
  <li>Creates a second,independent tidy data set and output it
      In this part a second independent tidy data set will be created with the average of each variable 
      for each activity and each subject based on the data set in step 4.
      <ul>
                <li>Tidy data set
                         <ul><li>
                         DataT = Data %>% 
                         group_by(Subject ,Activity) %>% 
                         summarise_each(funs(mean(.))) %>% 
                         arrange(Activity,Subject);
                         </li>
                         <li>
                         write.table(DataT, file = "tidydata.txt",row.name=FALSE)
                         </li>
                         <li>tbl_df(DataT)</li>
                         </ul>
                </li>
      </ul>
  </li>
</ol>