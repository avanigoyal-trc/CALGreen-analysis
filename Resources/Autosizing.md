## How to Autosize Zone System SZHP and SZAC

- In the `cases.csv` file that you are using to change parameters, please include the following variables:
    - `:prototype`: name of the prototype you are testing corresponding to the folder name under the `prototypes` folder
    - `:software`: "cbecc-com" or "cbecc-res"
    - `:measure_folder`: name of the measure you are testing corresponding under the `analysis` folder
    - `:folder_name`: name of the case you are testing. This should be the same as the `case` column you define in `cases.csv`
    - `:autosizing`: "Yes" or "No". The default is "No".
    - `:hvac_type`: "SZAC" or "SZHP". The default is "SZAC".
