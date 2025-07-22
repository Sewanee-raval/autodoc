#!/usr/bin/env bash
#----------------------------------------------------------------------
# Filename: autodoc.sh
# Written : 22-May-2017 (Hernan Fernandez Retamal) - Intitial Author
# Purpose : Automated System Documentation
# Usage   : ./autodoc.sh
#         :
# Input   : N/A
#         :
# Output  : N/A
#         :
# Notes   : This script is designed to collect information about a Linux system
#         : and generate a HTML report.
#         :
# Updated :
#         :
#----------------------------------------------------------------------
#   Version History:
#	04 Jan 23 - v0.2	- Updated sections for Network, Disk, and Config Files
#   10 Jan 23 - v0.3	- Updated sections for Security, Last Update, CPU, RAM, DST
#   18 Jan 23 - v0.4	- Updated sections for Config Files, Group, User, Host, Fstab, DNS, Banner, Yumcron
#   19 Jan 23 - v0.5	- Updated sections for Apache, Nginx, MySQL, Postgres, Oracle, Samba, NFS, DNS, DHCP, FTP
#   26 Jan 23 - v0.6	- Updated sections for HAProxy, Keepalived, FirewallD, Fail2Ban, FAPolicyD, SSSD
#   02 Feb 23 - v0.7	- Updated for Firewall Rules
#   21 Feb 23 - v0.8 	- Updated for fail2ban
#	08 Mar 23 - v0.9	- Added Sewanee Logo to Cover Page
#	09 Mar 23 - v0.10	- Updated the PS statement on line 68 to allow for python startup of programs
#   13 Mar 23 - v0.11   - Added section for gathering crontabs
#	14 Apr 23 - v0.12	- Added section to collect /etc/fstab
#	19 May 23 - v0.13	- Added section to collect nginx information
#   26 Jun 23 - v0.14   - Added section to collect /etc/fapolicyd/fapolicyd.conf & rules.d
# 	14 Nov 23 - v0.15	- Changed mount so only physical and remote drives are listed
#	15 Nov 23 - v0.16	- Added Security Section
#	03 Jan 24 - v0.17 	- Fixed issue with HAProxy section not reading correct conf file, added Disclaimer Page
#	06 Jun 25 - v0.18	- Added FAPolicyD section, updated SELinux, OpenSCAP, AIDE, Logwatch, FIPS Mode sections
#						- Updated sections for FirewallD, Fail2Ban, SSSD
#
#	TODO: Make the script more modular and add more sections
#	TODO: Add Networking Scripts
#	TODO: Add Sections: Document Management, About, Functional, and Operational
#	TODO: Add Network Infrastructure under Technical
#	TODO: Add Contributors and Version Control under Document Management
#	TODO: Add Overview and Service Description under About
#	TODO: Add Users and Contact List under Functional
#	TODO: Add System Security, Remote Access, Server Infrastructure, Logging, SSL Certs, Backup, Licenses under Operational
#	TODO: Add clamav, rkhunter, chkrootkit, and other security tools
#
#----------------------------------------------------------------------

# Set Name and Version
declare -r SCRIPT_NAME=""
declare -r VERSION="0.18.0"

if [ "$(id -u)" -ne 0 ]; then
	echo 'This script must be run by root or sudo' >&2
	exit 1
fi
# Set Working Variables
prog_name=$(basename "${0}")
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
datestamp=$(date +"%Y-%m-%d")

# Set Global Variables for php
SELinuxDB=""
OpenSCAPDB=""
AIDEDB=""
LogwatchDB=""
Fail2banDB=""
FirewalldDB=""
FapolicydDB=""
ClamAVDB=""
FIPSSettingDB=""
SSSDDB=""

input=$1
PATH=$PATH:$HOME/bin:/sbin:/bin:/usr/sbin:/usr/bin

DATE="date +%d-%m-%Y\ %R.%S"
uptime_days=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')

PreparerName="Raymond Val"
PreparerPhone="931-598-1355"
PreparerEmail="raval@sewanee.edu"

