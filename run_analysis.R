#########################################################################################
## FUNCTION run_analysis
##    Version 0.1
##    Noharminc / 20161013
##    Coursera | Datascience | R Programming | Week 4 | Programming Assigment
##    Description: see codebook      
#########################################################################################


run_analysis <- function() {
      
      #################################################################################################
      ## 0. Preparation
      #################################################################################################
      
      # load needed packages
      library(dplyr)
      library(data.table)
      
      # set working directory
      setwd("C:/Users/Beheerder/Coursera/DataScience")
      
      # path to source data
      rootDir <- paste(getwd(),"/datasciencecoursera/data/UCI HAR Dataset",sep="")
      testRootdir <- paste(getwd(),"/datasciencecoursera/data/UCI HAR Dataset/test",sep="")
      trainRootdir <- paste(getwd(),"/datasciencecoursera/data/UCI HAR Dataset/train",sep="")
      
      #################################################################################################
      ## 1. Merges the training and the test sets to create one data set.
      #################################################################################################
      
      # read all training sets      
      trainSet <- read.table(paste(trainRootdir,"/X_train.txt",sep=""))
      trainLabels <- read.table(paste(trainRootdir,"/y_train.txt",sep=""))
      trainSubject <- read.table(paste(trainRootdir,"/subject_train.txt",sep="")) 
      
      # Combine training sets (by row nr)
      #trainset
      trainSet <- trainSet %>% mutate(id=rownames(trainSet)) %>% select(id,V1:V561)
      #labels: rename V1 -> label
      trainLabels <- trainLabels %>% rename(label=V1) %>% mutate(id=rownames(trainLabels))
      #subject: rename V1 -> subject
      trainSubject <- trainSubject %>% rename(subject=V1) %>% mutate(id=rownames(trainSubject))
      #now merge set, labels and subject by rownames
      train <- full_join(trainSet,trainLabels,by="id")
      train <- full_join(train,trainSubject,by="id")
      #add type=TRAIN
      train <- train %>% mutate(type="TEST")
      #order variables
      train <- train %>% select(id,type,subject,label,V1:V561)
      
      # read all test sets      
      testSet <- read.table(paste(testRootdir,"/X_test.txt",sep=""))
      testLabels <- read.table(paste(testRootdir,"/y_test.txt",sep=""))
      testSubject <- read.table(paste(testRootdir,"/subject_test.txt",sep=""))             
      
      ## combine all test sets (by row nr)
      #trainset
      testSet <- testSet %>% mutate(id=rownames(testSet)) %>% select(id,V1:V561)
      #labels: rename V1 -> label
      testLabels <- testLabels %>% rename(label=V1) %>% mutate(id=rownames(testLabels))
      #subject: rename V1 -> subject
      testSubject <- testSubject %>% rename(subject=V1) %>% mutate(id=rownames(testSubject))
      #now merge set, labels and subject by rownames
      test <- full_join(testSet,testLabels,by="id")
      test <- full_join(test,testSubject,by="id")
      #add type = TEST
      test <- test %>% mutate(type="TEST")
      #order variables
      test <- test %>% select(id,type,subject,label,V1:V561)
      
      ## Combine test & training data (append)
      allData <- rbind(train,test)
      
      #################################################################################################
      ## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
      #################################################################################################
      
      ## Read features source file
      featureSet <- read.table(paste(rootDir,"/features.txt",sep=""))
      # select only records with mean() and std(), change column name to match data set - add "V"
      featureSet <- featureSet %>% 
            mutate(V1=paste("V",V1,sep="")) %>% 
            filter(grepl("mean\\(\\)|std\\(\\)",V2)) %>%
            mutate(V2=gsub("[[:punct:]]","",V2)) %>%
            mutate(V2=gsub("mean","Mean",V2)) %>%
            mutate(V2=gsub("std","Std",V2))
      
      # vector for data selection      
      keepVars <- featureSet %>% select(V1)
      keepVector <- keepVars[["V1"]]
      
      ## subset allData using above feature vector
      subsetData <- allData %>% select(id,type,subject,label,one_of(keepVector)) 
      subsetData <- subsetData %>% mutate(joinId=rownames(subsetData)) %>% select(joinId,type,subject,label,one_of(keepVector)) 
      
      #################################################################################################
      ## 3. Uses descriptive activity names to name the activities in the data set
      #################################################################################################
      
      ## Read activity labels source file
      labelSet <- read.table(paste(rootDir,"/activity_labels.txt",sep=""))
      labelSet <- labelSet %>% mutate(V1=as.integer(V1)) %>% rename(activity=V2)
      
      ## merge data and labels (left join)
      labeledData <- merge(x=subsetData,y=labelSet,by.x="label",by.y="V1",all.x=TRUE)
      ## sort by joinId
      labeledData <- labeledData %>% 
            mutate(joinId=as.numeric(joinId)) %>%
            arrange(joinId) %>% 
            select(subject,activity,starts_with("V"))
      
      #################################################################################################
      ## 4. Appropriately labels the data set with descriptive variable names.
      #################################################################################################
      rows <- nrow(featureSet)
      for (i in 1:rows){
            var <- featureSet[i,1]
            value <- as.vector(featureSet[i,2])
            setnames(labeledData,old=var,new=value)
      }
      
      #################################################################################################
      ## 5. From the data set in step 4, creates a second, independent tidy data set with the 
      ##    average of each variable for each activity and each subject.
      #################################################################################################
      summData <- labeledData %>% 
            group_by(activity,subject) %>% 
            summarize_each(funs(mean))
      
      
}

#################################################################################################
## End of code
#################################################################################################