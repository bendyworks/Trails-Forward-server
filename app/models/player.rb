class Player < ActiveRecord::Base
  versioned
  acts_as_api
  
  DefaultBalance = 1000
  
  attr_accessible :name
  
  has_many :megatiles, :inverse_of => :owner, :foreign_key => 'owner_id'
  has_many :resource_tiles, :through => :megatiles
  belongs_to :world
  belongs_to :user  
  validates_presence_of :user
  
  api_accessible :id_and_name do |template|
    template.add :id
    template.add 'user.name', :as => :name
    template.add :type
    template.add :world_id
    template.add 'world.name', :as => :world_name
  end
  
  api_accessible :player_public, :extend => :id_and_name do |template|
    #template.add :megatiles, :template => :id_and_name
  end
  
  api_accessible :player_private, :extend => :player_public do |template|
    template.add :balance
  end
end
