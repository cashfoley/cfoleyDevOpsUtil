
## Taken from https://github.com/Microsoft/vsts-tasks/blob/master/Tasks/SqlAzureDacpacDeployment/Utility.ps1

function Get-AgentStartIPAddress
{
    $endpoint = (Get-VstsEndpoint -Name SystemVssConnection -Require)
    $vssCredential = [string]$endpoint.auth.parameters.AccessToken

    $vssUri = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
    if ($vssUri.IndexOf("visualstudio.com", [System.StringComparison]::OrdinalIgnoreCase) -ne -1) {
        # This hack finds the DTL uri for a hosted account. Note we can't support devfabric since the
        # there subdomain is not used for DTL endpoint
        $vssUri = $vssUri.Replace("visualstudio.com", "vsdtl.visualstudio.com")
    }

    Write-Verbose "Querying VSTS uri '$vssUri' to get external ip address"

    # Getting start ip address from dtl service
    Write-Verbose "Getting external ip address by making call to dtl service"
    $vssUri = $vssUri + "/_apis/vslabs/ipaddress"
    $username = ""
    $password = $vssCredential

    $basicAuth = ("{0}:{1}" -f $username, $password)
    $basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
    $basicAuth = [System.Convert]::ToBase64String($basicAuth)
    $headers = @{Authorization=("Basic {0}" -f $basicAuth)}

    $response = Invoke-RestMethod -Uri $($vssUri) -headers $headers -Method Get -ContentType "application/json"
    Write-Verbose "Response: $response"

    return $response.Value
}

function Get-AgentIPAddress
{
    param([String] $startIPAddress,
          [String] $endIPAddress,
          [String] [Parameter(Mandatory = $true)] $ipDetectionMethod)

    [HashTable]$IPAddress = @{}
    if($ipDetectionMethod -eq "IPAddressRange")
    {
        $IPAddress.StartIPAddress = $startIPAddress
        $IPAddress.EndIPAddress = $endIPAddress
    }
    elseif($ipDetectionMethod -eq "AutoDetect")
    {
        $IPAddress.StartIPAddress = Get-AgentStartIPAddress
        $IPAddress.EndIPAddress = $IPAddress.StartIPAddress
    }

    return $IPAddress
}

function Get-Endpoint
{
    param([String] [Parameter(Mandatory=$true)] $connectedServiceName)

    $serviceEndpoint = Get-VstsEndpoint -Name "$connectedServiceName"
    return $serviceEndpoint
}
