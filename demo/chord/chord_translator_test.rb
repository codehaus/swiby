require 'test/unit'
require 'chord_translator'

class TestNoteArithmetic < Test::Unit::TestCase
  
  def test_adding_intervals

    assert_equal C, C + unison
    
    assert_equal D, C + major_second
    assert_equal Db, C + minor_second
    
    assert_equal E, C + major_third
    assert_equal C, A + minor_third
    assert_equal C, Ab + major_third
    
    assert_equal G, C + major_fifth
    assert_equal E, A + minor_fifth
    
    assert_equal Cb, Ab + minor_third
    assert_equal Cs, As + minor_third
    
    assert_equal Gs, C + augmented_fifth
    assert_equal Gb, C + diminished_fifth
    assert_equal A, Eb + diminished_fifth
    
    assert_equal D, C + major_ninth
    
  end
  
  def test_subtracting_intervals
    
    assert_equal C, D - major_second
    assert_equal C, Db - minor_second
    
    assert_equal C, E - major_third
    assert_equal A, C - minor_third
    assert_equal Ab, C - major_third
    
    assert_equal C, G - major_fifth
    assert_equal A, E - minor_fifth
    
  end
  
end

class TestParsingChordSymbols < Test::Unit::TestCase
  
  def test_major_chord
    
    chord = Chord.new('C')
    
    assert_equal C, chord.chord_root
    assert_equal :major, chord.quality
    
    chord = Chord.new('Abmaj')
    
    assert_equal Ab, chord.chord_root
    assert_equal :major, chord.quality
    
    ['C', 'Cmaj'].each do |chord_symbol|
      
      chord = Chord.new(chord_symbol)
    
      assert_equal C, chord.chord_root
      assert_equal :major, chord.quality
      
    end
    
  end
  
  def test_minor_chord
    
    chord = Chord.new('Emin')
    
    assert_equal E, chord.chord_root
    assert_equal :minor, chord.quality
    
    chord = Chord.new('D-')
    
    assert_equal D, chord.chord_root
    assert_equal :minor, chord.quality
    
    chord = Chord.new('Dm')
    
    assert_equal D, chord.chord_root
    assert_equal :minor, chord.quality
    
    chord = Chord.new('F#-')
    
    assert_equal Fs, chord.chord_root
    assert_equal :minor, chord.quality
    
    ['A-', 'Am', 'Amin'].each do |chord_symbol|
      
      chord = Chord.new(chord_symbol)
    
      assert_equal A, chord.chord_root
      assert_equal :minor, chord.quality
      
    end
  
  end
  
  def test_augmented_chord
    
    ['A+', 'Aaug'].each do |chord_symbol|
      
      chord = Chord.new(chord_symbol)
    
      assert_equal A, chord.chord_root
      assert_equal :augmented, chord.quality
      
    end
  
  end
  
  def test_diminished_chord
    
    ['D°', 'Dd', 'Ddim'].each do |chord_symbol|
      
      chord = Chord.new(chord_symbol)
    
      assert_equal D, chord.chord_root
      assert_equal :diminished, chord.quality
      
    end
  
  end
  
  def test_suspended_chord
    
    chord = Chord.new('C2')
    
    assert_equal C, chord.chord_root
    assert_equal :sus2, chord.quality
    
    ['C2', 'Csus2'].each do |chord_symbol|
      
      chord = Chord.new(chord_symbol)
    
      assert_equal C, chord.chord_root
      assert_equal :sus2, chord.quality
      
    end
  
    ['C4', 'Csus4'].each do |chord_symbol|
      
      chord = Chord.new(chord_symbol)
    
      assert_equal C, chord.chord_root
      assert_equal :sus4, chord.quality
      
    end
  
  end

  def test_seventh_chord
    
    chord = Chord.new('Ebdim7')
    
    assert_equal Eb, chord.chord_root
    assert_equal :diminished, chord.quality
    assert_equal '7', chord.extension
    
  end
  
  #'Gmin7b5'
  
end

class TestTranslator < Test::Unit::TestCase
  
  def test_major_chord
    
    chord = Chord.new('C')
    assert_equal [C, E, G], chord.to_a
    
    chord = Chord.new('Abmaj')
    assert_equal [Ab, C, Eb], chord.to_a
    
  end
  
  def test_minor_chord
    
    chord = Chord.new('Cmin')
    assert_equal [C, Eb, G], chord.to_a
    
    chord = Chord.new('Abmin')
    assert_equal [Ab, Cb, Eb], chord.to_a
    
  end
  
  def test_augmented_chord
    
    chord = Chord.new('Caug')
    assert_equal [C, E, Gs], chord.to_a
    
    chord = Chord.new('C+')
    assert_equal [C, E, Gs], chord.to_a
    
    chord = Chord.new('C+9')
    assert_equal [C, E, Gs, Bb, D], chord.to_a
    
  end
  
  def test_diminished_chord
    
    chord = Chord.new('C°')
    assert_equal [C, Eb, Gb], chord.to_a
    
  end
  
  def test_seventh_chord
    
    chord = Chord.new('C7')
    assert_equal [C, E, G, B], chord.to_a
    chord = Chord.new('Cm7')
    assert_equal [C, Eb, G, Bb], chord.to_a
    chord = Chord.new('C+7')
    assert_equal [C, E, Gs, Bb], chord.to_a
    chord = Chord.new('Cdim7')
    assert_equal [C, Eb, Gb, A], chord.to_a
    
    chord = Chord.new('Ebdim7')
    assert_equal [Eb, Gb, A, C], chord.to_a
    
    chord = Chord.new('Cdim7')
    assert_equal [C, Eb, Gb, A], chord.to_a
    
  end
  
  def test_ninth_chord
    
    chord = Chord.new('C9')
    assert_equal [C, E, G, B, D], chord.to_a
    
    chord = Chord.new('Cm9')
    assert_equal [C, Eb, G, Bb, D], chord.to_a
    
  end
  
  def test_sus2_chord
    
    chord = Chord.new('Csus2')
    assert_equal [C, D, G], chord.to_a
    
  end
  def test_sus4_chord
    
    chord = Chord.new('Csus4')
    assert_equal [C, F, G], chord.to_a
    
  end
  
end