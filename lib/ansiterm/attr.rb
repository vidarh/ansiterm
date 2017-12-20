
module AnsiTerm

  # Attr represents the attributes of a given character.
  # It is intended to follow the "Flyweight" GOF pattern
  # in that any object representing a given combination
  # of flags can be reused as the object itself is immutable.
  #
  # This allows you to decide on a case by case basis
  # whether to e.g. encode a string as spans with one Attr,
  # or characters with one Attr per character.
  #
  # Use Attr#transition(other_attr) to retrieve an ANSI
  # sequence that represents the changes from self to
  # other_attr.
  #
  class Attr
    NORMAL      = 0
    BOLD        = 1
    ITALICS     = 2
    UNDERLINE   = 4
    CROSSED_OUT = 8
    
    attr_reader :fgcol, :bgcol, :flags

    def initialize(fgcol: nil, bgcol: nil, flags: 0)
      @fgcol = fgcol
      @bgcol = bgcol
      @flags = flags || 0
      freeze
    end

    def merge(attrs)
      self.class.new({bgcol: @bgcol, fgcol: @fgcol, flags: @flags}.merge(attrs))
    end
    
    def add_flag(flags); merge({flags: @flags | flags}); end
      
    def bold;         add_flag(BOLD); end
    def underline;    add_flag(UNDERLINE); end
    def crossed_out;  add_flag(CROSSED_OUT); end

    def bold?;        (@flags & BOLD) != 0; end
    def underline?;   (@flags & UNDERLINE) != 0; end
    def crossed_out?; (@flags & CROSSED_OUT) != 0; end

    def transition_to(other)
      t = []
      t << [other.fgcol] if other.fgcol != self.fgcol
      t << [other.bgcol] if other.bgcol != self.bgcol
      t << [1] if other.bold? && !self.bold?
      
      if other.underline? != self.underline?
        t << [other.underline? ? 4 : 24]
      end
      
      if other.crossed_out? != self.crossed_out?
        t << [other.crossed_out? ? 9 : 29]
      end
      
      if t.empty?
        ""
      else
        "\e[#{t.join(";")}m"
      end
    end
  end

end
