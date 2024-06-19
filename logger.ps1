# Author: Corey Talbert
# https://datatracker.ietf.org/doc/html/rfc5424

class Logger {
    $PriorityLabelValues = @{
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
    [int]       $Facility = 1
    [string]    $HostName = $env:COMPUTERNAME
    [string]    $AppName = @(Get-PSCallStack)[1].InvocationInfo.MyCommand.Name
    [string]    $ProcId = $Script:PID
    [string]    $MsgId = $null

    Logger() {}

    Logger(
        [int]$Facility
    ) {
        Init($Facility, $null, $null, $null)
    }

    Logger(
        [int]$Facility,
        [string]$AppName
    ) {
        Init($Facility, $AppName, $null, $null)
    }

    Logger(
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId
    ) {
        Init($Facility, $AppName, $ProcId, $null)
    }

    Logger(
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId,
        [string]$MsgId
    ) {
        Init($Facility, $AppName, $ProcId, $MsgId)
    }

    hidden [void] Init(
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId,
        [string]$MsgId
    ) {
        if ($null -ne $Facility) {
            $this.Facility = $Facility
        }
        if ([string]::IsNullOrEmpty($AppName)) {
            $this.AppName = $AppName
        }
        if ([string]::IsNullOrEmpty($ProcId)) {
            $this.ProcId = $ProcId
        }
        if ([string]::IsNullOrEmpty($MsgId)) {
            $this.MsgId = $MsgId
        }
    }

    hidden [string] MakeHeader(
        [string]$PriorityLabel
    ) {
        $HeaderFormatString = "<{0}>{1} {2} {3} {4} {5} "
        if ( $this.MsgId ) {
            $HeaderFormatString += "{6} "
        }

        $Priority = $this.Facility * 8 + $this.PriorityLabelValues[$PriorityLabel]
        $TimeStamp = "$(Get-Date -Format "HH:mm:ss.fffzzz")"

        $Header = $HeaderFormatString `
            -f  $Priority, `
                $this.SyslogVersion, `
                $TimeStamp, `
                $this.HostName, `
                $this.AppName, `
                $this.ProcId, `
                $this.MsgId 

        return $Header;
    }

    [void] Log(
        [string]$PriorityLabel = "INFO",
        [string]$Message
    ) {
        $Header = $this.MakeHeader($PriorityLabel)
        Write-Host $Header $Message -Separator ''
        # Out-File -Encoding ascii -NoClobber -Append -FilePath $FilePath
    }

    [void] Log(
        [string]$PriorityLabel = "INFO",
        [string]$StructuredData,
        [string]$Message
    ) {
        $Header = $this.MakeHeader($PriorityLabel)
        Write-Host $Header $StructuredData $Message -Separator ''
        # Out-File -Encoding ascii -NoClobber -Append -FilePath $FilePath
    }

    [void] Log(
        [hashtable]$Table
    ) {
        [string]$PriorityLabel  =   $null
        [string]$StructuredData =   $null
        [string]$Message        =   $null

        switch ($Table.Keys) {
            'PriorityLabel'     { $PriorityLabel = $Table.PriorityLabel }
            'StructuredData'    { $StructuredData = $Table.StructuredData }
            'Message'           { $Message = $Table.Message }
        }

        $Header = $this.MakeHeader($PriorityLabel)
        Write-Host $Header $StructuredData $Message -Separator ''
        # Out-File -Encoding ascii -NoClobber -Append -FilePath $FilePath
    }

}