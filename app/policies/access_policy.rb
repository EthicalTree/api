class AccessPolicy
  include AccessGranted::Policy

  def configure
    # Example policy for AccessGranted.
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
    # In this case an administrator.
    #
    role :admin, proc { |user| user && user.admin? } do
      can :manage, User
      can :manage, Listing
      can :manage, Tag
      can :manage, CuratedList
      can :manage, DirectoryLocation
    end

    role :member, proc { |user| !!user } do
      can :create, Listing
      can :update, Listing do |listing, user|
        listing.owner == user
      end
    end

    role :guest do
      can :read, Listing
    end

  end
end
