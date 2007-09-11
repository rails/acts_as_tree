ActiveRecord::Schema.define(:version => 1) do
  create_table :mixins, :force => true do |t|
    t.column :parent_id, :integer
    t.column :pos, :integer        
    t.column :lft, :integer
    t.column :rgt, :integer
    t.column :root_id, :integer
    t.column :type, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime    
  end
end
