$(document).ready(function() {

  $('[rel="tooltip"]').tooltip({});

  $('a[data-d3-target]').each(function () {
    var el = $(this);

    el.on('click', function (e) {
      d3.json(el.data('d3-source'), function (data) {
        var target = $(el.data('d3-target'));

        var w = target.width() / (d3.max(data, function (d) { return d.x; }) + 1);
        var h = target.height();

        var x = d3.scale.linear()
          .domain([0, 1])
          .range([0, w]);

        var y = d3.scale.linear()
          .domain([0, d3.max(data, function (d) { return d.y; })])
          .rangeRound([0, h]);

        var chart = d3.select(el.data('d3-target')).append('svg')
          .attr('class', 'd3-chart');

        chart.selectAll('rect')
          .data(data, function (d) { return d.x; })
        .enter()
          .append('rect')
          .attr('x', function(d, i) { return x(d.x) - 0.5; })
          .attr('y', function(d) { return h - y(d.y) - 0.5; })
          .attr('width', w)
          .attr('height', function(d) { return y(d.y); });

        // labels y
        chart.selectAll('text.y-axis').
          data(data, function (d) { return d.x; })
        .enter()
          .append('svg:text')
          .attr('x', function(d, i) { return x(d.x) - 0.5; })
          .attr('y', function(d) { return h - y(d.y) - 0.5; })
          .attr('dx', w / 2)
          .attr('dy', '1.2em')
          .attr('text-anchor', 'middle')
          .text(function(d) { return d.label.y })
          .attr('class', 'y-axis');

        // labels x
        chart.selectAll('text.x-axis').
          data(data, function (d) { return d.x; })
        .enter()
          .append('svg:text')
          .attr('x', function(d, i) { return x(d.x) - 0.5; })
          .attr('y', function(d) { return h - 0.5; })
          .attr('dx', w / 2)
          .attr('dy', '1.2em')
          .attr('text-anchor', 'middle')
          .text(function(d) { return d.label.x })
          .attr('class', 'x-axis');
      });
    });

    if (el.data('d3-active') === true) {
      el.click();
    }
  });
});
