# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :author, inverse_of: :profile, touch: true

  def to_s
    description
  end

  class << self
    def ransackable_attributes(_auth_object = nil)
      ["author_id", "created_at", "description", "id", "updated_at"]
    end
  end
end
