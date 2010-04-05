
#
# This application translates chord symbols to the notes they comprise
#
# Notation:
#   sharp symbol is #
#   flat symbol is b
# 
# Here is an attempt to write the chord symbol syntax using the BNF grammar notation
#
#  chord         ::= root [quality] [extension] ['(' alternation ')']
#  root          ::= note | slashed-root
#  note          ::= simple-note | sharped-note | flatted-node
#  simple-note   ::= 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'G'
#  sharped-note  ::= 'A#' | 'B#' | 'C#' | 'D#' | 'E#' | 'F#' | 'G#'
#  flatted-note  ::= 'Ab' | 'Bb' | 'Cb' | 'Db' | 'Eb' | 'Fb' | 'Gb'
#  slashed-root  ::= note '/' note
#  quality       ::= 'maj'
#                  | '-' | 'min' | 'mi' | 'm'
#                  | '°' | 'dim' | 'd' 
#                  | '+' | 'aug'
#                  | 'sus2' | '2'
#                  | 'sus' | 'sus4' | '4'
#                  | '5'
#  extension     ::= 'add' | '4' | '6' | '7' | '9' | '11' | '13'
#  alternation   ::= ['#' | 'b'] <integer-number>
#
# This implementation does not support:
#   * slashed chords like C/G (C is the chord root and G indicates it should appear in the bass)
#   * alternations
#   * only seventh (7) and ninth (9)(in extension)
#
# We use the piano keyboard approach :
#
# |  1  |   2   | 3 | 4 |    5   | 6 |    7   | 8 |  9 |    10  |  11 |    12
# |     | A#/Bb |   |   |  C#/Db |   |  D#/Eb |   |    |  F#/Gb |     |  G#/Ab
# |  A  |       | B | C |        | D |        | E |  F |        |  G  |
# |     |       |   |   |        |   |        |   |    |        |     |
#
#


# Music theory expresses the distance between the pitches of two notes
# as an interval. The distance has two parts the number of scale steps
# and the number of semitones
#
#       name           number      semitones
#                                  of steps
#   perfect unison        0            0
#   minor second          1            1
#   major second          1            2
#   minor third           2            3
#   major third           2            4
#   perfect fourth        3            5
#   augmented fourth      3            6
#   diminished fifth
#   perfect fifth         4            7
#   minor sixth           5            8
#   major sixth           5            9
#   minor seventh         6           10
#   major seventh         6           11
#   perfect octave        7            8
#
class Interval
  
  attr_reader :number, :semitones
  
  def initialize number, semitones
    @number, @semitones = number, semitones
  end
  
end

