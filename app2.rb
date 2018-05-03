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
        db = SQLite3::Database::new("./database/db.db")
        db.execute("UPDATE users SET name = '#{new_name}' WHERE id=?", session[:user_id])
        session[:user_name] = db.execute("SELECT name FROM users WHERE id=?", session[:user_id])[0][0]
        redirect('/start')
    else
        redirect('/konto')
    end
end

=begin
post '/change_password' do
    p old_password = params[:old_password]
    p new_password = params[:new_password]
    p new_password_ver = params[:new_password_ver]
    p hashed_old_password = BCrypt::Password.create(old_password)
    db = SQLite3::Database::new("./database/db.db")
    p real_old_password = db.execute("SELECT password FROM users WHERE id IS ?", session[:user_id]) [0][0]
    p real_old_password = BCrypt::Password.new(real_old_password)
    if  new_password == new_password_ver 
        db.execute("DELETE password FROM users WHERE id IS ?", session[:user_id])
        p "correct"
        redirect ('/')
    end
end
=end

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

def get_product(product_id)
    db = SQLite3::Database::new("./database/db.db")
    names = db.execute("SELECT product_name FROM products WHERE id=?", product_id)
    names[0]
end

def get_product(product_id)
    db = SQLite3::Database::new("./database/db.db")
    product_data = db.execute("SELECT * FROM products WHERE id = ?", product_id)
    product_data = product_data[0]
    product_info = { id: product_data[0], name: product_data[1], price: product_data[2]}
    product_info[:designer] = get_designer(product_data[3])
    product_info
end

def get_designer(designer_id)
    db = SQLite3::Database::new("./database/db.db")
    names = db.execute("SELECT name FROM designers WHERE id=?", designer_id)
    names[0][0]
end

# routes

get '/' do
    erb(:login)
end

get '/start' do
    if session[:user_id] != nil
        db = SQLite3::Database::new("./database/db.db")
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
        db = SQLite3::Database::new("./database/db.db")
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
        db = SQLite3::Database::new("./database/db.db")
        designer = db.execute("SELECT * FROM designers")
        erb(:all_designers, locals: { designers:designer})
    else
        redirect('/error_login')
    end
end

get '/designers/:id/?' do
    if session[:user_id] != nil
        db = SQLite3::Database::new("./database/db.db")
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
        db = SQLite3::Database::new("./database/db.db")
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