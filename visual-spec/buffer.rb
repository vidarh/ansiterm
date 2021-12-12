
$: << File.dirname(__FILE__)+"/../lib"

require 'ansiterm'
require 'io/console'

h,w = IO.console.winsize

t = AnsiTerm::Buffer.new(w,h)

t.cls
t.move_cursor(1,1)
t.print([h,w].inspect)
t.move_cursor(0,0)
t.print("UL")
t.move_cursor(w-2,0)
t.print("UR")
t.move_cursor(w-2,h-2)
t.print("LR")
t.move_cursor(0,h-2)
t.print("LL")
t.move_cursor(1,2)
t.print ("Hello world")
print t.to_s
gets
