
=begin
○継承元
Rails 6: ActiveRecord::Base は個別に各種モジュールを include.
  それと別に, ActiveModel::Model が定義されている
  module ActiveModel::Model = ActiveModel::AttributeAssignment +
                          ActiveModel::Validations +   # errors メソッド
                          ActiveModel::Conversion +
                          extend ActiveModel::Naming +
                          extend ActiveModel::Translation
Rails 7/8:
  元の ActiveModel::Model を ActiveModel::API に名称変更
  ActiveRecord::Base は ActiveModel::API を include したうえで, 追加モジュールを
  include.
  新しい ActiveModel::Model も ActiveModel::API を include して, 若干追加.
=> 結局, ActiveModel::Model を include するだけでいい

○型変換する。attr_accessor では型変換されない
class Person
  include ActiveModel::Attributes

  attribute :name, :string      <- type specified
  attribute :active, :boolean, default: true     <- default value specified
end

○ARレコードへの保存
単に ARClass.new FormObject.attributes のようにすると, 
  unknown attribute 'hoge' for Invoice. (ActiveModel::UnknownAttributeError)
モデルにない attribute を使いたいのでフォームオブジェクトを使うのだから,
このやり方ではない.  

フォームオブジェクトの Web 上のサンプルだと, 保存まで機能を持たせる例が見える:
 - `accepts_nested_attributes_for` は非推奨.
   例: https://moneyforward-dev.jp/entry/2018/12/15/formobject/
 - AR レコードをメソッドの引数として取って更新し, 明細レコードは new() だけ
   して返すのはアリか
 - `ActiveModel::Conversion#to_model` を実装する方法もある: 
class PostForm
  def initialize(attributes = nil, post: Post.new)   ここで ARオブジェクトを得る
    @post = post
    ...
  end

  def save  ARオブジェクトを保存
     ...

  def to_model; post end   ARオブジェクトを返す
end
=end


# フォームオブジェクト:
#  - ActiveRecord::Base でないクラスのインスタンスで、Validations の機能を使う。
#  - 文字列で飛んでくる値を型変換する
# TODO: 必要に応じて, メソッドを足しなおす.
class BaseForm
  # Both of Rails 6 and Rails 7/8
  include ::ActiveModel::Model

  # Rails 5.2-
  # `attribute` class method. `#attributes` プロパティ, `#attributes=` mass-assignment.
  # Rails 5.1 までの ActiveModel::AttributeMethods だと, attr_accessor と
  # define_attribute_methods を組み合わせていた.
  # gem virtus (後継の dry-core gem `Dry::Types::Struct` class) など似たようなライブラリが多数.
  include ::ActiveModel::Attributes

  # こっちも追加で必要。Ref 公式ドキュメント
  include ::ActiveModel::Validations::Callbacks  # before_validation()

=begin  
  # extend ActiveModel::Translation でもよいが。
  def self.human_attribute_name attribute, options = {}
    attribute.to_s
  end


  def [](key)
    instance_variable_get(key)
  end
=end
  
=begin
  ここで super を呼ばないといけないみたい.
    - @attributes.fetch_value(attr_name)
    - @attributes.write_from_user(attr_name, value)
  def initialize attributes = nil
    if attributes
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
=end
  
end