class Note

  attr_accessor :unison
  attr_reader :note, :pitch, :index
  
  def initialize name
    
    raise ArgumentError, "Invalid note: #{name}" unless name =~ /([A-G])([#b]{0,1})/
    
    @name = name
    
    @note = $1
    @pitch = $2
    @index = $1[0] - "A"[0]
    
  end
  
  def to_s
    @name
  end
  
  def inspect
    "#{@name} - #{@index}"
  end
  
end

A = Note.new('A')
B = Note.new('B')
C = Note.new('C')
D = Note.new('D')
E = Note.new('E')
F = Note.new('F')
G = Note.new('G')

As = Note.new('A#')
Bs = Note.new('B#')
Cs = Note.new('C#')
Ds = Note.new('D#')
Es = Note.new('E#')
Fs = Note.new('F#')
Gs = Note.new('G#')

Ab = Note.new('Ab')
Bb = Note.new('Bb')
Cb = Note.new('Cb')
Db = Note.new('Db')
Eb = Note.new('Eb')
Fb = Note.new('Fb')
Gb = Note.new('Gb')

def unison
  Interval.new(0, 0)
end

def minor_second
  Interval.new(1, 1)
end
def major_second
  Interval.new(1, 2)
end

def minor_third
  Interval.new(2, 3)
end
def major_third
  Interval.new(2, 4)
end

def minor_fourth
  Interval.new(3, 5)
end
def major_fourth
  Interval.new(3, 5)
end

def minor_fifth
  Interval.new(4, 7)
end
def major_fifth
  Interval.new(4, 7)
end
def augmented_fifth
  Interval.new(4, 8)
end
def diminished_fifth
  Interval.new(4, 6)
end

def minor_sixsth
  Interval.new(5, 8)
end
def major_sixsth
  Interval.new(5, 9)
end

def minor_seventh
  Interval.new(6, 10)
end
def major_seventh
  Interval.new(6, 11)
end

def octave
  Interval.new(7, 12)
end

def minor_ninth
  Interval.new(8, 14)
end
def major_ninth
  Interval.new(8, 14)
end

class Note
  
  NOTES = [A, B, C, D, E, F, G]
  FLATS = [Ab, Bb, Cb, Db, Eb, Fb, Gb]
  SHARPS = [As, Bs, Cs, Ds, Es, Fs, Gs]
  SEMITONES = [Ab, A, Bb, B, C, Db, D, Eb, E, F, Gb, G]
  
  def self.to_note name, pitch = nil
    
    i = name[0] - "A"[0]
    
    if pitch == '#'
      SHARPS[i]
    elsif pitch == 'b'
      FLATS[i]
    else
      NOTES[i]
    end
    
  end
  
  def + interval

    this = self.pitch == '#' ? self.unison : self
    
    i_tone = (SEMITONES.index(this) + interval.semitones).modulo(SEMITONES.length)
    i_note = (@index + interval.number).modulo(NOTES.length)

    result = SEMITONES[i_tone]
    if NOTES[i_note].note != result.note
      result = result.unison if result.unison
    end
    
    result
    
  end
  
  def - interval
    
    this = self.pitch == '#' ? self.unison : self
    
    i_tone = (SEMITONES.index(this) - interval.semitones).modulo(SEMITONES.length)
    i_note = (@index - interval.number).modulo(NOTES.length)
    
    result = SEMITONES[i_tone]
    if NOTES[i_note].note != result.note
      result = result.unison if result.unison
    end
    
    result
    
  end

  As.unison = Bb
  Cs.unison = Db
  Ds.unison = Eb
  Fs.unison = Gb
  Gs.unison = Ab

  Ab.unison = Gs
  Bb.unison = As
  Db.unison = Cs
  Eb.unison = Ds
  Gb.unison = Fs

  C.unison = Bs
  Bs.unison = C
  B.unison = Cb
  Cb.unison = B
  
  E.unison = Fb
  Fb.unison = E
  Es.unison = F
  F.unison = Es
  
end

class Chord
  
  attr_reader :number_of_notes
  attr_reader :chord_root, :quality, :extension
  
  def initialize chord_symbol
    
    raise ArgumentError.new("Chord symbol cannot be nil") unless @buffer.nil?
    
    chord_symbol = chord_symbol.to_s
    
    @chord_symbol = chord_symbol
    
    if @chord_symbol =~ /^([A-G])([#b]{0,1})(maj|m|mi|min|-|°|dim|d|\+|aug|sus|sus2|2|sus4|4){0,1}([7,9]{0,1})$/
      
      @chord_root = Note.to_note($1, $2)
      
      @quality = case $3
      when nil, 'maj'
        :major
      when '-', 'mi', 'm', 'min'
        :minor
      when '+', 'aug'
        :augmented
      when '°', 'dim', 'd'
        :diminished
      when '2', 'sus2'
        :sus2
      when '4', 'sus4', 'sus'
        :sus4
      end
      
      @extension = $4
      
      @number_of_notes = case @extension
      when '7'
        4
      when '9'
        5
      else
        3
      end
      
    else
      raise ArgumentError.new("Invalid chord symbol: #{@chord_symbol}")
    end
    
  end

  RULES = { 
    :major      => [unison,  major_third,      major_fifth, major_seventh, major_ninth],
    :minor      => [unison,  minor_third,      minor_fifth, minor_seventh, minor_ninth],
    :augmented  => [unison,  major_third,  augmented_fifth, minor_seventh, minor_ninth],
    :diminished => [unison,  minor_third, diminished_fifth,  major_sixsth, major_ninth],
    :sus2       => [unison, major_second,      major_fifth, major_seventh, major_ninth],
    :sus4       => [unison, major_fourth,      major_fifth, major_seventh, major_ninth]
  }
  
  def to_a
    
    chord = RULES[@quality].collect do |interval|
       @chord_root + interval
    end
     
    chord[0..@number_of_notes - 1]
    
  end
  
end

if $0 == __FILE__
  
  if ARGV[0]
    
    ARGV.each do |chord|
      puts "#{chord} => #{Chord.new(chord).to_a.join(' ')}"
    end
    
  else
    
    puts "Enter a chords or 'quit': "
    
    loop do
      
      chord = $stdin.gets
      
      break if chord.nil? or chord.strip! == 'quit'
      
      begin
        puts "#{chord} => #{Chord.new(chord).to_a.join(' ')}"
      rescue ArgumentError => e
        puts e
      end
      
    end
    
  end
  
end
