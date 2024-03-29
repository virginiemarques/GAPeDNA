# Source code for GAPeDNA

Access the app online [here](https://shiny.cefe.cnrs.fr/GAPeDNA/)

This repo presents the source code of our web-app interface GAPeDNA, investigating database gaps in eDNA metabarcoding primers.   
If you notice the link to be broken, please file an issue here.   
The most probable reason is an ungoing server maintenance, unlikely to last for more than a couple days.   

Alternatively, you can also access the app in your local machine from the source code as further explained.

## New taxa addition

At the moment, GAPeDNA works for marine and freshwater fish.   
To propose a new taxon for addition in GAPeDNA, please file an issue labelled 'enhancement' in this repo stating the wanted group, and provide the necessary information:

* Primer pairs amplifying the taxon
* One or several global spatialized checklists with relevant resolution

With only those two information, the app will be updated to implement your suggestion.

## How to use GAPeDNA

GAPeDNA allows you to visualize current spatialized gaps in species coverage for a given taxonomical group within a reference database for a variety of primers.  
At the moment, the app uses ENA/EMBL from December 2021 (downloaded in February 2022) as the reference database and will be frequently updated.  

Here is how the data is generated:

![](README/schema_method2.png?raw=true "Title")

GAPeDNA allows you to interact with the spatialized species coverage map, while choosing the relevant primer pair and wanted spatial resolution for the species checklist.

![](README/schema_appli.png?raw=true "Title")

### User choices

#### World maps pane
First, you must choose the taxonomical group you want. At the moment, only marine and freshwater fishes are available.  
Then, you must choose the spatial resolution of the map. This depends on the taxon, for freshwater fishes the resolution in the drainage basins and for marine fishes, you can choose between ecoregions or provinces.
Then, you must choose which marker position you want your primer in. At the moment, you have the choice between 5 positions for fishes.  
Finally, you choose your primer of interest and the interactive map prints!

##### Navigating the interface

You can now interact with the map. You can zoom in to find your locality in details, you can hover over areas so that the percentage of coverage is displayed simultaneously.  

You can also click on a polygon of interest and the full list of species occurring  within this polygon will be displayed on the table below. In this table, you have information on the species present but also their IUCN status and whether or not they are sequenced for your chosen marker. You can filtrate your data to print only the sequenced species for example, or display only the threatened species, or both at the same time.  

##### Dowload data

Finally, you can download the printed table using the download button on the sidebar.

If you are interested in the full data to investigate the comparison in primer coverage on your own, you can install the app locally and load the full dataset in R.

#### Sequence extration pane
You have to upload a `csv` file generated from the `World maps` pane.  
The app will show a table with all species including the sequence corresponding the marker you chose, with or without the primer sequences and the number of mismatches on each primer. 

## Local display of the app

You need to have R installed in your local machine.  
Please make sure the necessary packages are installed in your machine and up to date, otherwise some errors might occur.

1) Using GitHub

You can load the app just by calling the GitHub repo in a local R session. Depending on your internet connexion, it can take up to a few minutes to fully load.   
Some errors linked to package version might also arise, if such you are invited to install it on your local computer on a R session and update or install the missing packages.

```R
library('shiny')
runGitHub("GAPeDNA", "virginiemarques")
```

2) On your local computer

Alternatively, you first need to download the repo, then launch R. Here are the command to run on the terminal (Linux/Mac only):

```bash
git clone https://github.com/virginiemarques/GAPeDNA
cd GAPeDNA/
R
```

After, you need to load `shiny` to run the app in local inside a R session:

```R
library('shiny')
runApp()
```

## Demonstration

Here is a GIF demonstration of how to interact with the app.

![grab-landing-page](https://github.com/virginiemarques/Gaps_shiny_quicktest/blob/master/README/Shiny_2.gif)

### Credits

P. Lopez (UMR MARBEC) for the illustration & [C. Bernard](https://github.com/cybernar) & M.Q. Quidoz for the online deployment on the CEFE's server.

