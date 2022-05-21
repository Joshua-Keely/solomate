#!/bin/bash

# This script auto-installs and auto-deploys Solana
# Candy machines using Metaplex. 

# Yarn/ ts-node/ node.js and git are the pre-requisites
# to use this script. 

############ Functions ############
menu () {
    figlet Solomate

    echo "Welcome to Solomate ! Where would you like to start ?

    1) Full Solana candy machine installation
    2) Solana Candy machine config file creator
    3) Metadata creation
    4) Assets validation
    5) Exit"

    read -p "Choose an option : " optn1
}

cm_auto_install () {
    
    # Installation directory
    read -p $'\e[32mWhere would you like to install the CM ? (path)\e[0m: ' path1

    #Clone from GitHub
    read -p $'\e[32mWould you like to install pre-requisites ? (y/n)\e[0m: ' yn
    if [ $yn == 'y' ]
    then
        apt install git
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -sudo apt-get install -y nodejs
        npm install --global yarn
        npm install -g typescript
        npm install -g ts-node 
    fi

    read -p $'\e[32mWould you like to clone Metaplex ? (y/n)\e[0m: ' yn1
    if [ $yn1 == 'y' ]
    then    
        git clone https://github.com/metaplex-foundation/metaplex.git $path1 -q
        echo $'\e[1;33m'Repo was clonned in$'\e[0m' $path1
    fi 

    # Install JS packages
    read -p $'\e[32mWould you like to install Js packages ? (y/n)\e[0m: ' yn2
    if [ $yn2 == 'y' ]
    then 
        yarn install --cwd $path1/js -s
        # Test CMV2 version. Output should be "0.0.2"
        ts-node $path1/js/packages/cli/src/candy-machine-v2-cli.ts --version
        echo $'\e[1;33m'Output should be '0.0.2' $'\e[0m'
    fi

    # Configuration of the CM
    read -p $'\e[32mCreate config file ? (y/n)\e[0m: ' yn3
    if [ $yn3 == 'y' ]
    then 
        read -p $'\e[32mPrice (ex: 2.0) \e[0m: ' psol
        read -p $'\e[32mNumber of NFTs (ex: 5) \e[0m: ' nsol
        read -p $'\e[32mWallet address \e[0m: ' wsol
        read -p $'\e[32mGo live date (Format: 25 Dec 2021 00:00:00 GMT) \e[0m: ' dsol
        echo "{ "price": $psol, "number": $nsol, "gatekeeper": null, "solTreasuryAccount": "$sol", "splTokenAccount": null, "splToken": null, "goLiveDate": "$dsol", "endSettings": null, "whitelistMintSettings": null, "hiddenSettings": null, "storage": "arweave-sol", "ipfsInfuraProjectId": null, "ipfsInfuraSecret": null, "awsS3Bucket": null, "noRetainAuthority": false, "noMutable": false }" > $path1/config.json 
        echo $'\e[1;33m'Config file has been created successfully$'\e[0m'
    fi

    # Solana suite installation
    read -p $'\e[32mWould you like to install the Solana Tool Suite ? (y/n)\e[0m: ' yn4
    if [ $yn4 == 'y' ]
    then
        sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
        solana-install update
        read -p $'\e[32mWould you like to create a new wallet ? (y/n)\e[0m: ' yn5
        if [ $yn5 == 'y' ]
        then
            read -p $'\e[32mSolana network (devnet, testnet, mainnet-beta)\e[0m: ' network
            solana-keygen new --outfile ~/.config/solana/$network.json
            solana config set --url https://metaplex.$network.rpcpool.com/
            if [ $network == 'devnet' ]
            then
                read -p $'\e[32mWould you like to airdrop SOL to your wallet ? (y/n)\e[0m: ' yn6
                if [ $yn6 == 'y' ] 
                then
                    read -p $'\e[32mHow many SOLs do you need ? (y/n)\e[0m: ' airsol
                    solana airdrop $airsol
                fi
            fi
        fi
    fi 

    echo $'\e[1;33m'Creation complete ! $'\e[0m'


}

config_file_creator () {
    # Configuration of the CM

    read -p  $'\e[32mPath to Metaplex folder \e[0m: '  $path2
    read -p $'\e[32mPrice (ex: 2.0) \e[0m: ' psol
    read -p $'\e[32mNumber of NFTs (ex: 5) \e[0m: ' nsol
    read -p $'\e[32mWallet address \e[0m: ' wsol
    read -p $'\e[32mGo live date (Format: 25 Dec 2021 00:00:00 GMT) \e[0m: ' dsol
    echo "{ "price": $psol, "number": $nsol, "gatekeeper": null, "solTreasuryAccount": "$sol", "splTokenAccount": null, "splToken": null, "goLiveDate": "$dsol", "endSettings": null, "whitelistMintSettings": null, "hiddenSettings": null, "storage": "arweave-sol", "ipfsInfuraProjectId": null, "ipfsInfuraSecret": null, "awsS3Bucket": null, "noRetainAuthority": false, "noMutable": false }" > $path1/config.json 
    echo $'\e[1;33m'Config file has been created successfully$'\e[0m'

}

assets_validator () {

    # Validates metadata from the assets (.png) and creates candy machine.
    # Pre-requisites : Create an "assets" folder in /metaplex/js/packages/cli/src/ and put the .png and the .json files. 
    #e.g : 
    # 0.png
    # 0.json

    read -p $'\ePath to CMV2 \e[0m:'  pathts-node $path/js/packages/cli/src/candy-machine-v2-cli.ts verify_assets ./assets
    # CM upload
    read -p $'\eSol network (devnet, testnet, mainnet-beta) \e[0m:' network
    ts-node $path/js/packages/cli/src/candy-machine-v2-cli.ts upload \
    -e $network \
    -k $path/.config/solana/$network.json \
    -cp config.json \
    -c example \
    ./assets
    echo $'\e[1;33m'Output should be "Successfull=True"$'\e[0m'

    # set collection
    read -p $'\ePublic SOL address : \e[0m:' soladd
    ts-node $path/js/packages/cli/src/candy-machine-v2-cli.ts set_collection \
    -e $network \
    -k  $path/.config/solana/$network.json \
    -c example \
    -m $soladd
    echo $'\e[1;33m'Assets validated !


}

metadata_creation () {
    clear
    echo $'\e[1;33m'Sorry for the inconvenience but this functionnality is yet to be developped...$'\e[0m'
    sleep 3s
    clear
}

############ Functions end ############

############ Main program #############
for (( ; ; ))
do
    clear
    menu
    if [ $optn1 == 1 ]
    then
        cm_auto_install
        clear
    fi

    if [ $optn1 == 2 ]
    then
        config_file_creator
        clear
    fi

    if [ $optn1 == 3 ]
    then
        metadata_creation
        clear
    fi

    if [ $optn1 == 4 ]
    then
        assets_validator
        clear
    fi

    if [ $optn1 == 5 ]
    then
        clear
        exit
    fi
done

########## Main program end ###########

clear
echo $'\e[1;33m'Thank you for using Solomate tools ! Created by Joshua Keely$'\e[0m'

