require "spec_helper"

describe Aspect::HasAttributes do
  describe ".attribute" do
    context "when no options are given" do
      context "and no block is given" do
        let(:instance) do
          instance_class = Class.new do
            include Aspect::HasAttributes

            attribute(:name)
          end

          instance_class.new
        end

        it "should define a getter and a setter which uses the argument given to set the instance variable" do
          expect(instance.name).to eq(nil)
          instance.name = "foo"
          expect(instance.name).to eq("foo")
        end
      end

      context "and a block is given" do
        let(:instance) do
          instance_class = Class.new do
            include Aspect::HasAttributes

            attribute(:name) { |value| value.to_s }
          end

          instance_class.new
        end

        it "should define a getter and a setter which uses the return value of the block to set the instance variable" do
          expect(instance.name).to eq(nil)
          instance.name = 123
          expect(instance.name).to eq("123")
        end
      end
    end

    context "when the :getter option is given" do
      context "and it's truthy" do
        let(:instance) do
          instance_class = Class.new do
            include Aspect::HasAttributes

            attribute(:name, getter: true)
          end

          instance_class.new
        end

        it "should define a query getter which uses the argument given to set the instance variable" do
          expect(instance.name).to eq(nil)
        end
      end

      context "and it's falsey" do
        let(:instance) do
          instance_class = Class.new do
            include Aspect::HasAttributes

            attribute(:name, getter: false)
          end

          instance_class.new
        end

        it "should not define a getter" do
          expect(instance.respond_to?(:name)).to eq(false)
        end
      end
    end

    context "when the :setter option is given" do
      context "and no block is given" do
        context "and it's truthy" do
          let(:instance) do
            instance_class = Class.new do
              include Aspect::HasAttributes

              attribute(:name, setter: true)
            end

            instance_class.new
          end

          it "should define a query setter which uses the argument given to set the instance variable" do
            expect(instance.name).to eq(nil)
            instance.name = "foobar"
            expect(instance.name).to eq("foobar")
          end
        end

        context "and it's falsey" do
          let(:instance) do
            instance_class = Class.new do
              include Aspect::HasAttributes

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
            instance_class = Class.new do
              include Aspect::HasAttributes

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
            instance_class = Class.new do
              include Aspect::HasAttributes

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

    context "when the :query option is given" do
      context "and no block is given" do
        context "and it's truthy" do
          let(:instance) do
            instance_class = Class.new do
              include Aspect::HasAttributes

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
            instance_class = Class.new do
              include Aspect::HasAttributes

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
            instance_class = Class.new do
              include Aspect::HasAttributes

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
            instance_class = Class.new do
              include Aspect::HasAttributes

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
      class_instance = Class.new do
        include Aspect::HasAttributes

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
end
