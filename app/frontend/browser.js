// JavaScript version of browser.js.coffee
// Part of the CoffeeScript to JavaScript migration

jQuery(function($) {
  if ($.browser.msie && ($.browser.version.match(/^6/) || $.browser.version.match(/^7/))) {
    $('#');
    // alert("Su navegador no es adecuado para este sitio por fabor cambielo")
  }
})();
