Policy
======

[![Gem Version](https://img.shields.io/gem/v/policy.svg?style=flat)][gem]
[![Build Status](https://img.shields.io/travis/nepalez/policy/master.svg?style=flat)][travis]
[![Dependency Status](https://img.shields.io/gemnasium/nepalez/policy.svg?style=flat)][gemnasium]
[![Code Climate](https://img.shields.io/codeclimate/github/nepalez/policy.svg?style=flat)][codeclimate]
[![Coverage](https://img.shields.io/coveralls/nepalez/policy.svg?style=flat)][coveralls]
[![Inline docs](http://inch-ci.org/github/nepalez/policy.svg)][inch]

[codeclimate]: https://codeclimate.com/github/nepalez/policy
[coveralls]: https://coveralls.io/r/nepalez/policy
[gem]: https://rubygems.org/gems/policy
[gemnasium]: https://gemnasium.com/nepalez/policy
[travis]: https://travis-ci.org/nepalez/policy
[inch]: https://inch-ci.org/github/nepalez/policy

The tiny library to implement a [Policy Object pattern].

The module provides:

* Policy class builder (`Policy`).
* Policy follower module (`Policy::Follower`).

[Policy Object pattern]: http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
[Struct]: http://ruby-doc.org//core-2.2.0/Struct.html
[ActiveModel::Validations]: http://apidock.com/rails/ActiveModel/Validations

# Installation

Add this line to your application's Gemfile:

```ruby
    gem "policy"
```

And then execute:

```
    $ bundle
```

Or install it yourself as:

```
    $ gem install policy
```

# Usage

Suppose you have models with attributes:
* `Account` with `:limit` and `:sum`;
* `Transaction` with `:account` and `:sum`;
* `Transfer` with `:witdrawal` and `:enrollment`.

And you need to apply the rule (policy):

* Withdrawal from one account should be equal to enrollment to another.

Let's do it with Policy Objects! 

## Policy Declaration

Define policies with a list of necessary attributes (like using [Struct]), and use [ActiveModel::Validations] methods to describe the policy rules:

```ruby
# An arbitrary namespace for policies
module Policies::Financial

  # Withdrawal from one account should be equal to enrollment to another
  class Consistency < Policy.new(:withdrawal, :enrollment)

    validates :withdrawal, :enrollment, presence: true
    validates :total_sum, numericality: { equal_to: 0 }

    private

    def total_sum
      withdrawal.sum + enrollment.sum
    end
  end
end
```

Policy can be declared and tested in isolation both from each other and from classes that follows them. They can be reused in various contexts.

## Following a Policy

Include the `Policy::Follower` module to the class and apply policies to corresponding attributes with `follow_policy` **class** method.

```ruby
class Transfer < Struct.new(:withdrawal, :enrollment)
  include Policy::Follower # also includes ActiveModel::Validations

  follow_policy Policies::Financial::Consistency, :withdrawal, :enrollment
end
```

The order of attributes should correspond to the policy definition.

You can swap attributes...

```ruby
follow_policy Policies::Financial::Consistency, :enrollment, :withdrawal
```

...or use the same attribute several times:

```ruby
follow_policy Policies::Financial::Consistency, :withdrawal, :withdrawal
```

Applied policies can be grouped by namespaces:

```ruby
use_policies Policies::Financial do
  follow_policy :Consistency, :withdrawal, :enrollment
end
```

## Policies Verification

To verify object use `#follow_policies?` or `#follow_policies!` **instance** methods.

```ruby
Transaction = Struct.new(:account, :sum)
withdrawal  = Transaction.new(account_1, -100)
enrollment  = Transaction.new(account_2, 1000)

transfer = Transfer.new withdrawal, enrollment

transfer.follow_policies?
# => false

transfer.follow_policies!
# => raises <Policy::ViolationError>
```

The policies are verified one-by-one until the first break in the same order they were applied.

### Asyncronous Verification

Define the unique names for policies using `as:` option:

```ruby
class Transfer < Struct.new(:withdrawal, :enrollment)
  include Policy::Follower

  use_policies Policies::Financial do
    follow_policy :Consistency, :withdrawal, :enrollment, as: :consistency
  end
end
```

Check policies by names (you can use a singular form `follow_policy`):

```ruby
# Checks only consistency and skips all other policies
transaction.follow_policy? :consistency
transaction.follow_policy! :consistency
```

The set of policies can be checked at once:

```ruby
transaction.follow_policies? :consistency, ...
```

The policies are verified one-by-one in given order until the first break.

# Compatibility

Tested under MRI rubies >= 2.1. Rubies under 2.1 aren't supported yet.

Uses [RSpec] 3.0+ for testing and [hexx-suit] for dev/test tools collection.

# Contributing

* Fork the project.
* Read the [STYLEGUIDE](config/metrics/STYLEGUIDE).
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version
  in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

# License

See [MIT LICENSE](LICENSE).
