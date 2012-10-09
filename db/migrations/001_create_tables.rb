Sequel.migration do
	change do
		# create table users
		create_table(:users) do
			String :user_id, :primary_key => true 	# because we want to store a hash of the user id
		end

		# table tracks
		create_table(:tracks) do
			Integer :track_id, :primary_key => true
		end

		# table user_tracks
		create_table(:user_tracks) do
			foreign_key :track_id, :tracks, {
				:null => false,
				:key => :track_id
			}
			foreign_key :user_id, :users, {
				:null => false,
				:key => :user_id,
				:type => String
			}
			primary_key( [ :user_id, :track_id ] )
			Integer :times_served, :default => 0
		end
	end
end