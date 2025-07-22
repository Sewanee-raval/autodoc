#!/usr/bin/env bash
#----------------------------------------------------------------------
# Filename: php_upload.sh
# Written : 14-July-2025 (Raymond Val)
# Purpose :
# Usage   : ./php_upload.sh
#         :
# Input   : N/A
#         :
# Output  : N/A
#         :
# Notes   :
#         :
# Updated :
#         :
#----------------------------------------------------------------------

# Set Global Variables for php
sestatus=1
oscapstatus=1
aidestatus=1
logwatchstatus=1
fail2banstatus
firewallstatus=1
fapolicydstatus=0
ClamAVDB=""
fipsstatus=1
SSSDDB=""

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
		firewallstatus=$?
	else
		firewallstatus=1
	fi

	if (($firewallstatus > 0)); then
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
		fail2banstatus=$?
	else
		fail2banstatus=1
	fi

	if (($fail2banstatus > 0)); then
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
	if hash clamscan 2>/dev/null; then
		clamscan status >/dev/null 2>&1
		clamavstatus=$?
	else
		clamavstatus=1
	fi

	if (($clamavstatus > 0)); then
		echo "<span class='clamavicon'>ClamAV is not installed or not enabled</span>"
	else
		echo "<span class='clamavicon'>ClamAV is installed and enabled</span>"
	fi
	echo '<hr style="height:2px;border-width:0;color:gray;background-color:gray;width:25%;text-align:left;margin-left:0">'

	#		fail2ban=$(echo "$psoutput" | egrep -i fail2ban | wc -l)
	# if (($fail2ban > 0)); then
	# 	echo "<span class='fail2banicon'>Fail2ban is Active</span>"
	# else
	# 	echo "<span class='fail2banicon'>Fail2ban is Not Active</span>"
	# fi
}
