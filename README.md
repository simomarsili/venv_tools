Utils for managing virtual environments via the Python3 venv module.
(https://docs.python.org/3/library/venv.html)

## Usage
- `venv_activate [project]`  
  Activate virtual environment <project> from project folders in ~/.virtualenvs.
  If not present, create the folder and install a ipython kernel with the
  same name. If no name is passed, activate a virtual environment named from
  the PWD.
- `venv_remove <project>`
  Remove project folder and the associated ipython kernel.
- `venv_ls`
  List the installed virtual environments.
