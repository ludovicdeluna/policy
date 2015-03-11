# encoding: utf-8

module Policy

  # Policy object interface
  module Interface

    # @private
    def self.included(klass)
      klass.extend(ClassMethods).__send__(:include, Validations)
    end

    # Container for the policy class methods
    module ClassMethods

      # Creates and validates the policy object
      #
      # @param (see Policy.new)
      #
      # @raise (see Policy::Interface#apply)
      #
      # @return [undefined]
      def apply(*attributes)
        new(*attributes).apply
      end

    end

    # Returns the list of error messages
    #
    # @return [Array<String>]
    def messages
      errors.messages.values.flatten
    end

    # Validates the policy object
    #
    # @raise [ViolationError]
    #   if a policy is invalid
    #
    # @return [undefined]
    def apply
      fail ViolationError.new(self) unless valid?
    end

  end # class Interface

end # module Policy
