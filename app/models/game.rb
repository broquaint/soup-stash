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

  scope :last_day,   -> { gt(end_time: DateTime.now - 1) }
  scope :last_week,  -> { gt(end_time: DateTime.now - 7) }
  scope :last_month, -> { gt(end_time: DateTime.now - 30) }
  scope :last_year,  -> { gt(end_time: DateTime.now - 365) }

  scope :tourney_0_13, -> {
    where(
      :end_time.gt => DateTime.iso8601('2013-10-11T20:00:00+00:00'),
      :end_time.lt => DateTime.iso8601('2013-10-27T20:00:00+00:00'),
      version: '0.13'
    )
  }

  scope :unwon, where(won: false)

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
  # Used on all game listing
  index({ god: 1, end_time: 1 })
  index({ race: 1, end_time: 1 })
  index({ background: 1, end_time: 1 })
  index({ race: 1, background: 1, end_time: 1 })
  index({ race: 1, background: 1, god: 1, end_time: 1 })
  index({ race: 1, god: 1, end_time: 1 })
  index({ background: 1, god: 1, end_time: 1 })

  # Used for the nemeses map/reduce in Player.
  index({ character: 1, ending: 1 })

  index({ won: 1 })

  def ending_str
    killer || terse_ending
  end

  def god
    g = super()
    g ? g.titleize : ''
  end

  # Temp hack to work around a bug in how the end_time_str is generated.
  def end_time_str
    str = super
    # 20130731161437 => 20130731-161437
    str.sub /^(\d{8})(\d{6})$/, '\1-\2'
  end

  def update_from_morgue!(uri)
    file   = uri.path.split('/')[-1]
    morgue = DCSS::Coroner.new(open(uri.to_s).read, file).parse

    # Don't overwrite existing logfile values, this is needed because
    # DCSS::Coroner isn't always 100% accurate and I'm too lazy to fix it.
    to_update = morgue.reduce({ has_morgue_file: true }) do |res, kv|
      key, value    = *kv
      should_update = self[key].nil? || !DCSS.is_logfile_field(key)
      should_update ? res.merge(key => value) : res
    end

    update_attributes!(to_update)
    save!
  end

  def self.for(character)
    Game.where(character: character)
  end

  def self.popular_combos # TODO Take time/version/etc as options
    return [] if self.count == 0

    map = <<-MAP
    function() {
      var drac_re = /^(?:(?:#{DCSS.drac_colours.join('|')}) )?/,
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
