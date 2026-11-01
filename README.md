# LineageOS 23.2 (Android 16) per HiGrace OC101

ROM e script di installazione per il tablet **HiGrace OC101** (Allwinner A523,
scheda "863C ... A523_101HD ... OC101_EEA"), basati sulla GSI LineageOS 23.2 di
MisterZtr con le correzioni necessarie per questo tablet (schermo, app di
fabbrica, ottimizzazioni). Le istruzioni complete sono in [LEGGIMI.txt](LEGGIMI.txt).

> Solo per HiGrace OC101. L'installazione cancella tutti i dati.
> Tutto a proprio rischio.

## Cosa scaricare

Dalla pagina **Releases** di questo repository:

| File | Dove metterlo |
|---|---|
| `LineageOS-23.2-HiGrace-OC101.img` | cartella `rom\` |
| `init_boot_magisk.img`, `init_boot_originale.img` | cartella `strumenti\` (solo per il root, opzioni 3-4) |

Da scaricare a parte, nella cartella `strumenti\`:

- `adb.exe`, `fastboot.exe` e i file `.dll` da
  [SDK Platform-Tools for Windows](https://developer.android.com/tools/releases/platform-tools)
- `Magisk-v30.7.apk` da [github.com/topjohnwu/Magisk](https://github.com/topjohnwu/Magisk/releases)
  (solo per il root)

Struttura finale:

```
HiGrace_Android16.bat
LEGGIMI.txt
rom\LineageOS-23.2-HiGrace-OC101.img
sorgenti\          modifiche applicate alla GSI
strumenti\         adb, fastboot, vbmeta_disabled.img, init_boot_*.img, Magisk
```

Poi doppio clic su `HiGrace_Android16.bat`.

SHA-256 della ROM:
`828D0D982A27C9567592FE0D2C9E15134B7CCBD83514748FB5C1F0B76810F8E5`

## Ringraziamenti

MisterZtr (GSI), LineageOS, TrebleDroid/phh, topjohnwu (Magisk),
sekaiacg / erofs-utils, xboot (xfel).
