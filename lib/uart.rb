require 'termios'
require 'fcntl'

module UART
  VERSION = '1.0.0'

  ##
  # Open a UART as a file.
  #
  # For example, we have a serial connection on `/dev/tty.usbserial-00000000'.
  # It's speed is 9600, 8 data bits, 1 stop bit, and no parity:
  #
  #   serial = UART.open '/dev/tty.usbserial-00000000', 9600, '8N1'
  #   serial.write 'whatever'
  #
  # A speed of 9600, 8 data bits, no parity, and 1 stop bit is default, so
  # we can reduce the code to this:
  #
  #   serial = UART.open '/dev/tty.usbserial-00000000'
  #   serial.write 'whatever'
  #
  # Finally, we can give a block and the file will be automatically closed for
  # us like this:
  #
  #   UART.open '/dev/tty.usbserial-00000000' do |serial|
  #     serial.write 'whatever'
  #   end
  def open filename, speed = 9600, mode = '8N1'
    f = File.open filename, File::RDWR|Fcntl::O_NOCTTY|Fcntl::O_NDELAY
    f.binmode
    f.sync = true

    # enable blocking reads, otherwise read timeout won't work
    f.fcntl Fcntl::F_SETFL, f.fcntl(Fcntl::F_GETFL, 0) & ~Fcntl::O_NONBLOCK

    t = Termios.tcgetattr f
    t.iflag = 0
    t.oflag = 0
    t.lflag = 0

    if mode =~ /^(\d)(\w)(\d)$/
      t = data_bits    t, $1.to_i
      t = stop_bits    t, $3.to_i
      t = parity       t, { 'N' => :none, 'E' => :even, 'O' => :odd }[$2]
      t = speed        t, speed
      t = read_timeout t, 5
      t = reading      t
    else
      raise ArgumentError, "Invalid format for mode"
    end

    Termios.tcsetattr f, Termios::TCSANOW, t
    Termios.tcflush f, Termios::TCIOFLUSH

    if block_given?
      begin
        yield f
      ensure
        f.close
      end
    else
      f
    end
  end
  module_function :open

  def data_bits t, val
    t.cflag &= ~Termios::CSIZE               # clear previous values
    t.cflag |= Termios.const_get("CS#{val}") # Set the data bits
    t
  end
  module_function :data_bits

  def stop_bits t, val
    case val
    when 1 then t.cflag &= ~Termios::CSTOPB
    when 2 then t.cflag |= Termios::CSTOPB
    else
      raise
    end
    t
  end
  module_function :stop_bits

  def parity t, val
    case val
    when :none
      t.cflag &= ~Termios::PARENB
    when :even
      t.cflag |= Termios::PARENB  # Enable parity
      t.cflag &= ~Termios::PARODD # Make it not odd
    when :odd
      t.cflag |= Termios::PARENB  # Enable parity
      t.cflag |= Termios::PARODD  # Make it odd
    else
      raise
    end
    t
  end
  module_function :parity

  def speed t, speed
    t.ispeed = Termios.const_get("B#{speed}")
    t.ospeed = Termios.const_get("B#{speed}")
    t
  end
  module_function :speed

  def read_timeout t, val
    t.cc[Termios::VTIME] = val
    t.cc[Termios::VMIN] = 0
    t
  end
  module_function :read_timeout

  def reading t
    t.cflag |= Termios::CLOCAL | Termios::CREAD
    t
  end
  module_function :reading
end
