require 'minitest/autorun'
require 'uart'

class TestUart < MiniTest::Test
  def test_sanity
    assert "lol, I need to figure out a good way to make a fake serial port"
    assert "but I don't want to use mocks"
    assert "I think there is a way to do that without mocks"
  end
end
