# Author: Corey Talbert
# https://datatracker.ietf.org/doc/html/rfc5424
enum PriorityLabel {
    EMERGENCY   # Emergency: system is unusable
    ALERT       # Alert: action must be taken immediately
    CRITICAL    # Critical: critical conditions
    ERROR       # Error: error conditions
    WARNING     # Warning: warning conditions
    NOTICE      # Notice: normal but significant condition
    INFO        # Informational: informational messages
    DEBUG       # Debug: debug-level messages
}
class Logger {

    static $PriorityMaskValues = @{
        EMERGENCY = 1
        ALERT = 2
        CRITICAL = 4
        ERROR = 8
        WARNING = 16
        NOTICE = 32
        INFO = 64
        DEBUG = 128
    }

    static $LoggerOptions = @{
        LOG_CONS = 1 # When on, logger writes message to stdout
        LOG_PID = 2 # When on, log message includes calling process' Process ID (PID)
    }

    [int]       $SyslogVersion = 1
    #[int]       $PriorityMask = 1 -bor 2 -bor 4 -bor 8 -bor 16 -bor 32 -bor 64 -bor 128
    [int]       $Options = 0
    [int]       $Facility = 1
    [string]    $HostName = $env:COMPUTERNAME
    [string]    $AppName = @(Get-PSCallStack)[1].InvocationInfo.MyCommand.Name
    [string]    $ProcId = $Script:PID
    [string]    $MsgId = $null

    Logger() {}

    Logger(
        [int]$Options
    ) {
        $this.Init($Options, $null, $null, $null, $null)
    }

    Logger(
        [int]$Options,
        [int]$Facility
    ) {
        $this.Init($Options, $Facility, $null, $null, $null)
    }

    Logger(
        [int]$Options,
        [int]$Facility,
        [string]$AppName
    ) {
        $this.Init($Options, $Facility, $AppName, $null, $null)
    }

    Logger(
        [int]$Options,
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId
    ) {
        $this.Init($Options, $Facility, $AppName, $ProcId, $null)
    }

    Logger(
        [int]$Options,
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId,
        [string]$MsgId
    ) {
        $this.Init($Options, $Facility, $AppName, $ProcId, $MsgId)
    }

    hidden [void] Init(
        [int]$Options,
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId,
        [string]$MsgId
    ) {
        $this.Options = $this.Options -bor $Options

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
        [PriorityLabel]$PriorityLabel
    ) {
        $HeaderFormatString = "<{0}>{1} {2} {3} {4} {5} "
        if ( $this.MsgId ) {
            $HeaderFormatString += "{6} "
        }

        $Priority = $this.Facility * 8 + $PriorityLabel
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
        [PriorityLabel]$PriorityLabel,
        [string]$Message
    ) {
        $this.Log(
            @{
                PriorityLabel = $PriorityLabel
                StructuredData = $null
                Message = $Message
            }
        )
    }

    [void] Log(
        [PriorityLabel]$PriorityLabel,
        [string]$StructuredData,
        [string]$Message
    ) {
        $this.Log(
            @{
                PriorityLabel = $PriorityLabel
                StructuredData = $StructuredData
                Message = $Message
            }
        )
    }

    [void] Log(
        [hashtable]$Table
    ) {
        [PriorityLabel]$PriorityLabel  =   "INFO"
        [string]$StructuredData =   $null
        [string]$Message        =   $null

        switch ($Table.Keys) {
            'PriorityLabel'     { $PriorityLabel = $Table.PriorityLabel }
            'StructuredData'    { $StructuredData = $Table.StructuredData }
            'Message'           { $Message = $Table.Message }
        }

        $Header = $this.MakeHeader($PriorityLabel)
        if ( $this.Options -band $this.LoggerOptions.LOG_CONS -ne 0 ) {
            Write-Host $Header $StructuredData $Message -Separator ''
        }
        # Out-File -Encoding ascii -NoClobber -Append -FilePath $FilePath
    }
}