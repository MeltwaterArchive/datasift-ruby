require '../examples/auth'
require 'test/unit'
class CoreApiTest < Test::Unit::TestCase

  def setup
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @csdl     = 'interaction.content contains "test"'
  end


  def teardown
    # Do nothing
  end

  def test_csdl_validation
    assert_true @datasift.valid?(@csdl)
    assert_raise_kind_of BadRequestError do
      datasift.valid?(@csdl+' random string')
    end
  end

  def test_compile
    stream = @datasift.compile(@csdl)
    hash_asserts(stream)
  end

  def test_dpus
    stream = @datasift.compile(@csdl)
    hash_asserts(stream)

    dpus = @datasift.dpu stream[:data][:hash]
    assert_not_nil dpus[:data][:dpu]
    assert_not_nil dpus[:data][:detail]
  end

  def hash_asserts(stream)
    assert_not_nil stream[:data]
    assert_not_nil stream[:data][:hash]
  end

end