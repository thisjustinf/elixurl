defmodule Elixurl.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Elixurl.Auth` context.
  """

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        first_name: "some first_name",
        last_name: "some last_name",
        password: "some password"
      })
      |> Elixurl.Auth.create_user()

    user
  end

  import Ecto.Query

  alias Elixurl.Auth
  alias Elixurl.Auth.Scope

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email()
    })
  end

  def unconfirmed_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Auth.register_user()

    user
  end

  # def user_fixture(attrs \\ %{}) do
  #   user = unconfirmed_user_fixture(attrs)

  #   token =
  #     extract_user_token(fn url ->
  #       Auth.deliver_login_instructions(user, url)
  #     end)

  #   {:ok, user, _expired_tokens} = Auth.login_user_by_magic_link(token)

  #   user
  # end

  def user_scope_fixture do
    user = user_fixture()
    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  def set_password(user) do
    {:ok, user, _expired_tokens} =
      Auth.update_user_password(user, %{password: valid_user_password()})

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def override_token_inserted_at(token, inserted_at) when is_binary(token) do
    Elixurl.Repo.update_all(
      from(t in Auth.UserToken,
        where: t.token == ^token
      ),
      set: [inserted_at: inserted_at]
    )
  end

  def generate_user_magic_link_token(user) do
    {encoded_token, user_token} = Auth.UserToken.build_email_token(user, "login")
    Elixurl.Repo.insert!(user_token)
    {encoded_token, user_token.token}
  end
end
