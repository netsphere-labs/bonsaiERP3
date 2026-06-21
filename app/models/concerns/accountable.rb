
# delegated_type :accountable の仮想的なサブクラスで include する
module Accountable
  extend ActiveSupport::Concern

  included do
    # `touch:` 関連づけられたオブジェクトの `updated_at` も更新される
    # 子レコード側 (Cash, Loan) を削除した場合も親レコードを削除したい場合は dependent: :destroy
    has_one :account, as: :accountable, touch: true, dependent: :destroy
  end
end
