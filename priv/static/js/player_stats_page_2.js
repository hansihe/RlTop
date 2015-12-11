var parseTime = d3.time.format("%Y-%m-%d %H:%M:%S").parse;

var margin = {top: 10 + 16, right: 10 + 32, bottom: 100 + 16, left: 40 + 32},
    margin2 = {top: 430 - 16, right: 10 + 32, bottom: 20 + 16, left: 40 + 32},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom,
    height2 = 500 - margin2.top - margin2.bottom;

var x = d3.time.scale().range([width, 0]),
    x2 = d3.time.scale().range([width, 0]),
    y = d3.scale.linear().range([0, height]),
    y2 = d3.scale.linear().range([0, height2]);

var xAxis = d3.svg.axis().scale(x).orient("bottom"),
    xAxis2 = d3.svg.axis().scale(x2).orient("bottom"),
    yAxis = d3.svg.axis().scale(y).orient("left")
        .tickFormat(function(d) {
            return y.tickFormat(4, d3.format(",d"))(d)
        });

var brush = d3.svg.brush()
    .x(x2)
    .on("brush", brushed);

var area = d3.svg.line()
    .interpolate("step")
    .x(function(d) { return x(d[0]) })
    .y(function(d) { return y(d[1]) });

var area2 = d3.svg.line()
    .interpolate("step")
    .x(function(d) { return x2(d[0]) })
    .y(function(d) { return y2(d[1]) });

var svg = d3.select("#playerChart").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom);

var defs = svg.append("defs")
    .append("clipPath").attr("id", "clip");

var clip = defs.append("rect").attr("width", width).attr("height", height);

var focus = svg.append("g")
    .attr("class", "focus")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var context = svg.append("g")
    .attr("class", "context")
    .attr("transform", "translate(" + margin2.left + "," + margin2.top + ")");

d3.select(window).on("resize", resize);
function resize() {
    width = +(d3.select("#playerChart").style("width").replace("px", ""));
    console.log(d3.select("#playerChart").style("width"));
    width = width - margin.left - margin.right;
    x.range([width, 0]);
    x2.range([width, 0]);
    svg.attr("width", width + margin.left + margin.right);
    clip.attr("width", width);
}
resize();
//76561198009833263
//76561198187511543

function nestedExtent(nested, accessor) {
    return [d3.max(nested, function(d) {
        return d3.max(d, accessor);
    }), d3.min(nested, function(d) {
        return d3.min(d, accessor);
    })];
}

d3.json("/api/player/steam/76561198187511543/values/s3v3,3v3,2v2,1v1", function(data) {
    var lines = d3.values(data.leaderboards).map(function(d) { return d; });
    var lines_values = lines.map(function(d) {
        return d.values.map(function(v) {
            return [parseTime(v[0]), v[1]];
        });
    });
    console.log(lines_values);

    x.domain(nestedExtent(lines_values, function(d) { return d[0]; }));
    y.domain(nestedExtent(lines_values, function(d) { return d[1]; }));
    x2.domain(x.domain());
    y2.domain(y.domain());

    focus.selectAll(".line")
        .data(lines_values)
        .enter().append("path")
        .attr("class", "line")
        .attr("d", area);

    focus.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    focus.append("g")
        .attr("class", "y axis")
        .call(yAxis);

    context.selectAll(".line")
        .data(lines_values)
        .enter().append("path")
        .attr("class", "line")
        .attr("d", area2);

    context.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height2 + ")")
        .call(xAxis2);

    context.append("g")
        .attr("class", "x brush")
        .call(brush)
        .selectAll("rect")
        .attr("y", -6)
        .attr("height", height2 + 7);
});

function brushed() {
    var extent = brush.extent();
    x.domain(brush.empty() ? x2.domain() : [extent[1], extent[0]]);
    focus.selectAll(".line").attr("d", area);
    focus.select(".x.axis").call(xAxis);
}
