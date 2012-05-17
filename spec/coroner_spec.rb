require 'coroner'

describe Coroner, 'matching' do
  it 'should make sections' do
    c = Coroner.new
    c.make_sections("foo\n\nbar\n\nbaz").should eq(%w{foo bar baz})
  end
  it 'matches version in a section' do
    c = Coroner.new
    sections = c.make_sections "the version 0.1\n\nanother section"
    c.match_one(sections, /([\d.]+)/).should eq('0.1')
  end
  it 'matches nothing in a section' do
    c = Coroner.new
    sections = c.make_sections "the version twelve\n\nanother section"
    c.match_one(sections, /([\d.]+)/).should be_false
  end
  it 'matches many things in a section' do
    c = Coroner.new
    sections = c.make_sections "HP  -1/15   AC   1\n\nMP   6/6   EV 17"
    c.match_many(sections, {
      :hp => /\bHP\s+(\S+)/,
      :ev => /\bEV\s+(\S+)/
    }).should eq({:hp => '-1/15', :ev => '17'})
  end
  it 'finds a version' do
    c = Coroner.new
    sections = c.make_sections " Dungeon Crawl Stone Soup version 0.9.1 character file.\n\n178 Snwcln the Vexing (level 3, -1/15 HPs)"
    c.find_version(sections).should eq('0.9.1')
  end
  it 'finds score, char, title + level' do
    c = Coroner.new
    sections = c.make_sections "178 Snwcln the Vexing (level 3, -1/15 HPs)\n\n33 creatures vanquished"
    c.find_score_char_title_level(sections).should eq({
                                                        :score     => 178,
                                                        :character => 'Snwcln',
                                                        :title     => 'Vexing',
                                                        :level     => 3
                                                      })
  end
  it 'find race, background, turns + duration' do
    c = Coroner.new
    sections = c.make_sections "Snwcln the Vexing (Felid Wanderer)  Turns: 3364, Time: 00:11:02"
    c.find_race_class_turns_duration(sections).should eq({
                                                           :race       => 'Felid',
                                                           :background => 'Wanderer',
                                                           :turns      => 3364,
                                                           :duration   => '00:11:02'
                                                         })
    
    sections = c.make_sections "fleugma the Thaumaturge (SEEE)   Turns: 14495, Time: 01:06:50"
    c.find_race_class_turns_duration(sections).should eq({
                                                           :race       => 'Sludge Elf',
                                                           :background => 'Earth Elementalist',
                                                           :turns      => 14495,
                                                           :duration   => '01:06:50'
                                                         })
  end

  it 'should match abbreviated race/background combo' do
    'FeWn'.should =~ Coroner::CrawlCombos.abbr_combo_re
    'HEFE'.should =~ Coroner::CrawlCombos.abbr_combo_re
  end

  it 'should return race/background combo from an abbreviated version' do
    Coroner::CrawlCombos.abbr2combo('SEEE').should eq(['Sludge Elf', 'Earth Elementalist'])

    expect {
      Coroner::CrawlCombos.abbr2combo 'FAKE'
    }.to raise_error(Exception, "Unknown combo 'FAKE'")
  end

  it 'should parse' do
    morgue = <<MORGUE
 Dungeon Crawl Stone Soup version 0.9.1 character file.

178 Snwcln the Vexing (level 3, -1/15 HPs)
             Began as a Felid Wanderer on Apr 23, 2012.
             Slain by a hound (2 damage)
             ... on Level 3 of the Dungeon.
             The game lasted 00:11:02 (3364 turns).

Snwcln the Vexing (Felid Wanderer)                  Turns: 3364, Time: 23:11:02

HP  -1/15        AC  1     Str 10      XL: 3   Next: 25%
MP   6/6         EV 17     Int 13      God: 
Gold 141         SH  0     Dex 14      Spells:  1 memorised,  3 levels left
                                       Lives: 0, deaths: 1

Res.Fire  : + . .   See Invis. : .    b - staff of conjuration
Res.Cold  : . . .   Warding    : . .  p - +2 robe {MR}
Life Prot.: . . .   Conserve   : .    (no shield)
Res.Acid. : + . .   Res.Corr.  : +    (helmet restricted)
Res.Poison: .       Clarity    : .    k - +0 orc cloak
Res.Elec. : +       Spirit.Shd : .    J - +2 pair of gloves
Sust.Abil.: . .     Stasis     : .    m - +2 pair of boots {run}
Res.Mut.  : .       Ctrl.Telep.: x    Q - amulet of Xaco {rCorr rF+}
Res.Rott. : .       Levitation : .    u - +5 ring of intelligence
Saprovore : . . .   Ctrl.Flight: .    s - ring of teleport control

@: quick, quite resistant to hostile enchantments, very stealthy
A: antennae 1, electricity resistance, AC +1, Str +1
a: Renounce Religion

You were on level 4 of the Orcish Mines.
You worshipped Vehumet.
Vehumet was exalted by your worship.
You were not hungry.

MORGUE
    # TODO Configure ruby-mode to indent sanely
    expected = {
      :name       => 'dcss',
      :version    => '0.9.1',
      :score      => 178,
      :character  => 'Snwcln',
      :title      => 'Vexing',
      :level      => 3,
      :race       => 'Felid',
      :background => 'Wanderer',
      :turns      => 3364.0,
      :duration   => 83462,
      :start_time => DateTime.parse('2012-04-23 00:50:42 +0100').to_time,
      :end_time   => DateTime.parse('2012-04-24 00:01:44 +0100').to_time,
      :god        => "Vehumet",
      :piety      => "exalted",
      :place      => "level 4 of the Orcish Mines",
      :branch     => 'Orcish Mines',
      :lvl        => 4,
    }
    Coroner.new(morgue, 'morgue-Snwcln-20120423-230144.txt').parse.should eq(expected)
  end
end

