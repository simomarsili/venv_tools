Virtual environments utils (via venv module).

## Usage
- `venv_activate [project]`  
  Activate the virtual environment from folder <project> in ~/.virtualenvs.  
  Default: get project name from the PWD.  
  If not present, create the folder <project> and install a ipython kernel
  with the same name.
- `venv_remove <project>`
  Remove <project> folder and the associated ipython kernel.
- `venv_ls`
  List virtual environments in ~/.virtualenvs.
