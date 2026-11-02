// JavaScript version of loan.coffee
// Part of the CoffeeScript to JavaScript migration

// Controller for creating the Loans
myApp.controller('LoanController', ['$scope', function($scope) {
  $scope.accounts = angular.element('#accounts').data('accounts');
  $scope.same_currency = true;

  // Set select2
  $('#account_to_id').select2({
    data: $scope.accounts,
    minimumResultsForSearch: $scope.accounts.length > 8 ? 1 : -1,
    formatResult: Plugin.paymentOptions,
    formatSelection: Plugin.paymentOptions,
    escapeMarkup: function(m) { return m; },
    dropdownCssClass: 'hide-select2-search',
    placeholder: 'Seleccione la cuenta'
  })
  .on('change', function(event) {
    const data = $(this).select2('data');
    const sc = $scope.baseCurrency === data.currency;
    
    $scope.$apply(function(scope) {
      scope.same_currency = sc;
      const rate = fx.convert(1, { from: data.currency, to: $scope.baseCurrency }).toFixed(4) * 1;
      scope.exchange_rate = rate;
    });
    
    $('.currency').html(_b.currencyLabel(data.currency));
  });
}]);
