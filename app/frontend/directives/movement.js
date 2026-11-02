// JavaScript version of movement.coffee
// Part of the CoffeeScript to JavaScript migration

// Go to directives/initial.js
// This file is kept for reference only, as the functionality has been moved to initial.js
// The original code was commented out in the CoffeeScript version as well.

/*
myApp.directive('ngMovementAccounts', function() {
  return {
    restrict: 'A',
    controller: ['$scope', '$element', '$attrs', function($scope, $element, $attrs) {
      $scope.accounts = $('#accounts').data('accounts');

      console.log($scope.account);
      // Set select2
      $element.select2({
        data: $scope.accounts,
        formatResult: Plugin.paymentOptions,
        formatSelection: Plugin.paymentOptions,
        escapeMarkup: function(m) { return m; },
        dropdownCssClass: 'hide-select2-search',
        placeholder: 'Seleccione la cuenta'
      })
      .on('change', function(event) {
        const data = $element.select2('data');
        $scope.currency = data.currency;
      });
    }]
  };
});
*/
