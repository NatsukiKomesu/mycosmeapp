require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'sinatra/cookies'
require 'pry'
require 'fileutils'
 
client = PG::connect(
  :host => "localhost",
  :user => 'nakatsukasayuya', :password => '',
  :dbname => "cosmetics")

  enable :sessions

  get '/' do
    @msg = session[:message]
    session[:message] = nil
    erb :index
  end

  get '/mypage' do
    erb :mypage
  end

  get '/album' do
    @pictures = client.exec_params("select * from albums")
    erb :album
  end

  get '/pouch' do
    erb :pouch
  end

  post '/pouch' do
    @item_name = params[:item_name]
    @category = params[:category]
    @brand = params[:brand]
    @color = params[:color]
    @image = params[:file][:filename]
    # @year = params[:year]
    # @manth = params[:manth]
    # @day = params[:day]

    client.exec_params("insert into cosmetics(name, color, category, brand, image) values($1, $2, $3, $4, $5)", [@item_name, @color, @category, @brand, @image])

    redirect 'pouchmenu'
  end

  get '/pouchmenu' do
    erb :pouchmenu
  end

  get '/lip' do
    @cosmetics = client.exec_params("select * from cosmetics where category = 'リップ'")
    erb :lip
  end

  get '/login' do
    session[:id] = nil
    erb :login
  end

  post '/login' do
    email = params[:email]
    password = params[:password]
    res = client.exec("select * from users where password = $1 and email = $2", [password, email]).to_a.first
    # binding.pry
    if res
      session[:id] = res['id']
      redirect '/'
    else
      redirect '/login'
    end
  end

  get '/index' do
    erb :index
  end

  get '/signup' do
    session[:id] = nil
    erb :signup
  end

  post '/signup' do
    name = params[:name]
    password = params[:password]
    email = params[:email]
    res = client.exec("select * from users where users.name = $1 and users.email = $2", [name, email]).to_a.first
    if res
      redirect '/signup'
    else
       client.exec("insert into users (name, password, email) values ($1, $2, $3)", [name, password, email])
       res = client.exec("select * from users where users.name = $1 and users.email = $2", [name, email]).to_a.first
       session[:id] = res["id"]
       redirect '/'
    end
  end

  get '/album' do
    session[:id] = nil
    erb :album
  end

  post '/album' do
    @file_name = params[:file][:filename]
    client.exec("insert into albums (path) values ($1)", [@file_name])
    FileUtils.mv(params[:file][:tempfile], "./public/images/albums/#{@file_name}")
    redirect 'album'
  end

  get '/cheeks' do
    @cosmetics = client.exec_params("select * from cosmetics where category = 'チーク'")
    erb :cheeks
  end

  get '/eyeshadow' do
    @cosmetics = client.exec_params("select * from cosmetics where category = 'アイシャドウ'")
    erb :eyeshadow
  end

  get '/base' do
    @cosmetics = client.exec_params("select * from cosmetics where category = 'ベース'")
    erb :base
  end

  get '/nail' do
    @cosmetics = client.exec_params("select * from cosmetics where category = 'ネイル'")
    erb :nail
  end

  get '/perfum' do
    @cosmetics = client.exec_params("select * from cosmetics where category = '香水'")
    erb :perfum
  end
  
  
  
  
  

