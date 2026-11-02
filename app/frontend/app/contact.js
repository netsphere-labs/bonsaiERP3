// JavaScript version of contact.coffee
// Part of the CoffeeScript to JavaScript migration

// Present Incomes, Expenses
class ContactBalance {
  constructor(elem) {
    this.elem = elem;
    this.$elem = $(this.elem);
    this.$incomes = this.$elem.find('.incomes');
    this.$expenses = this.$elem.find('.expenses');
    this.data = this.$elem.data('data');
  }

  render() {
    // Render incomes
    this.$incomes.append([
      this.data.incomes.TOTAL ? "<div class='b text-success'>Ingresos por cobrar</div>" : "",
      this.renderDetail(this.data.incomes)
    ].join(''));
    
    // Render expenses
    this.$expenses.append([
      this.data.expenses.TOTAL ? "<div class='b text-error'>Expenses por pagar</div>" : "",
      this.renderDetail(this.data.expenses)
    ].join(''));

    this.$elem.on('mouseover mouseout', '.detail', (event) => this.renderCurrencies(event));
  }

  renderDetail(data) {
    if (data.TOTAL) {
      let html = `${_b.ntc(data.TOTAL)} ${this.currencyLabel(organisation.currency)}`;
      if (data[organisation.currency] !== data.TOTAL) {
        html += ' <a href="javascript:;" class="label label-info detail"><i class="icon icon-exchange"></i></a>';
      }
      return html;
    }
    return '';
  }

  renderCurrencies(event) {
    switch (event.type) {
      case 'mouseover':
        this.showPopover(event);
        break;
      case 'mouseout':
        this.hidePopover(event);
        break;
    }
  }

  showPopover(event) {
    if ($(event.target).parents('.incomes').length > 0) {
      this.popoverIncomes = this.popoverIncomes || this.createPopoverIncomes(event);
      this.popoverIncomes.popover('show');
    } else {
      this.popoverExpenses = this.popoverExpenses || this.createPopoverExpenses(event);
      this.popoverExpenses.popover('show');
    }
  }

  hidePopover(event) {
    if ($(event.target).parents('.incomes').length > 0) {
      this.popoverIncomes.popover('hide');
    } else {
      this.popoverExpenses.popover('hide');
    }
  }

  createPopoverIncomes(event) {
    const title = '<span class="text-success b">Detalle ingresos por cobrar</span>';
    const html = this.createCurrenciesDetail(this.data.incomes);

    return $(event.target).popover({title: title, html: true, content: html, placement: 'top'});
  }

  createPopoverExpenses(event) {
    const title = '<span class="text-error b">Detalle Expenses por pagar</span>';
    const html = this.createCurrenciesDetail(this.data.expenses);

    return $(event.target).popover({title: title, html: true, content: html, placement: 'top'});
  }

  createCurrenciesDetail(data) {
    return _.map(data, (v, k) => {
      if (k !== 'TOTAL') {
        return '<p>' + _b.ntc(v) + ' ' + this.currencyLabel(k) + '</p>';
      }
      return '';
    }).join('');
  }

  currencyLabel(cur) {
    const name = currencies[cur].name;
    return `<span class="label label-inverse" data-toggle="tooltip" title="${name}">${cur}</span>`;
  }
}

App.ContactBalance = ContactBalance;
