.create_dir_skeleton <- function(package_dir = "C:/Playground/R-3.2.2/library/rCharts/libraries/rCharts_d3_sankey/") {
  if (!dir.exists("www")) {
    dir.create("www")
    dir.create("www/js")
    dir.create("www/css")
  } else {
    if (!dir.exists("www/js")) dir.create("www/js")
    if (!dir.exists("www/css")) dir.create("www/css")
  }
  
  file.copy(from = sprintf("%s/css/sankey.css", package_dir), to = "www/css/sankey.css")
  #file.copy(from = sprintf("%s/js/d3.v3.js", package_dir), to = "www/js/d3.v3.js")
  file.copy(from = sprintf("%s/js/sankey.js", package_dir), to = "www/js/sankey.js")
}

.generate_main_js <- function(data, chart_id = "sankey", width = 1200, height = 800, node_width = 15, node_padding = 10, layout = 32, 
                            units = "", node_tooltip = NULL, link_tooltip = NULL, destfile = "www/js/main.js") {
  
  if (is.null(node_tooltip)) node_tooltip <- 'd.name + "\\n$" + format(d.value);'
  if (is.null(link_tooltip)) link_tooltip <- 'd.source.name + " sent $" + format(d.value) + " to " + d.target.name + " on " + d.date;'
  
  src <- sprintf('"%s"', data$source) %>% paste(collapse = ", ")
  target <- sprintf('"%s"', data$target) %>% paste(collapse = ", ")
  value <- sprintf('"%s"', data$value) %>% paste(collapse = ", ")
  date <- sprintf('"%s"', data$date) %>% paste(collapse = ", ")
  data_json <- sprintf('{"source": [%s],
                        "target": [%s],
                        "value": [%s],
                        "date": [%s]}', src, target, value, date)
  js <- sprintf('
  (function(){
    var params = {
      "dom": "sankey",
      "width": %d,
      "height": %d,
      "data": %s,
      "nodeWidth": %d,
      "nodePadding": %d,
      "layout": %d,
      "units": "%s",
      "id": "sankey" 
    };
    
    params.units ? units = " " + params.units : units = "";
    
    //hard code these now but eventually make available
    var formatNumber = d3.format("0,.0f"),    // zero decimal places
    format = function(d) { return formatNumber(d) + units; },
    color = d3.scale.category20();
    
    if(params.labelFormat){
      formatNumber = d3.format(".2%%");
    }
    
    var svg = d3.select("#" + params.id).append("svg")
      .attr("width", params.width)
      .attr("height", params.height);
    
    var sankey = d3.sankey()
      .nodeWidth(params.nodeWidth)
      .nodePadding(params.nodePadding)
      .layout(params.layout)
      .size([params.width,params.height]);
    
    var path = sankey.link();
    
    var data = params.data,
      links = [],
      nodes = [];
    
    //get all source and target into nodes
    //will reduce to unique in the next step
    //also get links in object form
    data.source.forEach(function (d, i) {
      nodes.push({ "name": data.source[i] });
      nodes.push({ "name": data.target[i] });
      links.push({ "source": data.source[i], "target": data.target[i], "value": +data.value[i], "date": data.date[i] });
    }); 
    
    //now get nodes based on links data
    //thanks Mike Bostock https://groups.google.com/d/msg/d3-js/pl297cFtIQk/Eso4q_eBu1IJ
    //this handy little function returns only the distinct / unique nodes
    nodes = d3.keys(d3.nest()
                    .key(function (d) { return d.name; })
                    .map(nodes));
    
    //it appears d3 with force layout wants a numeric source and target
    //so loop through each link replacing the text with its index from node
    links.forEach(function (d, i) {
      links[i].source = nodes.indexOf(links[i].source);
      links[i].target = nodes.indexOf(links[i].target);
    });
    
    //now loop through each nodes to make nodes an array of objects rather than an array of strings
    nodes.forEach(function (d, i) {
      nodes[i] = { "name": d };
    });
    
    sankey
      .nodes(nodes)
      .links(links)
      .layout(params.layout);
    
    var link = svg.append("g").selectAll(".link")
      .data(links)
      .enter().append("path")
      .attr("class", "link")
      .attr("d", path)
      .style("stroke-width", function (d) { return Math.max(1, d.dy); })
      .sort(function (a, b) { return b.dy - a.dy; });
    
    link.append("title")
      .text(function (d) { return %s });
    
    var node = svg.append("g").selectAll(".node")
    .data(nodes)
    .enter().append("g")
    .attr("class", "node")
    .attr("transform", function (d) { return "translate(" + d.x + "," + d.y + ")"; })
    .call(d3.behavior.drag()
          .origin(function (d) { return d; })
          .on("dragstart", function () { this.parentNode.appendChild(this); })
          .on("drag", dragmove));
    
    node.append("rect")
      .attr("height", function (d) { return d.dy; })
      .attr("width", sankey.nodeWidth())
      .style("fill", function (d) { return d.color = color(d.name.replace(/ .*/, "")); })
      .style("stroke", function (d) { return d3.rgb(d.color).darker(2); })
      .append("title")
      .text(function (d) { return %s });
    
    node.append("text")
      .attr("x", -6)
      .attr("y", function (d) { return d.dy / 2; })
      .attr("dy", ".35em")
      .attr("text-anchor", "end")
      .attr("transform", null)
      .text(function (d) { return d.name; })
      .filter(function (d) { return d.x < params.width / 2; })
      .attr("x", 6 + sankey.nodeWidth())
      .attr("text-anchor", "start");
    
    // the function for moving the nodes
    function dragmove(d) {
      d3.select(this).attr("transform", 
                           "translate(" + (
                             d.x = Math.max(0, Math.min(params.width - d.dx, d3.event.x))
                           ) + "," + (
                             d.y = Math.max(0, Math.min(params.height - d.dy, d3.event.y))
                           ) + ")");
      sankey.relayout();
      link.attr("d", path);
    }
  })();', width, height, data_json, node_width, node_padding, layout, units, link_tooltip, node_tooltip)
  writeLines(text = js, con = destfile)
}

.generate_gif_js <- function(data, targets, delay = 2, destfile = "www/js/gif.js") {
  data$path <- apply(data, 1, function(row) {
    if (row[1] %in% targets) {
      return(sprintf("%s %s %s", row[1], row[2], row[4]))
    } else {
      return(sprintf("%s %s %s", row[2], row[1], row[4]))
    }
  }) %>% unlist() %>% unname()
  
  dates <- data$date %>% as.Date(format = "%m/%d/%y") %>% unique() %>% sort() %>% as.character()
  events_array <- vector("character")
  
  entities <- c(data$source, data$target) %>% unique()
  for (i in 1:length(dates)) {
    tmp <- data %>% filter(as.Date(date, format = "%m/%d/%y") == dates[i])
    highlight <- c(tmp$source, tmp$target) %>% unique()
    
    node_colors <- sapply(entities, function(entity) {
      if (entity %in% highlight) {
        if (entity %in% targets) {
          return(sprintf('"%s": "#FF6A6A"', entity))
        } else {
          return(sprintf('"%s": "#90EE90"', entity))
        }
      } else {
        return(sprintf('"%s": "#F7F7F7"', entity))
      }
    }) %>% unlist() %>% unname()
    
    node_colors <- paste(node_colors, collapse = ", ")
    
    text_colors <- sapply(entities, function(entity) {
      if (entity %in% highlight) {
        return(sprintf('"%s": "#000000"', entity))
      } else {
        return(sprintf('"%s": "#F7F7F7"', entity))
      }
    }) %>% unlist() %>% unname()
    
    text_colors <- paste(text_colors, collapse = ", ")
    
    link_colors <- apply(data, 1, function(row) {
      if (as.Date(row[4], format = "%m/%d/%y") == dates[i]) {
        return(sprintf('"%s": "#66CCFF"', row[5])) 
      } else {
        return(sprintf('"%s": "#F7F7F7"', row[5]))
      }
    }) %>% unlist() %>% unname()
    
    link_colors <- paste(link_colors, collapse = ", ")
      
    event <- sprintf('%d: {"node_colors": {%s}, "text_colors": {%s}, "link_colors": {%s}}', (i - 1), node_colors, text_colors, link_colors)
    events_array <- c(events_array, event)
  }
  
  n <- length(events_array)
  events <- paste(events_array, collapse = ", ") %>% {sprintf("{%s}", .)}
  targets <- sprintf('"%s"', targets) %>% paste(collapse = ", ")
  
  gif <- sprintf('
  $(function() {
    var selector = $("#sankey");
    var delay_sec = %d;
    var num = -1, 
    len = %d;
    var step_counter = 0;
    var threshold = 0;
    var height = 0;
    var timer = null;
    var events = %s;
    var targets = [%s];
    
    function reset() {
      stop();
      num = 0;
      threshold = 0;
      height = 0;
      delay_sec = 2;
      d3.selectAll("#sankey svg .node rect")
        .style("fill", function(d) { return (targets.indexOf(d.name) > -1) ? "#FF6A6A" : "#90EE90" })
        .style("stroke", function(d) { return (targets.indexOf(d.name) >= 0) ? "#FF6A6A" : "#90EE90" })
      $("#sankey svg .node text").css("fill", "#000000");
      $("#sankey svg path.link").css("stroke", "#66CCFF");
      $("#events").animate({scrollTop: 0}, "fast");
    };

    function blank_graph() {
      $("#sankey svg .node rect").css("fill", "#F7F7F7").css("stroke", "#F7F7F7");
      $("#sankey svg .node text").css("fill", "#F7F7F7");
      $("#sankey svg path.link").css("stroke", "#F7F7F7");
      $("#events").animate({scrollTop: 0}, "fast");
      $("#events").children().css("color", "#000000");
    };

    function event(num, scroll = true) {
      if (num === -1) {
        threshold = 0;
        height = 0;
        blank_graph();
      } else {
        $("#events").children().css("color", "#000000");
        d3.selectAll("#sankey svg .node rect")
          .style("fill", function(d) { return events[num]["node_colors"][d.name] })
          .style("stroke", function(d) { return events[num]["node_colors"][d.name] })
        d3.selectAll("#sankey svg .node text")
          .style("fill", function(d) { return events[num]["text_colors"][d.name] })
        d3.selectAll("#sankey svg path.link")
          .style("stroke", function (d) {
            if (targets.indexOf(d.source.name) > -1) {
              var path = d.source.name + " " + d.target.name + " " + d.date;
              return events[num]["link_colors"][path];
            } else {
              var path = d.target.name + " " + d.source.name + " " + d.date;
              return events[num]["link_colors"][path];
            }
          });
        $("#events h3:nth-of-type(" + (num + 1) + ")").css("color", "#FF6A6A");
        $("#events p:nth-of-type(" + (num + 1) + ")").css("color", "#FF6A6A");
        if (scroll) {
          threshold += ($("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true));
          if (threshold >= 795) {
            height += $("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true);
            $("#events").animate({scrollTop: height}, "slow");
          }
        } else {
          if (step_counter === 1) {
            threshold = 795 - ($("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true));
          } else {
            threshold -= ($("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true));
          }
        }
      }
    }

    function loop() {
      num = (num === len) ? -1 : num;
      event(num);
      num++;
      start();
    };

    function start() {
      timer = setTimeout(loop, (delay_sec * 1000));
    };

    function stop() {
      clearTimeout(timer);
    };

    function forward() {
      stop();
      num += 1;
      step_counter -= 1;
      step_counter = (step_counter < 0) ? 0 : step_counter;
      event(num);
    };

    function backward() {
      stop();
      num -= 1;
      step_counter += 1;
      
      event(num, false);
    };

    function speed_up() {
      stop();
      delay_sec -= .2;
      delay_sec = (delay_sec <= 0) ? 1 : delay_sec;
      start();
    };

    function speed_down() {
      stop();
      delay_sec += .2;
      delay_sec = (delay_sec > 10) ? 10 : delay_sec;
      start();
    }

    $("#start").on("click", start);
    $("#stop").on("click", stop);
    $("#step-forward").on("click", forward);
    $("#step-back").on("click", backward);
    $("#speed-up").on("click", speed_up);
    $("#speed-down").on("click", speed_down);
    $("#reset").on("click", reset);
  });', delay, n, events, targets)
  writeLines(text = gif, con = destfile)
}
                 
.generate_after_js <- function(data, targets, target_color = "#FF6A6A", non_target_color = "#90EE90", 
                              link_color = "#66CCFF", destfile = "www/js/after.js") {
  entities <- unique(c(data$source, data$target))
  target_color <- col2hex(target_color)
  non_target_color <- col2hex(non_target_color)
  
  json = vector()
  for (entity in entities) {
    if (entity  %in% targets) {
      json <- c(json, sprintf('"%s": "%s"', entity, target_color))
    } else {
      json <- c(json, sprintf('"%s": "%s"', entity, non_target_color))
    }
  }
  json <- paste(json, collapse = ", ")
  
  js <- sprintf('
    var node_colors = JSON.parse(\'{%s}\');
    d3.selectAll("#sankey svg .node rect")
      .style("fill", function(d) { return node_colors[d.name] })
      .style("stroke", function(d) { d3.rgb(node_colors[d.name]).darker(2); })

    d3.selectAll("#sankey svg .node rect title")
      .style("color", "#FF6A6A")
  
    d3.selectAll("#sankey svg path.link")
      .style("stroke", function(d) { return "%s" })', json, link_color)
  
  writeLines(text = js, con = destfile)
}

.generate_events_array <- function(data) {
  dates <- data$date %>% as.Date(format = "%m/%d/%y") %>% unique() %>% sort() %>% as.character()
  events_array <- vector("character")
  
  for (d in dates) {
    tmp <- data %>% filter(as.Date(date, format = "%m/%d/%y") == d)
    events <- apply(tmp, 1, function(row) sprintf("+ %s sends %s $%s", row[1], row[2], format(row[3], big.mark = ","))) %>% unlist()
    events <- paste(events, collapse = "<br>")
    events_array_elem <- sprintf('"<h3 style = \'padding: 0px; margin: 0px;\'>%s</h3><p style = \'margin: 3px 0px 10px 15px; font-size: small;\'>%s</p>"',
                                 as.character(d),
                                 events)
    events_array <- c(events_array, events_array_elem)
  }
  events_array <- paste(events_array, collapse = ", ") %>% {sprintf("[%s]", .)}
  return(events_array)
}
  
generate_html <- function(data, targets, graph_title, page_title = "Sankey Diagram", after_script = TRUE, gif = TRUE, dir = ".", destfile = "index.html") {
  if (!all(c("source", "target", "value", "date") %in% names(data))) stop("Your data doesn't look right. You should have a source, target, value, and date column.")
  if (!require(magrittr)) stop("I know it's a faux pas, but the pip is far too amazing to not use. As a result, the magrittr package does need to be installed for this code to work.")
  
  .create_dir_skeleton()
  .generate_main_js(data)
  .generate_after_js(data, targets)
  .generate_gif_js(data, targets)
  
  events <- .generate_events_array(data)
  sankey <- readr::read_lines("www/js/sankey.js") %>% paste(collapse = "\n")
  main <- readr::read_lines("www/js/main.js") %>% paste(collapse = "\n")
  after <- readr::read_lines("www/js/after.js") %>% paste(collapse = "\n")
  gif <- readr::read_lines("www/js/gif.js") %>% paste(collapse = "\n")
  
  html <- sprintf('
                  <!DOCTYPE HTML>
                  <html>
                  <head>
                  <meta charset = "utf-8">
                  <script type = "text/javascript" src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
                  <script type = "text/javascript" src = "http://code.jquery.com/jquery-latest.min.js"></script>
                  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
                  <style>
                    .node rect {
                      cursor: move;
                      fill-opacity: .9;
                      shape-rendering: crispEdges;
                    }

                    .node text {
                      pointer-events: none;
                      text-shadow: 0 1px 0 #fff;
                    }
                    
                    .link {
                      fill: none;
                      stroke: #000;
                      stroke-opacity: .2;
                    }
                    
                    .link:hover {
                      stroke-opacity: .5;
                    }
                    
                    svg {
                      font: 10px sans-serif;
                    }
                  </style>
                  <style>
                    .rChart {
                      display: block;
                      margin-left: auto;
                      margin-right: auto;
                      width: 1200px;
                      height: 1000px;
                    }

                    #sankey {
                    width: 80%%;
                    height: 800px;
                    float: left;
                    }
                    
                    #events {
                    width: 19%%;
                    float: left;
                    font-size: small;
                    height: 800px;
                    overflow: auto;
                    }
                    
                    #controls {
                    width: 80%%;
                    display: block;
                    margin-top: 30px;
                    margin-left: auto;
                    margin-right: auto;
                    float: left;
                    }
                    
                    svg {
                    height: 1100px;
                    }
                    
                    .divider {
                    width: 5px;
                    height: auto;
                    display: inline-block;
                    }
                  </style>
                  <script>
                    %s
                  </script>
                  
                  <title>%s</title>
                  </head>
                  
                  <body>
                  <div style = "text-align: center;"><h1>%s</h1></div>
                  <div>
                  <div id = "sankey" class = "rChart rCharts_d3_sankey" align = "center"></div>
                  <div id = "events">
                  <script>
                  $(function() {
                  var events = %s;
                  for (i = 0; i < events.length; i++) {
                  $("#events").append(events[i]);
                  }
                  });
                  </script>
                  </div>
                  </div>
                  <div id = "controls" align = "center">
                  <h4>Use the buttons to below to control the animation</h4>
                  <button type = "button" class = "btn" id = "start">
                    <i class = "fa fa-play fa-2x"></i>
                  </button>
                  <button type = "button" class = "btn" id = "stop">
                    <i class = "fa fa-stop fa-2x"></i>
                  </button>
                  <button type = "button" class = "btn" id = "step-back">
                    <i class = "fa fa-step-backward fa-2x"></i>
                  </button>
                  <button type = "button" class = "btn" id = "step-forward">
                    <i class = "fa fa-step-forward fa-2x"></i>
                  </button>
                  <div class = "divider"></div>
                  <button type = "button" class = "btn" id = "speed-down">
                    <i class = "fa fa-minus fa-2x"></i>
                  </button>
                  <button type = "button" class = "btn" id = "speed-up">
                    <i class = "fa fa-plus fa-2x"></i>
                  </button>
                  <div class = "divider"></div>
                  <button type = "button" class = "btn" id = "reset">
                    <i class = "fa fa-rotate-left fa-2x"></i>
                  </button>
                  </div>
                  <script>
                    %s
                  </script>
                  <script>
                    %s
                  </script>
                  <script>
                    %s
                  </script>
                  </body>
                  </html>', sankey, page_title, graph_title, events, main, after, gif)
  writeLines(text = html, con = destfile)
}
  
  
  
  
  
  
