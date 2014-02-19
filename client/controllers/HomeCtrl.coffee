angular.module('HomeCtrl', ['Socket'])
  .controller 'HomeCtrl', ['$scope', 'socket', ($scope, socket) ->
    socket.on 'devices', (devices) ->
      console.log "Got devices", devices
      $scope.devices = devices
  ]
