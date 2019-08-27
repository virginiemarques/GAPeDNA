# Quick test for shiny app

This repo allows sharing and testing of our shiny-app investigating database gaps in eDNA.

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
