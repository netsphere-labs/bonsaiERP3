// JavaScript version of transference.coffee
// Part of the CoffeeScript to JavaScript migration

class Transference extends App.Payment {
  constructor() {
    super();
    this.accountToSel = '#transference_account_to_id';
    this.formSel = '#transference-form';
    this.verificationSel = '#transference_payment_verification';
  }

  initialize() {
    this.set('inverse', currency != this.get('baseCurrency'));
    // select2 method to bind change
    this.setAccountToSelect2();
    this.setAccountToInit();
    this.setTotalCurrency();

    // set rivets
    rivets.bind($(this.formSel), {transference: this});

    this.on('change:exchange_rate change:amount', this.setTotalCurrency);
  }

  setAccountToInit() {
    const other = this.get('baseCurrency') == this.get('currency');
    this.set({
      currency: 'USD',
      sameCurrency: other // Used for enable disable exchange_rate
    });
  }
}

App.Transference = Transference;
