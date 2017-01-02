class Thing < ActiveRecord::Base
  validates :name, :presence=>true
end
