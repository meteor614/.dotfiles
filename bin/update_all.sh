#!/bin/bash

begin=`date "+%s"`
{
    if type brew &>/dev/null; then
        brew update
        brew upgrade --cleanup
        brew cleanup
        echo "brew update finish"
    elif type apt&>/dev/null; then
        sudo apt update
        sudo apt upgrade -y
        sudo apt-get clean
        echo "apt update finish"
    elif type yum&>/dev/null; then
        sudo yum -y update
        sudo yum clean
        echo "yum update finish"
    else
        echo "update command not found"
    fi
}&
{
    if type pip3&>/dev/null; then
        for i in `pip3 list --outdated --format=legacy|awk -F ' ' '{print $1}'`
            do pip3 install --upgrade $i &
        done
        wait
        echo "pip3 upgrade finish"
    else
        for i in `pip list --outdated --format=legacy|awk -F ' ' '{print $1}'`
            do pip install --upgrade $i &
        done
        wait
        echo "pip upgrade finish"
    fi
}&
if type upgrade_oh_my_zsh &>/dev/null; then
    {
        upgrade_oh_my_zsh
        echo "Oh My Zsh upgrade finish"
    }&
fi
if [ x$1 == xall ]; then
	{
		vim -c GoUpdateBinaries -c qa only_for_load_go.go
		echo "vim GoUpdateBinaries finish"
	}&
    {
        if type pip3&>/dev/null; then
            for i in `pip list --outdated --format=legacy|awk -F ' ' '{print $1}'`
                do pip install --upgrade $i &
            done
            wait
            echo "pip upgrade finish"
        fi
    }&
fi
vim -c PlugUpdate -c PlugUpgrade -c qa
echo "vim PlugUpdate finish"
wait
end=`date "+%s"`
echo "used `expr $end - $begin` seconds"
