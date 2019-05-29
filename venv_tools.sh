# Virtual environments utils (via venv module).
# 
# Usage:
# 
# $ venv_activate [-p <python executable>] [project]
# Activate the virtual environment from folder <project> in $HOME/.venvs.
# If the folder <project> does not exist, create it and install
# a ipython kernel with the same name.
# Default: get project name from the PWD.  
# 
# $ venv_remove <project>
# Remove <project> folder and the associated ipython kernel.
# 
# $ venv_ls
# List virtual environments in ~/.venvs.

ENVS_DIR="$HOME/.venvs"


function venv_activate {
    POSITIONAL=()
    while [[ $# -gt 0 ]]
    do
	key="$1"
	
	case $key in
	    -p|--python)
		PYTHON="$2"
		shift # past argument
		shift # past value
		;;
	    *)    # unknown option
		POSITIONAL+=("$1") # save it in an array for later
		shift # past argument
		;;
	esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters

    if [ "$#" -eq "0" ]; then
	PROJECT=${PWD##*/}
    elif [ "$#" -eq "1" ]; then
	PROJECT=$1
    else
	echo Found: "${POSITIONAL[@]}". Need a single project name.
	return 1
    fi

    if [ -z $PYTHON ]; then
	PYTHON=python3
	echo "default: ", python3
    else
	echo "found: "$PYTHON
    fi

    echo Python: $PYTHON, project: $PROJECT

    ve=$ENVS_DIR/$PROJECT
    if [ -d $ve ]; then
	source $ve/bin/activate
    else
	__venv_create $PROJECT $PYTHON
    fi
}


function venv_remove {
    if [ -z $1 ]; then
	PROJECT=${PWD##*/}
    else
	PROJECT=$1
    fi
    rm -r $ENVS_DIR/$PROJECT
    yes | jupyter kernelspec uninstall $PROJECT
    echo "Removed $PROJECT project folder from $ENVS_DIR."
}


function venv_ls {
    ls -1 $ENVS_DIR
}


function __build_project_ve {
    PROJECT=$1
    PYTHON=$2
    ve=$ENVS_DIR/$PROJECT
    echo "Creating $PROJECT project folder in $ENVS_DIR."
    # find python version
    version=`$PYTHON -c "import sys; print(sys.version_info[0])"`
    if [ "$version" -eq "2" ]; then
	virtualenv -p $PYTHON $ve
    elif [ "$version" -eq "3" ]; then
	$PYTHON -m venv $ve
    else
	echo Check Python version
	return 1
    fi
    source $ve/bin/activate
    pip install -U pip
    pip install ipykernel
    ipython kernel install --user --name=$PROJECT
}


function __venv_create {
    PROJECT=$1
    PYTHON=$2
    ve=$ENVS_DIR/$PROJECT
    if [ -d $ve ]; then
	echo "$PROJECT already exists. Replace it? (y/n)"
	read answer
	if [ -z "$answer" ]; then return 1; fi
	if [ $answer == "y" ]; then
	    rm -rf $ve
	    __build_project_ve $PROJECT $PYTHON
	elif [ $answer == "n" ]; then
	    source $ve/bin/activate
	else
	    echo "Please answer y/n"
	fi
    else
	__build_project_ve $PROJECT $PYTHON
    fi
}

