<#
Purpose - Classify and Sync S3 files 
Requirements - AWS CLI installed and Run the script in PowerShell
Developer - K.Janarthanan
Date - 24/11/2020
Version - 1 
#>

Param(
    [Parameter(Mandatory)]
    [string]$ConfigFile
)

try 
{
    if(-not(Test-Path -Path $ConfigFile -PathType Leaf))
    {
        throw "Config file not found"
    }

    $Config = Get-Content -path $ConfigFile -EA Stop | ConvertFrom-Json

    if(-not($Config.S3Bucket))
    {
        throw "S3Bucket Parameter is not found in Config file"
    }

    foreach($Item in $Config.Sync)
    {
        $Bucket = "s3://{0}" -f $Config.S3Bucket
        $IncludeFile = "*{0}*" -f $Item.HotelName

        Write-Host "`n Working on Hotel : $($Item.HotelName)" -ForegroundColor Magenta

        if(Test-Path -path $Item.Folder)
        {
            Write-Host "Going to sync files" -ForegroundColor Green
            aws s3 sync $Bucket $Item.Folder --exclude "*" --include $IncludeFile
            Write-Host "Successfully synced files" -ForegroundColor Green
        }
        else 
        {
            Write-Host "$($Item.Folder) not found to sync files" -ForegroundColor Red    
        }    
    }

    Write-Host "`nDone with the script" -ForegroundColor Green
}
catch 
{
    Write-Host "Error Occured : $_" -ForegroundColor Red
}
