class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.column :site_name, :string, :default => "My new RailsYard site"
      t.column :site_page_title, :string, :default => ""
      t.column :site_keyword, :string, :default => ""
      t.column :site_desc, :string, :default => ""
      t.column :default_lang, :string, :default => "en"
      t.column :homepage_id, :integer, :default => 1
      t.column :site_base_url, :string, :default => "localhost:3000"
      t.timestamps      
    end
    Setting.create :site_name => "My new RailsYard site", :default_lang => "en", :homepage_id => 1
  end

  def self.down
    drop_table :settings
  end
end
# Author::    Silvio Relli  (mailto:silvio@relli.org)