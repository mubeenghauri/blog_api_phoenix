defmodule BlogApiWeb.UserView do

	use BlogApiWeb.View

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

		def render("jwt.json", %{jwt: jwt}) do
			%{"token" => jwt}
		end

end
