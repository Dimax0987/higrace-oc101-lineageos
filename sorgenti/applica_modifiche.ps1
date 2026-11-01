# Applica le modifiche HiGrace alla ROM estratta in rom_work (ripetibile). Lanciare dalla cartella platform-tools.
$ErrorActionPreference = 'Stop'
$root = "higrace_tools\rom_work\LineageOS-23"
$sys  = "$root\system"
$fsc  = "higrace_tools\rom_work\config\LineageOS-23_fs_config"
$fcx  = "higrace_tools\rom_work\config\LineageOS-23_file_contexts"
$add  = "higrace_tools\rom_add"

function Write-Lf($path, $text) { [IO.File]::WriteAllText((Resolve-Path -LiteralPath (Split-Path $path)).Path + '\' + (Split-Path $path -Leaf), $text.Replace("`r`n", "`n"), (New-Object Text.UTF8Encoding $false)) }
function Add-Line($file, $line) { if (-not (Select-String -LiteralPath $file -SimpleMatch -Pattern $line -Quiet)) { [IO.File]::AppendAllText((Resolve-Path -LiteralPath $file).Path, "$line`n") ; "  + $line" } }

# 1. Debloat: app di telefonia/NFC/inutili su tablet solo Wi-Fi, Contatti (resta il provider)
$via = 'app\CarrierDefaultApp','app\QcRilAm','app\SecureElement','app\SimAppDialog','app\Stk',
       'priv-app\CallLogBackup','priv-app\CellBroadcastLegacyApp','priv-app\MtkInCallService','priv-app\ONS','priv-app\Tag',
       'product\app\messaging','product\priv-app\Dialer','product\priv-app\ImsServiceEntitlement','product\priv-app\Contacts',
       'system_ext\app\WAPPushManager','system_ext\app\LocalContactsBackup','system_ext\priv-app\EmergencyInfo',
       'system_ext\priv-app\Iwlan','system_ext\priv-app\QualifiedNetworksService','system_ext\priv-app\QuickAccessWallet'
"1. Debloat"
foreach ($d in $via) { if (Test-Path -LiteralPath "$sys\$d") { Remove-Item -LiteralPath "$sys\$d" -Recurse -Force; "  - $d" } }

# 2. Feature telefonia svuotate (tablet solo Wi-Fi)
"2. Feature telefonia"
$vuoto = "<?xml version=`"1.0`" encoding=`"utf-8`"?>`n<!-- svuotato per HiGrace OC101: tablet solo Wi-Fi -->`n<permissions/>`n"
foreach ($x in 'android.hardware.telephony.gsm.xml','android.hardware.telephony.ims.xml') { Write-Lf "$sys\etc\permissions\$x" $vuoto; "  = $x" }

# 3. Proprietà: adb aperto senza autorizzazione, fuso orario predefinito
"3. Proprieta"
$p = "$sys\system_ext\etc\build.prop"
$t = [IO.File]::ReadAllText((Resolve-Path $p).Path)
if ($t -match "ro\.adb\.secure=1") { [IO.File]::WriteAllText((Resolve-Path $p).Path, ($t -replace "ro\.adb\.secure=1", "ro.adb.secure=0"), (New-Object Text.UTF8Encoding $false)); "  = ro.adb.secure=0" }
$bp = "$sys\build.prop"
Add-Line $bp "# HiGrace OC101"
Add-Line $bp "persist.sys.usb.config=adb"
Add-Line $bp "persist.sys.timezone=Europe/Rome"

# 4. Correzioni hardware e ottimizzazioni (ex init_boot Magisk + modulo higrace_tweaks)
"4. higrace.sh / higrace.rc"
Write-Lf "$sys\bin\higrace.sh" (Get-Content -Raw "$add\higrace.sh")
Write-Lf "$sys\etc\init\higrace.rc" (Get-Content -Raw "$add\higrace.rc")
Add-Line $fsc "LineageOS-23/system/bin/higrace.sh 0 2000 0755"
Add-Line $fsc "LineageOS-23/system/etc/init/higrace.rc 0 0 0644"
Add-Line $fcx "/LineageOS-23/system/bin/higrace\.sh u:object_r:phhsu_exec:s0"
Add-Line $fcx "/LineageOS-23/system/etc/init/higrace\.rc u:object_r:system_file:s0"
"Fatto."
