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
        redirect('/start')
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
    db = SQLite3::Database::new("./database/db.db")
    products = db.execute("SELECT * FROM products")
    erb(:start, locals: {products: products})
end

get '/shoppa/?' do
    db = SQLite3::Database::new("./database/db.db")
    products = db.execute("SELECT * FROM products")
    erb(:shoppa, locals: {products: products})
end

get '/new_user/?' do
    erb(:new_user)
end

get '/designers/:id/?' do
    db = SQLite3::Database::new("./database/db.db")
    designer = db.execute("SELECT * FROM designers WHERE id=?",[ params[:id]])
    designer = designer[0]
    product = db.execute("SELECT * FROM products WHERE id IN (SELECT product_id FROM 'product_designer_relation' WHERE designer_id=?)", [ params[:id]])
    erb(:designers, locals: { designers:designer, products:product })
end

get '/product/:id/?' do
    db = SQLite3::Database::new("./database/db.db")
    product = db.execute("SELECT * FROM products WHERE id=?",[ params[:id]])
    product = product[0]
    designer = db.execute("SELECT * FROM designers WHERE id IN (SELECT designer_id FROM 'product_designer_relation' WHERE product_id=?)", [ params[:id]])
    erb(:product, locals: { products:product, designer:designer})
end