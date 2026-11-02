// JavaScript version of ajax_remote.coffee
// Part of the CoffeeScript to JavaScript migration

// Manages remotes methods
// Test on console: new AjaxRemote($('[data-remote]:not([data-method])').get(0))
class DataMethod {
  constructor(event, elem) {
    this.$this = $(elem);
    this.url = this.$this.attr('href');

    switch (this.$this.attr('data-method')) {
      case 'post':
      case 'POST':
        this.post();
        break;
      case 'delete':
      case 'DELETE':
        this.delete();
        break;
      case 'put':
      case 'PUT':
        this.put();
        break;
      case undefined:
      case '':
        this.get();
        break;
      default:
        throw this.$this.attr('data-method') + " data-method not found";
    }
  }

  delete() {
    const msg = this.$this.data('confirm') ? this.$this.data('confirm') : 'Are you sure to delete the selected item';
    if (!confirm(msg)) return false;

    const html = `
      <input name="utf8" type="hidden" value="✓">
      <input name="authenticity_token" type="hidden" value="${csrf_token}">
      <input type="hidden" name="_method" value="delete" />
    `;
    
    $('<form/>')
      .attr({
        action: this.$this.attr('href'), 
        method: 'post'
      })
      .html(html)
      .submit();
  }
}

class AjaxRemote extends DataMethod {
  get() {
    const urls = this.url.split('?');
    urls[0] = urls[0].match(/.+\.js$/) ? urls[0] : urls[0] + ".js";
    $.get(urls.join('?'));
  }

  delete() {
    this.$parent = this.$this.parents("tr:first, li:first");
    this.$parent.addClass('marked');

    const msg = this.$this.data('confirm') ? this.$this.data('confirm') : 'Are you sure to delete the selected item';

    if (confirm(msg)) {
      this.deleteItem();
    } else {
      this.$parent.removeClass('marked');
    }
  }

  deleteItem() {
    const self = this;
    $.ajax({
      'url': this.url,
      type: 'delete'
    })
    .success(function(resp) {
      if (resp['destroyed?'] || resp['success']) {
        self.$parent.remove();
      }
      $('body').trigger('ajax:delete', self.url);
    })
    .error(function() {
      alert('There was an error deleting');
    })
    .complete(function() {
      self.$parent.removeClass('marked');
    });
  }
}

Plugin.AjaxRemote = AjaxRemote;

jQuery(function() {
  $('body').on('click', '[data-remote]', function(event) {
    event.preventDefault();
    new AjaxRemote(event, this);
  });
  
  $('body').on('click', '[data-method]', function(event) {
    event.preventDefault();
    const $this = $(this);
    if (!($this.data('remote')) && !$this.hasClass('ajax')) {
      new DataMethod(event, this);
    }
  });
});
