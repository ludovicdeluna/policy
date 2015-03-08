# encoding: utf-8

module Policy

  # An exception to be risen by {Policy::Interface#apply}
  class ViolationError < RuntimeError
    include Adamantium

    # @!attribute [r] policy
    # The violated policy object
    #
    # @return [Policy::Follower]
    attr_reader :policy

    # @!scope class
    # @!method new(policy)
    # Constructs an exception
    #
    # @param [Policy::Follower] policy
    #   the violated policy object
    #
    # @return [Policy::ViolationError]
    def initialize(policy)
      @policy = policy.dup
    end

    # The human-readable description for the exception
    #
    # @return [String]
    def inspect
      "#<#{ self }: #{ message }>"
    end

    # The human-readable exception message
    #
    # @return [String]
    def message
      "#{ policy } violated: #{ messages }"
    end

    # The list of messages from the broken policy
    #
    # @return [Array<String>]
    def messages
      policy.messages
    end

    memoize :message, :messages, :inspect

  end # module Follower

end # module Policy
