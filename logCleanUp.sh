#!/bin/bash
for contList in $(docker ps -aq) ; do
        docker exec -i $contList bash -c "/matrix/logCleanup"
done
