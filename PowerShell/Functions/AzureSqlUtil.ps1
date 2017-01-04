
# Taken from https://github.com/Microsoft/vsts-tasks/blob/master/Tasks/SqlAzureDacpacDeployment/Utility.ps1

function Create-AzureSqlDatabaseServerFirewallRule
{
    param([String] [Parameter(Mandatory = $true)] $startIp,
          [String] [Parameter(Mandatory = $true)] $endIp,
          [String] [Parameter(Mandatory = $true)] $serverName,
          [Object] [Parameter(Mandatory = $true)] $endpoint)

    [HashTable]$FirewallSettings = @{}
    $firewallRuleName = [System.Guid]::NewGuid().ToString()

    Add-AzureSqlDatabaseServerFirewallRule -endpoint $endpoint -startIPAddress $startIp -endIPAddress $endIp -serverName $serverName -firewallRuleName $firewallRuleName | Out-Null

    $FirewallSettings.IsConfigured = $true
    $FirewallSettings.RuleName = $firewallRuleName

    return $FirewallSettings
}

function Delete-AzureSqlDatabaseServerFirewallRule
{
    param([String] [Parameter(Mandatory = $true)] $serverName,
          [String] [Parameter(Mandatory = $true)] $firewallRuleName,
          [String] $isFirewallConfigured,
          [String] [Parameter(Mandatory = $true)] $deleteFireWallRule,
          [Object] [Parameter(Mandatory = $true)] $endpoint)

    if($deleteFireWallRule -eq "true" -and $isFirewallConfigured -eq "true")
    {
        Remove-AzureSqlDatabaseServerFirewallRule -serverName $serverName -firewallRuleName $firewallRuleName -endpoint $endpoint
    }
}

