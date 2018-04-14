module Regexp::Expression

  class Subexpression < Regexp::Expression::Base
    attr_accessor :expressions

    def initialize(token, options = {})
      super

      @expressions = []
    end

    # Override base method to clone the expressions as well.
    def clone
      copy = super
      copy.expressions = @expressions.map {|e| e.clone }
      copy
    end

    def <<(exp)
      if exp.is_a?(WhiteSpace) and @expressions.last and
        @expressions.last.is_a?(WhiteSpace)
        @expressions.last.merge(exp)
      else
        @expressions << exp
      end
    end

    def insert(exp)
      @expressions.insert 0, exp
    end

    %w[[] all? any? at count each each_with_index empty?
       fetch find first index join last length values_at].each do |m|
      define_method(m) { |*args, &block| expressions.send(m, *args, &block) }
    end

    def te
      ts + to_s.length
    end

    def to_s(format = :full)
      s = ''

      # Note: the format does not get passed down to subexpressions.
      case format
      when :base
        s << @text.dup
        s << @expressions.map{|e| e.to_s}.join unless @expressions.empty?
      else
        s << @text.dup
        s << @expressions.map{|e| e.to_s}.join unless @expressions.empty?
        s << @quantifier if quantified?
      end

      s
    end

    def to_h
      h = super
      h[:text] = to_s(:base)
      h[:expressions] = @expressions.map(&:to_h)
      h
    end
  end

end
