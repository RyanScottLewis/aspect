# Aspect

A small collection of useful classes, modules, and mixins for plain old Ruby objects.

## Install

### Bundler: `gem "aspect"`

### RubyGems: `gem install aspect`

## Requiring

You should cherry pick the classes/modules you want to load like so:

```rb
require "aspect/has_attributes"

class User
  include Aspect::HasAttributes
end
```

You can load all classes/modules in a module by requiring just the directory:

```rb
require "aspect/foo/bar" # Would load aspect/foo/bar/**/*.rb
require "aspect/foo"     # Would load aspect/foo/**/*.rb
require "aspect"         # Would all files
```

## Usage

### Aspect::HasAttributes

**[Documentation](http://www.rubydoc.info/gems/aspect/Aspect/HasAttributes)**

```rb
require "aspect/has_attributes"

class User
  include Aspect::HasAttributes

  attribute(:name) { |value| value.to_s.strip }
  attribute(:moderator, query: true)
  attribute(:admin, query: true) { |value| @moderator && value }

  def initialize(attributes={})
    update_attributes(attributes)
  end
end

user = User.new(name: "  Ezio   ")

p user.name # => "Ezio"
user.name = :Ezio
p user.name # => "Ezio"

p user.moderator? # => false
p user.admin? # => false
user.admin = true
p user.moderator? # => false
p user.admin? # => false
user.moderator = "truthy value"
user.admin = true
p user.moderator? # => true
p user.admin? # => true
```

You can change the method names if you're including into an object which already
defines `.attribute` and `#update_attributes`:

```rb
require "aspect/has_attributes"

class User
  include Aspect::HasAttributes(method: { define: :atr, update: :mass_assign })

  atr(:name) { |value| value.to_s.strip }
  atr(:moderator, query: true)
  atr(:admin, query: true) { |value| @moderator && value }

  def initialize(attributes={})
    mass_assign(attributes)
  end
end
```

You may omit either method from being defined by passing `false` to it's `:method` option:

```rb
require "aspect/has_attributes"

class User
  include Aspect::HasAttributes(method: { define: false })

  def initialize(attributes={})
    update_attributes(attributes)
  end
end

p User.respond_to?(:attribute) # => false
```

## Copyright

Copyright © 2016 Ryan Scott Lewis <ryan@rynet.us>.

The MIT License (MIT) - See LICENSE for further details.
