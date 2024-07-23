# ByeByeWiFi
ByeByeWiFi.sh is a bash script used to perform a deauthentication attack on a selected wireless network. It scans for available networks, allows the user to select a network, and then sends deauthentication packets to all clients connected to that network, effectively disconnecting them.

## Dependencies
The script depends on the following tools:

- figlet
- airmon-ng
- airodump-ng
- aireplay-ng
- iwconfig
- ifconfig
- systemctl

Please ensure these are installed on your system before running the script.

## Usage
1. Run the script with root privileges using the command `sudo ./ByeByeWiFi.sh`
2. Select a Wireless Network Interface that will be put into monitor mode
3. Select the duration of the scan for networks.
4. Once the scan is complete, a list of available networks will be displayed. Choose the target network by entering the corresponding number when prompted.
5. The script will then send deauthentication packets to all clients connected to the selected network disconecting them. Press `enter` to finish the atack.

Note: This script should be used for educational purposes only and with the necessary permissions. Unauthorized use is illegal and unethical.

## Operation
1. Put the selected Network Interface into monitor mode
with `airmon-ng`
2. Scan for networks using `airodump-ng`, this tool uses the monitor mode interface to listen to all wireless traffic on the configured channel.
3. Change the channel of the Network Interface to the same channel as the target network with `iwconf`.  This is necessary because wireless networks operate on different channels, and to communicate with a specific network, the interface must be on the same channel.
4. `aireplay-ng`  crafts deauthentication frames, which are a type of management frame in the 802.11 standard. The frames are injected into the network using the monitor mode interface.
5. When clients receive these frames, they interpret them as a legitimate instruction to disconnect from the access point. This disrupts their connection until they attempt to reconnect, at which point more deauth frames can be sent to keep them disconnected.

## Disclaimer
#### Important Notice:
This script is created for educational and research purposes in cybersecurity only. Its purpose is to demonstrate how deauthentication (deauth) attacks work on Wi-Fi networks to aid in identifying and fixing vulnerabilities in controlled and authorized environments.

#### Responsible Use:

- Authorization: Use this script only on networks you own or for which you have explicit permission to conduct security testing.
- Legality: Executing deauthentication attacks on networks without permission is illegal and may result in serious consequences, including legal penalties.
- Responsibility: The author of this script is not responsible for any damages, losses, or consequences arising from improper or illegal use of this script.

By using this script, you agree to assume full responsibility for its use and to comply with all applicable laws and regulations.
