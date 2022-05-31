defmodule BlogApi.Paginator do
  require Logger
  require Ecto.Query
  alias BlogApi.Repo

  def paginate(query, page_num \\ 1, limit \\ 10 ) do
    Logger.info "[Paginator] paginating ..."
    offset = (page_num - 1) * limit

    total_entries =
      query
      |> total_entries

    result =
      query
        |> Ecto.Query.offset(^offset)
        |> Ecto.Query.limit(^limit)
        |> Repo.all

    result_count = length(result)

    # if there's nothing in result, then probably we have exceeded limit
    remaining =
      if result_count > 0, do:
        ( total_entries - (length(result) + offset) ),
      else: 0

    has_next = remaining > 0

    %{
      "page" => page_num,
      # total entries uptill now
      "size" => length(result),
      "result" => result,
      "has_next" => has_next,
      "remaining" => remaining,
      "total_in_db" => total_entries

      # TODO: add `next` and `total` fields
    }
  end

  defp total_entries(qry) do

    [entries_count | _] =
      qry
        |> Ecto.Query.exclude(:select)
        # removing unecessary things to improve query time
        |> Ecto.Query.exclude(:preload)
        # |> IO.inspect
        |> Ecto.Query.exclude(:order_by)
        # |> exclude(:where) # lets keep the where in query
        |> Ecto.Query.select(count("*"))
        |> Repo.all

    IO.inspect(entries_count)

    entries_count
  end

end
