
$: << File.dirname(__FILE__)+"/../lib"

require 'ansiterm'
require 'io/console'

h,w = IO.console.winsize

t = AnsiTerm::Buffer.new(w,h-1)

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
t.print ("Hello world. UL/UR/LL/LR should fit the corners but one line above the bottom.")
print t.to_s
gets
t.scroll_up
t.move_cursor(0,0)
t.print("ul")
t.move_cursor(w-2,0)
t.print("ur")
t.move_cursor(w-2,h-2)
t.print("lr")
t.move_cursor(0,h-2)
t.print("ll")

t.move_cursor(1,2)
t.print ("We've scrolled one line up. This should display right below the Hello World.")
t.move_cursor(1,3)
t.print ("Old LL/LR should be visible one line up; new, lower case ones replacing them")
print t.to_s
gets
