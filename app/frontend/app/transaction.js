// JavaScript version of transaction.coffee
// Part of the CoffeeScript to JavaScript migration

// Model to control the items
class Item extends Backbone.Model {
  constructor(attributes, options) {
    super(attributes, options);
    this.defaults = {
      item_id: 0,
      price: 0.0,
      original_price: 0.0,
      quantity: 1.0,
      subtotal: 0.0,
      rate: 1.0
    };
    
    // Bind methods to this instance
    this.delete = this.delete.bind(this);
  }
  
  initialize() {
    this.on('change:rate', this.setPrice);
    this.on('change:price change:quantity', this.setSubtotal);
    this.setSubtotal();
  }
  
  setSubtotal() {
    const sub = 1 * this.get('quantity') * 1 * this.get('price');
    this.set('subtotal', sub);
    this.collection.calculateSubtotal();
  }
  
  setPrice() {
    const price = _b.roundVal(this.get('original_price') * (1.0 / this.get('rate')), bonsai.presicion);
    this.set({price: price});
  }
  
  setAutocompleteEvent(el) {
    $(el).on('autocomplete-done', 'input.autocomplete', (event, item) => {
      if (this.collection.where({item_id: item.id}).length > 0) {
        this.resetAutocompleteValue(event);
        return false;
      }

      const price = _b.roundVal(item.price * (1/this.get('rate')), _b.numPresicion);
      this.set({original_price: item.price, price: price, item_id: item.id});
    });

    $(el).on('autocomplete-reset', 'input.autocomplete', (event) => {
      this.set({item_id: 0, price: 0, quantity: 1});
    });
  }
  
  resetAutocompleteValue(event) {
    setTimeout(() => {
      const $el = $(event.target);
      $el.data('value', '');
      $el.val('');
      $el.siblings('input:hidden').val('');
      alert('El ítem que selecciono ya existe en la lista');
    }, 50);
  }
  
  delete(event) {
    const src = event.currentTarget || event.srcElement;
    this.collection.deleteItem(this, src);
  }
}

// Uses the Item#buy_price instead of Item#price
class ExpenseItem extends Item {
  setAutocompleteEvent(el) {
    $(el).on('autocomplete-done', 'input.autocomplete', (event, item) => {
      if (this.collection.where({item_id: item.id}).length > 0) {
        this.resetAutocompleteValue(event);
        return;
      }

      const price = _b.roundVal(item.buy_price * (1/this.get('rate')), _b.numPresicion);
      this.set({original_price: item.buy_price, price: price, item_id: item.id});
    });
  }
}

// TransactionModel
class TransactionModel extends Backbone.Model {
  constructor(attributes, options) {
    super(attributes, options);
    this.defaults = {
      currency: '',
      baseCurrency: '',
      rate: 1,
      direct_payment: false,
      total: 0.0
    };
  }
  
  initialize() {
    const cur = $('#transaction_currency').val();
    this.set({
      currency: cur,
      baseCurrency: organisation.currency,
      sameCurrency: cur === organisation.currency
    });
    
    this.createAccountToOptions();
    this.setEvents();
    this.activateExchange();
    this.setCurrency();
  }
  
  setEvents() {
    const self = this;
    
    $('#transaction_currency').change(function(event) {
      self.set('currency', $(this).val());
      self.setCurrency();
      self.activateExchange();
      self.createAccountToOptions();
    });
    
    $('#transaction_exchange_rate').change(function(event) {
      self.set('rate', this.value * 1);
    });
  }
  
  setCurrency() {
    const rate = fx.convert(1, {from: this.get('currency'), to: this.get('baseCurrency')}).toFixed(4) * 1;
    this.set('rate', rate);
    $('#transaction_exchange_rate').val(rate);
    this.setCurrencyLabel();
  }
  
  setCurrencyLabel() {
    const html = `1 ${this.get('currency')} = `;
    const label = Currency.label(this.get('currency'));
    $('.currency').html(label);
  }
  
