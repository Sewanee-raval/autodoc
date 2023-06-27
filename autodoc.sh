#!/bin/bash
# ##################################################
# autodoc.sh - Automated System Documentation
# 
# Raymond Val
#
# HISTORY:
#
# * DATE - v0.6  - First Creation
#   02 Feb 23 - v0.7	- Updated for Firewall Rules
#   21 Feb 23 - v0.8 	- Updated for fail2ban
#	08 Mar 23 - v0.9	- Added Sewanee Logo to Cover Page
#	09 Mar 23 - v0.10	- Updated the PS statement on line 68 to allow for python startup of programs
#   13 Mar 23 - v0.11   - Added section for gathering crontabs
#	14 Apr 23 - v0.12	- Added section to collect /etc/fstab
#	19 May 23 - v0.13	- Added section to collect nginx information
#   26 Jun 23 - v0.14   - Added section to collect /etc/fapolicyd/fapolicyd.conf & rules.d
#
#	TODO: Make the script more modular and add more sections
#	TODO: Add Networking Scripts
#	
# ##################################################
version="0.14" 


if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root or sudo' >&2
        exit 1
fi

input=$1
PATH=$PATH:$HOME/bin:/sbin:/bin:/usr/sbin:/usr/bin

DATE='date +%d-%m-%Y\ %R.%S'
uptime_days=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')

TableOfContent () {

echo "<div class='page-break'></div>
<h2>Introduction</h2>

The server <b> $(hostname) </b> is a $(uname) system and has an uptime of $uptime_days since last reboot.
The following document has been automatically generated on $DATE

<!--more-->

<h2>Table of Content</h2>
<ol>
	<li><a href='#role'>Server Role(s)</a></li>
	<li><a href='#general'>General Information</a></li>
	<li><a href='#network'>Network Configuration</a></li>
	<li><a href='#disk'>Disk Configuration</a></li>
	<li><a href='#configfiles'>Configuration Files</a></li>
	<li><a href='#services'>Autostart Services</a></li>
	<li><a href='#listfiles'>List of all Installed Files</a></li>

</ol>
<div class='page-break'></div>
<p style='page-break-before: always;'>&nbsp;</p>"

}


DetectLinuxRole () {
        echo "<h2 id='role' style='text-decoration:underline;'>Server Roles</h2>"
        echo "The following running application(s) have been detected on this server. This will define the Server Role(s)."

        psoutput=$(ps -o comm  --ppid 2 -N |sort -u |egrep -vi COMMAND\|grep\|ps\|sort\|hald\|nrpe\|ntpd\|dbus\|pickup\|qmgr\|bash\|avahi\|dnsmasq\|lsmd\|sshd\|sftp-server\|polkitd\|uuidd\|sh\|tail\|cat\|postdrop\|sftp-server\|cleanup\|bounce\|nagios\|crond\|gnome\|gconf\|metacity\|gvfsd\|bonobo\|gdm\|portmap\|pulseaudio\|rtkit-daemon\|at-spi-registry\|perl\|xfs\|postmaster\|rpcbind\|ypbind\|kworker\|rcu\|scsi\|irq)

        echo "</pre>"		

        exit_status=$?

        if [ $exit_status -eq 1 ]; then
                psoutput=$(ps -fea | awk '{ print $8 $9 $10}' |sort -u |egrep -vi COMMAND\|grep\|ps\|sort\|hald\|nrpe\|ntpd\|dbus\|pickup\|qmgr\|chronyd\|bash\|avahi\|dnsmasq\|lsmd\|sshd\|sftp-server\|polkitd\|uuidd\|sh\|tail\|cat\|postdrop\|sftp-server\|cleanup\|bounce\|nagios\|crond\|gnome\|gconf\|metacity\|gvfsd\|bonobo\|gdm\|portmap\|pulseaudio\|rtkit-daemon\|at-spi-registry\|perl\|xfs\|postmaster\|rpcbind\|ypbind\|kworker\|rcu\|scsi\|irq)
				
				echo "</pre>"
        fi


        cant_process=$(echo "$psoutput" | grep -v ^$ |wc -l)

        echo "<pre>"

        if (( $cant_process > 0 )); then
                apache=$(echo "$psoutput" |egrep -i apache2\|httpd | wc -l)
                nginx=$(echo "$psoutput" |grep -i nginx | wc -l)
                oracle=$(echo "$psoutput" |egrep -i oracle\|ora_ | wc -l)
                mysql=$(echo "$psoutput" |egrep -i mysqld\|mariadb | wc -l)
                postgresql=$(echo "$psoutput" |grep -i postgres | wc -l)
                sap=$(echo "$psoutput" |egrep -i sap\|jstart | wc -l)
                java=$(echo "$psoutput" |grep -i java | wc -l)
                weblogic=$(echo "$psoutput" |egrep -i WebLogic\|startNodeManage | wc -l)
                dns=$(echo "$psoutput" |egrep -i named\|bind | wc -l)
                chrony=$(echo "$psoutput" |egrep -i chronyd | wc -l)				
				mail=$(echo "$psoutput" |egrep -i master\|sendmail | wc -l)
				samba=$(echo "$psoutput" |egrep -i smbd\|nmbd | wc -l)
				nfs=$(echo "$psoutput" |egrep -i rpc.mountd\|mountd | wc -l)
				ftp=$(echo "$psoutput" |egrep -i vsftpd | wc -l)
				nis=$(echo "$psoutput" |egrep -i ypserv | wc -l)
				snmp=$(echo "$psoutput" |egrep -i snmpd | wc -l)
				dhcp=$(echo "$psoutput" |egrep -i dhcpd | wc -l)
				tomcat=$(echo "$psoutput" |egrep -i tomcat | wc -l)
				haproxy=$(echo "$psoutput" |egrep -i haproxy | wc -l)
				vrrp=$(echo "$psoutput" |egrep -i keepalived | wc -l)
				firewall=$(echo "$psoutput" |egrep -i firewalld | wc -l)
				fail2ban=$(echo "$psoutput" |egrep -i fail2ban | wc -l)
				fapolicyd=$(echo "$psoutput" |egrep -i fapolicyd | wc -l)
			

                if (( $apache > 0 )); then
                        echo "<span class='apacheicon'>Apache WebServer</span>"
                fi

                if (( $nginx > 0 )); then
                        echo "<span class='nginxicon'>Nginx WebServer</span>"
                fi

                if (( $oracle > 0 )); then
                        echo "<span class='oracleicon'>Oracle Database</span>"
                fi

                if (( $mysql > 0 )); then
                        echo "<span class='mysqlicon'>MySQL Server</span>"
                fi

                if (( $postgresql > 0 )); then
                        echo "<span class='postgresicon'>Postgresql Server</span>"
                fi

                if (( $sap > 0 )); then
                        echo "<span class='sapicon'>SAP Application</span>"
                fi

                if (( $java > 0 )); then
                        echo "<span class='javaicon'>Java Application</span>"
                fi

                if (( $weblogic > 0 )); then
                        echo "<span class='weblogicicon'>Weblogic</span>"
                fi

                if (( $dns > 0 )); then
                  echo "<span class='dnsicon'>DNS Server</span>"
                fi
				
                if (( $chrony > 0 )); then
                  echo "<span class='chronyicon'>Chrony Service</span>"
                fi

                if (( $mail > 0 )); then
                  echo "<span class='mailicon'>Mail Server</span>"
                fi

                if (( $samba > 0 )); then
                  echo "<span class='sambaicon'>Samba Server</span>"
                fi

                if (( $nfs > 0 )); then
                  echo "<span class='nfsicon'>NFS Server</span>"
                fi
				
                if (( $nis > 0 )); then
                  echo "<span class='nfsicon'>NIS Server</span>"
                fi
				
                if (( $ftp > 0 )); then
                  echo "<span class='ftpicon'>VS FTP Server</span>"
                fi
                
				if (( $snmp > 0 )); then
				  echo "<span class='ftpicon'>SNMP Server</span>"
                fi

                if (( $dhcp > 0 )); then
                  echo "<span class='dhcpicon'>DHCP Server</span>"
                fi

                if (( $tomcat > 0 )); then
                  echo "<span class='tomcaticon'>Tomcat Server</span>"
                fi

                if (( $haproxy > 0 )); then
                  echo "<span class='haproxyicon'>HA PROXY Server</span>"
                fi

                if (( $vrrp > 0 )); then
			      echo "<span class='vrrpicon'>Keepalive (VRRP) Server</span>"
                fi

                if (( $firewall > 0 )); then
			      echo "<span class='firewallicon'>Firewalld is Active</span>"
                fi

                if (( $fail2ban > 0 )); then
			      echo "<span class='fail2banicon'>Fail2ban is Active</span>"
                fi

                if (( $fapolicyd > 0 )); then
			      echo "<span class='fapolicydicon'>Fapolicyd is Active</span>"
                fi


        else
                echo "No known services has been detected in this server.";
        fi
        echo "</pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
}


