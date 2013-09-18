class SiteModerator < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  attr_accessible :site_id, :user_id
  validates :site_id, :uniqueness => {:scope => :user_id}
end
