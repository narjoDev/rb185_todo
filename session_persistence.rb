class SessionPersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  def find_list(id)
    @session[:lists].find { |list| list[:id] == id }
  end

  def all_lists
    @session[:lists]
  end

  def create_new_list(list_name)
    id = next_element_id(all_lists)
    @session[:lists] << { id:, name: list_name, todos: [] }
  end

  def delete_list(id)
    @session[:lists].reject! { |list| list[:id] == id }
  end

  def update_list_name(id, new_name)
    find_list(id)[:name] = new_name
  end

  def create_new_todo(list_id, todo_name)
    todos = find_list(list_id)[:todos]
    id = next_element_id(todos)
    todos << { id:, name: todo_name, completed: false }
  end

  def delete_todo_from_list(list_id, todo_id)
    todos = find_list(list_id)[:todos]
    todos.reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, completed)
    todos = find_list(list_id)[:todos]
    todo = todos.find { |t| t[:id] == todo_id }
    todo[:completed] = completed
  end

  def list_complete_all(id)
    find_list(id)[:todos].each do |todo|
      todo[:completed] = true
    end
  end

  private

  def next_element_id(elements)
    max = elements.map { |todo| todo[:id] }.max || 0
    max + 1
  end
end
