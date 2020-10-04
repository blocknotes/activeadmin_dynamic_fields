(function () {
  'use strict'

  const ACTIONS = {
    addClass: (el, name) => el.addClass(name),
    addStyle: (el, extra_style) => {
      let style = (el.attr('style') || '').trim()
      if (!style.includes(extra_style)) {
        if (style) style = style.replace(/;$/, '') + '; ' // ensure style ends with ;
        el.attr('style', `${style}${extra_style}`)
      }
    },
    callback: (el, name) => {
      if (window[name]) window[name](el.data('args'))
      else {
        el.attr('data-df-errors', 'callback function not found')
        console.warn(`activeadmin_dynamic_fields callback function not found: ${name}`)
      }
    },
    fade: el => el.fadeOut(),
    hide: el => el.hide(),
    setText: (el, text) => el.text(text),
    setValue: (el, value) => {
      if (el.attr('type') == 'checkbox') el.prop('checked', value == '1')
      else el.val(value)
      el.trigger('change')
    },
    slide: el => el.slideUp()
  }
  const CONDITIONS = {
    blank: el => el.val().length === 0 || !el.val().trim(),
    changed: _el => true,
    checked: el => el.is(':checked'),
    eq: (el, value) => el.val() == value,
    match: (el, regexp) => regexp.test(el.val()),
    mismatch: (el, regexp) => !regexp.test(el.val()),
    not: (el, value) => el.val() != value,
    not_blank: el => !CONDITIONS.blank(el),
    not_checked: el => !el.is(':checked')
  }
  const REVERSE_ACTIONS = {
    addClass: (el, name) => el.removeClass(name),
    addStyle: (el, extra_style) => {
      if(el.attr('style')) el.attr('style', el.attr('style').replace(extra_style, ''))
    },
    fade: el => el.fadeIn(),
    hide: el => el.show(),
    slide: el => el.slideDown()
  }

  const REGEXP_NOT = /^!\s*/

  class Field {
    constructor(el) {
      this.el = el
      const action_name = this.evaluateAction()
      const result = this.evaluateCondition()
      this.condition = result.condition
      this.condition_arg = result.condition_arg
      this.evaluateTarget(action_name)
    }

    apply() {
      if (this.condition(this.el, this.condition_arg)) {
        if (this.else_reverse_action) this.else_reverse_action(this.target, this.else_action_arg)
        this.action(this.target, this.action_arg)
      }
      else {
        if (this.reverse_action) this.reverse_action(this.target, this.action_arg)
        if (this.else_action) this.else_action(this.target, this.else_action_arg)
      }
    }

    evaluateAction() {
      const action = this.el.data('then') || this.el.data('action') || ''
      const action_name = action.split(' ', 1)[0]
      const else_action = this.el.data('else') || ''
      const else_action_name = else_action.split(' ', 1)[0]

      this.action = ACTIONS[action_name]
      this.action_arg = action.substring(action.indexOf(' ') + 1)
      this.reverse_action = REVERSE_ACTIONS[action_name]
      this.else_action = ACTIONS[else_action_name]
      this.else_action_arg = else_action.substring(else_action.indexOf(' ') + 1)
      this.else_reverse_action = REVERSE_ACTIONS[else_action_name]

      return action_name
    }

    evaluateCondition() {
      let value
      if (value = this.el.data('if')) {
        if (REGEXP_NOT.test(value)) value = 'not_' + value.replace(REGEXP_NOT, '')
        return { condition: CONDITIONS[value] }
      }
      if (value = this.el.data('eq')) {
        if (REGEXP_NOT.test(value)) {
          return { condition: CONDITIONS['not'], condition_arg: value.replace(REGEXP_NOT, '') }
        }
        return { condition: CONDITIONS['eq'], condition_arg: value }
      }
      if (value = this.el.data('not')) {
        if (REGEXP_NOT.test(value)) {
          return { condition: CONDITIONS['eq'], condition_arg: value.replace(REGEXP_NOT, '') }
        }
        return { condition: CONDITIONS['not'], condition_arg: value }
      }
      if (value = this.el.data('match')) {
        return { condition: CONDITIONS['match'], condition_arg: new RegExp(value) }
      }
      if (value = this.el.data('mismatch')) {
        return { condition: CONDITIONS['mismatch'], condition_arg: new RegExp(value) }
      }

      this.custom_function = this.el.data('function')
      if (this.custom_function) {
        value = window[this.custom_function]
        if (value) return { condition: value }
        else {
          this.el.attr('data-df-errors', 'custom function not found')
          console.warn(`activeadmin_dynamic_fields custom function not found: ${this.custom_function}`)
        }
      }

      return {}
    }

    evaluateTarget(action_name) {
      // closest find for has many associations
      if (this.el.data('target')) this.target = this.el.closest('fieldset').find(this.el.data('target'))
      else if (this.el.data('gtarget')) this.target = $(this.el.data('gtarget'))
      if (action_name == 'callback') this.target = this.el
    }

    isValid() {
      if (!this.condition) return false
      if (!this.action && !this.custom_function) return false

      return true
    }

    setup() {
      if (!this.isValid()) return
      if (this.el.data('if') != 'changed') this.apply()
      this.el.on('change', () => this.apply())  
    }
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
    const selectors = '.active_admin .input [data-if], .active_admin .input [data-eq], .active_admin .input [data-not], .active_admin .input [data-match], .active_admin .input [data-mismatch], .active_admin .input [data-function]'
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
