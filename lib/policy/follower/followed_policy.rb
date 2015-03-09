# encoding: utf-8

module Policy

  module Follower

    # Stores the policy to be applied to all instances of the follower
    #
    # The policy object can be set either as a constant, or by name
    # in given namespace. Namespace and policy name can be set separately.
    #
    # The separation is used at the {Policy::Follower#apply_policies}.
    #
    # @example The policy can be constant
    #   FollowedPolicy.new nil, Foo::Bar::Baz, :baz_policy, :baz
    #
    # @example The policy can be name, relative to the namespace
    #   FollowedPolicy.new Foo::Bar, :Baz, :baz_policy, :baz
    #   # Foo::Bar::Baz policy object will be used
    #
    # @api private
    class FollowedPolicy
      include Adamantium

      # @!scope class
      # @!method new(policy, name, *attributes)
      # Creates the immutable policy to be followed by given object
      #
      # @param [Module] namespace
      #   the namespace for the policy, given by name
      # @param [Class, #to_s] policy
      #   the class for applicable policy
      # @param [#to_sym, nil] name
      #   the name for the policy
      # @param [Array<Symbol>] attributes
      #   the list of follower attributes to apply the policy to
      #
      # @return [Policy::Follower::FollowedPolicy]
      #   immutable object
      def initialize(namespace, policy, name, *attributes)
        @policy     = find_policy(namespace, policy)
        @name       = (name || SecureRandom.uuid).to_sym
        @attributes = check_attributes attributes
      end

      # @!attribute [r] name
      # The name for the policy
      #
      # @return [Symbol]
      attr_reader :name

      # @!attribute [r] policy
      # The policy object class to be followed
      #
      # @return [Class]
      attr_reader :policy

      # @!attribute [r] attributes
      # The list of follower attributes to be send to the policy object
      #
      # @return [Array<Symbol>]
      attr_reader :attributes

      # Applies the policy to follower instance
      #
      # @param [Policy::Follower]
      #   follower
      #
      # @raise [Policy::ViolationError]
      #   it the follower doesn't meet the policy
      #
      # @return [undefined]
      def apply_to(follower)
        policy.apply(*attributes_of(follower))
      end

      private

      def find_policy(namespace, policy)
        return policy if policy.instance_of?(Class)
        instance_eval [namespace, policy].join("::")
      end

      def attributes_of(follower)
        attributes.map(&follower.method(:send))
      end

      def check_attributes(attributes)
        number = policy.members.count - 1
        return attributes if attributes.count.equal?(number)
        fail wrong_number(number, attributes)
      end

      def wrong_number(number, attributes)
        ArgumentError.new [
          "#{ policy } requires #{ number } attribute(s).",
          "#{ attributes } cannot be assigned."
        ].join(" ")
      end

    end # class FollowedPolicy

  end # module Follower

end # module Policy