InfoOSLinux () {

		echo "<p style='page-break-before: always;'>&nbsp;</p>"
        echo "<h2 id='general' style='text-decoration:underline;'>General Information</h2>"
        echo "General Information about the server $(hostname)"
        echo "<pre>"
		if hash hostnamectl 2>/dev/null; then
				hostnamectl
		else
                #os_version=$(uname -o)
                if [ -f "/etc/system-release" ]; then
                        os_version=$(cat /etc/system-release);
                elif [ -f "/etc/redhat-release" ]; then
                        os_version=$(cat /etc/redhat-release);
                elif [ -f "/etc/issue" ]; then
                        os_version=$(cat /etc/issue |grep -v ^$);
                elif [ -z ${os_version+x} ]; then
                        os_version=$(uname -o);
                fi

                echo "<strong>Hostname         :</strong> $(hostname)"
                echo "<strong>Operating System :</strong> $os_version"
                echo "<strong>Kernel           :</strong> $(uname -r)"
                echo "<strong>Uptime           :</strong> $(uptime)"
        fi
        echo "</pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
 	
}


InfoIpsLinux () {
        #ip=$(/sbin/ifconfig -a |grep "inet " |awk '{print $2}' |awk -F":" '{if ($2-eq"") print $1; else print $2}' |grep -v 127.0.0.1)

        ip=$(ifconfig -a |grep "inet " |awk '{print $2}' |awk -F":" '{if ($2) print $2; else print $1}'|grep -v 127.0.0.1)

        echo "<h2 id='ipaddresses' style='text-decoration:underline;'>IP Addresses</h2>"
		echo "<pre>$ip</pre>"

        count_ip=$(echo "$ip" | grep -v ^$ | wc -l)

        if (( $count_ip == 1 )); then
                echo "<b>NOTE:</b> Cannot detect a secondary ip address"
        fi
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
}


InfoSystemLinux () {
        echo "<h2 id='hardwareinfo' style='text-decoration:underline;'>Hardware Information</h2>"
        echo "<pre>"
   		if hash dmidecode 2>/dev/null; then
			dmidecode -t system |grep Manufacturer
			dmidecode -t system |grep Product
			dmidecode -t system |grep -i  "Serial Number"
        fi
        echo -n "        Number of CPU : "; cat /proc/cpuinfo |grep processor |wc -l
        echo -n "        CPU Model     : "; cat /proc/cpuinfo |grep "model name" |sort -u |awk -F":" '{print $2}'
        echo -n "        Meminfo       : "; cat /proc/meminfo |grep MemTotal |awk '{print $2 $3}'
        echo "</pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
        
}


NetworkConfigLinux () {
        echo "<h2 id='network' style='text-decoration:underline;'>Network Configuration</h2>"
		
		echo "<h3 id='ifconfig'>Network Cards</h3>"
        echo "<span id='ifconfigspan'>Network cards configured in this server <b>ifconfig -a</b>"
        echo "<pre><small>"
        ifconfig -a
        echo "</small></pre>"
		echo "</span>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        
		echo "<h3 id='netstat'>Default Gateway</h3>"
        echo "<span id='netstatspan'>Route tables and default gateway: <b>netstat -nre</b>"
        echo "<pre><small>"
        netstat -nre
        echo "</small></pre>"
		echo "</span>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        
		echo "<h3 id='resolv'>DNS Information</h3>"
        echo "<span id='resolvspan'>Configured DNS Servers in <b>/etc/resolv.conf</b>"
        echo "<pre><small>"
		echo "<xmp>"
        cat /etc/resolv.conf
		echo "</xmp>"
		echo "</small></pre>"
		echo "</span>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
}


