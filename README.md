# Source code for GAPeDNA 

This repo presents the source code of our web-app interface GAPeDNA, investigating database gaps in eDNA metabarcoding primers. The online access to the app is [here](https://shiny.cefe.cnrs.fr/GAPeDNA/).  
If you notice the link to be broken, please file an issue here. The most probable reason is an ungoing server maintenance, unlikely to last for more than a couple days.  

Alternatively, you can also access the app in your local machine. 

## New taxa addition

To propose a new taxon to be added in GAPeDNA, please file an issue labelled 'enhancement' in this repo stating the wanted group, and provide the necessary informations:

* Primers amplifying the taxon, or a list of species amplified by each primer if you already performed the virtual PCRs
* One or several global spatialized checklist with relevant resolution 

If the information is correct, the app will be updated to implement your suggestion. 

## Display the app

1) Using GitHub

You can load the app just by calling the GitHub repo in a local R session. At the moment, it takes a  long time to load (>5-10 min):

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

![grab-landing-page](https://github.com/virginiemarques/Gaps_shiny_quicktest/blob/master/README/Shiny_2.gif)
