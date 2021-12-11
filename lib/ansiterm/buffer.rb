
module AnsiTerm

  # # AnsiTerm::Buffer #
  #
  # A terminal buffer that will eventually handle ANSI style strings
  # fully. For now it will handle the sequences AnsiTerm::String handles
  # but e.g. cursor movement etc. needs to be explicitly handled.
  #
  # Extracted out of https://github.com/vidarh/re
  #
  # FIXME: Provide method of setting default background color
  #
  class Buffer
    attr_reader :w,:h, :lines

    def initialize(w=80, h=25)
      @lines = []
      @x = 0
      @y = 0
      @w = w
      @h = h
      @cache = []
    end

    def cls
      @lines = (1..@h).map { nil } #AnsiTerm::String.new } #AnsiTerm::String.new("\e[37;40;0m"+(" "*@w)) }
    end

    def reset
      cls
      @cache=[]
    end

    def move_cursor(x,y)
      @x = x
      @y = y
      @x = @w-1 if @x >= @w
      @y = @y-1 if @y >= @h
    end

    def resize(w,h)
      if @w != w || @h != h
        @w, @h = w,h
        @cache = []
      end
    end

    def scroll
      while @y >= @h
        @lines.shift
        @lines << nil #AnsiTerm::String.new #"" #AnsiTerm::String.new("\e[37;40;0m"+(" "*@w))
        @y -= 1
      end
      true
    end

    def print *args
      args.each do |str|
        @lines[@y] ||= AnsiTerm::String.new("\e[0m")
        @dirty << @y
        l = @lines[@y]

        if l.length < @x
          l << (" "*(@x - l.length))
        end
        l[@x..@x+str.length] = str
        #      l[@x] << str
        #      if @x + s.length > @w
        #        l[@x .. @w-1] = s[0 .. @w - @x]
        #        @x = 0
        #        @y += 1
        #        scroll if @y >= @h
        #      end
      end
    end

    def to_s
      out = ""
      cachehit=0
      cachemiss=0
      @lines.each_with_index do |line,y|
        line ||= ""
        line = line[0..(@w-1)]
        l = line.length
        #if l > @w
        #  $editor&.log("WARNING: #{l} > @w #{@w}")
        #end
        s = line.to_str
        if @cache[y] != s
          out << ANSI.cup(y,0) << s << ANSI.sgr(:reset) << ANSI.el #<< X\n"
          cachemiss += s.length
          old = @cache[y]
          @cache[y] = s
          #$editor.pry([y,old, s])
        else
          cachehit += @cache[y].length
        end
        # FIXME: This is only worthwhile if a background colour is set
        #if l < @w
        #  out << ANSI.csi("m",0,38,48,2,48,48,64) << "-"*(@w-l)
        #end
      end
      @dirty = Set[]
      out
    end
  end
end
