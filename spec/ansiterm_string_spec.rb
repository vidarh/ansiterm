require "spec_helper"

describe AnsiTerm::String do
  let(:empty) { AnsiTerm::String.new }
  let(:bold)  { AnsiTerm::String.new("\e[1mbold") }

  it "responds to #to_str and returns a ::String" do
    expect(empty.to_str.class).to be ::String
  end

  it "takes an optional string to #new/#initialize, and if that string has no ANSI escapes, #to_str will return that string unchange" do
    expect(AnsiTerm::String.new("foo").to_str).to eq "foo"
  end

  it "changing the String passed to AnsiTerm::String on creation does not change the AnsiTerm::String" do
    str  = "foo"
    ansi = AnsiTerm::String.new(str)
    str[1] = "x"
    expect(ansi.to_str).to eq("foo")
  end

  it "responds to #encoding with a valid encoding" do
    # (In practice we expect the default encoding)
    expect(empty.encoding).to eq("".encoding)
  end

  it "responds to #length" do
    expect(empty.length).to eq(0)
    expect(AnsiTerm::String.new("hello").length).to eq(5)
  end

  describe "passing an ANSI CSI sequence during creation" do
    it "excludes the sequence from the length" do
      expect(bold.length).to eq(4)
    end

    it "returns no escape sequence if the string was entirely set to 'normal'" do
      expect(AnsiTerm::String.new("\e[0mnormal").to_str).to eq("normal")
    end

    it "returns no escape sequence to turn the string back to normal at the end" do
      expect(bold.to_str).to eq("\e[1mbold")
    end

    it "returns only the specific disabling sequence if only a single attribute needs to change to reurn to 'normal'" do
      expect(AnsiTerm::String.new("\e[1mbold\e[0mnormal").to_str).to eq("\e[1mbold\e[22mnormal")
    end

    it "handles leading zeros in CSI sequences" do
      expect(AnsiTerm::String.new("\e[01mbold\e[000mnormal").to_str).to eq("\e[1mbold\e[22mnormal")
    end

    it "handle underline/disable underline" do
      expect(AnsiTerm::String.new("\e[4munderlined\e[24mnormal").to_str).to eq("\e[4munderlined\e[24mnormal")
    end

    it "returns only the final set of attributes applicable for a given span" do
      expect(AnsiTerm::String.new("\e[1m\e[0mnormal").to_str).to eq("normal")
      expect(AnsiTerm::String.new("\e[1mfoo\e[22mnormal").to_str).to eq("\e[1mfoo\e[22mnormal")
    end

    it "handles multiple color directives in sequence" do
      expect(AnsiTerm::String.new("\e[37m\e[40mfoo").to_str).to eq("\e[37;40mfoo")
    end

    it "#[] returns a substring counting visible characters, setting the attributes according to attributes enabled at that point in the string" do
      expect(AnsiTerm::String.new("foo\e[1mbar")[0].to_str).to eq("f")
      expect(AnsiTerm::String.new("foo\e[1mbar")[3..-1].to_str).to eq("\e[1mbar")
      expect(AnsiTerm::String.new("foo\e[1mbar")[2..-1].to_str).to eq("o\e[1mbar")
      expect(AnsiTerm::String.new("foo\e[1mbar")[-1].to_str).to eq("\e[1mr")
    end
  end

  describe "#set_attr" do
    it "replaces the attributes for a given position or range of positions with the passed attribute" do
      a = AnsiTerm::String.new("\e[32;44mfoobarbaz")
      AnsiTerm::Attr.new
      a.set_attr(3..5, AnsiTerm::Attr.new(bgcol: 46))
      expect(a.to_str).to eq("\e[32;44mfoo\e[46mbar\e[44mbaz")
    end
  end

  describe "#<<" do
    it "concatenates an AnsiTerm::String and object that responds to #to_str" do
      a = AnsiTerm::String.new("\e[32;44mfoo")
      b = "bar"
      c = AnsiTerm::String.new("\e[32;44mbaz")

      a << b
      a << c
      expect(a.to_str).to eq("\e[32;44mfoo\e[0mbar\e[32;44mbaz")
    end

    it "correctly maintains attributes" do
      a = AnsiTerm::String.new("\e[4mfoo\e[0m bar")
      expect(a.to_str).to eq("\e[4mfoo\e[24m bar")
      a << " "
      expect(a.to_str).to eq("\e[4mfoo\e[24m bar ")
    end

    it "splitting an AnsiTerm::String with #[] and splicing in a substring with different attributes should retain the original attributes on both sides of he spliced in segment" do
      a = AnsiTerm::String.new("\e[32;44mfoobar")
      b = AnsiTerm::String.new("\e[35;46;4mhello")

      a1 = a[0..2]
      a2 = a[3..-1]

      r = a1
      r << b
      r << a2

      expect(r.to_str).to eq("\e[32;44mfoo\e[35;46;4mhello\e[32;44;24mbar")
    end
  end
end
