# Virtual environments utils (via venv module).
# 
# Usage:
# 
# $ venv_activate [-p <python executable>] [project]
# Activate the virtual environment from folder <project> in $HOME/.venvs.
# If the folder <project> does not exist, create it and install
# a ipython kernel with the same name.
# Project names are automatically converted to lowercase strings.
# Default: get project name from the PWD.  
# 
# $ venv_remove <project>
# Remove <project> folder and the associated ipython kernel.
# 
# $ venv_ls
# List virtual environments in ~/.venvs.

ENVS_DIR="$HOME/.venvs"


function lower {
    # turn to lowercase
    echo $1 | tr '[:upper:]' '[:lower:]'
}

function upper {
    # turn to lowercase
    echo $1 | tr '[:lower:]' '[:upper:]'
}


function confirm {
    # return 0/1 if yes/no else ask again
    while true; do
	if [[ -z $1 ]]; then
	    echo "error: confirm <question>"
	    return 1;
	fi
	question="$*"
	read -p "$question" reply
	reply=$(lower $reply)
	if [[ $reply =~ ^(y|yes)$ ]];
	then
	    return 0
	elif [[ $reply =~ ^(n|no)$ ]];
	then
	    return 1
	fi
    done
}


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
    fi

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
    PROJECT=`echo $PROJECT | awk '{print tolower($0)}'`
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
    if confirm "Install ipython kernel?"
    then
	ipython kernel install --user --name=$PROJECT
    fi
}


function __venv_create {
    PROJECT=$1
    PYTHON=$2
    PROJECT=`echo $PROJECT | awk '{print tolower($0)}'`
    ve=$ENVS_DIR/$PROJECT
    if [[ -d $ve ]]; then
	if confirm "$PROJECT already exists. Replace it?"
	then
	    rm -rf $ve
	    __build_project_ve $PROJECT $PYTHON
	else
	    source $ve/bin/activate
	fi
    else
	if confirm "Create project $PROJECT?"
	then
	    __build_project_ve $PROJECT $PYTHON
	fi
    fi
}

