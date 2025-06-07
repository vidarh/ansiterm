



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
      @cache = Array.new { AnsiTerm::String.new }
    end

    def cls
      @lines = (1..@h).map { nil }
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

    def print *args
      args.each do |str|
        @lines[@y] ||= AnsiTerm::String.new
        l = @lines[@y]

        if l.length < @x
          l << (" "*(@x - l.length))
        end

        r=@x..@x+str.length-1
        #p [r, str]
        l[r] = str
        @x += str.length
        # FIXME: Handle wrap.
      end
    end

    # This scrolls the *buffer* up
    # If you want it to also scroll the *cache*
    # pass `scroll_cache: true`. This will presume
    # that you've scrolled the *terminal* yourself.
    def scroll_up(num=1, scroll_cache: false)
      @lines.slice!(0)
      @lines << AnsiTerm::String.new
      if scroll_cache
        @cache.slice!(0)
      end
    end

    def to_s
      out = ""
      cachehit=0
      cachemiss=0
      @lines.each_with_index do |line,y|
        line ||= ""
        line = line[0..@w]
        l = line.length
        s = line.to_str
        if @cache[y] != s
          # Move to start of line; output line; clear to end
          #if l > 0
          #s.lstrip!
          #x = l - s.length
          out << "\e[#{y+1};1H"
          #if x > 1
          #  out << "\e[1K"
          #end
          #FIXME: We can only do this if:
          #1. we know no background color has been set
          #2. OR we add support for specifying it.
          #out << s.rstrip
          out << s
          if l < @w
              # FIXME: Allow setting background colour
              out << "\e[0m\e[0K"
            #end
          end
          cachemiss += s.length
          old = @cache[y]
          @cache[y] = s
        else
          cachehit += @cache[y].length
        end
      end
      out
    end
  end
end
