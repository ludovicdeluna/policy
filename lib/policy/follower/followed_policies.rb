# encoding: utf-8

module Policy

  module Follower

    # Describes the list of followed policies
    #
    # @api private
    class FollowedPolicies < Hash

      # Registers followed policy with given unique key
      #
      # @param [Policy::Follower::FollowedPolicy] policy
      #
      # @return [undefined]
      def add(policy)
        self[policy.name] = policy
      end

      # Applies to follower the policies, selected by names
      #
      # @param [Policy::Follower] follower
      # @param [Array<#to_s>] names
      #
      # @raise [Policy::ViolationError]
      #   unless all policies are met
      #
      # @return [undefined]
      def apply_to(follower, *names)
        named_by(names).each { |policy| policy.apply_to(follower) }
      end

      private

      def named_by(list)
        names = Names.from list
        names.any? ? names.map(&method(:[])).compact : values
      end

    end # class FollowedPolicies

  end # module Follower

end # module Policy
