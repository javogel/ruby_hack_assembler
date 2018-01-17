require './lib/dictionaries/hack_dictionary.rb'


class Assembler
  include HackDictionary

  def initialize(file)
    @addresses = ADDRESSES.clone
    @current_memory = 16
    @filename = file
    @clean_lines = begin_read(file)
    @desymbolized = desymbolize(@clean_lines)
    @binary = decode_pass(@desymbolized)
    write_binary
  end

  def begin_read(file)
    read_file(file) do |content|
      lines = content.split("\n")
      return clean_map(lines)
    end
  end

  def read_file(filename, &block)
    content = get_content(filename)
    yield(content)
    fh.close
  end

  def get_content(filename)
    fh = open filename
    content = fh.read
  end

  def clean_map(lines)
    lines.map do |l|
      line = clean_line(l)
      line.size == 0 ? nil : line
    end.compact
  end

  def clean_line(l)
    line = remove_comments(l)
    line.gsub(/\r/, '').gsub(' ', '')
  end

  def remove_comments(l)
    i = l.index("//")
    i ? l[0...i] : l
  end


  def decode_pass(lines)
    lines.map do |x|
      decode_line(x)
    end
  end

  def decode_line(str)
    if str[0] == "@"
       address = str[1..-1]
       address_to_binary(address)
    else
       instruction_to_binary(str)
    end
  end

  def address_to_binary(a)
    "%016b" % a
  end

  def instruction_to_binary(instruction)
    split_jmp = instruction.split(/[;]/)
    dest_comp = split_jmp[0].split(/[=]/)
    get_inst_binary(dest: dest_comp.length > 1 ? dest_comp[0] : nil,
                    comp: dest_comp.length > 1 ? dest_comp[1] : dest_comp[0],
                    jmp:  split_jmp.length > 1 ? split_jmp[-1] : nil)
  end

  def get_inst_binary(dest:, comp:, jmp:)

    ["111",
    get_comp_binary(comp),
    get_dest_binary(dest),
    get_jmp_binary(jmp)
    ].join('')
  end

  def get_dest_binary(dest)
    d = [dest.index("A") ? 1 : 0,
     dest.index("D") ? 1 : 0,
     dest.index("M") ? 1 : 0].join("") if dest
     d || "000"
  end

  def get_comp_binary(comp)
    c = comp.to_sym
    a0 = "0" + COMPUTATION_TABLE_A0[c] if COMPUTATION_TABLE_A0[c]
    a1 = "1" + COMPUTATION_TABLE_A1[c] if COMPUTATION_TABLE_A1[c]
    a0 || a1
  end

  def get_jmp_binary(jmp)
    s = jmp.to_sym if jmp
    j = JMP_TABLE[s] if JMP_TABLE[s]
    j || "000"
  end

  def write_binary
    name = @filename.split("/")[-1].split(".asm")[0]
    File.open(name + ".hack", "w+") do |f|
      f.puts(@binary)
    end
  end

  def desymbolize(arr)
    @instruction = 0
    arr.each do |line|
      map_placeholders(line)
    end

    arr.map do |l|
      decode_symbols(l)
    end.compact
  end


  def map_placeholders(str)
    if str[0] == "("
       map_ph(str[1..-2])
    else
      @instruction = @instruction + 1
    end
  end

  def map_ph(name)
    new_address(name, @instruction)
  end

  def decode_symbols(str)
    if  str[0] == "@"
       "@" + map_address(str[1..-1]).to_s
    elsif str[0] == "("
      nil
    else
      str
    end
  end

  def map_address(a)
    return a if a.match(/^(\d)+$/)
    address = @addresses[a.to_sym]
    new_address = address || new_address(a, next_memory - 1)
  end

  def new_address(a, memory)
    @addresses.merge!(a.to_sym => memory)
    memory
  end

  def next_memory
    @current_memory = @current_memory + 1
  end

end
