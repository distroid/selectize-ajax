# Selectize::Ajax

Useful [Selectize.js](https://selectize.github.io/selectize.js/) form control tag with autocomplete, create and edit items by ajax.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'selectize-ajax'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install selectize-ajax

In your application.js, include the following:

    //= require selectize-ajax

In your application.css, include the following:

    *= require selectize-ajax

## Usage

For example you want create dropdown control for choosing post category

```ruby
selectize_ajax_tag f.object, :category_id, collection: Category.collection
```

This code generate simple selectize dropdown.
The collection should be the following:

```ruby
[
  ...
  { value: <id>, label: <title> },
  ...
]
```

```ruby
def self.collection
  Category.map do |category|
    { label: category.title, value: category.id }
  end
end
```
### Autocomplete

For use ajax autocomplete you must add path for search:
```ruby
selectize_ajax_tag f.object, :category_id, collection_path: categories_autocomplete_path
```

By default search param is `q`, if you want use other param you need set `search_param` for control.

### Add new item

You can add new item from modal window. For this you need:

 1. Add path and modal target to selectize control
 2. Create modal and action on controller

```ruby
<%= selectize_ajax_tag f.object, :category_id,
    collection: Category.collection,
    add_path: new_category_path,
    add_modal: '#new-category-modal'
%>
```

Bootstrap modal window
```haml
  ...
  .modal-header
    %h4.modal-title
      Create new category

  .modal-body
    = simple_form_for(@category_form, url: categories_path,
      data: { target: '#new-category-modal' }, remote: true) do |f|
  ...
```

Controller action after success create new record should return json:
```ruby
def create
  ...
  render json: { label: record.title, value: record.id }
end
```

After that, the modal will close and the new record will be selected on dropdown.

### Edit selected item

For edit selected item you should add new modal and edit action path.

```ruby
<%= selectize_ajax_tag f.object, :category_id,
    collection: Category.collection,
    add_path: new_category_path,
    add_modal: '#new-category-modal',
    edit_path: edit_category_path(@category),
    edit_modal: '#edit-category-modal'
%>
```

**WARNING**: if you want use  `edit_path` and do not have record id for generate link path you need use following templates:

 - Replace ID to string `{{id}}` - `edit_category_path(id: '{{id}}')`
 - Or use `edit_category_path(id: f.object.category_id || '{{id}}')`
 - Or write hardcoded path without rails hepler `'/category/{{id}}/edit'` **(not recomended)**

Script automaticly will be replace `{{id}}` param to selected value.


## All options

 Parameter          | Values            | Default
--------------------|:------------------|:----------------
`label`             | string            | From object
`value`             | mixed             | From object
`placeholder`       | string            | --
`wrap_class`        | string \| false   | --
`wrap_class_only`   | true \| false     | false
`label_class`       | string            | --
`input_html[class]` | string            | --
`required`          | true \| false     | From object
`collection`        | array             | []
`add_modal`         | string            | --
`add_path`          | string            | --
`add_button_text`   | string            | I18n.t('selectize_ajax.add_button_text')
`add_button_class`  | string            | --
`edit_path`         | string            | --
`edit_modal`        | string            | --
`edit_button_text`  | string            | I18n.t('selectize_ajax.edit_button_text')
`edit_button_class` | string            | --
`horizontal`        | true \| false     | true
`collection_path`   | string            | --
`search_param`      | string            | `q`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/distroid/selectize-ajax.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
