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
      can :manage, Match
      can :manage, Game
      can :manage, GameDetail
      can :manage, Hero
      can :manage, Team
      can :manage, TeamAlternateName
      can :manage, Map
      can :manage, Player
      can :manage, PlayerAlternateName
      can :manage, Roster
      can :manage, League
      can :manage, PublicLeague
      can :manage, PrivateLeague
      can :manage, Tournament
      can :manage, Gameweek
    end

    # More privileged role, applies to registered users.
    #
    role :member, proc { |user| user.present? && user.registered? && !user.unconfirmed? } do
      can :read, Manager
      can :update, Manager do |manager, user|
        manager.user.id == user.id
      end
      can :read, Match
      can :read, Game
      can :read, Hero
      can :read, Team
      can :read, Map
      can :read, Player
      can :read, Tournament
      can :read, Gameweek
      can :read, PublicLeague
      can [:read, :create], League
      can [:read, :create], PrivateLeague
      can [:update, :destroy], PrivateLeague do |league, user|
        league.manager.user.id == user.id
      end
      can [:read, :create], Roster
      can [:update, :destroy], Roster do |roster, user|
        roster.manager.user.id == user.id
      end
    end

    role :unconfirmed_member, proc { |user| user.present? && user.registered? && user.unconfirmed? } do
      can :read, Manager
      can :read, Match
      can :read, Game
      can :read, Hero
      can :read, Team
      can :read, Map
      can :read, Player
      can :read, Tournament
      can :read, Gameweek
      can :read, League
      can :read, PublicLeague
      can :read, PrivateLeague
      can :read, Roster
    end

    # The base role with no additional conditions.
    # Applies to every user.
    #
    role :guest do
      # Very limited access, can only view the home page and sign up
    end
  end
end
