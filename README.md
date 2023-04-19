# jai-wayland
Wayland support for the Jai standard library

## "Installation"
1. copy everything from `modules/` to a local module directory
   * **do NOT overwrite the modules in your Jai distribution!**
   * if you already have a local module directory I would recommend adding a new one just for these modules to make it easier to opt-out of using them
1. add the path containing the modified modules to the list of import directories (either via `-import_dir` on the command line or from the build meta-program)
   * make sure it is the first one in the list of import directories so that the modified versions of `Window_Type`, `Window_Creation`, `Simp`, `Input` and `Clipboard` take precedence over the default ones
1. to go back to "normal" simply remove the local module directory containing the modified modules from the import path search list

## Usage
Use the standard modules (`Simp`, `GetRect`, `Window_Creation`, `Input`) as normal, there is no new API.
