class Flag < ActiveRecord::Base
  attr_accessible :comment_id, :author_name, :author_email, :author_ip, :author_user_agent, :referer, :guest_count
  belongs_to :comment
   
  after_destroy :update_flag_status
  after_save :update_flag_status

  validates :comment_id, :presence => true

  scope :latest, order("created_at DESC").limit(100)

  def add_flag
    self.guest_count = self.guest_count.to_i + 1
    self.save
  end
  
  def update_flag_status
    flag_comment = self.comment
    flag_comment.flag_status = flag_comment.flagged
    flag_comment.save
  end
  
end
