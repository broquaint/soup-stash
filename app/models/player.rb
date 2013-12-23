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
    totals = Game.collection.aggregate(
      { '$match' => { 'character' => name } },
      { '$group' => {'_id' => '$character', 'played' => { '$sum' => 1 }, 'turns' => { '$sum' => '$turns' }, 'kills' => { '$sum' => '$kill_total' }, 'gold' => { '$sum' => '$gold_found' }, 'xls' => { '$sum' => '$xl' }, 'score' => { '$sum' => '$score' } } }
    ).first
    # Don't count the XL1 every game starts with
    totals['xls'] -= totals['played']
    return totals
  end

  def favourites # TODO Take time/version/etc as options
    return {} if Game.count == 0

    rbg_list = Game.collection.aggregate(
      { '$match' => { 'character' => name } },
      { '$group' => {'_id' => { 'race'=> '$race', 'background' => '$background', 'god' => '$god' }, 'count' => { '$sum' => 1 } } }
    )
    return {} if rbg_list.empty?

    faves = { race: {}, background: {}, god: {} }

    # It feels like this could be done by MongoDB:
    # http://stackoverflow.com/q/16633669/2398559
    rbg_list.each do |rbg|
      count = rbg['count']
      %w{race background god}.each do |col|
        val = rbg['_id'][col]
        next unless val && val.length > 0
        sym = col.to_sym
        faves[sym].key?(val) ? (faves[sym][val] += count) : (faves[sym][val] = count)
      end
    end

    return faves
  end

  def worst
    game = Game.collection.aggregate(
      { '$match'  => { 'character' => name, 'won' => false } },
      { '$project'=> { 'score' => 1, 'killer' => 1 } },
      { '$sort'   => { 'score' => -1 } },
      # Hope to find something in the first 20.
      { '$limit'  => 20 }
    )

    # Hack to avoid doing "killer != nil" in mongo which involves a
    # sequential scan and therefore is SLOW for anyone with a large
    # number of games.
    the_worst = game.find{|g| g['killer'] && g['killer'].length > 0}

    return the_worst ? Game.find(the_worst['_id']) : Game.first
  end

  def nemeses
    return {} if Game.count == 0

    result = Game.collection.aggregate(
      { '$match' => { 'character' => name } },
      { '$group' => {'_id' => '$killer', 'count' => { '$sum' => 1 } } },
      # Cheaper to do after the grouping.
      { '$match' => { '_id' => { '$ne' => nil } } },
      { '$sort'  => { 'count' => -1 } }
    )

    return {} if result.empty?

    result.each{|n| n['killer'] = n.delete('_id')}

    return result
  end
end
