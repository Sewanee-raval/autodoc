#!/bin/bash
date

INPUTFILE="servers.txt"
OUTPUTDIR="output"

if [ ! -d "$OUTPUTDIR" ]; then
   mkdir output
fi

multihost () {
  INPUTFILE=$1
  while IFS=","  read -r -u3 ip uname pword site ; do
          echo "Copying script to remote host $site"
          timeout 60 /usr/bin/time -f "%e %C" sshpass -p$pword scp -o  UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no autodoc.sh $uname@$ip:/tmp 2>>/tmp/time.ssh.txt

          echo "running script on remote host $site"
          timeout 60 sshpass -p$pword ssh -n -o StrictHostKeyChecking=no $uname@$ip "echo '$pword' | sudo -S  bash /tmp/autodoc.sh" > $OUTPUTDIR/$site.html
      echo ""
    echo "$site completed"
      echo ""

  done 3< "$INPUTFILE"
  date
  unset IFS
}


# Reading arguments with getopts options
while getopts 'if:s:h:u:p:' OPTION; do
    case "$OPTION" in
        f)
            INPUTFILE=${OPTARG}
            echo "The input file $INPUTFILE"
            multihost "$INPUTFILE";;
        s)
            ip=${OPTARG}
            echo "The ip address is $ip" ;;
        u)
            uname=${OPTARG}
            echo "The username is $uname" ;;
        p)
            pword=${OPTARG}
            echo "The password is $pword" ;;
        h)
            host=${OPTARG}
            echo "The host name is $host" ;;
        i)
            interactive=1;;
        *)
            # Print helping message for providing wrong options
            echo "Usage: $0 [-i] [-f value] or [-s value] [-u value] [-p value] [-h value]" >&2
            # Terminate from the script
            exit 1 ;;
    esac
done

if [ "$interactive" = "1" ]; then

    response=

    read -p "Enter name of input file [$INPUTFILE] > " response
    if [ -n "$response" ]; then
        INPUTFILE="$response"
        multihost(INPUTFILE)
    fi

    if [ -f != $filename ]; then
        echo -n "Input file does not exist"
        echo "Exiting program."
        exit 1
    fi
fi