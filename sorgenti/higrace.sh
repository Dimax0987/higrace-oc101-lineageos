#!/system/bin/sh
# HiGrace OC101 (Allwinner A523) - correzioni integrate nella ROM
# Chiamato da /system/etc/init/higrace.rc nel contesto u:r:phhsu_daemon:s0

case "$1" in
post-fs)
  # App di fabbrica in /vendor/app firmate con la chiave stock e uid system: fanno crashare system_server
  mount -t tmpfs -o mode=0755 tmpfs /vendor/app && chcon u:object_r:vendor_app_file:s0 /vendor/app
  log -t higrace "vendor/app nascosta: $?"
  # Display: impedisce la sospensione runtime (schermo nero dopo 3 s con sunxihwc)
  echo on > /sys/devices/platform/soc@3000000/5000000.disp/power/control
  log -t higrace "disp control=$(cat /sys/devices/platform/soc@3000000/5000000.disp/power/control)"
  ;;

boot)
  DIR=/data/local/tmp/higrace
  mkdir -p $DIR
  {
  echo "avvio $(date)"

  # Memoria: zram = 100% RAM, lz4, swappiness 100
  # Il vendor attiva la sua zram (swapon_all) a boot completato: aspettare che finisca, poi riconfigurare
  i=0; while ! grep -q zram0 /proc/swaps && [ $i -lt 60 ]; do sleep 1; i=$((i+1)); done
  sleep 5
  # in awk: l'aritmetica di /system/bin/sh (mksh) è a 32 bit e 4 GB in byte diventano negativi
  WANT=$(awk '/MemTotal/{printf "%.0f", $2 * 1024}' /proc/meminfo)
  if [ "$(cat /sys/block/zram0/disksize)" != "$WANT" ]; then
    swapoff /dev/block/zram0 2>/dev/null
    for n in 1 2 3 4 5; do
      echo 1 > /sys/block/zram0/reset
      echo lz4 > /sys/block/zram0/comp_algorithm
      echo $WANT > /sys/block/zram0/disksize && break
      echo "disksize tentativo $n fallito"; sleep 2
    done
    /system/bin/mkswap /dev/block/zram0 >/dev/null
  fi
  grep -q zram0 /proc/swaps || /system/bin/swapon /dev/block/zram0 -p 32758
  echo 100 > /proc/sys/vm/swappiness
  echo "zram=$(cat /sys/block/zram0/disksize) alg=$(cat /sys/block/zram0/comp_algorithm) swappiness=$(cat /proc/sys/vm/swappiness)"
  echo "swap: $(tail -1 /proc/swaps)"

  # CPU: schedutil
  for p in /sys/devices/system/cpu/cpufreq/policy*; do
    echo schedutil > $p/scaling_governor
    echo "$p gov=$(cat $p/scaling_governor)"
  done

  # Pacchetti non rimovibili (APEX) o da tenere ma spenti: tablet solo Wi-Fi, niente NFC/profilazione
  for pkg in com.android.nfc com.android.cellbroadcastreceiver.module com.android.cellbroadcastservice \
    com.android.adservices.api com.android.ondevicepersonalization.services com.android.federatedcompute.services \
    com.android.healthconnect.controller com.android.virtualization.terminal com.android.egg; do
    echo "$pkg: $(pm disable-user --user 0 $pkg 2>&1 | head -1)"
  done

  # Compilazione speed di tutte le app, una volta sola (resta in primo piano: init chiude il gruppo all'uscita)
  if [ ! -f $DIR/speed_fatto ]; then
    echo "compilazione speed avviata $(date)"
    cmd package compile -m speed -a >/dev/null 2>&1
    touch $DIR/speed_fatto
    echo "compilazione speed finita $(date)"
  fi
  } > $DIR/ultimo_avvio.log 2>&1
  ;;
esac
