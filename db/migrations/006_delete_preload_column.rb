Sequel.migration do
    change do
      alter_table(:matches) do
        drop_column :preload
      end
    end
  end