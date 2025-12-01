
# delegated_type :accountable の仮想的なサブクラスで include する
module Accountable
  extend ActiveSupport::Concern

  included do
    # `touch:` 関連づけられたオブジェクトの `updated_at` も更新される
    has_one :account, as: :accountable, touch: true
  end
end
