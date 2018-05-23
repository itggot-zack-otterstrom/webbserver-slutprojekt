module DesicDB
    DB_PATH = './database/db.db'

    def db_connect
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        return db
    end

    def create_user(new_name)
        db = db_connect()
        taken_name = db.execute("SELECT * FROM users WHERE name IS ?", new_name)
    end

    def insert_new_user_in_DB(new_password, new_name)
        db = db_connect()
        hashed_password = BCrypt::Password.create(new_password)
        db.execute("INSERT INTO users (name, password) VALUES (?,?)", [new_name, hashed_password])
        redirect('/')
    end

    def get_all_products
        db = db_connect()
        products = db.execute("SELECT * FROM products")
    end

    def get_all_designers
        db = db_connect()
        designer = db.execute("SELECT * FROM designers")
    end

    def get_designer(id)
        db = db_connect()
        designer = db.execute("SELECT * FROM designers WHERE id=?", id)
        designer = designer[0]
    end

    def get_product(id)
        db = db_connect()
        product = db.execute("SELECT * FROM products WHERE id=?", id)
        product = product[0]
    end

    def get_product_with_designer_id(id)
        db = db_connect()
        product = db.execute("SELECT * FROM products WHERE id IN (SELECT product_id FROM 'product_designer_relation' WHERE designer_id=?)", id)
    end

    def get_designer_with_product_id(id)
        db = db_connect()
        designer = db.execute("SELECT * FROM designers WHERE id IN (SELECT designer_id FROM 'product_designer_relation' WHERE product_id=?)", id)
    end

    def get_user_password(name)
        db = db_connect()
        real_password = db.execute("SELECT password FROM users WHERE name=?", name)
    end

    def get_user_id_with_username(name)
        db = db_connect()
        id = db.execute("SELECT id FROM users WHERE name=?", name)[0][0]
    end

    def get_username_with_user_id(id)
        db = db_connect()
        username = db.execute("SELECT name FROM users WHERE id=?", session[:user_id])[0][0]
    end

    def change_name(new_name)
        db = db_connect()
        db.execute("UPDATE users SET name = '#{new_name}' WHERE id=?", session[:user_id])
        session[:user_name] = db.execute("SELECT name FROM users WHERE id=?", session[:user_id])[0][0]
    end
end