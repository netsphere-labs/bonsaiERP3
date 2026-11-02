// JavaScript version of currency.coffee
// Part of the CoffeeScript to JavaScript migration

window.Currency = {
  name: function(code) {
    return currencies[code].name;
  },
  label: function(code) {
    return `<span class='label label-inverse' title='${this.name(code)}' rel='tooltip'>${code}</span>`;
  }
};
