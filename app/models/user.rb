require 'digest/md5'

class User < ActiveRecord::Base
  has_many :sites, :inverse_of => :user, :order => 'name', :dependent => :destroy
  has_many :topics, :through => :sites
  
  has_many :site_moderators, :dependent => :destroy
  has_many :sites_as_moderator, :through => :site_moderators, :source => :site
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :timeoutable

  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :roles, :email, :password, :password_confirmation, :remember_me, :admin, :as => :admin
  
  before_validation :nullify_blank_password_on_update

  scope :with_role, lambda { |role| where("roles_mask & ? > 0", 2**ROLES.index(role.to_s) )}

  # Defines the roles that exist. To see what roles can do see the ability contorller.
  ROLES = %w[admin site_moderator]
  
  def comments
    Comment.
      joins(:topic => { :site => :user }).
      where(:users => { :id => id }).
      order('comments.created_at DESC')
  end
  
  def accessible_comments
    if role?(:admin)
      Comment.where(nil)
    else
      comments
    end
  end
  
  def accessible_sites
    if role?(:admin)
      Site.where(nil)
    else
      sites
    end
  end
  
  def email_md5
    if email
      Digest::MD5.hexdigest(email.downcase)
    else
      nil
    end
  end

  def role
    if role?(:admin)
      :admin
    else
      nil
    end
  end

  def admin?
    role?(:admin)
  end

  def role?(role)
    return false unless ROLES.include?(role.to_s)
    roles.include?(role.to_s)
  end

  # Makes a roles mask to push and pull mutliple roles out of the database using a bit mask.
  # http://railscasts.com/episodes/189-embedded-association
  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject { |r| ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero? }
  end

  def role_symbols
    roles.map(&:to_sym)
  end


private
  def nullify_blank_password_on_update
    if !new_record?
      self.password = nil if password.blank?
      self.password_confirmation = nil if password_confirmation.blank?
    end
  end
end
