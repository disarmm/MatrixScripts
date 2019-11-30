#!/bin/bash

# this script will help you check stats from your nodes in bulk

lb(){
        printf "\n"
}

function mining(){
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
lb
echo "This is a list of your containers"
docker ps | grep nodeConfig
lb
echo "This is your current block height list. Reference the order in the above list to find your peer count"
for s in $(docker ps | grep nodeConfig | awk {'print $1'}) ; do
        docker exec -i $s /bin/bash -c "/matrix/gman attach /matrix/chaindata/gman.ipc -exec man.blockNumber"
done
}

checkNodeMenu=$(
whiptail --title "Matrix AI Network Installer" --menu "How do you like your MAN?" 20 90 8 \
        '1)' "Mining - Check if nodes are mining" \
        '2)' "Syncing - Check the syncing progress/status of your nodes" \
	'3)' "Peer Count - Check the number of peers each container has" \
	'4)' "Block Number - Check the current block number for all containers" \
        '5)' "exit" 3>&2 2>&1 1>&3
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
                exit
                ;;
esac

