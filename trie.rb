
class TrieNode
  attr_accessor :value,:parent, :children, :value

  def initialize(value,parent)
    @value = value
    @parent = parent
    @children = {}
  end

  def add_value(val)
    c = val[0..0]
    return if c==nil || c==""
    node = @children[c] || (@children[c]=TrieNode.new(c,self))
    node.add_value(val[1..100])
  end

  def find_node_for(str)
    c=str[0..0]

    if @value=="" #en raiz 
      if @children.keys.include?(c)
        return @children[c].find_node_for(str[1..100]) 
      else
        return self
      end
    end

    return self if c==nil || c=="" || !@children.keys.include?(c)

    return @children[c].find_node_for(str[1..100])
  end

  def strings(prefix="")
    return [prefix+@value] if @children.length==0
    @children.map{|n| n.strings(prefix+@value).flatten}
  end

  def show(prefix="")
    (puts(prefix+@value) and return) if @children.length==0
    @children.each do |key,n| 
      n.show(prefix+@value)
    end
    return nil #solo para que en irb no me muestre todo el objeto otra vez
  end
  
end


class Trie
  attr_accessor :root

  def initialize
    @root = TrieNode.new('',nil)
  end

  def add_string(val)
    @root.add_value(val)
  end

  def show
    @root.show
  end

  def suggest(str)
    @root.find_node_for(str).show("[#{str}]")
  end

  def self.load_from_csv(filename)
    trie = Trie.new
    File.open(filename).each_line do |line|
      val,freq = line.chomp.split(",")
      trie.add_string val
    end  

    return trie
  end

end
