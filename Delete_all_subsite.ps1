Import-Module PnP.PowerShell

function Get-AndDeleteAllSubsites {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SiteUrl
    )

    # Connect to Root Site
    Connect-PnPOnline -Url $SiteUrl -ClientId "*****" -Interactive

    # Get all subsites
    $subsites = Get-PnPSubWeb -Recurse

    if ($subsites.Count -eq 0) {
        Write-Output "No subsites found in the site $SiteUrl."
    } else {
        foreach ($subsite in $subsites) {
            Write-Output "Deleting subsite: $($subsite.Url)"

            try {
                # Connect to each subsite before deleting
                Connect-PnPOnline -Url $subsite.Url -ClientId "b92c729d-4963-4010-994b-7b2e6df8da5a" -Interactive

                # Delete subsite using the web object
                $subweb = Get-PnPWeb
                Remove-PnPWeb -Identity $subweb -Force

                Write-Output "Deleted: $($subsite.Url)"
            } catch {
                Write-Output "Error deleting subsite: $($subsite.Url) - $_"
            }
        }
    }

    Write-Output "Subsite deletion process completed."
}

# Define root site URL
$rootSiteUrl = "https://intranet.xxx.net/sites/T01"

# Execute the function
Get-AndDeleteAllSubsites -SiteUrl $rootSiteUrl
