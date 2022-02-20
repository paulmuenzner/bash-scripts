#!/usr/bin/bash

## Title................: manage_ping_response.sh
## Description..........: Enabling or disabling ping responses upon user decision for IPv4 and IPv6.
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
# Declare sleep duration for better user experience
declare sleep=3
echo ""
echo ""
echo "###########################################"
echo "#        Request User Requirement         #"
echo "###########################################"
echo ""
echo ""
echo "Do you want to disable or enable ping responses on your server? Enter 1 to enable or 2 to block."
select yn in "Enable" "Disable" "Don't know!"; do
    case $yn in
    Enable)
        echo "Enable ping responses."
        declare ping=true
        break
        ;;
    Disable)
        echo "Disable ping responses."
        declare ping=false
        break
        ;;
    "Don't know!")
        echo "You cannot continue without deciding what you like to setup! Process will be stopped now."
        exit 1
        ;;
    esac
done
echo ""
echo ""
echo "###########################################"
echo "# Check if IPv6 is enabled on your system #"
echo "###########################################"
echo ""
echo ""
if (test -f /proc/net/if_inet6); then
    echo "IPv6 is supported."
    declare ipv6=true
else
    echo "IPv6 obviously not supported. Only ping setup for IPv4 will be managed."
    declare ipv6=false
fi
echo ""
echo ""
echo "###########################################"
echo "#             Manage Ping Setup           #"
echo "###########################################"
echo ""
echo ""
## Define file where setup is needed
declare file=/etc/sysctl.conf
## Delete all existing ping settings
sed -i '/^net.ipv4.icmp.echo_ignore_all\|^net.ipv6.icmp.echo_ignore_all/d' $file
##
## If user wants to disable pings
##
if [ $ping == false ]; then
    echo "Disabling ping responses for IPv4 ..."
    sleep $sleep
    echo "net.ipv4.icmp_echo_ignore_all = 1" >>$file
    echo "Testing ..."
    declare regexipv4="\s+net.ipv4.icmp_echo_ignore_all = 1\s+"
    declare file_content=$(cat "${file}")
    if [[ " $file_content " =~ $regexipv4 ]]; then
        declare ipv4=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
        echo "Succeeded! Ping responses for your IPv4 address $ipv4 disabled!"
        echo "Verify your IPv4 address $ipv4 with an external ping tool https://dnschecker.org/ping-ipv4.php."
    else
        echo "Process stopped. It was not possible to setup IPv6 in the relevant file $file"
        exit 1
    fi
fi
##
## If user wants to enable pings
##
if [ $ping == true ]; then
    echo "Enabling ping responses for IPv4 ..."
    sleep $sleep
    echo "net.ipv4.icmp_echo_ignore_all = 0" >>$file
    echo "Testing ..."
    declare regexipv4="\s+net.ipv4.icmp_echo_ignore_all = 0\s+"
    declare file_content=$(cat "${file}")
    if [[ " $file_content " =~ $regexipv4 ]]; then
        declare ipv4=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
        echo "Succeeded! Ping responses for your IPv4 address $ipv4 enabled!"
        echo "Verify your IPv4 address $ipv4 with an external ping tool https://dnschecker.org/ping-ipv4.php"
    else
        echo "Process stopped. It was not possible to setup IPv4 in the relevant file $file"
        exit 1
    fi
fi
echo ""
echo ""
if [ $ipv6 == true ]; then
    if [ $ping == true ]; then
        echo "Enabling ping responses for IPv6 ..."
        sleep $sleep
        echo "net.ipv6.icmp.echo_ignore_all = 0" >>$file
        echo "Testing ..."
        declare regexipv6="\s+net.ipv6.icmp.echo_ignore_all = 0\s+"
        declare file_content=$(cat "${file}")
        if [[ " $file_content " =~ $regexipv6 ]]; then
            declare ipv6=$(ip -6 addr | awk '{print $2}' | grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64' | cut -d '/' -f1)
            echo "Succeeded! Ping responses for your IPv6 address $ipv6 enabled!"
            echo "Verify your IPv6 address $ipv6 with an external ping tool https://dnschecker.org/ping-ipv4.php."
        else
            echo "Process stopped. It was not possible to setup IPv6 in the relevant file $file"
            exit 1
        fi
    fi
    ##
    ## Disabling pings for IPv6
    ##
    if [ $ping == false ]; then
        echo "Disabling ping responses for IPv6 ..."
        sleep $sleep
        echo "net.ipv6.icmp.echo_ignore_all = 1" >>$file
        echo "Testing ..."
        declare regexipv6="\s+net.ipv6.icmp.echo_ignore_all = 1\s+"
        declare file_content=$(cat "${file}")
        if [[ " $file_content " =~ $regexipv6 ]]; then
            declare ipv6=$(ip -6 addr | awk '{print $2}' | grep -P '^(?!fe80)[[:alnum:]]{4}:.*/64' | cut -d '/' -f1)
            echo "Succeeded!"
            echo "Verify your IPv4 address $ipv6 with an external ping tool https://dnschecker.org/ping-ipv4.php."
        else
            echo "Process stopped. It was not possible to setup IPv6 in the relevant file $file"
            exit 1
        fi
    fi
fi
##
## Apply this configuration without reboot
sysctl -p
echo ""
echo ""
echo "###########################################"
echo "#                #########                #"
echo "#               END PROCESS               #"
echo "#             ###############             #"
echo "###########################################"
echo ""
echo ""
