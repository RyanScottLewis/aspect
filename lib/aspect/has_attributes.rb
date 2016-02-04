module Aspect
  # Easily define attribute getter/setter/accessors on an object with a `.attribute` class method.
  #
  # This also defines the `#update_attributes` instance method to use for mass assignment.
  #
  # **Documentation Notes**
  #
  # Since `.attribute` is a method which dynamically defines methods, you may need to use a special declaration
  # in order to associate the documentation to the method.
  #
  # Here's how I do it with [YARD](http://yardoc.org):
  #
  # ```
  # class User
  #   include Aspect::HasAttributes
  #
  #   # @method name
  #   # Get the name.
  #   #
  #   # @return [String]
  #
  #   # @method name=
  #   # Set the name.
  #   #
  #   # @param [#to_s] value
  #   # @return [String]
  #   attribute(:name) { |value| value.to_s.strip }
  #
  #   # @method admin?
  #   # Get whether this user is an admin.
  #   #
  #   # @return [Boolean]
  #
  #   # @method admin=
  #   # Set whether this user is an admin.
  #   #
  #   # @param [Boolean] value
  #   # @return [Boolean]
  #   attribute(:admin, query: true)
  # end
  # ```
  module HasAttributes
    # The class methods to extend into the object HasAttributes was included in.
    module ClassMethods
      # @method attribute
      # Define an attribute on the object.
      #
      # @example Simple accessor
      #   class User
      #     include Aspect::HasAttributes
      #
      #     attribute(:name)
      #   end
      #
      #   user = User.new
      #   user.name = "Ezio Auditore"
      #   user.name # => "Ezio Auditore"
      # @example Simple getter
      #   class User
      #     include Aspect::HasAttributes
      #
      #     attribute(:name, setter: false)
      #
      #     def initialize(name)
      #       @name = name
      #     end
      #   end
      #
      #   user = User.new("Ezio Auditore")
      #   user.name # => "Ezio Auditore"
      # @example Simple setter
      #   class User
      #     include Aspect::HasAttributes
      #
      #     attribute(:name, getter: false)
      #
      #     def name
      #       @name.strip
      #     end
      #   end
      #
      #   user = User.new
      #   user.name = "  Ezio Auditore  "
      #   user.name # => "Ezio Auditore"
      # @example Accessor with block
      #   class User
      #     include Aspect::HasAttributes
      #
      #     attribute(:name) { |value| value.to_s.strip }
      #   end
      #
      #   user = User.new
      #   user.name = "  Ezio Auditore  "
      #   user.name # => "Ezio Auditore"
      # @example Accessor with block, passing options
      #   class User
      #     include Aspect::HasAttributes
      #
      #     conversion_block = Proc.new { |value, options| "#{options[:prefix]}-#{value.to_s.strip}" }
      #     attribute(:foo, prefix: "Foo", &conversion_block)
      #     attribute(:bar, prefix: "Bar", &conversion_block)
      #   end
      #
      #   user = User.new
      #   user.foo = "  Thing  "
      #   user.foo # => "Foo-Thing"
      #   user.bar = "   Thingy"
      #   user.bar # => "Bar-Thingy"
      # @example Query accessor
      #   class User
      #     include Aspect::HasAttributes
      #
      #     attribute(:admin, query: true)
      #   end
      #
      #   user = User.new
      #   user.admin? # => false
      #   user.admin = "yep" # Accepts truthy values
      #   user.admin? # => true
      # @example Query accessor with block
      #   class User
      #     include Aspect::HasAttributes
      #
      #     attribute(:moderator, query: true)
      #     attribute(:admin, query: true) { |value| @moderator && value }
      #   end
      #
      #   user = User.new
      #
      #   user.moderator? # => false
      #   user.admin? # => false
      #   user.admin = true
      #   user.admin? # => false
      #
      #   user.moderator = true
      #   user.moderator? # => true
      #   user.admin? # => false
      #   user.admin = true
      #   user.moderator? # => true
      #   user.admin? # => true
      # @param [#to_sym] name The name of the attribute and instance variable.
      # @param [Hash, #to_hash] options The options for defining and passing to the block.
      # @option options [Boolean] :getter (true) Determines whether to define an attribute getter.
      # @option options [Boolean] :setter (true) Determines whether to define an attribute setter.
      # @option options [Boolean] :query (false)
      #   Determines whether to define as a query attribute, with the getter having a question mark appended to the
      #   method name and the setter converting the value or block into a boolean using bang-bang (`!!`).
      # @option options [#to_sym] :method (nil) The method name to send to the value after executing
      # @yieldparam [Object] value The value given to the setter method.
      # @yieldparam [Hash] options The options given when defining, given to the setter method.
      # @yieldreturn [Object] The value to set the instance variable as.
      # @return [Object]
      def attribute(name, options={}, &block) # TODO: Should break out into protected methods?
        name = name.to_sym

        options = options.to_h unless options.is_a?(Hash)
        options = { getter: true, setter: true }.merge(options)

        if options[:getter]
          options[:getter] = options[:getter] == true ? {} : options[:getter].to_h

          options[:getter][:method]          = options[:getter][:method].to_sym          if options[:getter][:method]
          options[:getter][:instance_method] = options[:getter][:instance_method].to_sym if options[:getter][:instance_method]

          method_name = options[:query] ? "#{name}?" : name
          define_method(method_name) do
            value = instance_variable_get("@#{name}")
            value = value.send(options[:getter][:method]) if options[:getter][:method]
            value = method(options[:getter][:instance_method]).call(value) if options[:getter][:instance_method]

            options[:query] ? !!value : value
          end
        end

        if options[:setter]
          options[:setter] = options[:setter] == true ? {} : options[:setter].to_h

          options[:setter][:method]          = options[:setter][:method].to_sym          if options[:setter][:method]
          options[:setter][:instance_method] = options[:setter][:instance_method].to_sym if options[:setter][:instance_method]

          define_method("#{name}=") do |value|
            value = instance_exec(value, options, &block) unless block.nil?
            value = value.send(options[:setter][:method]) if options[:setter][:method]
            value = method(options[:setter][:instance_method]).call(value) if options[:setter][:instance_method]
            value = options[:query] ? !!value : value

            instance_variable_set("@#{name}", value)
          end
        end

        self
      end
    end

    class << self
      # On include hook.
      def included(base)
        base.send(:extend, ClassMethods)
      end
    end

    # @method update_attributes
    # Update attributes on this object.
    #
    # @example
    #   class User
    #     include Aspect::HasAttributes
    #
    #     attribute(:name) { |value| value.to_s.strip }
    #     attribute(:moderator, query: true)
    #     attribute(:admin, query: true) { |value| @moderator ? value : false }
    #   end
    #
    #   user = User.new
    #
    #   user.name # => nil
    #   user.moderator? # => false
    #   user.admin? # => false
    #
    #   user.update_attributes(name: "  Ezio Auditore  ", moderator: true)
    #
    #   user.name # => "Ezio Auditore"
    #   user.moderator? # => true
    #   user.admin? # => false
    # @example In `#initialize`
    #   class User
    #     include Aspect::HasAttributes
    #
    #     def initialize(attributes={})
    #       update_attributes(attributes)
    #     end
    #
    #     attribute(:name) { |value| value.to_s.strip }
    #     attribute(:moderator, query: true)
    #     attribute(:admin, query: true) { |value| @moderator ? value : false }
    #   end
    #
    #   user = User.new(name: "  Ezio Auditore  ", moderator: true)
    #
    #   user.name # => "Ezio Auditore"
    #   user.moderator? # => true
    #   user.admin? # => false
    # @param [Hash, #to_h] attributes
    # @return [Object] This object.
    def update_attributes(attributes={})
      attributes = attributes.to_h unless attributes.is_a?(Hash)

      attributes.each { |name, value| send("#{name}=", value) }
    end
  end
end
