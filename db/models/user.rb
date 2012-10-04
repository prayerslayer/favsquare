class User < Sequel::Model
	many_to_many :tracks, :join_table => :user_tracks
end