# Author: Corey Talbert

. .\logger.ps1
$default_logger = [Logger]::new(1)
$default_logger.Log("INFO", "This is a log message.")

$param_logger = [Logger]@{
    Options = 1
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
