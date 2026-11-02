// JavaScript version of inline_edit.coffee
// Part of the CoffeeScript to JavaScript migration

////////////////////////////////////////
// Base class
class InlineEdit {
  constructor(event, $link) {
    this.data = {};
    this.$link = $link;
    this.$parent = this.$link.parents('.inline-cont:first');
    this.$parent.hide();
    this.notify = this.$link.data('notify') || '.top-left';
    this.url = this.$link.attr('href');
    this.name = this.$link.data('name');

    this.$data = this.$parent.find('.inline-data');
    this.value = this.$data.data('value') || this.$data.text();
    this.setTemplate();
  }

  setButtons() {
    const self = this;
    this.$save = this.$template.find('.save');
    this.$cancel = this.$template.find('.cancel').on('click', function() {
      self.$parent.show();
      self.$template.remove();
    });
  }

  disableSave() {
    this.$save.prop('disabled', true);
  }
}

////////////////////////////////////////
// Textarea
class TextareaEdit extends InlineEdit {
  constructor(event, $link) {
    super(event, $link);
  }

  setTemplate() {
    const template = `
      <div class="inline-form-edit">
        <textarea cols="${this.$link.data('cols') || 40}" rows="${this.$link.data('rows') || 4}">${this.value}</textarea>
        <div>
          <button class="btn btn-primary btn-small save">Save</button>
          <button class="btn btn-small cancel">Cancel</button>
        </div>
      </div>
    `;
    
    this.$template = $(template).insertAfter(this.$parent);
    this.$editor = this.$template.find('textarea');
    this.setButtons();
    this.setEvents();
  }

  setEvents() {
    const self = this;
    this.$save.click(function() {
      self.value = self.$editor.val();
      self.data[self.name] = self.value;
      self.update(self.data);
    });
  }

  update(data) {
    const self = this;
    this.disableSave();
    
    $.ajax({
      method: 'patch',
      data: data,
      url: this.url
    })
    .done(function(resp) {
      if (resp.success || resp.id) {
        self.$data.html(_b.nl2br(self.value));
        self.$parent.show();
        self.$template.remove();
        self.$data.data('value', self.value);
      }
    })
    .fail(function(resp) {
      $(self.notify).notify({
        type: 'error',
        message: { text: resp.errors }
      }).show();
    });
  }
}

////////////////////////////////////////
// Date
class DateEdit extends InlineEdit {
  constructor(event, $link) {
    super(event, $link);
  }

  setTemplate() {
    const template = `
      <div class="inline-form-edit">
        <div class="datepicker">
          <input type="hidden"/>
          <input type="text" value="${this.value}" size="10"/>
          <div class="ib nw">
            <button class="btn btn-primary btn-small save">Save</button>
            <button class="btn btn-small cancel">Cancel</button>
          </div>
        </div>
      </div>
    `;
    
    this.due = this.$link.data('due') || false;
    this.$template = $(template).insertAfter(this.$parent);
    this.$template.setDatepicker();
    this.$editor = this.$template.find('input:text');
    this.$hidden = this.$template.find('input:hidden');
    this.setButtons();
    this.setEvents();
  }

  setEvents() {
    const self = this;
    this.$save.click(function() {
      self.data[self.name] = self.$hidden.val();
      self.value = self.$editor.val();
      self.valueDate = self.$editor.datepicker('getDate');
      self.update(self.data);
    });
  }

  update(data) {
    const self = this;
    this.disableSave();
    
    $.ajax({
      method: 'patch',
      data: data,
      url: this.url
    })
    .done(function(resp) {
      if (resp.success || resp.id) {
        self.setDate();
        self.$data.data('value', self.value);
        self.$parent.show();
        self.$template.remove();
      }
    })
    .fail(function(resp) {
      $(self.notify).notify({
        type: 'error',
        message: { text: resp.errors }
      }).show();
    });
  }

  setDate() {
    if (this.due && this.isDue()) {
      this.$data.html(`<span class='red'>${this.value}</span>`);
    } else {
      this.$data.text(this.value);
    }
  }

  isDue() {
    const today = $.datepicker.parseDate('yy-mm-dd', this.$link.data('today'));
    return this.valueDate < today;
  }
}

////////////////////////////////////////
// Number
class NumberEdit extends InlineEdit {
  constructor(event, $link) {
    super(event, $link);
    this.errors = {};
  }

  setTemplate() {
    const template = `
      <div class="inline-form-edit">
        <input type="text" value="${this.value}" size="10" class="r" />
        <div class="nw ib">
          <button class="btn btn-primary btn-small save">Save</button>
          <button class="btn btn-small cancel">Cancel</button>
        </div>
      </div>
    `;
    
    this.$template = $(template).insertAfter(this.$parent);
    this.validate = this.$link.data('validate');
    this.minimum = this.$link.data('minimum');
    this.maximum = this.$link.data('maximum');
    this.$editor = this.$template.find('input:text');
    this.setButtons();
    this.setEvents();
  }

  setEvents() {
    const self = this;
    this.$save.click(function() {
      self.value = self.$editor.val();
      self.data[self.name] = self.value;
      if (self.validateData()) {
        self.update(self.data);
      }
    });
  }

  update(data) {
    const self = this;
    this.disableSave();
    
    $.ajax({
      method: 'patch',
      data: data,
      url: this.url
    })
    .done(function(resp) {
      if (resp.success || resp.id) {
        self.$data.html(_b.ntc(self.value));
        self.$parent.show();
        self.$template.remove();
        self.$data.data('value', self.value);
      }
    })
    .fail(function(resp) {
      $(self.notify).notify({
        type: 'error',
        message: { text: resp.errors }
      }).show();
    });
  }

  validateData() {
    this.$template.removeClass('field_with_errors');
    this.errors = {};

    this.validNumber();
    if (this.minimum != null) this.validateMinimum();
    if (this.maximum != null) this.validateMaximum();

    if (_.any(this.errors)) {
      this.showErrors();
      return false;
    } else {
      return true;
    }
  }

  validNumber() {
    if (!_b.isNumber(this.value)) {
      this.errors['number'] = 'Debe ingresar un número';
    }
  }

  validateMinimum() {
    if (this.value < this.minimum) {
      this.errors['minimum'] = `El valor es menor que mínimo ${this.minimum}`;
    }
  }

  validateMaximum() {
    if (this.value > this.maximum) {
      this.errors['maximum'] = `El valor es mayor que máximo ${this.maximum}`;
    }
  }

  showErrors() {
    this.$template.addClass('field_with_errors');
    const text = [];
    for (const k in this.errors) {
      text.push(this.errors[k]);
    }

    $(this.notify).notify({
      type: 'error',
      message: { text: text.join(', ') }
    }).show();
  }
}

// TextEdit class is referenced but not defined in the original file
// Adding a basic implementation
class TextEdit extends TextareaEdit {
  constructor(event, $link) {
    super(event, $link);
  }
}

// Initialize event handlers
$(document).ready(function() {
  $('body').on('click', '.inline-edit', function(event) {
    event.preventDefault();
    const $this = $(this);
    switch ($this.data('type')) {
      case 'text':
        new TextEdit(event, $this);
        break;
      case 'textarea':
        new TextareaEdit(event, $this);
        break;
      case 'date':
        new DateEdit(event, $this);
        break;
      case 'number':
        new NumberEdit(event, $this);
        break;
    }
  });
});
