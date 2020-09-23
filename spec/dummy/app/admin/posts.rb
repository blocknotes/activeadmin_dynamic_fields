# frozen_string_literal: true

ActiveAdmin.register Post do # rubocop:disable Metrics/BlockLength
  permit_params :author_id, :title, :description, :category, :dt, :position, :published, tag_ids: []

  member_action :save, method: [:post] do
    render ActiveAdmin::DynamicFields.update(resource, params)
  end

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :published do |row|
      status_tag row.published, ActiveAdmin::DynamicFields.edit_boolean(:published, save_admin_post_path(row.id), row.published)
    end
    column :created_at
    actions
  end

  show do |record|
    attributes_table do
      row :author do
        link_to record.author.name, dialog_admin_author_path(record.author), title: record.author.name, 'data-df-dialog': true, 'data-df-icon': true
      end
      row :title
      row :description
      row :category
      row :dt
      row :position
      row :published
      row :tags
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    def add_field(form, name, type, data, override_options = {})
      options = { as: type, input_html: { data: data }, hint: data.inspect }
      options.merge! override_options
      form.input name, options
    end

    f.inputs 'Post' do
      f.input :author
      f.input :title

      f.input :data_test, as: :string

      # --- if
      df111 = { if: 'checked', then: 'addClass red', target: '#post_data_field_111_input label' }
      add_field(f, :data_field_111, :boolean, df111)

      df121 = { if: 'not_checked', then: 'addClass red', target: '#post_data_field_121_input label' }
      add_field(f, :data_field_121, :boolean, df121)

      df131 = { if: 'blank', then: 'addClass red', target: '#post_data_field_131_input label' }
      add_field(f, :data_field_131, :string, df131)

      df132 = { if: 'blank', then: 'addClass red', target: '#post_data_field_132_input label' }
      add_field(f, :data_field_132, :text, df132)

      df141 = { if: 'not_blank', then: 'addClass red', target: '#post_data_field_141_input label' }
      add_field(f, :data_field_141, :string, df141)

      df142 = { if: 'not_blank', then: 'addClass red', target: '#post_data_field_142_input label' }
      add_field(f, :data_field_142, :text, df142)

      df151 = { if: 'changed', then: 'addClass red', target: '#post_data_field_151_input label' }
      add_field(f, :data_field_151, :boolean, df151)

      df152 = { if: 'changed', then: 'addClass red', target: '#post_data_field_152_input label' }
      add_field(f, :data_field_152, :string, df152)

      df153 = { if: 'changed', then: 'addClass red', target: '#post_data_field_153_input label' }
      add_field(f, :data_field_153, :text, df153)

      # --- eq
      df161 = { eq: '161', then: 'addClass red', target: '#post_data_field_161_input label' }
      add_field(f, :data_field_161, :string, df161)

      df162 = { eq: '162', then: 'addClass red', target: '#post_data_field_162_input label' }
      add_field(f, :data_field_162, :select, df162, collection: [161, 162, 163])

      df163 = { eq: '163', then: 'addClass red', target: '#post_data_field_163_input label' }
      add_field(f, :data_field_163, :text, df163)

      # --- not
      df181 = { not: '181', then: 'addClass red', target: '#post_data_field_181_input label' }
      add_field(f, :data_field_181, :string, df181)

      df182 = { not: '182', then: 'addClass red', target: '#post_data_field_182_input label' }
      add_field(f, :data_field_182, :select, df182, collection: [181, 182, 183])

      df183 = { not: '183', then: 'addClass red', target: '#post_data_field_183_input label' }
      add_field(f, :data_field_183, :text, df183)

      # --- function
      df201 = { function: 'test_fun', then: 'addClass red', target: '#post_data_field_201_input label' }
      add_field(f, :data_field_201, :string, df201)

      df202 = { function: 'missing_fun', then: 'addClass red', target: '#post_data_field_202_input label' }
      add_field(f, :data_field_202, :string, df202)

      df203 = { function: 'test_fun2' }
      add_field(f, :data_field_203, :boolean, df203)

      # --- addClass
      df211 = { if: 'checked', then: 'addClass red', target: '#post_data_field_211_input label' }
      add_field(f, :data_field_211, :boolean, df211)

      # --- callback
      df221 = { if: 'checked', then: 'callback test_callback', args: 'test_callback_arg' }
      add_field(f, :data_field_221, :boolean, df221)

      df222 = { if: 'checked', then: 'callback missing_callback', args: 'callback arg' }
      add_field(f, :data_field_222, :boolean, df222)

      # --- setValue
      df231 = { if: 'checked', then: 'setValue data test', target: '#post_data_test' }
      add_field(f, :data_field_231, :boolean, df231)

      # --- hide
      df241 = { if: 'checked', then: 'hide', target: '#post_data_field_241_input .inline-hints' }
      add_field(f, :data_field_241, :boolean, df241)

      # --- fade
      df251 = { if: 'checked', then: 'fade', target: '#post_data_field_251_input .inline-hints' }
      add_field(f, :data_field_251, :boolean, df251)

      # --- slide
      df261 = { if: 'checked', then: 'slide', target: '#post_data_field_261_input .inline-hints' }
      add_field(f, :data_field_261, :boolean, df261)

      # --- setText
      df271 = { if: 'checked', then: 'setText data test', target: '#post_data_field_271_input .inline-hints' }
      add_field(f, :data_field_271, :boolean, df271)

      # --- gtarget
      df301 = { if: 'checked', then: 'addClass red', gtarget: 'body.active_admin' }
      add_field(f, :data_field_301, :boolean, df301)

      # This will not work - here only for testing:
      df302 = { if: 'checked', then: 'addClass red', target: 'body.active_admin' }
      add_field(f, :data_field_302, :boolean, df302)

      # --- else
      df321 = { if: 'checked', then: 'addClass red', target: '#post_data_field_321_input label', else: 'addClass green' }
      add_field(f, :data_field_321, :boolean, df321)
    end

    f.inputs 'Tags' do
      f.input :tags
    end

    f.actions
  end
end
