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

## REQUIREMENTS:

* ruby-termios

## INSTALL:

* `gem install uart`

## LICENSE:

(The MIT License)

Copyright (c) 2018 Aaron Patterson

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
