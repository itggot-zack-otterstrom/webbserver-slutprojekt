require 'sinatra'
require 'sqlite3'
require 'bcrypt'
enable:sessions
require_relative './model/model'
include DesicDB

# GET routes

get '/' do
    erb(:login)
end

get '/start' do
    if session[:user_id] != nil
        db = db_connect()
        products = get_all_products()
        erb(:start, locals: {products: products})
    else
        redirect('/error_login')
    end
end

get '/error_login' do
    erb(:error_login)
end

get '/shoppa/?' do
    if session[:user_id] != nil
        products = get_all_products()
        erb(:shoppa, locals: {products: products})        
    else
        redirect('/error_login')
    end
end

get '/new_user/?' do
    erb(:new_user)
end

get '/all_designers' do
    if session[:user_id] != nil
        designer = get_all_designers()
        erb(:all_designers, locals: { designers:designer})
    else
        redirect('/error_login')
    end
end

get '/designers/:id/?' do
    if session[:user_id] != nil
        id = [ params[:id]]
        designer = get_designer(id)
        product = get_product_with_designer_id(id)
        erb(:designers, locals: { designers:designer, products:product })
    else
        redirect('/error_login')
    end
end

get '/product/:id/?' do
    if session[:user_id] != nil
        id = [ params[:id]]
        product = get_product(id)
        designer = get_designer_with_product_id(id)
        erb(:product, locals: { products:product, designer:designer})
    else
        redirect('/error_login')
    end
end

get '/konto' do
    if session[:user_id] != nil
        erb(:konto)
    else
        redirect('/error_login')
    end
end

# POST

post '/new_user' do
    new_name = params[:name]
    new_password = params[:password]
    confirmed_password = params[:confirmed_password]
    if new_password == confirmed_password
        taken_name = create_user(new_name)
        if taken_name == []
            insert_new_user_in_DB(new_password, new_name)
        else
            redirect('/new_user')
        end
    else
        redirect('/new_user')
    end
end

post '/login' do
    name = params[:name]
    password = params[:password]
    db = db_connect()
    real_password = get_user_password(name)
    if real_password != [] && BCrypt::Password.new(real_password[0][0]) == password
        session[:user_id] = get_user_id_with_username(name)
        user_id = session[:user_id]
        session[:user_name] = get_username_with_user_id(user_id)
        redirect('/start') 
    else
        redirect('/')
    end
end

post '/logout' do
    session[:user_id] = nil
    session[:user_name] = nil
    redirect ('/')
end

post '/change_name' do
    old_name = params[:old_name]
    new_name = params[:new_name]
    if old_name == session[:user_name]
        new_name = params[:new_name]
        change_name(new_name)
        redirect('/start')
    else
        redirect('/konto')
    end
end