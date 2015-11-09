#### Credit
This repository will consist of only one file, which is the sankey.R file. The purpose of the project was to turn the already interactive sankey diagram provided in @ramnathv's [`rCharts`](https://github.com/ramnathv/rCharts) pacakge. The work accomplished here is based heavily on the work that was already done by a lot of people before me. @timelyportfolio's [work on the sankey diagram](https://github.com/timelyportfolio/rCharts_d3_sankey) specifically, along with some answers on StackOverflow, provided a LOT of assistance. [Mike Bostock](http://bost.ocks.org/mike/sankey/) was given some credit within the source code I used, so I'll give him credit here as well. 

#### Overview
Interactive charts are the new, cool way to visualize data. And for good reason. The issue, at least for me, is that those interactive charts make it difficult to turn visualizations into gifs, and I use gifs a lot to try to identify patterns in the data. As a result, I started this project and in the end I condensed everything down to a single HTML file that uses jquery and javascript to animate the graph over time. The animation provides an extra element of interactivity as the nodes/links can still be moved and the tooltips still generate. If you want to reduce the amount of interactivity and you don't want the animation, but want to change the color of the nodes and paths, or customize the tooltips, you can just set `gif = FALSE`. Or, if you just want the regular sankey diagram with nothing special, set `after_script = FALSE` as well. The code to edit the node/link colors is in the `.generate_after_js` function and should be relatively self explanatory. It currently requires two different colors - one for points of interest and one for everything else - but this can be tweaked to take a vector of colors as well. The code to change the tooltips can be found in the `.generate_main_js` function via the `node_tooltip` and `link_tooltip` parameters. These parameters expect javascript-readable strings.

When I first started writing the code for this, I didn't really anticipate putting it on Github because I didn't think it'd transition well to other use cases. But now that it's done, I figure it can at least inspire some work on other interactive visualizations. If you've got any questions or comments, feel free to post them in the Issues section. 

#### Example
``` {r}
dat <- data.frame("source" = c("Z", "Z", "o", "o", "o", "Z", "X", "m", "d", 
                               "m", "R", "R", "k", "F", "s", "X", "B", "O", 
                               "v", "B", "B", "B", "B", "t", "B", "B", "B", 
                               "i", "D", "u", "T", "T", "j", "n", "H", "H", 
                               "J", "n", "Q", "j", "C", "C", "E", "g", "q", 
                               "x", "K", "T", "A", "g", "U", "o", "o", "o",
                               "o", "o", "o", "o", "o", "o", "o", "o", "o", 
                               "o", "o", "o", "o", "o", "o", "o", "o", "o", 
                               "o", "o", "o", "o", "o", "Z", "Z", "Z", "Z", 
                               "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", 
                               "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", 
                               "Z", "Z", "Z"),
                  "target" = c("N", "N", "M", "L", "Z", "Y", "o", "Z", "m", "Z", 
                           "o", "o", "F", "o", "o", "o", "Z", "Z", "Z", "Z", 
                           "Z", "Z", "Z", "Z", "o", "o", "o", "Z", "o", "o", 
                           "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", 
                           "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", 
                           "o", "W", "W", "W", "W", "W", "W", "f", "W", "W", 
                           "W", "W", "e", "c", "W", "p", "z", "W", "W", "W", 
                           "W", "W", "S", "W", "W", "W", "W", "z", "z", "z", 
                           "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", 
                           "z", "z", "z", "z", "z", "z", "z", "z", "N", "N", 
                           "N", "Y"),
                  "value" = c("90220.88", "82000", "22947", "11744", "14000", 
                              "17400", "36300", "34987.39", "34987.39", "4300", 
                              "10000", "10000", "17600", "17600", "6000", "10000", 
                              "14325", "6451.46", "800", "7500", "29450", "9950", 
                              "8990", "800", "4400", "1200", "1200", "5775", "3800", 
                              "119959", "8000", "8000", "7974", "9975", "1000", "1000", 
                              "10000", "5975", "9973", "7974", "24968", "35768", "10000", 
                              "10000", "15000", "14975", "6600", "13000", "10000", "2000", 
                              "8450", "850", "4000", "4930", "569", "2653", "4848", "18000", 
                              "2752", "16408", "3142", "1009", "24000", "7700", "1899", "7270", 
                              "57000", "3132", "2858", "13829", "2844", "1680", "144450", 
                              "10409", "3693", "3182", "4913", "64641.34", "43522.2", "51000", 
                              "24000", "1845", "52000", "70000", "72000", "40000", "41380", 
                              "8870", "14565", "20000", "12810", "22000", "12700", "26300", 
                              "52970", "5897.45", "37000", "40328.05", "133141.72", "74872.76", 
                              "74068.3", "5215"),
                  "date" = c("07/30/14", "03/26/14", "10/07/14", "09/29/14", "04/22/14", "06/19/14", 
                             "01/28/15", "04/24/14", "04/24/14", "04/24/14", "08/03/14", "09/03/14", 
                             "06/13/14", "06/03/14", "01/16/15", "01/14/15", "09/25/14", "10/22/14", 
                             "10/22/14", "10/23/14", "02/18/14", "03/19/14", "06/23/14", "06/21/14", 
                             "03/25/14", "09/25/14", "12/03/14", "02/05/15", "01/17/14", "01/22/14", 
                             "02/09/15", "02/02/15", "02/04/15", "01/24/14", "08/01/14", "08/04/14", 
                             "05/02/14", "01/28/14", "04/29/14", "01/28/15", "09/02/14", "09/02/14", 
                             "09/02/14", "10/09/14", "08/29/14", "10/09/14", "12/29/14", "01/26/15", 
                             "11/28/14", "10/22/14", "11/03/14", "04/16/14", "04/22/14", "04/30/14", 
                             "02/12/14", "02/14/14", "04/11/14", "05/23/14", "06/24/14", "08/07/14", 
                             "08/12/14", "06/05/14", "06/09/14", "06/17/14", "12/31/14", "01/23/15", 
                             "02/03/15", "08/19/14", "09/25/14", "11/07/14", "01/02/14", "01/15/14", 
                             "01/23/14", "01/28/14", "01/03/14", "01/08/14", "01/14/14", "12/05/14", 
                             "01/09/15", "09/09/14", "08/19/14", "03/11/14", "02/14/14", "01/03/14", 
                             "02/05/14", "02/27/14", "03/06/14", "05/14/14", "04/18/14", "04/23/14", 
                             "04/08/14", "04/25/14", "03/24/14", "06/05/14", "07/08/14", "05/06/14", 
                             "10/30/14", "10/14/14", "06/23/14", "11/17/14", "05/30/14", "05/14/14"),
                  stringsAsFactors = FALSE)

generate_html(dat, targets = c("o", "Z", "F"), graph_title = "My Cool Animated Sankey Diagram!")
```

A live demo can also be viewed [here](http://45.55.233.87/shiny/sankey).
