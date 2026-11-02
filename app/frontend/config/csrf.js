// JavaScript version of csrf.coffee
// Part of the CoffeeScript to JavaScript migration

// Angularjs config for ajax
myApp.config(function($httpProvider) {
  const authToken = $('meta[name="csrf-token"]').attr("content");
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken;
});
