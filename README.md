# ActiveAdmin Dynamic Fields [![Gem Version](https://badge.fury.io/rb/activeadmin_dynamic_fields.svg)](https://badge.fury.io/rb/activeadmin_dynamic_fields) [![CircleCI](https://circleci.com/gh/blocknotes/activeadmin_dynamic_fields.svg?style=svg)](https://circleci.com/gh/blocknotes/activeadmin_dynamic_fields)

An Active Admin plugin to add dynamic behaviors to some fields.

Features:
- set conditional checks on fields
- trigger actions on target elements
- inline field editing
- create links to load some content in a dialog

The easiest way to show how this plugin works is looking the examples [below](#examples).

## Install
- Add to your Gemfile: `gem 'activeadmin_dynamic_fields'`
- Execute bundle
- Add at the end of your ActiveAdmin javascripts (_app/assets/javascripts/active_admin.js_):

```js
//= require activeadmin/dynamic_fields
```

## Options
Options are passed to fields using *input_html* parameter as *data* attributes.

Conditions:
- **data-if**: check a condition, values:
  + **checked**: check if a checkbox is checked (ex. `"data-if": "checked"`)
  + **not_checked**: check if a checkbox is not checked
  + **blank**: check if a field is blank
  + **not_blank**: check if a field is not blank
  + **changed**: check if the value of an input is changed (dirty)
- **data-eq**: check if a field has a specific value (ex. `"data-eq": "42"`)
- **data-not**: check if a field has not a specific value
- **data-function**: check the return value of a custom function (ex. `"data-function": "my_check"`)

Actions:
- **data-then**: action to trigger (alias **data-action**), values:
  + **hide**: hides elements (ex. `"data-then": "hide", "data-target": ".errors"`)
  + **slide**: hides elements (using sliding)
  + **fade**: hides elements (using fading)
  + **addClass**: adds classes (ex. `"data-then": "addClass red"`)
  + **addStyle**: adds some styles (ex. `"data-then": "addStyle color: #fb1; font-size: 12px"`)
  + **setText**: set the text of an element (ex. `"data-then": "setText A sample text"`)
  + **setValue**: set the value of an input element (ex. `"data-then": "setValue A sample value"`)
  + **callback**: call a function (with arguments: **data-args**) (ex. `"data-then": "callback a_fun"`)
- **data-else**: action to trigger when the condition check is not true
- **data-args**: arguments passed to the callback function

Targets:
- **data-target**: target css selector (from parent fieldset, look for the closest match)
- **data-gtarget**: target css selector globally

A check condition or a custom check function are required. A trigger action is required too, unless you are using a custom function (in that case it is optional).

## Examples

### Dynamic fields examples
- A checkbox that hides other fields if is checked (ex. model *Article*):

```rb
form do |f|
  f.inputs 'Article' do
    f.input :published, input_html: { data: { if: 'checked', then: 'hide', target: '.grp1' } }
    f.input :online_date, wrapper_html: { class: 'grp1' }
    f.input :draft_notes, wrapper_html: { class: 'grp1' }
  end
  f.actions
end
```

- Add 3 classes (*first*, *second*, *third*) if a checkbox is not checked, else add "forth" class:

```rb
data = { if: 'not_checked', then: 'addClass first second third', target: '.grp1', else: 'addClass forth' }
f.input :published, input_html: { data: data }
```

- Set another field value if a string field is blank:

```rb
f.input :title, input_html: { data: { if: 'blank', then: 'setValue 10', target: '#article_position' } }
```

- Use a custom function for conditional check (*title_not_empty()* must be available on global scope) (with alternative syntax for data attributes):

```rb
attrs = { 'data-function': 'title_empty', 'data-then': 'slide', 'data-target': '#article_description_input' }
f.input :title, input_html: attrs
```

```js
function title_empty(el) {
  return ($('#article_title').val().trim() === '');
}
```

- Call a callback function as action:

```rb
data = { if: 'checked', then: 'callback set_title', args: '["Unpublished !"]' }
f.input :published, input_html: { data: data }
```

```js
function set_title(args) {
  if($('#article_title').val().trim() === '') {
    $('#article_title').val(args[0]);
    $('#article_title').trigger('change');
  }
}
```

- Custom function without action:

```rb
collection = [['Cat 1', 'cat1'], ['Cat 2', 'cat2'], ['Cat 3', 'cat3']]
f2.input :category, as: :select, collection: collection, input_html: { 'data-function': 'on_change_category' }
```

```js
function on_change_category(el) {
  var target = el.closest('fieldset').find('.pub');
  target.prop('checked', (el.val() == 'cat2');
  target.trigger('change');
}
```

### Inline editing examples
- Prepare a custom member action to save data, an *update* helper function is available (third parameter is optional, allow to filter using strong parameters):

```rb
member_action :save, method: [:post] do
  render ActiveAdmin::DynamicFields.update(resource, params)
  # render ActiveAdmin::DynamicFields.update(resource, params, [:published])
  # render ActiveAdmin::DynamicFields.update(resource, params, Article::permit_params)
end
```

- In *index* config:

```rb
# Edit a string:
column :title do |row|
  div row.title, ActiveAdmin::DynamicFields.edit_string(:title, save_admin_article_path(row.id))
end
# Edit a boolean:
column :published do |row|
  status_tag row.published, ActiveAdmin::DynamicFields.edit_boolean(:published, save_admin_article_path(row.id), row.published)
end
# Edit a select ([''] allow to have a blank value):
column :author do |row|
  select ActiveAdmin::DynamicFields.edit_select(:author_id, save_admin_article_path(row.id)) do
    options_for_select([''] + Author.pluck(:name, :id), row.author_id)
  end
end
```

- In *show* config (inside `attributes_table` block):
```rb
row :title do |row|
  div row.title, ActiveAdmin::DynamicFields.edit_string(:title, save_admin_article_path(row.id))
end
```

### Dialog example
Example with 2 models: *Author* and *Article*

Prepare the content dialog - in Active Admin Author config:

```rb
ActiveAdmin.register Author do
  # ...
  member_action :dialog do
    record = resource
    context = Arbre::Context.new do
      dl do
        %i[name age created_at].each do |field|
          dt "#{Author.human_attribute_name(field)}:"
          dd record[field]
        end
      end
    end
    render plain: context
  end
  # ...
end
```

Add a link to show the dialog - in Active Admin Article config:

```rb
ActiveAdmin.register Article do
  # ...
  show do |object|
    attributes_table do
      # ...
      row :author do
        link_to object.author.name, dialog_admin_author_path(object.author), title: object.author.name, 'data-df-dialog': true, 'data-df-icon': true
      end
    end
  end
  # ...
end
```

The link url is loaded via AJAX before opening the dialog.

## Do you like it? Star it!
If you use this component just star it. A developer is more motivated to improve a project when there is some interest.

Take a look at [other ActiveAdmin components](https://github.com/blocknotes?utf8=✓&tab=repositories&q=activeadmin&type=source) that I made if you are curious.

## Contributors
- [Mattia Roccoberton](http://blocknot.es): author
- The good guys that opened issues and pull requests from time to time

## License
The gem is available as open-source under the terms of the [MIT](LICENSE.txt).
