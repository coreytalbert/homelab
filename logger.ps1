class Logger {
    $SeverityValues = @{
        EMERGENCY     = 0       # Emergency: system is unusable
        EMER          = 0
        ALERT         = 1       # Alert: action must be taken immediately
        ALRT          = 1  
        CRITICAL      = 2       # Critical: critical conditions
        CRIT          = 2
        ERROR         = 3       # Error: error conditions
        ERR           = 3
        WARNING       = 4       # Warning: warning conditions
        WARN          = 4
        WRN           = 4
        NOTICE        = 5       # Notice: normal but significant condition
        NOTE          = 5
        INFORMATIONAL = 6       # Informational: informational messages
        INFO          = 6       
        DEBUG         = 7       # Debug: debug-level messages
    }

    [int]       $SyslogVersion = 1
    [int]       $Facility
    [string]    $AppName
    [string]    $ProcId

    Logger() {
        $this.ProcId = $Script:PID
    }

    [void] Log(
        [string]$Message,
        [string]$Severity = "INFO"
    ) {
        $Priority = $this.Facility * 8 + $this.SeverityValues[$Severity]
        $TimeStamp = "$(Get-Date -Format "HH:mm:ss.fffzzz")"
        $HostName = $env:COMPUTERNAME
        if (-not $this.AppName) {
            $this.AppName = @(Get-PSCallStack)[1].InvocationInfo.MyCommand.Name # + ":" + @(Get-PSCallStack)[1].ScriptLineNumber
        }
        # $ProcId = Get-Process -Name @(Get-PSCallStack)[1].InvocationInfo.MyCommand
    
        $Header = "<{0}>{1} {2} {3} {4} {5} " -f $Priority, $this.SyslogVersion, $TimeStamp, $HostName, $this.AppName, $this.ProcId
    
        Write-Host $Header
        # Out-File -Encoding utf8 -NoClobber -Append -FilePath $FilePath
    }

}