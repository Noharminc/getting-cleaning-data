# getting-cleaning-data

Repository for Getting and Cleaning Data Course Project (week 4) - Datascience course

-------------------- Program flow ---------------------------------

1. Import & combine data

      a. Training data
      
            - Import measurements, labels, subjects
            - Merge
      b. Test data
      
            - Import measurements, labels, subjects
            - Merge
      c. Combine training and test data (append)


2. Keep only mean and standard deviation measurements

            - import features data
            - keep only mean and std vars
            - clean variable names (strip special characters)
            - only save vars from above selection from allData (3)

3. label activities with description

            - import activity label data
            - combine with measurement data


4. Replace varnames V1-Vn with logical variable names (from features data)


5. Summarize data: aggregate to one record with mean values per subject/activity

-----------------------------------------------------------------------

See codebook for additional information
