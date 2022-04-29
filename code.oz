local
   %Auteur : Thomas Lamby     NOMA: 27312000        
   % See project statement for API details.
   [Project] = {Link ['Project2022.ozf']}
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
   fun {Duration Seconds Partition T}
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
	 {Stretch Factor Partition T}
      end
   end
   
   % Cette fonction etire la duree de la partition par le facteur indique
   fun {Stretch Factor Partition V}
      local X in
	 case Partition
	 of nil then
	    {PartitionToTimedList V}
	 [] H|T then
	    case H
	    of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	       X = note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration*Factor intrument:Instrument)
	       X|{Stretch Factor T V}
	    [] silence(duration:Duration) then
	       X = silence(duration:H.duration*Factor)
	       X|{Stretch Factor T V}
	    [] H2|T2 then
	       case H2
	       of note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
		  X = note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration*Factor intrument:Instrument)
		  X|{Stretch Factor T2 nil}|{Stretch Factor T V}
	       [] silence(duration:Duration) then %peut etre pas necessaire en pratique mais grammaire
		  X = silence(duration:H.duration*Factor)
		  X|{Stretch Factor T2 nil}|{Stretch Factor T V}
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
   ListNote = record(c c#s d d#s e f f#s g g#s a a#s b)
   ReverseListNote = record(b a#s a g#s g f#s f e d#s d c#s c)
   fun {Transpose Partition Nsemitones Noctave V}
      local X Y Z
      in
	 case Partition
	 of nil then
	    {PartitionToTimedList V}
	 [] H|T then
	    if H.name == c then
	       if H.sharp == false then
		  Y = 1 + Nsemitones
		  if Y =< 0 then
		     Z = Y + (~1)
		     case ReverseListNote.(~Z)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.Y
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       else
		  Y = 2 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == d then
	       if H.sharp == false then
		  Y = 3 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
          		case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       else
		  Y = 4 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
         			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == e then
	       Y = 5 + Nsemitones
	       if Nsemitones < 0 then
		  if Y =< 0 then
		     Z = Y + (~1)
		     case ReverseListNote.(~Z)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
           			else
			X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.(Y)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       else
		  if Y > 12 then
		     Z = Y + (~12)
		     case ListNote.Z
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.Y
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       end
	    elseif H.name == f then
	       if H.sharp == false then
		  Y = 6 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       else
		  Y = 7 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == g then
	       if H.sharp == false then
		  Y = 8 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       else
		  Y = 9 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == a then
	       if H.sharp == false then
		  Y = 10 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       else
		  Y = 11 + Nsemitones
		  if Nsemitones < 0 then
		     if Y =< 0 then
			Z = Y + (~1)
			case ReverseListNote.(~Z)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.(Y)
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  else
		     if Y > 12 then
			Z = Y + (~12)
			case ListNote.Z
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     else
			case ListNote.Y
			of Name#s then
			   X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			else
			   X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			   X|{Transpose T Nsemitones Noctave V}
			end
		     end
		  end
	       end
	    elseif H.name == b then
	       Y = 12 + Nsemitones
	       if Nsemitones < 0 then
		  if Y =< 0 then
		     Z = Y + (~1)
		     case ReverseListNote.(~Z)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+(~1) sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ReverseListNote.(~Z) octave:H.octave+Noctave+(~1) sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.(Y)
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ReverseListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       else
		  if Y > 12 then
		     Z = Y + (~12)
		     case ListNote.Z
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave+1 sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Z octave:H.octave+Noctave+1 sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  else
		     case ListNote.Y
		     of Name#s then
			X = note(name:Name octave:H.octave+Noctave sharp:true duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     else
			X = note(name:ListNote.Y octave:H.octave+Noctave sharp:false duration:H.duration instrument:H.instrument)
			X|{Transpose T Nsemitones Noctave V}
		     end
		  end
	       end
	    end
	 end
      end
   end
   
% Cette fonction prend une partition en entree et retourne une flat partition.

   fun {PartitionToTimedList Partition}
      case Partition
      of nil then
	 nil
      [] H|T then
	 case H
	 of Name#Octave then
	    {NoteToExtended H}|{PartitionToTimedList T}
	    
	 [] duration(seconds:Duration Partition) then
	    if {Int.is H.seconds} then
	       {Duration {Int.toFloat H.seconds} {PartitionToTimedList H.1} T}
	    else
	       {Duration H.seconds {PartitionToTimedList H.1} T}
	    end
	    
	 [] stretch(factor:Factor Partition) then
	    if {Int.is H.factor} then
	       {Stretch {Int.toFloat H.factor} {PartitionToTimedList H.1} T}
	    else
	       {Stretch H.factor {PartitionToTimedList H.1} T}
	    end
	    
	 [] drone(note:Note amount:Amount) then
	    if {Int.is Amount} then
	       {Drone {PartitionToTimedList H.note} H.amount T}
	    else
	       {Drone {PartitionToTimedList H.note} {Float.toInt H.amount} T}
	    end

	 [] transpose(semitones:Semitones Partition) then
	       {Transpose {PartitionToTimedList Partition} {Int.'mod' H.semitones 12} {Int.'div' H.semitones 12} T}

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

%Cette fonction additionne deux listes
   fun {AddList L1 L2}
      case L1
      of H1|T1 then
	 case L2
	 of H2|T2 then
	    (H1 + H2)|{AddList T1 T2}
	 [] nil then
	    H1|T1
	 end
      [] nil then
	 case L2
	 of H2|T2 then
	    H2|T2
	 [] nil then
	    nil
	 end
      end
   end

%Cette fonction multiplie les entrées d'une liste par un facteur
   fun {MultiplyList Factor EchantillonList}
      case EchantillonList
      of H|T then
	 (H * Factor)|{MultiplyList Factor T}
      [] nil then
	 nil
      end
   end
   
%Cette fonction additione les echantillons des musiques de la liste Musicwithintensifies apres les avoir multiplier par leur facteur.

   fun {Merge P2T Musicwithintensifies}
	 case Musicwithintensifies
	 of H|T then
	    case H
	    of Factor#Music then
	       {AddList {MultiplyList Factor {Mix2 P2T Music}} {Merge P2T T}}
	    end
	 [] nil then
	    nil
	 end
      end
   
   
%Cette fonction repete une musique un nombre Amount de fois

   fun {Repeat Amount Samples}
      if Amount > 0 then
	 {Concat Samples {Repeat Amount+(~1) Samples}}
      else
	 nil
      end
   end
   
%Cette fonction boucle une musique pendant Duration secondes

   fun {Loop Duration Samples}
      local X Y Z A B
      in
	 X = {List.length Samples}
	 Y = Duration * 44100.0
	 Z = {Int.'div' {Float.toInt Y} X}
	 A = {Int.'mod' {Float.toInt Y} X}
	 if Z > 0 then
	    if A > 0 then
	       {List.take Samples A B}
	       {Concat {Repeat Z Samples} B}
	    else
	       {Repeat Z Samples}
	    end
	 else
	    if A > 0 then
	       {List.take Samples A B}
	       B
	    else
	       nil
	    end
	 end
      end
   end
   
%Cette fonction contraint les echantillons a une valeur plancher et plafond

   fun {Clip Low High Samples}
      case Samples
      of H|T then
	 if H < Low then
	    Low|{Clip Low High T}
	 elseif H > High then
	    High|{Clip Low High T}
	 else
	    H|{Clip Low High T}
	 end
      else
	 nil
      end
   end
      

%Cette fonction introduit un echo avec un delais de Delay de secondes et intensifier par un nombre decay.

   fun {Echo Delay Decay Samples}
      local AddSilence X Y Z
	 AddSilence =
	 fun {$ Amount}
	    if Amount > 0.0 then
	       0.0|{AddSilence Amount+(~1.0)}
	    else
	       nil
	    end
	 end
      in
	 X = Delay * 44100.0
	 Y = {MultiplyList Decay Samples}
	 Z = {Concat {AddSilence X} Y}
	 {AddList Z Samples}|nil
      end
   end

%Cette fonction creer un fondu au debut et a la fin d'une musique d'une duree respective de start et finish secondes
   fun{Fade Start Out Samples}
      local X Y A B FadeStartOut C D E F
	 FadeStartOut =
	 fun {$ X Y Depart Samples}
	    case Samples
	    of H|T then
	       if X > 0.0 then
		  (Depart * Y)|{FadeStartOut X+(~1.0) Y (Depart+1.0) T}
	       else
		  Samples
	       end
	    end
	 end
      in
	 X = Start * 44100.0
	 Y = {Float.'/' 1.0 X}
	 A = Out * 44100.0
	 B = {Float.'/' 1.0 A}
	 C = {FadeStartOut X Y 0.0 Samples}
	 {List.reverse C D}
	 E = {FadeStartOut A B 0.0 D}
	 {List.reverse E}
      end
   end

%Cette fonction recupere la partie de la musique qui se trouve entre Start et Finish secondes, si cette intervalle est plus grand que la musique, celle ci est completer par du silence
   fun {Cut Start Finish Samples}
      local X Y Z Cut2 Cut3
	 Cut2 =
	 fun {$ X Samples}
	    case Samples
	    of H|T then
	       if X > 0.0 then
		  {Cut2 X+(~1.0) T}
	       else
		  H|T
	       end
	    else
	       nil
	    end
	 end
	 
	 Cut3 =
	 fun {$ Z Y}
	    case Y
	    of H|T then
	       if Z > 0.0 then
		  H|{Cut3 Z+(~1.0) T}
	       else
		  nil
	       end
	    else
	       if Z > 0.0 then
		  0.0|{Cut3 Z+(~1.0) nil}
	       else
		  nil
	       end
	    end
	 end	 
      in
	 X = Start * 44100.0
	 Y = {Cut2 X Samples}
	 Z = (Finish*44100.0)+(~X)
	 {Cut3 Z Y}
      end
   end
   
%Cette fonction concat 2 listes
   fun {Concat L1 L2}
      case L1
      of H|T then
	 H|{Concat T L2}
      [] nil then
	 L2
      else
	 L1|L2
      end
   end	 
	 
%Cette fonction calcule la %formule pour convertir le temps de la note en nombre d'echantillon ainsi que la fr�quence
   fun {Echantillon FlatPartition Depart}
      local Hauteur F D A 
      in
	 case FlatPartition
	 of nil then
	    nil
	 [] H|T then
	    case H
	    of silence(duration:Duration) then
	       D = H.duration * 44100.0
	       {Concat {Echantillon2 D 0 Depart} {Echantillon T 0.0}}
	    [] nil then
	       nil
	    [] note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument) then
	       if H.name == c then
		  if H.sharp == false then
		     Hauteur = (~9.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}
		  else
		     Hauteur = (~8.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}
		  end
	       elseif H.name == d then
		  if H.sharp ==false then
		     Hauteur = (~7.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}
		  else
		     Hauteur = (~6.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}

		  end
	       elseif H.name == e then
		     Hauteur = (~5.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}

	       elseif H.name == f then
		  if H.sharp == false then
		     Hauteur = (~4.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}

		  else
		     Hauteur = (~3.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}

		  end
	       elseif H.name == g then
		  if H.sharp == false then
		     Hauteur = (~2.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}
		  else
		     Hauteur = (~1.0) + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}
		  end
	       elseif H.name == a then
		  if H.sharp == false then
		     Hauteur = 0.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}

		  else
		     Hauteur = 1.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
		     F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		     D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}

		  end
	       elseif H.name == b then
		  Hauteur = 2.0 + (({Int.toFloat H.octave} - 4.0) * 12.0)
		  F = {Number.pow 2.0 {Float.'/' Hauteur 12.0}} * 4410.0
		  D = (H.duration * 44100.0)
		     {Concat {Echantillon2 D F Depart} {Echantillon T 0.0}}
	       end
	    end
	 end
      end
   end
   
