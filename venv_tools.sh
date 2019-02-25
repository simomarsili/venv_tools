#!/bin/bash

# Utilities for managing virtual environments via the Python3 venv module.
# (https://docs.python.org/3/library/venv.html)
# 
# venv_activate [project]
# activate virtual environment <project> from project folders in ~/.virtualenvs
# (if not present create the folder and install a ipython kernel with the
# same name). If no name is passed, activate a virtual environment named from
# the PWD.
#
# venv_remove <project>
# remove project folder and the associated ipython kernel.
#
# venv_ls
# list of the installed virtual environments.

python=python3
envs_dir="$HOME/.virtualenvs"


function venv_activate {
    if [ -z $1 ]; then
	project=${PWD##*/}
    else
	project=$1
    fi

    ve=$envs_dir/$project
    if [ -d $ve ]; then
	source $ve/bin/activate
    else
	__venv_create $project
    fi
}


function venv_remove {
    if [ -z $1 ]; then
	project=${PWD##*/}
    else
	project=$1
    fi
    rm -r $envs_dir/$project
    yes | jupyter kernelspec uninstall $project
    echo "Removed $project project folder from $envs_dir."
}


function venv_ls {
    ls -1 $envs_dir
}


function __build_project_ve {
    project=$1
    ve=$envs_dir/$project
    echo "Creating $project project folder in $envs_dir."
    $python -m venv $ve
    source $ve/bin/activate
    pip install -U pip
    pip install ipykernel
    ipython kernel install --user --name=$project
}


function __venv_create {
    if [ -z $1 ]; then
	project=${PWD##*/}
    else
	project=$1
    fi

    ve=$envs_dir/$project
    if [ -d $ve ]; then
	echo "$project already exists. Replace it? (y/n)"
	read answer
	if [ -z "$answer" ]; then return 1; fi
	if [ $answer == "y" ]; then
	    rm -rf $ve
	    __build_project_ve $project
	elif [ $answer == "n" ]; then
	    source $ve/bin/activate
	else
	    echo "Please answer y/n"
	fi
    else
	__build_project_ve $project
    fi
}

