# Author: Corey Talbert

. .\logger.ps1
$default_logger = [Logger]::new("testlog", 1)
$default_logger.Log("INFO", "This is a log message.")

$param_logger = [Logger]@{
    LogFilePath = "testlog"
    Options = 3
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
