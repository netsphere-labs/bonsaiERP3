// JavaScript version of modal_manager.coffee
// Part of the CoffeeScript to JavaScript migration

class ModalManager {
  constructor() {
    this.template = 
      '<div id="{{modalId}}" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-toggle="modal">' +
      '  <div class="modal-header">' +
      '    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>' +
      '    <h3 class="tit">{{title}}</h3>' +
      '  </div>' +
      '  <div class="modal-body">' +
      '    {{body}}' +
      '    <h3 class="muted center"><img src="/assets/ajax-loader.gif"/> Loading...</h3>' +
      '  </div>' +
      '  <div class="modal-footer">' +
      '    {{footer}}' +
      '  </div>' +
      '</div>';
      
    this.options = {
      backdrop: true,
      keyboard: true,
      show: true,
      remote: false,
      toggle: true
    };
    
    this.renderer = _.template(this.template);
  }
  
  // Creates a modal dialog with twitter bootstrap
  create(options = {}) {
    $('.modal').remove();
    options = _.merge(options, {modalId: new Date().getTime()});
    
    this.$modal = $(this.renderer({
      title: options.title,
      body: options.body,
      footer: options.footer,
      modalId: options.modalId
    }));

    _.each(['title', 'body', 'footer'], function(v) { 
      delete options[v]; 
    });

    this.$modal.attr(options).modal();
    return this.$modal;
  }
  
  // Sets the html for the response from the server
  setResponse(resp) {
    const $resp = $('<div>').append(resp);
    this.$modal.find('.modal-header h3').html($resp.find('h1').html());
    this.$modal.find('.modal-body').html(resp);
    this.$modal.setDatepicker();

    if ($resp.find('.form-actions').length > 0) {
      this.setFormActions($resp);
    }
  }
  
  setFormActions($resp) {
    const self = this;
    this.$modal.find('.modal-footer').append($resp.find('.form-actions').html());
    this.$modal.find('.modal-footer').on('click', 'input:submit', function() {
      self.$modal.find('form').submit();
    });
  }
}

// Expose to global scope
window.ModalManager = ModalManager;
