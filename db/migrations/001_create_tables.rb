Sequel.migration do
	change do
		# create table users
		create_table(:users) do
			primary_key :user_id # own user id
			String :sc_user_id # because we want to store a hash of the user id
		end

		# table tracks
		create_table(:tracks) do
			primary_key :track_id
			String :embed_code
		end

		# table user_tracks
		create_table(:user_tracks) do
			foreign_key(:track_id, :artists)
			foreign_key(:user_id, :users)
			primary_key([:user_id, :track_id])
			Integer :times_served
		end
	end
end