class Role < ActiveRecord::Base
  ADMIN="admin"
  ORIGINATOR="originator"
  ORGANIZER="organizer"
  MEMBER="member"

  belongs_to :user, inverse_of: :roles

  scope :relevant, ->(model_name, model_id) { 
    where("mname is null or (mname=:mname and (mid is null or mid=:mid))", 
      :mname=>model_name, :mid=>model_id)
  }

  scope :application, ->{ where("mid is null") }
end
