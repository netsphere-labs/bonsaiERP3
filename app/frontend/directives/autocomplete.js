// JavaScript version of autocomplete.coffee
// Part of the CoffeeScript to JavaScript migration

// Autocomplete for movements
myApp.directive('detailAutocomplete', function() {
  return {
    restrict: 'A',
    scope: {},
    link: function($scope, $elem, $attr) {
      const mod = $attr.ngModel;
      const model = $attr.ngModel;

      $elem.data('value', $scope.$parent.detail.item);
      // Set autocomplete
      $elem.autocomplete({
        source: $attr.source,
        select: function(event, ui) {
          const details = $scope.$parent.$parent.details;

          if (_.find(details, function(det) { return det.item_id == ui.item.id; })) {
            $elem.val('');
            $('.top-left').notify({
              type: 'warning',
              message: { text: 'Ya ha seleccionado ese ítem' }
            }).show();
            return;
          }

          $scope.$apply(function(scope) {
            const er = scope.$parent.$parent.exchange_rate;
            scope.$parent.detail.exchange_rate = er;
            scope.$parent.detail.item = ui.item.label;
            scope.$parent.detail.item_old = ui.item.label;
            scope.$parent.detail.item_id = ui.item.id;
            scope.$parent.detail.price = _b.roundVal(ui.item.price / er, 2);
            scope.$parent.detail.original_price = ui.item.price;
            scope.$parent.detail.unit_symbol = ui.item.unit_symbol;
            scope.$parent.detail.unit_name = ui.item.unit_name;
          });
        },
        search: function(event, ui) {
          $elem.addClass('loading');
        },
        response: function(event, ui) {
          $elem.removeClass('loading');
        }
      });

      $elem.blur(function() {
        $scope.$apply(function(scope) {
          if ($scope.$parent.detail.item === '') {
            scope.$parent.detail.item = ui.item.label;
            scope.$parent.detail.item_old = ui.item.label;
            scope.$parent.detail.item = ui.item.label;
            scope.$parent.detail.item_id = ui.item.id;
            scope.$parent.detail.price = ui.item.price;
            scope.$parent.detail.original_price = ui.item.price;
            scope.$parent.detail.exchange_rate = scope.$parent.$parent.exchange_rate;
          } else {
            scope.$parent.detail.item = scope.$parent.detail.item_old;
          }
        });
      });
    }
  };
})

// Autocomplete for inventories
.directive('inventoryDetailAutocomplete', function() {
  return {
    restrict: 'A',
    scope: {},
    link: function($scope, $elem, $attr) {
      const model = $attr.ngModel;
      $elem.data('value', $scope.$parent.detail.item);
      // Set autocomplete
      $elem.autocomplete({
        source: $attr.source,
        select: function(event, ui) {
          const details = $scope.$parent.$parent.details;

          if (_.find(details, function(det) { return det.item_id == ui.item.id; })) {
            $elem.val('');
            $('.top-left').notify({
              type: 'warning',
              message: { text: 'Ya ha seleccionado ese ítem' }
            }).show();
            return;
          }

          $scope.$apply(function(scope) {
            scope.$parent.detail.item = ui.item.label;
            scope.$parent.detail.item_old = ui.item.label;
            scope.$parent.detail.item_id = ui.item.id;
            scope.$parent.detail.unit = ui.item.unit_symbol;
            scope.$parent.detail.stock = ui.item.stock;
          });
        },
        search: function(event, ui) {
          $elem.addClass('loading');
        },
        response: function(event, ui) {
          $elem.removeClass('loading');
        }
      });

      $elem.blur(function() {
        $scope.$apply(function(scope) {
          if ($scope.$parent.detail.item === '') {
            scope.$parent.detail.item_id = ui.item.id;
            scope.$parent.detail.item = ui.item.label;
            scope.$parent.detail.item_old = ui.item.label;
            scope.$parent.detail.unit = ui.item.unit_symbol;
            scope.$parent.detail.stock = ui.item.stock;
          } else {
            scope.$parent.detail.item = scope.$parent.detail.item_old;
          }
        });
      });
    }
  };
});
