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
        products = db.execute("SELECT * FROM products")
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
        db = db_connect()
        products = db.execute("SELECT * FROM products")
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
        db = db_connect()
        designer = db.execute("SELECT * FROM designers")
        erb(:all_designers, locals: { designers:designer})
    else
        redirect('/error_login')
    end
end

get '/designers/:id/?' do
    if session[:user_id] != nil
        db = db_connect()
        designer = db.execute("SELECT * FROM designers WHERE id=?",[ params[:id]])
        designer = designer[0]
        product = db.execute("SELECT * FROM products WHERE id IN (SELECT product_id FROM 'product_designer_relation' WHERE designer_id=?)", [ params[:id]])
        erb(:designers, locals: { designers:designer, products:product })
    else
        redirect('/error_login')
    end
end

get '/product/:id/?' do
    if session[:user_id] != nil
        db = db_connect()
        product = db.execute("SELECT * FROM products WHERE id=?",[ params[:id]])
        product = product[0]
        designer = db.execute("SELECT * FROM designers WHERE id IN (SELECT designer_id FROM 'product_designer_relation' WHERE product_id=?)", [ params[:id]])
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
    real_password = db.execute("SELECT password FROM users WHERE name=?", name)
    if real_password != [] && BCrypt::Password.new(real_password[0][0]) == password
        session[:user_id] = db.execute("SELECT id FROM users WHERE name=?", name)[0][0]
        session[:user_name] = db.execute("SELECT name FROM users WHERE id=?", session[:user_id])[0][0]
        redirect('/start') 
    else
        session[:failure] = "Login failed"
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
        db = db_connect()
        db.execute("UPDATE users SET name = '#{new_name}' WHERE id=?", session[:user_id])
        session[:user_name] = db.execute("SELECT name FROM users WHERE id=?", session[:user_id])[0][0]
        redirect('/start')
    else
        redirect('/konto')
    end
end