
## How to Use `results_summary.R`

-	In the analysis folder you are working in, ie. ‘qsr-nc’ please copy the folder [here](https://github.com/TRC-RTC/2020-Reach-Codes-Modeling/tree/master/framework/scripts/qc_template) called “reformatted_results” into your folder. This only has to be done the first time you create a new analysis folder.

-	Open "Results_Reformatted.xlsx" in the “reformatted_results” folder. There are 4 yellow tabs. These are linked to the Summary Graphs tabs. Rename the yellow tabs with the names of the measures you would like to compare using the Reach Code naming convention.
	 - Ie. for “qsr-nc-mf-code”, rename to “nc-mf-code”. The names should match the case names you use in the cases.csv file, except for the prototype description. 
-	Create the “results.csv” file as you normally would using modelkit rake.
-	Go to the “framework” folder and double click on “framework.Rproj”
	 - Open “results_summary.R” in the “scripts” folder.
   - Select all and run
   - In the console type: results_spreadsheet(path) where path is the path of your analysis folder in quotations. ie. For “analysis/qsr-nc”, type:  `results_spreadsheet(“analysis/qsr-nc”)`
   -Now all the results from “results.csv” should be in the “Results_Reformatted.xlsx” and the graphs are generated.

**Notes:**
-	4 tabs with graphs – Summary Graphs (first 2 green tabs) that have Excel graphs and End Use Stacked Graphs (last 2 green tabs) that have R graphs.
-	If there are more than 4 measures in the “results.csv” file, grey tabs are added to end with the summarized results but these aren’t linked to the Summary graph tabs
o	End use stacked charts contain graphs for all measures included in the “results.csv” (even if more than 4)
