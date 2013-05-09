require 'soupstash/model/game'

class Game # Specifically DCSS
  include Mongoid::Document
  # Kaminara paging dealy.
  paginates_per 27

  SoupStash::Model::Game.meta.get_all_attributes.each do |attr|
    field attr.name, type: attr.is_a
  end
  
  belongs_to :player
  field :_id, type: String, default: -> {
    "%s-%s-%s-%s" % [name, character, combo, end_time_str]
  }

  # XXX Will the time always reflect startup?
  scope :last_day,   gt(end_time: DateTime.now - 1)
  scope :last_week,  gt(end_time: DateTime.now - 7)
  scope :last_month, gt(end_time: DateTime.now - 30)
  scope :last_year,  gt(end_time: DateTime.now - 365)

  scope :unwon, where(won: false)

  # Used all over the place.
  index({ score: 1 })
  # Used by scopes
  index({ end_time: 1 })
  # Used by map/reduces + filters
  index({ character: 1 })
  index({ god: 1 })
  index({ race: 1 })
  index({ background: 1 })
  index({ race: 1, background: 1 })
  index({ race: 1, background: 1, god: 1 })
  # Used on game listing.
  index({ killer: 1 })
  index({ ending: 1 })

  index({ won: 1 })

  def ending_str
    killer || terse_ending
  end

  def god
    g = super()
    g ? g.titleize : ''
  end

  def self.for(character)
    Game.where(character: character)
  end

  # http://kylebanker.com/blog/2009/12/mongodb-map-reduce-basics/
  def self.popular_combos # TODO Take time/version/etc as options
    return [] if self.count == 0

    map = <<-MAP
    function() {
      var drac_re = /^(?:(?:#{DCSS::DRAC_COLOURS.join('|')}) )?/,
             race = this.race.replace(drac_re, '');
      emit(race + " " + this.background, { count: 1 })
    }
    MAP
    red = 'function(k,vals) { var tot = 0; vals.forEach(function(v) { tot += v.count }); return { count: tot }; }'
    self.map_reduce(map, red).out(:inline=>1).collect do |c|
      {
        :race  => c['_id'],
        :count => c['value']['count'].to_i,
      }
    end
  end  
end
