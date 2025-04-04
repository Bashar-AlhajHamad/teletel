class CreateCustomRolePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_role_permissions do |t|
      t.references :custom_role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true

      t.timestamps
    end
  end
end
