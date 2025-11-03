
# author: Boris Barroso
# email: boriscyber@gmail.com

# 元の `Project` クラスは、単に経費を括るだけのもの。タスク管理・進捗管理も何も
# ない
# -> make new Production Order
class ProdOrder < Order

  # output item
  belongs_to :prod_item, class_name:"Item"
  
  validates_lengths_from_database
end
