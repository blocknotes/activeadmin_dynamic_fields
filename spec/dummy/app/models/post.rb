# frozen_string_literal: true

class Post < ApplicationRecord
  enum state: %i[available unavailable arriving]

  belongs_to :author, inverse_of: :posts, autosave: true

  has_one :author_profile, through: :author, source: :profile

  has_many :post_tags, inverse_of: :post, dependent: :destroy
  has_many :tags, through: :post_tags

  serialize :description, JSON

  after_initialize -> { self.description = {} if description.nil? }

  validates :title, allow_blank: false, presence: true

  scope :published, -> { where(published: true) }
  scope :recents, -> { where('created_at > ?', Date.today - 8.month) }

  def method_missing(method_name, *arguments, &_block)
    method = method_name.to_s
    if method.start_with? 'data_'
      method.gsub! /\Adata_/, ''
      if method.end_with? '='
        self.description ||= {}
        description.send(:[]=, method.chop, arguments.any? ? arguments[0] : nil)
      else
        description&.send(:[], method)
      end
    else
      super
    end
  end

  def respond_to_missing?(method_name, _include_private = false) # rubocop:disable Style/OptionalBooleanParameter
    method_name.to_s.start_with?('data_') ? true : super
  end

  def short_title
    title.truncate 10
  end

  def upper_title
    title.upcase
  end

  class << self
    def ransackable_associations(_auth_object = nil)
      ["author", "author_profile", "post_tags", "tags"]
    end

    def ransackable_attributes(_auth_object = nil)
      ["author_id", "category", "created_at", "description", "dt", "id", "position", "published", "title", "updated_at"]
    end
  end
end
