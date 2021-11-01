class BaseForm
  include ActiveModel::Model
  extend ActiveModel::Callbacks

  def save
    ActiveRecord::Base.transaction do
      begin
        if valid?
          persist!
          true
        else
          false
        end
      rescue => e
        false
      end
    end
  end
end