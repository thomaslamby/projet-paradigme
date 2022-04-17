local
   %Auteur : Thomas Lamby     NOMA: 27312000        
   % See project statement for API details.
   %[Project] = {Link ['Project2022.ozf']}
   %Time = {Link ['x-oz:\\boot\Time']}.1.getReferenceTime


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
	 note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] silence then
	 silence(duration:1.0)
      [] Atom then
	 case {AtomToString Atom}
	 of [_] then
	    note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
	 [] [N O] then
	    note(name:{StringToAtom [N]}
		 octave:{StringToInt [O]}
		 sharp:false
		 duration:1.0
		 instrument: none)
	 end
      end
   end

   % Cette fonction fixe la duree de la partition au nombre de secondes indique.
   fun {Duration Seconds Partition}
      local Sum Factor
	 Sum =
	 fun {$ Partition N}
	    case Partition
	    of nil then
	       N
	    [] H|T then
	       case H
	       of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
		  {Sum T N+H.duration}
	       [] silence(duration:Duration) then
		  {Sum T N+H.duration}
	       [] H2|T2 then
		  {Sum T N+H2.duration}
	       end
	    end
	 end
      in
	 Factor = {Float.'/' Seconds {Sum Partition 0.0}}
	 {Stretch Factor Partition}
	 
      end
   end
   
   % Cette fonction etire la duree de la partition par le facteur indique
   fun {Stretch Factor Partition}
      local X in
	 case Partition
	 of nil then
	    nil
	 [] H|T then
	    case H
	    of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	       X = note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration*Factor intrument:Instrument)
	       X|{Stretch Factor T}
	    [] silence(duration:Duration) then
	       X = silence(duration:H.duration*Factor)
           	       X|{Stretch Factor T}
	    [] H2|T2 then
	       case H2
	       of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
		  X = note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration*Factor intrument:Instrument)
		  X|{Stretch Factor T2}|{Stretch Factor T}
	       [] silence(duration:Duration) then %peut etre pas necessaire en pratique mais grammaire
		  X = silence(duration:H.duration*Factor)
		  X|{Stretch Factor T2}|{Stretch Factor T}
	       end
	    end
	 end
      end
   end
   
   % Cette fonction repete une partition comprenant la note Note un nombre Amount de fois
   fun {Drone Note Amount Partition}
      if Amount == 0 then
	 {PartitionToTimedList Partition}
      else
	 Note|{Drone Note Amount-1 Partition}
      end
   end    

	 
