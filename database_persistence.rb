require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: 'todos')
          end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def find_list(id)
    sql = 'SELECT * FROM lists WHERE id = $1'
    result = query(sql, id)
    list_from(result.first)
  end

  def all_lists
    sql = 'SELECT * FROM lists'
    result = query(sql)
    result.map { |tuple| list_from(tuple) }
  end

  def create_new_list(list_name)
    sql = 'INSERT INTO lists (name) VALUES ($1)'
    query(sql, list_name)
  end

  def delete_list(id)
    # todos deleted through ON DELETE CASCADE
    sql = 'DELETE FROM lists WHERE id = $1'
    query(sql, id)
  end

  def update_list_name(id, new_name)
    sql = 'UPDATE lists SET name = $1 WHERE id = $2'
    query(sql, new_name, id)
  end

  def create_new_todo(list_id, todo_name)
    sql = 'INSERT INTO todos (list_id, name) VALUES ($1, $2)'
    query(sql, list_id, todo_name)
  end

  def delete_todo_from_list(list_id, todo_id)
    sql = 'DELETE FROM todos WHERE id = $1 AND list_id = $2'
    query(sql, todo_id, list_id)
  end

  def update_todo_status(list_id, todo_id, completed)
    sql = 'UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3'
    query(sql, completed, todo_id, list_id)
  end

  def list_complete_all(list_id)
    sql = 'UPDATE todos SET completed = true WHERE list_id = $1'
    query(sql, list_id)
  end

  private

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def list_from(tuple)
    list_id = tuple['id'].to_i
    sql = 'SELECT * FROM todos WHERE list_id = $1'
    result = query(sql, list_id)
    todos = result.map { |todo_tuple| todo_from(todo_tuple) }
    # TODO: sort by id?

    { id: list_id, name: tuple['name'], todos: }
  end

  def todo_from(tuple)
    { id: tuple['id'].to_i,
      name: tuple['name'],
      completed: tuple['completed'] == 't' }
  end
end
