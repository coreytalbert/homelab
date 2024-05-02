$vm_names = @("web0", "zab0", "db0", "hq0")

$switch_params = @{
    
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
        SwitchName = (Get-VMSwitch).Name
    }

    New-VM @vm_params

    Start-VM -Name $vm_name
}