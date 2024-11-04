require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'todos')
    @logger = logger
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
    # id = next_element_id(all_lists)
    # @session[:lists] << { id:, name: list_name, todos: [] }
  end

  def delete_list(id)
    sql = 'DELETE FROM lists WHERE id = $1'
    query(sql, id)
    # @session[:lists].reject! { |list| list[:id] == id }
  end

  def update_list_name(id, new_name)
    sql = 'UPDATE lists SET name = $1 WHERE id = $2'
    query(sql, new_name, id)
    # find_list(id)[:name] = new_name
  end

  def create_new_todo(list_id, todo_name)
    sql = 'INSERT INTO todos (list_id, name) VALUES ($1, $2)'
    query(sql, list_id, todo_name)
  end

  def delete_todo_from_list(_list_id, todo_id)
    # TODO:
    sql = 'DELETE FROM todos WHERE id = $1'
    query(sql, todo_id)
    # todos = find_list(list_id)[:todos]
    # todos.reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, completed)
    # todos = find_list(list_id)[:todos]
    # todo = todos.find { |t| t[:id] == todo_id }
    # todo[:completed] = completed
  end

  def list_complete_all(id)
    # find_list(id)[:todos].each do |todo|
    #   todo[:completed] = true
    # end
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
