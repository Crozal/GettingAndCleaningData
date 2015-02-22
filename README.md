# Getting and Cleaning Data
##Getting and Cleaning Data
###Course Project
###Raw Data collection
<ol>
  <li>**Get the data**
         <ul>
                <li>Download the Files</li>
                <font color='#00B2EE'>
                fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                <br>download.file(fileURL, destfile = "./Data/Dataset.zip", method = "curl")
                </font>
                <li>Unzip the Files - Decompressing the data , the files are in the folder named UCI HAR Dataset</li>
                <font color='#00B2EE'>unzip(zipfile="./Data/Dataset.zip",exdir="./Project")</font>
                <li>Get the list of the files in UCI HAR Dataset folder</li>
                <font color='#00B2EE'>
                fSource<-file.path("./", "Data", "UCI HAR Dataset")
                <br>files<-list.files(fSource, recursive=TRUE)
                <br>files
                </font>
        </ul>
  </li>
  
  <li>**Read data from files and assign to data frames variables**
        <ul>
                <li>Read the Test and Train Activity files
                        <font color='#00B2EE'>
                        <br>dataActivityTest  <- read.table(file.path(fSource, "test" , "Y_test.txt" ), header = FALSE)
                        <br>dataActivityTrain <- read.table(file.path(fSource, "train", "Y_train.txt"), header = FALSE)
                        </font>
                </li>
                <li>Read the Subject Test and Train files
                        <font color='#00B2EE'>
                        <br>dataSubjectTrain <- read.table(file.path(fSource, "train", "subject_train.txt"), header = FALSE)
                        <br>dataSubjectTest  <- read.table(file.path(fSource, "test" , "subject_test.txt"), header = FALSE)
                        </font>
                </li>
                <li>Read Fearures Test and Train files
                        <font color='#00B2EE'>
                        <br>dataFeaturesTest  <- read.table(file.path(fSource, "test" , "X_test.txt" ),header = FALSE)
                        <br>dataFeaturesTrain <- read.table(file.path(fSource, "train", "X_train.txt"),header = FALSE)
                        </font>
                </li>
        </ul>
  </li>
</ol>

###Raw Data transformation

**The R script run_analysis.R does the following.**
<ol>
  <li>**Merges the training and the test sets to create one data set**
        <ul>
                <li>Concatenate the data tables by rows
                        <font color='#00B2EE'>
                        <br>dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
                        <br>dataActivity<- rbind(dataActivityTrain, dataActivityTest)
                        <br>dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
                        </font>
                </li>
                <li>Set names to variables
                        <font color='#00B2EE'>
                        <br>names(dataSubject)<-c("Subject")
                        <br>names(dataActivity)<- c("Activity")
                        <br>dataFeaturesNames <- read.table(file.path(fSource, "features.txt"), head=FALSE)
                        <br>names(dataFeaturesNames)<-c("Key","Descripcion")
                        <br>names(dataFeatures)<- dataFeaturesNames--Descripcion
                        <br>head(dataFeatures)
                        <br>activityLabels <-  read.table(file.path(fSource, "activity_labels.txt"), head=FALSE)
                        <br>names(activityLabels)<-c("Activity","Descripcion")
                        </font>
                </li>
                <li>Merge Columns
                        <font color='#00B2EE'>
                        <br>Data <- cbind(dataFeatures,dataSubject,dataActivity)#563 Variables
                        </font>
                </li>
        </ul>
  </li>
  <li>**Extracts only the measurements on the mean and standard deviation for each measurement**
        <ul>
                <li>load dplyr package
                        <font color='#00B2EE'>
                        <br>suppressMessages(library(dplyr))
                        <br>ColSelected <- 
                        <br>dataFeaturesNames %>%
                        <br>        select(Descripcion) %>%
                        <br>        filter(grepl('Mean|Std', Descripcion,ignore.case=TRUE));
                        <br>ColSelected <- c(as.character(ColSelected$Descripcion), "Subject", "Activity")
                        <br>Data<-Data[,ColSelected]
                        </font>
                </li>
        </ul>
  </li>
  <li>**Uses descriptive activity names to name the activities in the data set**
        <ul>
                <li>Using Inner Join to Merge de Data
                        <font color='#00B2EE'>
                        <br>Data <- inner_join(Data, activityLabels,by="Activity")
                        <br>Data--Activity <-Data--Descripcion
                        <br>Data--Descripcion<-NULL
                        </font>
                </li>
        </ul>
  </li>
  <li>**Appropriately labels the data set with descriptive variable names**
        <ul>
                <li>Pattern Matching and Replacement
                        <font color='#00B2EE'>
                        <br>names(Data)<-gsub("Acc", "Accelerometer", names(Data))
                        <br>names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
                        <br>names(Data)<-gsub("BodyBody", "Body", names(Data))
                        <br>names(Data)<-gsub("Mag", "Magnitude", names(Data))
                        <br>names(Data)<-gsub("^t", "Time", names(Data))
                        <br>names(Data)<-gsub("^f", "Frequency", names(Data))
                        <br>names(Data)<-gsub("tBody", "TimeBody", names(Data))
                        <br>names(Data)<-gsub("-mean()", "Mean", names(Data), ignore.case = TRUE)
                        <br>names(Data)<-gsub("-std()", "STD", names(Data), ignore.case = TRUE)
                        <br>names(Data)<-gsub("-freq()", "Frequency", names(Data), ignore.case = TRUE)
                        <br>names(Data)<-gsub("angle", "Angle", names(Data))
                        <br>names(Data)<-gsub("gravity", "Gravity", names(Data))
                        <br>tbl_df(Data)
                        </font>
                </li>
        </ul>
  </li>
  <li>**Creates a second,independent tidy data set and output it**
      **In this part a second independent tidy data set will be created with the average of each variable **
      **for each activity and each subject based on the data set in step 4.**
      <ul>
                <li>Tidy data set 
                <font color='#00B2EE'>
                        <br>DataT <- Data %>% 
                        <br>group_by(Subject ,Activity) %>% 
                        <br>summarise_each(funs(mean(.))) %>% 
                        <br>arrange(Activity,Subject);
                        <br>write.table(DataT, file = "tidydata.txt",row.name=FALSE)
                        <br>tbl_df(DataT)
                </font>
                </li>
      </ul>
  
  </li>
</ol>