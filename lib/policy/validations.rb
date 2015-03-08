# encoding: utf-8
require "active_model"

module Policy

  # Wrapper around the ActiveModel::Validations
  #
  # Provides shared interface for [Policy::Inteface] and [Policy::Follower].
  #
  # @todo Implement it later from scratch without excessive features
  #
  # @example
  #   MyClass.include Policy::Validations
  #
  # @private
  module Validations

    # The implementation for validations
    IMPLEMENTATION = ActiveModel::Validations

    # @private
    def self.included(klass)
      klass.include(IMPLEMENTATION)
    end

  end # module Validations

end # module Policy
