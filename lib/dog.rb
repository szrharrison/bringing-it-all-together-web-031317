class Dog
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  attr_accessor :name, :breed
  attr_reader :id
  ##################################################
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db( row )
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name( name )
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.create(id: nil, name:, breed:)
    dog = self.new(id: id, name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      name = row[1]
      breed = row[2]
      dog = self.new(id: id, name: name, breed: breed)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      self.new_from_db(dog[0])
    else
      self.create(name: name, breed: breed)
    end
  end
  ##################################################
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
end
