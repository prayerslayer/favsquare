Sequel.migration do

	change do
		alter_table(:users) do
			add_column :email, String, :default => nil
		end
	end
end