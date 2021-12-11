# covex

# Running Application Depolyment
### ShinyServer (Shinyapps.io)
### AWS workspace (http://3.93.125.130/shinyapps/apps/covex/app/)
### Github ( http://github.com/saurabhwhadgar/covex)
### Docker ()
# Running Application Locally
## Applicaiton Dependancies

|   |package_name           | Version|
|---|-----------------------|--------|
| 1 |DT                     | 0.19   |
| 2 |shiny                  | 1.7.1  |
| 3 |dplyr                  | 1.0.7  |
| 4 |tidyr                  | 1.1.4  |
| 5 |ggExtra                | 0.9    |
| 6 |plotly                 | 4.10.0 |
| 7 |ggplot2                | 3.3.5  |
| 8 |shinydashboard library | 0.7.2  |

## Understanding Project Repo
/data
> Includes data used for CoVEx

ui.R
> Contains User interface code

server.R
> Contains user input and output process, data transformation and some cool stuff to plot your graphs

global.R
> Read the data from CSVs and sourced into server file


## Running An application 
Once you statisfies all the dependencies, there are mutliple ways to run the program.
But for this tutorial will be using simple RStudio IDE way.

1. Open `ui.R` and `server.R` files in Rstudio
2. You would see `Run App` button (as shown in below figure) click on that
3. Select Run External option so it will open in your system's default browser.
![](https://www.garrickadenbuie.com/blog/shiny-tip-option-where-to-run/shiny-rstudio-run-in.png)

## Understanding CoVEx UI
Visit -> https://docs.google.com/presentation/d/1Bysdji-_bBaLtmxPrcJfWaufW6Uuzfbyyq1u0O3d3nI/edit#slide=id.p
