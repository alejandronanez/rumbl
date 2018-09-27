defmodule Rumbl.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false
  alias Rumbl.Repo
  alias Rumbl.Accounts
  alias Rumbl.Multimedia.Category

  alias Rumbl.Multimedia.Video

  def list_videos do
    Video
    |> Repo.all(Video)
    |> preload_user
  end

  def create_category(name) do
    Repo.get_by(Category, name: name) || Repo.insert!(%Category{name: name})
  end

  def get_video!(id), do: preload_user(Repo.get!(Video, id))

  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  def create_video(%Accounts.User{} = user, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  def change_video(%Accounts.User{} = user, %Video{} = video) do
    video
    |> Video.changeset(%{})
    |> put_user(user)
  end

  def list_user_videos(%Accounts.User{} = user) do
    Video
    |> user_videos_query(user)
    |> Repo.all()
    |> preload_user()
  end

  def get_user_video!(%Accounts.User{} = user, id) do
    from(v in Video, where: v.id == ^id)
    |> user_videos_query(user)
    |> Repo.one!()
    |> preload_user()
  end

  defp user_videos_query(query, %Accounts.User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  defp put_user(changeset, user) do
    Ecto.Changeset.put_assoc(changeset, :user, user)
  end

  defp preload_user(video_or_videos) do
    Repo.preload(video_or_videos, :user)
  end
end
