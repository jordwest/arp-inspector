angular.module('app', ['ngRoute', 'HomeCtrl'])
  .config ['$routeProvider',
    ($routeProvider) ->
      $routeProvider.
        when '/', {
          templateUrl: 'partials/home.html',
          controller: 'HomeCtrl'
        }
  ]
