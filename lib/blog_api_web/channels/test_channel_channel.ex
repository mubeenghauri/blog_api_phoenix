defmodule BlogApiWeb.TestChannel do
  use BlogApiWeb, :channel

  require Logger

  @impl true
  def join("test_channel:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (test_channel:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:reply, {:ok, %{"SHOUTING" => payload["msg"]} }, socket}
  end

  def handle_in("new_msg", payload, socket) do

    Logger.debug "[TestChannel] Got new msg: #{payload["body"]}"
    broadcast(socket, "new_msg", payload)
    {:noreply, socket}

  end

  # Add authorization logic here as required.
  defp authorized?(payload) do
    inspect(payload)
    true
  end
end
