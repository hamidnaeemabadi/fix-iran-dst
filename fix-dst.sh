#!/bin/bash
# AUTHOR: Hamid Naeemabadi
# Version: 1.2 2023/03/06
# This script will update the tzdate package to fix the IRAN DST changes.
# Run this script with below command:
# wget https://raw.githubusercontent.com/hamidnaeemabadi/fix-iran-dst/main/fix-dst.sh && chmod u+x fix-dst.sh && ./fix-dst.sh
#========================================================#
# Message colors
ENDCOLOR="\e[0m"
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
#========================================================#
# Checking the new Time zone configuration
check_new_tz_configuration () {
    echo -e "$Green Checking the new Time zone configuration ...$ENDCOLOR"
    NEW_TZ_CONF=$(zdump -v Asia/Tehran | grep '202[2-9]' | wc -l)
    if [ "$NEW_TZ_CONF" -eq 4 ]; then
        # Print current Time Zone Config
        echo -e "$Green The new Asia/tehran Time Zone has been applied successfully, The latest DST setting in Tehran Time Zone has been in 2022:$ENDCOLOR"
        echo ""
        zdump -v Asia/Tehran | grep '202[2-9]'
        echo ""
        echo "Time zone configuration"
        timedatectl
    else
        echo -e "$Red The new time zone config appliment is failed with error code $? $ENDCOLOR"
        manually_timezone_compile
    fi
}
#========================================================#
# Manual timezone compile and config function
manually_timezone_compile () {
    echo -e "$Green Trying to download the Time Zone DB from IANA and compile it manually:$ENDCOLOR"
    sudo mkdir -p /usr/share/tz && cd /usr/share/tz
    wget https://data.iana.org/time-zones/releases/tzdata2022b.tar.gz > /dev/null 2>&1
    sudo tar -xvf tzdata2022b.tar.gz > /dev/null 2>&1 && sudo rm -f tzdata2022b.tar.gz
    zic asia
    zic -l Asia/Tehran
    if [ $? -eq 0 ];then
        echo -e "$Green The tzdate(2022g) has been upgraded successfully. $ENDCOLOR"
        echo ""
        check_new_tz_configuration
    else
        echo -e "$Red The tzdate packge upgrade failed with error code $? $ENDCOLOR"
        echo ""
    fi
}
#========================================================#
YUM_PACKAGE_NAME="tzdata"
DEB_PACKAGE_NAME="tzdata"

echo -e "$Green Update the TZ data package to the latest version ...$ENDCOLOR"
echo ""
# Redhat Based OS
if [ -f /etc/redhat-release ]; then
    sudo yum makecache
    sudo yum install -y $YUM_PACKAGE_NAME
    rpm -qa | grep tzdata | grep 2022g > /dev/null 2>&1
    if [ $? -eq 0 ];then
        echo -e "$Green The latest version of tzdate(2022g) has been installed successfully. $ENDCOLOR"
        echo ""
        check_new_tz_configuration
    else
        echo -e "$Red The tzdate packge upgrade failed with error code $? $ENDCOLOR"
        echo ""
        manually_timezone_compile
    fi
fi

# Debian Based OS
if [ -f /etc/lsb-release ]; then
    sudo apt-get update
    sudo apt-get install -y $DEB_PACKAGE_NAME
    apt list --installed | grep tzdata | grep 2022g > /dev/null 2>&1
    if [ $? -eq 0 ];then
        echo -e "$Green The latest version of tzdate(2022g) has been installed successfully. $ENDCOLOR"
        echo ""
        check_new_tz_configuration
    else
        echo -e "$Red The tzdate packge upgrade failed with error code $? $ENDCOLOR"
        echo ""
        manually_timezone_compile
    fi
fi
#========================================================#


