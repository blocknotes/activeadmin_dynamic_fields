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
    f.inputs 'Post' do
      f.input :author
      f.input :title
      f.input :description, input_html: { data: { if: 'blank', action: 'setValue no title', target: '#post_category' } }
      f.input :category
      f.input :published, input_html: { data: { if: 'not_checked', action: 'hide', target: '.group1' } }
      f.input :dt, wrapper_html: { class: 'group1' }
      f.input :position, wrapper_html: { class: 'group1' }
    end

    f.inputs 'Tags' do
      f.input :tags
    end

    f.actions
  end
end
