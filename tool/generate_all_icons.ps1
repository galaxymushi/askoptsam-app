Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\hp\askoptsam\assets\branding\logo.png"
if (-not (Test-Path $srcPath)) {
    Write-Error "Source logo not found at $srcPath"
    exit 1
}

$logo = New-Object System.Drawing.Bitmap($srcPath)
$navy = [System.Drawing.Color]::FromArgb(255, 11, 18, 41) # #0B1229
$transparent = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)

$resBase = "C:\Users\hp\askoptsam\android\app\src\main\res"

# Ensure directories exist
$anyDpiDir = Join-Path $resBase "mipmap-anydpi-v26"
if (-not (Test-Path $anyDpiDir)) {
    New-Item -ItemType Directory -Path $anyDpiDir -Force | Out-Null
}

$densities = @(
    @{ Name = "mipmap-mdpi";     LauncherSize = 48;  FgSize = 108; EmblemFg = 74 },
    @{ Name = "mipmap-hdpi";     LauncherSize = 72;  FgSize = 162; EmblemFg = 112 },
    @{ Name = "mipmap-xhdpi";    LauncherSize = 96;  FgSize = 216; EmblemFg = 150 },
    @{ Name = "mipmap-xxhdpi";   LauncherSize = 144; FgSize = 324; EmblemFg = 224 },
    @{ Name = "mipmap-xxxhdpi";  LauncherSize = 192; FgSize = 432; EmblemFg = 300 }
)

function Helper-DrawImage {
    param($graphics, $image, $x, $y, $w, $h)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.DrawImage($image, [System.Drawing.Rectangle]::new($x, $y, $w, $h))
}

foreach ($d in $densities) {
    $dir = Join-Path $resBase $d.Name
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # 1. Foreground layer for Adaptive Icons (transparent background, emblem in safe zone)
    $fgBmp = New-Object System.Drawing.Bitmap($d.FgSize, $d.FgSize)
    $fgG = [System.Drawing.Graphics]::FromImage($fgBmp)
    $fgG.Clear($transparent)
    $fgOffset = [int](($d.FgSize - $d.EmblemFg) / 2)
    Helper-DrawImage -graphics $fgG -image $logo -x $fgOffset -y $fgOffset -w $d.EmblemFg -h $d.EmblemFg
    $fgPath = Join-Path $dir "ic_launcher_foreground.png"
    $fgBmp.Save($fgPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $fgG.Dispose()
    $fgBmp.Dispose()

    # 2. Legacy Launcher Icon (navy background with rounded corners / squircle, emblem centered)
    $lSize = $d.LauncherSize
    $lBmp = New-Object System.Drawing.Bitmap($lSize, $lSize)
    $lG = [System.Drawing.Graphics]::FromImage($lBmp)
    $lG.Clear($transparent)
    
    # Rounded rectangle path for modern squircle look
    $radius = [int]($lSize * 0.22)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $rect = [System.Drawing.Rectangle]::new(0, 0, $lSize, $lSize)
    $path.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
    $path.AddArc($rect.Right - 2 * $radius, $rect.Y, $radius * 2, $radius * 2, 270, 90)
    $path.AddArc($rect.Right - 2 * $radius, $rect.Bottom - 2 * $radius, $radius * 2, $radius * 2, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - 2 * $radius, $radius * 2, $radius * 2, 90, 90)
    $path.CloseFigure()

    $lG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $brush = New-Object System.Drawing.SolidBrush($navy)
    $lG.FillPath($brush, $path)

    # Draw logo emblem centered
    $emblemSize = [int]($lSize * 0.82)
    $offset = [int](($lSize - $emblemSize) / 2)
    Helper-DrawImage -graphics $lG -image $logo -x $offset -y $offset -w $emblemSize -h $emblemSize
    
    $lPath = Join-Path $dir "ic_launcher.png"
    $lBmp.Save($lPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $brush.Dispose()
    $path.Dispose()
    $lG.Dispose()
    $lBmp.Dispose()

    # 3. Round Icon for round launcher configurations
    $rBmp = New-Object System.Drawing.Bitmap($lSize, $lSize)
    $rG = [System.Drawing.Graphics]::FromImage($rBmp)
    $rG.Clear($transparent)
    $rG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $rBrush = New-Object System.Drawing.SolidBrush($navy)
    $rG.FillEllipse($rBrush, 0, 0, $lSize, $lSize)

    $rEmblemSize = [int]($lSize * 0.82)
    $rOffset = [int](($lSize - $rEmblemSize) / 2)
    Helper-DrawImage -graphics $rG -image $logo -x $rOffset -y $rOffset -w $rEmblemSize -h $rEmblemSize

    $rPath = Join-Path $dir "ic_launcher_round.png"
    $rBmp.Save($rPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $rBrush.Dispose()
    $rG.Dispose()
    $rBmp.Dispose()

    Write-Host "Generated icons for $($d.Name)"
}

# 4. Also update drawable-nodpi/ic_launcher_foreground.png (432x432)
$nodpiDir = Join-Path $resBase "drawable-nodpi"
$nodpiFg = New-Object System.Drawing.Bitmap(432, 432)
$nodpiG = [System.Drawing.Graphics]::FromImage($nodpiFg)
$nodpiG.Clear($transparent)
Helper-DrawImage -graphics $nodpiG -image $logo -x 66 -y 66 -w 300 -h 300
$nodpiPath = Join-Path $nodpiDir "ic_launcher_foreground.png"
$nodpiFg.Save($nodpiPath, [System.Drawing.Imaging.ImageFormat]::Png)
$nodpiG.Dispose()
$nodpiFg.Dispose()

# 5. Splash logo (512x512 on transparent)
$splashBmp = New-Object System.Drawing.Bitmap(512, 512)
$spG = [System.Drawing.Graphics]::FromImage($splashBmp)
$spG.Clear($transparent)
$spEmblemSize = 420
$spOffset = (512 - $spEmblemSize) / 2
Helper-DrawImage -graphics $spG -image $logo -x $spOffset -y $spOffset -w $spEmblemSize -h $spEmblemSize
$spPath = Join-Path $nodpiDir "splash_logo.png"
$splashBmp.Save($spPath, [System.Drawing.Imaging.ImageFormat]::Png)
$spG.Dispose()
$splashBmp.Dispose()

$logo.Dispose()
Write-Host "All Android launcher and adaptive icons successfully generated!"
