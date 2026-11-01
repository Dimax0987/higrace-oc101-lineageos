# LineageOS 23.2 (Android 16) per HiGrace OC101

> **Build NON ufficiale**: non e' prodotta ne' supportata dal progetto LineageOS.

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

Da scaricare a parte, nella cartella `strumenti\`:

- `adb.exe`, `fastboot.exe` e i file `.dll` da
  [SDK Platform-Tools for Windows](https://developer.android.com/tools/releases/platform-tools)
- `Magisk-v30.7.apk` da [github.com/topjohnwu/Magisk](https://github.com/topjohnwu/Magisk/releases)
  (solo per il root)

**Root (opzioni 3-4):** le immagini `init_boot_originale.img` e
`init_boot_magisk.img` NON sono incluse, perche' contengono il kernel del
produttore. Vanno estratte dal proprio tablet (partizione `init_boot_a`, per
esempio in modalita' FEL con xfel) e patchate con l'app Magisk. Lo script
controlla l'SHA-256 delle immagini di riferimento: con immagini estratte da un
firmware diverso si ferma senza scrivere nulla. Per installare Android 16 il
root non serve.

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

## Sorgenti

- GSI di partenza: MisterZtr, LineageOS-23.2-20260524-VANILLA-EROFS-GSI
  ([SourceForge](https://sourceforge.net/projects/misterztr-gsi/files/LineageOS/Android%2016/))
- [LineageOS](https://github.com/LineageOS), [TrebleDroid](https://github.com/TrebleDroid)
- Le modifiche fatte per questo tablet sono nella cartella [sorgenti](sorgenti)
  (vedi LEGGIMI.txt, sezione 6). La ROM contiene solo la partizione `system`:
  kernel e driver restano quelli del tablet.

## Ringraziamenti

MisterZtr (GSI), LineageOS, TrebleDroid/phh, topjohnwu (Magisk),
sekaiacg / erofs-utils, xboot (xfel).
