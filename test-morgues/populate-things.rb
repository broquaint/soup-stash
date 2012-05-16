require 'mechanize'
require 'pp'
require 'forkmanager'

def goto_link(ua, page, text)
  ua.click( page.link_with(:text => Regexp.new(text)) )
end

def create_user(user)
  ua = Mechanize.new

  # There's likely a cleaner way to propagate state but I'm too lazy to figure it out ATM.
  player = nil
  ua.get('http://localhost:3000/users/sign_up') do |user_form|
    puts "Creating user #{user}"
    user_list = user_form.form_with(:method => 'POST') do |form|
      form['user[name]'] = user
      form['user[email]'] = "#{user}@example.com"
      form['user[password]'] = 'abc123'
      form['user[password_confirmation]'] = 'abc123'
    end.submit

    user_page = goto_link ua, user_list, user
    
    # Broken because rails thinks @player should map to players_path
    player_form = goto_link ua, user_page, 'Add a player.'

    puts "Creating player #{user}"
    # Assume user == player for simplicity
    # XXX - This fails because Rails tries to redirect to player_url for no obvious reason.
    player_list = player_form.form_with(:method => 'POST') do |form|
      form['player[name]'] = user
      form['player[for_game]'] = 'dcss'
    end.submit

    player = goto_link ua, player_list, 'Show'
  end

  return [ua, player]
end

def upload_game(form, morgue)
  # This fails because a) we don't login and b) the user[player] + game appraoch is a bit awkward
  form.form_with(:method => 'POST') do |f|
    f.file_uploads.first.file_name = morgue
  end.submit
end

users = Dir.open('.').select{|e| e =~ /^morgue/}.inject({}) do |res, morgue|
#  puts "Getting morgue #{morgue}"
  k = morgue.match(/morgue-([^-]+)-/)[1]
  v = res[k] || []
  res.merge({k => v.push(morgue)})
end

users.each_pair do |user, morgues|
  ua, player = create_user user
  sign_out_form = morgues.each do |m|

    # ??? Needed because reusing game_form was repeatedly uploading the same file :S
    puts "Uploading #{m} for #{user}"
    game_form = goto_link ua, player, 'Add game'
    upload_game game_form, m

  end
  # Bleh, this is handled by JS in the browsers.
  # REST is all good and well but the user should not have to care.
  ua.delete 'http://localhost:3000/users/sign_out'
end
