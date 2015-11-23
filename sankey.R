.generate_main_js <- function(data, chart_id = "sankey", node_width = 15, node_padding = 10, layout = 32, 
                            units = "", node_tooltip = NULL, link_tooltip_fw = NULL, link_tooltip_bw = NULL) {
  
  if (is.null(node_tooltip)) node_tooltip <- 'd.name + "\\n$" + format(d.value);'
  if (is.null(link_tooltip_fw)) {
    link_tooltip_fw <- 'd.source.name + " sent $" + d.value + " to " + d.target.name + " on " + d.date'
    if ("reverse" %in% tolower(names(data))) {
      link_tooltip_bw <- 'd.target.name + " sent $" + d.value + " to " + d.source.name + " on " + d.date'
    } else {
      link_tooltip_bw <- link_tooltip_fw
    }
  }
  
  src <- sprintf('"%s"', data$source) %>% paste(collapse = ", ")
  target <- sprintf('"%s"', data$target) %>% paste(collapse = ", ")
  value <- sprintf('"%s"', data$value) %>% paste(collapse = ", ")
  date <- sprintf('"%s"', data$date) %>% paste(collapse = ", ")
  reverse <- sprintf('"%s"', data$reverse) %>% paste(collapse = ", ")
  data_json <- sprintf('{"source": [%s],
                        "target": [%s],
                        "value": [%s],
                        "date": [%s],
                        "reverse": [%s]}', src, target, value, date, reverse)
  js <- sprintf('
  (function(){
    var width = $(window).width() * .78;
    var height = $(window).height() * .75;
    var params = {
      "dom": "sankey",
      "width": width,
      "height": height,
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
      links.push({ "source": data.source[i], "target": data.target[i], "value": +data.value[i], "date": data.date[i], "reverse": data.reverse[i] });
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
      .text(function (d) { return(d.reverse === "1" ? %s : %s) });
    
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
  })();', data_json, node_width, node_padding, layout, units, link_tooltip_bw, link_tooltip_fw, node_tooltip)
  return(js)
}

.generate_gif_js <- function(data, targets, delay = 2) {
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
      if ("reverse" %in% names(data)) {
        if (as.Date(row[4], format = "%m/%d/%y") == dates[i]) {
          if (row[5] == 1) {
            return(sprintf('"%s": "#A020F0"', row[6]))
          } else {
           return(sprintf('"%s": "#66CCFF"', row[6])) 
          }
        } else {
          return(sprintf('"%s": "#F7F7F7"', row[6]))
        }
      } else {
        if (as.Date(row[4], format = "%m/%d/%y") == dates[i]) {
          return(sprintf('"%s": "#66CCFF"', row[5]))
        } else {
          return(sprintf('"%s": "#F7F7F7"', row[5]))
        }
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
      d3.selectAll("#sankey svg path.link")
        .style("stroke", function(d) { console.log(d.reverse); return(d.reverse === "1" ? "#A020F0" : "#66CCFF") })
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
          if (threshold >= ($("#events").height() - 5)) {
            height += $("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true);
            $("#events").animate({scrollTop: height}, "slow");
          }
        } else {
          if (step_counter === 1) {
            threshold = ($("#events").height() - 5) - ($("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true));
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
  return(gif)
}
                 
.generate_after_js <- function(data, targets, target_color = "#FF6A6A", non_target_color = "#90EE90") {
  entities <- unique(c(data$source, data$target))
  
  if ("reverse" %in% names(data)) {
    link_colors <- ifelse(data$reverse == 1, "#A020F0", "#66CCFF")
  } else {
    link_colors <- "#66CCFF"
  }
  link_colors <- sapply(1:nrow(data), function(i) paste(data$source[i], data$target[i], data$date[i]) %>% {sprintf('"%s": "%s"', ., link_colors[i])}) %>% unlist() %>% unname()
  link_colors <- paste(link_colors, collapse = ", ")
  
  json = vector()
  for (entity in entities) {
    if (entity  %in% targets) {
      json <- c(json, sprintf('"%s": "%s"', entity, target_color))
    } else {
      json <- c(json, sprintf('"%s": "%s"', entity, non_target_color))
    }
  }
  node_colors <- paste(json, collapse = ", ")
  
  js <- sprintf('
    var node_colors = JSON.parse(\'{%s}\');
    var link_colors = JSON.parse(\'{%s}\');
    d3.selectAll("#sankey svg .node rect")
      .style("fill", function(d) { return node_colors[d.name] })
      .style("stroke", function(d) { d3.rgb(node_colors[d.name]).darker(2); })

    d3.selectAll("#sankey svg .node rect title")
      .style("color", "#FF6A6A")
  
    d3.selectAll("#sankey svg path.link")
      .style("stroke", function(d) { return link_colors[d.source.name + " " + d.target.name + " " + d.date] })', node_colors, link_colors)
  
  return(js)
}

.generate_events_array <- function(data) {
  dates <- data$date %>% as.Date(format = "%m/%d/%y") %>% unique() %>% sort() %>% as.character()
  events_array <- vector("character")
  
  for (d in dates) {
    tmp <- data %>% filter(as.Date(date, format = "%m/%d/%y") == d)
    tmp$value <- format(tmp$value, big.mark = ",")
    events <- apply(tmp, 1, function(row) {
      if ("reverse" %in% names(data)) {
        if (row[5] == 1) {
          return(sprintf("+ %s sends %s $%s", row[2], row[1], row[3]))
        } else {
          return(sprintf("+ %s sends %s $%s", row[1], row[2], row[3]))
        }
      } else {
        return(sprintf("+ %s sends %s $%s", row[1], row[2], row[3]))
      }
    }) %>% unlist()
    events <- paste(events, collapse = "<br>")
    events_array_elem <- sprintf('"<h3 style = \'padding: 0px; margin: 0px;\'>%s</h3><p style = \'margin: 3px 0px 10px 15px; font-size: small;\'>%s</p>"',
                                 as.character(d),
                                 events)
    events_array <- c(events_array, events_array_elem)
  }
  events_array <- paste(events_array, collapse = ", ") %>% {sprintf("[%s]", .)}
  return(events_array)
}

.reverse_paths <- function(data) {
  if (!"reverse" %in% names(data)) {
    reverse <- sapply(2:nrow(data), function(i) {
      j <- 1:(i - 1)
      row <- c(data$source[i], data$target[i])
      if (data$target[i] %in% data$source[j]) {
        k <- which(data$source[j] == data$target[i])
        if (any(data$source[i] %in% data$target[k])) {
          row_duplicated <- data[j, ] %>% filter(source == row[1] & target == row[2]) %>% nrow()
          if (row_duplicated) {
            dupe <- which(data$source[j] %in% row[1] & data$target[j] %in% row[2]) %>% min()
            rev <- which(data$target[j] %in% row[1] & data$source[j] %in% row[2]) %>% min()
            if (dupe < rev) {
              reverse <- 0
            } else {
              reverse <- 1
            }
          } else {
            reverse <- 1
          } 
        } else {
          reverse <- 0
        }
      } else {
        reverse <- 0
      }
      return(reverse)
    }) %>% unlist() %>% unname()
    data$reverse <- c(0, reverse)
  }
  data <- lapply(1:nrow(data), function(i) {
    if (data$reverse[i] == 1) {
      data <- data[i, c(2, 1, 3:5)]
      names(data) <- c("source", "target", "value", "date", "reverse")
      return(data)
    } else {
      return(data[i, ])
    }
  }) %>% plyr::rbind.fill()
  return(data)
}
  
generate_html <- function(data, targets, graph_title, page_title = "Sankey Diagram", after_script = TRUE, gif = TRUE, dir = ".", allow_circular_paths = TRUE, destfile = "index.html") {
  if (!all(c("source", "target", "value", "date") %in% names(data))) stop("Your data doesn't look right. You should have a source, target, value, and date column.")
  if (!require(dplyr)) stop("I know it's a faux pas, but dplyr is far too amazing to not use. As a result, the package does need to be installed for this code to work.")
  
  if (allow_circular_paths) data <- .reverse_paths(data)
  events <- .generate_events_array(data)
  main <- .generate_main_js(data)
  after <- .generate_after_js(data, targets)
  gif <- .generate_gif_js(data, targets)
  
  html <- paste('
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
                      width: 80%;
                      height: 100%;
                    }

                    #sankey {
                      width: 80%;
                      float: left;
                    }
                    
                    #events {
                      width: 19%;
                      float: left;
                      font-size: small;
                      overflow: auto;
                    }

                    #events h3 {
                      font-size: 12px;
                      font-weight: bold;
                    }

                    #events p {
                      font-size: 10px;
                    }
                    
                    #controls {
                      width: 80%;
                      height: auto;
                      display: block;
                      margin-top: 10px;
                      margin-left: auto;
                      margin-right: auto;
                      float: left;
                    }
                    
                    svg {
                      height: 100%;
                    }
                    
                    .divider {
                      width: 5px;
                      height: auto;
                      display: inline-block;
                    }
          
                    footer {
                      width: 100%;
                      float: left;
                      font-size: small;
                      text-align: left;
                      margin-top: 10px;
                    }
                    
                  </style>
                  <script>
                    d3.sankey = function() {
                      var sankey = {},
                      nodeWidth = 24,
                      nodePadding = 8,
                      size = [1, 1],
                      nodes = [],
                      links = [];
                  
                      sankey.nodeWidth = function(_) {
                        if (!arguments.length) return nodeWidth;
                        nodeWidth = +_;
                        return sankey;
                      };
                  
                      sankey.nodePadding = function(_) {
                        if (!arguments.length) return nodePadding;
                        nodePadding = +_;
                        return sankey;
                      };
                  
                      sankey.nodes = function(_) {
                        if (!arguments.length) return nodes;
                        nodes = _;
                        return sankey;
                      };
                  
                      sankey.links = function(_) {
                        if (!arguments.length) return links;
                        links = _;
                        return sankey;
                      };
                  
                      sankey.size = function(_) {
                        if (!arguments.length) return size;
                        size = _;
                        return sankey;
                      };
                  
                      sankey.layout = function(iterations) {
                        computeNodeLinks();
                        computeNodeValues();
                        computeNodeBreadths();
                        computeNodeDepths(iterations);
                        computeLinkDepths();
                        return sankey;
                      };
                  
                      sankey.relayout = function() {
                        computeLinkDepths();
                        return sankey;
                      };
                  
                      sankey.link = function() {
                        var curvature = .5;
                  
                        function link(d) {
                          var x0 = d.source.x + d.source.dx,
                          x1 = d.target.x,
                          xi = d3.interpolateNumber(x0, x1),
                          x2 = xi(curvature),
                          x3 = xi(1 - curvature),
                          y0 = d.source.y + d.sy + d.dy / 2,
                          y1 = d.target.y + d.ty + d.dy / 2;
                          return "M" + x0 + "," + y0
                          + "C" + x2 + "," + y0
                          + " " + x3 + "," + y1
                          + " " + x1 + "," + y1;
                        }
                  
                        link.curvature = function(_) {
                          if (!arguments.length) return curvature;
                          curvature = +_;
                          return link;
                        };
                  
                        return link;
                      };
                  
                      // Populate the sourceLinks and targetLinks for each node.
                      // Also, if the source and target are not objects, assume they are indices.
                      function computeNodeLinks() {
                        nodes.forEach(function(node) {
                          node.sourceLinks = [];
                          node.targetLinks = [];
                        });
                        links.forEach(function(link) {
                          var source = link.source,
                          target = link.target;
                          if (typeof source === "number") source = link.source = nodes[link.source];
                          if (typeof target === "number") target = link.target = nodes[link.target];
                          source.sourceLinks.push(link);
                          target.targetLinks.push(link);
                        });
                      }
                  
                      // Compute the value (size) of each node by summing the associated links.
                      function computeNodeValues() {
                        nodes.forEach(function(node) {
                          node.value = Math.max(
                            d3.sum(node.sourceLinks, value),
                            d3.sum(node.targetLinks, value)
                          );
                        });
                      }
                  
                      // Iteratively assign the breadth (x-position) for each node.
                      // Nodes are assigned the maximum breadth of incoming neighbors plus one;
                      // nodes with no incoming links are assigned breadth zero, while
                      // nodes with no outgoing links are assigned the maximum breadth.
                      function computeNodeBreadths() {
                        var remainingNodes = nodes,
                        nextNodes,
                        x = 0;
                  
                        while (remainingNodes.length) {
                          nextNodes = [];
                          remainingNodes.forEach(function(node) {
                            node.x = x;
                            node.dx = nodeWidth;
                            node.sourceLinks.forEach(function(link) {
                              nextNodes.push(link.target);
                            });
                          });
                          remainingNodes = nextNodes;
                          ++x;
                        }
                  
                        //
                        moveSinksRight(x);
                        scaleNodeBreadths((size[0] - nodeWidth) / (x - 1));
                      }
                  
                      function moveSourcesRight() {
                        nodes.forEach(function(node) {
                          if (!node.targetLinks.length) {
                            node.x = d3.min(node.sourceLinks, function(d) { return d.target.x; }) - 1;
                          }
                        });
                      }
                  
                      function moveSinksRight(x) {
                        nodes.forEach(function(node) {
                          if (!node.sourceLinks.length) {
                            node.x = x - 1;
                          }
                        });
                      }
                  
                      function scaleNodeBreadths(kx) {
                        nodes.forEach(function(node) {
                          node.x *= kx;
                        });
                      }
                  
                      function computeNodeDepths(iterations) {
                        var nodesByBreadth = d3.nest()
                        .key(function(d) { return d.x; })
                        .sortKeys(d3.ascending)
                        .entries(nodes)
                        .map(function(d) { return d.values; });
                  
                        //
                        initializeNodeDepth();
                        resolveCollisions();
                        for (var alpha = 1; iterations > 0; --iterations) {
                          relaxRightToLeft(alpha *= .99);
                          resolveCollisions();
                          relaxLeftToRight(alpha);
                          resolveCollisions();
                        }
                  
                        function initializeNodeDepth() {
                          var ky = d3.min(nodesByBreadth, function(nodes) {
                            return (size[1] - (nodes.length - 1) * nodePadding) / d3.sum(nodes, value);
                          });
                  
                          nodesByBreadth.forEach(function(nodes) {
                            nodes.forEach(function(node, i) {
                              node.y = i;
                              node.dy = node.value * ky;
                            });
                          });
                  
                          links.forEach(function(link) {
                            link.dy = link.value * ky;
                          });
                        }
                  
                        function relaxLeftToRight(alpha) {
                          nodesByBreadth.forEach(function(nodes, breadth) {
                            nodes.forEach(function(node) {
                              if (node.targetLinks.length) {
                                var y = d3.sum(node.targetLinks, weightedSource) / d3.sum(node.targetLinks, value);
                                node.y += (y - center(node)) * alpha;
                              }
                            });
                          });
                  
                          function weightedSource(link) {
                            return center(link.source) * link.value;
                          }
                        }
                  
                        function relaxRightToLeft(alpha) {
                          nodesByBreadth.slice().reverse().forEach(function(nodes) {
                            nodes.forEach(function(node) {
                              if (node.sourceLinks.length) {
                                var y = d3.sum(node.sourceLinks, weightedTarget) / d3.sum(node.sourceLinks, value);
                                node.y += (y - center(node)) * alpha;
                              }
                            });
                          });
                  
                          function weightedTarget(link) {
                            return center(link.target) * link.value;
                          }
                        }
                  
                        function resolveCollisions() {
                          nodesByBreadth.forEach(function(nodes) {
                            var node,
                                dy,
                                y0 = 0,
                                n = nodes.length,
                                i;
                  
                            // Push any overlapping nodes down.
                            nodes.sort(ascendingDepth);
                            for (i = 0; i < n; ++i) {
                              node = nodes[i];
                              dy = y0 - node.y;
                              if (dy > 0) node.y += dy;
                              y0 = node.y + node.dy + nodePadding;
                            }
                    
                            // If the bottommost node goes outside the bounds, push it back up.
                            dy = y0 - nodePadding - size[1];
                            if (dy > 0) {
                              y0 = node.y -= dy;
                    
                              // Push any overlapping nodes back up.
                              for (i = n - 2; i >= 0; --i) {
                                node = nodes[i];
                                dy = node.y + node.dy + nodePadding - y0;
                                if (dy > 0) node.y -= dy;
                                y0 = node.y;
                              }
                            }
                          });
                        }
                  
                        function ascendingDepth(a, b) {
                          return a.y - b.y;
                        }
                      }
                  
                      function computeLinkDepths() {
                        nodes.forEach(function(node) {
                          node.sourceLinks.sort(ascendingTargetDepth);
                          node.targetLinks.sort(ascendingSourceDepth);
                        });
                        nodes.forEach(function(node) {
                          var sy = 0, ty = 0;
                          node.sourceLinks.forEach(function(link) {
                            link.sy = sy;
                            sy += link.dy;
                          });
                          node.targetLinks.forEach(function(link) {
                            link.ty = ty;
                            ty += link.dy;
                          });
                        });
                  
                        function ascendingSourceDepth(a, b) {
                          return a.source.y - b.source.y;
                        }
                        
                        function ascendingTargetDepth(a, b) {
                          return a.target.y - b.target.y;
                        }
                      }
                  
                      function center(node) {
                        return node.y + node.dy / 2;
                      }
                  
                      function value(link) {
                        return link.value;
                      }
                  
                      return sankey;
                    };
                  </script>
                  
                  <title>', page_title, '</title>
                  </head>
                  
                  <body>
                  <div style = "text-align: center;"><h1>', graph_title, '</h1></div>
                  <div>
                  <div id = "sankey" class = "rChart rCharts_d3_sankey" align = "center"></div>
                  <div id = "events">
                  <script>
                  $(function() {
                  var events = ', events, ';
                  for (i = 0; i < events.length; i++) {
                  $("#events").append(events[i]);
                  }
                  $("#sankey").css("height", ($(window).height() * .80) + "px");
                  $("#events").css("height", ($(window).height() * .80) + "px");
                  });
                  </script>
                  </div>
                  </div>
                  <div id = "controls" align = "center">
                  <button type = "button" class = "btn" id = "start">
                    <i class = "fa fa-play"></i>
                  </button>
                  <button type = "button" class = "btn" id = "stop">
                    <i class = "fa fa-stop"></i>
                  </button>
                  <button type = "button" class = "btn" id = "step-back">
                    <i class = "fa fa-step-backward"></i>
                  </button>
                  <button type = "button" class = "btn" id = "step-forward">
                    <i class = "fa fa-step-forward"></i>
                  </button>
                  <div class = "divider"></div>
                  <button type = "button" class = "btn" id = "speed-down">
                    <i class = "fa fa-minus"></i>
                  </button>
                  <button type = "button" class = "btn" id = "speed-up">
                    <i class = "fa fa-plus"></i>
                  </button>
                  <div class = "divider"></div>
                  <button type = "button" class = "btn" id = "reset">
                    <i class = "fa fa-rotate-left"></i>
                  </button>
                  </div>
                  <script>
                    ', main, '
                  </script>
                  <script>
                    ', after, '
                  </script>
                  <script>
                    ', gif, '
                  </script>
                  <footer>
                    <p>Very special thanks goes out to <a href = "https://github.com/ramnathv">Ramnath Vaidyanathan</a> and <a href = "https://github.com/timelyportfolio">@timelyportfolio</a> for their amazing work on getting d3 graphics to work with R.</p>
                  </footer>
                  </body>
                  </html>', sep = "")
  writeLines(text = html, con = destfile)
}
  
 