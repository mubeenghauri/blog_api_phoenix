defmodule BlogApiWeb.UserView do

		def render("user.json", %{user: [name, email] =  _user}) do
			%{
				"data" => %{
					 "name" => name, "email" => email
				}
			}
		end

    def render("users.json", %{users: users}) do
    	%{
				"data" => Enum.map(users, fn user ->
					%{ "id" => user.id,  "name" => user.name, "email" => user.email}
				end )
			}
    end

		def render("ok.json", %{msg: msg}) do
			%{"status" => 200, "message" => msg}
		end

		def render("errors.json", %{errors: errors}) do
			%{"status" => 400, "errors" => errors}
		end

		def render("error.json", %{msg: msg}) do
			%{"status" => 500, "error" => msg}
		end

		def render("jwt.json", %{jwt: jwt}) do
			%{"token" => jwt}
		end

end
