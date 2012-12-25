Sequel.migration do

	up do
		# insert user
		
		self[:users].insert( [:user_id, :token ], ["2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", "1-25581-31206514-4dd99af223b6fae"])

		# insert tracks

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 55296102, "Richie_Gee", 883302, "http://soundcloud.com/richie_gee", "https://i1.sndcdn.com/avatars-000006405514-k7397o-large.jpg?923db0b", "04.08.12 Richie Gee @ Nature One 2012", 5325782, "https://w1.sndcdn.com/no0uA5e8kHgV_m.png"] )

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 60339242, "mobilee records", 80522, "http://soundcloud.com/mobilee-records", "https://i1.sndcdn.com/avatars-000003657742-sab9fp-large.jpg?923db0b", "Tom Flynn - Do You Like Bass? - Leena025", 227129, "https://w1.sndcdn.com/7wQiCtMiYBsu_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 59004036, "Ideal Audio", 238940, "http://soundcloud.com/ideal-audio", "https://i1.sndcdn.com/avatars-000006335720-zqs6tb-large.jpg?923db0b", "Ideal Podcast Vol. 21 - Martin Landsky", 3649882, "https://w1.sndcdn.com/Muyy8UKs8bs7_m.png" ] )

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 58205184, "tommyfourseven", 13647, "http://soundcloud.com/tommyfourseven", "https://i1.sndcdn.com/avatars-000000728468-blm28m-large.jpg?923db0b", "MONIX", 430223, "https://w1.sndcdn.com/zLScYci2kDm2_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 58598857, "Uncanny Valley Dresden", 1144342, "http://soundcloud.com/uncanny-valley-dresden", "https://i1.sndcdn.com/avatars-000007927877-hg2vob-large.jpg?923db0b", "10 Jacob Korn & Break SL feat. Tabitha Xavier  - You & Me ALBUM SNIPPET", 237892, "https://w1.sndcdn.com/p9XnmvGeIGDX_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 59271300, "adambeyer", 203, "http://soundcloud.com/adambeyer", "https://i1.sndcdn.com/avatars-000000067652-vhrn5v-large.jpg?923db0b", "Adam Beyer@Woodstock 2012-AUG-19", 13396872, "https://w1.sndcdn.com/HFP7g5OUh05c_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 48817950, "Pan-Pot (OFFICIAL)", 488, "http://soundcloud.com/pan-pot", "https://i1.sndcdn.com/avatars-000026547963-dui5a3-large.jpg?923db0b", "Pan-Pot - Sonar by Day 2012", 4379058, "https://w1.sndcdn.com/kVKO0qjCMuHx_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 50454833, "SPL", 43837, "http://soundcloud.com/spl", "https://i1.sndcdn.com/avatars-000028513184-8s6iz4-large.jpg?923db0b", "SPL - Sub.Mission Podcast", 1733309, "https://w1.sndcdn.com/57PyaZ92vhvr_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 1376169, "R_co", 29984, "http://soundcloud.com/r_co", "https://i1.sndcdn.com/avatars-000000622124-t3qy3j-large.jpg?923db0b", "Marco Carola, Sven Vaeth and DJ Hell Live @ Omen Closing Party, Frankfurt - 18-10-1998 - (Check The Comments To Download)", 52808829, "https://w1.sndcdn.com/VY7dDjccFops_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 18437313, "forward strategy group", 1663098, "http://soundcloud.com/forward-strategy-group", "https://i1.sndcdn.com/avatars-000001697477-bp1mjz-large.jpg?923db0b", "forward strategy group // CLR podcast 111", 3692665, "https://w1.sndcdn.com/ZABjZYUq17vC_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 43134070, "prayerslayer", 1133619, "http://soundcloud.com/prayerslayer", "https://i1.sndcdn.com/avatars-000017497633-m9dq0v-large.jpg?923db0b", "CLR Podcast #147 - Martin L. Gore", 3813187, "https://w1.sndcdn.com/WNwFz3xYuz7a_m.png" ])

		self[:tracks].insert( [:track_id, :creator, :creator_id, :creator_profile, :creator_avatar, :title, :duration, :waveform_url], [ 40357596, "Monoloc", 15258, "http://soundcloud.com/monoloc-smallroom-music", "https://i1.sndcdn.com/avatars-000017936923-za7jg2-large.jpg?923db0b", "MONOLOC @ BERGHAIN/1Hour/CLR/11.03.2012", 3667525, "https://w1.sndcdn.com/4uDFb8FnX5qS_m.png" ])

		# add to user tracks
		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 55296102, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 60339242, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 59004036, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 58205184, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 58598857, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 59271300, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 48817950, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 50454833, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 1376169, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 18437313, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 43134070, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

		self[:user_tracks].insert( [ :track_id, :user_id, :times_served, :faved_by_id, :faved_by, :faved_by_profile ], [ 40357596, "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4", 0, 1133619, "prayerslayer", "http://soundcloud.com/prayerslayer" ] )

	end

	down do
		# delete user
		self[:users].where( :user_id => "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4").delete

		# delete tracks
		self[:tracks].all.delete

		# delete user tracks
		self[:user_tracks].all.delete
	end
end