require 'dcss/coroner'

describe DCSS::Coroner, 'matching' do
  it 'should make blocks' do
    c = DCSS::Coroner.new
    c.make_blocks("foo\n\nbar\n\nbaz").should eq(%w{foo bar baz})
  end
  it 'matches version in a block' do
    c = DCSS::Coroner.new
    blocks = c.make_blocks "the version 0.1\n\nanother block"
    c.match_one(blocks, /([\d.]+)/).should eq('0.1')
  end
  it 'matches nothing in a block' do
    c = DCSS::Coroner.new
    blocks = c.make_blocks "the version twelve\n\nanother block"
    c.match_one(blocks, /([\d.]+)/).should be_false
  end
  it 'matches many things in a block' do
    c = DCSS::Coroner.new
    blocks = c.make_blocks "HP  -1/15   AC   1\n\nMP   6/6   EV 17"
    c.match_many(blocks, {
      :hp => /\bHP\s+(\S+)/,
      :ev => /\bEV\s+(\S+)/
    }).should eq({:hp => '-1/15', :ev => '17'})
  end
  it 'finds a version' do
    c = DCSS::Coroner.new
    blocks = c.make_blocks " Dungeon Crawl Stone Soup version 0.9.1 character file.\n\n178 Snwcln the Vexing (level 3, -1/15 HPs)"
    c.find_version(blocks).should eq('0.9.1')
  end
  it 'finds score, char, title + level' do
    c = DCSS::Coroner.new
    blocks = c.make_blocks "178 Snwcln the Vexing (level 3, -1/15 HPs)\n\n33 creatures vanquished"
    c.find_score_char_title_level(blocks).should eq({
                                                        :score     => 178,
                                                        :character => 'Snwcln',
                                                        :title     => 'Vexing',
                                                        :level     => 3
                                                      })
  end
  it 'find race, background, turns + duration' do
    c = DCSS::Coroner.new
    blocks = c.make_blocks "Snwcln the Vexing (Felid Wanderer)  Turns: 3364, Time: 00:11:02"
    c.find_race_class_turns_duration(blocks).should eq({
                                                           :race       => 'Felid',
                                                           :background => 'Wanderer',
                                                           :turns      => 3364,
                                                           :duration   => '00:11:02'
                                                         })
    
    blocks = c.make_blocks "fleugma the Thaumaturge (SEEE)   Turns: 14495, Time: 01:06:50"
    c.find_race_class_turns_duration(blocks).should eq({
                                                           :race       => 'Sludge Elf',
                                                           :background => 'Earth Elementalist',
                                                           :turns      => 14495,
                                                           :duration   => '01:06:50'
                                                         })
  end

  it 'finds stats' do
    c = DCSS::Coroner.new
    blocks = c.make_blocks <<STATS
HP  -1/15        AC  1     Str 10      XL: 3   Next: 25%
MP   6/6         EV 17     Int 13      God: Vehumet [*.....]
Gold 141         SH  0     Dex 14      Spells:  1 memorised,  3 levels left
                                       Lives: 0, deaths: 1
STATS
    c.find_stats(blocks).should eq({
                                       :hp    => '-1/15',
                                       :maxhp => nil,
                                       :ac    => 1,
                                       :str   => 10,
                                       :xl    => 3,
                                       :mp    => '6/6',
                                       :ev    => 17,
                                       :int   => 13,
                                       :gold  => 141,
                                       :sh    => 0,
                                       :dex   => 14
                                     })

    # via dcss-Arrhythmia-HuIE-20120814-024123 e.g winning stats
    blocks = c.make_blocks <<STATS