%Cette fonction transpose la partition d'un certain nombre de demi-tons vers le haut (entier positif) ou vers le bas (entier negatif) ainsi que l'octave si necessaire.
   ListNote = [c c# d d# e f f# g g# a a# b]
   ReverseListNote = {List.reverse ListNote}
   fun {Transpose Partition Nsemitones Noctave}
      nil
      local X Y Z
      in
	 case Partition
	 of nil then
	    nil
	 [] H|T then
	    if H.name == c then
	       if H.sharp == false then
		  Y = 1 + Nsemitones
		  if Y < 0 then
		     case ReverseListNote.(~Y)
		     of Name# then
			X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     else
			X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     end
		  else
		     case ListNote.Y
		     of Name# then
			X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     end
		  end
	       else
		  Y = 2 + Nsemitones
		  if Y < 0 then
		     if Y < ~1 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 10 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       end
	    elseif H.name == d
	       if H.sharp == false then
		  Y = 3 + Nsemitones
		  if Y < 0 then
		     if Y < ~2 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 9 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       else
		  Y = 4 + Nsemitones
		  if Y < 0 then
		     if Y < ~3 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 8 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       end
	    elseif H.name == e
	       Y = 5 + Nsemitones
	       if Y < 0 then
		  if Y < ~4 then
		     case ReverseListNote.(~Y)
		     of Name# then
			X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     else
			X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     end
		  else
		     case ReverseListNote.(~Y)
		     of Name# then
			X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     else
			X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     end
		  end
	       else
		  if Y > 7 then
		     case ListNote.Y
		     of Name# then
			X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     end
		  else
		     case ListNote.Y
		     of Name# then
			X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave}
		     end
		  end
	       end
	    elseif H.name == f
	       if H.sharp == false then
		  Y = 6 + Nsemitones
		  if Y < 0 then
		     if Y < ~5 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 6 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       else
		  Y = 7 + Nsemitones
		  if Y < 0 then
		     if Y < ~6 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 5 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       end
	    elseif H.name == g
	       if H.sharp == false then
		  Y = 8 + Nsemitones
		  if Y < 0 then
		     if Y < ~7 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 4 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       else
		  Y = 9 + Nsemitones
		  if Y < 0 then
		     if Y < ~8 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 3 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       end
	    elseif H.name == a
	       if H.sharp == false then
		  Y = 10 + Nsemitones
		  if Y < 0 then
		     if Y < ~9 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 2 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       else
		  Y = 11 + Nsemitones
		  if Y < 0 then
		     if Y < ~10 then
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave~1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave~1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ReverseListNote.(~Y)
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  else
		     if Y > 1 then
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     else
			case ListNote.Y
			of Name# then
			   X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave}
			end
		     end
		  end
	       end	       
	    elseif H.name == b
	       Y = 12 + Nsemitones
	       if Y < 0 then
		  case ReverseListNote.(~Y)
		  of Name# then
		     X = note(name:Name octave:H.octave+Noctave sharp:true instrument:H.instrument)
		     X|{Transpose T Nsemitones Noctave}
		  else
		     X = note(name:ReverseListNote.(~Y) octave:H.octave+Noctave sharp:false instrument:H.instrument)
		     X|{Transpose T Nsemitones Noctave}
		  end
	       else
		  case ListNote.Y
		  of Name# then
		     X = note(name:Name octave:H.octave+Noctave+1 sharp:true instrument:H.instrument)
		     X|{Transpose T Nsemitones Noctave}
		  else
		     X = note(name:ListNote.Y octave:H.octave+Noctave+1 sharp:false instrument:H.instrument)
		     X|{Transpose T Nsemitones Noctave}
		  end
	       end
	    end
	 end
      end
   end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
      case Partition
      of nil then
	 nil
      [] H|T then
	 case H
	 of Name#Octave then
	    {NoteToExtended H}|{PartitionToTimedList T}
	    
	 [] stretch(factor:Factor Partition) then
	    {Stretch H.factor {PartitionToTimedList  H.1}}|{PartitionToTimedList T}

	 [] duration(seconds:Duration Partition) then
     	    {Duration H.seconds {PartitionToTimedList H.1}}|{PartitionToTimedList T}

	 [] drone(note:Note amount:Amount) then
	    {Drone {PartitionToTimedList H.note} H.amount T}

	 [] transpose(semitones:Semitones Partition) then
	    {Transpose H.semitones {PartitionToTimedList Partition} {Int.'mod' H.semitones 12} {Int.'div' H.semitones 12}}

     [] H2|T2 then
     	    case H2

     	    of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
     	       H|{PartitionToTimedList T}

     	    [] silence(duration:Duration) then %pas sure qu'il y ai besoin en pratique mais grammaire
     	       H|{PartitionToTimedList T}

     	    [] Name#Octave then
     	       {PartitionToTimedList H}|{PartitionToTimedList T}

     	    [] Atom then
     	       {PartitionToTimedList H}|{PartitionToTimedList T}
     	    end
	    
	 [] silence then
	    {NoteToExtended H}|{PartitionToTimedList T}
	    
	 [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	    H|{PartitionToTimedList T}

	 [] silence(duration:Duration) then
	    H|{PartitionToTimedList T}

     [] Atom then
        {NoteToExtended H}|{PartitionToTimedList T}
	 end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %fun {Mix P2T Music}
      % TODO
    %  {Project.readFile 'wave\animals\cow.wav'}
   %end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Music = {Project.load 'joy.dj.oz'}
   %Start
   Son = [c c c b b silence]
   X = ~1
   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   %{Browse {PartitionToTimedList Son}}
   {Browse Son.(~X)}
   %Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   %{ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   %{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   %{Browse {IntToFloat {Time}-Start} / 1000.0}
   
end
