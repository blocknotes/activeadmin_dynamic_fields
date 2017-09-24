require 'active_admin'

module ActiveAdmin
  module DynamicFields
    class Engine < ::Rails::Engine
      engine_name 'activeadmin_dynamic_fields'
    end

    def self.edit_boolean( field, url, value )
      { 'data-field': field, 'data-field-type': 'boolean', 'data-field-value': value, 'data-content': "<span class=\"status_tag changed\">#{value ? 'no' : 'yes'}</span>", 'data-save-url': url, 'data-show-errors': '1' }
    end

    def self.edit_select( field, url )
      { 'data-field': field, 'data-field-type': 'select', 'data-save-url': url, 'data-show-errors': '1' }
    end

    def self.edit_string( field, url )
      { contenteditable: true, 'data-field': field, 'data-field-type': 'string', 'data-save-url': url, 'data-show-errors': '1' }
    end

    def self.update( resource, params, permit_params = nil )
      if params[:data]
        if resource.update( permit_params ? params[:data].permit( permit_params ) : params[:data].permit! )
          { json: { status: 'ok' } }
        else
          { json: { status: 'error', message: resource.errors } }
        end
      else
        { json: { status: 'error', message: 'No data' }, status: 400 }
      end
    end
  end
end
