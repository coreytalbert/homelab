# Author: Corey Talbert

. .\logger.ps1
$default_logger = [Logger]::new("log.txt", 3)
$default_logger.Log("INFO", "This is a log message.")

$param_logger = [Logger]@{
    LogFilePath = "log.txt"
    Options = [LoggerOption]::LOG_FILE + [LoggerOption]::LOG_CONS
    Facility = 1
    AppName = "TEST"
    ProcId = "99999"
    MsgId = "HOMELAB"
}

$param_logger.Log(
    @{
        PriorityLabel = "ALERT"
        Message = "This is a user facility alert message!"
    }
)

$vm_name = "VM_TEST"
$default_logger.Log([PriorityLabel]::NOTICE, "Creating VM $vm_name.")
