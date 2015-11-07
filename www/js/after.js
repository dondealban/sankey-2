
    var node_colors = JSON.parse('{"Z": "#FF6A6A", "o": "#FF6A6A", "X": "#90EE90", "m": "#90EE90", "d": "#90EE90", "R": "#90EE90", "k": "#90EE90", "F": "#FF6A6A", "s": "#90EE90", "B": "#90EE90", "O": "#90EE90", "v": "#90EE90", "t": "#90EE90", "i": "#90EE90", "D": "#90EE90", "u": "#90EE90", "T": "#90EE90", "j": "#90EE90", "n": "#90EE90", "H": "#90EE90", "J": "#90EE90", "Q": "#90EE90", "C": "#90EE90", "E": "#90EE90", "g": "#90EE90", "q": "#90EE90", "x": "#90EE90", "K": "#90EE90", "A": "#90EE90", "U": "#90EE90", "N": "#90EE90", "M": "#90EE90", "L": "#90EE90", "Y": "#90EE90", "W": "#90EE90", "f": "#90EE90", "e": "#90EE90", "c": "#90EE90", "p": "#90EE90", "z": "#90EE90", "S": "#90EE90"}');
    d3.selectAll("#sankey svg .node rect")
      .style("fill", function(d) { return node_colors[d.name] })
      .style("stroke", function(d) { d3.rgb(node_colors[d.name]).darker(2); })

    d3.selectAll("#sankey svg .node rect title")
      .style("color", "#FF6A6A")
  
    d3.selectAll("#sankey svg path.link")
      .style("stroke", function(d) { return "#66CCFF" })
