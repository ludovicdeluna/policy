# encoding: utf-8

module Policy

  # Adds features for the object to follow external policies
  module Follower

    require_relative "follower/names"
    require_relative "follower/followed_policy"
    require_relative "follower/followed_policies"

    # Methods to be added to the class the module is included to
    #
    # @private
    module ClassMethods

      # @!attribute [r] followed_policies
      # The collection of policies to be followed by instances of the class
      #
      # @return [Policy::Follower::FollowedPolicies]
      #
      # @private
      def followed_policies
        @followed_policies ||= FollowedPolicies.new
      end

      # Adds a policy to the list of {#followed_policies}
      #
      # @param [Class] policy
      #   the policy object klass
      # @param [Array<#to_sym>] attributes
      #   the list of attributes of the instance the policy should be applied to
      #
      # @option [#to_sym] :as
      #   the name for the policy to be used for selecting it
      #   in {#follow_policies!} and {#follow_policies?} methods
      #
      # @return [undefined]
      def follow_policy(policy, *attributes, as: nil)
        object = FollowedPolicy.new(__policies__, policy, as, *attributes)
        followed_policies.add object
      end

      # Changes the namespace for applied policies
      #
      # @example For Policies::Finances::TransferConsistency
      #   use_policies Policies::Finances do
      #     apply_policy :TransferConstistency, :debet, :credit
      #   end
      #
      # @param [Module] namespace
      #
      # @yield the block in the current scope
      #
      # @return [undefined]
      def use_policies(namespace, &block)
        @__policies__ = namespace
        instance_eval(&block)
      ensure
        @__policies__ = nil
      end

      private

      def __policies__
        @__policies__ ||= self
      end

    end

    # Checks whether an instance meets selected policies
    #
    # Mutates the object by adding new #errors
    #
    # @param [Array<#to_sym>] names
    #   the ordered list of names to select policies by
    #   when not names selected all policies will be applied
    #
    # @raise [Policy::ViolationError]
    #   unless all selected policies has been met
    #
    # @return [undefined]
    def follow_policies!(*names)
      followed_policies.apply_to self, *names
    rescue ViolationError => error
      collect_errors_from(error)
      raise
    end

    # Syntax shugar for the {#follow_policies!} with one argument
    #
    # @param [#to_sym] name
    #   the name of the policy to follow
    #
    # @raise (see #follow_policies!)
    #
    # @return [undefined]
    def follow_policy!(name)
      follow_policies! name
    end

    # Safely checks whether an instance meets selected policies
    #
    # Mutates the object by adding new #errors
    #
    # @param (see #follow_policies!)
    #
    # @return [Boolean]
    def follow_policies?(*names)
      follow_policies!(*names)
      true
    rescue ViolationError
      false
    end

    # Syntax shugar for the {#follow_policies?} with one argument
    #
    # @param  (see #follow_policy!)
    #
    # @return (see #follow_policies?)
    def follow_policy?(name)
      follow_policies? name
    end

    private

    # @!parse extend  Policy::Follower::ClassMethods
    # @!parse include ActiveModel::Validations
    def self.included(klass)
      klass.extend(ClassMethods).__send__(:include, Validations)
    end

    def followed_policies
      @followed_policies ||= self.class.followed_policies
    end

    def collect_errors_from(exception)
      exception.messages.each { |text| errors.add :base, text }
    end

  end # module Follower

end # module Policy