DiskConfigLinux () {

        echo "<h2 id='disk' style='text-decoration:underline;'>Disk Configuration</h2>"
        echo "<span id='df'>Local Filesystem  <b>df -hPl</b>"
        echo "<pre>"
        df -hPl -xsquashfs
        echo "</pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        if hash pvs 2>/dev/null; then
				echo "<span id='pvs'>Physical Volume Information<b> pvs --units G</b>"
				echo "<pre>"
				pvs --units G
				echo "</pre>"
				echo "</span>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi

        if hash vgs 2>/dev/null; then
				echo "<span id='vgs'>Volume Group Information<b> vgs --units G</b>"
				echo "<pre>"
				vgs --units G
				echo "</pre>"
				echo "</span>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi

        if hash lvs 2>/dev/null; then
				echo "<span id='lvs'>Logical Volume Information<b> lvs --units G</b>"
				echo "<pre>"
				lvs --units G
				echo "</pre>"
				echo "</span>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi

        if hash vgdisplay 2>/dev/null; then
				echo "<span id='vgdisplay'>Display Volume Group Information<b> vgdisplay -v --units G</b>"
				echo "<pre>"
				vgdisplay -v --units G
				echo "</pre>"
				echo "</span>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi

        if hash lsblk 2>/dev/null; then
                echo "<span id='lsblk'>Block Devices list <b>lsblk -e7</b>"
                echo "<pre>"
                lsblk -e7
                echo "</pre>"
				echo "</span>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        fi
		echo "</span>"
        echo "<div class='page-break'> </div>"
        echo "<span id='mount'>Local Mount points <b>mount</b>"
        echo "<pre><small>"
        mount | column -t | grep -v ":\|squashfs\|tmpfs\|cgroup" |sed -n 's/on//p' | sed -n 's/type//p'
        echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        echo "<div class='page-break'></div>"
		echo "</span>"
		
        remote_mount=$(mount | column -t | grep ":" | sed -n 's/on//p' | sed -n 's/type//p')
        count_mount=$(echo "$remote_mount" | grep -v ^$ | wc -l)

        if (( $count_mount > 0 )); then
                echo "<h2 id='rmount'>Remote Mount Points</h2>"
                echo "Remote Mount Points <b>mount | column -t | grep ":"</b>"
                echo "<pre><small>"
                echo "$remote_mount"
                echo "</small></pre>"
        fi

        echo "<div class='page-break'> </div>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
}


LastUpdateLinux () {
        echo "<h2 id='lastupdate'>Last Installed Software</h2>"
        echo "Last 25 software packages installed in the server"
        echo "<pre><small>"
        #redhat
        if hash rpm 2>/dev/null; then
                rpm -qa --last  |head -25
        else
                grep install /var/log/dpkg.log |tail -25
                grep install /var/log/dpkg.log.[0-9] |tail -25
                zcat /var/log/dpkg.log.*.gz |grep install  |sort  |tail -25
        fi
        echo "</small></pre>"
        echo "<div class='page-break'> </div>"
}

CPUProcessLinux () {
        echo "<h2 id='cpuuse'>Five Major CPU usage process</h2>"
        echo "Stats with the five process with major CPU usage since last process or server restart."
        echo "<pre>"
        echo "CPU Time Process"
        ps -e -o time,comm |grep -v COMMAND | sort -nr | head -5
        echo "</pre>"
}

RAMProcessLinux () {
        echo "<h2 id='ramuse'>Five Major RAM usage process</h2>"
        echo "Stats with the five process with major RAM usage since last process or server restart."
        echo "<pre>"
        echo "Memory  User  Process"
        ps -e -o 'vsz user comm' |sort -nr|head -5
        echo "</pre>"
        echo "<div class='page-break'> </div>"
}

DSTLinux () {
        echo "<h2 id='dst'>Daylight Saving Time</h2>"
        echo "Next daylight saving time changes"

        DATE1=`date +%Y`
        DATE2=$((DATE1 + 1))
        echo "Year $DATE1."
        echo "<pre><small>"
        zdump -v /etc/localtime |grep $DATE1
        echo "</small></pre>"

        echo "Year $DATE2."
        echo "<pre><small>"
        zdump -v /etc/localtime |grep $DATE2
        echo "</small></pre>"
        echo "<div class='page-break'> </div>"

}


ConfigFiles () {
        echo "<h2 id='configfiles' style='text-decoration:underline;'>Configuration files</h2>"
}

GroupFile () {
        echo "<h2 id='groupfile' style='text-decoration:underline;'>/etc/group file</h2>"
        echo "<h3>Contents of /etc/group file</h3>"
		echo "<pre><small>"
		echo "<xmp>"
        cat /etc/group  |grep -v "^#" |grep -v ^$
		echo "</xmp>"
		echo "</small></pre>"

		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        echo "<div class='page-break' style='page-break-before: always;'></div>"
}

UserFile () {
        echo "<h2 id='userfile' style='text-decoration:underline;'>/etc/passwd file</h2>"
        echo "<h3>Contents of /etc/passwd file</h3>"
		echo "<pre><small>"
		echo "<xmp>"
        cat /etc/passwd  |grep -v "^#" |grep -v ^$
        echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        echo "<div class='page-break' style='page-break-before: always;'></div>"
}

HostFile () {
        echo "<h2 id='hostfile' style='text-decoration:underline;'>/etc/hosts File</h2>"
        echo "<h3>Contents of /etc/hosts file</h3>"
		echo "<pre><small>"
		echo "<xmp>"
        cat /etc/hosts  |grep -v ^$		
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        echo "<div class='page-break' style='page-break-before: always;'></div>"
}

FstabFile () {
        echo "<h2 id='fstabfile' style='text-decoration:underline;'>/etc/fstab File</h2>"
        echo "<h3>Contents of /etc/fstab file</h3>"
		echo "<pre><small>"
		echo "<xmp>"
        cat /etc/fstab  |grep -v ^$		
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        echo "<div class='page-break' style='page-break-before: always;'></div>"
}

