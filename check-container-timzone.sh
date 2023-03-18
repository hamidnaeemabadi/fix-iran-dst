#!/bin/bash
# AUTHOR: Hamid Naeemabadi, Domil Co. - Infrastructure Team
# Version: 1.0 2023/03/14
#========================================================#
# check container time and timezone
echo "###########################################################"
if [[ $(which docker) ]]; then
    if [ $? -eq 0 ];then
        for container in $(docker ps --format "{{.Names}}")
        do
            # echo "Current time and number of Time Zone rows:"
            docker exec $container /bin/sh -c "date | grep +0330" > /dev/null 2>&1
            if [ $? -eq 0 ];then
                echo "----------------------------------"
                echo -e "Host Info: $(hostname) - $(hostname -I | awk '{print $1}')"
                echo $container
                docker exec $container /bin/sh -c "date && zdump -v Asia/Tehran | grep '202[2-9]' | wc -l"
                echo "----------------------------------"
            fi
        done
    else
        echo -e "No container is running on this host: $(hostanme && echo " " && hostname -I)"
    fi
fi
echo "###########################################################"
