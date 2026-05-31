param($VmName)
& VBoxManage controlvm $VmName poweroff 2>$null
Start-Sleep -Seconds 3
& VBoxManage unregistervm $VmName --delete
