class Frage < ActiveRecord::Base
  has_paper_trail
  attr_accessible :text, :title
  belongs_to :thema
  
  validates :thema, :presence => true
  validates :title, :prescece => true
  
  translates :title,:text, :versioning =>true, :fallbacks_for_empty_translations => true
end
