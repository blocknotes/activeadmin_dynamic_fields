//= require active_admin/base

//= require activeadmin/dynamic_fields

function test_fun(el) {
  return el.val() == 'test'
}

function test_fun2(el) {
  el.toggleClass('red', !el.is(':checked'))
}

function test_callback(args) {
  $('body').addClass(args)
}