DNSConf () {

        echo "<h2 id='ntp' style='text-decoration:underline;'>Network Time Protocol Config</h2>"
        if [ -f "/etc/ntp.conf" ]; then
		        echo "File /etc/ntp.conf"
				echo "<pre><small>"
				echo "<xmp>"
                cat /etc/ntp.conf |grep -v "^#" |grep -v ^$
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:15%;text-align:left;margin-left:0">'
        elif [ -f "/etc/chrony.conf" ]; then
                echo "File /etc/chrony.conf detected"
				echo "<pre><small>"
				echo "<xmp>"
                cat /etc/chrony.conf |grep -v "^#" |grep -v ^$
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:15%;text-align:left;margin-left:0">'
        elif [ -f "/etc/systemd/timesyncd.conf" ]; then
                echo "File /etc/systemd/timesyncd.conf detected"
				echo "<pre><small>"
				echo "<xmp>"
                cat /etc/systemd/timesyncd.conf |grep -v ^$
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:15%;text-align:left;margin-left:0">'
        else
                echo "No Network Time Protocol configuration found"
        fi


        echo "<h2>Time sync</h2>"
        echo "<pre><small>"
		echo "<xmp>"
        if hash timedatectl 2>/dev/null; then
                echo "Command: timedatectl"
                timedatectl
        elif hash ntpq 2>/dev/null; then
                echo "Command: ntpq -p"
                ntpq -p
        elif hash ntpdate 2>/dev/null; then
                echo "Command: ntpdate -p"
                ntpdate -p
        else
                echo "config not found"
        fi
		echo "</xmp>"
        echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
}

BannerFile () {
        echo "<h2 id='banner' style='text-decoration:underline;'>System Banner Files</h2>"
        if [ -f "/etc/issue" ]; then
		        echo "<h3>Contents of /etc/issue file</h3>"
				echo "<pre><small>"
				echo "<xmp>"
                cat /etc/issue
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        fi
		if [ -f "/etc/issue.net" ]; then
                echo "<h3>Contents of /etc/issue.net file</h3>"
				echo "<pre><small>"
				echo "<xmp>"
                cat /etc/issue.net
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
        if [ -d "/etc/update-motd.d" ]; then
		        echo "<h3>Contents of /etc/update-motd.d directory</h3>"
				
				FILES="/etc/update-motd.d/*"
				for f in $FILES
				do
					echo "<h4>Contents of $f file...</h4>"
					# take action on each file. $f store current file name
					echo "<pre><small>"
					echo "<xmp>"
					cat "$f"
					echo "</xmp>"
					echo "</small></pre>"
					echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				done
        fi
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
		echo "<div class='page-break' style='page-break-before: always;'></div>"
}

Yumcron () {
  echo "<h2 id='yumcron' style='text-decoration:underline;'>Automated Update Checking</h2>"
        if [ -f "/etc/sysconfig/yum-cron" ]; then
		        echo "<h3>Contents of /etc/sysconfig/yum-cron file</h3>"
				echo "<pre><small>"
				echo "<xmp>"
                cat /etc/sysconfig/yum-cron
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        fi
        if [ -f "/etc/yum/yum-cron.conf" ]; then
                    echo "<h3>Contents of /etc/yum/yum-cron.conf file</h3>"
            echo "<pre><small>"
            echo "<xmp>"
                    cat /etc/yum/yum-cron.conf
            echo "</xmp>"
            echo "</small></pre>"
            echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        fi
        if [ -f "/etc/dnf/automatic.conf" ]; then
                    echo "<h3>Contents of /etc/dnf/automatic.conf file</h3>"
            echo "<pre><small>"
            echo "<xmp>"
                    cat /etc/dnf/automatic.conf
            echo "</xmp>"
            echo "</small></pre>"
            echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
        fi

}

ApacheServer () {
    echo "<h2 id='apachefile' style='text-decoration:underline;'>Apache Configuration files</h2>"
			
	if [ -d "/etc/apache2" ]; then
		# Apache 2 root directory
		echo "<h3>Contents of /etc/apache2 directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		for f in $(find /etc/apache2 -maxdepth 1 -type f ! -iname magic)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done					
		echo "<div class='page-break'></div>"

		# Apache 2 configuration available directory
		echo "<h3>Contents of /etc/apache2/conf-available directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		for f in $(find /etc/apache2/conf-available -maxdepth 1 -type f  ! -iname magic)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre><small>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done					
		echo "<div class='page-break'></div>"
		
		# Apache 2 configuration enabled directory
		echo "<h3>List of enabled configurations in /etc/apache2/conf-enabled directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		echo "<pre>"
		ls -1 /etc/apache2/conf-enabled
		echo "</pre>"
		echo "<div class='page-break'></div>"
		
		# Apache 2 sites available directory
		echo "<h3>Contents of /etc/apache2/sites-available directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		for f in $(find /etc/apache2/sites-available -maxdepth 1 -type f  ! -iname magic)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre><small>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat "$f" |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done					
		echo "<div class='page-break'></div>"
		
		# Apache 2 sites enabled directory
		echo "<h3>List of enabled sites in /etc/apache2/sites-enabled directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		echo "<pre>"
		ls -1 /etc/apache2/sites-enabled
		echo "</pre>"

		echo "<div class='page-break'></div>"
		
		# Apache 2 mods enabled directory
		echo "<h3>List of enabled mods in /etc/apache2/mods-available directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		echo "<pre>"
		ls -1 /etc/apache2/mods-enabled
		echo "</pre>"
		echo "<div class='page-break'></div>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

	elif [ -d "/etc/httpd" ]; then
		# Apache 2 configuration directory
		echo "<h3>Contents of /etc/httpd/conf directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		if [ -d "/etc/httpd/conf" ]; then
			for f in $(find /etc/httpd/conf -maxdepth 1 -type f ! -iname magic)
			do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done					
		echo "<div class='page-break'></div>"
		fi

		# Apache 2 configuration available directory
		echo "<h3>Contents of /etc/httpd/conf.d directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		if [ -d "/etc/httpd/conf.d" ]; then
			for f in $(find /etc/httpd/conf.d -maxdepth 1 -type f)
			do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre><small>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done					
		echo "<div class='page-break'></div>"
		fi
		
		# Apache 2 mods directory
		echo "<h3>Contents of /etc/httpd/conf.modules.d directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		if [ -d "/etc/httpd/conf.modules.d" ]; then
			for f in $(find /etc/httpd/conf.modules.d -maxdepth 1 -type f)
			do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre><small>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat "$f" |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done					
		echo "<div class='page-break'></div>"
		fi

	else
		echo "Unable to locate Apache2 configuration directory"
	fi
}

