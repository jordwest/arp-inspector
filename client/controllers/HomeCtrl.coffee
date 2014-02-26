angular.module('HomeCtrl', ['Socket', 'angularMoment'])
  .controller 'HomeCtrl', ['$scope', 'socket', ($scope, socket) ->
    $scope.elements = {}
    elementId = 0

    socket.on 'devices', (devices) ->
      $scope.devices = devices

    socket.on 'arp', (arp) ->
      console.log "Arp from " + arp.from + " --> " + arp.to
      if not $scope.elements[arp.from]?
        $scope.elements[arp.from] = {
          id: elementId++
          ip: arp.from
          x: 20
          y: elementId * 20
          count: 0
        }

      if not $scope.elements[arp.to]?
        $scope.elements[arp.to] = {
          id: elementId++
          ip: arp.to
          x: 20
          y: elementId * 20
          count: 0
        }

      $scope.elements[arp.from].count++
      $scope.elements[arp.from].count = 10 if $scope.elements[arp.from].count > 10
      $scope.elements[arp.to].count++
      $scope.elements[arp.to].count = 10 if $scope.elements[arp.to].count > 10
  ]
