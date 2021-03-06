defmodule ElixirTw.Post do
  use ElixirTw.Web, :model

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :body, :string
    belongs_to :user, ElixirTw.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w/title body user_id/, ~w/slug/)
    |> build_slug
    |> validate_required([:title, :slug, :user_id])
    |> unique_constraint(:slug)
    |> assoc_constraint(:user)
  end

  defp build_slug(changeset = %{changes: changes}) when changes == %{}, do: changeset
  defp build_slug(changeset = %{changes: %{slug: slug}}), do: changeset
  defp build_slug(changeset = %{changes: %{ title: title}}) do
    put_change(changeset, :slug, title_to_slug(title))
  end

  defp title_to_slug(title), do: "#{slugify_time}-#{slugify_title(title)}"

  defp slugify_time, do: DateTime.utc_now |> DateTime.to_unix |> to_string

  defp slugify_title(nil), do: nil
  defp slugify_title(title) do
    title |> Phoenix.Naming.humanize |> String.downcase |> String.replace(" ", "-")
  end
end
