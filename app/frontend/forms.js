// JavaScript version of forms.coffee
// Part of the CoffeeScript to JavaScript migration

$(function() {
  // Parses the date with a predefined format
  // @param String date
  // @param String type : Type to return
  const parseDate = function(date, type) {
    date = $.datepicker.parseDate($.datepicker._defaults.dateFormat, date);
    const d = [date.getFullYear(), date.getMonth() + 1, date.getDate()];
    if ('string' === type) {
      return d.join("-");
    } else {
      return d;
    }
  };

  // Must be before any ajax click event to work with HTMLUnit
  // Makes that a dialog opened window makes an AJAX request and returns a JSON response
  // if response is JSON then trigger event stored in dialog else present the HTML
  // There are three types of response JSON, JavaScript and HTML
  // JavaScript response must have "// javascript" at the beginning
  $('body').on('submit', 'div.ajax-modal form', function(event) {
    if ($(this).attr('enctype') === 'multipart/form-data') return true;
    if ($(this).hasClass("no-ajax")) return true;

    event.preventDefault();
    // Prevent from submiting the form.enter when hiting ENTER
    if ($(this).hasClass('enter') && window.keyPress === 13) return false;

    const $el = $(this);
    const data = $el.serialize();
    $el.find('input, select, textarea').attr('disabled', true);

    const $div = $el.parents('.ajax-modal:first');
    const trigger = $div.data('trigger') || "ajax-call";

    $.ajax({
      'url': $el.attr('action'),
      'cache': false,
      'context': $el,
      'data': data,
      'type': (data['_method'] || $el.attr('method'))
    })
    .success(function(resp, status, xhr) {
      $el.find('input, select, textarea').attr('disabled', false);
      if (typeof resp === 'object') {
        callEvents($div.data(), resp);
        $div.html('').dialog('destroy');
      } else if (resp.match(/^\/\/\s?javascript/)) {
        $div.html('').dialog('destroy');
      } else {
        if ($div.attr('ng-controller')) {
          const $scope = $div.scope();
          $scope.$apply(function(scope) {
            scope.htmlContent = '';
            scope.$$childHead = null;
            scope.$$childTail = null;
            console.log(resp);
            scope.htmlContent = resp;
          });
        } else {
          $div.html(resp);
        }

        setTimeout(function() {
          $div.setDatepicker();
        }, 200);
        // Trigger that form has been reloaded
        $div.trigger('reload:ajax-modal');
      }
    })
    .error(function(resp) {
      alert('There were errors, please try again.');
    });
  });
  // End submit ajax form

  const popoverNotitle = function(options) {
    $(this).popover(_.merge(options, {
      template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'
    }));
  };

  $.popoverNotitle = $.fn.popoverNotitle = popoverNotitle;

  // Set autocomplete values
  const setAutocompleteValues = function(el, resp) {
    const $el = $(el);
    $el.val(resp.to_s);
    $el.data('value', resp.to_s);
    $el.siblings('input:hidden').val(resp.id);
  };

  // Adds an option to select and selects that option
  const setSelectValues = function(el, vals) {
    const $el = $(el);
    const desc = vals.to_s || vals.name || vals.description;
    $el.append(`<option value='${vals.id}'>${desc}</option>`);
    $el.val(`${vals.id}`).trigger('change');
  };

  // Calls the events after ajax call on ajax form
  const callEvents = function(data, resp) {
    if (!data) return;

    const $el = $(data.elem);

    if ($el.hasClass('autocomplete')) {
      setAutocompleteValues($el, resp);
    } else if ($el.get(0).nodeName === 'SELECT') {
      setSelectValues(data.elem, resp);
    }

    $el.trigger('ajax-call', resp);
  };

  ////////////////////////////////////////
  // Activates autocomplete for all autocomplete inputs
  const createAutocomplete = function() {
    $(this).find('div.autocomplete').each(function(i, el) {
      const $this = $(el);
      const $hidden = $this.find('[type=hidden]');
      const $input = $this.find('[type=text]');

      $input.autocomplete({
        source: $input.data('source'),
        select: function(e, ui) {
          $input.data('value', ui.item.value);
          $hidden.val(ui.item.id);
          $input.trigger('autocomplete-done', [ui.item]);
        },
        search: function(e, ui) {
          $input.addClass('loading');
        },
        response: function(e, ui) {
          $input.removeClass('loading');

          if (ui.content.length === 0) {
            $input.popoverNotitle({content: 'No results found'});
            $input.popover('show');
            $input.on('focusout', function() { $input.popover('destroy'); });
          } else {
            $input.popover('destroy');
          }
        }
      }).on('focusout keyup', function(event) {
        const $this = $(this);
        const value = $this.val();
        if (value.trim() === '') {
          $hidden.val('');
          $(this).data('value', '');
          $input.trigger('autocomplete-reset');
        }

        if (event.type === 'focusout') {
          $this.val($this.data('value'));
        }
      });
    });
  };

  $.fn.createAutocomplete = $.createAutocomplete = createAutocomplete;

  ////////////////////////////////////////
  // Datepicker for simple_form
  const setDatepicker = function() {
    $(this).find('div.datepicker:not(.hasDatepicker), span.datepicker:not(.hasDatepicker)').each(function(i, el) {
      const $this = $(el);
      $this.addClass('hasDatepicker');
      const $hidden = $this.find('[type=hidden]');
      const $picker = $this.find('[type=text]');

      let value = '';
      if ($hidden.val()) {
        const date = $.datepicker.parseDate('yy-mm-dd', $hidden.val());
        const formattedDate = $.datepicker.formatDate($.datepicker._defaults.dateFormat, date);
        $picker.val(formattedDate);
      }

      $picker.datepicker({
        yearRange: '1900:',
        showOn: $picker.data('hideButton') ? 'focus' : 'both',
        //showOptions: {direction: 'up'},
        //showOtherMonths: true,
        //showWeeks: false,
        //stepMonths: 1,
        buttonText: '',
        altFormat: 'yy-mm-dd',
        altField: $hidden.get(0)
      });
    });
  };

  $.setDatepicker = $.fn.setDatepicker = setDatepicker;
  
  ////////////////////////////////////////
  const createSelectOption = function(value, label) {
    const opt = `<option selected='selected' value='${value}'>${label}</option>`;
    $(this).append(opt).val(value).mark();
  };

  $.fn.createSelectOption = $.createSelectOption = createSelectOption;

  ////////////////////////////////////////
  // Select2
  $.fn.select2.defaults = _.merge($.fn.select2.defaults, {
    numCars: function(n) { return n === 1 ? "" : "s"; },
    formatResultCssClass: function() { return undefined; },
    formatNoMatches: function() { return "No matches found"; },
    formatInputTooShort: function(input, min) {
      const n = min - input.length;
      return `Enter ${n} more character${this.numCars(n)}`;
    },
    formatInputTooLong: function(input, max) {
      const n = input.length - max;
      return `Enter ${n} fewer character${this.numCars(n)}`;
    },
    /*
    formatSelectionTooBig: function() {
      //function (limit) { return "You can only select " + limit + " item" + (limit == 1 ? "" : "s"); },
    },
    */
    formatLoadMore: function() { return "Loading results..."; },
    //function (pageNumber) { return "Loading more results..."; },
    formatSearching: function() { return "Searching..."; }
  });

  const select2Autocomplete = function(el) {
    const $this = $(this);

    $this.select2({
      minimumInputLength: 2,
      ajax: {
        url: $this.data('source'),
        dataType: 'json',
        data: function(term) {
          return { q: term };
        },
        results: function(data, page) {
          return {results: data};
        }
      },
      formatResult: function(res) {
        return `${res.to_s}`;
      },
      formatSelection: function(res) {
        return `${res.to_s}`;
      }
    });
    
    if ($this.data('value') !== '') {
      const $a = $this.select2('container').find('>a');
      $a.removeClass('select2-default')
        .find('>span').text($this.data('value'));
    }
  };

  $.select2Autocomplete = $.fn.select2Autocomplete = select2Autocomplete;

  // For button tabs
  const buttonTab = function() {
    const $cont = $(this);

    $cont.find('>.buttons-list>.btn-group')
      .on('click', 'button', function() {
        $cont.find('>.panes>.button-pane').hide();
        $($(this).attr('href')).show();
      })
      .find('button:first').trigger('click');
  };

  $.buttonTab = $.fn.buttonTab = buttonTab;
});
