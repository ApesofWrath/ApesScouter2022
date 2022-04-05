Sequel.migration do
    change do
      alter_table(:matches) do
        add_column :fouls, String, :null => false
      end
    end
  end