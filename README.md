README:
#  README
:'
Version 2.1
-----------------------------
Credit to redditor /u/jvinch76  https://www.reddit.com/user/jvinch76 for creating the basis for this modification.
-----------------------------
Original Source https://www.reddit.com/r/pihole/comments/9gw6hx/sync_two_piholes_bash_script/
Previous Pastebin https://pastebin.com/KFzg7Uhi
-----------------------------
Reddit link https://www.reddit.com/r/pihole/comments/9hi5ls/dual_pihole_sync_20/
-----------------------------
Improvements:  check for existence of files before rsync and skip if not present, allow for remote command to be run without password by adding ssh keys to remote host no no longer require hard coding password in this script, HAPASS removed
-----------------------------
 
I had been thinking of a script like his to keep my primary and secondary pihole in sync, but could not find the motivation to create it.
/u/jvinch76 did the heavy lifting and I made changes I hope you find useful.
 
I modified the code to increase the frequency of the sync to every 5 minutes and reduce the file writes by using rsync to compare the files and only transfer changes.
Furthermore, gravity will be updated and services restarted only if files are modified and a sync occurs.
 
I am unsure of the performance cost, but it is likely there is a trade-off with rsync being more cpu heavy, but this script reduces the disk write to minimal amounts if no sync is necessary.
 
Why run dual piholes?
If you are not, you really, really should be.  If the primary pihole is being updated, undergoing maintenance, running a backup, or simply failed you will not have a backup pihole available.
This will happen on your network.  Your only other option during an outage (usually unexpected) is to configure your DHCP server to forward to a non-pihole, public DNS, thusly defeating why you have pihole installed in the first place.
Furthermore, DNS is high availability by design and the secondary\tertiary DNS always receives some portion of the DNS traffic and if configured with a public DNS IP, your devices will be bypassing the safety of pihole blocking.
If you are running a single pihole and have that pihole listed as the only DNS entry in your DHCP setting, all devices on your network will immediately be unable to resolve DNS if that pihole goes offline.
I recommend running a PI3 as your primary and a PI3/PI2/ZeroW as your secondary.  PI2/ZeroW is more than sufficient as a secondary and emergency failover.
 
What about using my pihole for DHCP?
I still prefer to use my router for DHCP, if you need help refer to /u/jvinch76 post https://www.reddit.com/r/pihole/comments/9gw6hx/sync_two_piholes_bash_script/
or other docs about using pihole for DHCP with this script.
 
/u/LandlordTiberius
 
'
 
# INSTALLATION STEPS ON PRIMARY PIHOLE
: '
1. Login to pihole
2. type "SUDO NANO ~/piholesync.rsync.sh" to create file
3. cut and paste all information in this code snippet
4. edit PIHOLE2 and HAUSER to match your SECONDARY pihole settings
5. save and exit
6. type "chmod +x ~/piholesync.rsync.sh" to make file executable
 
# CREATE SSH file transfer permissions
7. type "ssh-keygen"
8. type "ssh-copy-id root@192.168.1.3" <- type the same HAUSER and IP as PIHOLE2, this IP is specific to your network, 192.168.1.3 is an example only
9. type "yes" - YOU MUST TYPE "yes", not "y"
10. type the password of your secondary pihole
 
# ENABLE REMOTE COMMANDS USING SSH Keys ON Remote pihole
11  type "cd ~/.ssh"
12. type "eval `ssh-agent`" <- this step may not be needed, depending upon what is running on your primary pihole
13. type "ssh-add id_rsa.pub"
14. type "scp id_rsa.pub root@192.168.1.3:~/.ssh/"
15. login to secondary pihole (PIHOLE2) by typing "ssh root@192.168.1.3"
16. type "cd ~/.ssh"
17. type "cat id_rsa.pub >> authorized_keys"
18. type "exit"
# see https://www.dotkam.com/2009/03/10/run-commands-remotely-via-ssh-with-no-password/ for further information on running ssh commands remotely without a password.
 
# INSTALL CRON Job
19. type "crontab -e"
20. scroll to the bottom of the editor, and on a new blank line,
21. type "*/5 * * * * /bin/bash /root/piholesync.rsync.sh" <- this will run rsync every 5 minutes, edit per your preferences\tolerence, see https://crontab.guru/every-5-minutes for help
22. save and exit
 
# DONE
'




AWESOME SCRIPT!!! Thank you. Got my pi-hole servers syncing in no time. But there were some things that bothered me that I changed, wanted to share this info to anyone else who might like or need it. NOTE, I am NOT running my software on a raspberry pi so I am not sure how it might affect their performance.

I wanted to be able to update lists from any pihole server not just the first one so I did the same steps in the second server to connect to the first server too, I then changed all references in the code of "rsync -ai" to "rsync -aiu", that keeps the update from accidentally overwriting a newer file on the other server.

Waiting 5 minutes was way to long for me and I didn't like it running when no actual changes were made. To solve this I used a tool called inotifywait, this program sits and watches directories\files for changes and issues cmds when detected. The website has lots of information and examples. https://github.com/rvoicilas/inotify-tools/wiki yum install inotify-tools --or-- apt-get install inotify-tools

Here is a sample working code snippet. Add\Replace to piholesync.rync.sh( Remember this needs to run on both servers! )

#!/bin/bash -x

# START OF SCRIPT

# Dual pihole sync v2.2a

CURPATH=`pwd`

# Change /etc/pihole if your installation dir is different

inotifywait -mr --timefmt '%d/%m/%y %H:%M' --format '%T %w %f' \

-e close_write /etc/pihole | while read date time dir file; do

FILECHANGE=${dir}${file}

# convert absolute path to relative

FILECHANGEREL=`echo "$FILECHANGE" | sed 's_'$CURPATH'/__'`



# INSERT PI-HOLE SYNC SCRIPT HERE ( don't forget to change both references of "rsync -ai" to "rsync -aiu")



done

# END OF SCRIPT



This new script will now continuously monitor pihole files and only run when file changes are made.

Because of this we now need to change the 5 minutes interval run to just run once at boot time.

Start crontab -e and change"*/5 * * * * /bin/bash /root/piholesync.rsync.sh" to "@reboot /bin/bash /root/piholesync.rsync.sh"

Reboot machine and test it all out. I recommended testing the original script before using this one.Changes should be reflected almost instantly between both servers.



I made an edit to only watch for changes to *.TXT and *.LIST, otherwise the script will fire continuously because of activity with the FTL database.

inotifywait -mr --timefmt '%d/%m/%y %H:%M' --format '%T %w %f' \
-e close_write /etc/pihole/*.txt /etc/pihole/*.list | \
while read date time dir file; do

.
.
.

done