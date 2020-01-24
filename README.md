# T24 2022 CASE Modeling

## Notes:

- When making changes to the `root.pxt` file for any prototype, put this in a separate commit and make sure change is ovbious in the commit note.

## Current File Organization:

- `framework` folder contains all folders and files needed to run ModelKit.

    - If you need to create a new ModelKit run, please create a new folder in the `analysis` folder.

    - `analysis` folder: contains all run files. Create cases in `cases.csv` and view results in `results.csv` here.
    - `autosizing` folder: contains files needed for autosizing HVAC systems.
    - `baselines` folder: contains csv files with parameters of baseline system (dependent on climate zone).
    - `prototypes` folder: contains `root.pxt` files for prototypes that are shared.
    - `templates` folder: contains template files that are shared.

- `Prototypes` Folder contains current MidRise and HighRise prototype CBECC-Com files.

- `Resources` Folder contains CBECC-Com Data Dictionary.
