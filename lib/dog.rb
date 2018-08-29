class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        );
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
        DROP TABLE dogs;
      SQL

      DB[:conn].execute(sql)
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?);
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(attributes)
    dog = self.new(name: attributes[:name], breed: attributes[:breed])
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog = DB[:conn].execute(sql, id).first
    new_dog = self.new(id: dog[0], name: dog[1], breed: dog[2])
    new_dog
  end

  def self.find_or_create_by(attributes)
    sql = "SELECT * FROM dogs WHERE name = ?, breed = ?;"
    dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed]).first
    if !dog.empty?
      dog = self.new(id: dog[0], name: dog[1], breed: [2])
    else
      dog = self.create(attributes)
    end
    dog
  end

end
