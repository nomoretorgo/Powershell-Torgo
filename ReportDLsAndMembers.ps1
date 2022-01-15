# ReportDLsAndMembers.PS1
# Script Ammended by nomoretorgo
# This script generates a report of microsoft 365 exchange distribution groups and the members that belong to said group.
# Attribution: This is an adaptation of the ReportDLsAndManagers.PS1 script produced by 12Knocksinna @ https://github.com/12Knocksinna/Office365itpros/blob/master/ReportDLsAndManagers.PS1

CLS
# Check that we are connected to Exchange Online
$ModulesLoaded = Get-Module | Select Name
If (!($ModulesLoaded -match "ExchangeOnlineManagement")) {Write-Host "Please connect to the Exchange Online Management module and then restart the script"; break}

$OrgName = (Get-OrganizationConfig).Name
$CreationDate = Get-Date -format g
$Version = "1.0"
$ReportFile = "c:\temp\DLMembersReport.html"
$CSVFileMembers = "c:\temp\DLMembersReport.csv"

Write-Host "Finding Groups/Distribution lists in" $OrgName "..."
[array]$DLs = Get-DistributionGroup -ResultSize Unlimited
If (!($DLs)) { Write-Host "No distribution lists found - exiting" ; break }

$Report = [System.Collections.Generic.List[Object]]::new()
Write-Host "Reporting Groups/Distribution lists and members..."



ForEach ($DL in $DLs) {
    [array]$DGMs = Get-DistributionGroupMember -Identity $DL.DisplayName
    $MemberList = [System.Collections.Generic.List[Object]]::new()
  
    $name=$DL.DisplayName
    echo $name
    $DLLine = [PSCustomObject][Ordered]@{  
         'Groups-DLs' = $name
         Members     = " "
         }
    
    $Report.Add($DLLine)



    ForEach ($DGM in $DGMs) {
       If (!($Recipient)) { # Can't resolve manager
           $Recipient = "Unknown user" }
       $MemberLine = [PSCustomObject][Ordered]@{  
         DisplayName = $DGM.DisplayName
         
         }
       $MemberList.Add($MemberLine) 
    
    

    $Managers = $MemberList.DisplayName -join ", " 
    $DLLine = [PSCustomObject][Ordered]@{    
         DisplayName = " "
         Members     = $DGM.DisplayName
         }
    $Report.Add($DLLine)
    } # End processing managers
} # End processing DL


# Create the HTML report
$htmlhead="<html>
	   <style>
	   BODY{font-family: Arial; font-size: 8pt;}
	   H1{font-size: 22px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
	   H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
	   H3{font-size: 16px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
	   TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
	   TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;}
	   TD{border: 1px solid #969595; padding: 5px; }
	   td.pass{background: #B7EB83;}
	   td.warn{background: #FFF275;}
	   td.fail{background: #FF2626; color: #ffffff;}
	   td.info{background: #85D4FF;}
	   </style>
	   <body>
           <div align=center>
           <p><h1>Group/Distribution List Manager Report</h1></p>
           <p><h2><b>For the " + $Orgname + " organization</b></h2></p>
           <p><h3>Generated: " + (Get-Date -format g) + "</h3></p></div>"

$htmlbody1 = $Report | ConvertTo-Html -Fragment

$htmltail = "<p>Report created for: " + $OrgName + "</p>" +
             "<p>Created: " + $CreationDate + "<p>" +
             "<p>-----------------------------------------------------------------------------------------------------------------------------</p>"+  
             "<p>Number of Groups/distribution lists found:    " + $DLs.Count + "</p>" +
             "<p>-----------------------------------------------------------------------------------------------------------------------------</p>"+
             "<p>Groups/Distribution List AND Members Report<b> " + $Version + "</b>"	

$htmlreport = $htmlhead + $htmlbody1 + $htmltail
$htmlreport | Out-File $ReportFile  -Encoding UTF8

$Report | Export-CSV -NoTypeInformation $CSVFileMembers
CLS
Write-Host "All done. Output files are" $CSVFileMembers "and" $ReportFile
