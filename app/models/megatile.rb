class Megatile < ActiveRecord::Base
  acts_as_api

  belongs_to :world
  belongs_to :owner, :class_name => 'Player'
  has_many :resource_tiles

  has_and_belongs_to_many :megatile_groupings
  has_many :listings, :through => :megatile_groupings

  validates_presence_of :world

  validates_uniqueness_of :x, :scope => [:y, :world_id]
  validates_uniqueness_of :y, :scope => [:x, :world_id]

  def width
    world.try(:megatile_width)
  end

  def height
    world.try(:megatile_height)
  end

  def spawn_resources
    (x...(x + width)).each do |x|
      (y...(y + height)).each do |y|
        ResourceTile.create(:x => x, :y => y, :world => world, :megatile => self)
      end
    end
  end

  def active_listings
    listings.where(status: 'Active')
  end

  def bids_on(active_only = true)
    ret = Set.new
    megatile_groupings.each do |mg|
      bids = mg.bids_on
      if active_only
        bids = bids.where(:status => Bid.verbiage[:offered])
      end

      bids.each do |b|
        ret << b
      end
    end
    ret
  end

  def bids_offering(active_only = true)
    ret = Set.new
    megatile_groupings.each do |mg|
      bids = mg.bids_offering
      if active_only
        bids = bids.where(:status => Bid.verbiage[:offered])
      end

      bids.each do |b|
        ret << b
      end
    end
    ret
  end

  def estimated_value
    total_price = 0
    resource_tiles.each do |rt|
      tmp_price = rt.estimated_value
      if tmp_price != nil
        total_price += tmp_price
      end
    end
    total_price
  end

  api_accessible :id_and_name do |template|
    template.add :id
    template.add :x
    template.add :y
    template.add :updated_at
  end

  api_accessible :megatile_with_resources, :extend => :id_and_name do |template|
    template.add :owner, :template => :id_and_name
    template.add :resource_tiles, :template => :resource
  end

  api_accessible :megatiles_with_resources, :extend => :megatile_with_resources

  api_accessible :megatile_with_value, :extend => :id_and_name do |template|
    template.add :estimated_value
  end

  api_accessible :megatiles_with_value, :extend => :megatile_with_value

end
