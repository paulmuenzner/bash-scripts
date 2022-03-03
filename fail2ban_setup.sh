#!/usr/bin/bash

## Title................: fail2ban_setup.sh
## Description..........: Installation and basic setup of intrusion prevention software framework
##                        fail2ban to protect the server from brute-force attacks.
## Version..............: 1.0
## Author...............: Paul Münzner
## License..............: MIT LICENSE
## Testing Conditions ...
## ... Bash Version.....: 5.0 or later
## ... Ubuntu Version...: Ubuntu 20.04.4 LTS

echo ""
echo ""
echo "###########################################"
echo "#             ###############             #"
echo "#              START PROCESS              #"
echo "#                #########                #"
echo "###########################################"
echo ""
echo ""
##
##
######### Start Defining Scrip Functions #########
number_test() {
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Sorry, use plain numbers only for $2."
        echo "Setup stopped!"
        exit 1
    fi
}
######### End Defining Script Functions ##########
##
# Declare sleep duration for better user experience
declare sleep=3
##
echo "System updating now. Just some seconds..."
apt update && apt upgrade -y
echo "Update finished."
echo ""
echo ""
echo "#####################################"
echo "#           Fail2Ban Check          #"
echo "#####################################"
echo ""
echo ""
echo "Checking if fail2ban installed on system..."
sleep $sleep
REQUIRED_PKG="fail2ban"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")
if [ "" = "$PKG_OK" ]; then
    echo "No $REQUIRED_PKG installed on your system."
    declare f2bInstalled=false
else
    echo "$REQUIRED_PKG already installed on your system."
    declare f2bInstalled=true
fi
##
##
if [ $f2bInstalled == false ]; then
    echo ""
    echo ""
    echo "#####################################"
    echo "#       Installation Fail2Ban       #"
    echo "#####################################"
    echo ""
    echo ""
    echo "You agree to install fail2ban?"
    select yn in "Yes" "No"; do
        case $yn in
        Yes)
            echo "Installation will be started now! Once the installation is completed, fail2ban will be configured in a next step."
            apt-get --yes install $REQUIRED_PKG
            break
            ;;
        No)
            echo "We cannot continue without installing fail2ban on your system!"
            exit 1
            ;;
        esac
    done
fi

echo ""
echo ""
echo "#####################################"
echo "#          Config Fail2Ban          #"
echo "#####################################"
echo ""
echo ""
echo " Creating jail.local file if not existing to override respective fail2ban settings of jail.config. "
echo " The jail.local file doesn't need to include everything in the corresponding .conf file, only those settings which are requested to override. This also avoids merging problem when upgrading."
echo " For more information check http://www.fail2ban.org/wiki/index.php/MANUAL_0_8 "
##
read -p "Press enter to continue"
##

FILE=/etc/fail2ban/jail.local
if test -f "$FILE"; then
    declare jaillocal=true
    echo "Jail.local already existing. File provided at: $FILE"
else
    declare jaillocal=false
    touch $FILE
    echo "Jail.local not found. It will be created now."
    if test -f "$FILE"; then
        echo "Jail.local created at: $FILE"
    else
        echo "Jail.local creation failed. Process stopped!"
        exit 1
    fi
fi
echo ""
echo ""
read -p "Press enter to continue and add fail2ban rules to jail.local file now."
echo "Do you know the exact port you like to protect? Press 1 for \"Yes\" or 2 for \"No\"."
select yn in "Yes" "No"; do
    case $yn in
    Yes)
        echo "Great, let's start!"
        break
        ;;
    No)
        echo "You must know the port to protect it with fail2ban. Please check your file /etc/ssh/sshd_config!"
        exit 1
        ;;
    esac
done
echo ""
echo ""

echo "Enter your port number:"
read port
## Check if plain number entered by user
number_test $port "the Port"
##
echo "Enter the number of failures before an IP is banned:"
read maxretry
number_test $maxretry "the number of failures before an IP is banned"
##
echo "Enter the bantime in hours:"
read bantime
number_test $bantime "the bantime"
echo "Set the window that fail2ban will pay attention to when looking for repeated failed authentication attempts in minutes (Default 10m):"
read findtime
number_test $findtime "the window that fail2ban will pay attention to when looking for repeated failed authentication attempts"
##
## Adding new setup definitions
## Writing to jail.local if new installation
if [ $jaillocal == false ]; then
    {
        echo "[sshd]"
        echo "enabled = true"
        echo "port = SSH"
        echo "filter = sshd"
        echo "logpath = /var/log/auth.log"
        echo "maxretry = $maxretry"
        echo "bantime = ${bantime}h"
        echo "findtime = ${findtime}m"
    } >>$FILE
fi
##
## Writing to jail.local if fail2ban already installed and jail.local existing
if [ $jaillocal == true ]; then
    # Deleting existing setup definitions
    sed -i '/^maxretry\|^bantime\|^findtime\|^port/d' $FILE
    # Adding new setup definitions
    {
        echo "port = $port"
        echo "maxretry = $maxretry"
        echo "bantime = ${bantime}h"
        echo "findtime = ${findtime}m"
    } >>$FILE
fi
echo "Restarting fail2ban..."
service fail2ban restart
echo ""
echo ""
echo "Configuration of fail2ban finished and active. Your port $port will be locked after $maxretry trials within $findtime minutes for $bantime hours"
echo ""
echo ""
echo "###########################################"
echo "#                #########                #"
echo "#               END PROCESS               #"
echo "#             ###############             #"
echo "###########################################"
echo ""
echo ""
exit 0
