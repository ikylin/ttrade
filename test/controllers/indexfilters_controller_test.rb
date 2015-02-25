require 'test_helper'

class IndexfiltersControllerTest < ActionController::TestCase
  setup do
    @indexfilter = indexfilters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:indexfilters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create indexfilter" do
    assert_difference('Indexfilter.count') do
      post :create, indexfilter: { losscount: @indexfilter.losscount, marketdatecount: @indexfilter.marketdatecount, name: @indexfilter.name, platform: @indexfilter.platform, samplecount: @indexfilter.samplecount, script: @indexfilter.script, wincount: @indexfilter.wincount }
    end

    assert_redirected_to indexfilter_path(assigns(:indexfilter))
  end

  test "should show indexfilter" do
    get :show, id: @indexfilter
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @indexfilter
    assert_response :success
  end

  test "should update indexfilter" do
    patch :update, id: @indexfilter, indexfilter: { losscount: @indexfilter.losscount, marketdatecount: @indexfilter.marketdatecount, name: @indexfilter.name, platform: @indexfilter.platform, samplecount: @indexfilter.samplecount, script: @indexfilter.script, wincount: @indexfilter.wincount }
    assert_redirected_to indexfilter_path(assigns(:indexfilter))
  end

  test "should destroy indexfilter" do
    assert_difference('Indexfilter.count', -1) do
      delete :destroy, id: @indexfilter
    end

    assert_redirected_to indexfilters_path
  end
end
