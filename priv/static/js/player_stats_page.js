var chart = c3.generate({
    bindto: "#playerChart",
    size: {
        height: 600
    },
    data: {
        columns: [
            ["test", 1, 30, 2001, 8000]
        ]
    },
    axis: {
        y: {
            inverted: true,
            min: 1,
            padding: 0
        }
    },
    grid: {
        x: {
            show: true
        },
        y: {
            show: true
        }
    },
    subchart: {
        show: true
    },
    zoom: {
        enabled: true
    }
});
var new_proto = {
    getY: function(min, max, domain) {
        // https://github.com/masayuki0812/c3/blob/931109f8269688b8d623b4523335670dd813b4dc/src/scale.js
        if (this.isTimeSeriesY()) {
            throw "Log time series scale not supported.";
        }
        var scale = d3.scale.log().range([min, max]);
        if(domain) { 
            scale.domain(domain);
        }
        return scale;
    },
    getYDomain: function(targets, axisId, xDomain) {
        var orig = new_proto.__proto__.getYDomain.call(this, targets, axisId, xDomain);
        console.log(orig);
        if ((orig[0] == 0) && (orig[1] == 1)) return [1, 2];
        return [orig[0], 1];
    }
};
new_proto.__proto__ = chart.internal.__proto__;
chart.internal.__proto__ = new_proto;
chart.internal.updateScales();
console.log(chart);
