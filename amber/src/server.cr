require "amber"

struct Person
  include JSON::Serializable
  getter name : String
  getter age : Int32
end

class HomeController < Amber::Controller::Base
  def index
    response.content_type = "text/plain"
    "Hello, World!"
  end
end

class UsersController < Amber::Controller::Base
  def show
    response.content_type = "application/json"
    id = params["id"]
    {id: id, name: "user#{id}"}.to_json
  end
end

class PeopleController < Amber::Controller::Base
  def create
    response.content_type = "application/json"
    p = Person.from_json(request.body.not_nil!.gets_to_end)
    {name: p.name, age: p.age + 1}.to_json
  end
end

Amber::Server.configure do
  pipeline :api do
    plug Amber::Pipe::Error.new
  end

  routes :api do
    get "/", HomeController, :index
    get "/users/:id", UsersController, :show
    post "/people", PeopleController, :create
  end
end

Amber.settings.port = ENV.fetch("PORT", "3000").to_i
Amber::Server.start
