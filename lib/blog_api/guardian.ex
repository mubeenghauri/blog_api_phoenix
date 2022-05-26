defmodule BlogApi.Guardian do
	use Guardian, otp_app: :blog_api
	alias BlogApi.User
	require Logger

	@moduledoc"""
		JWT Authentication handler. Will be using user's id as subject for all guarded requets
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
		user = BlogApi.User.by(id: id)
		{:ok, user}
	end

	def resource_from_claim(_, _) do
		{:error, :invalid_subject_in_claim}
	end


end
