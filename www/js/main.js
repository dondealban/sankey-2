
  (function(){
    var params = {
      "dom": "sankey",
      "width": 1200,
      "height": 800,
      "data": {"source": ["Z", "Z", "o", "o", "o", "Z", "X", "m", "d", "m", "R", "R", "k", "F", "s", "X", "B", "O", "v", "B", "B", "B", "B", "t", "B", "B", "B", "i", "D", "u", "T", "T", "j", "n", "H", "H", "J", "n", "Q", "j", "C", "C", "E", "g", "q", "x", "K", "T", "A", "g", "U", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z"],
                        "target": ["N", "N", "M", "L", "Z", "Y", "o", "Z", "m", "Z", "o", "o", "F", "o", "o", "o", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "Z", "o", "o", "o", "Z", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "o", "W", "W", "W", "W", "W", "W", "f", "W", "W", "W", "W", "e", "c", "W", "p", "z", "W", "W", "W", "W", "W", "S", "W", "W", "W", "W", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "z", "N", "N", "N", "Y"],
                        "value": ["90220.88", "82000", "22947", "11744", "14000", "17400", "36300", "34987.39", "34987.39", "4300", "10000", "10000", "17600", "17600", "6000", "10000", "14325", "6451.46", "800", "7500", "29450", "9950", "8990", "800", "4400", "1200", "1200", "5775", "3800", "119959", "8000", "8000", "7974", "9975", "1000", "1000", "10000", "5975", "9973", "7974", "24968", "35768", "10000", "10000", "15000", "14975", "6600", "13000", "10000", "2000", "8450", "850", "4000", "4930", "569", "2653", "4848", "18000", "2752", "16408", "3142", "1009", "24000", "7700", "1899", "7270", "57000", "3132", "2858", "13829", "2844", "1680", "144450", "10409", "3693", "3182", "4913", "64641.34", "43522.2", "51000", "24000", "1845", "52000", "70000", "72000", "40000", "41380", "8870", "14565", "20000", "12810", "22000", "12700", "26300", "52970", "5897.45", "37000", "40328.05", "133141.72", "74872.76", "74068.3", "5215"],
                        "date": ["07/30/14", "03/26/14", "10/07/14", "09/29/14", "04/22/14", "06/19/14", "01/28/15", "04/24/14", "04/24/14", "04/24/14", "08/03/14", "09/03/14", "06/13/14", "06/03/14", "01/16/15", "01/14/15", "09/25/14", "10/22/14", "10/22/14", "10/23/14", "02/18/14", "03/19/14", "06/23/14", "06/21/14", "03/25/14", "09/25/14", "12/03/14", "02/05/15", "01/17/14", "01/22/14", "02/09/15", "02/02/15", "02/04/15", "01/24/14", "08/01/14", "08/04/14", "05/02/14", "01/28/14", "04/29/14", "01/28/15", "09/02/14", "09/02/14", "09/02/14", "10/09/14", "08/29/14", "10/09/14", "12/29/14", "01/26/15", "11/28/14", "10/22/14", "11/03/14", "04/16/14", "04/22/14", "04/30/14", "02/12/14", "02/14/14", "04/11/14", "05/23/14", "06/24/14", "08/07/14", "08/12/14", "06/05/14", "06/09/14", "06/17/14", "12/31/14", "01/23/15", "02/03/15", "08/19/14", "09/25/14", "11/07/14", "01/02/14", "01/15/14", "01/23/14", "01/28/14", "01/03/14", "01/08/14", "01/14/14", "12/05/14", "01/09/15", "09/09/14", "08/19/14", "03/11/14", "02/14/14", "01/03/14", "02/05/14", "02/27/14", "03/06/14", "05/14/14", "04/18/14", "04/23/14", "04/08/14", "04/25/14", "03/24/14", "06/05/14", "07/08/14", "05/06/14", "10/30/14", "10/14/14", "06/23/14", "11/17/14", "05/30/14", "05/14/14"]},
      "nodeWidth": 15,
      "nodePadding": 10,
      "layout": 32,
      "units": "",
      "id": "sankey" 
    };
    
    params.units ? units = " " + params.units : units = "";
    
    //hard code these now but eventually make available
    var formatNumber = d3.format("0,.0f"),    // zero decimal places
    format = function(d) { return formatNumber(d) + units; },
    color = d3.scale.category20();
    
    if(params.labelFormat){
      formatNumber = d3.format(".2%");
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
      .text(function (d) { return d.source.name + " sent $" + format(d.value) + " to " + d.target.name + " on " + d.date; });
    
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
      .text(function (d) { return d.name + "\n$" + format(d.value); });
    
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
  })();
