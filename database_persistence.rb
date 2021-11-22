require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: "contacts")
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def add_contact_info(contact_info)
    sql = <<~SQL
      INSERT INTO contacts (name, phone_number, email_address, category_id)
      VALUES ($1, $2, $3, $4)
    SQL
    query(sql, contact_info["name"], contact_info["phone"], contact_info["email"], contact_info["category"].to_i)
  end

  def update_contact_info(contact_info)
    sql = <<~SQL
      UPDATE contacts
      SET name = $1,
          phone_number = $2,
          email_address = $3
      WHERE id = $4
    SQL
    query(sql, contact_info["name"], contact_info["phone"], contact_info["email"], contact_info["id"])
  end

  def delete_contact(id)
    sql = "DELETE FROM contacts WHERE id = $1"
    query(sql, id)
  end

  def list_all_contacts
    result = @db.exec("SELECT * FROM contacts")
    result.map do |tuple|
      {id: tuple["id"].to_i,
      name: tuple["name"],
      phone: tuple["phone_number"],
      email: tuple["email_address"]}
    end
  end

  def list_contact_info(id)
    sql = "SELECT * FROM contacts WHERE id = $1"
    result = query(sql, id)
    result.map do |tuple|
      {id: tuple["id"],
       name: tuple["name"],
       phone: tuple["phone_number"],
       email: tuple["email_address"]}
    end.first
  end

  def list_contacts_by_category(category_id)
    sql = <<~SQL
      SELECT contacts.*, category.name AS category
      FROM contacts
      RIGHT JOIN category
      ON contacts.category_id = category.id
      WHERE contacts.category_id = $1 OR
            contacts.category_id IS NULL
    SQL

    result = query(sql, category_id)
    result.map do |tuple|
      {id: tuple["id"],
       name: tuple["name"],
       phone: tuple["phone_number"],
       email: tuple["email_address"],
       category: tuple["category"]}
    end
  end
end