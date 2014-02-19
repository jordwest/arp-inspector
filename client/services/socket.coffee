angular.module('Socket', [])
  .factory 'socket', ($rootScope) ->
    socket = io.connect()
    return {
      on: (eventName, callback) ->
        socket.on eventName, () ->
          args = arguments
          $rootScope.$apply () ->
            callback.apply(socket, args)
      emit: (eventName, data, callback) ->
        socket.emit eventName, data, () ->
          args = arguments
          $rootScope.$apply () ->
            if callback
              callback.apply(socket, args)
    }
