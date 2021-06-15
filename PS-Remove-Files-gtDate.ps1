#builds a simple arrow of directory paths, then removes any file in those paths older than variable number_days_old.

#adding to the array should allow other directories to be added no problem.

 

$ARRAY_FOLDER_PATH = @(

    'C:\sandbox\samp1'

    'C:\sandbox\samp2'

    'C:\sandbox\samp3'

    )

 

$NUMBER_OF_DAYS = 10

  

For ($i=0; $i -lt $ARRAY_FOLDER_PATH.Length; $i++) {

    Get-ChildItem -Path $ARRAY_FOLDER_PATH[$i] -File -Force | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(- $NUMBER_OF_DAYS))}| Remove-Item -Force   

    }