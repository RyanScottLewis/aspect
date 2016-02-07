require "spec_helper"

class TestObject
  include Aspect::HasAttributes

  def initialize
    @name = "foobar"
  end
end

describe Aspect::HasAttributes do
  describe ".attribute" do
    context "when no options are given" do
      context "and no block is given" do
        let(:instance) do
          instance_class = Class.new(TestObject) do
            attribute(:name)
          end

          instance_class.new
        end

        it "should define a getter and a setter which uses the argument given to set the instance variable" do
          expect(instance.name).to eq("foobar")
          instance.name = "foo"
          expect(instance.name).to eq("foo")
        end
      end

      context "and a block is given" do
        let(:instance) do
          instance_class = Class.new(TestObject) do
            attribute(:name) { |value| value.to_s }
          end

          instance_class.new
        end

        it "should define a getter and a setter which uses the return value of the block to set the instance variable" do
          expect(instance.name).to eq("foobar")
          instance.name = 123
          expect(instance.name).to eq("123")
        end
      end
    end

    context "when the :getter option is given" do
      context "and it's truthy" do
        let(:instance) do
          instance_class = Class.new(TestObject) do
            attribute(:name, getter: true)
          end

          instance_class.new
        end

        it "should define the getter" do
          expect(instance.name).to eq("foobar")
        end
      end

      context "and it's falsey" do
        let(:instance) do
          instance_class = Class.new(TestObject) do
            attribute(:name, getter: false)
          end

          instance_class.new
        end

        it "should not define a getter" do
          expect(instance).not_to respond_to(:name)
        end
      end
    end

    context "when the :setter option is given" do
      context "and no block is given" do
        context "and it's truthy" do
          let(:instance) do
            instance_class = Class.new(TestObject) do
              attribute(:name, setter: true)
            end

            instance_class.new
          end

          it "should define a setter which uses the argument given to set the instance variable" do
            expect(instance.name).to eq("foobar")
            instance.name = "foobar"
            expect(instance.name).to eq("foobar")
          end
        end

        context "and it's falsey" do
          let(:instance) do
            instance_class = Class.new(TestObject) do
              attribute(:name, setter: false)
            end

            instance_class.new
          end

          it "should define a getter and not a setter" do
            expect(instance).to respond_to(:name)
            expect(instance).not_to respond_to(:name=)
          end
        end
      end

      context "and a block is given" do
        context "and it's truthy" do
          let(:instance) do
            instance_class = Class.new(TestObject) do
              attribute(:name, setter: true) { |value| value.reverse }
            end

            instance_class.new
          end

          it "should define a setter which uses the argument given to set the instance variable" do
            expect(instance.name).to eq("foobar")
            instance.name = "foobar"
            expect(instance.name).to eq("raboof")
          end
        end

        context "and it's falsey" do
          let(:instance) do
            instance_class = Class.new(TestObject) do
              attribute(:name, setter: false)
            end

            instance_class.new
          end

          it "should define a getter and not a setter" do
            expect(instance).to respond_to(:name)
            expect(instance).not_to respond_to(:name=)
          end
        end
      end
    end

    context "when the :query option is given" do
      context "and no block is given" do
        context "and it's truthy" do
          let(:instance) do
            instance_class = Class.new(TestObject) do
              attribute(:admin, query: true)
            end

            instance_class.new
          end

          it "should define a query getter and a query setter which uses the argument given to set the instance variable as a truthy value" do
            expect(instance.admin?).to eq(false)
            instance.admin = "truthy"
            expect(instance.admin?).to eq(true)
          end
        end

        context "and it's falsey" do
          let(:instance) do
            instance_class = Class.new(TestObject) do
              attribute(:admin, query: false)
            end

            instance_class.new
          end

          it "should define a getter and a setter which uses the return value of the block to set the instance variable" do
            expect(instance.admin).to eq(nil)
            instance.admin = "truthy"
            expect(instance.admin).to eq("truthy")
          end
        end
      end

      context "and a block is given" do
        context "and it's truthy" do
          let(:instance) do
            instance_class = Class.new(TestObject) do
              attribute(:moderator, query: true)
              attribute(:admin, query: true) { |value| @moderator && value }
            end

            instance_class.new
          end

          it "should define a query getter and a query setter which uses the return value of the block to set the instance variable as a truthy value" do
            expect(instance.moderator?).to eq(false)
            expect(instance.admin?).to eq(false)
            instance.admin = "truthy"
            expect(instance.admin?).to eq(false)
            instance.moderator = true
            instance.admin = "truthy"
            expect(instance.moderator?).to eq(true)
            expect(instance.admin?).to eq(true)
          end
        end

        context "and it's falsey" do
          let(:instance) do
            instance_class = Class.new(TestObject) do
              attribute(:admin, query: false) { "return value" }
            end

            instance_class.new
          end

          it "should define a getter and a setter which uses the return value of the block to set the instance variable" do
            expect(instance.admin).to eq(nil)
            instance.admin = "anything"
            expect(instance.admin).to eq("return value")
          end
        end
      end
    end
  end

  describe "#update_attributes" do
    let(:instance) do
      class_instance = Class.new(TestObject) do
        attr_accessor :name
        attr_accessor :age
      end

      class_instance.new
    end

    it "should update the attributes on the instance" do
      instance.update_attributes(name: "Foo Bar", age: 123)

      expect(instance.name).to eq("Foo Bar")
      expect(instance.age).to eq(123)
    end
  end

  context "when included from the method", pending: true do
    context "and the :method option is passed" do
      context "and the values are not nil" do
        let(:instance) do
          class_instance = Class.new do
            include Aspect::HasAttributes(method: { define: :atr, update: :mass_assign })
          end

          class_instance.new
        end

        it "should update the attributes on the instance" do
          expect(instance.class).to respond_to("atr")
          expect(instance.class).not_to respond_to("attribute")
          expect(instance).to respond_to("mass_assign")
          expect(instance).not_to respond_to("update_attributes")
        end
      end

      context "and the values are nil" do
        let(:instance) do
          class_instance = Class.new do
            include Aspect::HasAttributes(method: { define: nil, update: nil })
          end

          class_instance.new
        end

        it "should update the attributes on the instance" do
          expect(instance.class).not_to respond_to("atr")
          expect(instance.class).not_to respond_to("attribute")
          expect(instance).not_to respond_to("mass_assign")
          expect(instance).not_to respond_to("update_attributes")
        end
      end
    end
  end
end
