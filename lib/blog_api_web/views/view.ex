defmodule BlogApiWeb.View do

  @moduledoc """
    Inject redundent functionss into the view

    How to use :
      use BlogApiWeb.View
    in view files.
  """

  def inject do
    quote do

      def render("paginate.json", %{paginated: paginated}) do
        paginated
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
    end
  end

  defmacro __using__(_)  do
    apply(__MODULE__, :inject, [])
  end

end
