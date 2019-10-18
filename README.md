# Temporary access to GAPeDNA 

This repo allows sharing and testing of our web-app interface investigating database gaps in eDNA.
After paper acceptance, the app will be deposited on a server for easy access thought a web link. 

## Display the app

1) Using GitHub

You can load the app just by calling the GitHub repo in a local R session. At the moment, it takes a  long time to load (>5-10 min):

```R
library('shiny')
runGitHub("Gaps_shiny_quicktest", "virginiemarques")
```

2) On your local computer

Alternatively, you first need to download the repo, then launch R. Here are the command to run on the terminal (Linux/Mac only):

```bash
git clone https://github.com/virginiemarques/Gaps_shiny_quicktest
cd Gaps_shiny_quicktest/
R
```

After, you need to load `shiny` to run the app in local inside a R session:

```R
library('shiny')
runApp()
```

## Demonstration

![grab-landing-page](https://github.com/virginiemarques/Gaps_shiny_quicktest/blob/master/README/Shiny_2.gif)
