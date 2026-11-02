// JavaScript version of bdialog.coffee
// Part of the CoffeeScript to JavaScript migration

window.bdialog = {
  defaultOptions: {
    loadingText: 'Cargando'
  }
};

// Class to control dialogs with options for select and other stuff
// when updating forms
window.Bdialog = class Bdialog {
  constructor(params) {
    this.loadingText = bdialog.defaultOptions.loadingText;
    this.loadingHTML = `<h4 class='c'><i class='icon-spinner icon-spin icon-large'></i> ${this.loadingText}</h4>`;
    
    const data = params || {};
    params = _.extend({
      'title': '', 
      'width': 800, 
      'modal': true, 
      'resizable': false, 
      'position': 'top'
    }, params);

    const html = params['html'] || this.loadingHTML;
    const div_id = params.id;
    const css = "ajax-modal " + (params['class'] || "");
    
    this.$dialog = $('<div/>')
      .attr({ 
        'id': params['id'], 
        'title': params['title'] 
      })
      .html(html)
      .data(data)
      .addClass(css)
      .css({'z-index': 10000 });

    delete(params['id']);
    delete(params['title']);

    this.$dialog.dialog(params);

    return this.$dialog;
  }

  updateRelated() {
    // This method is empty in the original
  }
};
