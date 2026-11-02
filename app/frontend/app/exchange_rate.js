// JavaScript version of exchange_rate.coffee
// Part of the CoffeeScript to JavaScript migration

// Backbone model
class ExchangeRate extends Backbone.Model {
  constructor() {
    super();
    this.defaults = {
      rate: 1
    };
  }

  setAll(input, observe, currency_id, accounts, currencies, options) {
    this.currency_id = currency_id;
    this.accounts = accounts;
    this.currencies = currencies;
    this.options = options;
    
    this.getRates();
    this.inverse = false;
    this.$input = $(input);
    this.observe = observe;
    this.$label = this.$input.parents(".control-group:first").find('label');
    this.inverted = this.options["inverted"] || false;

    this.$currencies = this.$label.find(".currencies");
    this.$hide = this.options["hide"] ? $(this.options["hide"]) : this.$input.parents(".control-group:first");

    // Set rate if exists
    if (this.$input.val().match(/^\d+$/) || $(this.observe).val().match(/^\d+$/)) {
      const rate = this.$input.val() * 1;
      const curr = $(this.observe).val() * 1;
      // Set the currency
      this.set({rate: rate, "currency": this.currencies[curr]});

      this.setCurrencyLabel();
      this.presentCurrency();
      this.triggerExchange(false);
    } else {
      this.$input.val(this.get("rate"));
    }

    this.set({ suggest_rate: this.get("rate").round(4) });
    // Events
    this.setEvents();
  }

  // Events
  setEvents() {
    // Currency
    this.bind("change:currency", () => {
      this.setCurrencyLabel();
    });

    this.chageCurrencyEvent();
    this.rateEvents();
  }

  // trigger for rate and currency
  triggerExchange(showSug = true) {
    if (showSug) this.setSuggestRates();
    const rate = this.get("rate");
    this.$input.trigger("change:rate", [{rate: rate, currency: this.get("currency"), inverse: this.inverse }]);
  }

  // Account event
  chageCurrencyEvent() {
    const self = this;

    // Triggers the suggested:rate Event
    $(this.observe)
      .off('change keyup')
      .on('change keyup', function() {
        let html = '';
        let rate = 0.0;
        let currency_id = false;

        if ($(this).val().match(/^\d+$/)) {
          const val = $(this).val() * 1;
          self.set({currency: self.currencies[self.accounts[val].currency_id]});
          self.setSuggestRates();
          self.triggerExchange();
        } else {
          self.$hide.hide('slow');
          rate = 1;
        }

        self.$input.trigger('suggested:rate', [rate]);
      });
  }

  // set the rate
  setRate() {
    this.$input.val(this.get("rate")).mark();
  }

  // Sets the data for currency
  setCurrencyLabel() {
    try {
      let from = this.currencies[this.currency_id].symbol;
      let to = this.get("currency").symbol;

      if (this.inverse) {
        const tmp = from;
        from = to;
        to = tmp;
      }

      this.$currencies.html(`(${from} a ${to})`);

      this.presentCurrency();
    } catch (e) {
      return false;
    }
  }

  // Presents the hidden div
  presentCurrency() {
    try {
      if (this.currency_id == this.get("currency").id) {
        this.$hide.hide('slow');
      } else {
        this.$hide.show('slow');
        this.$hide.show();
      }
    } catch (e) {
      return false;
    }
  }

  // Set the rate for a currency
  setSuggestRates() {
    try {
      let from = this.currencies[this.currency_id].code;
      let to = this.get("currency").code;

      if (this.currency_id == organisation.currency_id) {
        this.inverse = true;
        const tmp = from;
        from = to;
        to = tmp;
      } else {
        this.inverse = false;
      }

      const rate = fx.convert(1, {from: from, to: to}) || this.get("rate");

      this.set({suggest_rate: rate.round(4), rate: rate.round(4)});
      this.$input.val(rate.round(4));
    } catch (e) {
      // Handle error silently
    }
  }

  // rateEvents
  rateEvents() {
    const self = this;
    $('#suggested_exchange_rate').die().on('click', function(event) {
      self.set({rate: self.get("suggest_rate")});
    });
    
    // Inverted
    $('#suggested_inverted_rate').die().on('click', function(event) {
      const res = prompt("Tipo de cambio invertido:", self.get("suggest_inv_rate"));
      if (res) {
        const newRate = 1/(res * 1);
        self.set({rate: newRate.round(4)});
      }
    });
  }

  // gets the rates from a server form money.js
  getRates() {
    // 'http://openexchangerates.org/latest.json'
    $.getJSON("http://openexchangerates.org/latest.json", (data) => {
      // Check money.js has finished loading:
      if (typeof fx !== "undefined" && fx.rates) {
        fx.rates = data.rates;
        fx.base = data.base;
      } else {
        // If not, apply to fxSetup global:
        window.fxSetup = {
          rates: data.rates,
          base: data.base
        };
      }
      this.setSuggestRates();
    });
  }
}

App.ExchangeRate = ExchangeRate;
