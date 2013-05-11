require 'dcss/coroner'

describe DCSS::Coroner, 'matching' do
  let(:coroner) { DCSS::Coroner.new }
  it 'should make blocks' do
    coroner.make_blocks("foo\n\nbar\n\nbaz").should eq(%w{foo bar baz})
  end
  it 'matches version in a block' do
    blocks = coroner.make_blocks "the version 0.1\n\nanother block"
    coroner.match_one(blocks, /([\d.]+)/).should eq('0.1')
  end
  it 'matches nothing in a block' do
    blocks = coroner.make_blocks "the version twelve\n\nanother block"
    coroner.match_one(blocks, /([\d.]+)/).should be_false
  end
  it 'finds a version' do
    blocks = coroner.make_blocks " Dungeon Crawl Stone Soup version 0.9.1 character file.\n\n178 Snwcln the Vexing (level 3, -1/15 HPs)"
    coroner.find_version(blocks).should eq('0.9.1')
  end
  it 'finds score, char, title' do
    blocks = coroner.make_blocks "178 Snwcln the Vexing (level 3, -1/15 HPs)\n\n33 creatures vanquished"
    coroner.find_score_char_title(blocks).should eq({
                                                        :score     => 178,
                                                        :character => 'Snwcln',
                                                        :title     => 'Vexing',
                                                      })
  end
  it 'finds race + background' do
    blocks = coroner.make_blocks <<-BLOCK
    10194088 sydd the Petrodigitator (level 27, 245/273 HPs)
             Began as a Purple Draconian Transmuter on Apr 30, 2013.
             Was the Champion of Vehumet.
    BLOCK
    coroner.find_race_background(blocks).should eq({
        :race => 'Purple Draconian',
        :background => 'Transmuter'
      })
    expect {
      coroner.find_race_background([])
    }.to raise_error(DCSS::Coroner::ParseFailure)
  end
  it 'find turns + duration' do
    blocks = coroner.make_blocks "Snwcln the Vexing (Felid Wanderer)  Turns: 3364, Time: 00:11:02"
    coroner.find_turns_duration(blocks).should eq({
        :turns      => 3364,
        :duration   => '00:11:02'
      })
    
  end

  it 'finds stats' do
    blocks = coroner.make_blocks <<STATS
HP  -1/15        AC  1     Str 10      XL: 3   Next: 25%
MP   6/6         EV 17     Int 13      God: Vehumet [*.....]
Gold 141         SH  0     Dex 14      Spells:  1 memorised,  3 levels left
                                       Lives: 0, deaths: 1
