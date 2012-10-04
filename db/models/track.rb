class Track < Sequel::Model
	many_to_many :users, :join_table => :user_tracks
end