
class Resource < ApplicationRecord
  belongs_to :unit

  RES_TYPES = {machine: 1, labor: 2, other: 3}
  enum :res_type, RES_TYPES

  validates_presence_of :name
  
end
