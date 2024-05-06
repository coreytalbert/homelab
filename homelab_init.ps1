$vm_names = @("web0", "zab0", "db0", "hq0")

$image_path = "..."

$switch_params = @{
    Name = "switch0"
}

New-VMSwitch @switch_params

foreach ($vm_name in $vm_names) {
    $vhd_params = @{
        Path = "C:\Virtual Machines\$vm_name\$vm_name.vhdx"
    }

    New-VHD @vhd_params

    $vm_params = @{
        Name = $vm_name
        MemoryStartupBytes = 4096  
        Generation = 2
        VHDPath = $vhd_params['Path']
        BootDevice = "VHD"
        Path = "C:\Virtual Machines\$vm_name"
        SwitchName = $switch_params['Name']
    }

    New-VM @vm_params

    $boot_params = @{
        VMName = $vm_name
        BootOrder = $(Add-VMDvdDrive -VMName $vm_name -Path $image_path),
                    $(Get-VMHardDiskDrive -VMName $vm_name)
            
    }

    Set-VMFirmware @boot_params

    Start-VM -Name $vm_name
}
