class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  easy_roles :roles
  
  scope :with_role, proc { |r|
    query = "#{self.table_name}.roles LIKE " + ['\'%',r,'%\''].join
    where(query)
  }
end
