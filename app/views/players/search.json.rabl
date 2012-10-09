@players
attributes :name
node :url do |p|
     user_player_path(p.user, p)
end
