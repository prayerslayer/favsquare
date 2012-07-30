class User < Sequel::Model
	one_to_many :user_tracks
end