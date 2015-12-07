'use strict'

angular.module("extendi.business-hours", ['pascalprecht.translate', 'extendi.business-hours.tpl']).
  config(['$translateProvider', ($translateProvider) ->
    $translateProvider.translations('en',
      "business-hours.weekdays": "Week days"
      "business-hours.weekend": "Weekend"
      "business-hours.alldays": "All days"
    )
    $translateProvider.translations('it',
      "business-hours.weekdays": "Giorni feriali"
      "business-hours.weekend": "Fine settimana"
      "business-hours.alldays": "Tutti i giorni"
    )
    $translateProvider.preferredLanguage('it')
    $translateProvider.useSanitizeValueStrategy('escapeParameters')
  ]).
  directive('businessHours', ->
    restrict: 'E'
    scope:
      model: "="
    controller: "BusinessHoursCtrl"
    templateUrl: "templates/hours.html"
  ).
  directive('businessHoursInput', ->
    restrict: 'E'
    scope:
      model: "="
    controller: "BusinessHoursCtrl"
    templateUrl: "templates/hours_input.html"
  ).
  controller("BusinessHoursCtrl", [
    "$scope"
    "$q"
    "$translate"
    "$locale"
    ($scope, $q, $translate, $locale) ->
      $scope.days = [0..6]
      $scope.days_label =  angular.copy($locale.DATETIME_FORMATS.DAY)
      dom = $scope.days_label.shift()
      $scope.days_label.push(dom)
      
      $scope.weekdays = [0..4]
      
      $scope.weekend = [5..6]
      
      $scope.range_hours = ->
        hours = _.range(0, 24)
        _.flatten(
          _.map([0,15,30,45], (mins) ->
            _.map(hours, (hour) ->
              "#{_.padLeft(hour, 2, '0')}:#{_.padLeft(mins, 2, '0')}"
            )
          )
        )
        
      $scope.hours_for = (hours, day) ->
        _.sortBy(_.where(hours, {days: [day]}), (item) -> item.start)
      
      $scope.toggle_day = (hour, index) ->
        if (i = _.indexOf(hour.days, $scope.days[index])) >= 0
          hour.days.splice(i, 1)
        else
          hour.days.push($scope.days[index])
          hour.days = _.sortBy(hour.days, (day) ->
            _.indexOf($scope.days, day)
          )
    
      $scope.days_group_label = (days) ->
        return "business-hours.weekdays" if _.xor(days, $scope.weekdays).length == 0
        return "business-hours.weekend" if _.xor(days, $scope.weekend).length == 0
        return "business-hours.alldays" if _.xor(days, $scope.days).length == 0
        return _.map(days, (day) -> 
          ($scope.days_label[day])[0..2]).join(",") if days.length > 0
        return "Scegli un giorno"
      
      $scope.add_hour = ->
        value = if $scope.model.length > 0
          {days: []}
        else
          {days: angular.copy($scope.weekdays)}
          
        $scope.model.push(value)
    
      $scope.remove_hour = (index) ->
        $scope.model.splice(index, 1)
      
      $scope.checked_day = (days, day) ->
        if _.include(days, day)
          true
        else
          false
  ])
