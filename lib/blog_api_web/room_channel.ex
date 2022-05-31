defmodule BlogApiWeb.RoomChannel do

  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:"<>room, _msg, socket) do
    {:error, %{reason: "Invalid room: "<>room}}
  end

end
