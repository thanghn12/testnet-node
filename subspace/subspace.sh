#!/bin/bash
echo "=================================================="
echo -e "\033[0;35m"
echo "      ___                        ___                                    _____    ";
echo "     /  /\          ___         /  /\                      ___         /  /::\   ";
echo "    /  /::|        /__/\       /  /::\                    /  /\       /  /:/\:\  ";
echo "   /  /:/:|        \  \:\     /  /:/\:\    ___     ___   /  /:/      /  /:/  \:\ ";
echo "  /  /:/|:|__       \  \:\   /  /:/~/::\  /__/\   /  /\ /__/::\     /__/:/ \__\:|";
echo " /__/:/ |:| /\  ___  \__\:\ /__/:/ /:/\:\ \  \:\ /  /:/ \__\/\:\__  \  \:\ /  /:/";
echo " \__\/  |:|/:/ /__/\ |  |:| \  \:\/:/__\/  \  \:\  /:/     \  \:\/\  \  \:\  /:/ ";
echo "     |  |:/:/  \  \:\|  |:|  \  \::/        \  \:\/:/       \__\::/   \  \:\/:/  ";
echo "     |  |::/    \  \:\__|:|   \  \:\         \  \::/        /__/:/     \  \::/   ";
echo "     |  |:/      \__\::::/     \  \:\         \__\/         \__\/       \__\/    ";
echo "     |__|/           ~~~~       \__\/                                            ";
echo -e "\e[0m"
echo "=================================================="

sleep 2

echo -e "\e[1m\e[32m1. Updating dependencies... \e[0m" && sleep 1
sudo apt update

echo "=================================================="

echo -e "\e[1m\e[32m2. Installing wget... \e[0m" && sleep 1
sudo apt install wget -y
cd $HOME

echo "=================================================="

echo -e "\e[1m\e[91mNOTE. This step is only for those who used previously our script to run the node!!!"
echo -e "If you have used a different setup to start node/farmer then terminate this process CTRL+C, stop the node/farmer and wipe the old data before continuing!!! \e[0m"
echo -e "\e[1m\e[91mOfficial Guide: https://github.com/subspace/subspace/blob/main/docs/farming.md#switching-to-a-new-snapshot \e[0m"
echo -e "./FARMER_FILE_NAME wipe"
echo -e "./NODE_FILE_NAME purge-chain --chain testnet \n"

echo -e "\e[1m\e[91m3. If you were running a node previously, and want to switch to a new snapshot we need to cleanup old data. Please confirm (y/n) \e[0m"
read -p "(y/n)?" response
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then   
    sudo systemctl stop subspace-farmer.service
    sudo systemctl stop subspace-node.service
    subspace-farmer wipe
    subspace-node purge-chain -y --chain testnet
fi
echo "=================================================="

echo -e "\e[1m\e[32m3. Downloading subspace node binary... \e[0m" && sleep 1
sudo wget https://github.com/subspace/subspace/releases/download/snapshot-2022-mar-09/subspace-node-ubuntu-x86_64-snapshot-2022-mar-09

echo "=================================================="

echo -e "\e[1m\e[32m4. Downloading subspace farmer binary... \e[0m" && sleep 1
sudo wget https://github.com/subspace/subspace/releases/download/snapshot-2022-mar-09/subspace-farmer-ubuntu-x86_64-snapshot-2022-mar-09

echo "=================================================="

echo -e "\e[1m\e[32m5. Moving node to /usr/local/bin/subspace-node ... \e[0m" && sleep 1
sudo mv subspace-node-ubuntu-x86_64-snapshot-2022-mar-09 /usr/local/bin/subspace-node

echo "=================================================="

echo -e "\e[1m\e[32m6. Moving farmer to /usr/local/bin/subspace-farmer ... \e[0m" && sleep 1
sudo mv subspace-farmer-ubuntu-x86_64-snapshot-2022-mar-09 /usr/local/bin/subspace-farmer

