#!/bin/sh

origin=""

configurator()
{
    echo -e "\nEnter process name for which you want to move a clip:"
    read -e -r process
    processes+=("$process")

    echo -e "Enter the directory where you want to move a clip for process $process:"
    read -e -r dir
    directories+=("$dir")

    if [[ -d $dir ]]
    then
        echo -e "Found provided directory."
    else
        echo -e "Provided directory was not found!\nAttempting to make one for you..."
        mkdir $dir
    fi

    # Credits: https://stackoverflow.com/a/3232082/16318032
    read -e -r -p "Do you want to add another process? [Y/n]" response
    case "$response" in
        [nN][oO]|[nN])
            touch "$HOME/.config/gpu-screen-recorder-autosort.conf"
            echo "src=$origin" >> "$HOME/.config/gpu-screen-recorder-autosort.conf"
            for i in "${!processes[@]}"
            do    
                echo "${processes[i]}|${directories[i]}" >> "$HOME/.config/gpu-screen-recorder-autosort.conf"
            done
            run
            ;;
        *)
            return 1
            ;;
    esac
}

run()
{
    while read -r line; do
        substr="${line%=*}"
        if [ "$substr" == "src" ]
        then
            origin="${line#*=}"
        fi
        substr_proc="${line%|*}"
        proc=`pgrep -x $substr_proc`
        if [[ "$proc" != "" ]]
        then
            latest_file=`ls $origin*.mp4 -t | head -1` # This only supports .mp4 files but I kinda dont care :)
            echo -e "Found process ${line%|*}, moving file $latest_file"
            mv "$latest_file" "${line#*|}"
            exit 1
        fi
    done < "$HOME/.config/gpu-screen-recorder-autosort.conf"
    exit 0
}

# Check if config folder and config file exists
if [[ -d "$HOME/.config" ]]
then
    if [[ -f "$HOME/.config/gpu-screen-recorder-autosort.conf" ]]
    then
        echo "Found config file"
        run
    else
        echo -e "Config file does not exist!\nCreating one for you...\n"
        echo -e "Where are your clips saved (-o flag you specified for gpu-screen-recorder):"
        read -e origin
        if [[ -d $origin ]]
        then
            declare -a processes=()
            declare -a directories=()
            while
                configurator
                [[ true ]]
            do true; done
        else
            echo "Provided directory does not exist!\nAre you sure this is the right path?" # Lets not create the folder for the user
            exit 1
        fi
    fi
else
    echo "Config directory does not exist!"
    exit 1
fi