STATS
    coroner.find_stats(blocks).should eq({
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
    blocks = coroner.make_blocks <<STATS
HP 223/231 (241) AC 18     Str 30      XL: 27
MP  42/47        EV 39     Int 46      God: Cheibriados [******]
Gold 8008        SH 43     Dex 33      Spells: 15 memorised,  1 level left
STATS
    coroner.find_stats(blocks).should eq({
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

  it 'should find skills' do
    skills = coroner.make_blocks <<SKILLS
   Skills:
 - Level 5.0 Fighting
 - Level 9.0(13.3) Short Blades
   Level 1.0 Slings
 - Level 1.1 Throwing
 - Level 16.0 Dodging
 + Level 24.5 Stealth
 * Level 15.1 Stabbing
 - Level 5.3(8.3) Shields
 - Level 14.0 Traps & Doors
 O Level 27 Spellcasting
SKILLS

    coroner.find_skills(skills).should eq({:skills=>
  {"Fighting"=>{:state=>"deselected", :level=>5.0, :boosted_level=>nil},
   "Short Blades"=>{:state=>"deselected", :level=>9.0, :boosted_level=>13.3},
   "Slings"=>{:state=>"untrainable", :level=>1.0, :boosted_level=>nil},
   "Throwing"=>{:state=>"deselected", :level=>1.1, :boosted_level=>nil},
   "Dodging"=>{:state=>"deselected", :level=>16.0, :boosted_level=>nil},
   "Stealth"=>{:state=>"selected", :level=>24.5, :boosted_level=>nil},
   "Stabbing"=>{:state=>"focused", :level=>15.1, :boosted_level=>nil},
   "Shields"=>{:state=>"deselected", :level=>5.3, :boosted_level=>8.3},
   "Traps & Doors"=>{:state=>"deselected", :level=>14.0, :boosted_level=>nil},
   "Spellcasting"=>{:state=>"max", :level=>27.0, :boosted_level=>nil}}})
  end

  # TODO Use a single full morgue of my own instead of this hodge podge
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


Inventory:

Hand weapons
 a - the +5,+3 dagger of Eternal Night (weapon) {=f, holy, +Inv rN+ MR Dex+1 Int+1}
   (You bought it in a shop on level 4 of the Orcish Mines)   
   
   It has been blessed by the Shining One to cause great damage to the undead
   and demons.
   
   It affects your intelligence (+1).
   It affects your dexterity (+1).
   It protects you from negative energy.
   It increases your resistance to enchantments.
   It lets you turn invisible.
 b - the +5,+6 quick blade of Inflation {god gift, drain, Dex+1 Int-2}
   (Okawaru gifted it to you on level 17 of the Dungeon)   
   
   A truly terrible weapon, it drains the life of those it strikes.
   
   It affects your intelligence (-2).
   It affects your dexterity (+1).
 d - the +3,+2 quick blade "Danoixt" {god gift, elec, rF+ rC- rN+ Dex-2 Int+2}
   (Okawaru gifted it to you on level 20 of the Dungeon)   
   
   Occasionally, upon striking a foe, it will discharge some electrical energy
   and cause terrible harm.
   
   It affects your intelligence (+2).
   It affects your dexterity (-2).
   It protects you from fire.
   It makes you vulnerable to cold.
   It protects you from negative energy.
Armour
 m - a +2 buckler of reflection
 v - a +2 cap of intelligence (worn) {god gift}
 H - the +5 swamp dragon armour "Mugejaj" (worn) {god gift, rElec rPois SInv}
   (Okawaru gifted it to you on level 1 of the Shoals)   
   
   It insulates you from electricity.
   It protects you from poison.
   It enhances your eyesight.
 J - a +2 cloak of darkness (worn) {god gift}
Magical devices
 e - a wand of teleportation (4)
 g - a wand of digging (9)
 k - a wand of teleportation (5)
 l - a wand of hasting (2)
 n - a wand of digging (11)
 s - a wand of frost (19)
 u - a wand of disintegration (0)
 S - a wand of heal wounds (0)
 U - a wand of lightning (8)
 W - a wand of fire (9)
Scrolls
 f - 4 scrolls of teleportation
 i - 2 scrolls of fear
 t - 6 scrolls of identify
 w - 4 scrolls of blinking
 K - 2 scrolls of fog
Jewellery
 c - an uncursed ring of wizardry
 q - an uncursed ring of protection from fire
 y - an uncursed amulet of resist corrosion
 B - a +3 ring of dexterity (right hand)
 F - an uncursed ring of sustain abilities
 M - the ring "Lililuexu" {-TELE rN+ Acc+4}
   (You found it on level 5 of the Elven Halls)   
   
   [ring of life protection]
   
   It affects your accuracy (+4).
   It prevents most forms of teleportation.
 O - an uncursed amulet of resist mutation
 P - an amulet of clarity (around neck)
 R - an uncursed amulet of stasis
 V - a +5 ring of strength (left hand)
Potions
 j - 3 potions of heal wounds
 o - a potion of brilliance
 p - a potion of restore abilities
 r - a potion of might
 x - 2 potions of speed
 E - 2 potions of magic
 L - 3 potions of curing
Books
 A - a book of Frost   
   
   Spells                             Type                      Level
   Freeze                             Ice                          1
   Throw Frost                        Conjuration/Ice              2
   Ozocubu's Armour                   Charms/Ice                   3
   Throw Icicle                       Conjuration/Ice              4
   Summon Ice Beast                   Ice/Summoning                4
   Condensation Shield                Ice/Transmutation            4
 C - a book of Party Tricks   
   
   Spells                             Type                      Level
   Summon Butterflies                 Summoning                    1
   Apportation                        Translocation                1
   Projected Noise                    Hexes                        2
   Blink                              Translocation                2
   Alistair's Intoxication            Transmutation/Poison         4
Magical staves
 D - a staff of death
 Q - a staff of channeling


...


   Skills:
 + Level 25.3 Fighting
 + Level 25.8 Dodging
 - Level 2.0 Stealth
 + Level 23.7 Shields
 - Level 16.1 Traps & Doors
 - Level 22.4 Spellcasting
 - Level 20.0 Conjurations
 - Level 7.5(9.3) Charms
 - Level 6.5 Summonings
 - Level 15.4 Necromancy
 - Level 10.6 Translocations
 - Level 15.2 Transmutations
 O Level 27 Ice Magic
 - Level 7.7 Air Magic
 - Level 18.0 Invocations
 O Level 27 Evocations


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

    expected = {
      :name             => 'dcss',
      :version          => '0.9.1',
      :score            => 178,
      :character        => 'Snwcln',
      :title            => 'Vexing',
      :level            => 3,
      :race             => 'Felid',
      :background       => 'Wanderer',
      :turns            => 3364.0,
      :duration_seconds => 83462,
      :duration         => '23:11:02',
      :start_time       => DateTime.parse('2012-04-23 00:50:42 +0100').to_time,
      :end_time         => DateTime.parse('2012-04-24 00:01:44 +0100').to_time,
      :god              => "Vehumet",
      :piety            => "exalted",
      :place            => "level 4 of the Orcish Mines",
      :branch           => 'Orcish Mines',
      :lvl              => 4,
      :kills            => 53,
      :killer           => 'hound',
      :levels_seen      => 3,
      :hp               => '-1/15',
      :maxhp            => nil,
      :ac               => 1,
      :str              => 10,
      :xl               => 3,
      :mp               => "6/6",
      :ev               => 17,
      :int              => 13,
      :gold             => 141,
      :sh               => 0,
      :dex              => 14,
      :resistances      => {
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
      :equipped => {"weapon"=>"b", "armour"=>"p", "shield"=>nil, "helmet"=>nil, "cloak"=>"k", "gloves"=>"J", "boots"=>"m", "amulet"=>"Q", "right ring"=>"u", "left ring"=>"s"},
      # via http://crawl.develz.org/morgues/0.10/Snowclone/morgue-Snowclone-20120303-000043.txt
      :inventory => {"a"=>{:type=>"Hand weapons", :item=>"the +5,+3 dagger of Eternal Night (weapon) {=f, holy, +Inv rN+ MR Dex+1 Int+1}", :desc=>"\n   (You bought it in a shop on level 4 of the Orcish Mines)   \n   \n   It has been blessed by the Shining One to cause great damage to the undead\n   and demons.\n   \n   It affects your intelligence (+1).\n   It affects your dexterity (+1).\n   It protects you from negative energy.\n   It increases your resistance to enchantments.\n   It lets you turn invisible.\n"}, "b"=>{:type=>"Hand weapons", :item=>"the +5,+6 quick blade of Inflation {god gift, drain, Dex+1 Int-2}", :desc=>"\n   (Okawaru gifted it to you on level 17 of the Dungeon)   \n   \n   A truly terrible weapon, it drains the life of those it strikes.\n   \n   It affects your intelligence (-2).\n   It affects your dexterity (+1).\n"}, "d"=>{:type=>"Hand weapons", :item=>"the +3,+2 quick blade \"Danoixt\" {god gift, elec, rF+ rC- rN+ Dex-2 Int+2}", :desc=>"\n   (Okawaru gifted it to you on level 20 of the Dungeon)   \n   \n   Occasionally, upon striking a foe, it will discharge some electrical energy\n   and cause terrible harm.\n   \n   It affects your intelligence (+2).\n   It affects your dexterity (-2).\n   It protects you from fire.\n   It makes you vulnerable to cold.\n   It protects you from negative energy.\n"}, "m"=>{:type=>"Armour", :item=>"a +2 buckler of reflection", :desc=>nil}, "v"=>{:type=>"Armour", :item=>"a +2 cap of intelligence (worn) {god gift}", :desc=>nil}, "H"=>{:type=>"Armour", :item=>"the +5 swamp dragon armour \"Mugejaj\" (worn) {god gift, rElec rPois SInv}", :desc=>"\n   (Okawaru gifted it to you on level 1 of the Shoals)   \n   \n   It insulates you from electricity.\n   It protects you from poison.\n   It enhances your eyesight.\n"}, "J"=>{:type=>"Armour", :item=>"a +2 cloak of darkness (worn) {god gift}", :desc=>nil}, "e"=>{:type=>"Magical devices", :item=>"a wand of teleportation (4)", :desc=>nil}, "g"=>{:type=>"Magical devices", :item=>"a wand of digging (9)", :desc=>nil}, "k"=>{:type=>"Magical devices", :item=>"a wand of teleportation (5)", :desc=>nil}, "l"=>{:type=>"Magical devices", :item=>"a wand of hasting (2)", :desc=>nil}, "n"=>{:type=>"Magical devices", :item=>"a wand of digging (11)", :desc=>nil}, "s"=>{:type=>"Magical devices", :item=>"a wand of frost (19)", :desc=>nil}, "u"=>{:type=>"Magical devices", :item=>"a wand of disintegration (0)", :desc=>nil}, "S"=>{:type=>"Magical devices", :item=>"a wand of heal wounds (0)", :desc=>nil}, "U"=>{:type=>"Magical devices", :item=>"a wand of lightning (8)", :desc=>nil}, "W"=>{:type=>"Magical devices", :item=>"a wand of fire (9)", :desc=>nil}, "f"=>{:type=>"Scrolls", :item=>"4 scrolls of teleportation", :desc=>nil}, "i"=>{:type=>"Scrolls", :item=>"2 scrolls of fear", :desc=>nil}, "t"=>{:type=>"Scrolls", :item=>"6 scrolls of identify", :desc=>nil}, "w"=>{:type=>"Scrolls", :item=>"4 scrolls of blinking", :desc=>nil}, "K"=>{:type=>"Scrolls", :item=>"2 scrolls of fog", :desc=>nil}, "c"=>{:type=>"Jewellery", :item=>"an uncursed ring of wizardry", :desc=>nil}, "q"=>{:type=>"Jewellery", :item=>"an uncursed ring of protection from fire", :desc=>nil}, "y"=>{:type=>"Jewellery", :item=>"an uncursed amulet of resist corrosion", :desc=>nil}, "B"=>{:type=>"Jewellery", :item=>"a +3 ring of dexterity (right hand)", :desc=>nil}, "F"=>{:type=>"Jewellery", :item=>"an uncursed ring of sustain abilities", :desc=>nil}, "M"=>{:type=>"Jewellery", :item=>"the ring \"Lililuexu\" {-TELE rN+ Acc+4}", :desc=>"\n   (You found it on level 5 of the Elven Halls)   \n   \n   [ring of life protection]\n   \n   It affects your accuracy (+4).\n   It prevents most forms of teleportation.\n"}, "O"=>{:type=>"Jewellery", :item=>"an uncursed amulet of resist mutation", :desc=>nil}, "P"=>{:type=>"Jewellery", :item=>"an amulet of clarity (around neck)", :desc=>nil}, "R"=>{:type=>"Jewellery", :item=>"an uncursed amulet of stasis", :desc=>nil}, "V"=>{:type=>"Jewellery", :item=>"a +5 ring of strength (left hand)", :desc=>nil}, "j"=>{:type=>"Potions", :item=>"3 potions of heal wounds", :desc=>nil}, "o"=>{:type=>"Potions", :item=>"a potion of brilliance", :desc=>nil}, "p"=>{:type=>"Potions", :item=>"a potion of restore abilities", :desc=>nil}, "r"=>{:type=>"Potions", :item=>"a potion of might", :desc=>nil}, "x"=>{:type=>"Potions", :item=>"2 potions of speed", :desc=>nil}, "E"=>{:type=>"Potions", :item=>"2 potions of magic", :desc=>nil}, "L"=>{:type=>"Potions", :item=>"3 potions of curing", :desc=>nil}, "A"=>{:type=>"Books", :item=>"a book of Frost   ", :desc=>"\n   \n   Spells                             Type                      Level\n   Freeze                             Ice                          1\n   Throw Frost                        Conjuration/Ice              2\n   Ozocubu's Armour                   Charms/Ice                   3\n   Throw Icicle                       Conjuration/Ice              4\n   Summon Ice Beast                   Ice/Summoning                4\n   Condensation Shield                Ice/Transmutation            4\n"}, "C"=>{:type=>"Books", :item=>"a book of Party Tricks   ", :desc=>"\n   \n   Spells                             Type                      Level\n   Summon Butterflies                 Summoning                    1\n   Apportation                        Translocation                1\n   Projected Noise                    Hexes                        2\n   Blink                              Translocation                2\n   Alistair's Intoxication            Transmutation/Poison         4\n"}, "D"=>{:type=>"Magical staves", :item=>"a staff of death", :desc=>nil}, "Q"=>{:type=>"Magical staves", :item=>"a staff of channeling", :desc=>nil}},
      :skills => {"Fighting"=>{:state=>"selected", :level=>25.3}, "Dodging"=>{:state=>"selected", :level=>25.8}, "Stealth"=>{:state=>"deselected", :level=>2.0}, "Shields"=>{:state=>"selected", :level=>23.7}, "Traps & Doors"=>{:state=>"deselected", :level=>16.1}, "Spellcasting"=>{:state=>"deselected", :level=>22.4}, "Conjurations"=>{:state=>"deselected", :level=>20.0}, "Charms"=>{:state=>"deselected", :level=>7.5}, "Summonings"=>{:state=>"deselected", :level=>6.5}, "Necromancy"=>{:state=>"deselected", :level=>15.4}, "Translocations"=>{:state=>"deselected", :level=>10.6}, "Transmutations"=>{:state=>"deselected", :level=>15.2}, "Air Magic"=>{:state=>"deselected", :level=>7.7}, "Invocations"=>{:state=>"deselected", :level=>18.0}},
      :character_abilities => ["Renounce Religion"],
      :character_features => ["antennae 1", "electricity resistance", "AC +1", "Str +1"],
      :character_state => ["quick", "quite resistant to hostile enchantments", "very stealthy", "very slightly contaminated"],
      :ending      => 'Slain by a hound',
      :morgue      => '' #morgue,
    }
    DCSS::Coroner.new(morgue, 'morgue-Snwcln-20120423-230144.txt').parse.should eq(expected)
  end
end

