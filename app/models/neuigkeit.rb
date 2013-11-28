# == Schema Information
#
# Table name: neuigkeiten
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  text       :text
#  datum      :datetime
#  rubrik_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :integer
#

class Neuigkeit < ActiveRecord::Base
  
  attr_accessible :datum, :text, :title, :rubrik_id, :author_id,:picture, :calentries_attributes
  belongs_to :author, :class_name =>'User'
  belongs_to :rubrik, :class_name =>'Rubrik', :foreign_key => "rubrik_id"
  validates :rubrik, :presence=>true
  validates :author, :presence=>true
  translates :title,:text, :versioning=>true, :fallbacks_for_empty_translations => true
  has_many :calentries, inverse_of: :object
  mount_uploader :picture, PictureUploader
  scope :published, -> {where("datum <= ? AND datum IS NOT NULL", Time.now.to_date).order(:datum).reverse_order}
  scope :recent, -> { published.where("updated_at >= ? ",Time.now - 7.days)}
  scope :unpublished, -> {where("datum >= ? OR datum IS NULL", Date.today)}
  scope :public, ->{includes(:rubrik).where("rubriken.public"=>:true)}
  accepts_nested_attributes_for :calentries, :allow_destroy=>true , :reject_if=> lambda{|a| a[:start].blank?}
  before_validation :sanitize
  def datum_nilsave
	self.datum.nil? ? Time.now + 42.years : self.datum
  end
  def public
	self.rubrik.public && self.datum_nilsave >=Time.now.to_date
  end
  def published?
   self.datum_nilsave>=Time.now.to_date
  end

  def publish
    self.datum = Date.today
  end
  def reverse_publish
    self.datum = nil
  end
 def name
self.title
end
  def text_first_words
    md = /<p>(?<text>[\w\s,\.!\?]*)/.match self.text
    md[:text].split(" ")[0..100].join(" ")+ " ..."
  end
def has_calentries?
!self.calentries.nil? && !self.calentries.empty?
end
private
def sanitize
self.calentries.each do |calentry|
calentry.calendar= self.rubrik.calendar
calentry.typ=1
calentry.object=self
end
end
end