echo "=================================================="

echo -e "\e[1m\e[32m7. Giving permissions to subspace-farmer & subspace-node ... \e[0m" && sleep 1
sudo chmod +x /usr/local/bin/subspace*

echo "=================================================="

echo -e "\e[1m\e[32m8. Enter Polkadot JS address to receive rewards \e[0m"
read -p "Address: " ADDRESS

echo "=================================================="

echo -e "\e[1m\e[32m9. Enter Subspace Node name \e[0m"
read -p "Node Name : " NODE_NAME

echo "=================================================="

echo -e "\e[1m\e[92m Node Name: \e[0m" $NODE_NAME

echo -e "\e[1m\e[92m Address:  \e[0m" $ADDRESS

echo -e "\e[1m\e[91m    11.1 Continue the process (y/n) \e[0m"
read -p "(y/n)?" response
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then

    echo "=================================================="

    echo -e "\e[1m\e[32m12. Creating service for Subspace Node \e[0m"

    echo "[Unit]
Description=Subspace Node

[Service]
User=$USER
ExecStart=subspace-node --chain testnet --wasm-execution compiled --execution wasm --bootnodes '/dns/farm-rpc.subspace.network/tcp/30333/p2p/12D3KooWPjMZuSYj35ehced2MTJFf95upwpHKgKUrFRfHwohzJXr' --rpc-cors all --rpc-methods unsafe --ws-external --validator --telemetry-url 'wss://telemetry.polkadot.io/submit/ 1' --telemetry-url 'wss://telemetry.subspace.network/submit 1' --name '$NODE_NAME'
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
    " > $HOME/subspace-node.service

    sudo mv $HOME/subspace-node.service /etc/systemd/system

    echo "=================================================="

    echo -e "\e[1m\e[32m13. Creating service for Subspace Farmer \e[0m"

    echo "[Unit]
Description=Subspace Farmer

[Service]
User=$USER
ExecStart=subspace-farmer farm --reward-address $ADDRESS
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
    " > $HOME/subspace-farmer.service

    sudo mv $HOME/subspace-farmer.service /etc/systemd/system

    echo "=================================================="

    # Enabling services
    sudo systemctl daemon-reload
    sudo systemctl enable subspace-farmer.service
    sudo systemctl enable subspace-node.service

    # Starting services
    sudo systemctl restart subspace-node.service
    sudo systemctl restart subspace-farmer.service

    echo "=================================================="

    echo -e "\e[1m\e[32mNode Started \e[0m"
    echo -e "\e[1m\e[32mFarmer Started \e[0m"

    echo "=================================================="

    echo -e "\e[1m\e[32mTo stop the Subspace Node: \e[0m" 
    echo -e "\e[1m\e[39m    systemctl stop subspace-node.service \n \e[0m" 

    echo -e "\e[1m\e[32mTo start the Subspace Node: \e[0m" 
    echo -e "\e[1m\e[39m    systemctl start subspace-node.service \n \e[0m" 

    echo -e "\e[1m\e[32mTo check the Subspace Node Logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-node.service -f \n \e[0m" 

    echo -e "\e[1m\e[32mTo stop the Subspace Farmer: \e[0m" 
    echo -e "\e[1m\e[39m    systemctl stop subspace-farmer.service \n \e[0m" 

    echo -e "\e[1m\e[32mTo start the Subspace Farmer: \e[0m" 
    echo -e "\e[1m\e[39m    systemctl start subspace-farmer.service \n \e[0m" 

    echo -e "\e[1m\e[32mTo check the Subspace Farmer signed block logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-farmer.service -o cat | grep 'Successfully signed block' \n \e[0m" 

    echo -e "\e[1m\e[32mTo check the Subspace Farmer default logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-farmer.service -f \n \e[0m" 
else
    echo -e "\e[1m\e[91m    You have terminated the process \e[0m"
fi
