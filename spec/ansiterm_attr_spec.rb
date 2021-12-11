require "spec_helper"

describe AnsiTerm::Attr do
  let(:attr) { AnsiTerm::Attr.new }

  it "responds to fgcol (foreground color)" do
    expect(attr.respond_to?(:fgcol)).to be true
  end

  it "responds to bgcol (background color)" do
    expect(attr.respond_to?(:bgcol)).to be true
  end

  it "responds to #flags" do
    expect(attr.respond_to?(:flags)).to be true
  end

  it "is immutable / frozen from creation" do
    expect(attr.frozen?).to be true
  end

  it "can be created with fgcol and bgcol as named attributes" do
    expect(AnsiTerm::Attr.new(fgcol: 123, bgcol: 0)).to_not be nil
  end

  it "can be created with flags as a named attribute" do
    expect(AnsiTerm::Attr.new(flags: nil)).to_not be nil
  end

  it "can be created with Attr::UNDERLINE flag" do
    a = AnsiTerm::Attr.new(flags: AnsiTerm::Attr::UNDERLINE)
    expect(a.flags).to be AnsiTerm::Attr::UNDERLINE
  end

  it "can have the flags cleared with #clear_flag" do
    a = AnsiTerm::Attr.new(flags: AnsiTerm::Attr::UNDERLINE)
    a = a.clear_flag(AnsiTerm::Attr::UNDERLINE)
    expect(a.flags).to be(AnsiTerm::Attr::NORMAL)
  end

  it "can be created with Attr::BOLD flag" do
    a = AnsiTerm::Attr.new(flags: AnsiTerm::Attr::BOLD)
    expect(a.flags).to be AnsiTerm::Attr::BOLD
  end

  it "can be created with Attr::ITALICS flag" do
    a = AnsiTerm::Attr.new(flags: AnsiTerm::Attr::ITALICS)
    expect(a.flags).to be AnsiTerm::Attr::ITALICS
  end

  it "can be created with Attr::CROSSED_OUT flag" do
    a = AnsiTerm::Attr.new(flags: AnsiTerm::Attr::CROSSED_OUT)
    expect(a.flags).to be AnsiTerm::Attr::CROSSED_OUT
  end

  it "creates a new object with the BOLD flag set when you call #bold" do
    bold = attr.bold
    expect(attr).to_not be eq(bold)
    expect(bold.flags).to eq AnsiTerm::Attr::BOLD
    expect(attr.flags).to eq nil
  end

  it "creates a new object with the BOLD flag *cleared* when you call #normal" do
    f = attr.bold.underline
    expect(attr).to_not be eq(f)
    expect(f.flags).to eq AnsiTerm::Attr::BOLD | AnsiTerm::Attr::UNDERLINE
    expect(f.normal.flags).to eq AnsiTerm::Attr::UNDERLINE
  end

  it "returns a boolean from #bold? reflecting whether the BOLD flag is set" do
    expect(attr.bold?).to eq false
    expect(attr.bold.bold?).to eq true
  end

  it "returns a boolean from #underline? reflecting whether the UNDERLINE flag is set" do
    expect(attr.underline?).to eq false
    expect(attr.underline.underline?).to eq true
  end

  describe "#transition_to" do
    it "returns an empty string when there is no change" do
      expect(attr.transition_to(attr)).to eq ""
    end

    it "returns \\e[1m if enabling bold" do
      expect(attr.transition_to(attr.bold)).to eq "\e[1m"
    end

    it "returns \\e[22m if disabling bold" do
      expect(attr.bold.transition_to(attr)).to eq "\e[22m"
    end

    it "returns \\e[32m; if fgcol changes to 32" do
      expect(attr.transition_to(attr.merge(fgcol: 32))).to eq "\e[32m"
    end

    it "returns \\e[44m; if bgcol changes to 44" do
      expect(attr.transition_to(attr.merge(bgcol: 44))).to eq "\e[44m"
    end

    it "returns \\e[4m; if we enable underline" do
      expect(attr.transition_to(attr.underline)).to eq "\e[4m"
    end

    it "returns \\e[24m; if we disable underline" do
      expect(attr.underline.transition_to(attr)).to eq "\e[24m"
    end

    it "returns \\e[9m; if we enable crossed_out" do
      expect(attr.transition_to(attr.crossed_out)).to eq "\e[9m"
    end

    it "returns \\e[29m; if we disable crossed_out" do
      expect(attr.crossed_out.transition_to(attr)).to eq "\e[29m"
    end

    it "returns \\e[0m; if we transition to 'normal' (no flags or colors) and more than 1 other flag needs to be cleared" do
      expect(attr.bold.crossed_out.transition_to(attr)).to eq "\e[0m"
    end
  end

  describe "#merge" do
    it "overwrites the background when a different background is passed" do
      bg1 = AnsiTerm::Attr.new(bgcol: 44)
      bg2 = AnsiTerm::Attr.new(bgcol: 45)
      expect(bg1.merge(bg2).bgcol).to eq bg2.bgcol
    end

    it "does not overwrite the background when the second attribute does not have a background set" do
      bg1 = AnsiTerm::Attr.new(bgcol: 44)
      bg2 = AnsiTerm::Attr.new(bgcol: nil)
      expect(bg1.merge(bg2).bgcol).to eq bg1.bgcol
    end

  end
end
