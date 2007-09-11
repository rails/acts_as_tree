require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'fixtures/mixin')

class TreeTest < Test::Unit::TestCase
  fixtures :mixins

  def test_children
    assert_equal mixins(:tree_1).children, mixins(:tree_2, :tree_4)
    assert_equal mixins(:tree_2).children, [mixins(:tree_3)]
    assert_equal mixins(:tree_3).children, []
    assert_equal mixins(:tree_4).children, []
  end

  def test_parent
    assert_equal mixins(:tree_2).parent, mixins(:tree_1)
    assert_equal mixins(:tree_2).parent, mixins(:tree_4).parent
    assert_nil mixins(:tree_1).parent
  end

  def test_delete
    assert_equal 6, TreeMixin.count
    mixins(:tree_1).destroy
    assert_equal 2, TreeMixin.count
    mixins(:tree2_1).destroy
    mixins(:tree3_1).destroy
    assert_equal 0, TreeMixin.count
  end

  def test_insert
    @extra = mixins(:tree_1).children.create

    assert @extra

    assert_equal @extra.parent, mixins(:tree_1)

    assert_equal 3, mixins(:tree_1).children.size
    assert mixins(:tree_1).children.include?(@extra)
    assert mixins(:tree_1).children.include?(mixins(:tree_2))
    assert mixins(:tree_1).children.include?(mixins(:tree_4))
  end

  def test_ancestors
    assert_equal [], mixins(:tree_1).ancestors
    assert_equal [mixins(:tree_1)], mixins(:tree_2).ancestors
    assert_equal mixins(:tree_2, :tree_1), mixins(:tree_3).ancestors
    assert_equal [mixins(:tree_1)], mixins(:tree_4).ancestors
    assert_equal [], mixins(:tree2_1).ancestors
    assert_equal [], mixins(:tree3_1).ancestors
  end

  def test_root
    assert_equal mixins(:tree_1), TreeMixin.root
    assert_equal mixins(:tree_1), mixins(:tree_1).root
    assert_equal mixins(:tree_1), mixins(:tree_2).root
    assert_equal mixins(:tree_1), mixins(:tree_3).root
    assert_equal mixins(:tree_1), mixins(:tree_4).root
    assert_equal mixins(:tree2_1), mixins(:tree2_1).root
    assert_equal mixins(:tree3_1), mixins(:tree3_1).root
  end

  def test_roots
    assert_equal mixins(:tree_1, :tree2_1, :tree3_1), TreeMixin.roots
  end

  def test_siblings
    assert_equal mixins(:tree2_1, :tree3_1), mixins(:tree_1).siblings
    assert_equal [mixins(:tree_4)], mixins(:tree_2).siblings
    assert_equal [], mixins(:tree_3).siblings
    assert_equal [mixins(:tree_2)], mixins(:tree_4).siblings
    assert_equal mixins(:tree_1, :tree3_1), mixins(:tree2_1).siblings
    assert_equal mixins(:tree_1, :tree2_1), mixins(:tree3_1).siblings
  end

  def test_self_and_siblings
    assert_equal mixins(:tree_1, :tree2_1, :tree3_1), mixins(:tree_1).self_and_siblings
    assert_equal mixins(:tree_2, :tree_4), mixins(:tree_2).self_and_siblings
    assert_equal [mixins(:tree_3)], mixins(:tree_3).self_and_siblings
    assert_equal mixins(:tree_2, :tree_4), mixins(:tree_4).self_and_siblings
    assert_equal mixins(:tree_1, :tree2_1, :tree3_1), mixins(:tree2_1).self_and_siblings
    assert_equal mixins(:tree_1, :tree2_1, :tree3_1), mixins(:tree3_1).self_and_siblings
  end           
end

class TreeTestWithEagerLoading < Test::Unit::TestCase
  fixtures :mixins
    
  def test_eager_association_loading
    roots = TreeMixin.find(:all, :include=>"children", :conditions=>"mixins.parent_id IS NULL", :order=>"mixins.id")
    assert_equal mixins(:tree_1, :tree2_1, :tree3_1), roots
    assert_no_queries do
      assert_equal 2, roots[0].children.size
      assert_equal 0, roots[1].children.size
      assert_equal 0, roots[2].children.size
    end
  end
  
  def test_eager_association_loading_with_recursive_cascading_three_levels_has_many
    root_node = RecursivelyCascadedTreeMixin.find(:first, :include=>{:children=>{:children=>:children}}, :order => 'mixins.id')
    assert_equal mixins(:recursively_cascaded_tree_4), assert_no_queries { root_node.children.first.children.first.children.first }
  end

  def test_eager_association_loading_with_recursive_cascading_three_levels_has_one
    root_node = RecursivelyCascadedTreeMixin.find(:first, :include=>{:first_child=>{:first_child=>:first_child}}, :order => 'mixins.id')
    assert_equal mixins(:recursively_cascaded_tree_4), assert_no_queries { root_node.first_child.first_child.first_child }
  end

  def test_eager_association_loading_with_recursive_cascading_three_levels_belongs_to
    leaf_node = RecursivelyCascadedTreeMixin.find(:first, :include=>{:parent=>{:parent=>:parent}}, :order => 'mixins.id DESC')
    assert_equal mixins(:recursively_cascaded_tree_1), assert_no_queries { leaf_node.parent.parent.parent }
  end
end

class TreeTestWithoutOrder < Test::Unit::TestCase
  fixtures :mixins

  def test_root
    assert mixins(:tree_without_order_1, :tree_without_order_2).include?(TreeMixinWithoutOrder.root)
  end

  def test_roots
    assert_equal [], mixins(:tree_without_order_1, :tree_without_order_2) - TreeMixinWithoutOrder.roots
  end
end