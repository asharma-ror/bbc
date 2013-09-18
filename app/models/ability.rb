class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Non-logged in users cannot do anything.
    return if !user

    crud = [:create, :read, :update, :destroy]

    if user.admin?
      can :manage, :all
    elsif user.role?(:site_moderator)
      can [:read, :update, :destroy], User, :id => user.id
      can [:read], Site, :users_as_moderator => { :id => user.id}
      can [:create, :read, :update, :destroy, :open_close_commenting], Topic, :site => { :users_as_moderator => { :id => user.id} }
      can [:create, :read, :update, :destroy, :flags, :destroy_flag, :approve, :destroy_comments_by_author], Comment, :topic => { :site => { :users_as_moderator => { :id => user.id} } }
      can crud, Flag, :comment => { :topic => { :site => { :users_as_moderator => { :id => user.id} } }}
    end
  end
end