HP 223/231 (241) AC 18     Str 30      XL: 27
MP  42/47        EV 39     Int 46      God: Cheibriados [******]
Gold 8008        SH 43     Dex 33      Spells: 15 memorised,  1 level left
STATS
    c.find_stats(blocks).should eq({
                                       :hp    => '223/231',
                                       :maxhp => 241,
                                       :ac    => 18,
                                       :str   => 30,
                                       :xl    => 27,
                                       :mp    => '42/47',
                                       :ev    => 39,
                                       :int   => 46,
                                       :gold  => 8008,
                                       :sh    => 43,
                                       :dex   => 33
                                     })

  end

  it 'should match abbreviated race/background combo' do
    'FeWn'.should =~ DCSS.abbr_combo_re
    'HEFE'.should =~ DCSS.abbr_combo_re
  end

  it 'should return race/background combo from an abbreviated version' do
    DCSS.abbr2combo('SEEE').should eq(['Sludge Elf', 'Earth Elementalist'])

    expect {
      DCSS.abbr2combo 'FAKE'
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

@: quick, quite resistant to hostile enchantments, very stealthy, very
slightly contaminated
A: antennae 1, electricity resistance, AC +1, Str +1
a: Renounce Religion

You were on level 4 of the Orcish Mines.
You worshipped Vehumet.
Vehumet was exalted by your worship.
You were not hungry.

You visited 1 branch of the dungeon, and saw 3 of its levels.

...

Vanquished Creatures
  Jessica (D:3)
  A snake (D:2)
  4 giant geckos (D:2)
  8 bats
  4 goblins
  6 hobgoblins
  3 jackals (D:2)
  6 giant cockroaches
  5 giant newts
  8 kobolds
  5 rats
  2 small snakes (D:1)
53 creatures vanquished.

Grand Total: 56 creatures vanquished

Notes
Turn   | Place    | Note
--------------------------------------------------------------
     0 | D:1      | Snwcln, the Felid Wanderer, began the quest for the Orb.
     0 | D:1      | Reached XP level 1. HP: 8/8 MP: 3/3
   752 | D:1      | Reached skill level 1 in Stealth
   752 | D:1      | Reached XP level 2. HP: 10/12 MP: 4/4
   841 | D:1      | Reached skill level 1 in Dodging
  1054 | D:1      | Reached skill level 1 in Unarmed Combat
  1906 | D:2      | Reached XP level 3. HP: 15/15 MP: 6/6
  2510 | D:2      | Reached skill level 1 in Stabbing
  2888 | D:3      | Found a radiant altar of Vehumet.
  2920 | D:3      | Noticed Jessica
  2931 | D:3      | Defeated Jessica
  2931 | D:3      | Reached XP level 4. HP: 12/19 MP: 9/9
  3341 | D:3      | Slain by a hound
  3342 | D:3      | Reached XP level 3. HP: -1/15 MP: 6/6
  3364 | D:3      | Slain by a hound

MORGUE
    # TODO Configure ruby-mode to indent sanely
    expected = {
      :name        => 'dcss',
      :version     => '0.9.1',
      :score       => 178,
      :character   => 'Snwcln',
      :title       => 'Vexing',
      :level       => 3,
      :race        => 'Felid',
      :background  => 'Wanderer',
      :turns       => 3364.0,
      :duration    => 83462,
      :start_time  => DateTime.parse('2012-04-23 00:50:42 +0100').to_time,
      :end_time    => DateTime.parse('2012-04-24 00:01:44 +0100').to_time,
      :god         => "Vehumet",
      :piety       => "exalted",
      :place       => "level 4 of the Orcish Mines",
      :branch      => 'Orcish Mines',
      :lvl         => 4,
      :kills       => 53,
      :killer      => 'hound',
      :levels_seen => 3,
      :hp          => '-1/15',
      :maxhp       => nil,
      :ac          => 1,
      :str         => 10,
      :xl          => 3,
      :mp          => "6/6",
      :ev          => 17,
      :int         => 13,
      :gold        => 141,
      :sh          => 0,
      :dex         => 14,
      :resistances => {
        "Res.Fire"    => "1/3",
        "See Invis."  => "off",
        "Res.Cold"    => "0/3",
        "Warding"     => "0/2",
        "Life Prot."  => "0/3",
        "Conserve"    => "off",
        "Res.Acid."   => "1/3",
        "Res.Corr."   => "on",
        "Res.Poison"  => "off",
        "Clarity"     => "off",
        "Res.Elec."   => "on",
        "Spirit.Shd"  => "off",
        "Sust.Abil."  => "0/2",
        "Stasis"      => "off",
        "Res.Mut."    => "off",
        "Ctrl.Telep." => "disabled",
        "Res.Rott."   => "off",
        "Levitation"  => "off",
        "Saprovore"   => "0/3",
        "Ctrl.Flight" => "off"
      },
      :equipped => {
        "weapon"     => { :slot => "b", :item => "staff of conjuration"},
        "armour"     => { :slot => "p", :item => "+2 robe {MR}" },
        "shield"     => nil,
        "helmet"     => nil,
        "cloak"      => { :slot => "k", :item => "+0 orc cloak" },
        "gloves"     => { :slot => "J", :item => "+2 pair of gloves" },
        "boots"      => { :slot => "m", :item => "+2 pair of boots {run}" },
        "amulet"     => { :slot => "Q", :item => "amulet of Xaco {rCorr rF+}" },
        "right ring" => { :slot => "u", :item => "+5 ring of intelligence" },
        "left ring"  => { :slot => "s", :item => "ring of teleport control" }
      },
      :character_abilities => ["Renounce Religion"],
      :character_features => ["antennae 1", "electricity resistance", "AC +1", "Str +1"],
      :character_state => ["quick", "quite resistant to hostile enchantments", "very stealthy", "very slightly contaminated"],
      :ending      => 'Slain by a hound',
      :morgue      => morgue,
    }
    DCSS::Coroner.new(morgue, 'morgue-Snwcln-20120423-230144.txt').parse.should eq(expected)
  end
end

