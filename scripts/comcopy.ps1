function CopyWithExplorer([string]$srcfile, [string]$dstfile)
{

    $dst = Get-Item $dstfile
    $src = Get-Item $srcfile

    if( $dst.PSIsContainer )
    {
        $dstname = $dst.FullName
    }
    else
    {
        $dstname = $dst.Directory.FullName
    }

    # shell作成
    $shell = New-Object -comObject Shell.Application
    $folder = $shell.NameSpace($dstname)

    # Copy
    Write-Host "Copy File with Shell.Application"
    Write-Host "From: " $src.FullName
    Write-Host "  To: " $dstname
    Write-Host "Please allow copying with Administrator Credential" -BackgroundColor Red -ForegroundColor Black

    $folder.CopyHere($src.FullName,16)
}

try {
	if ($args.count -lt 2)
	{
		throw "Not enough arguments"
	} 
	else
	{
		CopyWithExplorer $args[0] $args[1]
	}
} catch  {
	Write-Host $error[0]
	Write-Host "`nUsage: <srcpath> <destpath>"
}