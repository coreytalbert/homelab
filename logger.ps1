# Author: Corey Talbert
# https://datatracker.ietf.org/doc/html/rfc5424
[Flags()] enum PriorityLabel {
    EMERGENCY = 1   # Emergency: system is unusable
    ALERT = 2    # Alert: action must be taken immediately
    CRITICAL = 4   # Critical: critical conditions
    ERROR = 8   # Error: error conditions
    WARNING = 16   # Warning: warning conditions
    NOTICE = 32    # Notice: normal but significant condition
    INFO = 64   # Informational: informational messages
    DEBUG = 128    # Debug: debug-level messages
}

[Flags()] enum LoggerOption {
    LOG_CONS = 1 # When on, logger writes message to stdout
    LOG_FILE = 2 # When on, logger writes out to a file
    LOG_PID = 4 # When on, log message includes calling process' Process ID (PID)
}

class Logger {
    [int]           $SyslogVersion = 1
    [string]        $LogFilePath = $null
    [LoggerOption]  $Options = 0
    [int]           $Facility = 1
    [string]        $HostName = $env:COMPUTERNAME
    [string]        $AppName = @(Get-PSCallStack)[1].InvocationInfo.MyCommand.Name
    [string]        $ProcId = $Script:PID
    [string]        $MsgId = $null

    Logger() {}

    Logger(
        [string]$LogFilePath,
        [LoggerOption]$Options
    ) {
        $this.Init($LogFilePath, $Options, $null, $null, $null, $null)
    }

    Logger(
        [string]$LogFilePath,
        [LoggerOption]$Options,
        [int]$Facility
    ) {
        $this.Init($LogFilePath, $Options, $Facility, $null, $null, $null)
    }

    Logger(
        [string]$LogFilePath,
        [LoggerOption]$Options,
        [int]$Facility,
        [string]$AppName
    ) {
        $this.Init($LogFilePath, $Options, $Facility, $AppName, $null, $null)
    }

    Logger(
        [string]$LogFilePath,
        [LoggerOption]$Options,
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId
    ) {
        $this.Init($LogFilePath, $Options, $Facility, $AppName, $ProcId, $null)
    }

    Logger(
        [string]$LogFilePath,
        [LoggerOption]$Options,
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId,
        [string]$MsgId
    ) {
        $this.Init($LogFilePath, $Options, $Facility, $AppName, $ProcId, $MsgId)
    }

    hidden [void] Init(
        [string]$LogFilePath,
        [LoggerOption]$Options,
        [int]$Facility,
        [string]$AppName,
        [string]$ProcId,
        [string]$MsgId
    ) {
        $this.SetLogFile($LogFilePath)

        $this.Options = $this.Options -bor $Options

        if ($null -ne $Facility) {
            $this.Facility = $Facility
        }
        if (-not [string]::IsNullOrEmpty($AppName)) {
            $this.AppName = $AppName
        }
        if (-not [string]::IsNullOrEmpty($ProcId)) {
            $this.ProcId = $ProcId
        }
        if (-not [string]::IsNullOrEmpty($MsgId)) {
            $this.MsgId = $MsgId
        }
    }

    [void] SetLogFile([string]$LogFilePath) {
        if (-not $(Test-Path $LogFilePath)) {
            New-Item -Type 'file' -Path $LogFilePath
        } 
        $this.LogFilePath = $LogFilePath
    }

    hidden [string] MakeHeader(
        [PriorityLabel]$PriorityLabel
    ) {
        $HeaderFormatString = '<{0}>{1} {2} {3} {4} {5} '
        if ( $this.MsgId ) {
            $HeaderFormatString += '{6} '
        }

        $Priority = $this.Facility * 8 + $PriorityLabel
        $TimeStamp = "$(Get-Date -Format 'yyyy-dd-MMTHH:mm:ss.fffzzz')"

        $Header = $HeaderFormatString `
            -f $Priority, `
            $this.SyslogVersion, `
            $TimeStamp, `
            $this.HostName, `
            $this.AppName, `
            $this.ProcId, `
            $this.MsgId 

        return $Header
    }

    [void] Log(
        [PriorityLabel]$PriorityLabel,
        [string]$Message
    ) {
        $this.Log(
            @{
                PriorityLabel  = $PriorityLabel
                StructuredData = $null
                Message        = $Message
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
                PriorityLabel  = $PriorityLabel
                StructuredData = $StructuredData
                Message        = $Message
            }
        )
    }

    [void] Log(
        [hashtable]$Table
    ) {
        [PriorityLabel]$PriorityLabel = 'INFO'
        [string]$StructuredData = $null
        [string]$Message = $null

        switch ($Table.Keys) {
            'PriorityLabel' { $PriorityLabel = $Table.PriorityLabel }
            'StructuredData' { $StructuredData = $Table.StructuredData }
            'Message' { $Message = $Table.Message }
        }

        $Header = $this.MakeHeader($PriorityLabel)
        if ( $this.Options.HasFlag([LoggerOption]::LOG_CONS) ) {
            Write-Host $Header $StructuredData $Message -Separator ''
        }

        if ( $this.Options.HasFlag([LoggerOption]::LOG_FILE) ) {
            Out-File -Encoding ASCII -NoClobber -NoNewline -Append `
                -FilePath $this.LogFilePath `
                -InputObject $Header, $StructuredData, $Message, "`n" 
        }
    }
}