# frozen_string_literal: true

require "test_helper"

class SubComponentsTest < ViewComponent::TestCase
  def test_renders_slots
    c = SubComponentComponent.new(class_names: "mt-4")
    render_inline(c) do |component|
      component.title do
        "This is my title!"
      end
      component.subtitle do
        "This is my subtitle!"
      end

      component.tab do
        "Tab A"
      end
      component.tab do
        "Tab B"
      end

      component.item do
        "Item A"
      end
      component.item(highlighted: true) do
        "Item B"
      end
      component.item do
        "Item C"
      end

      component.footer(class_names: "text-blue") do
        "This is the footer"
      end
    end

    assert_selector(".card.mt-4")

    assert_selector(".title", text: "This is my title!")

    assert_selector(".subtitle", text: "This is my subtitle!")

    assert_selector(".tab", text: "Tab A")
    assert_selector(".tab", text: "Tab B")

    assert_selector(".item", count: 3)
    assert_selector(".item.highlighted", count: 1)
    assert_selector(".item.normal", count: 2)

    assert_selector(".footer.text-blue")
  end

  def test_renders_slots_in_inherited_components
    render_inline(InheritedSubComponentComponent.new(class_names: "mt-4")) do |component|
      component.title do
        "This is my title!"
      end
      component.subtitle do
        "This is my subtitle!"
      end

      component.tab do
        "Tab A"
      end
      component.tab do
        "Tab B"
      end

      component.item do
        "Item A"
      end
      component.item(highlighted: true) do
        "Item B"
      end
      component.item do
        "Item C"
      end

      component.footer(class_names: "text-blue") do
        "This is the footer"
      end
    end

    assert_selector(".card.mt-4")

    assert_selector(".title", text: "This is my title!")

    assert_selector(".subtitle", text: "This is my subtitle!")

    assert_selector(".tab", text: "Tab A")
    assert_selector(".tab", text: "Tab B")

    assert_selector(".item", count: 3)
    assert_selector(".item.highlighted", count: 1)
    assert_selector(".item.normal", count: 2)

    assert_selector(".footer.text-blue", text: "This is the footer")
  end

  def test_renders_slots_with_empty_collections
    render_inline(SubComponentComponent.new) do |component|
      component.title do
        "This is my title!"
      end

      component.subtitle do
        "This is my subtitle!"
      end

      component.footer do
        "This is the footer"
      end
    end

    assert_text "No tabs provided"
    assert_text "No items provided"
  end

  def test_renders_slots_template_raise_with_unknown_content_areas
    assert_raises NoMethodError do
      render_inline(SubComponentComponent.new) do |component|
        component.foo { "Hello!" }
      end
    end
  end

  def test_sub_component_raise_with_duplicate_slot_name
    exception = assert_raises ArgumentError do
      SubComponentComponent.renders_one :title
    end

    assert_includes exception.message, "title slot declared multiple times"
  end

  def test_sub_component_with_positional_args
    render_inline(SubComponentWithPosArgComponent.new(class_names: "mt-4")) do |component|
      component.item("my item", class_names: "hello") { "My rad item" }
    end

    assert_selector(".item", text: "my item")
    assert_selector(".item-content", text: "My rad item")
  end

  def test_slot_with_component_delegate
    render_inline SubComponentDelegateComponent.new do |component|
      component.item do
        "Item A"
      end
      component.item(highlighted: true) do
        "Item B"
      end
      component.item do
        "Item C"
      end
    end

    assert_selector(".item", count: 3)
    assert_selector(".item.highlighted", count: 1)
    assert_selector(".item.normal", count: 2)
  end

  # In a previous implementation of slots,
  # the list of slots registered to a component
  # was accidentally assigned to all components!
  def test_slots_pollution
    new_component_class = Class.new(ViewComponent::Base)
    new_component_class.include(ViewComponent::Slotable)
    # this returned:
    # [SubComponentComponent::Subtitle, SubComponentComponent::Tab...]
    assert_empty new_component_class.slots
  end
end
