<#
.SYNOPSIS
    Connects to Azure and shuts down all VMs in the specified Azure subscription and deallocates their cloud services.

.DESCRIPTION
   This runbook sample demonstrates how to connect to Azure using organization id credential
   based authentication. Before using this runbook, you must create an Azure Active Directory
   user and allow that user to manage the Azure subscription you want to work against. You must
   also place this user's username / password in an Azure Automation credential asset.
   
   You can find more information on configuring Azure so that Azure Automation can manage your
   Azure subscription(s) here: http://aka.ms/Sspv1l

   After configuring Azure and creating the Azure Automation credential asset, make sure to
   update this runbook to contain your Azure subscription name and credential asset name.

   This runbook can be scheduled to stop all VMs at a certain time of day.

.NOTES
	Original Author: System Center Automation Team
    Last Updated: 10/02/2014  -   Microsoft Services - Adapted to stop all VMs.   
#>

workflow Stop-AllAzureVM
{   
	# Grab the credential to use to authenticate to Azure. 
	# TODO: Fill in the -Name parameter with the name of the Automation PSCredential asset
	# that has has access to your Azure subscription
	$Cred = Get-AutomationPSCredential -Name "Automator1@MyMinions.onmicrosoft.com"

	# Connect to Azure
	Add-AzureAccount -Credential $Cred

	# Select the Azure subscription you want to work against
	# TODO: Fill in the -SubscriptionName parameter with the name of your Azure subscription
	Select-AzureSubscription -SubscriptionName "Windows Azure  MSDN - Visual Studio Premium"

	# Get all Azure VMs in the subscription that are not stopped and deallocated, and shut them down.
    inlinescript
      {
	    Get-AzureVM | where{$_.status -ne 'StoppedDeallocated'} | Stop-AzureVM –force 
      }
}
