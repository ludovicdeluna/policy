# encoding: utf-8

# Loads the RSpec test suit.
require "hexx-suit"

# Loads runtime metrics in the current scope
Hexx::Suit.load_metrics_for(self)

# Loads the code of the module.
require "policy"
