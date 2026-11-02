// JavaScript version of item.js.coffee
// Part of the CoffeeScript to JavaScript migration

class DiscountRange {
  constructor(field_id) {
    this.field_id = field_id;
    // Regular expression to test
    this.reg_range_discount = /^([\d]+(\.[\d]+)?:[\d]+(\.\d)?\s+)*([\d]+(\.[\d]+)?:[\d]+(\.\d)?\s*)?$/;
    this.setEvents();
  }

  // setEvents
  setEvents() {
    const self = this;
    
    // focus
    $(`#${self.field_id}`).focus(function() {
      if ($(`#${self.field_id}_div`).length <= 0) {
        self.createDiv();
      }
      $(`#${self.field_id}_div`).show();
    });
    
    // blur
    $(`#${self.field_id}`).blur(function() {
      $(`#${self.field_id}_div`).hide();
      self.validateSecuence(self.splitValues($(`#${self.field_id}`).val()));
    });
    
    // keyup
    $(`#${self.field_id}`).keyup(function() {
      self.setTable();
    });
  }

  // Sets the table
  setTable() {
    const self = this;
    const values = self.splitValues($(`#${self.field_id}`).val());
    $(`#${self.field_id}_table`).replaceWith(self.createTable(values));
  }

  // Split the values
  // @param String
  // @return Array
  splitValues(val) {
    const self = this;
    val = val.replace(/\s*$/, '');
    
    if (self.reg_range_discount.test(val) && !(/^\s*$/.test(val))) {
      return $(val.split(" ")).map((i, el) => {
        return [$(el.split(":")).map((i, elem) => {
          return parseFloat(elem);
        }).toArray()];
      }).toArray();
    }
    return [];
  }

  // Create table
  // @param Array values
  createTable(values) {
    let html = '';
    const self = this;
    
    $(values).each((i, el) => {
      let txt;
      if (values[i + 1]) {
        txt = `${el[0]} o menor que ${values[i + 1][0]}`;
      } else {
        txt = `mayores o igual a ${el[0]}`;
      }
      html += `<tr><td>${txt}</td><td>${el[1]} %</td></tr>`;
    });
    
    return `<table class="decorated" id="${self.field_id}_table"><tr><th>Rango</th><th>Porcentaje (%)</th>${html}</table>`;
  }

  // creates a Div with the table
  createDiv() {
    const self = this;
    const values = self.splitValues($(`#${self.field_id}`).val());
    
    const html = [
      '<p class="hint">Ingrese rangos con formato (cantidad:porcentaje) Ej.: 10:5 20:7 40:7.5<br/>',
      'o oferta única Ej.: 0:3<br />', 
      'Nota: el porcetaje acepta solo números con 1 decimal</p>',
      '<h3 class="dark">Rangos</h3>', 
      self.createTable(values)
    ].join("");
    
    $('<div />').attr({
      'id': `${self.field_id}_div`
    }).css({
      'position': 'absolute', 
      'width': '300px', 
      'padding': '5px', 
      'margin-top': '-1px',
      'background-color': '#FFF', 
      'border': '1px solid #DFDFDF'
    }).html(html).insertAfter(`#${self.field_id}`);
  }

  // Validates that the sequence goes from minor to greater
  validateSecuence(values) {
    let curr_val = 0;
    let curr_per = 0;
    let first = true;
    
    $(values).each((i, el) => {
      if (!first) {
        if (el[0] <= curr_val || el[1] <= curr_per) {
          alert('La secuencia de un rango de descuento debe ser de menor a mayor Ej.: 10:2 15:2.5');
          return false;
        }
      }
      first = false;
      curr_val = el[0];
      curr_per = el[1];
    });
  }
}

window.DiscountRange = DiscountRange;

// Alternative class that shows the range and not binded to an event
class DiscountRangeShow extends DiscountRange {
  constructor(field_id) {
    super(field_id);
    this.field_id = field_id;
  }
  
  // Creates a table for a field
  tableForField(value) {
    const self = this;
    $(self.createTable(self.splitValues(value))).appendTo(`#${self.field_id}`);
  }
}

window.DiscountRangeShow = DiscountRangeShow;
