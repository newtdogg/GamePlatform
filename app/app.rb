require 'sinatra/base'
require 'json'
require 'sinatra/flash'

require_relative 'DataMapperSetup'

class GamePlatform < Sinatra::Base
  data_mapper_setup
  enable :sessions
  set :session_secret, 'super secret'
  register Sinatra::Flash

  helpers do
    def current_user
      current_user ||= User.get(session[:user_id])
    end

    def save_image(image_file, filename)
      File.open("#{File.dirname(__FILE__)}/public/images/#{filename}", 'wb'){|file|
        file.write(image_file.read)
      }
    end

    def add_user_profile_pic(user, image_file, filename)
      save_image(image_file,filename)
      user.profile_pic = "/images/#{filename}"
      user.save
    end

  end

  post '/users' do
    user = User.create(email: params[:email],
            username: params[:username],
            first_name: params[:first_name],
            last_name: params[:last_name],
            password: params[:password],
            password_confirm: params[:password_confirm])
    if user.save
      session[:user_id] = user.id
      add_user_profile_pic(user, params[:image][:tempfile], params[:image][:filename]) if params[:image]
      redirect '/'
    else
      flash.next[:errors] = user.errors.full_messages
      redirect('/users/new')
    end
  end



  post '/login' do
    user = User.authenticate(params[:username], params[:password])
    if user
      session[:user_id] = user.id
      redirect '/'
    else
      flash.next[:errors] = ['The email or password is incorrect']
      redirect '/'
    end
  end

   post '/logout' do
    session[:user_id] = nil
    flash.keep[:notice] = 'goodbye!'
    redirect '/'
  end

  get '/' do
    erb :homepage
  end

  post '/status/new' do
    user = current_user
    user.status = params[:status]
    user.save
    params[:status].to_json
  end

  post '/tagline/new' do
    user = current_user
    user.tagline = params[:tagline]
    user.save
    params[:tagline].to_json
  end

  get '/keyboard_fighter' do
    erb(:'/gamesView/keyboard_fighter')
  end

  get '/game/:name' do
    @game = Game.first(name: params[:name])
    erb :game
  end

  get '/test/play' do
    game = Game.first()
    play = Play.create(game: game, gamestate: [{}].to_json)
    play.users << current_user
    play.save
    redirect "/play?id=#{play.id}"
  end

  get '/test/join' do
    play = Play.last
    play.users << current_user
    play.save
    redirect "/play?id=#{play.id}"
  end

  post '/play/new' do
    game = Game.first(id: params[:game_id])
    play = Play.create(game: game, gamestate: [{}].to_json)
    play.users << current_user
    play.save
    redirect "/play?id=#{play.id}"
  end

  get '/play' do
    @play_id = params[:id]
    play =Play.first(id: params[:id])
    @game =  play.game
    @players = play.users.map{|usr| usr.username}
    @currentplayer = play.users.index(current_user)
    erb :play
  end

  get '/play/getstate/:id' do
    play =Play.first(id: params[:id])
    play.gamestate.to_json
  end

  post '/play/gamestate' do
    play = Play.first(id: params[:id])
    play.gamestate = params[:gamestate]
    play.save
    play.gamestate
  end

  get '/games' do
    @games = Game.all
    erb(:games)
  end

  get '/games/new' do
    erb(:new_game)
  end

  post '/games/new' do
    Game.create(name: params[:game_name],
                type: params[:game_type],
                description: params[:game_description],
                rootpath: "/games/#{params[:game_folder]}",
                minplayercount: params[:game_min_player_count],
                maxplayercount: params[:game_max_player_count])
    redirect('/games')
  end

  get '/play' do
    erb(:play)
  end

  run if app_file == $0

end
