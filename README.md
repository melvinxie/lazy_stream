lazy_stream
===========

A Ruby class to represent lazy infinite stream.
It is implemented in the same way as the streams in the book [SICP]
(http://mitpress.mit.edu/sicp/full-text/sicp/book/node69.html).

## Usage

A stream is just a delayed list. We do lazy evaluation in Ruby with code blocks.
To create a stream:

    s = lazy_stream(1) { lazy_stream(2) { lazy_stream(3) } }
    s.to_a   #=> [1, 2, 3]
    s.first  #=> 1
    s.rest   #=> A LazyStream object for the rest of the list

Methods empty?, at, drop, each, map, reduce, select, take are also implemented
like Array.

It becomes powerful when we construct infinite streams like these:

    def integers_starting_from(n)
      lazy_stream(n) { integers_starting_from(n + 1) }
    end

    def fibgen(a, b)
      lazy_stream(a) { fibgen(b, a + b) }
    end

    def sieve(stream)
      lazy_stream(stream.first) do
        sieve(stream.rest.select { |x| x % stream.first > 0 })
      end
    end

    def primes
      sieve(integers_starting_from(2))
    end

## Installation
The library is distributed via [RubyGems](http://rubygems.org/):

    $ gem install lazy_stream

## Author
[Mingmin Xie](http://github.com/melvinxie)
