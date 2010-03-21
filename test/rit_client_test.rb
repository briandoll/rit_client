require File.dirname(__FILE__) + '/test_helper'

class RitClientTest < Test::Unit::TestCase
  
  context "The Rit::Plate class" do
    should "have a default timeout of 5 seconds" do
      assert_equal(5, Rit::Plate.timeout)
    end

    should "have a different timeout when set" do
      Rit::Plate.timeout = 3
      assert_equal(3, Rit::Plate.timeout)
    end

    should "return a proper rit publish path with an instance name" do
      path = Rit::Plate.published_plate_path('a', 'b', 'c')
      assert_equal('/published/a/b/c', path)
    end

    should "return a proper rit publish path without an instance name" do
      path = Rit::Plate.published_plate_path('a', nil, 'c')
      assert_equal('/published/a/c', path)
    end
  end

  context "Rit::Plate#handle_response" do
    setup do
      @response = mock
    end

    context "when sent a 200 response" do
      setup { @response.stubs(:code).returns('200') }
      should "return response" do
        assert_equal(@response, Rit::Plate.handle_response(@response))
      end
    end

    context "when sent a 404 response" do
      setup { @response.stubs(:code).returns('404') }
      should "raise NotFoundError" do
        assert_raise(Rit::NotFoundError) { Rit::Plate.handle_response(@response) }
      end
    end

    context "when sent a 500 response" do
      setup { @response.stubs(:code).returns('500') }
      should "raise NotFoundError" do
        assert_raise(Rit::ConnectionError) { Rit::Plate.handle_response(@response) }
      end
    end
  end
end