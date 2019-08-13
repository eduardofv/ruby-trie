
class TrieNode
  attr_accessor :value, :parent, :children, :freq, :eot #is end of term

  def initialize(value, freq, parent)
    @value = value
    @freq = freq
    @parent = parent
    @children = {}
    @eot = false
  end

  def add_value(str,freq)
    c = str[0..0]
    return if c==nil || c==""

    @freq += freq
    node = @children[c] || (@children[c]=TrieNode.new(c,freq,self))
    node.eot = true if str.length==1
    node.add_value(str[1..100],freq)
  end

  #regresa el nodo que mejor corresponde a la cadena
  def find_node_for(str)
    c = str[0..0]
    return nil if @value=="" and !@children.keys.include?(c)
    if @children.keys.include?(c)
        if( str.length<=1 )
	  ret = @children[c]
        else
          ret =  @children[c].find_node_for(str[1..100])
        end
    else
      ret = self
    end
    return ret
  end

  def strings(prefix="")
    return [{prefix=>@freq}] if @children.length==0 
    ret = eot ? [{prefix=>@freq}] : []
    return (@children.map{|k,n| n.strings(prefix+k)}+ret).flatten 
  end

  def show(prefix="",dump=false)
    str = "#{prefix},#{@freq}"
    puts(str) if dump
    if @children.length==0 or eot
      (puts(str) and return)
    end

    @children.each do |key,n| 
      n.show(prefix+key,dump)
    end
    return nil #solo para que en irb no me muestre todo el objeto otra vez
  end

  def normalize(max)
    #las frecuencias se convierten en probs
    @freq/=max
    @children.each{|k,n| n.normalize(max)}
  end 
  
end


class Trie
  attr_accessor :root

  def initialize
    @root = TrieNode.new('',0,nil)
  end

  def add_string(val,freq)
    @root.add_value(val,freq)
  end

  def normalize
    @root.normalize(@root.freq)
  end

  def show(complete=false)
    @root.show("",complete)
  end

  def suggest(str)
    @root.find_node_for(str).strings("#{str}").sort{|a,b| b.values[0]<=>a.values[0]}
  end

=begin
  def suggest_wc(str)
    @root.children.map{|k,n| n.find_node_for(str)}.each{|n| n.show}
    return nil
  end
=end

  def show_suggestions(str)
    puts suggest(str).map{|n| "#{n.keys[0]}\t#{n.values[0]}"}.join("\n")
  end

  def self.load_from_csv(filename)
    trie = Trie.new
    File.open(filename).each_line do |line|
      val,freq = line.chomp.split(",")
      trie.add_string val,freq.to_f
    end  
 
    trie.normalize

    return trie
  end

end
