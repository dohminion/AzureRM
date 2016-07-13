workflow Get-Sub
{
    $Cred = Get-AutomationPSCredential -Name "Automator1@MyMinions.onmicrosoft.com"

	# Connect to Azure
	Add-AzureAccount -Credential $Cred
	Select-AzureSubscription -SubscriptionName "Windows Azure  MSDN - Visual Studio Premium"
    #Get-AzureVM |select InstanceName
	# Get all Azure VMs in the subscription that are not stopped and deallocated, and shut them down.
    inlinescript
      {
        $display=Get-AzureSubscription
        write-output $display
	    #Get-AzureVM | where{$_.status -ne 'StoppedDeallocated'} | Stop-AzureVM –force 
      }
 }