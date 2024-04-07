# https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/best-practices-for-running-linux-on-hyper-v

# https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/try-hyper-v-powershell 

$VMName = "homesrv"
$ImagePath = "C:\ISO\kali-linux-2022.1-amd64.iso"

$VMParams = @{
     Name = $VMName
     MemoryStartupBytes = 4294967296 # 4 GB RAM
     Generation = 2
     NewVHDPath = "C:\Virtual Machines\$VMName\$VMName.vhdx"
     NewVHDSizeBytes = 34359738368 # 32 GB storage
     BootDevice = "VHD"
     Path = "C:\Virtual Machines\$VMName"
     SwitchName = (Get-VMSwitch).Name   
 }

 New-VM @VMParams -Confirm

# https://learn.microsoft.com/en-us/powershell/module/hyper-v/add-vmdvddrive?view=windowsserver2022-ps
# https://4sysops.com/archives/how-to-create-a-hyper-v-vm-with-powershell/

Add-VMDvdDrive -VMName $VMName -Path $ImagePath -Confirm

Set-VMFirmware -VMName $VMName -BootOrder $(Get-VMDvdDrive -VMName $VMName), $(Get-VMHardDiskDrive -VMName $VMName), $(Get-VMNetworkAdapter -VMName $VMName) -Confirm

Start-VM -Name $VMName -Confirm