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

  def favourites # TODO Take time/version/etc as options
    return {} if Game.count == 0

    # XXX db.eval(File.read('underscore.js'))
    map = <<-MAP
      function() {
        var e = { race: {}, background: {}, god: {} },
           me = this;
        // { race: { val: 'High Elf', count: 1 } }
        ['race','background','god'].forEach(function(i) { e[i][me[i] || 'none'] = 1; });
        emit(this.character, e);
      }
    MAP

    red = <<-RED
      function(k, vals) {
        var t = { race: {}, background: {}, god: {} };
        // Oh for CoffeeScript!
        vals.forEach(function(v) {
          ['race','background','god'].forEach(function(i) {
            for(var p in v[i])
              t[i][p] = 1 + (p in t[i] ? t[i][p] : 0);
          });
        });
        return t;
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
