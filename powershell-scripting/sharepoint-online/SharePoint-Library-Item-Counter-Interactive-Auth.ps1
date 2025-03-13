# Import necessary module
Import-Module PnP.PowerShell

# Initialize results array to store library item counts
$results = New-Object System.Collections.ArrayList

<#
    Script Name: SharePoint Library Item Counter
    Description: This script retrieves the item count of all document libraries and lists 
                 in a SharePoint Online site, including its subsites. The data is exported
                 as a CSV file.
    
    Developed By: [Akash Neel]
    
	#>

function Get-AllListItemCount {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SiteUrl
    )

    Connect-PnPOnline -Url $SiteUrl -ClientId "#Add Client ID of application configured in Azure" -Interactive

    # Retrieve all lists and libraries
    $lists = Get-PnPList

    if ($lists.Count -eq 0) {
        Write-Output "No lists or libraries found in the site $SiteUrl."
    } else {
        # Loop through each list to get the item count
        foreach ($list in $lists) {
            try {
                $itemCount = $list.ItemCount
                $results.Add([pscustomobject]@{
                    SiteUrl   = $SiteUrl
                    Library   = $list.Title
                    ItemCount = $itemCount
                }) | Out-Null
            } catch {
                $results.Add([pscustomobject]@{
                    SiteUrl   = $SiteUrl
                    Library   = $list.Title
                    ItemCount = "Error retrieving item count"
                }) | Out-Null
            }
        }
    }

    # Recursively check subsites
    $subsites = Get-PnPSubWeb -Recurse
    foreach ($subsite in $subsites) {
        Get-AllListItemCount -SiteUrl $subsite.Url
    }
}

function Get-AllSubsites {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SiteUrl
    )

    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
    
    # Retrieve all subsites
    $subsites = Get-PnPSubWeb -Recurse
    
    if ($subsites.Count -eq 0) {
        Write-Output "No subsites found in the site $SiteUrl."
    } else {
        foreach ($subsite in $subsites) {
            Write-Output $subsite.Url
        }
    }
}

# Define root site
$rootSiteUrl = "# add your site url here https://intranet.xyzorganization.net/sites/akash-TestTeam"

# Get and list all subsites
Get-AllSubsites -SiteUrl $rootSiteUrl

# Retrieve item counts for all lists and libraries
Get-AllListItemCount -SiteUrl $rootSiteUrl

# Generate CSV output file path
$siteName = ($rootSiteUrl.TrimEnd('/') -split "/")[-1]
$csvFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "$siteName-LibraryItemCounts.csv")

# Export results to CSV
$results | Export-Csv -Path $csvFilePath -NoTypeInformation -Encoding UTF8

Write-Output "Results have been exported to: $csvFilePath"

# Disconnect session
Disconnect-PnPOnline
