Sequel.migration do

	up do
		self[:users].insert( [:user_id, :token ], ["2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4
", "1-25581-31206514-4dd99af223b6fae"])
	end

	down do
		self[:users].where( :user_id => "2c82b3db619ea8dbf305b10f263bea85747b055558964c205c014976250d9d5d73258c08c4cb5644985bfb9e7edc3601c1423b4aed106120a5edf262ac7234b4").delete
	end
end