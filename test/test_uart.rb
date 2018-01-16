require 'minitest/autorun'
require 'uart'

class TestUart < MiniTest::Test

  def setup
    File.delete('socat.log') if File.file?('socat.log')

    raise 'socat not found' unless (`socat -h` && $? == 0)

    Thread.new do
      system('socat -lf socat.log -d -d pty,raw,echo=0 pty,raw,echo=0')
    end

    @ptys = nil
    @ports = []

    loop do
      if File.file? 'socat.log'
        @file = File.open('socat.log', "r")
        @fileread = @file.read

        unless @fileread.count("\n") < 3
          @ptys = @fileread.scan(/PTY is (.*)/)
          break
        end
      end
    end

    @ports = [@ptys[1][0], @ptys[0][0]]

    @uart_write = UART.open @ports[0]
    @uart_read  = UART.open @ports[1]
  end

  def test_read_write
    @uart_write.write 'Hello World!'
    # small delay so it can write to the other port.
    sleep 0.1
    check = @uart_read.read(12)
    assert check == 'Hello World!'
  end

  def test_sanity
    assert "lol, I need to figure out a good way to make a fake serial port"
    assert "but I don't want to use mocks"
    assert "I think there is a way to do that without mocks"
  end
end
