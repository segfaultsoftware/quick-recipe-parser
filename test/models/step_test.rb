require "test_helper"

class StepTest < ActiveSupport::TestCase
  test "valid step" do
    step = steps(:one)
    assert step.valid?
  end

  test "requires body" do
    step = Step.new(recipe: recipes(:one), position: 0, body: "")
    assert_not step.valid?
    assert_includes step.errors[:body], "can't be blank"
  end

  test "requires position" do
    step = Step.new(recipe: recipes(:one), body: "Do something", position: nil)
    assert_not step.valid?
    assert_includes step.errors[:position], "can't be blank"
  end

  test "position must be an integer" do
    step = Step.new(recipe: recipes(:one), body: "Do something", position: 1.5)
    assert_not step.valid?
    assert_includes step.errors[:position], "must be an integer"
  end

  test "position must be non-negative" do
    step = Step.new(recipe: recipes(:one), body: "Do something", position: -1)
    assert_not step.valid?
    assert_includes step.errors[:position], "must be greater than or equal to 0"
  end

  test "belongs to recipe" do
    step = steps(:one)
    assert_equal recipes(:one), step.recipe
  end

  test "destroyed with recipe" do
    recipe = recipes(:one)
    step_ids = recipe.steps.pluck(:id)
    assert step_ids.any?

    recipe.destroy
    step_ids.each do |id|
      assert_nil Step.find_by(id: id)
    end
  end

  test "recipe steps are ordered by position" do
    recipe = recipes(:one)
    positions = recipe.steps.pluck(:position)
    assert_equal positions.sort, positions
  end
end
