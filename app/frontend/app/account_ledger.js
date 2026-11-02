// JavaScript version of account_ledger.coffee
// Part of the CoffeeScript to JavaScript migration

class AccountLedgerReference {
  constructor(link) {
    this.link = link;
    this.$link = $(this.link);
    this.$cont = this.$link.parents('.edit-reference');
    this.$row = this.$link.parents('.account_ledger');

    this.$form = $(_.template(template, { reference: this.$link.data('reference') }));
    this.setEvents();
  }

  setEvents() {
    this.$form.on('submit', (event) => {
      event.preventDefault();
      this.$form.find('.btn-primary').prop('disabled', true).text('Salvando...');
      this.save();
    });

    this.$form.on('click', 'a.cancel', () => {
      this.$cont.show();
      this.$form.remove();
    });

    this.$form.insertAfter(this.$cont);
    this.$cont.hide();
  }

  save() {
    const self = this;
    const reference = this.$form.find('#reference').val();
    
    $.ajax({
      url: `/account_ledgers/${self.$link.data('id')}`,
      data: { reference: reference },
      type: 'PUT'
    })
    .done(function(resp) {
      self.$row.find('.reference').html(reference.replace(/\n/g, '<br>'));
      const $user = self.$row.find('.updater');
      self.$link.data('reference', reference);

      if ($user.length > 0) {
        $user.attr('data-original-title', `MODIFICADO por: ${resp.updater} ${resp.updated_at}`);
      }
      
      self.$cont.show();
      self.$form.remove();
      self.$row.trigger('ledger-reference:update', [resp]);
    })
    .fail(function() {
      const txt = self.$row.find('.code').text();
      alert('Exisitio un error al actualizar la referencia de' + txt);
    });
  }
}

$(function() {
  $('body').on('click', '.account_ledger .edit-ledger-reference-link', function() {
    new AccountLedgerReference(this);
  });
});

const template = `
<form>
  <textarea id='reference' rows='3' cols='35'>[:reference:]</textarea>
  <div class='clearfix'></div>
  <button class='btn btn-small btn-primary' title='Actualizar referencia'>Act. referencia</button>
  <a class='btn btn-small cancel'>Cancel</a>
</form>
`;

App.AccountLedgerReference = AccountLedgerReference;
