// JavaScript version of batch_operations.coffee
// Part of the CoffeeScript to JavaScript migration

const batchOperations = function($http, $window) {
  return {
    restrict: 'E',
    transclude: true,
    controller: function($scope, $attrs, $element) {
      if ($attrs.modelType === 'Income') {
        $scope.paymentText = 'Cobro multiple';
        $scope.inventoryText = 'Entrega inventario multiple';
      } else {
        $scope.paymentText = 'Pago multiple';
        $scope.inventoryText = 'Recojo inventario multiple';
      }

      $scope.modelName = $attrs.modelName;
      const accounts = [];

      $scope.redirectUrl = $window.location.href;

      const setAccountSelect2 = function(accounts) {
        accounts.forEach(function(account) { 
          account.to_s = account.name;
        });
        console.log(accounts);
        // Set select2
        $element.find('#account_to_id').select2({
          data: accounts,
          minimumResultsForSearch: accounts.length > 8 ? 1 : -1,
          formatResult: Plugin.paymentOptions,
          formatSelection: Plugin.paymentOptions,
          escapeMarkup: function(m) { return m; },
          dropdownCssClass: 'hide-select2-search',
          placeholder: 'Seleccione la cuenta',
          formatNoMatches: function(term) { return 'No se encotro cuentas'; }
        })
        .on('change', function(event) {
          const data = $(this).select2('data');
        });
      };

      // Load accounts
      const loadAccounts = function() {
        $http.get('/banks/money')
        .success(function(resp) {
          accountsLoaded = true;
          setAccountSelect2(resp);
        });
      };

      $scope.movements = [];

      // Make payments
      $scope.makePayments = function() {
        $scope.paying = true;
        const ids = $scope.movements.map(function(mov) { 
          return mov.id; 
        });

        $http.post($attrs.url, { ids: ids, account_to_id: $scope.account_to_id})
        .success(function(resp, status) {
          $scope.paying = false;
          if (resp.success) {
            $scope.showPaymentMessage = true;
          } else {
            alert('Usted no tiene privilegios para realizar esta operación');
          }
        })
        .error(function() {
          $scope.paying = false;
        });
      };

      $scope.multiplePayments = function() {
        $scope.modalTitle = $scope.paymentText;
        if (!(accounts.length === 0)) {
          loadAccounts();
        }

        $element.find('.pay-button').show();
        $element.find('.inv-button').hide();

        $scope.movements = [];
        $('input.row-check:checked').each(function(i, el) {
          const $el = $(el);
          $scope.movements.push({
            id: el.id, 
            name: $el.attr('code-name')
          });
        });

        return true;
      };
    },
    
    link: function($scope, $elem, $attrs, $ctrl, transclude) {
      $elem.find('[ng-transclude]').replaceWith(transclude());
    },
    
    template: 
      '<div class="btn-group">' +
      '  <a href class="btn dropdown-toggle" data-toggle="dropdown">' +
      '    Operaciones' +
      '    <i class="icon-caret-down"></i>' +
      '  </a>' +
      '  <ul class="dropdown-menu text-left">' +
      '    <li>' +
      '      <a href' +
      '      data-target="#multiple-operations-modal" data-toggle="modal"' +
      '      ng-click="multiplePayments()">' +
      '        {{ paymentText }}' +
      '      </a>' +
      '    </li>' +
      '    <!--<li>' +
      '      <a href="javascript:;">{{ inventoryText }}</a>' +
      '    </li>-->' +
      '    <div ng-transclude></div>' +
      '  </ul>' +
      '</div>' +
      '' +
      '<div class="modal hide fade" id="multiple-operations-modal">' +
      '  <div class="modal-dialog">' +
      '    <div class="modal-content l">' +
      '      <div class="modal-header">' +
      '        <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>' +
      '        <h3>{{ modalTitle }}</h3>' +
      '      </div>' +
      '      <div class="modal-body">' +
      '        <div class="modal-payments">' +
      '          Seleccionados:' +
      '          <strong ng-repeat="mov in movements">' +
      '            {{ mov.name }}' +
      '          </strong>' +
      '' +
      '          <h4 class="red" ng-show="movements.length <= 0">Debe seleccionar al menos un {{ modelName }}</h4>' +
      '' +
      '          <label>Seleccione una cuenta</label>' +
      '          <input type="text" id="account_to_id" ng-model="account_to_id" class="span11" />' +
      '          <div class="clearfix"></div>' +
      '          <h3 ng-show="showPaymentMessage">' +
      '            Se completo la operación, por favor' +
      '            <a href="{{ redirectUrl }}">recargue la página</a>' +
      '          </h3>' +
      '        </div>' +
      '' +
      '        <div class="modal-inventories">' +
      '        </div>' +
      '' +
      '      </div>' +
      '      <div class="modal-footer">' +
      '        <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>' +
      '        <button type="button" class="btn btn-primary pay-button" ng-click="makePayments()" ng-disabled="paying">{{ paymentText }}</button>' +
      '        <button type="button" class="btn btn-primary inv-button">{{ inventoryText }}</button>' +
      '      </div>' +
      '    </div><!-- /.modal-content -->' +
      '  </div><!-- /.modal-dialog -->' +
      '</div>'
  };
};

batchOperations.$inject = ['$http', '$window'];

myApp.directive('batchOperations', batchOperations);
