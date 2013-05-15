class Player
  include Mongoid::Document

  paginates_per 27
  
  field :for_game, :type => String # Possibly unnecessary/implied?
  field :name,     :type => String

  field :created_at, :type => Time, :default => -> { Time.now }
  
  belongs_to  :user
  has_many    :games
  field :_id, :type => String, :default => -> { "%s-%s" % [name, for_game] }

  def basic_totals
    map = <<-MAP
      function() {
        var result = { played: 1 };
        result.kills = this.kill_total;
        result.turns = this.turns;
        result.gold  = this.gold_found;
        result.xls   = this.xl > 1 ? this.xl : 0;
        result.score = this.score;
        emit(this.character, result);
      }
    MAP
    red = <<-RED
      function(k ,vals) {
        var result = {
            played: 0,
            kills:  0,
            turns:  0,
            xls:    0,
            gold:   0,
            score:  0
        };
        vals.forEach(function(v) {
          for(var p in v)
            result[p] += v[p];
        });
        return result;
      }
    RED
    result = Game.for(name).map_reduce(map, red).out(inline: 1) 
    return result.first['value'].reduce({}) do |r, kv|
      r.merge(kv[0]=>kv[1].to_i)
    end
  end

  def array_to_totals(a)
    a.reduce({}) {|totals, v| totals.merge v => 0}
  end
  def favourites # TODO Take time/version/etc as options
    return {} if Game.count == 0

    totals = {
      race:       array_to_totals(DCSS::RACE.values),
      background: array_to_totals(DCSS::BACKGROUND.values),
      god:        array_to_totals(DCSS::GODS),
    }
    
    # XXX db.eval(File.read('underscore.js'))
    map = <<-MAP
    function() {
        var out = #{totals.to_json},
        drac_re = /^(?:(?:#{DCSS::DRAC_COLOURS.join('|')}) )?/,
           race = this.race.replace(drac_re, '');

        out.race[race] = 1;
        out.background[this.background] = 1;
        out.god[this.god || 'none'] = 1;

        emit(this.character, out);
    }
    MAP

    red = <<-RED
    function(character, vals) {
        var totals = #{totals.to_json},
            addUpTotalFor = function(key, rbg) {
                for(var prop in rbg)
                    totals[key][prop] += rbg[prop];
            };

        vals.forEach(function(val) {
            ['race', 'background', 'god'].forEach(function(key) {
                addUpTotalFor(key, val[key]);
            });
        });
    
        return totals;
    }
    RED

    faves = Game.for(name).map_reduce(map, red).out(inline: 1)
    return {} if faves.empty?
    return {
      race:       faves.first['value']['race'],
      background: faves.first['value']['background'],
      god:        faves.first['value']['god'],
    }
  end

  def nemeses
    return {} if Game.count == 0

    map = <<-MAP
      function() {
        var result = {};
        result[this.killer] = 1;
        emit(this.character, result);
      }
    MAP
    red = <<-RED
      function(k ,vals) {
        var result = {};
        vals.forEach(function(v) {
          for(var killer in v)
            result[killer] = 1 + (killer in result ? result[killer] : 0);
        });
        return result;
      }
    RED

    result = Game.for(name).unwon.map_reduce(map, red).out(inline: 1)
    return {} if result.empty?
    return result.first['value']
  end
end
