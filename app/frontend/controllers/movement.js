// JavaScript version of movement.coffee
// Part of the CoffeeScript to JavaScript migration

// Controller for incomes and expenses
const MovementController = function($scope, $window, MovementDetail) {
  $scope.currency = $('#currency').val();
  $scope.same_currency = true;
  $scope.details = [];
  $scope.direct_payment = $('#direct_payment').prop('checked');
  $scope.tax_in_out = $('#tax_in_out').prop('checked');
  $scope.tax_label = 'Outside';
  $scope.taxes = angular.element('#taxes').data('taxes');
  $scope._destroy = '0';
  //$scope.exchange_rate = $('#exchange_rate').val() * 1;
  $scope.calls = 0;
  $scope.accounts = angular.element('#accounts').data('accounts');

  $scope.same_currency = $scope.currency === $window.organisation.currency;

  // Set tax
  const tax_id = $('#tax_id').val() * 1;
  if (tax_id > 0) {
    $scope.tax = _.find($scope.taxes, function(v) { return v.id == tax_id; });
  }

  // ng-class Does not work fine with bootstrap buttons javascript
  if ($scope.tax_in_out) $('#tax-in-out-btn').addClass('active');
  if ($scope.direct_payment) $('#direct-payment-button').addClass('active');

  // initialize items
  const detailsData = $('#details').data('details');
  for (let i = 0; i < detailsData.length; i++) {
    const det = detailsData[i];
    det.item_old = det.item;
    det.price = parseFloat(det.price);
    det.quantity = parseFloat(det.quantity);
    $scope.details.push(new MovementDetail(det));
  }

  // Remove an item
  $scope.destroy = function(index) {
    if ($scope.details.length === 1) {
      // Alert message
      return;
    }

    if ($scope.details[index].id != null) {
      $scope.details[index]._destroy = 1;
      $scope.details[index].quantity = 0;
    } else {
      $scope.details.splice(index, 1);
    }
  };

  // Changes the exchange_rates on the details
  $scope.updateDetailsExchangeRate = function(rate) {
    // Implementation left empty in original
  };

  // Check for the change in currency and activate all methods
  $scope.$watch('currency', function(current, old, scope) {
    if (current !== old) {
      const curr = $window.organisation.currency;
      scope.same_currency = current === curr;
      scope.exchange_rate = fx.convert(1, { from: current, to: curr }).toFixed(4) * 1;
      // Set all classes to correct currency
      $('.currency').html(_b.currencyLabel(scope.currency));
    }
  });

  // Check for changes on exchange_rate to update details
  $scope.$watch('exchange_rate', function() {
    $scope.calls += 1;
    if ($scope.calls === 1) return;
    
    for (let i = 0; i < $scope.details.length; i++) {
      const det = $scope.details[i];
      det.price = _b.roundVal(det.original_price / $scope.exchange_rate, 2);
    }
  });

  // add details
  $scope.addDetail = function() {
    $scope.details.push(new MovementDetail({quantity: 1}));
  };

  // Tax id
  $scope.setTaxId = function() { 
    $scope.tax_id = $scope.tax.id;
  };

  // Tax label
  $scope.taxLabel = function() {
    return $scope.tax_in_out === true ? 'Inside' : 'Outside';
  };

  // Subtotal
  $scope.subtotal = function() {
    return _.reduce($scope.details, function(s, det) {
      return s + det.subtotal();
    }, 0);
  };

  $scope.taxTotal = function() {
    const sub = $scope.subtotal();
    if ($scope.tax && $scope.tax_in_out) {
      return sub - (sub / (1 + $scope.tax.percentage / 100));
    } else if ($scope.tax && $scope.tax_in_out === false) {
      return sub * ($scope.tax.percentage / 100);
    } else {
      return 0;
    }
  };

  // total
  $scope.total = function() {
    if ($scope.tax_in_out) {
      return $scope.subtotal();
    } else {
      return $scope.subtotal() + $scope.taxTotal();
    }
  };

  // Any valid item
  $scope.anyValidItem = function() {
    return _.any(_.map($scope.details, function(det) { 
      return det.valid(); 
    }));
  };

  // Validation using jquery, not really angular way
  $('form.movement-form').on('submit', function(event) {
    if ($scope.anyValidItem()) {
      return true;
    } else {
      event.preventDefault();
      $.notify('You must select at least one item', { className: 'error', position: 'top right' });
    }
  });

  // Add new item with add button
  $('body').on('ajax-call', '.movement-details a.add-new-item', function(event, resp) {
    const scope = $(this).parents('li.row-fluid:first').scope();

    scope.$apply(function(sc) {
      sc.detail.exchange_rate = $scope.exchange_rate;
      sc.detail.item = resp.label;
      sc.detail.item_old = resp.label;
      sc.detail.item_id = resp.id;
      sc.detail.price = _b.roundVal(resp.price / $scope.exchange_rate, 2);
      sc.detail.original_price = resp.price;
    });
  });

  $('body').on('ajax-call', 'a.add-new-tax', function(event, resp) {
    $scope.$apply(function(scope) {
      const tax = { id: resp.id, name: resp.name, percentage: resp.percentage };
      scope.taxes.push(tax);
      scope.tax = tax;
      scope.tax_id = tax.id;
    });
  });
};

MovementController.$inject = ['$scope', '$window', 'MovementDetail'];
myApp.controller('MovementController', MovementController);
