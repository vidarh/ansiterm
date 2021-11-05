# coding: utf-8
module AnsiTerm

  class String
    def initialize(str=nil)
      if str
        parse(str)
      else
        @str = ""
        @attrs = []
      end
    end

    def to_plain_str
      @str.dup
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

    def to_s
      to_str
    end

    def encoding
      @str.encoding
    end

    def length
      @str.length
    end

    def index str, off = 0
      @str.index(str,off)
    end

    def set(str,attrs)
      @str, @attrs = str,Array(attrs)
    end

    def raw
      return @str, Array(@attrs)
    end

    def set_attr(range, attr)
      min   = [range.first - 1,0].max
      fattr = @attrs[min]
      attr  = fattr.merge(attr)
      r = Array(@attrs[range]).count # Inefficient, but saves dealing with negative offsets etc. "manually"
      last = nil
      @attrs[range] = @attrs[range].map do |a|
        n = a.merge(attr)
        last == n ? last : n
      end
      rm = range.last
      if a = @attrs[rm]
        @attrs[rm] = Attr.new(bgcol:40).merge(fattr).merge(a)
      end
    end

    def merge_attr_below(range, attr)
      min = [0,range.first - 1].max
      fattr = @attrs[min]
      r = Array(@attrs[range]).count # Inefficient, but saves dealing with negative offsets etc. "manually"
      last = nil
      @attrs[range] = @attrs[range].map do |a|
        if a.bgcol == 49
          a.merge(attr)
        else
          attr.merge(a)
        end
      end
      #fattr #@attrs[min+r].merge(fattr)
    end

    def[]= range, str
      s = @str
      a = @attrs
      parse(str)
      @str   = s[0..(range.min-1)].to_s + @str   + s[(range.max)..-1].to_s
      @attrs = a[0..(range.min-1)].to_a + @attrs + a[(range.max)..-1].to_a
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

    def char_at(index)
      @str[index]
    end
    
    def attr_at(index)
      @attrs[index]
    end

    def << str
      return self if str.nil?
      if !str.kind_of?(self.class)
        parse(self.to_str + "\e[0m" + str.to_str)
        return self
      end

      s,a = str.raw
      @str.concat(s)
      @attrs.concat(a)
      self
    end

    private

    def parse_color(par, params, a, attr_name)
      col = par
      if col == 38 || col == 48
        par = params.shift
        if par == "5"
          col = [col,5,params.shift].join(";")
        elsif par == "2"
          col = ([col,2] << params.slice!(0..2)).join(";")
#          ,params.shift,params.shift, params.shift].join(";")
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
          params = []
          i += 2
          par = ""
          while i < max && str[i].ord < 0x40
            if str[i] == ";"
              params << par
              par = ""
            else
              par << str[i]
            end
            i+=1
          end
          params << par if !par.empty?
          final = str[i]

          if final == "m"
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
                old = a
                a = a.clear_flag(Attr::UNDERLINE)
              when 29
                a = a.clear_flag(Attr::CROSSED_OUT)
              when 30..39, 90..98
                a = parse_color(par, params, a, :fgcol)
              when 40..49, 100..107
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

  def self.str(*args)
    AnsiTerm::String.new(*args)
  end
end
