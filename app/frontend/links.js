// JavaScript version of links.coffee
// Part of the CoffeeScript to JavaScript migration

$(function() {
  // Creates cancel button for data-target or other
  const createCancelButton = function($div, $link) {
    if ($div.find('.cancel').length > 0) return;

    const $cancel = $('<a/>', {
      class: 'btn cancel', 
      href: 'javascript:;', 
      text: 'Cancel',
      click: function() {
        if ($div.attr('ng-controller')) {
          const $scope = $div.scope();
          $scope.$apply(function(scope) {
            scope.htmlContent = '';
            scope.$$childHead = null;
            scope.$$childTail = null;
          });
        } else {
          $div.html('').hide('medium');
        }

        $link.show('medium');
      }
    });

    $div.find('.form-actions').append($cancel);
  };

  ////////////////////////////////////////
  // Hide container for data target
  const getHideCont = function($this) {
    const target = $this.data('targethide');
    if (target) {
      return target.$jquery ? target : $(target);
    } else {
      return $this;
    }
  };

  // Creates a data target loaded via AJAX
  // data-target
  $('body').on('click', 'a[data-target]', function(event) {
    if ($(this).data('toggle')) return; // Prevent data toggle modal

    event.preventDefault();
    const $this = $(this);
    const $hide = getHideCont($this);
    $hide.hide('medium');
    const $div = $($this.data('target'));
    $div.addClass('ajax-modal').data('link', $this);

    if ($div.attr('ng-controller')) {
      const $scope = $div.scope();
      $scope.$apply(function(scope) {
        scope.$$childHead = null;
        scope.$$childTail = null;
        scope.htmlContent = AjaxLoadingHTML();
      });
    } else {
      $div.show('medium').html(AjaxLoadingHTML());
    }

    $.get($this.attr('href'), function(resp, status, jqXHR) {
      if (status === 'error') {
        $div.hide('medium');
        $this.show('medium');
        $('.top-left').notify({
          type: 'error',
          message: { text: 'An error occurred' }
        }).show();
      } else {
        if ($div.attr('ng-controller')) {
          const $scope = $div.scope();
          $scope.$apply(function(scope) {
            scope.$$childHead = null;
            scope.$$childTail = null;
            scope.htmlContent = resp;
          });
        } else {
          $div.html(resp);
        }

        $div.setDatepicker();
        createCancelButton($div, $hide);
      }
    });
    
    $div.on('reload:ajax-modal', function() {
      createCancelButton($div, $hide);
    });
  });

  // Marks a row adding a selected class to the row
  const rowCheck = function() {
    $(this).on('click', '>li,>tr', function(event) {
      const target = event.target;
      const $target = $(target);

      if ($target.get(0).tagName === 'A' || $target.parent('a').length > 0) return true;

      const $check = $(this).find('input.row-check');
      const $row = $check.parents('tr,li');

      if (target.type === 'checkbox' && $(target).hasClass('row-check')) {
        if ($check.prop('checked')) {
          $row.addClass('selected');
        } else {
          $row.removeClass('selected');
        }
        return true;
      }

      if ($check.prop('checked')) {
        $check.trigger('click');
        $row.removeClass('selected');
      } else {
        $check.trigger('click');
        $row.addClass('selected');
      }
    });
  };

  $.rowCheck = $.fn.rowCheck = rowCheck;

  $('.has-row-check').rowCheck();

  ////////////////////////////////////////
  // Presents any link url in a modal dialog and loads with AJAX the url
  $('body').on('click', 'a.ajax', function(event) {
    event.preventDefault();

    const id = new Date().getTime().toString();
    const $this = $(this);
    $this.data('ajax_id', id);

    const $div = createDialog({
      title: $this.data('title'),
      // Elem related with the call input, select, etc
      elem: $this.data('elem') || $this,
      width: $this.data('width') || 800,
      //dialogClass: $this.data('class') || 'normal-dialog',
      // Return response instead of calling default
      return: $this.data('return') || true
    });

    $div.load($this.attr("href"), function(resp, status, xhr, dataType) {
      const $this = $(this);

      if ($div.attr('ng-controller')) {
        $div.scope().htmlContent = resp;
      } else {
        const $div = $('<div>').html(resp);
      }

      $this.find('.form-actions').append('<a class="btn cancel" href="javascript:;">Cancel</a>');

      const $tit = $this.dialog('widget').find('.ui-dialog-title')
        .text($div.find('h1').text());

      $div.setDatepicker();
    });
    
    event.stopPropagation();
  });

  ////////////////////////////////////////
  // Replace jquery_ujs

  // Creates a form for the url
  const getFormLink = function(action, method, params = {}) {
    let html = "<input type='hidden' name='utf-8' value='&#x2713;' />";
    html += `<input type='hidden' name='authenticity_token' value='${csrf_token}' />`;
    html += `<input type='hidden' name='_method' value='${method}' />`;

    return $('<form/>').attr({'method': 'post', 'action': action })
      .html(html).appendTo('body');
  };

  // Method to remove rows
  const deleteRow = function($link, url, confCallback) {
    const $parent = $link.parents('tr:first, li:first');
    $parent.addClass('marked');

    if (confCallback.call(this)) {
      $.ajax({
        'url': url,
        'type': 'delete'
      })
      .done(function(resp) {
        if (resp['destroyed?']) {
          $link.trigger('ajax:delete', $link);
          $('body').trigger('ajax:delete', [url, $link]);
          $parent.remove();
        } else {
          $parent.removeClass('marked');
          alert("The record cannot be deleted because it has relationships.");
        }
      })
      .fail(function() { 
        alert('There was an error deleting');
      });
    } else {
      $parent.removeClass('marked');
    }
  };

  // Get the confirmation message
  const getConfirmMessage = function($this) {
    if ($this.data('confirm')) {
      return $this.data('confirm');
    } else if ($this.data('method') === 'delete' && $this.data('remote')) {
      return 'Are you sure you want to delete the record?';
    } else if ($this.data('method') === 'delete') {
      return 'Are you sure you want to delete the record?';
    } else {
      return null;
    }
  };

  // call remote xhr AJAX
  const callUrlRemoteMethod = function($link, confCallback) {
    const url = $link.attr('href') || this.data('href') || this.data('url');

    if (($link.parents('tr') || $link.parents('li')) && $link.data('method') === 'delete') {
      return deleteRow($link, url, confCallback);
    }

    if (confCallback.call(this)) {
      switch ($link.data('method')) {
        case 'post':
          $.post(url);
          break;
        case 'put':
          $.put(url);
          break;
        case 'patch':
          $.patch(url);
          break;
        case 'delete':
          $.delete(url);
          break;
        default:
          $.get(url);
      }
    }
  };

  // Call using a form
  const callUrlMethod = function($link, confCallback) {
    const url = $link.attr('href') || this.data('href') || this.data('url');
    const method = $link.data('method');

    if (confCallback.call(this)) {
      getFormLink(url, method).submit();
    }
  };

  // Check the methods to call the url
  $('body').on('click', '[data-method]', function(event) {
    event.preventDefault();

    const $this = $(this);
    const method = $this.data('method') || 'get';
    const callbackMessage = getConfirmMessage($this);

    const confirmCallback = function() {
      if (callbackMessage) {
        return confirm(callbackMessage);
      } else {
        return true;
      }
    };

    if ($this.data('remote')) {
      callUrlRemoteMethod($this, confirmCallback);
    } else {
      callUrlMethod($this, confirmCallback);
    }
  });
});
