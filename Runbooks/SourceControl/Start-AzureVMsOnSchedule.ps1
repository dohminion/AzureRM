<# 
	This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
#>
<#
.SYNOPSIS
    Creates scheduled tasks to start Virtual Machines.
.DESCRIPTION
    Creates scheduled tasks to start a single Virtual Machine or a set of Virtual Machines (using
    wildcard pattern syntax for the Virtual Machine name).
.EXAMPLE
    Start-AzureVMsOnSchedule.ps1 -ServiceName "MyServiceName" -VMName "testmachine1" `
        -TaskName "Start Test Machine 1" -At 8AM
    
    Start-AzureVMsOnSchedule.ps1 -ServiceName "MyServiceName" -VMName "test*" `
        -TaskName "Start All Test Machines" -At 8:15AM
#>


workflow Start-AzureVMsOnSchedule {
	param(
    	# The name of the VM(s) to start on schedule.  Can be wildcard pattern.
    	[Parameter(Mandatory = $true)] 
    	[string]$VMName,
	
	
    	# The service name that $VMName belongs to.
    	[Parameter(Mandatory = $true)] 
    	[string]$ServiceName,
	
	
    	# The name of the scheduled task.
    	[Parameter(Mandatory = $true)] 
    	[string]$TaskName,
	
	
    	# The name of the "Stop" scheduled tasks.
    	[Parameter(Mandatory = $true)] 
    	[DateTime]$At
	)
	# Converter: Wrapping initial script in an InlineScript activity, and passing any parameters for use within the InlineScript
	# Converter: If you want this InlineScript to execute on another host rather than the Automation worker, simply add some combination of -PSComputerName, -PSCredential, -PSConnectionURI, or other workflow common parameters (http://technet.microsoft.com/en-us/library/jj129719.aspx) as parameters of the InlineScript
	inlineScript {
		$VMName = $using:VMName
		$ServiceName = $using:ServiceName
		$TaskName = $using:TaskName
		$At = $using:At
		
		
		
		# The script has been tested on Powershell 3.0
		Set-StrictMode -Version 3
		
		
		# Following modifies the Write-Verbose behavior to turn the messages on globally for this session
		$VerbosePreference = "Continue"
		
		
		# Check if Windows Azure Powershell is avaiable
		if ((Get-Module -ListAvailable Azure) -eq $null)
		{
    		throw "Windows Azure Powershell not found! Please install from http://www.windowsazure.com/en-us/downloads/#cmd-line-tools"
		}
		
		
		# Define a scheduled task to start the VM(s) on a schedule.
		$startAzureVM = "Start-AzureVM -Name " + $VMName + " -ServiceName " + $ServiceName + " -Verbose"
		$startTaskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At $At
		$startTaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $startAzureVM
		$startTaskSettingsSet = New-ScheduledTaskSettingsSet  -AllowStartIfOnBatteries 
		
		$startScheduledTask = New-ScheduledTask -Action $startTaskAction -Trigger $startTaskTrigger -Settings $startTaskSettingsSet
		
		
		# Register the scheduled tasks to start and stop the VM(s).
		Register-ScheduledTask -TaskName $TaskName -InputObject $startScheduledTask
		
		
	}
}