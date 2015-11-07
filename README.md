#### Credit
This repository will consist of only one file, which is the sankey.R file. The purpose of the project was to turn the already interactive sankey diagram provided in @ramnathv's [`rCharts`](https://github.com/ramnathv/rCharts) pacakge. The work accomplished here is based heavily on the work that was already done by a lot of people before me. @timelyportfolio's [work on the sankey diagram](https://github.com/timelyportfolio/rCharts_d3_sankey) specifically, along with some answers on StackOverflow, provided a LOT of assistance. [Mike Bostock](http://bost.ocks.org/mike/sankey/) was given some credit within the source code I used, so I'll give him credit here as well. 

#### Overview
Interactive charts are the new, cool way to visualize data. And for good reason. The issue, at least for me, is that those interactive charts make it difficult to turn visualizations into gifs, and I use gifs a lot to try to identify patterns in the data. As a result, I started this project and in the end I condensed everything down to a single HTML file that uses jquery and javascript to animate the graph over time. The animation provides an extra element of interactivity as the nodes/links can still be moved and the tooltips still generate. If you want to reduce the amount of interactivity and you don't want the animation, but want to change the color of the nodes and paths, or customize the tooltips, you can just set `gif = FALSE`. Or, if you just want the regular sankey diagram with nothing special, set `after_script = FALSE` as well. The code to edit the node/link colors is in the `.generate_after_js` function and should be relatively self explanatory. It currently requires two different colors - one for points of interest and one for everything else - but this can be tweaked to take a vector of colors as well. The code to change the tooltips can be found in the `.generate_main_js` function via the `node_tooltip` and `link_tooltip` parameters. These parameters expect javascript-readable strings.

When I first started writing the code for this, I didn't really anticipate putting it on Github because I didn't think it'd transition well to other use cases. But now that it's done, I figure it can at least inspire some work on other interactive visualizations. If you've got any questions or comments, feel free to post them in the Issues section. 
