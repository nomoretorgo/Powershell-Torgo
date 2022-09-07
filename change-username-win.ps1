
##SCRIPT  change username


function ChangeUsername{
    Param (
        [Parameter (Mandatory = $true)]
        [string] $oldname,
        [Parameter (Mandatory = $true)]
        [string] $newname
    )



    #static
    #$oldname='user test'
    #$newname='user.test'


    #Step:  Get SID for user
    $mysid = get-localuser -Name $oldname | select sid
    $regstring = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' + $mysid.sid.value
    $new_user_dir = ‘C:\Users\’ + $newname
    $old_user_dir = ‘C:\Users\’ + $oldname



    #Step:  change name
    Rename-LocalUser -Name $oldname -NewName $newname

    $ACL = Get-Acl  $old_user_dir
    $ACL_Rule = new-object System.Security.AccessControl.FileSystemAccessRule ('installadmin', "FullControl",”Allow”)
    $ACL.SetAccessRule($ACL_Rule)
    Set-Acl -Path $old_user_dir -AclObject $ACL 

    #Step todo:  check C:\user directory for folders who may have same naming format already, ie. firstname.lastname

    #step log user out
    [string]$userlogged_in=((quser) -replace '^>', '') -replace '\s{2,}', ',' | Select-String $oldname
    $userlogged_in=$userlogged_in -replace '\D+([0-9]*).*','$1'
    logoff $userlogged_in
    Start-Sleep -Seconds 5

    #Step:  change directory name
    mv $old_user_dir $new_user_dir


    #Step:  Create a symbolic link from old profile to new.  this helps direct registry values still pointing to old location.  **If apps still fail, they have to be reinstalled.
    #mklink /d $old_user_dir $new_user_dir
    New-Item -ItemType SymbolicLink -Path $old_user_dir -Target $new_user_dir

    #Step:  registery modification
    REG ADD $regstring /v ProfileImagePath /t REG_EXPAND_SZ /d $new_user_dir /f

    #Start-Sleep -Seconds 5
    #step:  reboot
    shutdown /r /f /t 0
}
