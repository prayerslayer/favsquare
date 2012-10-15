Sequel.migration do
	change do
		alter_table( :users ) do
			add_column :token, String, :default => ""
		end
		alter_table( :tracks ) do
			# creator information
			add_column :creator, String, :default => "Unknown"
			add_column :creator_id, Integer, :default => 0
			add_column :creator_profile, String, :default => ""
			add_column :creator_avatar, String, :default => ""
			# more track info
			add_column :title, String, :default => "No title"
			add_column :duration, Integer, :default => 0
			add_column :waveform_url, String, :default => ""
		end

		alter_table( :user_tracks ) do
			# favgiver information
			rename_column :faved_by, :faved_by_id
			add_column :faved_by, String, :default => "Unknown"
			add_column :faved_by_profile, String, :default => ""
		end
	end
end