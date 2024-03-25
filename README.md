# UART

* https://github.com/tenderlove/uart

## DESCRIPTION:

UART is a simple wrapper around the ruby-termios gem that gives you an easy
interface for setting up a UART or serial connection.  This gem is written in
pure Ruby.  This gem relies on ruby-termios to provide bindings to the termios
system call, but uses those bindings to set up a serial connection in pure Ruby.

## FEATURES/PROBLEMS:

* No C code
* No FFI code
* Seems to work

## SYNOPSIS:

Here is an example of writing to an LCD screen over UART.  The speed is 9600,
8 data bits, no parity, and one stop bit:

```ruby
require 'uart'

UART.open '/dev/tty.usbserial-00000000' do |serial|
  str = 'Hello World!'
  serial.write [0x8A, 0xA8, 0x00, 0x00, str.bytesize].pack 'C5'
  serial.write str.b
  p serial.read(4).unpack('C4').map { |x| x.to_s(16) }
end
```

MHZ-19B CO2 sensor for Raspberry Pi
* http://www.winsen-sensor.com/d/files/infrared-gas-sensor/mh-z19b-co2-ver1_0.pdf
```ruby
require 'uart'

a = UART.open('/dev/ttyAMA0') { |s| s.write("\xFF\x01\x86\x00\x00\x00\x00\x00\x79"); s.read(9).unpack('C9')}
{ temp: a[4] - 40, co2: a[2] * 256 + a[3] } if 256 - a[1..7].reduce(&:+)%256 == a[8]
```

Plantower Particle Sensor
* https://cdn-shop.adafruit.com/product-files/3686/plantower-pms5003-manual_v2-3.pdf
```ruby
require 'uart'
require 'io/wait'

class Sample < Struct.new(:time,
                          :pm1_0_standard, :pm2_5_standard, :pm10_standard,
                          :pm1_0_env,      :pm2_5_env,
                          :concentration_unit,
                          :particle_03um,   :particle_05um,   :particle_10um,
                          :particle_25um,   :particle_50um,   :particle_100um)
end

uart = UART.open ARGV[0], 9600, '8N1'

p Sample.members # header

loop do
  uart.wait_readable
  start1, start2 = uart.read(2).bytes

  # According to the data sheet, packets always start with 0x42 and 0x4d
  unless start1 == 0x42 && start2 == 0x4d
    # skip a sample
    uart.read
    next
  end

  length = uart.read(2).unpack('n').first
  data = uart.read(length)
  crc  = 0x42 + 0x4d + 28 + data.bytes.first(26).inject(:+)
  data = data.unpack('n14')

  next unless crc == data.last # crc failure

  p Sample.new(Time.now.utc, *data.first(12)).to_a
end
```

[Flipper Zero client](https://gist.github.com/knowtheory/1fd9e05a48c182177c7ad73e8bfaa4cf) (thanks to Ted Han!!)

```ruby
require 'uart'

# find your flipper zero device handle: https://docs.flipper.net/development/cli#rnDLl
fname = ARGV.shift # provide the path to your flipper zero
raise "Please specify a device to open" if fname.nil?
raise "Couldn't find #{fname}" unless File.exist?(fname)

# open the flipper and specify the correct baud
UART.open fname, 115200 do |flipper|
    # read & print the Flipper Zero terminal art
    puts flipper.read

    # input command, or "help" if no command is supplied
    message = ARGV.join(" ") || "help"
    flipper.write "#{message}\r\n" # flipper cli uses \r\n to terminate lines.
    # read & print message output
    puts flipper.read
end
```

## REQUIREMENTS:

* ruby-termios

## INSTALL:

* `gem install uart`

## LICENSE:

(The MIT License)

Copyright (c) Aaron Patterson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
