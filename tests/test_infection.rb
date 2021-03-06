require 'test/unit'
require './user.rb'
require './infection.rb'
require 'pry'

class TestInfection < Test::Unit::TestCase

  def test_total_infection
    t = User.new
    users = create_class t

    # test teachers infecting students
    total_infection t, 2
    assert_true check_version users, 2

    # test students infecting teachers
    total_infection t.coaches.last, 3
    assert_true check_version users, 3
  end

  def test_limited_infection_simple
    t = User.new
    users = create_class t

    # test too small limit
    limited_infection t, 2, (users.length - 1)
    assert_false check_version users, 2
    # what else should be the outcome?

    # test exact limit
    limited_infection t, 3, users.length
    assert_true check_version users, 3

    # test students infecting teachers
    limited_infection t.coaches.first, 4, users.length
    assert_true check_version users, 4
  end

  def test_limited_infection_double
    t1 = User.new
    c1 = create_class t1
    t2 = User.new
    c2 = create_class t2

    # one student taking 2 classes
    student = t2.coaches.first
    t1.add_student student
    users = c1 + c2

    # test double infection
    limited_infection student, 2, users.length
    assert_true check_version users, 2
  end

  def test_limited_infection_chain
    t1 = User.new
    c1 = create_class t1, 3
    # one student teaching another class
    c2 = create_class c1.last, 3
    users = c1 + c2
    users.uniq!

    limited_infection t1, 2, users.length
    assert_true check_version users, 2

    limit = 4
    limited_infection t1, 3, limit
    v = user_versions_assoc users
    assert_equal v[3], (limit - 1)
  end

  def test_zero_limit
    t1 = User.new
    t2 = User.new
    t1.add_student t2
    users = create_class t2
    users.push t1

    limited_infection t1, 2, 1
    assert_true check_version users, 1

    limited_infection t2, 2, 0
    assert_true check_version users, 1
  end

  # helper functions
  def create_class t, size = 10
    users = []
    users << t
    size.times do
      u = User.new
      t.add_student u 
      users << u
    end
    return users
  end

  def check_version users, version
    good = true
    for u in users
      if u.version != version
        good = false
        break
      end
    end

    return good
  end

  def user_versions_assoc users
    hash = {}
    users.each do |user|
      k = user.version
      if hash.has_key? k
        hash[k] += 1
      else
        hash[k] = 1
      end
    end
    return hash
  end
end
