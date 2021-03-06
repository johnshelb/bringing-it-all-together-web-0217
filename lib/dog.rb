require "pry"
class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize (id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql=<<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    name = row[1]
    breed = row[2]
    id = row[0]
    self.new(id: id,name: name,breed: breed)
  end


  def self.find_by_name(name)
    sql=<<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
    x=DB[:conn].execute(sql, name)[0]
    Dog.new(id: x[0], name: x[1], breed: x[2])
  end

  def self.find_by_id(id)
    sql=<<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
    x=DB[:conn].execute(sql, id)[0]
    Dog.new(id: x[0], name: x[1], breed: x[2])
  end

  def save
    if self.id
      self.update
    else
      sql=<<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql=<<-SQL
      UPDATE dogs SET name=?, breed=? WHERE id=?
    SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
      Dog.find_by_name(self.name)
    end

    def self.create(name:, breed:)
      self.new(name: name, breed: breed).save
    end

    def self.find_or_create_by(arg)
      name=arg[:name]
      breed=arg[:breed]
      sql=<<-SQL
        SELECT * FROM dogs WHERE name=? AND breed = ?
      SQL
        x=DB[:conn].execute(sql,name,breed)[0]
      if x
        self.find_by_name(arg[:name])
      else
         self.create(name: name, breed: breed)
      end
    end


end
