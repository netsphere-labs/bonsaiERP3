// JavaScript version of number_filters.coffee
// Part of the CoffeeScript to JavaScript migration

angular.module('numberFilters', [])
.filter('decimal', function() {
  return function(input, dec = 2) {
    return _b.ntc(input, dec);
  };
})
.filter('currencyLabel', function() {
  return function(input) {
    return _b.currencyLabel(input);
  };
});
