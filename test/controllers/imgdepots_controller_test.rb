require 'test_helper'

class ImgdepotsControllerTest < ActionController::TestCase
  setup do
    @imgdepot = imgdepots(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:imgdepots)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create imgdepot" do
    assert_difference('Imgdepot.count') do
      post :create, imgdepot: { summary: @imgdepot.summary, titile: @imgdepot.titile }
    end

    assert_redirected_to imgdepot_path(assigns(:imgdepot))
  end

  test "should show imgdepot" do
    get :show, id: @imgdepot
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @imgdepot
    assert_response :success
  end

  test "should update imgdepot" do
    patch :update, id: @imgdepot, imgdepot: { summary: @imgdepot.summary, titile: @imgdepot.titile }
    assert_redirected_to imgdepot_path(assigns(:imgdepot))
  end

  test "should destroy imgdepot" do
    assert_difference('Imgdepot.count', -1) do
      delete :destroy, id: @imgdepot
    end

    assert_redirected_to imgdepots_path
  end
end
