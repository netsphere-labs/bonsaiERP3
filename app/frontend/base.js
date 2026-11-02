// JavaScript version of base.coffee
// Part of the CoffeeScript to JavaScript migration

//////////////////////////////////////
// All events related to jQuery
window.bonsai = {
  presicion: 2,
  separator: '.',
  delimiter: ' ',
  dateFormat: 'dd M yy'
};

////////////////////////////////////////
// Init function
const init = function($) {
  // Regional settings for jquery-ui datepicker
  $.datepicker.regional['es'] = {
    closeText: 'Close',
    prevText: '',//'<',
    nextText: '',//'>',
    currentText: 'Today',
    monthNames: ['January','February','March','April','May','June',
    'July','August','September','October','November','December'],
    monthNamesShort: ['Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'],
    dayNames: ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
    dayNamesShort: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'],
    dayNamesMin: ['Su','Mo','Tu','We','Th','Fr','Sa'],
    weekHeader: 'Sm',
    dateFormat: 'dd/mm/yy',
    firstDay: 1,
    isRTL: false,
    showMonthAfterYear: false,
    yearSuffix: ''
  };
  $.datepicker.setDefaults($.datepicker.regional['es']);

  // Effect for dropdown
  const initjDropDown = function() {
    $(this).find('li').bind('mouseover mouseout', function(event) {
      if (event.type == 'mouseover') {
        $(this).addClass('marked');
      } else {
        $(this).removeClass('marked');
      }
    });
  };
  $.initjDropDown = $.fn.initjDropDown = initjDropDown;

  // Speed in milliseconds
  const speed = 300;
  // Date format
  $.datepicker._defaults.dateFormat = 'dd M yy';

  //////////////////////////////////////////////////

  // Ajax preloader content
  const AjaxLoadingHTML = function() {
    return "<h4 class='c'><img src='/assets/ajax-loader.gif' alt='Loading..' /> Loading...</h4>";
  };

  // Width for dialog
  const getWidth = function(width) {
    const winWidth = $(window).width();
    return winWidth < width ? winWidth : width;
  };

  // Creates the dialog container
  window.createDialog = function(params) {
    const data = params;
    params.width = getWidth(params['width'] || 800);

    params = _.extend({
      id: new Date().getTime(), 
      title: '', 
      modal: true,
      resizable: false, 
      position: 'top', 
      dialogClass: 'normal-dialog'
    }, params);

    const html = params['html'] || AjaxLoadingHTML();
    const div_id = params.id;
    const div = document.createElement('div');
    const css = "ajax-modal " + (params['class'] || "");
    const $div = $(div);
    
    $div.attr({ 'id': params['id'], 'title': params['title'] }).data(data)
      .addClass(css).css({ 'z-index': 10000 }).html(html);
    
    delete(params['id']);
    delete(params['title']);

    $div.dialog(params);

    return $div;
  };

  window.AjaxLoadingHTML = AjaxLoadingHTML;

  $('body').on('click', '.ui-dialog-content.ajax-modal .cancel', function() {
    $(this).parents('.ajax-modal').dialog('close');
  });

  // Delete an Item from a list, deletes a tr or li
  // Very important with default fallback for trigger
  $('body').on('click', 'a.delete[data-remote=true]', function(e) {
    const self = this;
    $(self).parents("tr:first, li:first").addClass('marked');
    const trigger = $(self).data('trigger') || 'ajax:delete';

    const conf = $(self).data('confirm') || 'Are you sure you want to delete the selected item?';

    if(confirm(conf)) {
      const url = $(this).attr('href');
      const el = this;
      $.ajax({
        url: url,
        type: 'delete',
        context: el,
        data: {'authenticity_token': csrf_token },
        success: function(resp, status, xhr) {
          if (typeof resp == "object") {
            if (resp['destroyed?'] || resp.success) {
              $(el).parents("tr:first, li:first").remove();
              $('body').trigger(trigger, [resp, url]);
            } else {
              $(self).parents("tr:first, li:first").removeClass('marked');
              const error = resp.errors || "";
              alert(`Error could not delete: ${error}`);
            }
          } else if (resp.match(/^\/\/\s?javascript/)) {
            $(self).parents("tr:first, li:first").removeClass('marked');
          } else {
            alert('There was an error deleting');
          }
        },
        'error': function() {
          $(self).parents("tr:first, li:first").removeClass('marked');
          alert('There was an error deleting');
        }
      });
    } else {
      $(this).parents("tr:first, li:first").removeClass('marked');
      e.stopPropagation();
    }

    return false;
  });

  // Method to delete when it's in the .links in the top
  $('body').on('click', 'a.delete', function(event) {
    if ($(this).attr("data-remote")) return false;

    const txt = $(this).data("confirm") || "Are you sure you want to delete?";
    if (!confirm(txt)) {
      return false;
    } else {
      const html = `
        <form action="${$(this).attr('href')}" method="post">
          <input type="hidden" name="_method" value="delete" />
          <input type="hidden" name="authenticity_token" value="${csrf_token}" />
        </form>
      `;
      $(html).appendTo('body').submit();
    }
  });

  // Marks a row with a yellow color
  const mark = function(selector, velocity, val) {
    const self = selector || this;
    val = val || 0;
    velocity = velocity || 50;
    $(self).css({background: 'rgb(255,255,'+val+')'});
    if(val >= 255) {
      $(self).attr("style", "");
      return false;
    }
    setTimeout(function() {
      val += 5;
      mark(self, velocity, val);
    }, velocity);
  };

  $.mark = $.fn.mark = mark;

  // Adds a new link to any select with a data-new-url
  const dataNewUrl = function() {
    $(this).find('[data-new-url]').each(function(i, el) {
      const data = $.extend({width: 800}, $(el).data());
      const title = data.title || "New";
      const trigger = data.trigger || 'ajax-call';

      const $a = $('<a/>', {
        html: '<i class="icon-plus-sign"></i>',
        href: data.newUrl,
        title: title,
        'data-toggle': 'tooltip',
        class: 'btn add-new-url ajax',
        tabindex: -1
      })
      .data({trigger: trigger, width: data.width, elem: el, return: data.return});

      $a.insertAfter(el);
    });
  };

  $.fn.dataNewUrl = dataNewUrl;

  // Opens the correct tab for twitter bootstrap
  const activeTab = function(sel) {
    sel = sel || '#cont';
    if (window.location.hash) {
      sel = `ul.nav > li > a[href='${window.location.hash}']`;
      $(cont).find(sel).tab('show');
    } else {
      $(cont).find('ul.nav > li > a:first').tab('show');
    }
  };

  window.activeTab = activeTab;

  // Closes the nearest div container
  $('body').on('click', 'a.close', function() {
    const self = this;
    const cont = $(this).parents('div:first').hide(speed);
    if (!$(this).parents("div:first").hasClass("search")) {
      setTimeout(function() {
        cont.remove();
      }, speed);
    }
  });

  // Ajax configuration
  const csrf_token = $('meta[name=csrf-token]').attr('content');
  window.csrf_token = csrf_token;
  $.ajaxSetup({
    beforeSend: function(xhr) {
      xhr.setRequestHeader('X-CSRF-Token', csrf_token);
    }
  });
};
////////////////////////////////////////
// End of init function

