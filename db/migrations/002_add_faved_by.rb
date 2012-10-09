Sequel.migration do
	change do
		alter_table( :user_tracks ) do
			add_column :faved_by, Integer, :default => 0
			add_index :user_id
		end
	end
end