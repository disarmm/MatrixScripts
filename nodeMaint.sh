#!/bin/bash

# this script will help you check stats from your nodes in bulk

lb(){
        printf "\n"
}
checkDocker(){
	if [ -x "$(command -v docker)" ]; then
		:
	else
		echo "Docker does not exist on this system. This script is for docker setups only."
		exit 1
	fi
}
runningCheck(){
	if [ $(docker ps | sed -n '1!p' | wc -l) -eq 0 ]; then
		echo "ERROR: No containers currently running"
		exit 1
	fi
}

function mining(){
runningCheck
lb
echo "This is a list of your containers"
docker ps | grep nodeConfig
lb
echo "This is your status list. Reference the order in the above list to find the status"
for m in $(docker ps | grep nodeConfig | awk {'print $1'}) ; do
        docker exec -i $m /bin/bash -c "/matrix/gman attach /matrix/chaindata/gman.ipc -exec man.mining"
done
}

function syncing(){
runningCheck
lb
echo "This is a list of your containers"
docker ps | grep nodeConfig
lb
echo "This is your status list. Reference the order in the above list to find the status"
for s in $(docker ps | grep nodeConfig | awk {'print $1'}) ; do
        docker exec -i $s /bin/bash -c "/matrix/gman attach /matrix/chaindata/gman.ipc -exec man.syncing"
done
}

function peers(){
runningCheck
lb
echo "This is a list of your containers"
docker ps | grep nodeConfig
lb
echo "This is your peer list. Reference the order in the above list to find your peer count"
for s in $(docker ps | grep nodeConfig | awk {'print $1'}) ; do
        docker exec -i $s /bin/bash -c "/matrix/gman attach /matrix/chaindata/gman.ipc -exec net.peerCount"
done
}

function blockNumber(){
runningCheck
lb
echo "This is a list of your containers"
docker ps | grep nodeConfig
lb
echo "This is your current block height list. Reference the order in the above list to find your peer count"
for s in $(docker ps | grep nodeConfig | awk {'print $1'}) ; do
        docker exec -i $s /bin/bash -c "/matrix/gman attach /matrix/chaindata/gman.ipc -exec man.blockNumber"
done
}

function shortenLogs(){
runningCheck
i=0
W=()
while read -r line; do
    let i=$i+1
    W+=($i "$line")
done < <( docker ps --format '{{.Names}}' )
whiptail --title "Log Reducing" --msgbox "This will clear your logs down to the most recent 25 lines" 8 70
contChoice=$(whiptail --title "Log Reducing" --menu "Which container logs would you like to shorten?" 32 70 15 "${W[@]}" 3>&1 1>&2 2>&3)
exitStatus=$?
if [ ${exitStatus} -eq 0 ]; then
        contName=$( docker ps --format '{{.Names}}' | sed -n "${contChoice}"p)
	contLog=$(docker inspect -f '{{.LogPath}}' ${contName} 2> /dev/null)
	echo "$(tail -n 50 $contLog)" > $contLog

	if [ $? -eq 0 ]; then
        	echo "Container logs for ${contName} have been shortened."
	fi
fi
}
obtainLogs(){
i=0
W=()
while read -r line; do
    let i=$i+1
    W+=($i "$line")
done < <( docker ps -a --format '{{.Names}}' )
ITYPE=$(whiptail --title "Collecting Logs..." --menu "From which container would you like to retrieve logs?" 22 80 12 "${W[@]}" 3>&1 1>&2 2>&3)
mkdir -p /tmp/MatrixLog
exitStatus=$?
if [ ${exitStatus} = 0 ]; then
        logChoice=$(docker ps -a --format '{{.Names}}' | sed -n "`echo "$ITYPE p" | sed 's/ //'`")
	for logs in $(docker exec -i ${logChoice} bash -c "ls -tr /matrix/MatrixLog/ | tail --lines=5") ; do
		docker cp $logChoice:/matrix/MatrixLog/$logs /tmp/MatrixLog
	done
fi
lb
echo "Your logs have been copied to the /tmp/MatrixLog directory"
}
checkDocker
runningCheck
checkNodeMenu=$(
whiptail --title "Matrix AI Network Docker Maintenance" --menu "Please select an option:" 20 90 8 \
        '1)' "Mining - Check if nodes are mining" \
        '2)' "Syncing - Check the syncing progress/status of your nodes" \
	'3)' "Peer Count - Check the number of peers each container has" \
	'4)' "Block Number - Check the current block number for all containers" \
	'5)' "Shorten Logs - This will reduce the size of your docker logs to 25 lines" \
	'6)' "Obtain Logs - This option will gather the last 5 log entries for troubleshooting" \
        'X)' "exit" 3>&2 2>&1 1>&3
)

case $checkNodeMenu in
        "1)")
                mining
                ;;
        "2)")
                syncing
                ;;
	"3)")
		peers
		;;
	"4)")
                blockNumber
                ;;
	"5)")
		shortenLogs
		;;
	"6)")
                obtainLogs
                ;;
        "X)")
                exit
                ;;
esac

