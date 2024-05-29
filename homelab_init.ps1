$vm_names = @("web0", "zab0", "db0", "hq0")
$startup_memory = 2GB
$minimum_memory = 256MB
$maximum_memory = 8GB
$CPU_count = 2

$image_path = "..."

# https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines?tabs=powershell
#$switch_params = @{
#    Name           = "switch0"
#    NetAdapterName = $(Get-NetAdapter | Where-Object Name -Like "*Wi-Fi*")
#}
#New-VMSwitch @switch_params | Tee-Object -FilePath "./homelab_init.log"

$switch_name = Get-VMSwitch -name "vWifi" | select -expand Name

ForEach ($vm_name in $vm_names) {
    # https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/best-practices-for-running-linux-on-hyper-v
    Write-Host "Creating VM $vm_name"
    
    $vm_params = @{
        Name               = $vm_name
        MemoryStartupBytes = $startup_memory
        Generation         = 2
        Path               = "C:\Virtual Machines\$vm_name"
        SwitchName         = $switch_name
    }

    $vm = New-VM @vm_params 

    $vhd_params = @{
        Path           = "C:\Virtual Machines\$vm_name\$vm_name.vhdx"
        SizeBytes      = 16GB
        BlockSizeBytes = 1MB
    }

    New-VHD @vhd_params -Dynamic

    $vm | Add-VMHardDiskDrive -Path $vhd_params['Path']

    $vm | Set-VMMemory -DynamicMemoryEnabled $true -MinimumBytes $minimum_memory -MaximumBytes $maximum_memory

    $vm | Set-VMProcessor -Count $CPU_count

    $boot_params = @{
        BootOrder = $($vm | Add-VMDvdDrive -Path $image_path),
                    $($vm | Get-VMHardDiskDrive)
    }

    $vm | Set-VMFirmware @boot_params

    $vm | Start-VM -PassThru | Tee-Object -FilePath "./homelab_init.log"
}
