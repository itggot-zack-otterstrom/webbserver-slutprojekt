require 'sinatra'
require 'sqlite3'
require 'bcrypt'
enable:sessions

# funktioner

def failure
    error = session[:failure]
    session[:failure] = nil
    return error
end

post '/login' do
    name = params[:name]
    password = params[:password]
    db = SQLite3::Database::new("./database/db.db")
    real_password = db.execute("SELECT password FROM users WHERE name=?", name)
    if real_password != [] && BCrypt::Password.new(real_password[0][0]) == password
        session[:user_id] = db.execute("SELECT id FROM users WHERE name=?", name)[0][0]
        redirect('/all_books')
    else
        session[:failure] = "Login failed"
        redirect('/')
    end
end

post '/new_user' do
    new_name = params[:name]
    new_password = params[:password]
    confirmed_password = params[:confirmed_password]
    if new_password == confirmed_password
        db = SQLite3::Database::new("./database/db.db")
        taken_name = db.execute("SELECT * FROM users WHERE name IS ?", new_name)
        if taken_name == []
            hashed_password = BCrypt::Password.create(new_password)
            db.execute("INSERT INTO users (name, password) VALUES (?,?)", [new_name, hashed_password])
            redirect('/')
        else
            session[:failure] = "Username is already taken."
            redirect('/new_user')
        end
    else
        session[:failure] = "Passwords didn't match. Please try again."
        redirect('/new_user')
    end
end

# routes

get '/' do
    erb(:login)
end

get '/start' do
    erb(:start)
end

get '/shop/?' do
    erb(:shop)
end

get '/new_user/?' do
    erb(:new_user)
end
