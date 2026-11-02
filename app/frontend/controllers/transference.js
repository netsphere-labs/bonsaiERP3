// JavaScript version of transference.coffee
// Part of the CoffeeScript to JavaScript migration

// Controller for creating the payments
myApp.controller('TransferenceController', ['$scope', function($scope) {
  $scope.accounts = angular.element('#accounts').data('accounts');
  $scope.same_currency = true;
  $scope.amount_currency = 0;
  $scope.is_bank = false;

  $scope.isInverse = function() {
    return organisation.currency !== $scope.base_currency;
  };

  $scope.amountCurrency = function() {
    if ($scope.isInverse()) {
      return $scope.amount * $scope.exchange_rate;
    } else {
      return $scope.amount / $scope.exchange_rate;
    }
  };

  // Set select2
  $('#account_to_id').select2({
    data: $scope.accounts,
    formatResult: Plugin.paymentOptions,
    formatSelection: Plugin.paymentOptions,
    escapeMarkup: function(m) { return m; },
    dropdownCssClass: 'hide-select2-search',
    placeholder: 'Seleccione la cuenta'
  })
  .on('change', function(event) {
    const data = $(this).select2('data');
    
    $scope.$apply(function(scope) {
      scope.same_currency = $scope.base_currency === data.currency;
      scope.is_bank = data.type === 'Bank';

      let rate;
      if ($scope.isInverse()) {
        rate = fx.convert(1, {to: data.currency, from: $scope.base_currency}).toFixed(4) * 1;
      } else {
        rate = fx.convert(1, {from: data.currency, to: $scope.base_currency}).toFixed(4) * 1;
      }

      scope.exchange_rate = rate;
    });
    
    $('.currency').html(_b.currencyLabel(data.currency));
  });
}]);
