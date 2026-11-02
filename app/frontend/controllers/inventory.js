// JavaScript version of inventory.coffee
// Part of the CoffeeScript to JavaScript migration

myApp.controller('InventoryController', ['$scope', function($scope) {
  $scope.details = $('#details').data('details');

  // Remove detail item
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

  // Add new detail
  $scope.addDetail = function() {
    $scope.details.push({
      item_id: null, 
      item: null, 
      unit: null, 
      quantity: 0.0, 
      stock: 0.0
    });
  };

  // Handle ajax-call event for adding new items
  $('body').on('ajax-call', 'table a.add-new-item', function(event, resp) {
    const $parent = $(this).parents('tr:first');
    $parent.find('.item-name').data('value', resp.label);
    const scope = $parent.scope();

    scope.$apply(function(sc) {
      sc.detail.item_id = resp.id;
      sc.detail.item_old = resp.label;
      sc.detail.item = resp.label;
      sc.detail.unit = resp.unit_symbol;
      sc.detail.quantity = 0;
      sc.detail.stock = 0;
    });
  });
}]);