SambaServer () {
	echo "<h2 id='sambaserverfiles' style='text-decoration:underline;'>Samba Server Files</h2>"
	echo "<span class='sambaicon'>Samba Server</span>"
	if [ -f "/etc/samba.conf" ]; then
			echo "<h3>Contents of /etc/samba.conf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/samba.conf
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -d "/etc/samba" ]; then
			echo "<h3> Contents of /etc/samba directory</he>"
			for f in $(find /etc/samba -maxdepth 1 -type f)
			do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done					
			echo "<div class='page-break'></div>"
	fi
	if [ -f "/etc/nsswitch.conf" ]; then
			echo "<h3>Contents of /etc/nssswitch.conf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/nsswitch.conf  |grep -v "^#" |grep -v ^$
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi	
}

MysqlServer () {
	echo "<h2 id='mysqlfile' style='text-decoration:underline;'>MySQL Server files</h2>"	
	if [ -f "/etc/my.conf" ]; then
			echo "File /etc/my.conf"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/my.conf |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -f "/etc/my.cnf" ]; then
			echo "File /etc/my.cnf"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/my.cnf |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi

	if [ -d "/etc/my.conf.d" ]; then
			echo "<h3>/etc/my.conf.d directory</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			FILES="/etc/my.conf.d/*"
			for f in $FILES
			do
				echo "Contents of $f ..."
				# take action on each file. $f store current file name
				cat "$f" |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -d "/etc/mysql" ]; then
			echo "<h3>/etc/mysql directory</h3>"
			
			for f in $(find /etc/mysql -type f)
			do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre><small>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat "${f}" |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done					
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
	echo "<div class='page-break' style='page-break-before: always;'></div>"
}

PostgresqlServer () {
	echo "<h2 id='postgresserverfiles' style='text-decoration:underline;'>Postgresql Server Files</h2>"
	echo "<span class='postgresicon'>Postgresql Server</span>"
	if [ -d "/etc/postgresql" ]; then
		echo "<h3>/etc/postgresql directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		for f in $(find /etc/postgresql -maxdepth 4 -type f)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done			
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
}

Firewall () {
  echo "<h2 id='firewallfiles' style='text-decoration:underline;'>System Firewall Information</h2>"
  echo "<span class='firewallicon'><h3>Firewall Status</h3></span>"
  echo "<pre><small>"
	echo "<xmp>"
	firewall-cmd --list-all
	echo "</xmp>"
	echo "</pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

  if [ -f "/etc/firewalld/firewalld.conf" ]; then
			echo "<h3>Firewall Configuration: /etc/firewalld/firewalld.conf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/firewalld/firewalld.conf
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
  if [ -f "/etc/firewalld/lockdown-whitelist.xml" ]; then
			echo "<h3>Lockdown Whitelist: /etc/firewalld/lockdown-whitelist.xml</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/firewalld/lockdown-whitelist.xml
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi

	if [ -d "/etc/firewalld/zones" ]; then
		echo "<h3>/etc/firewalld/zones directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		for f in $(find /etc/firewald/zones -maxdepth 2 -type f)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
  if [ -d "/etc/firewalld/helpers" ]; then
		echo "<h3>/etc/firewalld/helpers directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		for f in $(find /etc/firewald/helpers -maxdepth 2 -type f)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -d "/etc/firewalld/icmptypes" ]; then
		echo "<h3>/etc/firewalld/icmptypes directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		for f in $(find /etc/firewald/icmptypes -maxdepth 2 -type f)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -d "/etc/firewalld/ipsets" ]; then
		echo "<h3>/etc/firewalld/ipsets directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		for f in $(find /etc/firewald/ipsets -maxdepth 2 -type f)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -d "/etc/firewalld/policies" ]; then
		echo "<h3>/etc/firewalld/policies directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		for f in $(find /etc/firewald/policies -maxdepth 2 -type f)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -d "/etc/firewalld/services" ]; then
		echo "<h3>/etc/firewalld/services directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		for f in $(find /etc/firewald/services -maxdepth 2 -type f)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -f "/etc/firewalld/direct.xml" ]; then
			echo "<h3>Contents of /etc/firewalld/direct.xml</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/firewalld/direct.xml
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
}

NginxServer () {
		echo "<h3>Nginx Server</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/nginx/nginx.conf
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

		if [ -d "/etc/nginx/conf.d" ]; then
			echo "<h3>/etc/nginx/conf.d directory</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			for f in $(find /etc/nginx/conf.d -maxdepth 2 -type f)
			do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
}

Fapolicyd () {
		echo "<h3>Fapolicyd</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/fapolicyd/fapolicyd.conf
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

		if [ -f "/etc/fapolicyd/compiled.rules" ]; then
				echo "<h3>Firewall Configuration: /etc/fapolicyd/compiled.rules</h3>"
				echo "<pre><small>"
				echo "<xmp>"
				cat /etc/fapolicyd/compiled.rules
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -f "/etc/fapolicyd/compiled.rules.prev" ]; then
				echo "<h3>Firewall Configuration: /etc/fapolicyd/compiled.rules.prev</h3>"
				echo "<pre><small>"
				echo "<xmp>"
				cat /etc/fapolicyd/compiled.rules.prev
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi		
		if [ -f "/etc/fapolicyd/fapolicyd.trust" ]; then
				echo "<h3>Lockdown Whitelist: /etc/fapolicyd/fapolicyd.trust</h3>"
				echo "<pre><small>"
				echo "<xmp>"
				cat /etc/fapolicyd/fapolicyd.trust
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -f "/etc/fapolicyd/rpm-filter.conf" ]; then
				echo "<h3>Lockdown Whitelist: /etc/fapolicyd/rpm-filter.conf</h3>"
				echo "<pre><small>"
				echo "<xmp>"
				cat /etc/fapolicyd/rpm-filter.conf
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -d "/etc/fapolicyd/rules.d" ]; then
			echo "<h3>/etc/fapolicyd/rules.d directory</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			for f in $(find /etc/fapolicyd/rules.d -maxdepth 2 -type f)
			do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -d "/etc/fapolicyd/trust.d" ]; then
			echo "<h3>/etc/fapolicyd/trust.d directory</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			for f in $(find /etc/fapolicyd/trust.d -maxdepth 2 -type f)
			do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
			done
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
}

ServerFiles () {
		if (( $apache > 0 )); then
			ApacheServer
		fi

		if (( $nginx > 0 )); then
				echo "<span class='nginxicon'>Nginx WebServer</span>"
			NginxServer
		fi

		if (( $oracle > 0 )); then
				echo "<span class='oracleicon'>Oracle Database</span>"
		fi

		if (( $mysql > 0 )); then
			MysqlServer
		fi

		if (( $postgresql > 0 )); then
			PostgresqlServer
		fi

		if (( $sap > 0 )); then
				echo "<span class='sapicon'>SAP Application</span>"
		fi

		if (( $java > 0 )); then
				echo "<span class='javaicon'>Java Application</span>"
		fi

		if (( $weblogic > 0 )); then
				echo "<span class='weblogicicon'>Weblogic</span>"
		fi

		if (( $dns > 0 )); then
				echo "<h2 id='dnsserverfiles' style='text-decoration:underline;'>DNS / Bind Server Files</h2>"
				echo "<span class='dnsicon'>DNS Server</span>"
		fi
		
		if (( $chrony > 0 )); then
				echo "<h2 id='dnsserverfiles' style='text-decoration:underline;'>Chronyd Server Files</h2>"
				echo "<span class='chronyicon'>DNS Server</span>"
				echo "<h3>Content of /etc/chrony.conf</h3>"
				echo "<pre><small>"
				echo "<xmp>"
				cat /etc/chrony.conf  |grep -v "^#" |grep -v ^$
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				echo "<div class='page-break'></div>"
		fi

		if (( $mail > 0 )); then
				echo "<h2 id='mailserverfiles' style='text-decoration:underline;'>Mail Server Files</h2>"
				if [ -f "/etc/aliases" ]; then
						echo "<h3>Contents of /etc/aliases</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/aliases
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi				
				if [ -f "/etc/postfix/main.cf" ]; then
						echo "<h3>Contents of /etc/postfix/main.cf</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/postfix/main.cf
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi				
				if [ -f "/etc/postfix/virtual" ]; then
						echo "<h3>Contents of /etc/postfix/virtual</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/postfix/virtual |grep -v "^#" |grep -v ^$
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi				
		fi

		if (( $samba > 0 )); then
			SambaServer
		fi

		if (( $nis > 0 )); then
                echo "<h2 id='nisserverfiles' style='text-decoration:underline;'>NIS Server Files</h2>"
				if [ -f "/etc/default/nis" ]; then
						echo "<h3>Contents of /etc/default/nis</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/default/nis
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi
				if [ -f "/etc/ypserv.securenets" ]; then
						echo "<h3>Contents of /etc/ypserv.securenets</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/ypserv.securenets
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi
				if [ -f "/etc/ypserv.conf" ]; then
						echo "<h3>Contents of /etc/ypserv.conf</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/ypserv.conf |grep -v "^#" |grep -v ^$
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi
				if [ -f "/etc/yp.conf" ]; then
						echo "<h3>Contents of /etc/ypconf</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/yp.conf  |grep -v "^#" |grep -v ^$
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi
				if [ -f "/etc/nsswitch.conf" ]; then
						echo "<h3>Contents of /etc/nssswitch.conf</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/nsswitch.conf  |grep -v "^#" |grep -v ^$
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi
				if [ -f "/etc/pamd.d/common-session" ]; then
						echo "<h3>Contents of /etc/pamd.d/common-session</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/pamd.d/common-session  |grep -v "^#" |grep -v ^$
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi

				
		fi

		if (( $nfs > 0 )); then
				echo "<h2 id='NFSserverfiles' style='text-decoration:underline;'>NFS Server Files</h2>"
				if [ -f "/etc/exports" ]; then
						echo "<h3>Contents of /etc/exports</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/exports  |grep -v "^# " |grep -v ^$ |grep -v "^#$"
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi	
		fi
		
		if (( $snmp > 0 )); then
				echo "<h2 id='SNMPserverfiles' style='text-decoration:underline;'>SNMP Files</h2>"
				echo "<h3> Contents of /etc/snmp directory</he>"
				for f in $(find /etc/snmp -maxdepth 1 -type f)
				do
					echo "<h4>Contents of  ${f} ...</h4>"
					echo "<pre>"
					echo "<xmp>"
					# take action on each file. $f store current file name
					cat $f |grep -v "^# " |grep -v ^$ |grep -v "^#$"
					echo "</xmp>"
					echo "</pre>"
					echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				done					
				echo "<div class='page-break'></div>"
		fi

		if (( $dhcp > 0 )); then
				echo "<h2 id='DHCPserverfiles' style='text-decoration:underline;'>DHCP Server Files</h2>"
				echo "<h3> Contents of /etc/dhcp/dhcpd.conf</h3>"
				echo "<pre><small>"
				echo "<xmp>"
				cat /etc/dhcp/dhcpd.conf  |grep -v "^# " |grep -v ^$ |grep -v "^#$"
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				echo "<div class='page-break'></div>"
		fi



		if (( $ftp > 0 )); then
				echo "<h2 id='ftpserverfiles' style='text-decoration:underline;'>VS FTP Server Files</h2>"
				if [ -f "/etc/vsftpd.conf" ]; then
						echo "<h3>Contents of /etc/vsftpd.conf</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/vsftpd.conf |grep -v "^# " |grep -v ^$ |grep -v "^#$"
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi	
				if [ -f "/etc/vsftpd/vsftpd.conf" ]; then
						echo "<h3>Contents of /etc/vsftpd/vsftpd.conf</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/vsftpd/vsftpd.conf |grep -v "^# " |grep -v ^$ |grep -v "^#$"
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi	
				if [ -f "/etc/ftpusers" ]; then
						echo "<h3>Contents of /etc/ftpusers</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/ftpusers
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi	
				if [ -f "/etc/vsftpd.ftpusers" ]; then
						echo "<h3>Contents of /etc/vsftpd.ftpusers</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/vsftpd.ftpusers
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi	
				if [ -f "/etc/vsftpd.user_list" ]; then
						echo "<h3>Contents of /etc/vsftpd.user_list</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/vsftpd.user_list
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi	


		fi

		if (( $haproxy > 0 )); then
				echo "<h2 id='haproxyserverfiles' style='text-decoration:underline;'>HA Proxy Server Files</h2>"
				echo "<h3> Contents of /etc/haproxy/haproxy.conf</h3>"
				echo "<pre><small>"
				echo "<xmp>"
				cat /etc/haproxy/haproxy.conf
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				echo "<div class='page-break'></div>"
		fi

		if (( $vrrp > 0 )); then
				echo "<h2 id='vrrpserverfiles' style='text-decoration:underline;'>Keepalive (VRRP) Server Files</h2>"
				echo "<h3> Contents of /etc/keepalived/keepalived.conf</h3>"
				echo "<pre><small>"
				echo "<xmp>"
				cat /etc/keepalived/keepalived.conf
				echo "</xmp>"
				echo "</small></pre>"
				echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				echo "<div class='page-break'></div>"
		fi

		if (( $firewall > 0 )); then
        Firewall
		fi
		if (( $fapolicyd > 0 )); then
        Fapolicyd
		fi



		if (( $count_mount > 0 )); then
                echo "<h2 id='nisclientfiles' style='text-decoration:underline;'>NIS Client Files</h2>"
				if [ -f "/etc/yp.conf" ]; then
						echo "<h3>Contents of /etc/ypconf</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/yp.conf |grep -v "^# " |grep -v ^$ |grep -v "^#$"
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi
				if [ -f "/etc/nsswitch.conf" ]; then
						echo "<h3>Contents of /etc/nssswitch.conf</h3>"
						echo "<pre><small>"
						echo "<xmp>"
						cat /etc/nsswitch.conf |grep -v "^# " |grep -v ^$ |grep -v "^#$"
						echo "</xmp>"
						echo "</small></pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi
				if [ -d "/etc/systemd/system/systemd-logind.service.d" ]; then
						echo "<h3>Contents of /etc/systemd/system/systemd-logind.service.d directory</h3>"
						
						FILES="/etc/systemd/system/systemd-logind.service.d/*"
						for f in $FILES
						do
							echo "<h4>Contents of $f file...</h4>"
							# take action on each file. $f store current file name
							echo "<pre><small>"
							echo "<xmp>"
							cat "$f"
							echo "</xmp>"
							echo "</small></pre>"
							echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
						done
						echo "<div class='page-break'></div>"
				fi
				if [ -f "/lib/systemd/system/systemd-logind.service" ]; then
						echo "<h3>IP Address Deny line of /lib/systemd/system/systemd-logind.service</h3>"
						echo "<pre>"
						egrep 'IPAddressDeny' /lib/systemd/system/systemd-logind.service
						echo "</pre>"
						echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
				fi				
        fi
		
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'		
}


ServicesAutoStart () {
        echo "<h2 id='services' style='text-decoration:underline;'>Autostart Services</h2>"
        echo "The server autostart services are."
        echo "<pre>"

        if hash systemctl 2>/dev/null; then
                echo "<!-- systemctl1 -->"
        systemctl list-unit-files |grep enabled
                echo "<!-- systemctl2 -->"
        elif hash chkconfig 2>/dev/null; then
                echo "<!-- chkconfig1 -->"
                chkconfig --list |grep "3:on\|5:on"
                echo "<!-- chkconfig2 -->"
        else
                echo "Runlevel 2"
                ls -l /etc/rc2.d/S* | awk '{print $NF}' |sort -u
                echo "Runlevel 3"
                ls -l /etc/rc3.d/S* | awk '{print $NF}' |sort -u

                ls -l /sbin/rc3.d/S* | awk '{print $NF}' |sort -u

                echo "Runlevel 5"
                ls -l /etc/rc5.d/S* | awk '{print $NF}' |sort -u
        fi
        echo "</pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'		
}

ListCrontabs () {
	echo "<h2 id='listcrontabs' style='text-decoration:underline;'>All Available Crontabs</h2>"
		echo "<pre><small>"
		for f in $(find /var/spool/cron -maxdepth 2 -type f)
		do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
}

ListAllFiles () {
        echo "<h2 id='listfiles' style='text-decoration:underline;'>All Installed Software</h2>"
        echo "<pre><small>"
		#ubuntu
		if hash dpkg-query 2>/dev/null; then
				dpkg-query -W -f '${status} ${package} \t ${version} \t ${origin}\n' | sed -n 's/^install ok installed //p' | column -t
		elif hash apt 2>/dev/null; then
				apt list --installed | column -t
		# RHEL / Oracle
		elif hash dnf 2>/dev/null; then
				dnf list --installed
		elif hash yum 2>/dev/null; then
				yum list installed
        elif hash rpm 2>/dev/null; then
                rpm -qa --last  |head -25
        else
				echo "Unknown Package Manager - Aborting package list"
        fi
        echo "</small></pre>"
        echo "<div class='page-break'> </div>"
}

HeaderPage () {
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta charset="UTF-8" />
    <title>'"$(hostname)"'</title>
    <meta name="author" content="Raymond Val" />
  </head>
  <body>';
}

FooterPage () {
echo "  </body>
</html>";
}

CoverPage () {
DATE=`date +"%d %b %Y"`
echo "
<p style='text-align:center;'><img src='data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEA3ADcAAD/2wBDAAIBAQEBAQIBAQECAgICAgQDAgICAgUEBAMEBgUGBgYFBgYGBwkIBgcJBwYGCAsICQoKCgoKBggLDAsKDAkKCgr/2wBDAQICAgICAgUDAwUKBwYHCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgr/wAARCAG4BV8DASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9+KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKQso71zvjz4wfCj4W2bah8S/iXoPh+BV3NNrWrw2qgeuZGFVGMpytFXYbnR0V8y/ED/gsp/wAEx/hnfPp3iT9r7w3PJH97+wYLrVVHOMbrKGVSfoa821D/AIOI/wDgmFZyKlv8TPEd0GXJa38H3YC+3zqp/KvRp5LnFZXhh5tf4X/kbRw9eW0X9x9x0V8V6B/wcFf8Es9aljivvjrqml71+9qHg3UiFOeh8mB/8PUivWvht/wVF/4J6fFravgj9rzwTJIxAW31LVl0+Zs+kd0I3P4DiprZRm1BXqUJpd3F2++wpUa0d4v7j3qiqWg+JPD3irTl1jwxrtnqNo/C3VjcrNG30ZSRVvzFxk15z93RmQ6iiigAo3D1prOq/ePvX5S/Gj/g570L4Y/F3xN8OPDP7Hn/AAkGn6Dr11p9rrf/AAsX7P8AbkhlaMTeV/Z8mwNtzt3tjPU16WXZTmObSlHCQ5nHV6pWv6tGtKjVrXUFex+rmaK80/Y8/aDP7Vv7M/g79ov/AIRH+wf+Et0lb7+xvt/2r7Jl2XZ5vlx7/u5zsXr0r0uuGrTqUasqc1ZxbT9VozOUXGVmFFFFZiCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAoorG+IPxD8EfCnwZqXxC+I/iqx0XRdJtWuNR1LULhYooI1GSSzH8h1JwBkmnGMpSSSu2BryPsGT/APqr4x/bk/4L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pU7v7wuYP/Cq/hf/ANE30H/wTwf/ABNH/Cq/hf8A9E30H/wTwf8AxNb1FHtKnd/eFzB/4VX8L/8Aom+g/wDgng/+Jo/4VX8L/wDom+g/+CeD/wCJreoo9pU7v7wuYP8Awqv4X/8ARN9B/wDBPB/8TR/wqv4X/wDRN9B/8E8H/wATW9RR7Sp3f3hcwf8AhVfwv/6JvoP/AIJ4P/iaP+FV/C//AKJvoP8A4J4P/ia3qKPaVO7+8LmD/wAKr+F//RN9B/8ABPB/8TR/wqv4X/8ARN9B/wDBPB/8TW9RR7Sp3f3hcwf+FV/C/wD6JvoP/gng/wDiaP8AhVfwv/6JvoP/AIJ4P/ia3qKPaVO7+8LmD/wqv4X/APRN9B/8E8H/AMTR/wAKr+F//RN9B/8ABPB/8TW9RR7Sp3f3hcwf+FV/C/8A6JvoP/gng/8AiadB8Mfhva3Ed3afD/RIpY2DRyR6TCrKw5BBC8HPetyil7Sp3f3hcKKKKgAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAD0r4h/aa/wCC8/7If7KPx48Rfs9/Ebwd42uNa8M3UcF9NpumwPAzPCko2FplJG2QdQOa+3q/Af8A4Kzf8E9/23vjD/wUQ+J3xI+F/wCy54z13QdV1a2k03VtN0Z5ILhVsrdCUYdQGVh9RX0nC+X5bmOOnTxsrRUW173LrdLd+TZ1YSnSq1Gqj0t3sfb/APxE2/sG/wDQg/ET/wAE9t/8kUf8RNv7Bv8A0IPxE/8A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aKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACkKKTkilooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigArD8Y/Ez4cfDtLeT4geP9F0JbpmFq2s6pDaiYrjcF8xl3YyM46ZFbh5GDX5B/wDB0YdQ8X+MPgH8K/C9hJeateTa41vaRp80sk8mnQwop7lmVxj6V6mS5dHNsyhhZS5VK93va0W/0NsPS9tVUG7XP1EP7Tv7Ng6/tCeB/wDwrLP/AOOUf8NO/s1/9HC+B/8AwrLP/wCOV+VHwb/4NbdV1XwjZ6t8df2ojpOrXFukl1pPh7w+LiO2cjJj86SVd5HTIQDPTjr34/4NYvgARn/hqjxh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1j7XrVxeeaLcymLHnO2zHnSdMZzz0Fdp+0n+zd8Jf2tPhBqXwL+N+hz6l4b1aW3kvbO3vpLd3aGZJo8SRsGGHRTwecYPFfm1SOBWM5YSk6V1q0ua2l9L2utba6+R5T9nz6N2/E/Ob/g4T/4KH/s7eKf2VF/Zb+DXxf0XxTr/AIk12zm1qHw5qkd5DZWNu5mxNJCzIJDMkGIyc4BYgYXP4qV/RR/xD2f8Et/+iL6z/wCFnqH/AMeo/wCIe3/glv8A9EW1j/ws9R/+PV+h5LxRw7kuBWHpKo9W23GOrf8A295I9PD4zC4enyq/4f5lz/gmB/wUo/ZL+K/7HngPw9rvx48K6D4n8M+FbHSNf0PXtagsbiOa2gWDzFSZl8xGEYYMmVG7BIIxX2PY31lqllDqWm3cdxb3EayW9xDIGSRGGVZSOCCOQRwRXxX/AMQ9n/BLf/oi+s/+FnqH/wAer7J8I+FtG8DeFNL8FeHLdodP0fT4bKxhaQuUhiQIiljkkhVHJ5NfD5tLKalZ1ME5+822pJK1+zTd/mefW9i5Xp3+ZoUUUV5JiFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRgEYIoooAKKKKACiiigAooooAKKKKACjA9KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAo/CiigAwPSiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAD8KKKKAD8KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACgADoKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//2Q==' style='width:600px;height:192px' alt='Sewanee Logo' /></p>
<h1 style='text-align:center;'>Linux System Documentation</h1>
<h2 style='text-align:center;'>System: $(hostname)</h2>
<p style='color:red;text-align:center;font-family:Times New Roman;font-size:14'><em>The information in this document is considered sensitive information and not to be shared without the explicit permission of Strategic Digital Infrastructure.</em></p>
<p style='text-align:center'><em>This document was prepared by:</em></p>
<pre style='text-align:center;font-family:Arial'><strong>Raymond Val</strong>
Linux System Administrator<br />
University of the South
735 University Avenue
Sewanee TN 37383
Phone: [Company Phone]
Email: [Company E-mail]<br />
Prepared: $(DATE)
Last Updated: [Date]
</pre>
<div style='page-break-before:always;'></div>
<p>&nbsp;</p>
<hr />
<div class='page-break'></div>";
}

unamestr=`uname`

case "$unamestr" in
        Linux*)
                 HeaderPage
				 CoverPage $input
                 TableOfContent $input
                 DetectLinuxRole
                 InfoOSLinux
                 InfoIpsLinux
                 InfoSystemLinux
                 NetworkConfigLinux
                 DiskConfigLinux
                # LastUpdateLinux
                # CPUProcessLinux
                # RAMProcessLinux
                # DSTLinux
				 ConfigFiles
                 GroupFile
                 UserFile
                 HostFile
				 FstabFile
                 DNSConf
				 BannerFile
				 ServerFiles
                 ServicesAutoStart
				 ListCrontabs
				 ListAllFiles
				 FooterPage

                ;;
        Solaris*)
                echo "Solaris"
                ;;
        FreeBSD*)
                echo "FreeBSD"
                ;;
        OpenBSD*)
                echo "OpenBSD"
                ;;
        AIX*)
                echo "AIX"
                ;;
        *)
                echo "unknown: $unamestr"
                ;;
esac

