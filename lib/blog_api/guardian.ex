defmodule BlogApi.Guardian do
	use Guardian, otp_app: :blog_api
	alias BlogApi.User
	require Logger

	@moduledoc"""
		JWT Authentication handler.
	"""

	@doc"""
		Defines what value is to be used to identify token
	"""
	def subject_for_token(%User{} =  user, _claims) do
		Logger.debug user
		subject = to_string(user.id)
		{:ok, subject}
	end

	def subject_for_token(_, _) do
		{:error, :invalid_resource_for_subject}
	end

	def resource_from_claims(%{"sub" => id}) do
		resource = BlogApi.get_resource_by_id(id)
		{:ok, resource}
	end

	def resource_from_claim(_, _) do
		{:error, :invalid_subject_in_claim}
	end


end
