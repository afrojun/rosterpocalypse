class AccessPolicy
  include AccessGranted::Policy

  def configure
    # Policy for AccessGranted.
    # For more details check the README at
    #
    # https://github.com/chaps-io/access-granted/blob/master/README.md
    #
    # Roles inherit from less important roles, so:
    # - :admin has permissions defined in :member, :guest and himself
    # - :member has permissions from :guest and himself
    # - :guest has only its own permissions since it's the first role.
    #
    # The most important role should be at the top.
    #
    role :owner, proc { |user| user.present? && user.admin? && user.owner? } do
      can [:manage, :make_admin], User
    end

    role :admin, proc { |user| user.present? && user.admin? } do
      can :manage, User do |target_user, user|
        !target_user.admin?
      end
      can :manage, Manager
      can :manage, Game
      can :manage, Hero
      can :manage, Team
      can :manage, Map
      can :manage, Player
      can :manage, Roster
      can :manage, PlayerGameDetail
      can :manage, PlayerAlternateName
      can :manage, TeamAlternateName
    end

    # More privileged role, applies to registered users.
    #
    role :member, proc { |user| user.present? && user.registered? } do
      can :create, Roster
      can [:update, :destroy], Roster do |roster, user|
        roster.manager.user.id == user.id
      end
    end

    # The base role with no additional conditions.
    # Applies to every user.
    #
    role :guest do
      can :read, Manager
      can :read, Game
      can :read, Hero
      can :read, Team
      can :read, Map
      can :read, Player
      can :read, Roster
    end
  end
end
