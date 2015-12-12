var d3 = require("d3");

var parseTime = d3.time.format("%Y-%m-%d %H:%M:%S").parse;

var margin = {top: 10 + 8, right: 10 + 8, bottom: 100 + 8, left: 40 + 8},
    margin2 = {top: 530 - 8, right: 10 + 8, bottom: 20 + 16, left: 40 + 8},
    width = 960 - margin.left - margin.right,
    height = 600 - margin.top - margin.bottom,
    height2 = 600 - margin2.top - margin2.bottom;

function nestedExtent(nested, accessor) {
    return [d3.min(nested, function(d) {
        return d3.min(d, accessor);
    }), d3.max(nested, function(d) {
        return d3.max(d, accessor);
    })];
}

function padExtent(extent, padding) {
    return [extent[0]-padding, extent[1]+padding];
}

function parseDatapoint(data) {
    return [parseTime(data[0]), data[1]];
}

export default class PlayerStatsGraph {
    constructor(elementSelector) {
        this.width = 960 - margin.left - margin.right;
        this.colorAccessor = (num) => "steelblue";

        this.x = d3.time.scale().range([0, this.width]);
        this.x2 = d3.time.scale().range([0, this.width]);
        this.y = d3.scale.linear().range([height, 0]);
        this.y2 = d3.scale.linear().range([height2, 0]);

        this.xAxis = d3.svg.axis().scale(this.x).orient("bottom");
        this.xAxis2 = d3.svg.axis().scale(this.x2).orient("bottom");
        this.yAxis = d3.svg.axis().scale(this.y).orient("left")
            .tickFormat(d => this.y.tickFormat(4, d3.format(",d"))(d))

        this.brush = d3.svg.brush()
            .x(this.x2)
            .on("brush", this.brushed.bind(this));

        this.area = d3.svg.line()
            .interpolate("step")
            .x(d => this.x(d[0]))
            .y(d => this.y(d[1]));

        this.area2 = d3.svg.line()
            .interpolate("step")
            .x(d => this.x2(d[0]))
            .y(d => this.y2(d[1]));

        this.element = d3.select(elementSelector);

        this.svg = this.element.append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom);

        this.defs = this.svg.append("defs")
            .append("clipPath").attr("id", "clip");

        this.clip = this.defs.append("rect")
            .attr("width", this.width)
            .attr("height", height);

        this.focus = this.svg.append("g")
            .attr("class", "focus")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        this.context = this.svg.append("g")
            .attr("class", "context")
            .attr("transform", "translate(" + margin2.left + "," + margin2.top + ")");

        d3.select(window).on("resize", this.resize.bind(this));
        this.resize();
    }

    updateData(data) {
        var lines = d3.values(data.leaderboards);
        var lines_values = lines.map(d => {
            return d.values.map(v => parseDatapoint(v))
                .concat([parseDatapoint([data.time_now, d.current[1]])]);
        });
        console.log(lines_values);

        this.x.domain(nestedExtent(lines_values, d => d[0]));
        this.y.domain(padExtent(nestedExtent(lines_values, d => d[1]), 10));
        this.x2.domain(this.x.domain());
        this.y2.domain(this.y.domain());

        this.focus.selectAll(".line")
            .data(lines_values)
            .enter().append("path")
            .attr("stroke", (dat, num) => this.colorAccessor(num))
            .attr("class", "line")
            .attr("d", this.area);

        this.focus.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(this.xAxis);

        this.focus.append("g")
            .attr("class", "y axis")
            .call(this.yAxis);

        this.context.selectAll(".line")
            .data(lines_values)
            .enter().append("path")
            .attr("stroke", (dat, num) => this.colorAccessor(num))
            .attr("class", "line")
            .attr("d", this.area2);

        this.context.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height2 + ")")
            .call(this.xAxis2);

        this.context.append("g")
            .attr("class", "x brush")
            .call(this.brush)
            .selectAll("rect")
            .attr("y", -6)
            .attr("height", height2 + 7);
    }

    resize() {
        console.log(this.element);
        this.width = +(this.element.style("width").replace("px",  ""))
            - margin.left - margin.right;

        this.x.range([0, this.width]);
        this.x2.range([0, this.width]);
        this.svg.attr("width", this.width + margin.left + margin.right);
        this.clip.attr("width", this.width);
    }

    brushed() {
        this.x.domain(this.brush.empty() ? this.x2.domain() : this.brush.extent());
        this.focus.selectAll(".line").attr("d", this.area);
        this.focus.select(".x.axis").call(this.xAxis);
    }

    colors(accessor) {
        this.colorAccessor = accessor;
    }
}
