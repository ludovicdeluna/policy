# encoding: utf-8

module Policy

  module Follower

    # Converter of items to array of unique symbols
    #
    # @api private
    module Names

      # Converts items to array of unique symbols
      #
      # @example
      #   Policy::Follower::Names.from "foo", [:foo, "bar"], "baz"
      #   # => [:foo, :bar, :baz]
      #
      # @param [Array<#to_sym>] items
      #
      # @return [Array<Symbol>]
      def self.from(*items)
        items.flatten.map(&:to_sym)
      end

    end

  end

end