TableOfContent() {

	echo "<div class='page-break'></div>
<h2>Introduction</h2>

The server <b> $(hostname) </b> is a $(uname) system and has an uptime of $uptime_days since last reboot.
The following document has been automatically generated on $(date +%d-%m-%Y\ %R.%S)

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

DetectLinuxRole() {
	echo "<h2 id='role' style='text-decoration:underline;'>Server Roles</h2>"
	echo "The following running application(s) have been detected on this server. This will define the Server Role(s)."

	psoutput=$(ps -o comm --ppid 2 -N | sort -u | egrep -vi COMMAND\|grep\|ps\|sort\|hald\|nrpe\|ntpd\|dbus\|pickup\|qmgr\|bash\|avahi\|dnsmasq\|lsmd\|sshd\|sftp-server\|polkitd\|uuidd\|sh\|tail\|cat\|postdrop\|sftp-server\|cleanup\|bounce\|nagios\|crond\|gnome\|gconf\|metacity\|gvfsd\|bonobo\|gdm\|portmap\|pulseaudio\|rtkit-daemon\|at-spi-registry\|perl\|xfs\|postmaster\|rpcbind\|ypbind\|kworker\|rcu\|scsi\|irq)

	echo "</pre>"

	exit_status=$?

	if [ $exit_status -eq 1 ]; then
		psoutput=$(ps -fea | awk '{ print $8 $9 $10}' | sort -u | egrep -vi COMMAND\|grep\|ps\|sort\|hald\|nrpe\|ntpd\|dbus\|pickup\|qmgr\|chronyd\|bash\|avahi\|dnsmasq\|lsmd\|sshd\|sftp-server\|polkitd\|uuidd\|sh\|tail\|cat\|postdrop\|sftp-server\|cleanup\|bounce\|nagios\|crond\|gnome\|gconf\|metacity\|gvfsd\|bonobo\|gdm\|portmap\|pulseaudio\|rtkit-daemon\|at-spi-registry\|perl\|xfs\|postmaster\|rpcbind\|ypbind\|kworker\|rcu\|scsi\|irq)

		echo "</pre>"
	fi

	cant_process=$(echo "$psoutput" | grep -v ^$ | wc -l)

	echo "<pre>"

	if (($cant_process > 0)); then
		apache=$(echo "$psoutput" | egrep -i apache2\|httpd | wc -l)
		nginx=$(echo "$psoutput" | grep -i nginx | wc -l)
		oracle=$(echo "$psoutput" | egrep -i oracle\|ora_ | wc -l)
		mysql=$(echo "$psoutput" | egrep -i mysqld\|mariadb | wc -l)
		postgresql=$(echo "$psoutput" | grep -i postgres | wc -l)
		sap=$(echo "$psoutput" | egrep -i sap\|jstart | wc -l)
		java=$(echo "$psoutput" | grep -i java | wc -l)
		weblogic=$(echo "$psoutput" | egrep -i WebLogic\|startNodeManage | wc -l)
		dns=$(echo "$psoutput" | egrep -i named\|bind | wc -l)
		chrony=$(echo "$psoutput" | egrep -i chronyd | wc -l)
		mail=$(echo "$psoutput" | egrep -i master\|sendmail | wc -l)
		samba=$(echo "$psoutput" | egrep -i smbd\|nmbd | wc -l)
		nfs=$(echo "$psoutput" | egrep -i rpc.mountd\|mountd | wc -l)
		ftp=$(echo "$psoutput" | egrep -i vsftpd | wc -l)
		nis=$(echo "$psoutput" | egrep -i ypserv | wc -l)
		snmp=$(echo "$psoutput" | egrep -i snmpd | wc -l)
		dhcp=$(echo "$psoutput" | egrep -i dhcpd | wc -l)
		tomcat=$(echo "$psoutput" | egrep -i tomcat | wc -l)
		haproxy=$(echo "$psoutput" | egrep -i haproxy | wc -l)
		vrrp=$(echo "$psoutput" | egrep -i keepalived | wc -l)
		sssd=$(echo "$psoutput" | egrep -i sssd | wc -l)

		if (($apache > 0)); then
			echo "<span class='apacheicon'>Apache WebServer</span>"
		fi

		if (($nginx > 0)); then
			echo "<span class='nginxicon'>Nginx WebServer</span>"
		fi

		if (($oracle > 0)); then
			echo "<span class='oracleicon'>Oracle Database</span>"
		fi

		if (($mysql > 0)); then
			echo "<span class='mysqlicon'>MySQL Server</span>"
		fi

		if (($postgresql > 0)); then
			echo "<span class='postgresicon'>Postgresql Server</span>"
		fi

		if (($sap > 0)); then
			echo "<span class='sapicon'>SAP Application</span>"
		fi

		if (($java > 0)); then
			echo "<span class='javaicon'>Java Application</span>"
		fi

		if (($weblogic > 0)); then
			echo "<span class='weblogicicon'>Weblogic</span>"
		fi

		if (($dns > 0)); then
			echo "<span class='dnsicon'>DNS Server</span>"
		fi

		if (($chrony > 0)); then
			echo "<span class='chronyicon'>Chrony Service</span>"
		fi

		if (($mail > 0)); then
			echo "<span class='mailicon'>Mail Server</span>"
		fi

		if (($samba > 0)); then
			echo "<span class='sambaicon'>Samba Server</span>"
		fi

		if (($nfs > 0)); then
			echo "<span class='nfsicon'>NFS Server</span>"
		fi

		if (($nis > 0)); then
			echo "<span class='nfsicon'>NIS Server</span>"
		fi

		if (($ftp > 0)); then
			echo "<span class='ftpicon'>VS FTP Server</span>"
		fi

		if (($snmp > 0)); then
			echo "<span class='ftpicon'>SNMP Server</span>"
		fi

		if (($dhcp > 0)); then
			echo "<span class='dhcpicon'>DHCP Server</span>"
		fi

		if (($tomcat > 0)); then
			echo "<span class='tomcaticon'>Tomcat Server</span>"
		fi

		if (($haproxy > 0)); then
			echo "<span class='haproxyicon'>HA PROXY Server</span>"
		fi

		if (($vrrp > 0)); then
			echo "<span class='vrrpicon'>Keepalive (VRRP) Server</span>"
		fi
	else
		echo "No known services has been detected in this server."
	fi
	echo "</pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
}

InfoOSLinux() {

	echo "<p style='page-break-before: always;'>&nbsp;</p>"
	echo "<h2 id='general' style='text-decoration:underline;'>General Information</h2>"
	echo "General Information about the server $(hostname)"
	echo "<pre>"
	if hash hostnamectl 2>/dev/null; then
		hostnamectl
	else
		#os_version=$(uname -o)
		if [ -f "/etc/system-release" ]; then
			os_version=$(cat /etc/system-release)
		elif [ -f "/etc/redhat-release" ]; then
			os_version=$(cat /etc/redhat-release)
		elif [ -f "/etc/issue" ]; then
			os_version=$(cat /etc/issue | grep -v ^$)
		elif [ -z ${os_version+x} ]; then
			os_version=$(uname -o)
		fi

		echo "<strong>Hostname         :</strong> $(hostname)"
		echo "<strong>Operating System :</strong> $os_version"
		echo "<strong>Kernel           :</strong> $(uname -r)"
		echo "<strong>Uptime           :</strong> $(uptime)"
	fi
	echo "</pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'

}

InfoIpsLinux() {
	#ip=$(/sbin/ifconfig -a |grep "inet " |awk '{print $2}' |awk -F":" '{if ($2-eq"") print $1; else print $2}' |grep -v 127.0.0.1)

	ip=$(ifconfig -a | grep "inet " | awk '{print $2}' | awk -F":" '{if ($2) print $2; else print $1}' | grep -v 127.0.0.1)

	echo "<h2 id='ipaddresses' style='text-decoration:underline;'>IP Addresses</h2>"
	echo "<pre>$ip</pre>"

	count_ip=$(echo "$ip" | grep -v ^$ | wc -l)

	if (($count_ip == 1)); then
		echo "<b>NOTE:</b> Cannot detect a secondary ip address"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
}

InfoSystemLinux() {
	echo "<h2 id='hardwareinfo' style='text-decoration:underline;'>Hardware Information</h2>"
	echo "<pre>"
	if hash dmidecode 2>/dev/null; then
		dmidecode -t system | grep Manufacturer
		dmidecode -t system | grep Product
		dmidecode -t system | grep -i "Serial Number"
	fi
	echo -n "        Number of CPU : "
	cat /proc/cpuinfo | grep processor | wc -l
	echo -n "        CPU Model     : "
	cat /proc/cpuinfo | grep "model name" | sort -u | awk -F":" '{print $2}'
	echo -n "        Meminfo       : "
	cat /proc/meminfo | grep MemTotal | awk '{print $2 $3}'
	echo "</pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'

}

NetworkConfigLinux() {
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

DiskConfigLinux() {

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
	mount | column -t | grep -v "snaps|squashfs\|tmpfs\|cgroup" | /bin/grep -E '^/|:/' | sed -n 's/on//p' | sed -n 's/type//p' | sort
	#mount | column -t | grep -v ":\|squashfs\|tmpfs\|cgroup" |sed -n 's/on//p' | sed -n 's/type//p'
	echo "</small></pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	echo "<div class='page-break'></div>"
	echo "</span>"

	remote_mount=$(mount | column -t | grep ":" | sed -n 's/on//p' | sed -n 's/type//p')
	count_mount=$(echo "$remote_mount" | grep -v ^$ | wc -l)

	if (($count_mount > 0)); then
		echo "<h2 id='rmount'>Remote Mount Points</h2>"
		echo "Remote Mount Points <b>mount | column -t | grep ":"</b>"
		echo "<pre><small>"
		echo "$remote_mount"
		echo "</small></pre>"
	fi

	echo "<div class='page-break'> </div>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
}

SELinuxStatus() {
	echo "<h3 id='sestatusfiles' style='text-decoration:underline;'>SELinux Status</h3>"
	if hash sestatus 2>/dev/null; then
		sestatus >/dev/null 2>&1
		sestatus=$?
	else
		sestatus=1
	fi

	if (($sestatus > 0)); then
		echo "<span class='selinuxicon'>SELinux is not installed or not enabled</span>"
	else
		sestatus=$(sestatus | grep "Current mode" | awk '{print $3}')
		echo "<span class='selinuxicon'>SELinux is installed and enabled</span>"
		echo "<span class='selinuxicon'>SELinux status is: $sestatus </span>"

	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
}

OpenSCAPLinuxStatus() {
	echo "<h3 id='openscapfiles' style='text-decoration:underline;'>OpenSCAP Status</h3>"
	if hash oscap 2>/dev/null; then
		oscap --version >/dev/null 2>&1
		oscapstatus=$?
	else
		oscapstatus=1
	fi

	if (($oscapstatus > 0)); then
		echo "<span class='openscapicon'>OpenSCAP is not installed or not enabled</span>"
	else
		oscapversion=$(oscap --version | grep "command line tool" | awk '{print $6}')
		echo "<span class='openscapicon'>OpenSCAP is installed and enabled</span>"
		echo "<span class='openscapicon'>OpenSCAP version is: $oscapversion </span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
}

AIDELinuxStatus() {
	echo "<h3 id='aidefiles' style='text-decoration:underline;'>AIDE Status</h3>"
	if hash aide 2>/dev/null; then
		aide --version >/dev/null 2>&1
		aidestatus=$?
	else
		aidestatus=1
	fi

	if (($aidestatus > 0)); then
		echo "<span class='aideicon'>AIDE is not installed or not enabled</span>"
	else
		aideversion=$(aide --version 2>&1 | head -n 1 | awk '{print $2}')
		echo "<span class='aideicon'>AIDE is installed and enabled</span>"
		echo "<span class='aideicon'>AIDE version is: $aideversion </span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
}

LogwatchLinuxStatus() {
	echo "<h3 id='logwatchfiles' style='text-decoration:underline;'>Logwatch Status</h3>"
	if hash logwatch 2>/dev/null; then
		logwatch --version >/dev/null 2>&1
		logwatchstatus=$?
	else
		logwatchstatus=1
	fi

	if (($logwatchstatus > 0)); then
		echo "<span class='logwatchicon'>Logwatch is not installed or not enabled</span>"
	else
		logwatchversion=$(logwatch --version | awk '{print $2}')
		echo "<span class='logwatchicon'>Logwatch is installed and enabled</span>"
		echo "<span class='logwatchicon'>Logwatch version is: $logwatchversion </span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
}

FIPSModeLinuxStatus() {
	echo "<h3 id='fipsfiles' style='text-decoration:underline;'>FIPS Mode Status</h3>"
	if hash fips-mode-setup 2>/dev/null; then
		fips-mode-setup --check >/dev/null 2>&1
		fipsstatus=$?
	else
		fipsstatus=1
	fi

	if (($fipsstatus > 0)); then
		echo "<span class='fipsicon'>FIPS Mode is enabled</span>"
	else
		echo "<span class='fipsicon'>FIPS Mode is not enabled</span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
}
FirewalldLinuxStatus() {
	echo "<h3 id='firewalldfiles' style='text-decoration:underline;'>Firewalld Status</h3>"
	if hash firewall-cmd 2>/dev/null; then
		firewall-cmd --state >/dev/null 2>&1
		firewall=$?
	else
		firewall=1
	fi

	if (($firewall > 0)); then
		echo "<span class='firewallicon'>Firewalld is not installed or not enabled</span>"
	else
		echo "<span class='firewallicon'>Firewalld is installed and enabled</span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

	#		firewall=$(echo "$psoutput" | egrep -i firewalld | wc -l)
	# if (($firewall > 0)); then
	# 	echo "<span class='firewallicon'>Firewalld is Active</span>"
	# else
	# 	echo "<span class='firewallicon'>Firewalld is Not Active</span>"
	# fi

}

Fail2banLinuxStatus() {
	echo "<h3 id='fail2banfiles' style='text-decoration:underline;'>Fail2Ban Status</h3>"
	if hash fail2ban-client 2>/dev/null; then
		fail2ban-client status >/dev/null 2>&1
		fail2ban=$?
	else
		fail2ban=1
	fi

	if (($fail2ban > 0)); then
		echo "<span class='fail2banicon'>Fail2Ban is not installed or not enabled</span>"
	else
		echo "<span class='fail2banicon'>Fail2Ban is installed and enabled</span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

	#		fail2ban=$(echo "$psoutput" | egrep -i fail2ban | wc -l)
	# if (($fail2ban > 0)); then
	# 	echo "<span class='fail2banicon'>Fail2ban is Active</span>"
	# else
	# 	echo "<span class='fail2banicon'>Fail2ban is Not Active</span>"
	# fi
}

FapolicdLinuxStatus() {
	fapolicydstatus=$(echo "$psoutput" | egrep -i fapolicyd | wc -l)
	echo "<h3 id='fapolicydfiles' style='text-decoration:underline;'>Fapolicyd Status</h3>"
	if hash fapolicyd 2>/dev/null; then
		fapolicydstatus=$(echo "$psoutput" | egrep -i fapolicyd | wc -l)
	else
		fapolicydstatus=0
	fi

	if (($fapolicydstatus > 0)); then
		echo "<span class='fapolicydicon'>Fapolicyd is installed and enabled</span>"
	else
		echo "<span class='fapolicydicon'>Fapolicyd is not installed or not enabled</span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

	#		fapolicyd=$(echo "$psoutput" | egrep -i fapolicyd | wc -l)
	# if (($fapolicyd > 0)); then
	# 	echo "<span class='fapolicydicon'>Fapolicyd is Active</span>"
	# else
	# 	echo "<span class='fapolicydicon'>Fapolicyd is Not Active</span>"
	# fi
	# if (($sssd > 0)); then
	# 	echo "<span class='adauthicon'>AD Authentication is Configured</span>"
	# fi

}

ClamAVLinuxStatus() {
	echo "<h3 id='clamavfiles' style='text-decoration:underline;'>ClamAV Status</h3>"
	if hash clamav 2>/dev/null; then
		clamav --version >/dev/null 2>&1
		clamavstatus=$?
	else
		clamavstatus=1
	fi

	if (($clamavstatus > 0)); then
		echo "<span class='clamavicon'>ClamAV is not installed or not enabled</span>"
	else
		clamavversion=$(clamav --version | grep "ClamAV" | awk '{print $2}')
		echo "<span class='clamavicon'>ClamAV is installed and enabled</span>"
		echo "<span class='clamavicon'>ClamAV version is: $clamavversion </span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
}

SecurityConfigLinux() {
	echo "<h2 id='security' style='text-decoration:underline;'>Security Configuration</h2>"
	SELinuxStatus
	OpenSCAPLinuxStatus
	AIDELinuxStatus
	LogwatchLinuxStatus
	FIPSModeLinuxStatus
	FirewalldLinuxStatus
	Fail2banLinuxStatus
	FapolicdLinuxStatus
	echo "<div class='page-break'> </div>"
}

LastUpdateLinux() {
	echo "<h2 id='lastupdate'>Last Installed Software</h2>"
	echo "Last 25 software packages installed in the server"
	echo "<pre><small>"
	#redhat
	if hash rpm 2>/dev/null; then
		rpm -qa --last | head -25
	else
		grep install /var/log/dpkg.log | tail -25
		grep install /var/log/dpkg.log.[0-9] | tail -25
		zcat /var/log/dpkg.log.*.gz | grep install | sort | tail -25
	fi
	echo "</small></pre>"
	echo "<div class='page-break'> </div>"
}

CPUProcessLinux() {
	echo "<h2 id='cpuuse'>Five Major CPU usage process</h2>"
	echo "Stats with the five process with major CPU usage since last process or server restart."
	echo "<pre>"
	echo "CPU Time Process"
	ps -e -o time,comm | grep -v COMMAND | sort -nr | head -5
	echo "</pre>"
}

RAMProcessLinux() {
	echo "<h2 id='ramuse'>Five Major RAM usage process</h2>"
	echo "Stats with the five process with major RAM usage since last process or server restart."
	echo "<pre>"
	echo "Memory  User  Process"
	ps -e -o 'vsz user comm' | sort -nr | head -5
	echo "</pre>"
	echo "<div class='page-break'> </div>"
}

DSTLinux() {
	echo "<h2 id='dst'>Daylight Saving Time</h2>"
	echo "Next daylight saving time changes"

	DATE1=$(date +%Y)
	DATE2=$((DATE1 + 1))
	echo "Year $DATE1."
	echo "<pre><small>"
	zdump -v /etc/localtime | grep $DATE1
	echo "</small></pre>"

	echo "Year $DATE2."
	echo "<pre><small>"
	zdump -v /etc/localtime | grep $DATE2
	echo "</small></pre>"
	echo "<div class='page-break'> </div>"

}

ConfigFiles() {
	echo "<h2 id='configfiles' style='text-decoration:underline;'>Configuration files</h2>"
}

GroupFile() {
	echo "<h2 id='groupfile' style='text-decoration:underline;'>/etc/group file</h2>"
	echo "<h3>Contents of /etc/group file</h3>"
	echo "<pre><small>"
	echo "<xmp>"
	cat /etc/group | grep -v "^#" | grep -v ^$
	echo "</xmp>"
	echo "</small></pre>"

	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	echo "<div class='page-break' style='page-break-before: always;'></div>"
}

UserFile() {
	echo "<h2 id='userfile' style='text-decoration:underline;'>/etc/passwd file</h2>"
	echo "<h3>Contents of /etc/passwd file</h3>"
	echo "<pre><small>"
	echo "<xmp>"
	cat /etc/passwd | grep -v "^#" | grep -v ^$
	echo "</xmp>"
	echo "</small></pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	echo "<div class='page-break' style='page-break-before: always;'></div>"
}

HostFile() {
	echo "<h2 id='hostfile' style='text-decoration:underline;'>/etc/hosts File</h2>"
	echo "<h3>Contents of /etc/hosts file</h3>"
	echo "<pre><small>"
	echo "<xmp>"
	cat /etc/hosts | grep -v ^$
	echo "</xmp>"
	echo "</small></pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	echo "<div class='page-break' style='page-break-before: always;'></div>"
}

FstabFile() {
	echo "<h2 id='fstabfile' style='text-decoration:underline;'>/etc/fstab File</h2>"
	echo "<h3>Contents of /etc/fstab file</h3>"
	echo "<pre><small>"
	echo "<xmp>"
	cat /etc/fstab | grep -v ^$
	echo "</xmp>"
	echo "</small></pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	echo "<div class='page-break' style='page-break-before: always;'></div>"
}

DNSConf() {

	echo "<h2 id='ntp' style='text-decoration:underline;'>Network Time Protocol Config</h2>"
	if [ -f "/etc/ntp.conf" ]; then
		echo "File /etc/ntp.conf"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/ntp.conf | grep -v "^#" | grep -v ^$
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:15%;text-align:left;margin-left:0">'
	elif [ -f "/etc/chrony.conf" ]; then
		echo "File /etc/chrony.conf detected"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/chrony.conf | grep -v "^#" | grep -v ^$
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:15%;text-align:left;margin-left:0">'
	elif [ -f "/etc/systemd/timesyncd.conf" ]; then
		echo "File /etc/systemd/timesyncd.conf detected"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/systemd/timesyncd.conf | grep -v ^$
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

BannerFile() {
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
		for f in $FILES; do
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

Yumcron() {
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

ApacheServer() {
	echo "<h2 id='apachefile' style='text-decoration:underline;'>Apache Configuration files</h2>"

	if [ -d "/etc/apache2" ]; then
		# Apache 2 root directory
		echo "<h3>Contents of /etc/apache2 directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		for f in $(find /etc/apache2 -maxdepth 1 -type f ! -iname magic); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "<div class='page-break'></div>"

		# Apache 2 configuration available directory
		echo "<h3>Contents of /etc/apache2/conf-available directory</h3>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		for f in $(find /etc/apache2/conf-available -maxdepth 1 -type f ! -iname magic); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre><small>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
		for f in $(find /etc/apache2/sites-available -maxdepth 1 -type f ! -iname magic); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre><small>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat "$f" | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
			for f in $(find /etc/httpd/conf -maxdepth 1 -type f ! -iname magic); do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
			for f in $(find /etc/httpd/conf.d -maxdepth 1 -type f); do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre><small>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
			for f in $(find /etc/httpd/conf.modules.d -maxdepth 1 -type f); do
				echo "<h4>Contents of  ${f} ...</h4>"
				echo "<pre><small>"
				echo "<xmp>"
				# take action on each file. $f store current file name
				cat "$f" | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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

SambaServer() {
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
		for f in $(find /etc/samba -maxdepth 1 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
		cat /etc/nsswitch.conf | grep -v "^#" | grep -v ^$
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
}

MysqlServer() {
	echo "<h2 id='mysqlfile' style='text-decoration:underline;'>MySQL Server files</h2>"
	if [ -f "/etc/my.conf" ]; then
		echo "File /etc/my.conf"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/my.conf | grep -v "^# " | grep -v ^$ | grep -v "^#$"
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -f "/etc/my.cnf" ]; then
		echo "File /etc/my.cnf"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/my.cnf | grep -v "^# " | grep -v ^$ | grep -v "^#$"
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi

	if [ -d "/etc/my.conf.d" ]; then
		echo "<h3>/etc/my.conf.d directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		FILES="/etc/my.conf.d/*"
		for f in $FILES; do
			echo "Contents of $f ..."
			# take action on each file. $f store current file name
			cat "$f" | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -d "/etc/mysql" ]; then
		echo "<h3>/etc/mysql directory</h3>"

		for f in $(find /etc/mysql -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre><small>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat "${f}" | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
	echo "<div class='page-break' style='page-break-before: always;'></div>"
}

PostgresqlServer() {
	echo "<h2 id='postgresserverfiles' style='text-decoration:underline;'>Postgresql Server Files</h2>"
	echo "<span class='postgresicon'>Postgresql Server</span>"
	if [ -d "/etc/postgresql" ]; then
		echo "<h3>/etc/postgresql directory</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		for f in $(find /etc/postgresql -maxdepth 4 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
}

Firewall() {
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
		for f in $(find /etc/firewald/zones -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
		for f in $(find /etc/firewald/helpers -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
		for f in $(find /etc/firewald/icmptypes -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
		for f in $(find /etc/firewald/ipsets -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
		for f in $(find /etc/firewald/policies -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
		for f in $(find /etc/firewald/services -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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

NginxServer() {
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
		for f in $(find /etc/nginx/conf.d -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
}

Fapolicyd() {
	echo "<h3>Fapolicyd</h3>"
	echo "<pre><small>"
	echo "<xmp>"
	cat /etc/fapolicyd/fapolicyd.conf
	echo "</xmp>"
	echo "</small></pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

	if [ -f "/etc/fapolicyd/compiled.rules" ]; then
		echo "<h3>Fapolicyd Configuration: /etc/fapolicyd/compiled.rules</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/fapolicyd/compiled.rules
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
	if [ -f "/etc/fapolicyd/compiled.rules.prev" ]; then
		echo "<h3>Fapolicyd Configuration: /etc/fapolicyd/compiled.rules.prev</h3>"
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
		for f in $(find /etc/fapolicyd/rules.d -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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
		for f in $(find /etc/fapolicyd/trust.d -maxdepth 2 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
	fi
}

ServerFiles() {
	if (($apache > 0)); then
		ApacheServer
	fi

	if (($nginx > 0)); then
		echo "<span class='nginxicon'>Nginx WebServer</span>"
		NginxServer
	fi

	if (($oracle > 0)); then
		echo "<span class='oracleicon'>Oracle Database</span>"
	fi

	if (($mysql > 0)); then
		MysqlServer
	fi

	if (($postgresql > 0)); then
		PostgresqlServer
	fi

	if (($sap > 0)); then
		echo "<span class='sapicon'>SAP Application</span>"
	fi

	if (($java > 0)); then
		echo "<span class='javaicon'>Java Application</span>"
	fi

	if (($weblogic > 0)); then
		echo "<span class='weblogicicon'>Weblogic</span>"
	fi

	if (($dns > 0)); then
		echo "<h2 id='dnsserverfiles' style='text-decoration:underline;'>DNS / Bind Server Files</h2>"
		echo "<span class='dnsicon'>DNS Server</span>"
	fi

	if (($chrony > 0)); then
		echo "<h2 id='dnsserverfiles' style='text-decoration:underline;'>Chronyd Server Files</h2>"
		echo "<span class='chronyicon'>DNS Server</span>"
		echo "<h3>Content of /etc/chrony.conf</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/chrony.conf | grep -v "^#" | grep -v ^$
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		echo "<div class='page-break'></div>"
	fi

	if (($mail > 0)); then
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
			cat /etc/postfix/virtual | grep -v "^#" | grep -v ^$
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
	fi

	if (($samba > 0)); then
		SambaServer
	fi

	if (($nis > 0)); then
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
			cat /etc/ypserv.conf | grep -v "^#" | grep -v ^$
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -f "/etc/yp.conf" ]; then
			echo "<h3>Contents of /etc/ypconf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/yp.conf | grep -v "^#" | grep -v ^$
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -f "/etc/nsswitch.conf" ]; then
			echo "<h3>Contents of /etc/nssswitch.conf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/nsswitch.conf | grep -v "^#" | grep -v ^$
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -f "/etc/pamd.d/common-session" ]; then
			echo "<h3>Contents of /etc/pamd.d/common-session</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/pamd.d/common-session | grep -v "^#" | grep -v ^$
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi

	fi

	if (($nfs > 0)); then
		echo "<h2 id='NFSserverfiles' style='text-decoration:underline;'>NFS Server Files</h2>"
		if [ -f "/etc/exports" ]; then
			echo "<h3>Contents of /etc/exports</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/exports | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
	fi

	if (($snmp > 0)); then
		echo "<h2 id='SNMPserverfiles' style='text-decoration:underline;'>SNMP Files</h2>"
		echo "<h3> Contents of /etc/snmp directory</he>"
		for f in $(find /etc/snmp -maxdepth 1 -type f); do
			echo "<h4>Contents of  ${f} ...</h4>"
			echo "<pre>"
			echo "<xmp>"
			# take action on each file. $f store current file name
			cat $f | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		done
		echo "<div class='page-break'></div>"
	fi

	if (($dhcp > 0)); then
		echo "<h2 id='DHCPserverfiles' style='text-decoration:underline;'>DHCP Server Files</h2>"
		echo "<h3> Contents of /etc/dhcp/dhcpd.conf</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/dhcp/dhcpd.conf | grep -v "^# " | grep -v ^$ | grep -v "^#$"
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		echo "<div class='page-break'></div>"
	fi

	if (($ftp > 0)); then
		echo "<h2 id='ftpserverfiles' style='text-decoration:underline;'>VS FTP Server Files</h2>"
		if [ -f "/etc/vsftpd.conf" ]; then
			echo "<h3>Contents of /etc/vsftpd.conf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/vsftpd.conf | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -f "/etc/vsftpd/vsftpd.conf" ]; then
			echo "<h3>Contents of /etc/vsftpd/vsftpd.conf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/vsftpd/vsftpd.conf | grep -v "^# " | grep -v ^$ | grep -v "^#$"
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

	if (($haproxy > 0)); then
		echo "<h2 id='haproxyserverfiles' style='text-decoration:underline;'>HA Proxy Server Files</h2>"
		echo "<h3> Contents of /etc/haproxy/haproxy.cfg</h3>"
		echo "<pre><small>"
		echo "<xmp>"
		cat /etc/haproxy/haproxy.cfg
		echo "</xmp>"
		echo "</small></pre>"
		echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		echo "<div class='page-break'></div>"
	fi

	if (($vrrp > 0)); then
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

	if (($count_mount > 0)); then
		echo "<h2 id='nisclientfiles' style='text-decoration:underline;'>NIS Client Files</h2>"
		if [ -f "/etc/yp.conf" ]; then
			echo "<h3>Contents of /etc/ypconf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/yp.conf | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -f "/etc/nsswitch.conf" ]; then
			echo "<h3>Contents of /etc/nssswitch.conf</h3>"
			echo "<pre><small>"
			echo "<xmp>"
			cat /etc/nsswitch.conf | grep -v "^# " | grep -v ^$ | grep -v "^#$"
			echo "</xmp>"
			echo "</small></pre>"
			echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'
		fi
		if [ -d "/etc/systemd/system/systemd-logind.service.d" ]; then
			echo "<h3>Contents of /etc/systemd/system/systemd-logind.service.d directory</h3>"

			FILES="/etc/systemd/system/systemd-logind.service.d/*"
			for f in $FILES; do
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

ServicesAutoStart() {
	echo "<h2 id='services' style='text-decoration:underline;'>Autostart Services</h2>"
	echo "The server autostart services are."
	echo "<pre>"

	if hash systemctl 2>/dev/null; then
		echo "<!-- systemctl1 -->"
		systemctl list-unit-files | grep enabled
		echo "<!-- systemctl2 -->"
	elif hash chkconfig 2>/dev/null; then
		echo "<!-- chkconfig1 -->"
		chkconfig --list | grep "3:on\|5:on"
		echo "<!-- chkconfig2 -->"
	else
		echo "Runlevel 2"
		ls -l /etc/rc2.d/S* | awk '{print $NF}' | sort -u
		echo "Runlevel 3"
		ls -l /etc/rc3.d/S* | awk '{print $NF}' | sort -u

		ls -l /sbin/rc3.d/S* | awk '{print $NF}' | sort -u

		echo "Runlevel 5"
		ls -l /etc/rc5.d/S* | awk '{print $NF}' | sort -u
	fi
	echo "</pre>"
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray">'
}

ListCrontabs() {
	echo "<h2 id='listcrontabs' style='text-decoration:underline;'>All Available Crontabs</h2>"
	echo "<pre><small>"
	for f in $(find /var/spool/cron -maxdepth 2 -type f); do
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

ListAllFiles() {
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
		rpm -qa --last | head -25
	else
		echo "Unknown Package Manager - Aborting package list"
	fi
	echo "</small></pre>"
	echo "<div class='page-break'> </div>"
}

HeaderPage() {
	echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta charset="UTF-8" />
    <title>'"$(hostname)"'</title>
    <meta name="author" content="Raymond Val" />
  </head>
  <body>'
}

FooterPage() {
	echo "  </body>
</html>"
}

CoverPage() {
	echo "
<h1 style='text-align:center;'>Linux System Documentation</h1>
<h2 style='text-align:center;'>System: $(hostname)</h2>
<p style='color:red;text-align:center;font-family:Times New Roman;font-size:14'><em>The information in this document is considered sensitive information and not to be shared without the explicit permission of Strategic Digital Infrastructure.</em></p>
<p style='text-align:center'><em>This document was prepared by:</em></p>
<pre style='text-align:center;font-family:Arial'><strong>$PreparerName</strong>
Linux System Administrator<br />
University of the South
735 University Avenue
Sewanee TN 37383
Phone: $PreparerPhone
Email: $PreparerEmail<br />
Prepared: $DATE
Last Updated: [Date]
</pre>
<div style='page-break-before:always;'></div>
<p>&nbsp;</p>
<hr />
<div class='page-break'></div>"
}

DisclaimerPage() {
	echo "
<div style='page-break-before:always;'></div>
<h1 style='text-align:center;'>Disclaimer</h1>
<h2 style='text-align:center;'>This document is for authorized use by the intended recipient(s) only. It may contain proprietary material, confidential information and, or be subject to legal privilege. It should not be copied, disclosed to, retained, or used by any other party.</h2>
<p>&nbsp;</p>
<hr />
<div class='page-break'></div>
"

}

DocumentManagementPage() {
	echo "
<div style='page-break-before:always;'></div>
<h1>Document Management</h1>
<p>&nbsp;</p>
<h3>Contributors</h3>

Please provide details of all contributors to this document

<p>&nbsp;</p>
<h3>Version Control</h3>

Please document all changes made to this document since initial distribution.
<p>&nbsp;</p>
<hr />
<div class='page-break'></div>
"
}

AboutPage() {
	echo "
<div style='page-break-before:always;'></div>
<h1>About</h1>
<p>&nbsp;</p>
<h3>Overview</h3>

«overview»

<h3>Service Description </h3>

SERVICE1:  <<Service Description>>
<p>&nbsp;</p>
SERVICE2:  <<Service Description>>
<p>&nbsp;</p>
<hr />
<div class='page-break'></div>
"
}

FunctionalPage() {
	echo "
	<div style='page-break-before:always;'></div>
	<h1>Functional</h1>
	<p>&nbsp;</p>
	<h3>Users</h3>
	<p>&nbsp;</p>
	<h3>Contact List</h3>
	<p>&nbsp;</p>
	<h4>Current Administration Team</h4>
	<p>&nbsp;</p>
	<h4>End User Contacts</h4>
	<p>&nbsp;</p>

<p>&nbsp;</p>
<hr />
<div class='page-break'></div>
"
}

OperationalPage() {
	echo "Operational Page"
	# Remote access
	# Network infrastructure
	# Server infrastructure
	# Logging
	# Monitoring
	# SSL Certificates
	# Backup
	# Licenses
}

SecurityPage() {
	echo "Security Page"
	# SELinux
	# OpenSCAP
	# AIDE
	# Logwatch
	# Fail2ban
	# Firewalld
	# Fapolicyd
	# ClamAV
	# FIPS Setting
	# SSSD
}

unamestr=$(uname)

case "$unamestr" in
Linux*)
	HeaderPage
	CoverPage $input
	TableOfContent $input
	DisclaimerPage
	DocumentManagementPage
	AboutPage
	FunctionalPage
	TechnicalPage
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
	OperationalPage
	# Remote access
	# Network infrastructure
	# Server infrastructure
	# Logging
	# Monitoring
	# SSL Certificates
	# Backup
	# Licenses
	SecurityPage
	ConfigurationPage
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
