# encoding: utf-8

require "adamantium"

# Policy Object builder
#
# @!parse include Policy::Interface
module Policy

  require_relative "policy/version"
  require_relative "policy/validations"
  require_relative "policy/violation_error"
  require_relative "policy/interface"
  require_relative "policy/follower"

  class << self

    # Builds a base class for the policy object with some attributes
    #
    # @example
    #   class TransactionPolicy < Policy.new(:debet, :credit)
    #   end
    #
    # @param [Array<Symbol>] attributes
    #   names for the policy object attributes
    #
    # @return [Struct]
    def new(*attributes)
      Struct.new(*attributes) do
        include Interface
        
        def self.name
          "Policy"
        end

      end
    end

  end # Policy singleton class

end # module Policy
