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

end # module Policy
