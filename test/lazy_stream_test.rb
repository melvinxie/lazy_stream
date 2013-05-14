require 'test/unit'
require 'lazy_stream'

class LazyStreamTest < Test::Unit::TestCase
  def test_new
    assert lazy_stream.empty?
    assert_equal [1, 2], lazy_stream(1) { lazy_stream(2) { lazy_stream } }.to_a
    assert_equal [1, 2, 3],
                 lazy_stream(1) { lazy_stream(2) { lazy_stream(3) } }.to_a
  end

  def integers_starting_from(n)
    lazy_stream(n) { integers_starting_from(n + 1) }
  end

  def test_integers
    integers = integers_starting_from(1)
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], integers.take(10).to_a
    assert_equal 55, integers.take(10).reduce(&:+)
    no_sevens = integers_starting_from(1).select { |i| i % 7 > 0 }
    assert_equal [1, 2, 3, 4, 5, 6, 8, 9, 10, 11], no_sevens.take(10).to_a
  end

  def fibgen(a, b)
    lazy_stream(a) { fibgen(b, a + b) }
  end

  def test_fibgen
    assert_equal [0, 1, 1, 2, 3, 5, 8, 13, 21, 34], fibgen(0, 1).take(10).to_a
  end

  def sieve(stream)
    lazy_stream(stream.first) do
      sieve(stream.rest.select { |x| x % stream.first > 0 })
    end
  end

  def test_primes
    primes = sieve(integers_starting_from(2))
    assert_equal [2, 3, 5, 7, 11, 13, 17, 19, 23, 29], primes.take(10).to_a
  end

  def test_implicit_integers
    ones = lazy_stream(1) { ones }
    assert_equal [1, 1, 1, 1, 1, 1, 1, 1, 1, 1], ones.take(10).to_a
    integers = lazy_stream(1) { LazyStream.add(ones, integers) }
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], integers.take(10).to_a
  end

  def test_implicit_fibs
    fibs = lazy_stream(0) { lazy_stream(1) { LazyStream.add(fibs.rest, fibs) } }
    assert_equal [0, 1, 1, 2, 3, 5, 8, 13, 21, 34], fibs.take(10).to_a
  end

  def prime?(n)
    iter = -> ps do
      if ps.first**2 > n
        true
      elsif n % ps.first == 0
        false
      else
        iter.call(ps.rest)
      end
    end
    iter.call(@primes)
  end

  def test_implicit_primes
    @primes = lazy_stream(2) do
      integers_starting_from(3).select(&method(:prime?))
    end
    assert_equal [2, 3, 5, 7, 11, 13, 17, 19, 23, 29], @primes.take(10).to_a
  end

  def enumerate_interval(low, high)
    low > high ? lazy_stream :
                 lazy_stream(low) { enumerate_interval(low + 1, high) }
  end

  def prime_enumerate_interval(low, high)
    enumerate_interval(low, high).select(&method(:prime?))
  end

  def test_interval
    @primes = lazy_stream(2) do
      integers_starting_from(3).select(&method(:prime?))
    end
    assert_equal [11, 13, 17, 19, 23, 29], prime_enumerate_interval(10, 30).to_a
    assert_equal 73434270, prime_enumerate_interval(10000, 40000).reduce(&:+)
  end

  def sqrt_improve(guess, x)
    (guess + x / guess) / 2
  end

  def sqrt_stream(x)
    guesses = lazy_stream(1.0) do
      guesses.map { |guess| sqrt_improve(guess, x) }
    end
  end

  def test_sqrt
    assert_equal [1.0, 1.5, 1.4166666666666665, 1.4142156862745097,
                  1.4142135623746899],
                  sqrt_stream(2).take(5).to_a
  end

  def pi_summands(n)
    lazy_stream(1.0 / n) { pi_summands(n + 2).map(&:-@) }
  end

  def pi_stream
    pi_summands(1).partial_sums.scale(4)
  end

  def test_pi_stream
    assert_equal [4.0, 2.666666666666667, 3.466666666666667, 2.8952380952380956,
                  3.3396825396825403, 2.9760461760461765, 3.2837384837384844,
                  3.017071817071818],
                  pi_stream.take(8).to_a
  end

  def euler_transform(s)
    lazy_stream(s[2] - ((s[2] - s[1])**2 / (s[0] - 2 * s[1] + s[2]))) do
      euler_transform(s.rest)
    end
  end

  def test_euler_transform
    assert_equal [3.166666666666667, 3.1333333333333337, 3.1452380952380956,
                  3.13968253968254, 3.1427128427128435, 3.1408813408813416,
                  3.142071817071818, 3.1412548236077655],
                  euler_transform(pi_stream).take(8).to_a
  end

  def make_tableau(s, &transform)
    lazy_stream(s) { make_tableau(transform.call(s), &transform) }
  end

  def accelerated_sequence(s, &transform)
    make_tableau(s, &transform).map(&:first)
  end

  def test_accelerated_sequence
    assert_equal [4.0, 3.166666666666667, 3.142105263157895, 3.141599357319005,
                  3.1415927140337785, 3.1415926539752927, 3.1415926535911765,
                  3.141592653589778],
                  accelerated_sequence(pi_stream, &method(:euler_transform))
                      .take(8).to_a
  end

  def pairs(s, t)
    lazy_stream([s.first, t.first]) do
      LazyStream.interleave(t.rest.map { |x| [s.first, x] },
                        pairs(s.rest, t.rest))
    end
  end

  def test_pairs
    integers = integers_starting_from(1)
    assert_equal [[1, 1], [1, 2], [2, 2], [1, 3], [2, 3]],
                 pairs(integers, integers).take(5).to_a
  end

  def integral(integrand, initial, dt)
    int = lazy_stream(initial) { LazyStream.add(integrand.call.scale(dt), int) }
  end

  def solve(f, y0, dt)
    y = integral(lambda { y.map(&f) }, y0, dt)
  end

  def test_solve
    assert_equal 2.716923932235896, solve(lambda { |y| y }, 1, 0.001).at(1000)
  end
end
