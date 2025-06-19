#!/bin/bash
date

INPUTFILE="servers.txt"
OUTPUTDIR="output"

# Accept an arg of a filename or else use servers.txt as the filename

while [ "$1" != "" ]; do
    case $1 in
    -f | --file)
        shift
        INPUTFILE="$1"
        ;;
    -i | --interactive)
        interactive=1
        ;;
    -s | --system)
        shift
        INPUTFILE="$1"
        ;;
    -h | --help)
        usage
        exit
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift
done

if [ "$interactive" = "1" ]; then

    response=

    read -p "Enter name of input file [$INPUTFILE] > " response
    if [ -n "$response" ]; then
        INPUTFILE="$response"
    fi

    if [ -f != ${filename} ]; then
        echo -n "Input file does not exist"
        echo "Exiting program."
        exit 1
    fi
fi

if [ ! -d "$OUTPUTDIR" ]; then
    mkdir output
fi

while IFS="," read -r -u3 ip uname pword site; do
    echo "Copying script to remote host $site"
    timeout 60 /usr/bin/time -f "%e %C" sshpass -p$pword scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no autodoc.sh $uname@$ip:/tmp 2>>/tmp/time.ssh.txt

    echo "running script on remote host $site"
    timeout 60 sshpass -p$pword ssh -n -o StrictHostKeyChecking=no $uname@$ip "echo '$pword' | sudo -S  bash /tmp/autodoc.sh" >$OUTPUTDIR/$site.html
    echo ""
    echo "$site completed"
    echo ""

done 3<"$INPUTFILE"
date
unset IFS
