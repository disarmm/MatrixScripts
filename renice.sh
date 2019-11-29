#!/bin/bash

for c in $(docker ps | grep nodeConfig | awk {'print $1'}) ; do
	miningStatus=$(docker exec ${c} /bin/bash -c "/matrix/gman attach /matrix/chaindata/gman.ipc -exec man.mining")
	entrypointPID=$(docker inspect --format '{{.State.Pid}}' ${c})
	gmanPID=$(pstree -p ${entrypointPID} | cut -d "(" -f 3 | cut -d ")" -f 1)
	echo ${gmanPID}
	if [ miningStatus == "true" ] ; then
		renice -n -20 -p ${gmanPID}
	else
		renice -n 0 -p ${gmanPID}
	fi
done
