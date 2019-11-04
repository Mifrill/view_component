# frozen_string_literal: true

require "test_helper"

class IntegrationTest < ActionDispatch::IntegrationTest
  test "rendering component in a view" do
    get "/"
    assert_response :success
    assert_equal trim_result(response.body), "<span><div>Foobar</div></span>"
  end

  test "rendering component with content" do
    get "/content"
    assert_response :success
    assert_select "div.State--green"
    assert_select "div[title='Status: Open']"
    assert_includes response.body, "Open"
  end

  test "rendering component in a view with component: syntax" do
    get "/component"
    assert_response :success
    assert_equal trim_result(response.body), "<span><div>Foobar</div></span>"
  end

  test "rendering component with a partial" do
    get "/partial"
    assert_response :success
    assert_equal trim_result(response.body), "partial:<div>hello,partialworld!</div>component:<div>hello,partialworld!</div><div>hello,partialworld!</div>"
  end

  test "rendering component with deprecated syntax" do
    get "/deprecated"
    assert_response :success
    assert_equal trim_result(response.body), "<span><div>Foobar</div></span>"
  end

  test "rendering component without variant" do
    get "/variants"
    assert_response :success
    assert_equal "Default", trim_result(response.body)
  end

  test "rendering component with tablet variant" do
    get "/variants?variant=tablet"
    assert_response :success
    assert_equal "Tablet", trim_result(response.body)
  end

  test "rendering component several times with different variants" do
    get "/variants?variant=tablet"
    assert_response :success
    assert_equal "Tablet", trim_result(response.body)

    get "/variants?variant=phone"
    assert_response :success
    assert_equal "Phone", trim_result(response.body)

    get "/variants"
    assert_response :success
    assert_equal "Default", trim_result(response.body)

    get "/variants?variant=tablet"
    assert_response :success
    assert_equal "Tablet", trim_result(response.body)

    get "/variants?variant=phone"
    assert_response :success
    assert_equal "Phone", trim_result(response.body)
  end

  test "rendering component with caching" do
    Rails.cache.clear
    ActionController::Base.perform_caching = true

    get "/cached"
    assert_response :success
    assert_equal "Cached", trim_result(response.body)

    get "/cached"
    assert_response :success
    assert_equal "Cached", trim_result(response.body)

    ActionController::Base.perform_caching = false
    Rails.cache.clear
  end
end
