#piholesync.rsync.sh

#!/bin/bash -x
# START OF SCRIPT
# Dual pihole sync v2.2a

CURPATH=`pwd`

# Change /etc/pihole if your installation dir is different

inotifywait -mr --timefmt '%d/%m/%y %H:%M' --format '%T %w %f' \
-e close_write /etc/pihole/*.db /etc/pihole/*.list | \
while read date time dir file; do

  FILECHANGE=${dir}${file}

  # convert absolute path to relative

  FILECHANGEREL=`echo "$FILECHANGE" | sed 's_'$CURPATH'/__'`



  # INSERT PI-HOLE SYNC SCRIPT HERE ( don't forget to change both references of "rsync -ai" to "rsync -aiu")

  #VARS
  FILES=(gravity.db custom.list) #list of files you want to sync
  PIHOLEDIR=/etc/pihole #working dir of pihole
  PIHOLE2=172.16.10.2 #IP of 2nd PiHole
  HAUSER=pi #user of second pihole

  #LOOP FOR FILE TRANSFER
  RESTART=0 # flag determine if service restart is needed
  for FILE in ${FILES[@]}
  do
    if [[ -f $PIHOLEDIR/$FILE ]]; then
    RSYNC_COMMAND=$(rsync -aiuv --rsync-path="sudo rsync" $PIHOLEDIR/$FILE $HAUSER@$PIHOLE2:$PIHOLEDIR)
      if [[ -n "${RSYNC_COMMAND}" ]]; then
        # rsync copied changes
        RESTART=1 # restart flagged
       # else 
         # no changes
       fi
    # else
      # file does not exist, skipping
    fi
  done

## updates to Local DNS Records do not require restart, but update to gravity.db does.

#  if [ $RESTART == "1" ]; then
#    # INSTALL FILES AND RESTART pihole
#    ssh $HAUSER@$PIHOLE2 "sudo -S service pihole-FTL stop"
#    ssh $HAUSER@$PIHOLE2 "sudo -S pkill pihole-FTL"
#    ssh $HAUSER@$PIHOLE2 "sudo -S service pihole-FTL start"
#  fi

done

# END OF SCRIPT