angular.module('HomeCtrl', ['Socket', 'angularMoment'])
  .controller 'HomeCtrl', ['$scope', 'socket', ($scope, socket) ->
    elements = {}
    connections = {}

    nodes = []
    links = []
    elementId = 0
    connectionId = 0
    inProgress = false

    $scope.width = 1000
    $scope.height = 800

    socket.on 'devices', (devices) ->
      $scope.devices = devices

    svg = d3.select('#network-graph').append('svg')
      .attr('width', $scope.width)
      .attr('height', $scope.height)

    force = d3.layout.force()
      .charge(-650)
      .linkDistance(60)
      .gravity(0.4)
      .friction(0.7)
      .size([$scope.width, $scope.height])
      .nodes(nodes)
      .links(links)
      .start()

    updatePositions = ->
      link = svg.selectAll('.link')
      node = svg.selectAll('.node')
      text = svg.selectAll('.text')
      link.attr('x1', (d) -> d.source.x)
      link.attr('y1', (d) -> d.source.y)
      link.attr('x2', (d) -> d.target.x)
      link.attr('y2', (d) -> d.target.y)

      node.attr('cx', (d) -> d.x)
      node.attr('cy', (d) -> d.y)

      text.attr('x', (d) -> d.x)
      text.attr('y', (d) -> d.y + 10)

    reloadGraph = ->
      link = svg.selectAll('.link')
      node = svg.selectAll('.node')
      text = svg.selectAll('.text')
      node
        .data(nodes)
        .attr('class', 'node')
        .attr('r', (d) -> if d.alive then 10 else 2)
        .style('fill', (d) -> if d.alive then '#090' else '#333')
        .enter().append('circle')
        .attr('class', 'node')
        .attr('r', (d) -> if d.alive then 10 else 2)
        .style('fill', (d) -> if d.alive then '#090' else '#333')
        .call(force.drag)
      link
        .data(links)
        .enter().append('line')
        .attr('class', 'link')
        .style('stroke-width', 1)
        .style('stroke', '#999')
      text
        .data(nodes)
        .attr('font-size', (d) -> if d.alive then 10 else 8)
        .enter().append('text')
        .attr('font-size', (d) -> if d.alive then 10 else 8)
        .attr('class', 'text')
        .text((d) -> d.ip)
        .attr('text-anchor', 'middle')
        .call(force.drag)

    force.on('tick', () ->
      updatePositions()
    )

    socket.on 'arp', (arp) ->
      newItem = false
      if not elements[arp.from]?
        elements[arp.from] = nodes.push({
          ip: arp.from
          alive: false
        })- 1
        newItem = true
      nodes[elements[arp.from]].alive = true

      if not elements[arp.to]?
        elements[arp.to] = nodes.push({
          ip: arp.to
          alive: false
        }) - 1
        newItem = true

      if not connections[arp.from+'-'+arp.to]?
        connections[arp.from+'-'+arp.to] = connectionId++
        links.push {
          from: arp.from
          to: arp.to
          count: 0
          source: elements[arp.from]
          target: elements[arp.to]
        }
        newItem = true

      links[connections[arp.from+'-'+arp.to]].count++
      ###
      force.nodes(nodes)
        .links(links)
      ###
      force.start()
      reloadGraph()

    undefined
  ]
