// JavaScript version of movement_detail.coffee
// Part of the CoffeeScript to JavaScript migration

myApp.factory('MovementDetail', [function($resource) {
  class MovementDetail {
    constructor(attributes) {
      this.attributes = attributes;
      this.default = {
        id: null,
        item_id: null,
        item: null,
        item_old: null,
        unit_name: null,
        unit_symbol: null,
        itemAttributes: {},
        quantity: 1,
        price: 0,
        original_price: 0,
        exchange_rate: 1,
        _destroy: 0,
        errors: {}
      };
      
      // Assign default values or values from attributes
      for (const [key, val] of Object.entries(this.default)) {
        this[key] = (this.attributes[key] != null) ? this.attributes[key] : val;
      }
    }
    
    subtotal() {
      return this.price * this.quantity;
    }
    
    hasError(key) {
      return _.any(this.errors[key]);
    }
    
    errorsFor(key) {
      return (this.errors[key] != null) ? this.errors[key][0] : '';
    }
    
    valid() {
      return (this.item_id != null) && this.quantity > 0;
    }
  }
  
  return MovementDetail;
}]);
