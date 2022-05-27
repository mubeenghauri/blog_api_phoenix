# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BlogApi.Repo.insert!(%BlogApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


defmodule PostSeeds do

  alias BlogApi.{Post, Repo}

  def main do
    for user_id <-[1, 5, 6]  do
      for i <- 1..20  do
        Repo.insert!(
          %Post{
            title: "My Post #{i}",
            content: "This is post #{i} for user #{user_id}",
            user_id: user_id
          }
        )
      end
    end
  end

end

PostSeeds.main
