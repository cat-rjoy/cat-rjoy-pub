# Azure Bulk Tagging


## Install Instructions
Clone or download TagCleanup.psm1.

To import the module into the current PowerShell Session.

1: Open PowerShell

2: `
Import-Module <path to module>\TagCleanup.psm1
`

Where path to module is the dot sources or full path to the module file.

## Usage

To rename a tag on all resources in a subscription:

`Set-RenameTags -tagName "Created By" -newTagName "createdBy"`