////////////////////////////////////////
// Start jquery
(function($) {
  const createErrorLog = function(data) {
    if (!$('#error-log').length > 0) {
      $('<div id="error-log" style="background: #FFF"></div>')
        .dialog({title: 'Error', width: 900, height: 500});
    }

    $('#error-log').html(data).dialog("open");
  };

  // Creates a message window with the text passed
  // @param String: HTML to insert inside the message div
  // @param Object
  const createMessageCont = function(text, options) {
    return `<div class='message'><a class='close' href='javascript:'>Close</a>${text}</div>`;
  };

  window.createMessageCont = createMessageCont;

  // For the modal forms and dialogs
  const setTransformations = function() {
    $(this).setDatepicker();
    $(this).createAutocomplete();
  };

  $.fn.setTransformations = setTransformations;

  // Template
  // Underscore templates
  _.templateSettings.interpolate = /\[:(.+?):\]/g; //\{\{(.+?)\}\}/g

  ////////////////////////////////////////
  // Wrapped inside this working
  $(document).ready(function() {
    // Initializes
    init($);
    $('[data-toggle=tooltip]').tooltip();
    $('body').tooltip({selector: '[data-toggle=tooltip]'});
    $('body').setDatepicker();
    $('body').createAutocomplete();
    $('.select2-autocomplete').select2Autocomplete();
    $('body').dataNewUrl();
    fx.rates = exchangeRates.rates;

    // Prevent enter submit forms in some forms
    window.keyPress = false;
    $('body').on('keydown', 'form.enter input', function(event) {
      window.keyPress = event.keyCode;
      if ($(this).attr('type') === 'submit') return true;
      if (event.keyCode === 13) event.preventDefault();
    });

    $('.listing').on('mouseenter', '>li', function() {
      $(this).find('[title]').tooltip();
    });

    // OpenIn
    $('body').on('click', '[data-openin]', function(event) {
      event.preventDefault();
      const $this = $(this);
      const url = $this.attr('href');
      $($this.data('openin')).html(AjaxLoadingHTML())
        .load(url);
      if ($this.data('openinhide')) $this.hide();
    });

    // View more
    $('body').on('click', 'a.view-more', function(event) {
      const $this = $(this);
      $this.siblings('.modal-more:first').show('fast');
      $this.hide('fast');
      $this.parents('.ajax-modal').addClass('view-more-enabled');
    });
  });
  // End of $(document).ready
  
  _b.numSeparator = window.bonsai.separator;
  _b.numDelimiter = window.bonsai.delimiter;
})(jQuery);
