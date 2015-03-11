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

A tiny library to implement a **Policy Object pattern**.

The gem was inspired by:
* the CodeClimate's blog post "[7 ways to decompose fat ActiveRecord module]" 
* the part "How to Model Less Obvious Kinds of Concept" from the "[Domain-Driven Design]" by Eric Evans.

A **Policy Object** encapsulates a business rule in isolation from objects (such as entities or services) following it.

This separation provides a number of benefits:

* It makes business rules **explicit** instead of spreading and hiding them inside application objects.
* It makes the rules **reusable** in various context (think of the *transaction consistency* both in bank transfers and cach machine withdrawals).
* It allows definition of rules for **numerous attributes** that should correspond to each other in some way.
* It makes complex rules **testable** in isolation from even more complex objects.

[7 ways to decompose fat ActiveRecord module]: http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
[Domain-Driven Design]: http://www.amazon.com/dp/B00794TAUG/

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

## The Model for Illustration

Suppose an over-simplified model of bank account transactions and account-to-account transfers.

```ruby
# The bank account with a withdrawal limit being set
class Account < Struct.new(:limit); end

# The account transaction (either enrollment or witdrawal)
class Transaction < Struct.new(:account, :sum); end

# The account-to account transfer, connecting two separate transactions
# (maybe this isn't an optimal model, but helpful for the subject)
class Transfer < Struct.new(:withdrawal, :enrollment); end
```

What we need is to apply the simple policy:

**Withdrawal from one account should be equal to enrollment to another.**

Let's do it with Policy Objects! 

## Policy Declaration

Define policies with a list of necessary attributes like using [Struct].

Tnen use [ActiveModel::Validations] methods to describe its rules:

```ruby
# An arbitrary namespace for financial policies
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

Note a policy knows nothing about the complex nature of its attributes until their quack like transactions with `#sum` method defined.

[Struct]: http://ruby-doc.org//core-2.2.0/Struct.html
[ActiveModel::Validations]: http://apidock.com/rails/ActiveModel/Validations

## Following a Policy

Include the `Policy::Follower` module to the class and apply policies to corresponding attributes with `follow_policy` **class** method.

```ruby
class Transfer < Struct.new(:withdrawal, :enrollment)
  include Policy::Follower # also includes ActiveModel::Validations

  follow_policy Policies::Financial::Consistency, :withdrawal, :enrollment
end
```

The order of attributes should correspond to the policy definition.

You can swap attributes (this is ok for our example)...

```ruby
follow_policy Policies::Financial::Consistency, :enrollment, :withdrawal
```

...or use the same attribute several times when necessary (not in our example, though):

```ruby
follow_policy Policies::Financial::Consistency, :withdrawal, :withdrawal
```

Applied policies can be grouped by namespaces (useful when the object should follow many policies):

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

The policies are verified one-by-one until the first break - in just the same order they were declared.

### Asyncronous Verification

Define names for policies using `as:` option. The names should be unique in the class' scope:

```ruby
class Transfer < Struct.new(:withdrawal, :enrollment)
  include Policy::Follower

  use_policies Policies::Financial do
    follow_policy :Consistency, :withdrawal, :enrollment, as: :consistency
  end
end
```

Check policies by names (you can also use singular forms `follow_policy?` and `follow_policy!`):

```ruby
# Checks only consistency and skips all other policies
transaction.follow_policy? :consistency
transaction.follow_policy! :consistency
```

The set of policies can be checked at once:

```ruby
transaction.follow_policies? :consistency, ...
```

Now the policies are verified one-by-one in **given order** (it may differ from the order of policies declaration) until the first break.

# Compatibility

Tested under rubies, compatible with MRI 2.0+:

* MRI rubies 2.0+
* Rubinius 2+ (2.0+ mode)
* JRuby 1.7+ (2.0+ mode)

Rubies with API 1.9 are not supported.

Uses [ActiveModel::Validations] - tested for 3.1+

Uses [RSpec] 3.0+ for testing and [hexx-suit] for dev/test tools collection.

[RSpec]: http://rspec.info/
[hexx-suit]: https://github.com/nepalez/hexx-suit/
[ActiveModel::Validations]: http://apidock.com/rails/v3.1.0/ActiveModel/Validations

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
