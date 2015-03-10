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
  def self.new(*attributes)
    Struct.new(*attributes).include(Interface)
  end

end # module Policy