  activateExchange() {
    if (this.get('baseCurrency') === this.get('currency')) {
      $('#transaction_exchange_rate').attr('disabled', true);
    } else {
      $('#transaction_exchange_rate').attr('disabled', false);
    }
  }
  
  // Creates the account_to options
  createAccountToOptions() {
    const data = _.filter(this.get('accountsTo'), (v) => this.get('currency') === v.currency);

    $('#account_to_id').select2('destroy')
      .select2({
        data: data,
        formatResult: App.Payment.paymentOptions,
        formatSelection: App.Payment.paymentOptions,
        dropdownCssClass: 'hide-select2-search',
        escapeMarkup: (m) => m
      });
  }
}

// Collection that holds and integrates all models Item and TransModel
class Transaction extends Backbone.Collection {
  constructor(models, options) {
    super(models, options);
    this.model = Item;
    this.total = 0.0;
    this.totalPath = '#total';
    this.subtotalPath = '#subtotal';
    this.transSel = '.trans';
    this.transModel = false;
    this.subtotal = 0;
    this.taxPercent = 0;
    this.tax = 0.0;
    this.accountsTo = [];
  }
  
  initialize() {
    const total = $('#total').data('value');
    this.$table = $('#items-table');
    this.itemTemplate = _.template(itemTemplate);

    this.setTaxComponent();
    this.setEvents();
    this.setList();
    
    // Set the transaction model
    const self = this;
    this.transModel = new TransactionModel({
      accountsTo: this.accountsTo
    });
    
    // Set the direct payment
    $('#direct_payment').change(function() {
      const val = $(this).is(':checked');
      self.transModel.set('direct_payment', val);
      
      if (val) {
        $('.save-button').hide();
      } else {
        $('.save-button').show();
      }
    });

    rivets.bind($(this.transSel), {trans: this.transModel});
    this.transModel.on('change:rate', () => self.setCurrency());
  }
  
  calculateSubtotal() {
    this.subtotal = this.reduce((sum, p) => {
      if (p.attributes.item_id != null) {
        return sum + p.get('subtotal');
      } else {
        return sum + 0.0;
      }
    }, 0.0);

    $(this.subtotalPath).html(_b.ntc(this.subtotal));
    this.calculateTotal(this.subtotal);
  }
  
  // TOTAL
  calculateTotal(subtotal) {
    if (this.taxPercent > 0) {
      this.tax = subtotal * this.taxPercent / 100;
      $('#taxes-percentage').html(_b.ntc(this.tax));
    }
    
    const tot = subtotal + this.tax;
    $(this.totalPath).html(_b.ntc(tot));
    this.transModel.set('total', tot);
  }
  
  // Sets the tax component
  setTaxComponent() {
    const $tax = $('#taxes-percentage');
    if ($tax.length > 0) {
      this.taxPercent = $tax.data('tax');
    }
  }
  
  // Set events
  setEvents() {
    const self = this;
    $('#add-item-link').click(function(event) {
      event.preventDefault();
      self.addItem();
    });
  }
  
  // Set the list
  setList() {
    this.$table.find('tr.item').each((i, el) => {
      this.add(_.merge($(el).data('item'), {elem: el}));
      const item = this.models[this.length - 1];
      rivets.bind(el, {item: item});
      item.setAutocompleteEvent(el);
    });
  }
  
  addItem() {
    const $tr = $(this.getItemHtml()).insertBefore('#subtotal-line');

    $tr.createAutocomplete();
    $tr.dataNewUrl();
    this.add({rate: this.transModel.get('rate'), elem: $tr.get(0)});
    const item = this.models[this.length - 1];
    rivets.bind($tr, {item: item});
    item.setAutocompleteEvent($tr);
    this.calculateSubtotal();
  }
  
