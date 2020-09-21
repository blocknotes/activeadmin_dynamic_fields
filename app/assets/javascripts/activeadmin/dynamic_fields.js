(function () {
  'use strict'

  const ACTIONS = {
    addClass: (el, name) => el.addClass(name),
    callback: (el, name) => {
      if (window[name]) window[name](el.data('args'))
      else {
        el.attr('data-df-errors', 'callback function not found')
        console.warn(`activeadmin_dynamic_fields callback function not found: ${name}`)
      }
    },
    fade: el => el.fadeOut(),
    hide: el => el.hide(),
    setValue: (el, value) => dfSetValue(el, value),
    slide: el => el.slideUp()
  }

  const CONDITIONS = {
    blank: el => el.val().length === 0 || !el.val().trim(),
    changed: _el => true,
    checked: el => el.is(':checked'),
    eq: (el, value) => el.val() == value,
    not: (el, value) => el.val() != value,
    not_blank: el => el.val().trim(),
    not_checked: el => !el.is(':checked')
  }

  const REVERSE_ACTIONS = {
    addClass: (el, name) => el.removeClass(name),
    fade: el => el.fadeIn(),
    hide: el => el.show(),
    slide: el => el.slideDown()
  }

  class Field {
    constructor(el) {
      const action = (el.data('then') || el.data('action') || '')
      const action_name = action.split(' ', 1)[0]

      this.el = el
      this.action = ACTIONS[action_name]
      this.action_arg = action.substring(action.indexOf(' ') + 1)
      this.reverse_action = REVERSE_ACTIONS[action_name]
      this.condition = CONDITIONS[el.data('if')]
      if (!this.condition && el.data('eq')) {
        [this.condition, this.condition_arg] = [CONDITIONS['eq'], el.data('eq')]
      }
      if (!this.condition && el.data('not')) {
        [this.condition, this.condition_arg] = [CONDITIONS['not'], el.data('not')]
      }
      this.custom_function = el.data('function')
      if (!this.condition && this.custom_function) {
        this.condition = window[this.custom_function]
        if (!this.condition) {
          el.attr('data-df-errors', 'custom function not found')
          console.warn(`activeadmin_dynamic_fields custom function not found: ${this.custom_function}`)
        }
      }

      // closest find for has many associations
      if (el.data('target')) this.target = el.closest('fieldset').find(el.data('target'))
      else if (el.data('gtarget')) this.target = $(el.data('gtarget'))
      if (action_name == 'callback') this.target = el
    }

    apply(el) {
      if (this.condition(el, this.condition_arg)) {
        this.action(this.target, this.action_arg)
      }
      else {
        if (this.reverse_action) this.reverse_action(this.target, this.action_arg)
      }
    }

    is_valid() {
      if (!this.condition) return false
      if (!this.action && !this.custom_function) return false

      return true
    }

    setup() {
      if (!this.is_valid()) return
      if (this.el.data('if') != 'changed') this.apply(this.el)
      this.el.on('change', () => this.apply(this.el))  
    }
  }

  // Set the value of an element
  function dfSetValue(el, val) {
    if (el.attr('type') == 'checkbox') el.prop('checked', val == '1')
    else el.val(val)
    el.trigger('change')
  }

  // Inline update - must be called binded on the editing element
  function dfUpdateField() {
    if ($(this).data('loading') != '1') {
      $(this).data('loading', '1');
      let _this = $(this);
      let type = $(this).data('field-type');
      let new_value;
      if (type == 'boolean') new_value = !$(this).data('field-value');
      else if (type == 'select') new_value = $(this).val();
      else new_value = $(this).text();
      let data = {};
      data[$(this).data('field')] = new_value;
      $.ajax({
        context: _this,
        data: { data: data },
        method: 'POST',
        url: $(this).data('save-url'),
        complete: function (req, status) {
          $(this).data('loading', '0');
        },
        success: function (data, status, req) {
          if (data.status == 'error') {
            if ($(this).data('show-errors')) {
              let result = '';
              let message = data.message;
              for (let key in message) {
                if (typeof (message[key]) === 'object') {
                  if (result) result += ' - ';
                  result += key + ': ' + message[key].join('; ');
                }
              }
              if (result) alert(result);
            }
          }
          else {
            $(this).data('field-value', new_value);
            if ($(this).data('content')) {
              let old_text = $(this).text();
              let old_class = $(this).attr('class');
              let content = $($(this).data('content'));
              $(this).text(content.text());
              $(this).attr('class', content.attr('class'));
              content.text(old_text);
              content.attr('class', old_class);
              $(this).data('content', content);
            }
          }
        }
      });
    }
  }

  // Init
  $(document).ready(function () {
    // Setup dynamic fields
    const selectors = '.active_admin .input [data-if], .active_admin .input [data-eq], .active_admin .input [data-not], .active_admin .input [data-function]'
    $(selectors).each(function () {
      new Field($(this)).setup()
    })

    // Setup dynamic fields for associations
    $('.active_admin .has_many_container').on('has_many_add:after', () => {
      $(selectors).each(function () {
        new Field($(this)).setup()
      })
    })

    // Set dialog icon link
    $('.active_admin [data-df-icon]').each(function () {
      $(this).append(' &raquo;')
    })

    // Open content in dialog
    $('.active_admin [data-df-dialog]').on('click', function (event) {
      event.preventDefault()
      $(this).blur()
      if ($('#df-dialog').data('loading') != '1') {
        $('#df-dialog').data('loading', '1')
        if ($('#df-dialog').length == 0) $('body').append('<div id="df-dialog"></div>')
        let title = $(this).attr('title')
        $.ajax({
          url: $(this).attr('href'),
          complete: function (req, status) {
            $('#df-dialog').data('loading', '0')
          },
          success: function (data, status, req) {
            if (title) $('#df-dialog').attr('title', title)
            $('#df-dialog').html(data)
            $('#df-dialog').dialog({ modal: true })
          },
        })
      }
    })

    // Inline editing
    $('[data-field][data-field-type="boolean"][data-save-url]').each(function () {
      $(this).on('click', $.proxy(dfUpdateField, $(this)))
    })
    $('[data-field][data-field-type="string"][data-save-url]').each(function () {
      $(this).data('field-value', $(this).text())
      let fnUpdate = $.proxy(dfUpdateField, $(this))
      $(this).on('blur', function () {
        if ($(this).data('field-value') != $(this).text()) fnUpdate()
      })
    })
    $('[data-field][data-field-type="select"][data-save-url]').each(function () {
      $(this).on('change', $.proxy(dfUpdateField, $(this)))
    })
  })
})()
