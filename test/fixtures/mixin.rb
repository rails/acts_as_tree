class Mixin < ActiveRecord::Base
end

class TreeMixin < Mixin 
  acts_as_tree :foreign_key => "parent_id", :order => "id"
end

class TreeMixinWithoutOrder < Mixin
  acts_as_tree :foreign_key => "parent_id"
end

class RecursivelyCascadedTreeMixin < Mixin
  acts_as_tree :foreign_key => "parent_id"
  has_one :first_child, :class_name => 'RecursivelyCascadedTreeMixin', :foreign_key => :parent_id
end
