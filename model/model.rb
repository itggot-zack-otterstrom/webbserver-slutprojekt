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
end