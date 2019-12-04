## How to Autosize SZHPs

### First Run

1. In the `parameters/cases` folder, create 16 .pxv files for each climate zone named "CZ##.pxv" ie. `CZ01.pxv` or `CZ12.pxv` for each of the climate zones.
2. In the `root.pxt` file, use the [pre_autosizing_szhp_addon.pxt](https://github.com/TRC-RTC/T24-2022-CASE-Modeling/blob/master/ModelKit%20Run%20-%20AllElectric/modelkit/templates/pre_autosizing_szhp_addon.pxt) file.
   - Insert this Ruby code chunk in the `root.pxt` file where you would like to place SZHPs.
3. Use `_compose_all.bat` and `_run_all.bat` to initially generate and run 16 models.

### Batch Scripts

  4. Use [_copy_all_autosizing.bat](https://github.com/TRC-RTC/T24-2022-CASE-Modeling/blob/master/ModelKit%20Run%20-%20AllElectric/modelkit/bin/_copy_all_autosizing.bat) to copy the HVACSecondary files from the baseline model into the appropriate folder [here](https://github.com/TRC-RTC/T24-2022-CASE-Modeling/tree/master/ModelKit%20Run%20-%20AllElectric/modelkit/parameters/cases/autosizing) needed for autosizing. There should be 16 csv files with the baseline HVACSecondary csv file renamed as each of the climate zones.
   - If you want to copy one folder at a time use [_copy_autosized_file.bat](https://github.com/TRC-RTC/T24-2022-CASE-Modeling/blob/master/ModelKit%20Run%20-%20AllElectric/modelkit/bin/_copy_autosized_file.bat)
     - In the commandline run like below with the name of the folder as an argument:
     ```{commandline}
     _copy_autosized_file name_of_folder
     ```

### AutoSized Run

5. Take the same `root.pxt` file but now replace the Ruby chunk from `pre_autosizing_szhp_addon` with [autosizing_szhp_addon.pxt](https://github.com/TRC-RTC/T24-2022-CASE-Modeling/blob/master/ModelKit%20Run%20-%20AllElectric/modelkit/templates/autosizing_szhp_addon.pxt).
   - As long as capacities do not change and CZ is specified, this "add-on" pxt file will match the proposed model SZHP cooling capacity, heating capacity, and Supply Fan CFM to the baseline model. Steps from "First Run" and "Batch Scripts" do not have to be run again.
6. Note: To use `_compose_all` use the `_compose_all` in the `parameters/cases` folder. There may be a better way to do this in the future... 
