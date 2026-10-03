# Run from PowerShell: ./tool/generate_app_icon.ps1
# Converts the splash SVG's M/L/H/V/C/Z path to Android launcher PNGs.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot -Parent
$res = Join-Path $root 'android/app/src/main/res'
[xml]$svg = Get-Content (Join-Path $root 'assets/images/splash_symbol.svg')
$pathData = $svg.svg.path.d
$tokens = [regex]::Matches($pathData, '[a-zA-Z]|-?\d+(?:\.\d+)?')
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$point = [System.Drawing.PointF]::new(0, 0)
$script:tokenIndex = 0
function Read-Number {
    $value = [float]::Parse($tokens[$script:tokenIndex].Value, [Globalization.CultureInfo]::InvariantCulture)
    $script:tokenIndex++
    return $value
}
while ($script:tokenIndex -lt $tokens.Count) {
    $command = $tokens[$script:tokenIndex].Value
    $script:tokenIndex++
    switch ($command) {
        'M' {
            $path.StartFigure()
            $point = [System.Drawing.PointF]::new((Read-Number), (Read-Number))
        }
        'L' {
            $next = [System.Drawing.PointF]::new((Read-Number), (Read-Number))
            $path.AddLine($point, $next)
            $point = $next
        }
        'V' {
            $next = [System.Drawing.PointF]::new($point.X, (Read-Number))
            $path.AddLine($point, $next)
            $point = $next
        }
        'H' {
            $next = [System.Drawing.PointF]::new((Read-Number), $point.Y)
            $path.AddLine($point, $next)
            $point = $next
        }
        'C' {
            $control1 = [System.Drawing.PointF]::new((Read-Number), (Read-Number))
            $control2 = [System.Drawing.PointF]::new((Read-Number), (Read-Number))
            $next = [System.Drawing.PointF]::new((Read-Number), (Read-Number))
            $path.AddBezier($point, $control1, $control2, $next)
            $point = $next
        }
        'Z' { $path.CloseFigure() }
        default { throw "Unsupported SVG command: $command" }
    }
}
function Save-Icon([int]$size, [string]$destination) {
    $large = [System.Drawing.Bitmap]::new($size * 4, $size * 4)
    $graphics = [System.Drawing.Graphics]::FromImage($large)
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#064E3B'))
    $graphics.SmoothingMode = 'AntiAlias'
    $graphics.TranslateTransform($large.Width * 0.18, $large.Height * 0.18)
    $scale = $large.Width * 0.64 / 94
    $graphics.ScaleTransform($scale, $scale)
    $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 6)
    $pen.StartCap = 'Round'
    $pen.EndCap = 'Round'
    $graphics.DrawPath($pen, $path)
    $output = [System.Drawing.Bitmap]::new($size, $size)
    $resize = [System.Drawing.Graphics]::FromImage($output)
    $resize.InterpolationMode = 'HighQualityBicubic'
    $resize.DrawImage($large, 0, 0, $size, $size)
    $output.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
    $resize.Dispose()
    $output.Dispose()
    $pen.Dispose()
    $graphics.Dispose()
    $large.Dispose()
}
foreach ($entry in @{mdpi=48; hdpi=72; xhdpi=96; xxhdpi=144; xxxhdpi=192}.GetEnumerator()) {
    Save-Icon $entry.Value (Join-Path $res "mipmap-$($entry.Key)/ic_launcher.png")
}
Save-Icon 1024 (Join-Path $root 'assets/images/app_icon.png')
# Keep the symbol inside the safe area of adaptive launcher masks.
$foreground = @"
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <group android:scaleX="0.5744681" android:scaleY="0.5744681"
        android:translateX="27" android:translateY="27">
        <path android:pathData="$pathData"
            android:strokeColor="#FFFFFF" android:strokeWidth="6"
            android:strokeLineCap="round" android:fillColor="@android:color/transparent" />
    </group>
</vector>
"@
[IO.File]::WriteAllText((Join-Path $res 'drawable/ic_launcher_foreground.xml'), $foreground)
$path.Dispose()

