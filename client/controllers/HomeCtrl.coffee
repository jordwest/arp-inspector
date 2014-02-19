angular.module('HomeCtrl', ['Socket', 'angularMoment'])
  .controller 'HomeCtrl', ['$scope', 'socket', ($scope, socket) ->
    socket.on 'devices', (devices) ->
      $scope.devices = devices

    socket.on 'otherInspectors', (otherInspectors) ->
      $scope.otherInspectors = otherInspectors
  ]
