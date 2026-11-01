
# 部門, 品目などの "軸" を表す
class TagGroup < ApplicationRecord
  has_many :tags
  
  validates :name, presence: true, length: { within: 2..100 }, uniqueness: true
  validates :bgcolor, presence: true
  
  scope :api, -> { select('id, name, tag_ids') }


  def to_s
    name
  end

  def to_api
    { id: id, name: name, tag_ids: tag_ids }
  end

end
