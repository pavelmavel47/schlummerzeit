# Baut aus index.html die installierbare iPhone-Version im Ordner iphone-app.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$out = Join-Path $PSScriptRoot 'iphone-app'
New-Item -ItemType Directory -Force $out | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)

$page = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'index.html'), $utf8)
$head = @'
<!doctype html><html lang="de"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Schlummerzeit">
<meta name="theme-color" content="#0F1738">
<link rel="apple-touch-icon" href="icon-180.png">
<link rel="manifest" href="manifest.webmanifest">
<style>:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%}[hidden]{display:none!important}html{-webkit-text-size-adjust:100%}button{-webkit-tap-highlight-color:transparent}</style>
</head><body>

'@
$foot = @'

<script>if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js').catch(() => {});</script>
</body></html>
'@
[IO.File]::WriteAllText((Join-Path $out 'index.html'), $head + $page + $foot, $utf8)

$manifest = @'
{
  "name": "Schlummerzeit",
  "short_name": "Schlummerzeit",
  "lang": "de",
  "start_url": "./index.html",
  "scope": "./",
  "display": "standalone",
  "background_color": "#0F1738",
  "theme_color": "#0F1738",
  "icons": [
    { "src": "icon-180.png", "sizes": "180x180", "type": "image/png" },
    { "src": "icon-512.png", "sizes": "512x512", "type": "image/png", "purpose": "any maskable" }
  ]
}
'@
[IO.File]::WriteAllText((Join-Path $out 'manifest.webmanifest'), $manifest, $utf8)

# Bei jedem Build neue Version, damit installierte Apps das Update laden.
$version = Get-Date -Format 'yyyyMMddHHmmss'
$sw = @'
const CACHE = 'schlummerzeit-__VERSION__';
const FILES = ['./', './index.html', './manifest.webmanifest', './icon-180.png', './icon-512.png'];
self.addEventListener('install', e => e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting())));
self.addEventListener('activate', e => e.waitUntil(
  caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())
));
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(caches.match(e.request).then(hit => hit || fetch(e.request).then(res => {
    if (e.request.url.includes('fonts.g') || new URL(e.request.url).origin === location.origin) {
      const copy = res.clone();
      caches.open(CACHE).then(c => c.put(e.request, copy));
    }
    return res;
  })));
});
'@
[IO.File]::WriteAllText((Join-Path $out 'sw.js'), $sw.Replace('__VERSION__', $version), $utf8)

function New-Icon([int]$size, [string]$path) {
  $bmp = New-Object Drawing.Bitmap $size, $size
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $rect = New-Object Drawing.Rectangle 0, 0, $size, $size
  $sky = New-Object Drawing.Drawing2D.LinearGradientBrush $rect, ([Drawing.ColorTranslator]::FromHtml('#0F1738')), ([Drawing.ColorTranslator]::FromHtml('#3F4A96')), 90
  $g.FillRectangle($sky, $rect)
  $butter = New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml('#FFE08A'))
  # Mondsichel: grosser Kreis, davon ein versetzter Kreis abgezogen.
  $moon = New-Object Drawing.Drawing2D.GraphicsPath
  $moon.AddEllipse($size * .2, $size * .2, $size * .6, $size * .6)
  $bite = New-Object Drawing.Drawing2D.GraphicsPath
  $bite.AddEllipse($size * .38, $size * .13, $size * .52, $size * .52)
  $region = New-Object Drawing.Region $moon
  $region.Exclude($bite)
  $g.FillRegion($butter, $region)
  foreach ($s in @(@(.72, .24, .05), @(.82, .46, .03), @(.58, .17, .025), @(.74, .68, .035))) {
    $g.FillEllipse($butter, $size * $s[0], $size * $s[1], $size * $s[2], $size * $s[2])
  }
  $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}
New-Icon 180 (Join-Path $out 'icon-180.png')
New-Icon 512 (Join-Path $out 'icon-512.png')
Write-Output "Fertig: $out"
