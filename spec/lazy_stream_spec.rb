require_relative 'spec_helper'

describe LazyStream do
  it "initializes an empty stream" do
    empty_stream = LazyStream.new
    empty_stream.should be_empty
  end

  it "returns the first element" do
    stream = LazyStream.new(1)
    stream.first.should == 1
  end

  it "has the rest as another lazy stream itself" do
    stream = LazyStream.new(1) { LazyStream.new(2) }
    stream.rest.first.should == 2
  end

  it "caches the rest" do
    cached = false
    rest = lambda do
      if !cached
        cached = true
        LazyStream.new(2)
      else
        raise Exception, "Did not cache"
      end
    end
    stream = LazyStream.new(1, &rest)
    stream.rest.first.should == 2
    stream.rest.first.should == 2
  end

  it "knows when it's not empty" do
    LazyStream.new(1).should_not be_empty
  end

  context "#[]" do
    it "returns nil when is empty" do
      LazyStream.new[0].should == nil
    end

    it "returns first for zero index" do
      LazyStream.new(1)[0].should == 1
    end

    it "returns from the rest for greater than zero indices" do
      stream = LazyStream.new(1) { LazyStream.new(2) }
      stream[1].should == 2
    end

    it "aliases to [] from at" do
      stream = LazyStream.new(1) { LazyStream.new(2) }
      stream.at(1).should == 2
    end
  end

  context "#drop" do
    it "returns the stream when it's empty" do
      stream = LazyStream.new
      stream.drop(10).should == stream
    end

    it "returns itself when nothing has been dropped" do
      stream = LazyStream.new(1)
      stream.drop(0).should == stream
    end

    it "returns the rest after dropping the first element" do
      stream = LazyStream.new(1) { LazyStream.new(2) }
      stream.drop(1).should == LazyStream.new(2)
    end
  end

  context "#each" do
    it "iterates through all elements in stream" do
      stream = LazyStream.new(1) { LazyStream.new(2) }
      elements = []
      stream.each { |element| elements << element }
      elements.should == [1, 2]
    end
  end

  context "#map" do
    it "maps the elements one at a time" do
      stream = LazyStream.new(1) { LazyStream.new(2) }
      mapped = stream.map do |item|
        item * 2
      end
      mapped.should == LazyStream.new(2) { LazyStream.new(4) }
    end
  end

  context "#select" do
    it "returns self if stream is empty" do
      stream = LazyStream.new
      selected = stream.select { |element| element % 2 == 0 }
      selected.should == stream
    end

    it "selects first when it only applies to it" do
      stream = LazyStream.new(2) { LazyStream.new(1) }
      selected = stream.select { |element| element % 2 == 0 }
      selected == LazyStream.new(2)
    end

    it "selects as longs as predicate applies" do
      stream = LazyStream.new(2) { LazyStream.new(4) }
      selected = stream.select { |element| element % 2 == 0 }
      selected.should == stream
    end
  end

  context "#take" do
    it "returns an empty steam if stream is empty" do
      stream = LazyStream.new
      stream.take(10).should be_empty
    end

    it "returns empty stream if n is less than one" do
      stream = LazyStream.new(1)
      stream.take(0).should == LazyStream.new
    end

    it "returns the first element for n equals 1" do
      stream = LazyStream.new(2)
      stream.take(1).should == stream
    end

    it "returns first & rest from rest when n is greater than 1" do
      stream = LazyStream.new(1) { LazyStream.new(2) }
      stream.take(2).should == stream
    end
  end

  context "#==" do
    it "is not equal with something other than LazyStream" do
      LazyStream.new.should_not == 2
    end

    it "is equal when both empty" do
      LazyStream.new.should == LazyStream.new
    end

    it "is equal when they both have single same element" do
      LazyStream.new(1).should == LazyStream.new(1)
    end

    it "is not equal when they have different first" do
      LazyStream.new(1).should_not == LazyStream.new(2)
    end

    it "is equal when first and rest are equal" do
      stream = LazyStream.new(1) { LazyStream.new(2) }
      stream.should == LazyStream.new(1) { LazyStream.new(2) }
    end

    it "is not equal when rests are not equal" do
      stream = LazyStream.new(1) { LazyStream.new(2) }
      stream.should_not == LazyStream.new(1) { LazyStream.new(3) }
    end
  end
end