  deleteItem(item, src) {
    const $row = $(src).parents('tr.item');
    if (item.get('id') != null) {
      item.set('_destroy', "1");
      $row.hide();
    } else {
      $row.detach();
    }

    this.remove(item);
    this.calculateSubtotal();
  }
  
  // Sets the items currency
  setCurrency() {
    this.each((el) => {
      el.set('rate', this.transModel.get('rate'));
    });
  }
  
  setAutocompleteVal(tr, resp) {
    const $auto = $(tr).find('input.autocomplete').val(resp.label);
    $auto.siblings('input:hidden').val(resp.id);
  }
}

// Income
class Income extends Transaction {
  getItemHtml() {
    const num = new Date().getTime();
    return this.itemTemplate({num: num, klass: 'incomes_form', det: 'income', search_path: 'search_income'});
  }
  
  setEvents() {
    const self = this;
    super.setEvents();
    
    $('body').on('ajax-call', '.item_id', function(event, resp) {
      const tr = $(this).parents('tr').get(0);
      const mod = self.where({elem: tr})[0];
      const rate = self.transModel.get('rate');
      const price = _b.roundVal((resp.price * 1) * (1.0 / rate), bonsai.presicion);

      mod.set({
        item_id: resp.id,
        price: price,
        original_price: resp.price,
      });

      self.setAutocompleteVal(tr, resp);
    });
  }
}

// Expense
class Expense extends Transaction {
  constructor(models, options) {
    super(models, options);
    this.model = ExpenseItem;
  }
  
  getItemHtml() {
    const num = new Date().getTime();
    return this.itemTemplate({num: num, klass: 'expenses_form', det: 'expense', search_path: 'search_expense'});
  }
  
  setEvents() {
    const self = this;
    super.setEvents();
    
    $('body').on('ajax-call', '.item_id', function(event, resp) {
      const tr = $(this).parents('tr').get(0);
      const mod = self.where({elem: tr})[0];
      const rate = self.transModel.get('rate');
      const price = _b.roundVal((resp.buy_price * 1) * (1.0 / rate), bonsai.presicion);

      mod.set({
        item_id: resp.id,
        price: price,
        original_price: resp.buy_price,
      });
      
      self.setAutocompleteVal(tr, resp);
    });
  }
}

window.App.Income = Income;
window.App.Expense = Expense;

const itemTemplate = `<tr class="item form-inline" data-item="{"original_price":"0.0","price":"0.0","quantity":"1.0","subtotal":"0.0"}">
    <td class='span6 nw'>
      <div class="control-group autocomplete optional">
        <div class="controls">
          <input id="{{klass}}_{{det}}_details_attributes_{{num}}_item_id" name="{{klass}}[{{det}}_details_attributes][{{num}}][item_id]" type="hidden"/>
          <input class="autocomplete optional item_id ui-autocomplete-input span11" data-source="/items/{{search_path}}.json" id="item_autocomplete" name="item_autocomplete" placeholder="Escriba para buscar el ítem" size="35" type="text" autocomplete="off" data-new-url="/items/new" data-return="true" data-title="Crear ítem" />
        </div>
      </div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-original-price="null" data-value="item.price" id="{{klass}}_{{det}}_details_attributes_{{num}}_price" name="{{klass}}[{{det}}_details_attributes][{{num}}][price]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td>
      <div class="control-group decimal optional"><div class="controls"><input class="numeric decimal optional" data-value="item.quantity" id="{{klass}}_{{det}}_details_attributes_{{num}}_quantity" name="{{klass}}[{{det}}_details_attributes][{{num}}][quantity]" size="8" step="any" type="decimal" value=""></div></div>
    </td>
    <td class="total_row r">
      <span data-text="item.subtotal | number"></span>
    </td>
    <td class="del"><a href="javascript:;" class="dark btn" title="Borrar" data-toggle="tooltip" data-on-click="item:delete"><i class="icon-trash"></i></a></td>
</tr>`;