%Cette fonction est la suite d'echantillon et calcule la valeur des echantillons pour une note
   fun {Echantillon2 D F Depart}
      local
	 A
      in
	 if D == 0.0 then
	    nil
	 else
	    if F == 0.0 then
	       0.0|{Echantillon2 D+(~1.0) F Depart+1.0}
	    else
	       A = 0.5 * {Float.sin ({Float.'/' (2.0 * 3.1415926535 * F * Depart) 44100.0})}
	       A|{Echantillon2 D+(~1.0) F Depart+1.0}
	    end
	 end
      end
   end

%Cette fonction prend une musique en entree et retourne une liste d'echantillon.(Mix2 est le pour permettre la recursion)

   fun {Mix P2T Music}
      {Mix2 P2T Music}
   end  

   fun {Mix2 P2T Music}
      local X
      in
	 case Music
	 of nil then
	    nil
	 [] H|T then
	    case H
	    of samples(Samples) then
	       {Concat H.1 {Mix2 P2T T}}

	    [] partition(Partition) then
	       {Concat {Echantillon {P2T H.1} 0.0} {Mix2 P2T T}}
	    
	    [] wave(Filename) then
	       {Concat {Project.load H.1} {Mix2 P2T T}}
	    
	    [] merge(Musicwithintensifies) then
	       {Concat {Merge P2T H.1} {Mix2 P2T T}}

	    [] reverse(Music) then
	       {List.reverse {Mix2 P2T H.1} X}
	       {Concat X {Mix2 P2T T}}

	    [] repeat(amount:Amount Music) then
	       {Concat {Repeat H.amount {Mix2 P2T H.1}} {Mix2 P2T T}}

	    [] loop(duration:Duration Music) then
	       {Concat {Loop H.duration {Mix2 P2T H.1}} {Mix2 P2T T}}

	    [] clip(low:Float high:Float2 Music) then
	       {Concat {Clip H.low H.high {Mix2 P2T H.1}} {Mix2 P2T T}}

	    [] echo(delay:Duration decay:Factor Music) then
	       X = {Echo H.delay H.decay {Mix2 P2T H.1}}
	       {Concat X {Mix2 P2T T}}

	    [] fade(start:Duration out:Duration2 Music) then
	       {Concat {Fade H.start H.out {Mix2 P2T H.1}} {Mix2 P2T T}}

	    [] cut(start:Duration finish:Duration2 Music) then
	       {Concat {Cut H.start H.finish {Mix2 P2T H.1}} {Mix2 P2T T}}
	    end
	 end
      end	     
    %  {Project.readFile 'wave\animals\cow.wav'}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Music = {Project.load 'joy.dj.oz'}
   Music = [cut(start:1.0 finish:8.0 [partition(Truc)])]
   %Music = [merge([0.5#Truc 0.2#Truc])]
   Truc = [c c note(name:c octave:4 sharp:false duration:1.0 instrument:none) note(name:c octave:4 sharp:false duration:1.0 instrument:none) c c]
   %Start
in
   
   %Start = {Time}
   {Browse {Mix PartitionToTimedList Music}}
   %{Browse Truc.1}
   %{Browse Music.1}

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