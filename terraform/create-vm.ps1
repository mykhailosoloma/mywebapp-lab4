param($VmName, $Memory, $Cpus, $HostIf, $SourceVm)

Write-Host "Cloning $SourceVm to $VmName..."
& VBoxManage clonevm $SourceVm --name $VmName --register --mode machine --basefolder "D:\VirtualBox VMs"

& VBoxManage modifyvm $VmName --memory $Memory --cpus $Cpus
& VBoxManage modifyvm $VmName --nic1 nat
& VBoxManage modifyvm $VmName --nic2 hostonly --hostonlyadapter2 $HostIf

Write-Host "Starting $VmName..."
& VBoxManage startvm $VmName --type headless
Write-Host "Done: $VmName"
