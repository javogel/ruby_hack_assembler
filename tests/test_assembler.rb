require "./lib/assembler.rb"
require "test/unit"

class TestAssembler < Test::Unit::TestCase

  def test_sample
    assert_equal(4, 2+2)
  end

end
