<#
.SYNOPSIS
    Azure Automation Runbook to Start or Pause Power BI Embedded capacities based on a custom tag.

.DESCRIPTION
    This script is designed to be used in an Azure Automation Account with a System-Assigned Managed Identity.
    It searches for Power BI Embedded resources (Microsoft.PowerBIDedicated/capacities) that have a specific tag
    and performs a start ("Resume") or pause ("Suspend") operation based on the input parameter.

.PARAMETER Action
    Accepts either "Start" or "Pause" to control the Power BI Embedded capacity state.

.REQUIREMENTS
    - Azure Automation Account with Managed Identity enabled.
    - The Managed Identity must have at least 'Contributor' role on the Resource Group or Subscription.
    - Power BI Embedded capacity (SKU A) must have the following tag set:
        Key:   AutoStartStop
        Value: true
    - Modules installed: Az.Accounts, Az.Resources

.EXAMPLE
    .\run-powerbi.ps1 -Action Start
    Starts all Power BI capacities with the tag AutoStartStop = true.

.EXAMPLE
    .\run-powerbi.ps1 -Action Pause
    Pauses all Power BI capacities with the tag AutoStartStop = true.
#>

param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Start", "Pause")]
    [string]$Action
)

# Tag filter
$tagKey = "AutoStartStop"
$tagValue = "true"

# Authenticate using Managed Identity
try {
    Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "Authenticated with Managed Identity successfully."
} catch {
    Write-Error "Failed to authenticate using Managed Identity: $_"
    exit 1
}

# Set subscription context explicitly
try {
    $subscriptionId = (Get-AzContext).Subscription.Id
    if (-not $subscriptionId) {
        throw "SubscriptionId is empty. Check the permissions of the Managed Identity."
    }
    Set-AzContext -SubscriptionId $subscriptionId -ErrorAction Stop
    Write-Output "Subscription context set successfully: $subscriptionId"
} catch {
    Write-Error "Failed to set subscription context: $_"
    exit 1
}

# Get Power BI Embedded capacities
try {
    $capacities = Get-AzResource -ResourceType "Microsoft.PowerBIDedicated/capacities"
    if (-not $capacities) {
        Write-Output "No Power BI Embedded capacities found in the subscription."
        exit 0
    }
} catch {
    Write-Error "Failed to retrieve Power BI capacities: $_"
    exit 1
}

# Loop through capacities and apply the action
foreach ($capacity in $capacities) {
    $tags = $capacity.Tags
    if ($tags.ContainsKey($tagKey) -and $tags[$tagKey] -eq $tagValue) {
        Write-Output "Tagged capacity found: $($capacity.Name)"

        switch ($Action) {
            "Start" {
                Write-Output "Resuming $($capacity.Name)..."
                Invoke-AzResourceAction -ResourceId $capacity.ResourceId -Action "Resume" -Force
            }
            "Pause" {
                Write-Output "Suspending $($capacity.Name)..."
                Invoke-AzResourceAction -ResourceId $capacity.ResourceId -Action "Suspend" -Force
            }
        }
    }
}
