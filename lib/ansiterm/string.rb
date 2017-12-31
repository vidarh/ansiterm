
module AnsiTerm

  class String
    def initialize(str="")
      parse(str)
    end
    
    def to_str
      out = ""
      a = Attr.new
      @str.length.times.each do |i|
        if a != @attrs[i]
          old = a
          a = @attrs[i]||Attr.new
          out << old.transition_to(a)
        end
        out << @str[i]
      end
      out
    end

    def encoding
      @str.encoding
    end

    def length
      @str.length
    end

    def set(str,attrs)
      @str, @attrs = str,Array(attrs)
    end

    def[] i
      str = @str[i]
      if str
        a = self.class.new
        a.set(str,@attrs[i])
        a
      else
        nil
      end
    end

    
    private

    def parse_color(par, params, a, attr_name)
      col = par
      if col == 38 || col == 48
        par = params.shift
        if par == "5"
          col = [col,5,params.shift].join(";")
        elsif par == "2"
          col = [col,5,params.shift,params.shift, params.shift].join(";")
        end
      end
      a.merge(attr_name => col)
    end
    
    def parse(str)
      @str   = ""
      @attrs = []
      a = AnsiTerm::Attr.new

      max = str.length
      i   = 0
      
      while i < max
        c = str[i]
        if c == "\e" && str[i+1] == "[" # CSI
          params = ""
          i += 2
          while i < max && str[i].ord < 0x40
            params << str[i]
            i+=1
          end
          final = str[i]

          if final == "m"
            params = params.split(";")
            while par = params.shift
              par = par.to_i
              case par
              when 0
                a = a.reset
              when 1
                a = a.bold
              when 4
                a = a.underline
              when 9
                a = a.crossed_out
              when 22
                a = a.normal
              when 24
                a = a.clear_flag(Attr::UNDERLINE)
              when 29
                a = a.clear_flag(Attr::CROSSED_OUT)
              when 30..39
                a = parse_color(par, params, a, :fgcol)
              when 40..49
                a = parse_color(par, params, a, :bgcol)
              else
                @str << "[unknown escape: #{par}]"
              end
            end
          end
        else
          @str   << c
          @attrs << a
        end
        i += 1
      end
      self
    end
  end
end
