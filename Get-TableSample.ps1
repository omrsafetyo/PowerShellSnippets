[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string] 
    $Server,
    
    [parameter(Mandatory=$true)]
    [string] 
    $Database,
    
    [parameter(Mandatory=$false)]
    [string[]] 
    $Table,
    
    [parameter(Mandatory=$false)]
    [string[]] 
    $Patterns,
    
    [parameter(Mandatory=$false)]
    [string[]] 
    $Schema,
    
    [parameter(Mandatory=$false)]
    [int] 
    $SampleSize = 4,
    
    [parameter(Mandatory=$false)]
    [switch] 
    $NoClobber
)

BEGIN {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
    $sqlServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Server
}

PROCESS {
    $WhereArray = @()
    if ($Patterns -ne $null) {
        ForEach ( $Pattern in $Patterns ) {
            $WhereArray += '$_.Name -like "{0}"' -f $Pattern
        }
        $WhereString = $WhereArray -Join " -or "
        $WhereString = '({0})' -f $WhereString
        $WhereArray = @($WhereString)
    }

    if ( $Table -ne $null ) {
        $WhereArray += '($Table -contains $_.Name)'
    }

    if ( $Schema -ne $null ) {
        $WhereArray += '($Schema -contains $_.Schema)'
    }
    
    if ( $WhereString.Count -gt 0 ) {
        $WhereString = $WhereArray -Join " -or "
        $WhereBlock = [scriptblock]::Create($WhereString)
        
        $Tables = $sqlServer.Databases[$Database].Tables | Where-Object -FilterScript $WhereBlock
    }
    else {
        $Tables = $sqlServer.Databases[$Database].Tables
    }
    
    ForEach ( $sqlTable in $Tables ) {
        $ReportTable = New-Object System.Collections.ArrayList
        $Order = 1 # Assuming the Column order in the Columns property is the same as the ordinal position of the column in INFORMATION_SCHEMA(COLUMNS) 
        ForEach ( $Column in $sqlTable.Columns ) {
            $CustomObject = [PSCustomObject] @{
                Table = $sqlTable.Name
                Field = $Column.Name
                Ord = $Order
                Type = $Column.DataType.SqlDataType
                Length = $Column.DataType.MaximumLength
                Nullable = $Column.Nullable
            }
            [void]$ReportTable.Add($CustomObject)
            $Order++
        }
        
        $TSQL = 'SELECT TOP {0} {1} FROM {2}' -f $SampleSize, ($ReportTable.Field -Join ","), $sqlTable.Name
        $TSQL
        $SampleRows = $SqlServer.Databases[$Database].ExecuteWithResults($TSQL).Tables[0].Rows
        
        ForEach ($CustomObject in $ReportTable) {
            $Row = 1
            ForEach ( $SampleRow in $SampleRows ) {
                $CustomObject | Add-Member -MemberType NoteProperty -Name "Row$($Row)" -Value $SampleRow.$($CustomObject.Field)
                $Row++
            }
            $CustomObject
        }
    }
}
