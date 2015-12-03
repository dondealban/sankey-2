.generate_main_js <- function(data, chart_id = "sankey", node_width = 15, node_padding = 10, layout = 32, 
                            units = "", node_tooltip = NULL, link_tooltip_fw = NULL, link_tooltip_bw = NULL) {
  
  if (is.null(node_tooltip)) node_tooltip <- 'd.name + "\\nTotal Out: " + out_n + " transactions for $" + format(out_total) + "\\nTotal In: " + in_n + " transactions for $" + format(in_total);'
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
  data_json <- paste('{"source": [', src, '], "target": [', target, '], "value": [', value, '], "date": [', date, '], "reverse": [', reverse, ']}', sep = "")
  js <- paste('\n\t\t\t(function(){',
              '\n\t\t\t\tvar width = $(window).width() * .78;',
              '\n\t\t\t\tvar height = $(window).height() * .75;',
              '\n\t\t\t\tvar params = {',
              '\n\t\t\t\t\t"dom": "sankey",',
              '\n\t\t\t\t\t"width": width,',
              '\n\t\t\t\t\t"height": height,',
              '\n\t\t\t\t\t"data": ', data_json, ',',
              '\n\t\t\t\t\t"nodeWidth": ', node_width, ',',
              '\n\t\t\t\t\t"nodePadding": ', node_padding, ',',
              '\n\t\t\t\t\t"layout": ', layout, ',',
              '\n\t\t\t\t\t"units": "', units, '",',
              '\n\t\t\t\t\t"id": "sankey"',
              '\n\t\t\t\t};',
              '\n',
              '\n\t\t\t\tparams.units ? units = " " + params.units : units = "";',
              '\n',
              '\n\t\t\t\t//hard code these now but eventually make available',
              '\n\t\t\t\tvar formatNumber = d3.format("0,.0f"),    // zero decimal places',
              '\n\t\t\t\tformat = function(d) { return formatNumber(d) + units; },',
              '\n\t\t\t\tcolor = d3.scale.category20();',
              '\n',
              '\n\t\t\t\tif(params.labelFormat){',
              '\n\t\t\t\t\tformatNumber = d3.format(".2%");',
              '\n\t\t\t\t}',
              '\n',
              '\n\t\t\t\tvar svg = d3.select("#" + params.id).append("svg")',
              '\n\t\t\t\t\t.attr("width", params.width)',
              '\n\t\t\t\t\t.attr("height", params.height);',
              '\n',
              '\n\t\t\t\tvar sankey = d3.sankey()',
              '\n\t\t\t\t\t.nodeWidth(params.nodeWidth)',
              '\n\t\t\t\t\t.nodePadding(params.nodePadding)',
              '\n\t\t\t\t\t.layout(params.layout)',
              '\n\t\t\t\t\t.size([params.width,params.height]);',
              '\n',
              '\n\t\t\t\tvar path = sankey.link();',
              '\n',
              '\n\t\t\t\tvar data = params.data,',
              '\n\t\t\t\t\tlinks = [],',
              '\n\t\t\t\t\tnodes = [];',
              '\n',
              '\n\t\t\t\t//get all source and target into nodes',
              '\n\t\t\t\t//will reduce to unique in the next step',
              '\n\t\t\t\t//also get links in object form',
              '\n\t\t\t\tdata.source.forEach(function (d, i) {',
              '\n\t\t\t\t\tnodes.push({ "name": data.source[i] });',
              '\n\t\t\t\t\tnodes.push({ "name": data.target[i] });',
              '\n\t\t\t\t\tlinks.push({ "source": data.source[i], "target": data.target[i], "value": +data.value[i], "date": data.date[i], "reverse": data.reverse[i] });',
              '\n\t\t\t\t});',
              '\n',
              '\n\t\t\t\t//now get nodes based on links data',
              '\n\t\t\t\t//thanks Mike Bostock https://groups.google.com/d/msg/d3-js/pl297cFtIQk/Eso4q_eBu1IJ',
              '\n\t\t\t\t//this handy little function returns only the distinct / unique nodes',
              '\n\t\t\t\tnodes = d3.keys(d3.nest()',
              '\n\t\t\t\t\t.key(function (d) { return d.name; })',
              '\n\t\t\t\t\t.map(nodes));',
              '\n',
              '\n\t\t\t\t//it appears d3 with force layout wants a numeric source and target',
              '\n\t\t\t\t//so loop through each link replacing the text with its index from node',
              '\n\t\t\t\tlinks.forEach(function (d, i) {',
              '\n\t\t\t\t\tlinks[i].source = nodes.indexOf(links[i].source);',
              '\n\t\t\t\t\tlinks[i].target = nodes.indexOf(links[i].target);',
              '\n\t\t\t\t});',
              '\n',
              '\n\t\t\t\t//now loop through each nodes to make nodes an array of objects rather than an array of strings',
              '\n\t\t\t\tnodes.forEach(function (d, i) {',
              '\n\t\t\t\t\tnodes[i] = { "name": d };',
              '\n\t\t\t\t});',
              '\n',
              '\n\t\t\t\tsankey',
              '\n\t\t\t\t\t.nodes(nodes)',
              '\n\t\t\t\t\t.links(links)',
              '\n\t\t\t\t\t.layout(params.layout);',
              '\n',
              '\n\t\t\t\tvar link = svg.append("g").selectAll(".link")',
              '\n\t\t\t\t\t.data(links)',
              '\n\t\t\t\t\t.enter().append("path")',
              '\n\t\t\t\t\t.attr("class", "link")',
              '\n\t\t\t\t\t.attr("d", path)',
              '\n\t\t\t\t\t.style("stroke-width", function (d) { return Math.max(2, d.dy); })',
              '\n\t\t\t\t\t.sort(function (a, b) { return b.dy - a.dy; });',
              '\n',
              '\n\t\t\t\tlink.append("title")',
              '\n\t\t\t\t\t.text(function (d) { return(d.reverse === "1" ? ', link_tooltip_bw, ' : ', link_tooltip_fw, ') });',
              '\n',
              '\n\t\t\t\tvar node = svg.append("g").selectAll(".node")',
              '\n\t\t\t\t\t.data(nodes)',
              '\n\t\t\t\t\t.enter().append("g")',
              '\n\t\t\t\t\t.attr("class", "node")',
              '\n\t\t\t\t\t.attr("transform", function (d) { return "translate(" + d.x + "," + d.y + ")"; })',
              '\n\t\t\t\t\t.call(d3.behavior.drag()',
              '\n\t\t\t\t\t\t.origin(function (d) { return d; })',
              '\n\t\t\t\t\t\t.on("dragstart", function () { this.parentNode.appendChild(this); })',
              '\n\t\t\t\t\t\t.on("drag", dragmove));',
              '\n',
              '\n\t\t\t\tnode.append("rect")',
              '\n\t\t\t\t\t.attr("height", function (d) { return d.dy > 1 ? d.dy : 1; })',
              '\n\t\t\t\t\t.attr("width", sankey.nodeWidth())',
              '\n\t\t\t\t\t.style("fill", function (d) { return d.color = color(d.name.replace(/ .*/, "")); })',
              '\n\t\t\t\t\t.style("stroke", function (d) { return d3.rgb(d.color).darker(2); })',
              '\n\t\t\t\t\t.append("title")',
              '\n\t\t\t\t\t.text(function (d) {',
              '\n\t\t\t\t\t\tvar out_total = 0,',
              '\n\t\t\t\t\t\t\tin_total = 0,', 
              '\n\t\t\t\t\t\t\tout_n = d.sourceLinks.filter(function(r) { return r.reverse === "0"; }).length + d.targetLinks.filter(function(r) { return r.reverse === "1"; }).length,', 
              '\n\t\t\t\t\t\t\tin_n = d.targetLinks.filter(function(r) { return r.reverse === "0"; }).length + d.sourceLinks.filter(function(r) { return r.reverse === "1"; }).length;',
              '\n\t\t\t\t\t\td.sourceLinks.forEach(function(s) {', 
              '\n\t\t\t\t\t\t\tout_total += (s.reverse === "0") ? s.value : 0;',
              '\n\t\t\t\t\t\t\tin_total += (s.reverse === "1") ? s.value : 0;',
              '\n\t\t\t\t\t\t});',
              '\n\t\t\t\t\t\td.targetLinks.forEach(function(t) {',
              '\n\t\t\t\t\t\t\tin_total += (t.reverse === "0") ? t.value : 0;',
              '\n\t\t\t\t\t\t\tout_total += (t.reverse === "1") ? t.value : 0;',
              '\n\t\t\t\t\t\t});',
              '\n\t\t\t\t\t\treturn ', node_tooltip, ' });',
              '\n',
              '\n\t\t\t\tnode.append("text")',
              '\n\t\t\t\t.attr("x", -6)',
              '\n\t\t\t\t.attr("y", function (d) { return d.dy / 2; })',
              '\n\t\t\t\t.attr("dy", ".35em")',
              '\n\t\t\t\t.attr("text-anchor", "end")',
              '\n\t\t\t\t.attr("transform", null)',
              '\n\t\t\t\t.text(function (d) { return d.name; })',
              '\n\t\t\t\t.filter(function (d) { return d.x < params.width / 2; })',
              '\n\t\t\t\t.attr("x", 6 + sankey.nodeWidth())',
              '\n\t\t\t\t.attr("text-anchor", "start");',
              '\n',
              '\n\t\t\t\t// the function for moving the nodes',
              '\n\t\t\t\tfunction dragmove(d) {',
              '\n\t\t\t\t\td3.select(this).attr("transform","translate(" + (d.x = Math.max(0, Math.min(params.width - d.dx, d3.event.x))) + "," + (d.y = Math.max(0, Math.min(params.height - d.dy, d3.event.y))) + ")");',
              '\n\t\t\t\t\tsankey.relayout();',
              '\n\t\t\t\t\tlink.attr("d", path);',
              '\n\t\t\t\t}',
              '\n\t\t\t})();', sep = "")
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
  
  gif <- paste('\n\t\t\t$(function() {', 
               '\n\t\t\t\tvar selector = $("#sankey");', 
               '\n\t\t\t\tvar delay_sec = ', delay, ';', 
               '\n\t\t\t\tvar num = -1,',
               '\n\t\t\t\tlen = ', n, ';',
               '\n\t\t\t\tvar step_counter = 0;',
               '\n\t\t\t\tvar threshold = 0;',
               '\n\t\t\t\tvar height = 0;',
               '\n\t\t\t\tvar timer = null;',
               '\n\t\t\t\tvar events = ', events, ';',
               '\n\t\t\t\tvar targets = [', targets, '];',
               '\n',
               '\n\t\t\t\tfunction reset() {',
               '\n\t\t\t\t\tstop();',
               '\n\t\t\t\t\tnum = 0;',
               '\n\t\t\t\t\tthreshold = 0;',
               '\n\t\t\t\t\theight = 0;',
               '\n\t\t\t\t\tdelay_sec = 2;',
               '\n\t\t\t\t\td3.selectAll("#sankey svg .node rect")',
               '\n\t\t\t\t\t\t.style("fill", function(d) { return (targets.indexOf(d.name) > -1) ? "#FF6A6A" : "#90EE90" })',
               '\n\t\t\t\t\t\t.style("stroke", function(d) { return (targets.indexOf(d.name) >= 0) ? "#FF6A6A" : "#90EE90" })',
               '\n\t\t\t\t\t$("#sankey svg .node text").css("fill", "#000000");',
               '\n\t\t\t\t\td3.selectAll("#sankey svg path.link")',
               '\n\t\t\t\t\t\t.style("stroke", function(d) { return(d.reverse === "1" ? "#A020F0" : "#66CCFF") })',
               '\n\t\t\t\t\t$("#events").animate({scrollTop: 0}, "fast");',
               '\n\t\t\t\t};',
               '\n',
               '\n\t\t\t\tfunction blank_graph() {',
               '\n\t\t\t\t\t$("#sankey svg .node rect").css("fill", "#F7F7F7").css("stroke", "#F7F7F7");',
               '\n\t\t\t\t\t$("#sankey svg .node text").css("fill", "#F7F7F7");',
               '\n\t\t\t\t\t$("#sankey svg path.link").css("stroke", "#F7F7F7");',
               '\n\t\t\t\t\t$("#events").animate({scrollTop: 0}, "fast");',
               '\n\t\t\t\t\t$("#events").children().css("color", "#000000");',
               '\n\t\t\t\t};',
               '\n',
               '\n\t\t\t\tfunction event(num, scroll = true) {',
               '\n\t\t\t\t\tif (num === -1) {',
               '\n\t\t\t\t\t\tthreshold = 0;',
               '\n\t\t\t\t\t\theight = 0;',
               '\n\t\t\t\t\t\tblank_graph();',
               '\n\t\t\t\t\t} else {',
               '\n\t\t\t\t\t\t$("#events").children().css("color", "#000000");',
               '\n\t\t\t\t\t\td3.selectAll("#sankey svg .node rect")',
               '\n\t\t\t\t\t\t\t.style("fill", function(d) { return events[num]["node_colors"][d.name] })',
               '\n\t\t\t\t\t\t\t.style("stroke", function(d) { return events[num]["node_colors"][d.name] })',
               '\n\t\t\t\t\t\td3.selectAll("#sankey svg .node text")',
               '\n\t\t\t\t\t\t\t.style("fill", function(d) { return events[num]["text_colors"][d.name] })',
               '\n\t\t\t\t\t\td3.selectAll("#sankey svg path.link")',
               '\n\t\t\t\t\t\t\t.style("stroke", function (d) {',
               '\n\t\t\t\t\t\t\t\tif (targets.indexOf(d.source.name) > -1) {',
               '\n\t\t\t\t\t\t\t\t\tvar path = d.source.name + " " + d.target.name + " " + d.date;',
               '\n\t\t\t\t\t\t\t\t\treturn events[num]["link_colors"][path];',
               '\n\t\t\t\t\t\t\t\t} else {',
               '\n\t\t\t\t\t\t\t\t\tvar path = d.target.name + " " + d.source.name + " " + d.date;',
               '\n\t\t\t\t\t\t\t\t\treturn events[num]["link_colors"][path];',
               '\n\t\t\t\t\t\t\t\t}',
               '\n\t\t\t\t\t\t\t});',
               '\n\t\t\t\t\t\t\t$("#events h3:nth-of-type(" + (num + 1) + ")").css("color", "#FF6A6A");',
               '\n\t\t\t\t\t\t\t$("#events p:nth-of-type(" + (num + 1) + ")").css("color", "#FF6A6A");',
               '\n\t\t\t\t\t\t\tif (scroll) {',
               '\n\t\t\t\t\t\t\t\tthreshold += ($("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true));',
               '\n\t\t\t\t\t\t\t\t\tif (threshold >= ($("#events").height() - 5)) {',
               '\n\t\t\t\t\t\t\t\t\t\theight += $("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true);',
               '\n\t\t\t\t\t\t\t\t\t\t$("#events").animate({scrollTop: height}, "slow");',
               '\n\t\t\t\t\t\t\t\t\t}',
               '\n\t\t\t\t\t\t\t} else {',
               '\n\t\t\t\t\t\t\t\tif (step_counter === 1) {',
               '\n\t\t\t\t\t\t\t\t\tthreshold = ($("#events").height() - 5) - ($("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true));',
               '\n\t\t\t\t\t\t\t\t} else {',
               '\n\t\t\t\t\t\t\t\t\tthreshold -= ($("#events p:nth-of-type(" + (num + 1) + ")").outerHeight(true) + $("#events h3:nth-of-type(" + (num + 1) + ")").outerHeight(true));',
               '\n\t\t\t\t\t\t\t\t}',
               '\n\t\t\t\t\t\t\t}',
               '\n\t\t\t\t\t}',
               '\n\t\t\t\t}',
               '\n',
               '\n\t\t\t\tfunction loop() {',
               '\n\t\t\t\t\tnum = (num === len) ? -1 : num;',
               '\n\t\t\t\t\tevent(num);',
               '\n\t\t\t\t\tnum++;',
               '\n\t\t\t\t\tstart();',
               '\n\t\t\t\t};',
               '\n',
               '\n\t\t\t\tfunction start() {',
               '\n\t\t\t\t\ttimer = setTimeout(loop, (delay_sec * 1000));',
               '\n\t\t\t\t};',
               '\n',
               '\n\t\t\t\tfunction stop() {',
               '\n\t\t\t\t\tclearTimeout(timer);',
               '\n\t\t\t\t};',
               '\n',
               '\n\t\t\t\tfunction forward() {',
               '\n\t\t\t\t\tstop();',
               '\n\t\t\t\t\tnum += 1;',
               '\n\t\t\t\t\tstep_counter -= 1;',
               '\n\t\t\t\t\tstep_counter = (step_counter < 0) ? 0 : step_counter;',
               '\n\t\t\t\t\tevent(num);',
               '\n\t\t\t\t};',
               '\n',
               '\n\t\t\t\tfunction backward() {',
               '\n\t\t\t\t\tstop();',
               '\n\t\t\t\t\tnum -= 1;',
               '\n\t\t\t\t\tstep_counter += 1;',
               '\n\t\t\t\t\tevent(num, false);',
               '\n\t\t\t\t};',
               '\n',
               '\n\t\t\t\tfunction speed_up() {',
               '\n\t\t\t\t\tstop();',
               '\n\t\t\t\t\tdelay_sec -= .2;',
               '\n\t\t\t\t\tdelay_sec = (delay_sec <= 0) ? 1 : delay_sec;',
               '\n\t\t\t\t\tstart();',
               '\n\t\t\t\t};',
               '\n',
               '\n\t\t\t\tfunction speed_down() {',
               '\n\t\t\t\t\tstop();',
               '\n\t\t\t\t\tdelay_sec += .2;',
               '\n\t\t\t\t\tdelay_sec = (delay_sec > 10) ? 10 : delay_sec;',
               '\n\t\t\t\t\tstart();',
               '\n\t\t\t\t}',
               '\n',
               '\n\t\t\t\t$("#start").on("click", start);',
               '\n\t\t\t\t$("#stop").on("click", stop);',
               '\n\t\t\t\t$("#step-forward").on("click", forward);',
               '\n\t\t\t\t$("#step-back").on("click", backward);',
               '\n\t\t\t\t$("#speed-up").on("click", speed_up);',
               '\n\t\t\t\t$("#speed-down").on("click", speed_down);',
               '\n\t\t\t\t$("#reset").on("click", reset);',
               '\n\t\t\t});', sep = "")
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
  
  js <- paste('\n\t\t\tvar node_colors = JSON.parse(\'{', node_colors, '}\');', 
              '\n\t\t\tvar link_colors = JSON.parse(\'{', link_colors, '}\');',
              '\n\t\t\td3.selectAll("#sankey svg .node rect")',
              '\n\t\t\t\t.style("fill", function(d) { return node_colors[d.name] })',
              '\n\t\t\t\t.style("stroke", function(d) { d3.rgb(node_colors[d.name]).darker(2); })',
              '\n',
              '\n\t\t\td3.selectAll("#sankey svg .node rect title")',
              '\n\t\t\t\t.style("color", "#FF6A6A")',
              '\n',
              '\n\t\t\td3.selectAll("#sankey svg path.link")',
              '\n\t\t\t\t.style("stroke", function(d) { return link_colors[d.source.name + " " + d.target.name + " " + d.date] })', sep = "")
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

.add_reverse_flags <- function(data) {
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
  return(data)
}

.reverse_paths <- function(data) {
  if (!"reverse" %in% names(data)) data <- .add_reverse_flags(data)
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
  
  html <- paste('<!DOCTYPE HTML>',
                '\n<html>',
                '\n\t<head>',
                '\n\t\t<meta charset = "utf-8">',
                '\n\t\t<script type = "text/javascript" src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>',
                '\n\t\t<script type = "text/javascript" src = "http://code.jquery.com/jquery-latest.min.js"></script>',
                '\n\t\t<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">',
                '\n\t\t<style>',
                '\n\t\t\t.node rect {',
                '\n\t\t\t\tcursor: move;',
                '\n\t\t\t\tfill-opacity: .9;',
                '\n\t\t\t\tshape-rendering: crispEdges;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\t.node text {',
                '\n\t\t\t\tpointer-events: none;',
                '\n\t\t\t\ttext-shadow: 0 1px 0 #fff;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\t.link {',
                '\n\t\t\t\tfill: none;',
                '\n\t\t\t\tstroke: #000;',
                '\n\t\t\t\tstroke-opacity: .2;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\t.link:hover {',
                '\n\t\t\t\tstroke-opacity: .5;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\tsvg {',
                '\n\t\t\t\tfont: 10px sans-serif;',
                '\n\t\t\t}',
                '\n\t\t</style>',
                '\n\t\t<style>',
                '\n\t\t\t.rChart {',
                '\n\t\t\t\tdisplay: block;',
                '\n\t\t\t\tmargin-left: auto;',
                '\n\t\t\t\tmargin-right: auto;',
                '\n\t\t\t\twidth: 80%;',
                '\n\t\t\t\theight: 100%;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\t#sankey {',
                '\n\t\t\t\twidth: 80%;',
                '\n\t\t\t\tfloat: left;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\t#events {',
                '\n\t\t\t\twidth: 19%;',
                '\n\t\t\t\tfloat: left;',
                '\n\t\t\t\tfont-size: small;',
                '\n\t\t\t\toverflow: auto;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\t#events h3 {',
                '\n\t\t\t\tfont-size: 12px;',
                '\n\t\t\t\tfont-weight: bold;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\t#events p {',
                '\n\t\t\t\tfont-size: 10px;',
                '\n\t\t\t}',
                '\n', 
                '\n\t\t\t#controls {',
                '\n\t\t\t\twidth: 80%;',
                '\n\t\t\t\theight: auto;',
                '\n\t\t\t\tdisplay: bl',
                '\n\t\t\t\tmargin-top: 10px;',
                '\n\t\t\t\tmargin-left: auto;',
                '\n\t\t\t\tmargin-right: auto;',
                '\n\t\t\t\tfloat: left;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\tsvg {',
                '\n\t\t\t\theight: 100%;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\t.divider {',
                '\n\t\t\t\twidth: 5px;',
                '\n\t\t\t\theight: auto;',
                '\n\t\t\t\tdisplay: inline-block;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t\tfooter {',
                '\n\t\t\t\twidth: 100%;',
                '\n\t\t\t\tfloat: left;',
                '\n\t\t\t\tfont-size: small;',
                '\n\t\t\t\ttext-align: left;',
                '\n\t\t\t\tmargin-top: 10px;',
                '\n\t\t\t}',
                '\n',
                '\n\t\t</style>',
                '\n\t\t<script>',
                '\n\t\t\td3.sankey = function() {',
                '\n\t\t\t\tvar sankey = {},',
                '\n\t\t\t\tnodeWidth = 24,',
                '\n\t\t\t\tnodePadding = 8,',
                '\n\t\t\t\tsize = [1, 1],',
                '\n\t\t\t\tnodes = [],',
                '\n\t\t\t\tlinks = [];',
                '\n',
                '\n\t\t\t\tsankey.nodeWidth = function(_) {',
                '\n\t\t\t\t\tif (!arguments.length) return nodeWidth;',
                '\n\t\t\t\t\tnodeWidth = +_;',
                '\n\t\t\t\t\treturn sankey;',
                '\n\t\t\t\t};',
                '\n',
                '\n\t\t\t\tsankey.nodePadding = function(_) {',
                '\n\t\t\t\t\tif (!arguments.length) return nodePadding;',
                '\n\t\t\t\t\tnodePadding = +_;',
                '\n\t\t\t\t\treturn sankey;',
                '\n\t\t\t\t};',
                '\n',
                '\n\t\t\t\tsankey.nodes = function(_) {',
                '\n\t\t\t\t\tif (!arguments.length) return nodes;',
                '\n\t\t\t\t\tnodes = _;',
                '\n\t\t\t\t\treturn sankey;',
                '\n\t\t\t\t};',
                '\n',
                '\n\t\t\t\tsankey.links = function(_) {',
                '\n\t\t\t\t\tif (!arguments.length) return links;',
                '\n\t\t\t\t\tlinks = _;',
                '\n\t\t\t\t\treturn sankey;',
                '\n\t\t\t\t};',
                '\n',
                '\n\t\t\t\tsankey.size = function(_) {',
                '\n\t\t\t\t\tif (!arguments.length) return size;',
                '\n\t\t\t\t\tsize = _;',
                '\n\t\t\t\t\treturn sankey;',
                '\n\t\t\t\t};',
                '\n',
                '\n\t\t\t\tsankey.layout = function(iterations) {',
                '\n\t\t\t\t\tcomputeNodeLinks();',
                '\n\t\t\t\t\tcomputeNodeValues();',
                '\n\t\t\t\t\tcomputeNodeBreadths();',
                '\n\t\t\t\t\tcomputeNodeDepths(iterations);',
                '\n\t\t\t\t\tcomputeLinkDepths();',
                '\n\t\t\t\t\treturn sankey;',
                '\n\t\t\t\t};',
                '\n',
                '\n\t\t\t\tsankey.relayout = function() {',
                '\n\t\t\t\t\tcomputeLinkDepths();',
                '\n\t\t\t\t\treturn sankey;',
                '\n\t\t\t\t};',
                '\n',
                '\n\t\t\t\tsankey.link = function() {',
                '\n\t\t\t\t\tvar curvature = .5;',
                '\n\t\t\t\t\tfunction link(d) {',
                '\n\t\t\t\t\t\tvar x0 = d.source.x + d.source.dx,',
                '\n\t\t\t\t\t\tx1 = d.target.x,',
                '\n\t\t\t\t\t\txi = d3.interpolateNumber(x0, x1),',
                '\n\t\t\t\t\t\tx2 = xi(curvature),',
                '\n\t\t\t\t\t\tx3 = xi(1 - curvature),',
                '\n\t\t\t\t\t\ty0 = d.source.y + d.sy + d.dy / 2,',
                '\n\t\t\t\t\t\ty1 = d.target.y + d.ty + d.dy / 2;',
                '\n\t\t\t\t\t\treturn "M" + x0 + "," + y0 + "C" + x2 + "," + y0 + " " + x3 + "," + y1 + " " + x1 + "," + y1;',
                '\n\t\t\t\t\t}',
                '\n',
                '\n\t\t\t\t\tlink.curvature = function(_) {',
                '\n\t\t\t\t\t\tif (!arguments.length) return curvature;',
                '\n\t\t\t\t\t\tcurvature = +_;',
                '\n\t\t\t\t\t\treturn link;',
                '\n\t\t\t\t\t};',
                '\n',
                '\n\t\t\t\t\treturn link;',
                '\n\t\t\t\t};',
                '\n',
                '\n\t\t\t\t// Populate the sourceLinks and targetLinks for each node.',
                '\n\t\t\t\t// Also, if the source and target are not objects, assume they are indices.',
                '\n\t\t\t\tfunction computeNodeLinks() {',
                '\n\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\tnode.sourceLinks = [];',
                '\n\t\t\t\t\t\tnode.targetLinks = [];',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t\tlinks.forEach(function(link) {',
                '\n\t\t\t\t\t\tvar source = link.source,',
                '\n\t\t\t\t\t\ttarget = link.target;',
                '\n\t\t\t\t\t\tif (typeof source === "number") source = link.source = nodes[link.source];',
                '\n\t\t\t\t\t\tif (typeof target === "number") target = link.target = nodes[link.target];',
                '\n\t\t\t\t\t\tsource.sourceLinks.push(link);',
                '\n\t\t\t\t\t\ttarget.targetLinks.push(link);',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t}',
                '\n\t\t\t\t// Compute the value (size) of each node by summing the associated links.',
                '\n\t\t\t\tfunction computeNodeValues() {',
                '\n\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\tnode.value = Math.max(d3.sum(node.sourceLinks, value), d3.sum(node.targetLinks, value));',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t}',
                '\n\t\t\t\t// Iteratively assign the breadth (x-position) for each node.',
                '\n\t\t\t\t// Nodes are assigned the maximum breadth of incoming neighbors plus one;',
                '\n\t\t\t\t// nodes with no incoming links are assigned breadth zero, while',
                '\n\t\t\t\t// nodes with no outgoing links are assigned the maximum breadth.',
                '\n\t\t\t\tfunction computeNodeBreadths() {',
                '\n\t\t\t\t\tvar remainingNodes = nodes,',
                '\n\t\t\t\t\tnextNodes,',
                '\n\t\t\t\t\tx = 0;',
                '\n\t\t\t\t\twhile (remainingNodes.length) {',
                '\n\t\t\t\t\t\tnextNodes = [];',
                '\n\t\t\t\t\t\tremainingNodes.forEach(function(node) {',
                '\n\t\t\t\t\t\t\tnode.x = x;',
                '\n\t\t\t\t\t\t\tnode.dx = nodeWidth;',
                '\n\t\t\t\t\t\t\tnode.sourceLinks.forEach(function(link) {',
                '\n\t\t\t\t\t\t\t\tnextNodes.push(link.target);',
                '\n\t\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\tremainingNodes = nextNodes;',
                '\n\t\t\t\t\t\t++x;',
                '\n\t\t\t\t\t}',
                '\n\t\t\t\t\t//',
                '\n\t\t\t\t\tmoveSinksRight(x);',
                '\n\t\t\t\t\tscaleNodeBreadths((size[0] - nodeWidth) / (x - 1));',
                '\n\t\t\t\t}',
                '\n\t\t\t\tfunction moveSourcesRight() {',
                '\n\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\tif (!node.targetLinks.length) {',
                '\n\t\t\t\t\t\t\tnode.x = d3.min(node.sourceLinks, function(d) { return d.target.x; }) - 1;',
                '\n\t\t\t\t\t\t}',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t}',
                '\n\t\t\t\tfunction moveSinksRight(x) {',
                '\n\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\tif (!node.sourceLinks.length) {',
                '\n\t\t\t\t\t\t\tnode.x = x - 1;',
                '\n\t\t\t\t\t\t}',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t}',
                '\n\t\t\t\tfunction scaleNodeBreadths(kx) {',
                '\n\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\tnode.x *= kx;',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t}',
                '\n\t\t\t\tfunction computeNodeDepths(iterations) {',
                '\n\t\t\t\t\tvar nodesByBreadth = d3.nest()',
                '\n\t\t\t\t\t.key(function(d) { return d.x; })',
                '\n\t\t\t\t\t.sortKeys(d3.ascending)',
                '\n\t\t\t\t\t.entries(nodes)',
                '\n\t\t\t\t\t.map(function(d) { return d.values; });',
                '\n\t\t\t\t\t//',
                '\n\t\t\t\t\tinitializeNodeDepth();',
                '\n\t\t\t\t\tresolveCollisions();',
                '\n\t\t\t\t\tfor (var alpha = 1; iterations > 0; --iterations) {',
                '\n\t\t\t\t\t\trelaxRightToLeft(alpha *= .99);',
                '\n\t\t\t\t\t\tresolveCollisions();',
                '\n\t\t\t\t\t\trelaxLeftToRight(alpha);',
                '\n\t\t\t\t\t\tresolveCollisions();',
                '\n\t\t\t\t\t}',
                '\n\t\t\t\t\tfunction initializeNodeDepth() {',
                '\n\t\t\t\t\t\tvar ky = d3.min(nodesByBreadth, function(nodes) {',
                '\n\t\t\t\t\t\t\treturn (size[1] - (nodes.length - 1) * nodePadding) / d3.sum(nodes, value);',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\tnodesByBreadth.forEach(function(nodes) {',
                '\n\t\t\t\t\t\t\tnodes.forEach(function(node, i) {',
                '\n\t\t\t\t\t\t\t\tnode.y = i;',
                '\n\t\t\t\t\t\t\t\tnode.dy = node.value * ky;',
                '\n\t\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\tlinks.forEach(function(link) {',
                '\n\t\t\t\t\t\t\tlink.dy = link.value * ky;',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t}',
                '\n\t\t\t\t\tfunction relaxLeftToRight(alpha) {',
                '\n\t\t\t\t\t\tnodesByBreadth.forEach(function(nodes, breadth) {',
                '\n\t\t\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\t\t\tif (node.targetLinks.length) {',
                '\n\t\t\t\t\t\t\t\t\tvar y = d3.sum(node.targetLinks, weightedSource) / d3.sum(node.targetLinks, value);',
                '\n\t\t\t\t\t\t\t\t\tnode.y += (y - center(node)) * alpha;',
                '\n\t\t\t\t\t\t\t\t}',
                '\n\t\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\tfunction weightedSource(link) {',
                '\n\t\t\t\t\t\t\treturn center(link.source) * link.value;',
                '\n\t\t\t\t\t\t}',
                '\n\t\t\t\t\t}',
                '\n\t\t\t\t\tfunction relaxRightToLeft(alpha) {',
                '\n\t\t\t\t\t\tnodesByBreadth.slice().reverse().forEach(function(nodes) {',
                '\n\t\t\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\t\t\tif (node.sourceLinks.length) {',
                '\n\t\t\t\t\t\t\t\t\tvar y = d3.sum(node.sourceLinks, weightedTarget) / d3.sum(node.sourceLinks, value);',
                '\n\t\t\t\t\t\t\t\t\tnode.y += (y - center(node)) * alpha;',
                '\n\t\t\t\t\t\t\t\t}',
                '\n\t\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\tfunction weightedTarget(link) {',
                '\n\t\t\t\t\t\t\treturn center(link.target) * link.value;',
                '\n\t\t\t\t\t\t}',
                '\n\t\t\t\t\t}',
                '\n\t\t\t\t\tfunction resolveCollisions() {',
                '\n\t\t\t\t\t\tnodesByBreadth.forEach(function(nodes) {',
                '\n\t\t\t\t\t\t\tvar node,',
                '\n\t\t\t\t\t\t\tdy,',
                '\n\t\t\t\t\t\t\ty0 = 0,',
                '\n\t\t\t\t\t\t\tn = nodes.length,',
                '\n\t\t\t\t\t\t\ti;',
                '\n\t\t\t\t\t\t\t// Push any overlapping nodes down.',
                '\n\t\t\t\t\t\t\tnodes.sort(ascendingDepth);',
                '\n\t\t\t\t\t\t\tfor (i = 0; i < n; ++i) {',
                '\n\t\t\t\t\t\t\t\tnode = nodes[i];',
                '\n\t\t\t\t\t\t\t\tdy = y0 - node.y;',
                '\n\t\t\t\t\t\t\t\tif (dy > 0) node.y += dy;',
                '\n\t\t\t\t\t\t\t\t\ty0 = node.y + node.dy + nodePadding;',
                '\n\t\t\t\t\t\t\t}',
                '\n\t\t\t\t\t\t\t// If the bottommost node goes outside the bounds, push it back up.',
                '\n\t\t\t\t\t\t\tdy = y0 - nodePadding - size[1];',
                '\n\t\t\t\t\t\t\tif (dy > 0) {',
                '\n\t\t\t\t\t\t\t\ty0 = node.y -= dy;',
                '\n\t\t\t\t\t\t\t\t// Push any overlapping nodes back up.',
                '\n\t\t\t\t\t\t\t\tfor (i = n - 2; i >= 0; --i) {',
                '\n\t\t\t\t\t\t\t\t\tnode = nodes[i];',
                '\n\t\t\t\t\t\t\t\t\tdy = node.y + node.dy + nodePadding - y0;',
                '\n\t\t\t\t\t\t\t\t\tif (dy > 0) node.y -= dy;',
                '\n\t\t\t\t\t\t\t\t\ty0 = node.y;',
                '\n\t\t\t\t\t\t\t\t}',
                '\n\t\t\t\t\t\t\t}',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t}',
                '\n\t\t\t\t\tfunction ascendingDepth(a, b) {',
                '\n\t\t\t\t\t\treturn a.y - b.y;',
                '\n\t\t\t\t\t}',
                '\n\t\t\t\t}',
                '\n\t\t\t\tfunction computeLinkDepths() {',
                '\n\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\tnode.sourceLinks.sort(ascendingTargetDepth);',
                '\n\t\t\t\t\t\tnode.targetLinks.sort(ascendingSourceDepth);',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t\tnodes.forEach(function(node) {',
                '\n\t\t\t\t\t\tvar sy = 0, ty = 0;',
                '\n\t\t\t\t\t\tnode.sourceLinks.forEach(function(link) {',
                '\n\t\t\t\t\t\t\tlink.sy = sy;',
                '\n\t\t\t\t\t\t\tsy += link.dy;',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t\tnode.targetLinks.forEach(function(link) {',
                '\n\t\t\t\t\t\t\tlink.ty = ty;',
                '\n\t\t\t\t\t\t\tty += link.dy;',
                '\n\t\t\t\t\t\t});',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t\tfunction ascendingSourceDepth(a, b) {',
                '\n\t\t\t\t\t\treturn a.source.y - b.source.y;',
                '\n\t\t\t\t\t}',
                '\n',
                '\n\t\t\t\t\tfunction ascendingTargetDepth(a, b) {',
                '\n\t\t\t\t\t\treturn a.target.y - b.target.y;',
                '\n\t\t\t\t\t}',
                '\n\t\t\t\t}',
                '\n\t\t\t\tfunction center(node) {',
                '\n\t\t\t\t\treturn node.y + node.dy / 2;',
                '\n\t\t\t\t}',
                '\n\t\t\t\tfunction value(link) {',
                '\n\t\t\t\t\treturn link.value;',
                '\n\t\t\t\t}',
                '\n\t\t\t\treturn sankey;',
                '\n\t\t\t};',
                '\n\t\t</script>',
                '\n',
                '\n\t\t<title>', page_title, '</title>',
                '\n\t</head>',
                '\n',
                '\n\t<body>',
                '\n\t\t<div style = "text-align: center;"><h1>', graph_title, '</h1></div>',
                '\n\t\t<div>',
                '\n\t\t\t<div id = "sankey" class = "rChart rCharts_d3_sankey" align = "center"></div>',
                '\n\t\t\t<div id = "events">',
                '\n\t\t\t\t<script>',
                '\n\t\t\t\t\t$(function() {',
                '\n\t\t\t\t\t\tvar events = ', events, ';',
                '\n\t\t\t\t\t\tfor (i = 0; i < events.length; i++) {',
                '\n\t\t\t\t\t\t\t$("#events").append(events[i]);',
                '\n\t\t\t\t\t\t}',
                '\n\t\t\t\t\t\t$("#sankey").css("height", ($(window).height() * .80) + "px");',
                '\n\t\t\t\t\t\t$("#events").css("height", ($(window).height() * .80) + "px");',
                '\n\t\t\t\t\t});',
                '\n\t\t\t\t</script>',
                '\n\t\t\t</div>',
                '\n\t\t</div>',
                '\n\t\t<div id = "controls" align = "center">',
                '\n\t\t\t<button type = "button" class = "btn" id = "start">',
                '\n\t\t\t\t<i class = "fa fa-play"></i>',
                '\n\t\t\t</button>',
                '\n\t\t\t<button type = "button" class = "btn" id = "stop">',
                '\n\t\t\t\t<i class = "fa fa-stop"></i>',
                '\n\t\t\t</button>',
                '\n\t\t\t<button type = "button" class = "btn" id = "step-back">',
                '\n\t\t\t\t<i class = "fa fa-step-backward"></i>',
                '\n\t\t\t</button>',
                '\n\t\t\t<button type = "button" class = "btn" id = "step-forward">',
                '\n\t\t\t\t<i class = "fa fa-step-forward"></i>',
                '\n\t\t\t</button>',
                '\n\t\t\t<div class = "divider"></div>',
                '\n\t\t\t<button type = "button" class = "btn" id = "speed-down">',
                '\n\t\t\t\t<i class = "fa fa-minus"></i>',
                '\n\t\t\t</button>',
                '\n\t\t\t<button type = "button" class = "btn" id = "speed-up">',
                '\n\t\t\t\t<i class = "fa fa-plus"></i>',
                '\n\t\t\t</button>',
                '\n\t\t\t<div class = "divider"></div>',
                '\n\t\t\t<button type = "button" class = "btn" id = "reset">',
                '\n\t\t\t\t<i class = "fa fa-rotate-left"></i>',
                '\n\t\t\t</button>',
                '\n\t\t</div>',
                '\n\t\t<script>',
                main,
                '\n\t\t</script>',
                '\n\t\t<script>',
                after,
                '\n\t\t</script>',
                '\n\t\t<script>',
                gif,
                '\n\t\t</script>',
                '\n\t\t<footer>',
                '\n\t\t\t<p>Very special thanks goes out to <a href = "https://github.com/ramnathv">Ramnath Vaidyanathan</a> and <a href = "https://github.com/timelyportfolio">@timelyportfolio</a> for their amazing work on getting d3 graphics to work with R.</p>',
                '\n\t\t</footer>',
                '\n\t</body>',
                '\n</html>', sep = "")
  if (is.na(destfile)) {
    return(html)
  } else {
    writeLines(text = html, con = destfile)
  }
}
  
 