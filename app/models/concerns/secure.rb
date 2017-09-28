module Secure
  extend ActiveSupport::Concern

  def permissions user=nil
    policy = AccessPolicy.new(user)

    def create_permission policy, perm
      policy.can? perm, self
    end

    perms = [:create, :read, :update, :destroy]

    Hash[perms.collect { |k| [k, create_permission(policy, k)] }]
  end

end

