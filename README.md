# Azure Bulk Tagging


## Install Instructions
Clone or download TagCleanup.psm1.

To import the module into the current PowerShell Session.

1: Open PowerShell

2: `
Import-Module <path to module>\TagCleanup.psm1
`

Where path to module is the dot sources or full path to the module file.

## Pre-Requisites

1. Install the Powershell Az Module

https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-4.2.0

2. Connect to your Azure Tenant

`Connect-AzAccount`

3. Be sure to set the appropriate Subscription Context
https://docs.microsoft.com/en-us/powershell/module/az.accounts/set-azcontext?view=azps-4.2.0#description

`Set-AzContext -SubscriptionId "xxxx-xxxx-xxxx-xxxx"`

## Usage

### To rename a tag on all resources in a subscription:

`Set-RenameTags -tagName "CreatedBy" -newTagName "createdBy"`

### To rename a tag value on all resources in a subscription:

`Set-RenameTags -tagName "CreatedBy" -oldTagValue "Ron Joy" -newTagValue "ron_joy@github.com"`
