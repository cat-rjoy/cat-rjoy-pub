<#
 .Synopsis
  Rename a Tag. Connect via Connect-AzAccount to connect to your Azure Tenant.

 .Description
  Rename is case sensitive.

 .Parameter tagName
  The existing tag name to be replaced.

 .Parameter newTagName
  What to rename the tag to.

 .Example
   # Show a default display of this month.
   Set-RenameTags -tagName "Created By" -newTagName "createdBy"
#>
function Set-RenameTags {
    param (
        [Parameter(Mandatory = $true)]
        [string] $tagName,
        [Parameter(Mandatory = $true)]
        [string] $newTagName
    )
    
    Get-AzResource -TagName $tagName | ForEach-Object {
        $lock = Get-AzResourceLock -ResourceName $_.Name -ResourceType $_.ResourceType -ResourceGroupName $_.ResourceGroupName
        if (-not($lock)) {
            ForEach ($key in $_.Tags.Keys) {
                if ($key.toLower() -eq $tagName.ToLower()) {
                    $val = $_.Tags[$key]
                    $actualCaseTagName = $key
                    break
                }
            }
            if ($actualCaseTagName) {
                if (-not($_.Tags.ContainsKey($newTagName))) {
                    $_.Tags.Add($newTagName, $val)
                }
                $_.tags.Remove($actualCaseTagName)
                
                Write-Host -ForegroundColor Blue "Modifying $($_.name): `n`t$actualCaseTagName='$val'`n`t  to`n`t$newTagName='$val'"
                $_ | Set-AzResource -Force
            }
        }
        else {
            Write-Warning "$($_.name) is Locked"
        }
        Clear-Variable lock
        Clear-Variable actualCaseTagName -ErrorAction SilentlyContinue
    }
}

<#
 .Synopsis
  Bulk replace Tag Values. Connect via Connect-AzAccount to connect to your Azure Tenant.

 .Description
  Rename is case sensitive.

 .Parameter tagName
  [Optional] Restrict the bulk operation to a specific tag key set.

 .Parameter oldTagValue
  The existing value to be replaced.

 .Parameter newTagValue
  The new value for the tag.

 .Example
   # Show a default display of this month.
   Set-RenameTags -tagName "Created By" -oldTagValue "Ron Joy" -newTagValue "ron_joy@dellteam.com" 
#>
function Set-RenameTagValues {
    param (
        [string] $tagName,
        [Parameter(Mandatory = $true)]
        [string] $oldTagValue,
        [Parameter(Mandatory = $true)]
        [string] $newTagValue
    )
    if ($tagName) {
        $resources = Get-AzResource -TagName $tagName -TagValue $oldTagValue
    }
    else {
        $resources = Get-AzResource -TagValue $oldTagValue
    }

    $resources | ForEach-Object {
        $lock = Get-AzResourceLock -ResourceName $_.Name -ResourceType $_.ResourceType -ResourceGroupName $_.ResourceGroupName
        if (-not($lock)) {
            # If the tag name wasn't specified, lookup the tag with the value
            if (-not($tagName)) {
                Foreach ($Key in ($_.Tags.GetEnumerator() | Where-Object { $_.Value -eq $oldTagValue })) {
                    $tagName = $Key.Key
                }
            }
            if ($tagName) {
                # Swip Swap the new tag value, log it, and set the resource
                $_.Tags[$tagName] = $newTagValue
                Write-Host -ForegroundColor Blue "Modifying $($_.name): `n`t$tagName='$oldTagValue'`n`t  to`n`t$tagName='$newTagValue'"
                $_ | Set-AzResource -Force
            }
        }
        else {
            Write-Warning "$($_.name) is Locked, This resource will not be updated."
        }
        Clear-Variable lock
        Clear-Variable tagName
    }
}

function Set-RGTagsToResources {
    param (
        [Parameter(Mandatory = $true)]
        [string] $resourceGroupName
    )
    $group = Get-AzResourceGroup $resourceGroupName

    if ($null -ne $group.Tags) {
        $resources = Get-AzResource -ResourceGroupName $group.ResourceGroupName
        foreach ($r in $resources) {
            $lock = Get-AzResourceLock -ResourceName $r.Name -ResourceType $r.ResourceType -ResourceGroupName $r.ResourceGroupName
            if (-not($lock)) {
                $resourcetags = (Get-AzResource -ResourceId $r.ResourceId).Tags
                if ($resourcetags) {
                    foreach ($key in $group.Tags.Keys) {
                        if (-not($resourcetags.ContainsKey($key))) {
                            $resourcetags.Add($key, $group.Tags[$key])
                        }
                    }
                    Set-AzResource -Tag $resourcetags -ResourceId $r.ResourceId -Force
                }
                else {
                    Set-AzResource -Tag $group.Tags -ResourceId $r.ResourceId -Force
                }
            } 
            else {
                Write-Warning "$($r.name) is Locked, This resource will not be updated."
            }
            Clear-Variable lock
        }
    }
}

# Set-RenameTagValues -oldTagValue "Dev (PoC)" -newTagValue "Dev"


Export-ModuleMember -Function Set-RenameTags
Export-ModuleMember -Function Set-RenameTagValues
Export-ModuleMember -Function Set-RGTagsToResources