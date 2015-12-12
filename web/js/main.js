var d3 = require("d3");
var mdl = require("exports?componentHandler!material-design-lite/material.js");
var _ = require("lodash");

import PlayerStatsGraph from "./player_stats_graph";

window.addEventListener("load", function() {

    if (d3.select("meta[name='show_player_rank_graph']") != null) {
        var colors = d3.scale.category10();
        var categories = ["s3v3", "3v3", "2v2", "1v1"];
        var categoryColors = _.object(_.map(categories, (cat, idx) => [cat, colors(idx)]));
        _.each(categories, (category, idx) => {
            d3.select("#l_" + category + "_color")
                .style("border-bottom", categoryColors[category] + " 3px solid");
        });

        var graph = new PlayerStatsGraph("#playerChart");
        graph.colors(num => colors(num));

        var player_id = d3.select("meta[name='player_id']").attr("content");
        var player_platform = d3.select("meta[name='player_platform']").attr("content");

        var url = "/api/player/" + player_platform + "/" 
            + player_id + "/values/" + categories.join(",");

        d3.json(url, function(data) {
            console.log(data);

            var leaderboards = d3.values(data.leaderboards);
            var leaderboardsLength = leaderboards.length;
            for (var i = 0; i < leaderboardsLength; i++) {
                var leaderboard = leaderboards[i];
                d3.select("#l_" + leaderboard.url_id +  "_value")
                    .text(leaderboard.current[1]);
            }

            graph.updateData(data);
        });
    }

});

