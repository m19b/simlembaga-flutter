$files = Get-ChildItem -Path "d:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\lib" -Recurse -Filter *.dart
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "GoogleFonts") {
        $newContent = $content -replace "GoogleFonts\.[a-zA-Z0-9_]+\(", "TextStyle("
        $newContent = $newContent -replace "import 'package:google_fonts/google_fonts\.dart';", "// import 'package:google_fonts/google_fonts.dart';"
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Updated $($file.FullName)"
    }
}
