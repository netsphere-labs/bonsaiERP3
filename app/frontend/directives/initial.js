// JavaScript version of initial.coffee
// Part of the CoffeeScript to JavaScript migration

myApp.directive('initial', function() {
  return {
    restrict: 'A',
    controller: [
      '$scope', '$element', '$attrs', '$parse', function($scope, $element, $attrs, $parse) {
        let val = $attrs.value || $attrs.ngInitial;
        if ($attrs.type === 'number') {
          val = val * 1;
        }

        const getter = $parse($attrs.ngModel);
        const setter = getter.assign;
        setter($scope, val);
      }
    ]
  };
})
.directive('ngMovementAccounts', function() {
  return {
    restrict: 'A',
    controller: ['$scope', '$element', '$attrs', function($scope, $element, $attrs) {
      $scope.accounts = $('#accounts').data('accounts');

      // Set select2
      $element.select2({
        data: $scope.accounts,
        minimumResultsForSearch: $scope.accounts.length > 8 ? 1 : -1,
        formatResult: Plugin.paymentOptions,
        formatSelection: Plugin.paymentOptions,
        escapeMarkup: function(m) { return m; },
        dropdownCssClass: 'hide-select2-search',
        placeholder: 'Seleccione la cuenta',
        formatNoMatches: function(term) { return 'No se encontro resultados'; }
      })
      .on('change', function(event) {
        const data = $element.select2('data');
        $scope.currency = data.currency;
      });

      $scope.$watch('account_to_id', function(ac_id) {
        $element.select2('val', ac_id);
      });
    }]
  };
});
