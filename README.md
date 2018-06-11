# Apple Watch Exploratory Analysis

+ Contributors
	+ Raul Eulogio

+ Revisions and edits made by:
    + Brittany-Marie Swanson
    + [Ivana Gomez](https://www.linkedin.com/in/ivana-gomez-71ba04155)

This repository serves as a supplement to the exploratory analysis done in the `RforDataScienceCommunity` youtube channel. 

Shiny dashboard found [here](https://raviolli77.shinyapps.io/apple_watch_dashboard/#). 

For publishing purposes `rds` files must be contained in same directory as the [Shiny Dashboard](https://rstudio.github.io/shinydashboard/). 


## Running Project

Project runs on R <= 3.4, will not run on 3.5 due to many packages not yet supported by 3.5 (since it was recently released). 

For reproducibility, when starting this project open *Rstudio* and go to `File > Open Project in New Session...` as shown below

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/10_open_project.png" />


Upon doing this, the hidden file named `.Rprofile` will run automatically. Inside this file there is a call to run a file called `init.R` which was created by the `packrat` package. This will download all the dependencies with respect to packages.

**IMPORTANT TO NOTE**: There have been complaints about the `BH` package downloaded slowly within `packrat` unfortunately this might be the case when doing the previous command. The issue is still currently being discussed by maintainers of the `packrat` package. If the wait time to download remains significant, I might remove `packrat` in later iterations.

## Troubleshooting

If you receive the error below when first opening the Rproject, run the command in the screenshot ( `packrat::restore(prompt = FALSE)` ):

<img src="https://raw.githubusercontent.com/raviolli77/apple_watch_data_analysis/master/reports/figures/11_packrat_fix.png" />

After all files successfully downloaded, you should be able to run all scripts. Any questions please [reach out to me](https://www.linkedin.com/in/raul-eulogio/).


## Resources

+ [Programming with dplyr](https://dplyr.tidyverse.org/articles/programming.html)
+ Foschini Luca et. all - [Observation Time vs. Performance in Digital Phenotyping](https://evidation.com/wp-content/uploads/2017/10/observation-time-vs-performance-in-digital-phenotyping.pdf)
+ Ballinger Brandon  et. all - [Deep Heart: Semi-Supervised Sequence Learning for Cardiovascular Risk Prediction](https://arxiv.org/pdf/1802.02511.pdf)
+ Prabhakaran Selva - [Top 50 ggplot2 Visualizations - The Master List (With Full R Code)](http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html)
+ Thoen Edwin - [Tidy Evaluations, most commmon Actions](https://edwinth.github.io/blog/dplyr-recipes/)
