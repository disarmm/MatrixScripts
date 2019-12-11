#!/bin/bash

# this has turned into a little more than renice. I noticed that nodes perform worse if left running for several days, so i've added some lines to restart the nodes after each time they are elected

# create for loop to check all containers that exist on the computer
for c in $(docker ps | grep nodeConfig | awk {'print $1'}) ; do
	# check the mining status of the container
	miningStatus=$(docker exec ${c} /bin/bash -c "/matrix/gman attach /matrix/chaindata/gman.ipc -exec man.mining")
	# now get the PID of the script that starts gman in the container
	entrypointPID=$(docker inspect --format '{{.State.Pid}}' ${c})
	# then we need to get the host PID based on the entrypoint PID
	gmanPID=$(pstree -p ${entrypointPID} | cut -d "(" -f 3 | cut -d ")" -f 1)
	# funciton for cleaning up the mining tag
	cleanUp(){
	docker exec ${c} /bin/bash -c "rm /matrix/chaindata/miningTrue"
	}
	# hope this is obvious
	restartContainer(){
	docker restart ${c} &>/dev/null
	}
	# now we run the if then statement to change the CPU priority using the host PID of the gman process running inside each container
	if [ ${miningStatus} == "true" ] ; then
		renice -n -20 -p ${gmanPID} &>/dev/null && docker exec ${c} /bin/bash -c "touch /matrix/chaindata/miningTrue" # i made it silent so it doesn't ouput anything
	else
		renice -n 0 -p ${gmanPID} &>/dev/null
	fi
	# restart containers after they finished a round of mining
	if [ "$(docker exec ${c} /bin/bash -c "if [ -f /matrix/chaindata/miningTrue ]; then echo "True"; fi")" == "True" ] && [ ${miningStatus} == "false" ]; then
		cleanUp && restartContainer
	fi
done

# if you want to see the changing renice values you can run "ps -eo pid,ppid,ni,comm | grep gman" from the host
# just for the record -20 is the highest priority while 20 is the lowest priority. Yes this sounds backwards, but you can google it if you dont believe me
