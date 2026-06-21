
class BomStructure < ApplicationRecord
  belongs_to :parent, class_name: "Item"

  # "Order BoM". If NULL, template BoM
  belongs_to :sales_order, class_name:"Order", optional:true
  
  # oneOf:
  belongs_to :child_item, class_name: "Item", optional: true
  belongs_to :child_res, class_name: "Resource", optional: true
  
  enum :child_type, {item: 1, resource: 2, text: 3}

  validates_presence_of :qty
end
