#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

## Make sure any modules we depend on are installed
$modulesToInstall = @(
    'GitHubActions'
)

$modulesToInstall | ForEach-Object {
    if (-not (Get-Module -ListAvailable -All $_)) {
        Write-Output "Module [$_] not found, INSTALLING..."
        Install-Module $_ -Force
    }
}

## Import dependencies
Import-Module GitHubActions -Force

Write-ActionInfo "Running from [$($PSScriptRoot)]"

function splitListInput { $args[0] -split ',' | % { $_.Trim() } }
function writeListInput { $args[0] | % { Write-ActionInfo "    - $_" } }

$inputs = @{
    markdown_path = Get-ActionInput markdown_path -Required
    report_title = Get-ActionInput report_title -Required
    report_name = Get-ActionInput report_name -Required
    github_token       = Get-ActionInput github_token -Required
    skip_check_run     = Get-ActionInput skip_check_run
}

$script:markdown_path = $inputs.markdown_path
$script:report_name = $inputs.report_name
$script:report_title = $inputs.report_title

function Publish-ToCheckRun {
    param(
        [string]$reportData,
        [string]$reportName,
        [string]$reportTitle
    )

    Write-ActionInfo "Publishing Report to GH Workflow"

    $ghToken = $inputs.github_token
    $ctx = Get-ActionContext
    $repo = Get-ActionRepo
    $repoFullName = "$($repo.Owner)/$($repo.Repo)"

    Write-ActionInfo "Resolving REF"
    $ref = $ctx.Sha
    if ($ctx.EventName -eq 'pull_request') {
        Write-ActionInfo "Resolving PR REF"
        $ref = $ctx.Payload.pull_request.head.sha
        if (-not $ref) {
            Write-ActionInfo "Resolving PR REF as AFTER"
            $ref = $ctx.Payload.after
        }
    }
    if (-not $ref) {
        Write-ActionError "Failed to resolve REF"
        exit 1
    }
    Write-ActionInfo "Resolved REF as $ref"
    Write-ActionInfo "Resolve Repo Full Name as $repoFullName"

    Write-ActionInfo "Adding Check Run"
    $url = "https://api.github.com/repos/$repoFullName/check-runs"
    $hdr = @{
        Accept = 'application/vnd.github.antiope-preview+json'
        Authorization = "token $ghToken"
    }
    $bdy = @{
        name       = $reportName
        head_sha   = $ref
        status     = 'completed'
        conclusion = 'neutral'
        output     = @{
            title   = $reportTitle
            summary = "This run completed at ``$([datetime]::Now)``"
            text    = $ReportData
        }
    }
      Invoke-WebRequest -Headers $hdr $url -Method Post -Body ($bdy | ConvertTo-Json)
}


Write-ActionInfo "Publishing Report to GH Workflow"    

if ($inputs.skip_check_run -ne $true)
    {
        Write-Output "publishing markdown"
        
        $markdownData = [System.IO.File]::ReadAllText($script:markdown_path)

        Set-Variable -Name "report_title" -Value $script:report_title

        Set-Variable -Name "report_name" -Value $script:report_name
        
        Publish-ToCheckRun -ReportData $markdownData -ReportName $report_name -ReportTitle $report_title
    }
else
    {
        Write-Output "skipping checkrun publishing"
    }

if ($stepShouldFail) {
    Write-ActionInfo "Thowing error as something went wrong"
}
