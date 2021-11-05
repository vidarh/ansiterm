
module AnsiTerm

  # # Attr #
  #
  # Attr represents the attributes of a given character.
  # It is intended to follow the "Flyweight" GOF pattern
  # in that any object representing a given combination
  # of flags can be reused as the object itself is immutable.
  #
  # This allows you to decide on a case by case basis
  # whether to e.g. encode a string as spans with one Attr,
  # or characters with one Attr per character.
  #
  # Use `Attr#transition(other_attr)` to retrieve an ANSI
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

    def ==(other)
      return false if !other.kind_of?(self.class)
      return fgcol == other.fgcol &&
             bgcol == other.bgcol &&
             flags == other.flags
    end

    def merge(attrs)
      return self if self == attrs
      if attrs.kind_of?(self.class)
        old = attrs
        attrs = {}
        attrs[:bgcol] = old.bgcol if old.bgcol
        attrs[:fgcol] = old.fgcol if old.fgcol
        attrs[:flags] = old.flags if old.flags
      end
      self.class.new({bgcol: @bgcol, fgcol: @fgcol, flags: @flags}.merge(attrs))
    end

    def add_flag(flags); merge({flags: @flags | flags}); end
    def clear_flag(flags); merge({flags: @flags & ~flags}); end

    def reset;        self.class.new; end
    def normal;       clear_flag(BOLD); end
    def bold;         add_flag(BOLD); end
    def underline;    add_flag(UNDERLINE); end
    def crossed_out;  add_flag(CROSSED_OUT); end

    def bold?;        (@flags & BOLD) != 0; end
    def underline?;   (@flags & UNDERLINE) != 0; end
    def crossed_out?; (@flags & CROSSED_OUT) != 0; end

    def normal?
      @flags == NORMAL &&
        @fgcol.nil? &&
        @bgcol.nil?
    end

    def transition_to(other)
      t = []
      t << [other.fgcol] if other.fgcol != self.fgcol && other.fgcol
      t << [other.bgcol] if other.bgcol != self.fgcol && other.bgcol

      if other.bold? != self.bold?
        t << [other.bold? ? 1 : 22]
      end

      if other.underline? != self.underline?
        t << [other.underline? ? 4 : 24]
      end

      if other.crossed_out? != self.crossed_out?
        t << [other.crossed_out? ? 9 : 29]
      end

      return "\e[0m" if other.normal? && !self.normal? && t.length != 1

      if t.empty?
        ""
      else
        "\e[#{t.join(";")}m"
      end
    end
  end

  def self.attr(*args)
    Attr.new(*args)
  end
end
